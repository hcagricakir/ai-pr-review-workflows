# Spring Review Rules

These rules reflect common Spring usage across `payload`, `rotate`, `kangaroo`, and `orbit`.

## Boundary Validation

- Controllers are commonly annotated with `@Validated`, and request bodies, path variables, and query params usually carry bean validation close to the boundary. Flag externally supplied input that reaches service or persistence code without equivalent validation.
- Custom validators such as company-aware id checks, date-range validation, and request-level validation are common. Flag changes that bypass those validators on new fields or alternate endpoints.

## Response And Exception Conventions

- These repos commonly expose `ServiceResponse` or generated service-response wrappers and use `ServiceResponses.successful(...)` on success paths. Treat changes to that response envelope or success/error semantics as contract changes, not cosmetic ones.
- `@ControllerAdvice` is used to unwrap rollback-style exceptions back into the original service response. Flag controller-local catch blocks that change error payloads or status semantics for flows already covered by centralized advice.

## Transaction Boundaries

- Multi-write service methods frequently declare `@Transactional(rollbackFor = Exception.class)`. Flag new write paths that can leave state partially updated because transaction scope or rollback semantics no longer match the business operation.
- Read-only flows sometimes mark read transactions explicitly. Flag transaction changes that expand a read path into writes or make write ordering ambiguous.
