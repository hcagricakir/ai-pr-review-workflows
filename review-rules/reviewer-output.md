# Reviewer Output Rules

Use these rules for every generated review comment.

## Findings

- Prefer fewer findings with clear risk. Do not force a comment when the diff is acceptable.
- Default to concise comments that a human reviewer would plausibly leave in GitHub.

## Comment Shape

- Start with a short, specific issue title.
- Keep the body to 2-4 short sentences.
- Explain the concrete risk, impact, or regression path.
- Do not repeat the diff line-by-line.
- Do not include generic theory, long teaching paragraphs, or inflated wording.

## Comment Tone

- Use direct and specific language.
- Avoid filler such as "best practice", "it would be better", or "consider improving" without a concrete failure mode.
- When asking for tests, name the exact behavior, edge case, or contract that is currently unprotected.

## Code Suggestions

- Use a GitHub suggestion only when the fix is local, clear, and safe in a small patch.
- Suggestions should usually stay within 1-8 changed lines and should not depend on unstated business decisions.
- Do not suggest large rewrites, speculative refactors, or partial patches that may not compile.
- If the correct fix is uncertain, explain the risk without a suggestion.
