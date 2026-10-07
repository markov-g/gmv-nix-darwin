// engram-nudge: a mechanical backstop for Engram memory saves.
//
// WHY THIS EXISTS
// ----------------
// This repo deliberately wires Engram into OpenCode via the "manual MCP-only"
// path (see opencode.jsonc's "mcp.engram" block) rather than running
// `engram setup opencode`, specifically to avoid an imperative install step
// mutating config outside Nix. That gives the agent the mem_* TOOLS, but
// the only instruction telling it WHEN to use them was a paragraph in
// AGENTS.md -- which in practice turned out to be exactly as weak as any
// other buried instruction competing for the model's attention against a
// louder, more specific orchestrator prompt (oh-my-opencode-slim's
// "Ultraworker" prompt). Confirmed empirically this session: a long, real
// working session produced zero mem_save calls until the user asked
// directly. The real fix for THAT is in oh-my-opencode-slim.jsonc's
// orchestrator prompt itself (a "## Memory (Engram, mandatory, not
// optional)" section was added there, in the loud prompt, not a separate
// file) -- this plugin is a narrower, second-line mechanism, not the
// primary fix.
//
// REVISION NOTE: an earlier version of this file fired a macOS
// notification (osascript) at the user on an idle timer. Rejected --
// bothering a human with a popup is not an acceptable way to compensate
// for the agent not doing its job. Removed entirely. What remains below is
// deliberately narrower: logging only (visible via `opencode log`/the
// client logger, never interrupts you), plus the one mechanism that
// targets the AGENT's own context rather than you.
//
// WHAT THIS DOES, AND WHY EACH PIECE USES ONLY DOCUMENTED HOOKS
// --------------------------------------------------------------
// Engram's own real OpenCode plugin (plugin/opencode/engram.ts, not used
// here) achieves proactive reminding via an UNDOCUMENTED hook
// ("experimental.chat.system.transform") found only by reading their
// source -- it does not appear in OpenCode's public plugin docs
// (opencode.ai/docs/plugins "Events" list). Depending on an unpublished
// hook risks silent breakage on an OpenCode upgrade with no changelog
// entry to warn you. This file uses ONLY hooks confirmed in the public
// Events list:
//
//   - "tool.execute.after"              (documented: Tool Events)
//   - "experimental.session.compacting" (documented: dedicated "Compaction
//                                        hooks" section with a worked example)
//   - "event" with event.type === "session.idle" (documented: Session
//                                        Events -- used here for a log
//                                        line only, see revision note above)
//
// Mechanism:
//   1. Track mem_save / mem_session_summary tool calls in-process (no
//      dependency on Engram's HTTP API -- we don't run `engram serve`,
//      see opencode.jsonc's comment on why).
//   2. On "experimental.session.compacting", inject a reminder into the
//      compaction context -- mirroring Engram's own plugin's stated
//      rationale ("the old agent dies, a new one starts with the
//      compacted summary -- this is our chance to remind it"). This
//      targets the AGENT's own next context, not the human. It is injected
//      at the single highest-value moment (right before memory of any
//      prior instruction would otherwise be wiped), not just once at cold
//      start.
//   3. On session.idle, if a save is overdue, write a structured LOG entry
//      only (via client.app.log) -- visible if you go looking, never
//      pushed at you. This is a deliberate downgrade from the earlier
//      notification: it trades "impossible to miss" for "never annoying,"
//      on the reasoning that a frequent unwanted interruption is worse
//      than an occasional missed save you can always catch by asking the
//      agent directly, as you already do.
//
// HONEST LIMITATION (unchanged from the original design)
// ---------------------------------------------------------
// No documented OpenCode hook lets plugin code invoke another MCP server's
// tool directly on the model's behalf. This plugin cannot force a save.
// The compaction-context injection (#2 above) is the only part of this
// file that has a real chance of changing agent behavior mechanically;
// the idle-log (#3) is a passive diagnostic aid, not a behavior fix --
// treat the orchestrator-prompt change in oh-my-opencode-slim.jsonc as the
// actual fix, and this file as a narrow supplement to it.
//
// CONFIG (environment variables, all optional)
// ----------------------------------------------
//   ENGRAM_NUDGE_THRESHOLD_SECS  minutes-since-last-save before logging
//                                 (default: 900 = 15 minutes)
//   ENGRAM_NUDGE_COOLDOWN_SECS   minimum gap between repeat log entries
//                                 (default: 900 = 15 minutes)
//
// DEPLOYMENT
// -----------
// This is a LOCAL plugin file, auto-loaded from the global plugin directory
// at OpenCode startup (opencode.ai/docs/plugins: "Files in these
// directories are automatically loaded at startup" -- no entry needed in
// opencode.jsonc's "plugin" array, that array is for npm packages only).
// Deployed here via home.nix (Nix-managed, same as every other dotfile in
// this repo), gated to hosts listed in modules/engram-hosts.nix -- same
// gate as the mcp.engram block itself, since this plugin is meaningless
// without Engram actually being installed.

const THRESHOLD_SECS = Number(process.env.ENGRAM_NUDGE_THRESHOLD_SECS ?? 900);
const COOLDOWN_SECS = Number(process.env.ENGRAM_NUDGE_COOLDOWN_SECS ?? 900);

const nowSecs = () => Math.floor(Date.now() / 1000);

// Module-level state: this plugin is written for a single local developer's
// machine (this repo's whole premise), not a multi-tenant server, so global
// (not per-session) tracking is a deliberate simplification -- it avoids
// depending on unverified assumptions about what shape the "session.idle"
// event payload carries (the official docs' own example does not read any
// session identifier off it either).
let lastSaveTime = nowSecs();
let lastNudgeTime = 0;

export const EngramNudgePlugin = async ({ client }: any) => {
  return {
    "tool.execute.after": async (input: any) => {
      const toolName = typeof input?.tool === "string" ? input.tool : "";
      if (/mem_save|mem_session_summary/i.test(toolName)) {
        lastSaveTime = nowSecs();
      }
    },

    "experimental.session.compacting": async (_input: any, output: any) => {
      output.context.push(
        "## Memory reminder (post-compaction)\n\n" +
          "This session was just compacted -- you are continuing from a summary, " +
          "not the original conversation. Before anything else:\n" +
          "1. If Engram's mem_* tools are available in this session, call " +
          "`mem_session_summary` to persist what you now know, then `mem_context` " +
          "if you need more detail than the summary provides.\n" +
          "2. Resume proactively saving decisions, fixes, and discoveries with " +
          "`mem_save` as you make them -- do not wait to be asked."
      );
    },

    event: async ({ event }: any) => {
      if (event?.type !== "session.idle") return;

      const now = nowSecs();
      const sinceLastSave = now - lastSaveTime;
      const sinceLastNudge = now - lastNudgeTime;

      if (sinceLastSave < THRESHOLD_SECS || sinceLastNudge < COOLDOWN_SECS) {
        return;
      }

      lastNudgeTime = now;
      const minutes = Math.floor(sinceLastSave / 60);

      // Log only -- never surfaces as a popup/notification/interruption.
      // Visible via OpenCode's own logging if you go looking; does nothing
      // on its own otherwise. See the file header's revision note for why
      // the earlier osascript-notification version was removed.
      try {
        await client?.app?.log?.({
          body: {
            service: "engram-nudge",
            level: "warn",
            message: `No Engram memory save in ${minutes} minutes.`,
          },
        });
      } catch {
        // Best-effort only; a logging failure here should never throw or
        // otherwise disrupt the session.
      }
    },
  };
};
