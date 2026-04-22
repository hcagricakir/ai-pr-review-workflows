# Reviewer Output Rules

Use these rules for every generated review comment.

## Findings

- Prefer fewer findings with clear risk. Do not force a comment when the diff is acceptable.
- Default to concise comments that a human reviewer would plausibly leave in GitHub.
- Write only the problem that needs attention. Do not add separate "Why it matters", "Recommendation", or "Confidence" sections.
- Cap the review to the strongest 1-3 findings. Drop weaker or overlapping comments.

## Comment Shape

- Start with a short, specific issue title.
- Keep the body to 1-2 short sentences.
- State the concrete bug, regression, or unsafe behavior directly.
- Do not repeat the diff line-by-line.
- Do not include generic theory, long teaching paragraphs, or inflated wording.
- Do not use labeled subsections or repeated framing.

## Comment Tone

- Use direct and specific language.
- Avoid filler such as "best practice", "it would be better", or "consider improving" without a concrete failure mode.
- When asking for tests, name the exact behavior, edge case, or contract that is currently unprotected.

## Code Suggestions

- Use a GitHub suggestion only when the fix is local, clear, and safe in a small patch.
- Prefer a suggestion over extra prose when the correct replacement is obvious from the diff.
- Suggestions should usually stay within 1-8 changed lines and should not depend on unstated business decisions.
- Do not suggest large rewrites, speculative refactors, or partial patches that may not compile.
- When a suggestion is appropriate, append a single fenced code block with the info string `suggestion` and include only the replacement lines.
- Do not add explanation after the suggestion block.
- If the correct fix is uncertain, explain the problem without a suggestion.

## Preferred Patterns

- Preferred without suggestion:

  `Boundary check changed from >= to >, so orders exactly at the free-delivery threshold now get charged.`

- Preferred with suggestion:

  `Null lookup result is dereferenced before checking whether the customer exists.`

  ```suggestion
          if (customer == null || customer.getPrimaryEmail() == null || customer.getPrimaryEmail().isBlank()) {
              return null;
          }
  ```

- Avoid:

  `Problem: ...`
  `Why it matters: ...`
  `Recommendation: ...`
  `Confidence: ...`
