---
name: api-lookup
description: Use before calling any third-party library, framework, or CLI API you have not seen used in this repo, or when a build/runtime fails with unknown attribute, wrong signature, version mismatch, or deprecated API errors. Verifies the real installed API instead of guessing from memory.
---

# api-lookup

Never write a third-party library call from memory (especially libraries with major breaking versions like `arcade` 2 vs 3, `pydantic` v1 vs v2, `langchain`/`langgraph`, `sqlalchemy` 1.4 vs 2.x). Resolve in this order:

1. **Installed version first (Python / Node / Go / Rust).**
   - Python: `bash scripts/py.sh -c "import <pkg>; print(getattr(<pkg>, '__version__', 'unknown'), getattr(<pkg>, '__file__', ''))"`
   - Node: read the dependency version in `package.json` / `node_modules/<pkg>/package.json`.
   If the installed version differs from online examples, ALWAYS trust the installed version.
2. **Serena LSP & repo usages.** Use `find_symbol` / `search_files` for existing usage patterns in this repo.
3. **context7 MCP** (if listed in MCP SERVERS): resolve the library id (`resolve-library-id`), then query docs (`query-docs` or `get-library-docs` — exact name from schema) specifically for the installed major version and narrow symbol/topic (e.g., `"arcade 3.0 Window draw_rect_filled"`).
4. **Installed source / types / `help()`.** If context7 is unavailable, stale, or unclear:
   - Python: `bash scripts/py.sh -c "import inspect, <pkg>; print(inspect.signature(<pkg>.<Symbol>))"` or `bash scripts/py.sh -c "help(<pkg>.<Symbol>)"`
   - Node: read `node_modules/<pkg>/` (`types` field in `package.json` -> `.d.ts` range)
   - Go / Rust: `go doc <pkg>.<Name>` or module cache source
5. **Ask the user** for a doc link if steps 1–4 give nothing.

Report the verified library version and signature in 1 line before coding against it.
