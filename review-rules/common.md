# Common Review Rules

Apply these rules in every repository before profile-specific guidance.

## Review Priorities

- Prefer correctness, regression risk, data integrity, compatibility, and operational safety over style.
- Skip style-only comments unless the change also creates a concrete maintenance or defect risk.
- Report only issues that are directly supported by the diff and nearby code.

## Signal Over Noise

- Do not write findings that only restate the diff.
- Do not ask for generic cleanups, optional refactors, or vague "consider improving" changes.
- Prefer one precise finding over several overlapping comments on the same root problem.

## Compatibility And Safety

- Treat request or response contract changes, changed defaults, removed checks, and reordered side effects as high-signal review targets.
- Flag newly introduced trust of unvalidated input, authorization gaps, secret exposure, or unsafe command/query construction when the exploit path is concrete.
- Flag logging that can leak credentials, tokens, personal data, or noisy request/response payloads without operational value.
- Call out migrations, event changes, or rollout-sensitive behavior when backward compatibility is unclear.

## Test Expectations

- Ask for tests when the diff changes behavior, contracts, transactions, or message flow in a way that could regress production behavior.
- Name the missing scenario precisely instead of asking for "more tests" in the abstract.
- Do not ask for tests for trivial renames, formatting changes, or refactors with unchanged behavior.
