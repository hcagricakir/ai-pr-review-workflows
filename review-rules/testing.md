# Testing Review Rules

Choose the test expectation that matches the type of risk introduced by the diff.

## Service And Persistence Changes

- For business-rule, transaction, repository, or exception-translation changes, prefer service-level tests that verify the affected scenario directly.
- When a write path depends on update counts, optional lookups, or rollback behavior, ask for the failing edge case, not only the happy path.

## API Contract Changes

- When controller validation, route versioning, request shape, or response shape changes, prefer contract coverage such as `Swagger2SpecTest` over vague requests for controller tests.

## Messaging Changes

- When a diff changes Kafka topic names, keys, payloads, tombstones, or publish timing, prefer EmbeddedKafka or event-publisher assertions that prove the wire behavior.

## Scope Control

- Do not ask for tests on trivial refactors.
- Do ask for a targeted test when the code changes a shared convention from the inspected repos and the regression would be hard to spot manually.
