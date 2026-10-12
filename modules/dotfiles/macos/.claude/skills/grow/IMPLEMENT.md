## implement -- Implementation phase quiz

Code or configuration is written. Quiz on what language/framework/tool concepts were
used and why the code is structured the way it is.

Generate questions from the actual code written:
- What does this construct do, and why was it chosen over the alternative?
- What would break if this line were removed?
- What invariant does this code rely on?
- If a colleague asked you why this is structured this way, what would you say?

**Examples of the kind of question to generate:**
- "We used lib.hm.dag.entryAfter in the activation script. What does that guarantee
  about the ordering of activation steps, and what breaks if it runs too early?"
- "The symlink in home.nix uses .source =, not .text =. What is the difference, and
  why does it matter for Nix store paths?"

**In-session exercise** (tight feedback loop): Ask the user to find something specific:

> "Find the line in <file> where <thing> is set. Read the comment above it. Tell me
> what would happen if that line were missing."

You look, I verify. Immediate feedback. This is the exercise that cannot be skipped.

**Async exercise** (written to ~/learning/queue.md): Re-derivation task with SRS dates.

```
## 2026-07-28 -- <concept slug>
<Re-derive task: write from scratch, explain without looking it up, then verify at file:line>
Due: 2026-07-29 (1-day)
Next: 2026-07-31 (3-day) / 2026-08-04 (1-week) / 2026-08-18 (2-week) / 2026-09-18 (1-month)
```
