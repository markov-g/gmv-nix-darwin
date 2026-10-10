// jev-systemone: a custom OpenCode tool wrapping Siemens' Jev SystemOne
// Structured Decisions (Preview) protocol.
//
// PROVENANCE: this is TypeSafe's (typesafe.ai) "System One" protocol, run as
// a Siemens-hosted deployment at api.siemens.com/llm/v1/systemone -- "Jev"
// is TypeSafe's model family name, "SystemOne" is the protocol/endpoint
// name. Full upstream docs: https://docs.typesafe.ai (llms.txt index at
// https://docs.typesafe.ai/llms.txt). Siemens' own docs describe the same
// wire protocol under the model id "diffusiongemma-26b-a4b-it" --
// TypeSafe's own docs use "jev-latest"/"jev-1.12" model ids instead. Use
// Siemens' model id here since this tool talks to Siemens' gateway
// specifically, not TypeSafe's hosted API -- do not assume these two
// deployments share a model catalog or behave identically; Siemens' is
// explicitly Preview.
//
// WHY A PLUGIN TOOL, NOT A PROVIDER ENTRY
// -----------------------------------------
// opencode.jsonc's "provider" block (see the "siemens" entry there) only
// works for conversational chat-completion models -- OpenCode sends
// messages, gets text back, via the OpenAI-compatible adapter. SystemOne is
// a genuinely different protocol: POST /v1/systemone takes a `state` plus a
// map of typed `questions` (noul/choice/score) and returns structured
// `answers` with probabilities -- not a chat turn. It cannot be a /preset or
// /model choice; it has to be something the agent calls explicitly, the
// same way it calls read/edit/bash. OpenCode's plugin API supports exactly
// this (a custom `tool()` with a typed args schema and an execute function
// that can do arbitrary work, including an HTTP call) -- confirmed from
// opencode.ai/docs/plugins "Events"/tool registration section. An MCP
// server was considered and rejected for this one: MCP is the right choice
// when you want a persistent external process with its own state (Engram's
// SQLite store, its own CLI, its own lifecycle) -- SystemOne is a single
// stateless REST call with no local state of its own, so a plugin tool
// making a direct fetch() is simpler and has one fewer moving part.
//
// WHAT THIS TOOL IS FOR, AND WHAT IT IS NOT (per TypeSafe's own design
// philosophy, confirmed from docs.typesafe.ai/concepts/how-to-build-with-
// system-one -- read this section before changing the tool description)
// -----------------------------------------------------------------------
// "System One is TypeSafe's model for building AI-powered software, NOT
// agents. It does not generate code or choose its own next action." The
// documented pattern is: CODE stays in control of the workflow; this tool
// answers narrow, atomic, typed questions that code (or the orchestrator,
// acting as code here) then combines with its own logic/thresholds. Do not
// use this as a substitute for normal reasoning, writing, or chat -- use it
// specifically for classification, routing, scoring, and similar structured
// judgments where a calibrated probability is more useful than prose.
// TypeSafe's own guidance, repeated here because they call it "probably the
// most important concept": ask narrow, ATOMIC questions (one judgment per
// question) rather than one broad question hiding several judgments: ask
// many decomposed questions about the same `state` in ONE request (they
// run in parallel server-side) rather than one vague question or several
// separate calls.
//
// AUTH
// -----
// Uses CODE_SIEMENS_COM_LLM_API_KEY -- explicitly a DIFFERENT credential
// from the existing "siemens" provider's SIEMENS_API_KEY in opencode.jsonc,
// even though both target the same api.siemens.com/llm/v1 base URL. Do not
// assume these keys are interchangeable; each must carry the `llm` scope
// for its respective endpoint per Siemens' own docs. If this env var is
// unset, the tool returns a clear error instead of attempting the call and
// failing with an opaque 401 -- confirmed unset in the shell this was
// written in, so this path should be expected to fire until the key is
// exported wherever this repo's other API keys are (see opencode.jsonc's
// "anthropic"/"azure"/"siemens" provider "env" arrays for the sibling
// pattern -- this key was NOT added to any of those blocks, since none of
// them are the right place for a non-chat credential).
//
// SCOPE AND LIMITS -- TWO DOCS DISAGREE, DOCUMENTED HONESTLY RATHER THAN
// PICKING ONE SILENTLY
// -----------------------------------------------------------------------
// - Context limit: Siemens' docs say 8,192 tokens total, including question
//   instructions and state. TypeSafe's own docs give no fixed token limit,
//   only "send only relevant context." Treat 8,192 as the binding limit
//   since this tool calls Siemens' gateway specifically -- do not pass
//   large files or long transcripts as `state`; summarize first if needed.
// - Question count: both docs agree -- up to 64 questions per request.
//   Batch related questions about the same state into one call.
// - Choice/Score option counts: THE TWO DOCS DISAGREE. Siemens' docs say
//   "between 2 and 26 alternatives" for both choice and score combined.
//   TypeSafe's own docs say choice allows "a maximum of 255 options" and
//   score "at least two levels... up to 10." This plugin does NOT enforce
//   either ceiling client-side -- it passes through to Siemens' gateway and
//   lets a real 422 response (with the offending-field detail TypeSafe's
//   error docs promise) be authoritative, rather than guessing which
//   number applies to this specific deployment.
// - Question IDs: non-empty, no colon, no newline (both docs agree).
// - Preview model -- Siemens' own docs say to measure latency and decision
//   quality for your use case before relying on it for anything load-bearing.
//
// RETRY BEHAVIOR
// ----------------
// TypeSafe's docs document 429 (rate limit) and 529 (overloaded) as
// retry-with-exponential-backoff conditions, noting their own SDKs handle
// this automatically. This plugin is not an SDK, so it replicates that
// policy directly: up to 3 attempts, doubling the delay each time,
// starting at 500ms. Any other non-2xx status is NOT retried and is
// returned to the agent immediately as an error (401/422 are caller
// mistakes, not transient -- retrying them wastes calls and masks the
// real problem).
//
// KNOWN FAILURE MODE TO GUARD AGAINST: per TypeSafe's own "Common issues"
// docs, "the agent invents request or response fields" is a recurring,
// named problem, usually from a stale schema/skill. The args schema below
// is typed as closely as practical to the documented request shape
// specifically to make an invented field a schema-validation error the
// agent sees immediately, rather than a silently-malformed request.

