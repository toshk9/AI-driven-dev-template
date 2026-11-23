---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/test_*.py"
  - "tests/**"
  - "test/**"
---
# Test-file rules (active only when working with tests)

- One behavior per test. Name: `<unit> <does what> when <condition>`.
- Arrange / Act / Assert, with no logic (no loops or ifs) in the test body.
- Assert observable behavior and outputs, never private internals or call counts unless the call IS the behavior.
- No network, no real clock, no randomness: inject or mock them.
- A new test must be seen failing before the implementation exists. Quote the failure message in your report.
- Never edit an existing test to make it pass. If the test is wrong, explain why and ask.
- Run only the affected test file while iterating; run the full gate (`bash scripts/verify.sh`) at the end.
