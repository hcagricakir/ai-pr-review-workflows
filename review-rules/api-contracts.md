# API Contract Review Rules

These rules are based on repeated API patterns in `payload`, `rotate`, `kangaroo`, and `orbit`.

## Request Contracts

- Request objects usually carry the contract: positive ids, bounded strings, collection limits, and custom validation annotations live on the DTO or controller parameter. Flag new fields or endpoints that skip those constraints and rely on deep service checks instead.
- Versioned routes such as `/v2` or route variants with different semantics are common. Flag diffs that silently repurpose an existing route or payload shape instead of introducing a new version or preserving old behavior.

## Response Contracts

- Many endpoints return DTOs or response wrappers with existing field names and shapes that are consumed across services. Flag renamed fields, nullability changes, entity exposure, or changed success semantics that can break generated clients or downstream callers.
- Pagination parameters such as `offset` and `limit` are validated explicitly in several repos. Treat removed bounds or changed pagination semantics as contract regressions.

## Contract Coverage

- `Swagger2SpecTest` appears across the inspected repos as a contract guard. When endpoint shape, validation, or versioning changes, ask for the matching contract/spec update rather than a generic controller test.