import type { Plugin } from "@opencode-ai/plugin";
import { z } from "zod";

const SYSTEMONE_URL = "https://api.siemens.com/llm/v1/systemone";
const MODEL = "diffusiongemma-26b-a4b-it";
const MAX_RETRIES = 3;
const RETRY_BASE_DELAY_MS = 500;

// "instructions" and "criteria" descriptions can each be a plain string, OR
// a structured object/array -- per TypeSafe's documented pattern of putting
// the question in one field and supporting data in named sibling fields,
// then referencing that data from the question text via a backticked name
// (e.g. "Is this the same person as `potential_duplicate`?"). Supporting
// both shapes, not just string, is what the original version of this file
// was missing -- TypeSafe's own docs call this "probably the most
// important concept" for building good System One questions.
const structuredText = z.union([
  z.string(),
  z.record(z.string(), z.unknown()),
  z.array(z.unknown()),
]);

const questionSchema = z.record(
  z.string(),
  z.union([
    z.object({
      type: z.literal("noul"),
      instructions: structuredText,
      criteria: z
        .object({ true: structuredText.optional(), false: structuredText.optional() })
        .optional(),
    }),
    z.object({
      type: z.literal("choice"),
      instructions: structuredText,
      criteria: z.record(z.string(), structuredText.nullable()),
    }),
    z.object({
      type: z.literal("score"),
      instructions: structuredText,
      criteria: z.array(structuredText),
    }),
  ]),
);

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export const JevSystemOnePlugin: Plugin = async () => {
  return {
    tool: {
      jev_systemone: {
        description:
          "Ask Siemens' Jev SystemOne (DiffusionGemma 26B, TypeSafe-compatible protocol) " +
          "narrow, atomic, typed questions about a piece of context and get back structured " +
          "answers with calibrated probabilities -- yes/no (noul), multiple-choice (choice), " +
          "or ordered-scale (score). This is NOT a chat model: it does not write prose, " +
          "generate code, or choose its own next action -- use it only for classification, " +
          "routing, and priority/severity scoring where code (you, acting as the caller) " +
          "combines the typed answers with your own logic afterward. Prefer several narrow " +
          "questions over one broad question (ask 'is this urgent', 'which team', 'how " +
          "frustrated' as separate questions, not one compound judgment). Batch all related " +
          "questions about the same state into ONE call -- they run in parallel server-side. " +
          "Context limit is 8192 tokens total (state + all question instructions combined) " +
          "-- summarize large input before passing it as state. Only use the exact request " +
          "fields documented here (state, questions{type,instructions,criteria}) -- do not " +
          "invent additional fields.",
        args: {
          state: structuredText.describe(
            "The context to evaluate -- plain text, or a JSON object/array (e.g. a support " +
              "ticket, chat log, or record). Prefer an object with named fields over a flat " +
              "string so each part of the state is unambiguous.",
          ),
          questions: questionSchema.describe(
            "Map of question ID -> question definition, 1-64 entries. IDs must be non-empty " +
              "and contain no colon or newline. noul = yes/no (returns a 0-1 probability); " +
              "choice = pick one named option (returns the choice + a probability per option); " +
              "score = rate on an ordered scale (returns a probability-weighted score + a " +
              "probability per level). For any question, 'instructions' can be a plain string " +
              "or a structured object/array holding the question plus named supporting data, " +
              "referenced from the question text in backticks, e.g. instructions: " +
              '{ "potential_duplicate": {...}, "question": "Same person as `potential_duplicate`?" }.',
          ),
        },
        async execute(args) {
          const apiKey = process.env.CODE_SIEMENS_COM_LLM_API_KEY;
          if (!apiKey) {
            return (
              "jev_systemone error: CODE_SIEMENS_COM_LLM_API_KEY is not set in this " +
              "environment. This is a separate credential from SIEMENS_API_KEY (the existing " +
              "siemens provider in opencode.jsonc) -- it must be exported wherever this " +
              "repo's other API keys are configured before this tool can authenticate."
            );
          }

          const body = JSON.stringify({
            model: MODEL,
            state: args.state,
            questions: args.questions,
          });

          let lastError = "";
          for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
            const response = await fetch(SYSTEMONE_URL, {
              method: "POST",
              headers: {
                Authorization: `Bearer ${apiKey}`,
                "Content-Type": "application/json",
              },
              body,
            });

            if (response.ok) {
              const data = await response.json();
              return JSON.stringify(data, null, 2);
            }

            // Only 429 (rate limited) and 529 (overloaded) are transient --
            // retry those with exponential backoff per TypeSafe's documented
            // policy. Everything else (401 auth, 422 validation, etc.) is a
            // caller-side problem that retrying cannot fix -- surface it
            // immediately instead of wasting attempts and hiding the cause.
            const responseBody = await response.text().catch(() => "<unreadable body>");
            lastError = `HTTP ${response.status} ${response.statusText} -- ${responseBody}`;

            const isRetryable = response.status === 429 || response.status === 529;
            if (!isRetryable || attempt === MAX_RETRIES) {
              return `jev_systemone error: ${lastError}`;
            }

            await sleep(RETRY_BASE_DELAY_MS * 2 ** (attempt - 1));
          }

          return `jev_systemone error: ${lastError}`;
        },
      },
    },
  };
};
