# MCP tools (context7, serena)

Use ONLY the server and tool names listed in the MCP SERVERS section of your system prompt, with their exact parameter names. None listed: say "MCP servers are not visible, check the MCP panel" once and use the `api-lookup` fallback.

- **context7**: before code that calls a 3rd-party library not yet used in this repo, and on `AttributeError`/`TypeError`/wrong-signature errors. Check the installed version first (`bash scripts/py.sh -c "import <pkg>; print(<pkg>.__version__)"`), then `resolve-library-id`, then the docs tool, narrow to the installed version. Not for stdlib.
- **serena**: `find_referencing_symbols` before changing or renaming a signature; `get_symbols_overview` before reading a file over ~200 lines; `find_symbol` to jump to a definition. To change an existing function or method use `replace_symbol_body`; to add one use `insert_after_symbol` / `insert_before_symbol` (cheapest edit: no exact-text matching). New files: `write_to_file`. Symbol edit failed: `replace_in_file`.
- Overview of an existing project (what files and functions exist): ONE `read_file memory-bank/repo-map.md`, not many `list_dir` / `get_symbols_overview` calls. Serena is for references and symbol edits.
- Never call Serena `write_memory`, `read_memory`, `list_memories`, `onboarding`. Project memory is `memory-bank/`.
- An MCP call failed twice: stop using that server for this task, note it in one line, use `api-lookup`.
- Keep only the 3-10 relevant lines of an MCP result. Plain text search and small files: `search_files` / `read_file` are cheaper. Check: `/mcp-check.md`.
