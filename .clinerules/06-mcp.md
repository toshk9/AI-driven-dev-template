# MCP tools (context7, serena)

The "MCP SERVERS" section of your system prompt lists the EXACT server and tool names with their schemas. Use ONLY those names; do not guess. If no servers are listed, say "MCP servers are not visible, check the MCP panel" in one line and continue with `api-lookup` fallback.

## How to call
```
<use_mcp_tool>
<server_name>NAME_FROM_MCP_SERVERS</server_name>
<tool_name>TOOL_NAME_FROM_MCP_SERVERS</tool_name>
<arguments>
{ "parameter_name": "value" }
</arguments>
</use_mcp_tool>
```
Valid JSON, exact parameter names from the schema. One call per message.

## When to use them
- **context7** (library docs): MANDATORY before writing code that calls a 3rd-party library not yet used in this repo, and whenever an error shows `AttributeError`, `TypeError`, wrong signature, or deprecated API.
  1. Check the installed version first (`bash scripts/py.sh -c "import <pkg>; print(getattr(<pkg>, '__version__', '?'))"`).
  2. Resolve library id (`resolve-library-id`), then query docs (`query-docs` or `get-library-docs` — use the exact tool name shown in MCP SERVERS) for the narrow API/topic matching that installed version. Not needed for stdlib.
- **serena** (symbols & refactoring): before changing or renaming any function, class, or method signature, run `find_referencing_symbols`. For files over ~200 lines use `get_symbols_overview` before `read_file`. To jump to a definition: `find_symbol`.
- **serena `initial_instructions`**: call ONLY when the repo already has source code, and ONLY AFTER reading `memory-bank/activeContext.md` in BOOT. Ignore Serena's own memory instructions: project memory is `memory-bank/`.
- Serena symbol-edit tools (`replace_symbol_body`, `insert_after_symbol`): good for editing existing functions/methods. New files and small edits: `write_to_file` / `replace_in_file`. Failed symbol edit -> fall back to `replace_in_file`.
- Plain text search and small files: `search_files` and `read_file` are faster and cheaper.

## Do not
- Never call Serena `write_memory`, `read_memory`, `list_memories`, `onboarding`.
- If an MCP call fails twice: stop calling that server for this task, note it in one line, and fall back to installed source/types in `.cline/skills/api-lookup/SKILL.md`.
- Never paste raw MCP dumps into chat; summarize only the 3–10 relevant lines.
- To verify MCP connectivity, run `/mcp-check.md`.
