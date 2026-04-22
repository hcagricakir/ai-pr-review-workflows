# ai-pr-review-workflows

Reusable GitHub Actions workflow and shared rule bundles for AI-assisted pull request review.

This repository is intended to be published as `hcagricakir/ai-pr-review-workflows` and consumed from multiple repositories through `workflow_call`.

It owns:

- reusable GitHub Actions orchestration
- shared markdown review rules
- rule composition and layering
- the internal reviewer engine runtime used by the workflow
- setup and usage documentation

The internal reviewer engine contains the Java CLI, prompt assembly, AI provider integration, diff loading, and GitHub review publishing logic.

## Repository Layout

```text
ai-pr-review-workflows/
├── .github/workflows/pr-review.yml
├── reviewer-engine/
│   ├── pom.xml
│   ├── config/
│   │   └── runtime/
│   ├── policies/
│   ├── scripts/
│   └── src/
├── review-rules/
│   ├── reviewer-output.md
│   ├── common.md
│   ├── java.md
│   ├── spring.md
│   ├── api-contracts.md
│   ├── persistence.md
│   ├── messaging.md
│   ├── testing.md
│   └── profiles/
│       ├── java.txt
│       └── java-spring.txt
├── scripts/compose-review-rules.sh
└── README.md
```

## What The Reusable Workflow Does

The reusable workflow:

1. Resolves pull request metadata from the caller event.
2. Checks out the caller repository at the pull request head commit.
3. Checks out this shared workflow repository.
4. Builds the internal reviewer engine with Java 21.
5. Composes shared and optional repository-local markdown rules.
6. Runs the reviewer runtime launcher against the active pull request using a runtime config file.
7. Publishes GitHub pull request comments through the engine.

## Convention Sources

The shared rules were tightened using repeated patterns observed in local repositories rather than generic best-practice lists.

The rules emphasize only conventions that were repeated, meaningful, and enforceable in review. They intentionally do not encode business rules that appeared isolated to a single repository.

Examples of recurring conventions that now drive the review bundles:

- layered `app` / `core` / `domain` / `plug` or `client` module boundaries
- controller-to-service boundaries with minimal transport-layer logic
- request and parameter validation at the API boundary via `@Validated`, `@Valid`, and custom validators
- `ServiceResponse`-style API envelopes and centralized rollback exception handling
- dedicated mapper usage for DTO boundaries
- explicit transaction scopes on multi-write service flows
- repository methods that translate missing rows or empty optionals into domain failures
- centralized topic constants plus environment-aware Kafka naming
- post-commit event publishing for state-dependent messages
- focused service tests, `Swagger2SpecTest` contract checks, and EmbeddedKafka coverage where message behavior changes

## Rule Structure

The rule system is now split into three layers:

1. Always-on reviewer behavior:
   - `review-rules/reviewer-output.md`
   - `review-rules/common.md`
2. Profile bundle:
   - resolved from `review-rules/profiles/<review_profile>.txt` when present
   - falls back to the legacy `review_profile` split-by-`-` behavior for backward compatibility
3. Optional repository-local rules:
   - appended from a single markdown file, or
   - appended from every `*.md` file in a directory, in lexical order

## Profile Bundles

Current profile bundles:

- `java`
  - `java.md`
  - `api-contracts.md`
  - `persistence.md`
  - `testing.md`
- `java-spring`
  - `java.md`
  - `spring.md`
  - `api-contracts.md`
  - `persistence.md`
  - `messaging.md`
  - `testing.md`

This keeps the caller-facing profile name simple while allowing the rule set behind that profile to grow in a controlled way.

## Comment Brevity And Suggestions

The shared rules now explicitly steer the reviewer toward shorter, higher-signal comments.

Expected comment shape:

- short issue title
- 1-2 short sentences describing only the problem
- strongest 1-3 findings only
- no "Why it matters", "Recommendation", or "Confidence" sections
- no long background explanation or repeated rationale
- optional fenced code block with info string `suggestion` when the fix is local and safe

GitHub code suggestions are now requested only when the fix is:

- local
- clear
- safe in a small patch

Suggestions are explicitly discouraged for broad rewrites, speculative refactors, or business-dependent fixes.

Whether the suggestion renders correctly in GitHub depends on the reviewer engine preserving markdown suggestion blocks when publishing review comments.

## Workflow Inputs

- `review_profile`: shared review profile bundle such as `java` or `java-spring`
- `extra_rules_path`: optional file or directory in the caller repository, default `.github/review`
- `workflow_ref`: optional git ref used to checkout shared rule files and the internal reviewer engine. When omitted, the workflow reuses the same ref that invoked the reusable workflow.
- `runtime_config_path`: internal runtime config path inside `ai-pr-review-workflows`, default `reviewer-engine/config/runtime/github-pr-review.yml`

