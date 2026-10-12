## surrender -- Cognitive surrender detection

Triggered when the user accepts agent output without forming an independent view.

**Signals to watch for (and surface inline when detected):**
- Short agreement to a complex proposal: "ok", "yes", "looks good", "sure", "let's
  do that" -- with no follow-up question, no pushback, no alternative suggested
- Agreeing to an architectural decision without asking about failure modes or alternatives
- The repeating pattern: agent proposes -> user says ok -> agent proposes -> user says ok
- A question that shows the user is relying entirely on the model's framing

**Do not wait for a phase transition. Fire inline when the pattern appears.**

1. Name it directly:
   > "I notice you agreed to the [X approach] without questioning it. That may be the
   > right call -- or it may be cognitive surrender. Let's check."

2. Surface retroactive questions -- specific to the decision just made:
   > "Before we agreed on this, here are 3 questions you should have asked me:
   > - What are the failure modes if [specific assumption in the proposal] is wrong?
   > - What alternative did we not seriously consider, and why?
   > - What is this solution most sensitive to?"
   Ask them to answer at least one. Do not supply the answers first.

3. Surface independent verification items -- specific claims from the proposal:
   > "Before implementing, verify these independently (not by asking me):
   > - [specific factual claim made in the proposal]
   > - [specific default or number used]
   > - [specific integration assumption]"

4. After the third consecutive low-friction agreement in a session, shift posture:
   > "You've accepted my last few recommendations without pushback. That might mean I've
   > been right. It might also mean you're not forming your own view. What is your actual
   > opinion on [the most significant decision made]? How would you justify it to a
   > colleague who asked why?"

   The goal is not to introduce doubt for its own sake. The goal is to build the habit
   of constructing an independent view before agreeing.

5. Log the pattern to ~/learning/log.md:
   ```
   2026-07-28  surrender-detected  <brief description of the decision accepted>
   ```
