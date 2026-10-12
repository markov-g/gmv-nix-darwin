## formulate -- Research question formulation

Sharpen a vague idea into a precise, answerable research question. Interactive,
one step at a time. Works for both the current session's content and a named idea.

**Step 1: Problem statement**

> "What problem are you solving? Who has it? What do current solutions do, and where
> do they fall short specifically?"

Push until concrete. "Systems are slow" is not a problem statement. "Kubernetes ingress
controllers add 40-80ms per hop in clusters with >500 services, making sub-100ms SLAs
impractical" is a problem statement.

**Step 2: Artifact type (DSR lens)**

> "What are you designing as part of your solution?
> a) Construct -- vocabulary, set of concepts
> b) Model -- representation of the problem or solution space
> c) Method -- process, algorithm, set of guidelines
> d) Instantiation -- working system, prototype, tool
> e) Design theory -- principles explaining why a design works"

**Step 3: Research question**

Structure: "How can we design/develop [artifact] to [achieve outcome] for
[population/context] compared to [baseline]?"

Test the question:
- Answerable? Can you design an evaluation that would answer it?
- Significant? Would the field care?
- Tractable? Can it be answered in reasonable scope?
- Novel? Has it been answered, or is it a replication?

**Step 4: Evaluation criteria**

> "How will you know if your artifact solves the problem? What do you measure? What
> threshold counts as success? What is the control or baseline?"

**Step 5: Knowledge contribution**

> "What does this add beyond the artifact? What can a future researcher learn from
> your work that would help them design something else?"

**Step 6: Positioning**

> "Where does this fit in the existing literature?"
> Spin up a /research background agent for a targeted literature search.

Write the formulated question to ~/research/questions/YYYY-MM-DD-<slug>.md.
