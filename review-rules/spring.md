# Spring Review Rules

Apply these rules for Spring and Spring Boot repositories.

## Transaction Boundaries

- Flag transactional changes that can leave state partially updated or make rollback behavior unclear.
- Call out transactional work that spans remote calls or mixes unrelated responsibilities without clear need.
- Prefer transaction scopes that match one business operation.

## Controller And Service Separation

- Flag controllers that absorb business logic, persistence logic, or orchestration that belongs in services.
- Call out services that start depending on web-layer details without a clear boundary.
- Prefer clean separation between transport concerns and domain/application behavior.

## Validation

- Flag externally supplied input that reaches business logic or persistence without validation.
- Call out missing bean validation, missing normalization, or inconsistent validation across similar entry points.
- Prefer validation close to the boundary where invalid input first appears.

## Repository Usage

- Flag repository access patterns that create N+1 query risk, excessive round trips, or unclear transactional assumptions.
- Call out persistence logic leaking into unrelated layers.
- Prefer findings where data access behavior can become incorrect, expensive, or hard to maintain.

## API Contract Safety

- Flag controller changes that alter request shape, response shape, status semantics, or error payloads without compatibility consideration.
- Call out serialization changes that can surprise clients, especially around nullability and field naming.
- Prefer explicit notes about downstream impact when public endpoints change.
