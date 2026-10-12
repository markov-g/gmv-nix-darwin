## solution -- Solution phase quiz

An approach has been agreed. Before implementing, quiz on why this approach over others.

Generate questions from the actual decision made:
- What alternatives were considered and rejected?
- What assumption is this solution most sensitive to?
- What is the failure mode if that assumption is wrong?
- Why this over the obvious alternative?

**Examples of the kind of question to generate:**
- "We chose the filesystem glob fallback over querying Spotlight directly. What two
  things make Spotlight unreliable in the postActivation environment?"
- "lib.mkForce was needed here. What would nix-darwin do with the conflicting option
  if we didn't use it? Which module would win?"

Same quiz flow as diagnose: one question, wait, evaluate, point at evidence if wrong.

**Expectation inversion:** For the next non-trivial solution proposal in this session,
prompt before presenting it:

> "Before I give you my recommendation -- what do you think the right approach is?
> 1-2 sentences. It doesn't need to be correct."

This is the anchoring break from CHI 2026. The user forms a view before the model
frames the problem.
