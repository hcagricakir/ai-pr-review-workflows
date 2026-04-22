#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CONFIG_PATH="${PR_REVIEW_CONFIG_PATH:-config/runtime/github-pr-review.yml}"

if [[ -z "${PR_REVIEW_PR_NUMBER:-}" ]]; then
  echo "PR_REVIEW_PR_NUMBER is required." >&2
  exit 1
fi

if [[ "${CONFIG_PATH}" == reviewer-engine/* ]]; then
  CONFIG_PATH="${CONFIG_PATH#reviewer-engine/}"
fi

cd "${PROJECT_ROOT}"

echo "Using review runtime config: ${CONFIG_PATH}"
echo "Using OpenAI model: ${OPENAI_MODEL:-}"

java -jar target/ai-pr-reviewer.jar \
  review \
  --config "${CONFIG_PATH}" \
  --github-pr "${PR_REVIEW_PR_NUMBER}" \
  "$@"
