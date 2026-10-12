## check -- Spaced repetition queue

Read ~/learning/queue.md. Find all items with Due date <= today (2026-07-28).

Report:
> "You have X items in your learning queue. Y are due today.
> Oldest due item: [title] (due [date])"

Present the first due item:
> "[Re-derivation task text]"
> "Try it now, or schedule for later?"

If they attempt it:
- Evaluate the answer
- If correct: mark done, write next review date per SRS schedule
- If not: reschedule to tomorrow, add a hint to the entry

If they defer: ask for a new date.

The SRS schedule (from first learning):
- 1 day -> 3 days -> 1 week -> 2 weeks -> 1 month -> 2 months -> 4 months
