# Stack and commands

- Language / runtime: Node.js 22 / TypeScript 5.x (или Python 3.12 / Bash)
- Package manager: npm
- Run dev: npm run dev
- Run one test file: npx vitest run <path-to-test>
- Run all tests: npm test
- Lint / typecheck: npx tsc --noEmit && npx eslint .
- Full gate: bash scripts/verify.sh

## Layout
- `src/` — Source code
- `tests/` — Test files
- `memory-bank/` — Project context and memory persistence

## Conventions
- Naming: camelCase for variables/functions, PascalCase for classes/types.
- Imports: Relative imports (`./` or `../`).
- Tests: Located in `tests/` matching source structure.
