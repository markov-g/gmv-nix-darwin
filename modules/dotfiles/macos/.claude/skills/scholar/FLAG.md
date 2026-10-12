## flag -- Inline detection and background delegation

This is the most common invocation. It fires when you detect a novelty signal in the
session. The user should barely feel it.

**Novelty signals to watch for:**

- A new approach to a known problem that avoids a known limitation
- An unusual or non-obvious combination of techniques
- An existing method applied to a domain where it has not been applied before
- An empirical observation that contradicts a common assumption
- A tool, system, or method that enables something previously impractical
- A theoretical model or framework that explains something previously unexplained
- An optimization that significantly improves on the current state of the art
- A design decision that solves a hard problem in a way not found in the literature
- Anything where the honest reaction is "I haven't seen this done this way before"

**When a signal is detected:**

1. Flag inline in 1-2 sentences -- do not expand, do not interrupt the flow:
   > "[Scholar] Flagged: <brief description of the potentially novel thing>. Spinning
   > up a background investigation -- continuing our discussion."

2. Immediately spin up a background agent using the Agent tool with
   `run_in_background: true` and `subagent_type: general-purpose`.

   The agent brief must include:
   - What was flagged and why it looks potentially novel
   - The full context: what problem was being solved, what approach was taken, what
     makes it non-obvious
   - Current date (for IP timing calculation)
   - Instruction to write findings to ~/research/ideas/YYYY-MM-DD-<slug>.md
   - Instruction to report a 3-line summary when done

3. Resume the main conversation immediately. Do not wait for the agent.

**Background agent instructions (include verbatim in the agent brief):**

```
You are a research and IP triage agent. You have been given a potentially novel idea
from an engineering/research session. Your tasks:

1. Prior art search: Search across:
   - Google Patents (patents.google.com)
   - arXiv (arxiv.org) -- cs.SE, cs.AI, cs.NI, cs.DC, cs.OS
   - ACM Digital Library (dl.acm.org)
   - IEEE Xplore (ieeexplore.ieee.org)
   - GitHub (for open-source prior implementations)
   Use WebSearch and WebFetch. Search for the core technique, not the application domain.

2. Triage -- classify as one of:
   - patent-candidate: appears novel, non-obvious, has utility, no clear prior art
   - paper: publishable contribution, prior art exists but not this specific approach
   - workshop: interesting observation, narrower contribution
   - not-novel: clear prior art, or obvious extension of existing work
   - investigate: prior art search inconclusive, needs deeper search

3. Write findings to ~/research/ideas/<YYYY-MM-DD>-<slug>.md:
   ---
   date: YYYY-MM-DD
   status: raw
   type: <classification>
   title: <short descriptive title>
   session-context: <1-2 sentences on what we were working on>
   ---

   ## Core idea
   <2-3 sentences: what the idea is, why it is non-obvious>

   ## Prior art found
   <list with links -- or "None found" if clean>

   ## Triage rationale
   <1 paragraph: why this classification>

   ## IP timing notice
   (Include only if type is patent-candidate)
   Public disclosure before filing is an absolute novelty bar in EU, Asia, and most
   jurisdictions. In the US, a 12-month grace period exists after first public
   disclosure. A provisional patent application is inexpensive and buys 12 months of
   patent-pending status. Do not disclose this publicly -- in a paper, talk, GitHub
   commit, or public repo -- until you have decided whether to file.

   ## Next steps
   <2-3 bullet points: what would need to happen to develop this further>

4. Append one line to ~/research/log.md:
   <date>  <slug>  <type>  <3-word summary>

5. Return a 3-line summary:
   Line 1: Classification and confidence
   Line 2: Key prior art found (or "clean search")
   Line 3: Most important next step
```

Also append to ~/research/log.md from the main session:
```
<date>  flagged  <slug>  agent-spun
```
