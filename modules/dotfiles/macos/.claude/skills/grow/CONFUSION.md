## confusion <concept> -- Inline confusion teaching

Triggered when the same concept appears in multiple questions, or an answer reveals a
missing prerequisite, or a question assumes something that is not true.

**Do not wait for a phase transition. Fire inline.**

1. Name it:
   > "I've noticed you've asked about <concept> a few times in different ways. Let's
   > make sure this is solid before we go further."

2. Ask for their current understanding:
   > "Tell me what you currently understand about <concept>. A few sentences."

3. Evaluate the answer for depth and accuracy.

4. Check ~/learning/depth.md. Has a depth level been set for this concept?

   If not, ask:
   > "For your work, how deep do you need <concept>?
   > a) Know it exists and roughly what it does
   > b) Configure and use it in practice
   > c) Own it in production -- debug failures, handle edge cases
   > d) Be the expert others come to"

   Write the result to ~/learning/depth.md: `<concept>: <level>`

5. Based on depth level and answer quality, explain concretely:
   - With file/line references if the concept appears in the current session's code
   - With a specific mechanism description if it is a pure concept
   - With a contrasting example showing what it is not

6. Resources -- suggest 1-2 appropriate to the depth level:
   - Level a: one official docs page or one overview article
   - Level b: official how-to docs, a focused tutorial with exercises
   - Level c: official deep-dive docs, a well-regarded book chapter, an incident report
   - Level d: source code, design documents, a community resource (forum, maintainer talk)

   For current or specialized topics: "I know good starting points, but /research can
   find better-targeted resources -- especially for version-specific behavior."

   Prefer: official docs, well-regarded books, specific talks with known authors.
   Avoid: aggregator tutorial sites, "top 10 X" posts, undated blog posts.

7. Re-ask a version of the question that prompted the confusion to confirm it landed.

8. Write to ~/learning/records/:
   ```
   0NNN-<concept-slug>.md
   ---
   Concept: <name>
   Depth target: <level>
   What was unclear: <1-2 sentences>
   Resources given: <list>
   ---
   <1-3 sentences: what was learned and why it matters for future sessions>
   ```
