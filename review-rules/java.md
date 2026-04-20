# Java Review Rules

These rules are derived from repeated patterns in `payload`, `rotate`, `kangaroo`, and `orbit`.

## Layering And Ownership

- The common module split is `app` for controllers/config, `core` for business services, `domain` for shared enums/events, and `plug` or `client` for external integrations. Flag changes that blur those boundaries without a clear reason.
- Controllers typically depend on services and mappers, not repositories or raw persistence concerns. Call out new controller logic that performs business rules, persistence orchestration, or direct repository access.

## DTO And Mapper Usage

- DTO and request mapping is usually handled by dedicated mappers such as MapStruct mappers or explicit mapper classes. Flag manual field-by-field mapping added in controllers or scattered across services when a mapper already owns that boundary.
- When a module already returns DTOs for an endpoint or service boundary, treat a switch to raw entities or loosely typed maps as a contract and maintainability regression.

## Explicit Failure Handling

- Repository calls commonly translate `Optional.empty()` or `affectedRowCount < 1` into domain-specific failures. Flag write paths that silently succeed on zero updated rows or read paths that stop checking for missing data.
- Exceptions are usually domain-specific and keep operational context. Flag broad catch-and-ignore blocks or generic wrappers that hide which entity, id, or downstream call failed.

## Integration Failure Semantics

- Several repos preserve downstream `ServiceResponse` failures through `RollbackServiceException` rather than inventing a new local success path. Flag changes that swallow or reshape those failures and alter published API behavior.
- When a write flow combines local state changes with a remote call, call out rollback gaps or partial-update risk if the remote failure can no longer unwind the local change.
