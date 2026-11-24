---
name: api-lookup
description: Use before calling any third-party library, framework, or CLI API you have not seen used in this repo, or when a build fails with unknown method, wrong signature, or deprecated API errors. Verifies the real API instead of guessing from memory.
---

# api-lookup

Never write a library call from memory. Resolve it in this order and stop at the first hit. Tool names are the ones listed in "MCP SERVERS" of your system prompt; if a tool is not listed, skip that step.

1. **Serena LSP and repo usages.** Use `find_symbol` or `find_declaration` to inspect exact definitions in this repo. Fall back to `search_files` for existing usage examples.
2. **context7 MCP** (if listed): resolve the library id, then fetch docs for the specific topic or method signature (see `06-mcp.md`).
3. **Installed source or types.** Only if Serena and context7 give no clear signature:
   - Node: `node_modules/<pkg>/` (read `package.json` `types`, then the `.d.ts` file, narrow range)
   - Python: `bash scripts/py.sh -c "import <pkg>; print(<pkg>.__file__, <pkg>.__version__)"`, then `bash scripts/py.sh -c "help(<pkg>.<name>)"`
   - Go / Rust: `go doc <pkg>.<Name>` or the source in the module cache
4. **Ask the user** for a doc link if 1 to 3 give nothing.

Report the version you verified against in one line. If the installed version differs from the docs, trust the installed version.
