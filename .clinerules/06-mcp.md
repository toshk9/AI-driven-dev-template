# MCP tools (context7, serena)

The "MCP SERVERS" section of your system prompt lists the EXACT server and tool names with their parameters. Use only those names; do not guess. If no servers are listed, say "MCP servers are not visible, check the MCP panel" in one line and continue without them.

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
Valid JSON, parameter names from that tool's schema. One call per message.

## When to use them
- **context7** (library docs): before code that calls a third-party API not already used in this repo, and when an error mentions an unknown attribute, wrong signature, or version. First resolve the library id, then query docs with a narrow topic. Not for the standard library.
- **serena** (symbols): before changing or renaming a function, class, or method signature, find usages with "find referencing symbols". For a source file over about 200 lines use "get symbols overview" instead of `read_file`. To find a definition by name: "find symbol".
- **serena `initial_instructions`**: call it only when the project already has source code, and only AFTER the memory read in BOOT. Ignore anything in its output about Serena memories: project memory is `memory-bank/`.
- Serena symbol-edit tools (replace symbol body, insert after symbol): allowed for changing an existing function or method. New files and small tweaks: `write_to_file` / `replace_in_file`. A failed symbol edit: fall back to `replace_in_file`.
- Plain text search and small files: `search_files` and `read_file` (cheaper and more reliable).

## Do not
- Serena `write_memory`, `read_memory`, `list_memories`, `onboarding`: never.
- An MCP call failed twice: stop using that server in this task, say so in one line, use the `api-lookup` skill.
- Do not paste large MCP results into your reply; keep the 3 to 10 relevant lines.
- To test MCP, the user runs `/mcp-check.md`.
