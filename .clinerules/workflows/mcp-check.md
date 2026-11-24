# /mcp-check.md — check that MCP servers are visible and working (modifies no files)

1. Check the "MCP SERVERS" section of your system prompt. List: `server -> tool names`.
   If empty or missing, say so in one line and tell the user to check Cline's MCP settings against `mcp/cline_mcp_settings.windows.example.json` (Windows) or `mcp/cline_mcp_settings.example.json` (POSIX), ensure `npx`/`uvx` are on PATH and Serena `--project` points to the repo root, then STOP.
2. `context7`: call the library-id resolution tool (e.g., `resolve-library-id`) for `"pytest"`, using the exact tool and parameter names from its schema. Report OK or FAIL and the first line of the result.
3. `context7`: call the docs query tool (e.g., `query-docs` or `get-library-docs` as shown in MCP SERVERS) for that id with topic `"fixtures"`. Report OK or FAIL.
4. `serena`: call `get_symbols_overview` on any source file, or `list_dir` on `.` if no source files exist yet. Report OK or FAIL.
5. Final answer, at most 8 lines, as a table: `server | tool | status`. Include exact error text if anything failed.
