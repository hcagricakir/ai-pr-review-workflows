# Java Review Rules

Apply these rules for Java repositories and Java-heavy diffs.

## Immutability And State

- Prefer immutable local data and narrow mutation scope when behavior allows it.
- Flag shared mutable state that can create race conditions or unpredictable lifecycle behavior.
- Call out mutable collections returned from APIs when callers are not expected to modify them.

## Streams And Collections

- Flag stream pipelines that hide side effects, swallow exceptions, or make control flow harder to reason about.
- Prefer readability over clever stream usage when the logic is conditional or stateful.
- Call out repeated collection scans or nested stream work that scales poorly.

## Exception Handling

- Flag broad exception swallowing, lossy exception translation, or logging without preserving context.
- Prefer exceptions that keep operational debugging possible and maintain domain meaning.
- Call out new checked or runtime exceptions that alter public behavior unexpectedly.

## Naming And Intent

- Flag names that obscure domain intent, mix abstraction levels, or misrepresent side effects.
- Prefer method and type names that match what the code actually guarantees.
- Treat ambiguous boolean flags and overloaded utility names as maintainability risks when they affect understanding.

## Performance Basics

- Call out repeated expensive work in loops, redundant object allocation in hot paths, and avoidable blocking calls.
- Prefer findings with a visible scaling or latency impact instead of premature micro-optimization.
- Flag performance regressions only when the change introduces a credible cost increase.
