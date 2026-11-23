---
name: api-lookup
description: Use before calling any third-party library, framework, or CLI API you have not seen used in this repo, or when a build fails with unknown method, wrong signature, or deprecated API errors. Verifies the real API instead of guessing from memory.
---

# api-lookup

Never write a library call from memory. Resolve it in this order and stop at the first hit.

1. **Serena LSP & Repo Usages.** Use `serena:find_symbol` or `serena:find_declaration` to inspect exact type definitions. Fall back to `search_files` for existing codebase examples.
2. **context7 MCP** (if enabled): resolve the library id, then fetch docs for the specific topic or method signature.
3. **Installed source or types.** Look in the dependency directory only if Serena/Context7 do not yield clear signatures:
  - Node: `node_modules/<pkg>/` (read `package.json` `types`, then `.d.ts` narrow range)
  - Python: `python -c "import <pkg>; print(<pkg>.__file__, <pkg>.__version__)"`, then `python -c "help(<pkg>.<name>)"`
4. **Ask the user** for a doc link if 1 to 3 give nothing.

Report the version you verified against in one line. If the installed version differs from what the docs show, trust the installed version.
