# /mcp-check.md — check that MCP servers are visible and working (modifies no files)

1. Look at the "MCP SERVERS" section of your system prompt. Write the list: server name → tool names (names only). If it is empty or missing, say so in one line and STOP. The user must check the connection (see `02-cline-settings/MCP_TROUBLESHOOTING.md`).
2. context7: call the tool that resolves a library name to an id, for the library "pytest". Use the real tool and parameter names from the schema. Report OK or FAIL and the first line of the result.
3. context7: call the docs tool for that id with the topic "fixtures". Report OK or FAIL.
4. serena: call the "get symbols overview" tool on any source file; if the repo has no source files yet, call the directory-listing tool on the repo root. Report OK or FAIL.
5. Final answer, at most 8 lines, as a table: server | tool | status. If something failed, add the exact error text.
