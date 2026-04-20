# Persistence Review Rules

These rules are grounded in repository and transaction patterns from `payload`, `rotate`, `kangaroo`, and `orbit`.

## Repository Boundaries

- Repositories usually sit behind services or configuration classes. Flag repository leakage into controllers or other transport-layer code.
- Custom query repositories are common, including `@SqlSelect`, `@SqlUpdate`, and repository-specific extractors. Flag diffs that duplicate query logic outside the repository abstraction instead of extending the existing repository API.

## Update Semantics

- Write methods often use affected-row counts to detect missing records or failed updates. Flag mutations that ignore those counts and report success even when nothing changed.
- Partial-update flows exist in some repos through patch-style requests or `COALESCE` SQL. Flag changes that accidentally overwrite existing values, treat `false` or `0` like `null`, or widen a partial update into a destructive overwrite.

## Transactional Safety

- Database writes, downstream service calls, and event publication are often coordinated carefully. Flag flows that publish external side effects before the database commit or that make rollback behavior dependent on code outside the transaction.
- Isolation or propagation is used selectively for edge cases. Flag those settings when they are removed or changed in code that depends on them for correctness.
