# Messaging Review Rules

These rules are based on Kafka and event patterns repeated in `payload`, `rotate`, and `kangaroo`.

## Topic Naming And Routing

- Topic names are usually centralized in constants such as `PayloadKafkaTopics`, `RotateKafkaTopics`, or `Topics`. Flag raw topic strings or ad-hoc environment suffixing added in business logic.
- Retry and dead-letter suffix conventions are already encoded in several listeners and producers. Flag changes that break retry, DLT, or tombstone routing expectations.

## Publish Timing

- Event publication often uses `ApplicationEventPublisher` with `KafkaEvent`, and some flows defer publishing with `@TransactionalEventListener(AFTER_COMMIT)`. Flag new event publication that can escape before the corresponding database state is committed.
- Tombstone publication is used for deletion-like stream semantics in several modules. Flag tombstones that are emitted on the wrong key, wrong topic, or without preserving existing consumer expectations.

## Consumer Configuration

- Several consumer configs explicitly keep `missingTopicsFatal(false)`. Flag changes that make missing topics fatal unless the rollout really depends on failing fast.
- If a diff changes event keys, topic selection, serialization shape, or commit timing, ask for messaging-focused coverage such as EmbeddedKafka or listener tests.
