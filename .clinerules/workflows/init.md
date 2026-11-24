# /init.md: bring an EXISTING project under this workflow (ACT mode)

One tool call per message.

1. `list_files` at the repo root (non-recursive). Read the manifests that exist: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `README.md`.
2. `write_to_file memory-bank/projectbrief.md` (whole file): what it is, who uses it, features, out of scope, stack. Facts only; write UNKNOWN for what you cannot tell and ask the user about it.
3. `write_to_file .clinerules/10-stack.md` (whole file): the REAL run / test / lint commands, layout, conventions, found in the manifests. Do not guess.
4. `write_to_file memory-bank/techContext.md` (whole file): stack, entry points, dependencies, data storage, test setup.
5. `write_to_file docs/plan.md`: if the user gave work, break it into steps (`- [ ] S01 | goal | files | test | AC`); otherwise a single step `- [ ] S01 | baseline: scripts/verify.sh is green | scripts/verify.sh | - | -`.
6. `bash scripts/repo-map.sh`, then `bash scripts/intake-done.sh "<one-line goal>"`. If it prints INTAKE NOT DONE, fix and rerun.
7. If `verify.sh` is red because of the project's own setup, create `scripts/verify.local.sh` with the correct gate commands.
8. Reply in at most 6 lines: detected stack, verify status, what the user must decide.
