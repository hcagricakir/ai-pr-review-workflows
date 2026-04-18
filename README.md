# ai-pr-review-workflows

Reusable GitHub Actions workflow and shared rule bundles for AI-assisted pull request review.

This repository is intended to be published as `hcagricakir/ai-pr-review-workflows` and consumed from multiple repositories through `workflow_call`.

It owns:

- reusable GitHub Actions orchestration
- shared markdown review rules
- setup and usage documentation

It does not own the review engine implementation. The workflow checks out and builds a separate reviewer engine repository.

## Companion Engine Repository

The default reviewer engine repository is:

- `hcagricakir/ai-pr-reviewer`

That engine repository contains the Java CLI, prompt assembly, AI provider integration, diff loading, and GitHub review publishing logic.

## Repository Layout

```text
ai-pr-review-workflows/
├── .github/workflows/pr-review.yml
├── review-rules/common.md
├── review-rules/java.md
├── review-rules/spring.md
├── scripts/compose-review-rules.sh
└── README.md
```

## What The Reusable Workflow Does

The reusable workflow:

1. Resolves pull request metadata from the caller event.
2. Checks out the caller repository at the pull request head commit.
3. Checks out this shared workflow repository.
4. Checks out the reviewer engine repository configured by input.
5. Builds the reviewer engine with Java 21.
6. Merges shared and optional repository-specific markdown rules.
7. Runs the reviewer CLI against the active pull request.
8. Publishes GitHub pull request comments through the engine.

## Workflow Inputs

- `review_profile`: shared profile such as `java` or `java-spring`
- `extra_rules_path`: optional path in the caller repository, for example `.github/review/business-rules.md`
- `reviewer_repo`: reviewer engine repository, default `hcagricakir/ai-pr-reviewer`
- `reviewer_ref`: reviewer engine git ref, default `main`
- `workflow_ref`: git ref used to checkout shared rule files and helper scripts from `hcagricakir/ai-pr-review-workflows`, default `main`

## Required Permissions

The reusable workflow job uses:

- `contents: read`
- `pull-requests: write`

The caller workflow must run from:

- `pull_request`, or
- `issue_comment` on a pull request

Comment-triggered runs are restricted to same-repository pull requests. That avoids checking out untrusted fork code with reusable workflow secrets.

## Secrets And Variables

Required secret:

- `OPENAI_API_KEY`

Preferred repository variable:

- `OPENAI_MODEL`

If `OPENAI_MODEL` is not set, the workflow falls back explicitly to `gpt-5.4-mini`. That fallback is logged during workflow execution so repositories can see which model is being used.

These values must be configured in the consuming repository that calls the reusable workflow. They do not need to be configured in `ai-pr-review-workflows` unless that repository also becomes a caller itself.

## Rule Layering

Rule composition is intentionally simple:

1. `review-rules/common.md` is always included.
2. `review_profile` is split on `-`.
3. Each profile part resolves to `review-rules/<part>.md`.
4. If `extra_rules_path` exists in the caller repository, it is appended last.

Examples:

- `java` resolves to `common.md` + `java.md`
- `java-spring` resolves to `common.md` + `java.md` + `spring.md`

The merge is handled by `scripts/compose-review-rules.sh`.

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
      extra_rules_path: .github/review/business-rules.md
      reviewer_repo: hcagricakir/ai-pr-reviewer
      reviewer_ref: main
      workflow_ref: main

  review_on_comment:
    if: ${{ github.event_name == 'issue_comment' && github.event.issue.pull_request && contains(github.event.comment.body, '!review') }}
    uses: hcagricakir/ai-pr-review-workflows/.github/workflows/pr-review.yml@main
    permissions:
      contents: read
      pull-requests: write
    secrets: inherit
    with:
      review_profile: java-spring
      extra_rules_path: .github/review/business-rules.md
      reviewer_repo: hcagricakir/ai-pr-reviewer
      reviewer_ref: main
      workflow_ref: main
```

## Consuming Repository Setup

### 1. Add required secret

Create repository secret:

- `OPENAI_API_KEY`

### 2. Add model variable

Create repository variable:

- `OPENAI_MODEL`

Recommended starting value:

- `gpt-5.4-mini`

### 3. Optionally add business rules

Repository-specific business/domain rules can live at:

```text
.github/review/business-rules.md
```

When that file exists, pass it through `extra_rules_path`. If the file does not exist, the workflow skips it without failing.

## Extensibility

This repository keeps orchestration intentionally small. Future additions can extend profile coverage or engine selection without coupling those concerns into the engine repository.
