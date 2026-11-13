---
name: implement
description: "Implement a piece of work based on a spec, plan, or set of tickets."
disable-model-invocation: true
model: sonnet
context: fork
---

Implement the work described by the user in the spec, plan or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Run typechecking once you finish a ticket, new or modified single test files as-needed, and all related tests once all changes are complete.

Commit your work after each ticket to the current branch.