Deprecated inputs retained only for backward compatibility:

- `reviewer_repo`
- `reviewer_ref`

## Required Permissions

The reusable workflow job uses:

- `contents: read`
- `pull-requests: write`

The caller workflow must run from:

- `pull_request`, or
- `issue_comment` on a pull request

Comment-triggered runs are restricted to same-repository pull requests. That avoids checking out untrusted fork code with reusable workflow secrets.

## Secrets And Variables

Preferred repository variable:

- `OPENAI_MODEL`

If `OPENAI_MODEL` is not set, the workflow falls back explicitly to `gpt-5.4-mini`.

`OPENAI_API_KEY` still must be available from the caller workflow context because GitHub reusable workflows do not directly read secrets that exist only in the called workflow repository. The practical way to avoid duplicating repository secrets is:

1. create an organization-level Actions secret named `OPENAI_API_KEY`
2. grant that secret to the repositories that will use this workflow
3. call the reusable workflow with `secrets: inherit`

This keeps consuming repositories free from per-repository API key setup while remaining compatible with GitHub's reusable workflow security model.

## Runtime Configuration

The workflow no longer hardcodes the Java invocation details inline. Instead it delegates to:

- runtime config: `reviewer-engine/config/runtime/github-pr-review.yml`
- launcher script: `reviewer-engine/scripts/run-github-pr-review.sh`

The runtime config controls provider, output format, publish mode, diff filters, and the env-backed extra rules file path. The launcher script only supplies the dynamic pull request context and executes the jar.

This keeps the reusable workflow thin while allowing the runtime to be executed locally with the same config-driven behavior.

## Rule Layering

Rule composition is handled by `scripts/compose-review-rules.sh`.

Composition order:

1. `review-rules/reviewer-output.md`
2. `review-rules/common.md`
3. profile bundle files from `review-rules/profiles/<review_profile>.txt`
4. repo-local rules from `extra_rules_path`

If a profile bundle file does not exist, the script falls back to the legacy behavior:

1. split `review_profile` on `-`
2. resolve each part to `review-rules/<part>.md`
3. append them once each

Repository-local layering rules:

- if `extra_rules_path` points to a file, that file is appended last
- if `extra_rules_path` points to a directory, every `*.md` file in that directory is appended last in lexical order
- missing repo-local paths do not fail the workflow

Recommended repository-local layout:

```text
.github/review/
├── business-rules.md
├── api-exceptions.md
└── rollout-notes.md
```

Use lexical prefixes such as `10-`, `20-`, `30-` if a specific order matters.

## Example Usage

```yaml
name: PR Review

on:
  pull_request:
    types: [opened, synchronize, reopened]
  issue_comment:
    types: [created]

jobs:
  review_on_pr_update:
    if: ${{ github.event_name == 'pull_request' }}
    uses: hcagricakir/ai-pr-review-workflows/.github/workflows/pr-review.yml@main
    permissions:
      contents: read
      pull-requests: write
    secrets: inherit
    with:
      review_profile: java-spring
      extra_rules_path: .github/review
      runtime_config_path: reviewer-engine/config/runtime/github-pr-review.yml

  review_on_comment:
    if: ${{ github.event_name == 'issue_comment' && github.event.issue.pull_request && contains(github.event.comment.body, '!review') }}
    uses: hcagricakir/ai-pr-review-workflows/.github/workflows/pr-review.yml@main
    permissions:
      contents: read
      pull-requests: write
    secrets: inherit
    with:
      review_profile: java-spring
      extra_rules_path: .github/review
      runtime_config_path: reviewer-engine/config/runtime/github-pr-review.yml
```

## Consuming Repository Setup

### 1. Make the OpenAI key available

Recommended approach:

- create organization Actions secret `OPENAI_API_KEY`
- allow the consuming repositories to access it
- use `secrets: inherit` in the caller workflow

Repository-level `OPENAI_API_KEY` also works, but is no longer the recommended setup.

### 2. Add model variable

Create repository variable:

- `OPENAI_MODEL`

Recommended starting value:

- `gpt-5.4-mini`

### 3. Optionally add repository-local review rules

Recommended path:

```text
.github/review/
```

This directory can contain one or many markdown files. If the directory does not exist, the workflow skips it without failing.

## Extensibility

This repository keeps orchestration intentionally small.

Future extension points are:

- adding new topical rule files
- adding new profile bundle manifests under `review-rules/profiles/`
- adding repo-local markdown files without changing the shared workflow
- swapping the reviewer engine repository or ref per caller

If future improvements require structured suggestion handling, richer output schemas, or more advanced comment deduplication, that work belongs in the reviewer engine repository rather than in this workflow repository.
