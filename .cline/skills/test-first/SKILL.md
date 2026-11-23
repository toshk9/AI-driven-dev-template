---
name: test-first
description: Use when adding or changing behavior in this repo and a test must be written first. Gives the exact red-green procedure, how to pick the test location, and how to prove the test fails for the right reason.
---

# test-first

1. Find the nearest existing test for similar code (`search_files` for the module name in test files). Copy its structure, imports, and helpers. Do not invent a new test style.
2. Write ONE test for ONE behavior from the step. Smallest possible setup.
3. Run only that test (command in `.clinerules/10-stack.md`). It must FAIL, and the failure must be about the missing behavior, not a typo, import error, or syntax error. If it fails for another reason, fix the test first.
4. Quote the failure line in your report.
5. Write the minimum implementation. Re-run the single test until green.
6. Run `bash scripts/verify.sh` for the full gate.
7. Add the failure-path test (bad input, empty case) only if the acceptance criteria mention it.
