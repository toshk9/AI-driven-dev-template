# /init.md: bring an EXISTING project under this workflow (ACT mode)

One tool call per message. Use forward slashes `/` only.

1. `list_files` at the repo root (non-recursive). Read existing manifests: `pyproject.toml`, `requirements.txt`, `package.json`, `go.mod`, `Cargo.toml`, `Dockerfile`, `README.md`.
2. `write_to_file memory-bank/projectbrief.md` (whole file): what it is, who uses it, features, out of scope, stack. Facts only; write `UNKNOWN` for unclear parts and ask the user.
3. `write_to_file .clinerules/10-stack.md` (whole file): REAL run / test / lint commands, directory layout, conventions found in manifests. Do not guess.
4. `write_to_file memory-bank/techContext.md` (whole file): stack, entry points, dependencies, data storage, test setup.
5. `write_to_file docs/plan.md`: if the user gave work, break it into steps (`- [ ] S01 | goal | real paths | test | AC`); otherwise a single step `- [ ] S01 | baseline: scripts/verify.sh is green | scripts/verify.sh | - | -`.
6. Run `bash scripts/decide.sh "existing stack: <summary>" stated "found in manifests"`, then `bash scripts/intake-done.sh "<one-line goal>"` (it also generates `memory-bank/repo-map.md`). Fix any `INTAKE NOT DONE` error and re-run.
7. If `verify.sh` fails due to custom project tooling, create `scripts/verify.local.sh` with the exact gate commands.
8. Reply in <= 6 lines: detected stack, verify status, what the user must decide.
