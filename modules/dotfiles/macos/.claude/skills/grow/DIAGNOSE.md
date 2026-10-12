## diagnose -- Problem phase quiz

The problem is understood. Before moving to solutions, quiz on root cause.

Generate questions from the actual session content -- not from templates. Review the
conversation and files examined to produce questions tied to what specifically happened.

**Question format:**
- Concrete, pointing at specific files, lines, mechanisms
- "Why did X cause Y?" not "What is X?"
- "What would happen if you removed line N?" not "What does line N do?"

**Examples of the kind of question to generate (not templates to use):**
- "The error was in mas-install.nix line 47. What specifically caused it to fail there
  rather than at the point where mas is called?"
- "The Spotlight detection was returning empty. What are the two independent reasons
  that can happen on this machine, and how does the fallback handle each?"

**Quiz flow:**
1. Ask one question. Wait for the answer.
2. Evaluate: correct / partially correct / wrong / "I don't know"
3. If wrong or don't know: point at the evidence. "Look at <file> line <N>. Read it.
   Tell me in your own words what it says." Do not explain first. Make them find it.
4. If they still can't get it after finding the evidence: explain concretely with
   file/line references, then re-ask a simpler version.
5. Move to next question only after the current one lands.

Ask 2-3 questions per phase. Then write 1-2 exercises to ~/learning/queue.md for
async review.

**For non-coding sessions** (concept discussions, architecture): same structure, but
questions reference the specific explanation built in the session, the specific decision
made, the specific mechanism described -- not line numbers.
