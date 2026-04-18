# Common Review Rules

Use these rules for every repository unless a more specific rule file overrides them.

## Correctness

- Prioritize concrete correctness issues over stylistic preferences.
- Flag behavior that can produce wrong results, corrupted state, or broken control flow.
- Prefer findings that are directly supported by the diff and its nearby context.

## Regression Risk

- Look for changes that silently alter existing behavior without corresponding safeguards.
- Treat removed checks, changed defaults, and reordered side effects as regression candidates.
- Call out risky migrations or branching changes when backward compatibility is unclear.

## Security

- Flag newly introduced trust of unvalidated input, insecure defaults, or authorization gaps.
- Call out secrets exposure, unsafe command execution, injection risks, and missing output encoding where relevant.
- Prefer concrete exploit paths over generic security warnings.

## Null Safety And Defensive Coding

- Flag null handling regressions, unchecked optional values, and new assumptions that can fail at runtime.
- Treat error-prone edge cases as actionable when the diff introduces or worsens them.
- Prefer precise explanations of the failing path.

## Logging And PII

- Flag logs that may expose credentials, tokens, personal data, or sensitive business data.
- Call out logs that create noise without operational value in hot paths or failure loops.
- Prefer structured, minimal, and safe logging.

## API Compatibility

- Flag request or response contract changes that can break existing clients or downstream systems.
- Call out renamed fields, changed semantics, removed defaults, and incompatible status code changes.
- Treat compatibility risk as important even when compilation still succeeds.

## Test Expectations

- Call out missing or weakened test coverage when the diff changes important behavior, edge cases, or contracts.
- Do not request tests for trivial refactors with unchanged behavior.
- Prefer naming the behavior that should be covered rather than asking for more tests in the abstract.
