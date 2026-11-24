---
name: mas-architecture
description: Use when building a Multi-Agent System (MAS), AI workflow, agentic orchestrator, tool-calling pipeline, or LLM-backed service. Ensures clean boundaries, typed contracts, deterministic tests, and loop safety.
---

# mas-architecture

1. **Package layout (`src/<pkg>/`):**
   - `config.py`: typed settings (`model_name`, `max_steps`, `timeout_sec`, `max_tokens`, env-backed).
   - `schemas/`: Pydantic v2 I/O models (`AgentState`, `AgentMessage`, `ToolResult`, `FinalReport`).
   - `prompts/`: prompt templates separated from Python control flow (`.txt`/`.md` or dedicated builder functions).
   - `llm/`: narrow `LLMClient` protocol/interface + real provider adapter (timeouts, retries on transient 429/5xx, structured output parsing) + `FakeLLMClient` for offline tests.
   - `tools/`: each tool has typed Pydantic input/output, explicit validation, and safe error return (never crash the whole graph on bad tool input).
   - `agents/`: single-responsibility agent nodes/roles taking `state` + `LLMClient` + `tools` via injection.
   - `orchestrator/`: explicit state machine / graph / router with hard `max_steps` (and loop-detection / budget guard) so agents cannot spin infinitely.
2. **Observability & Error handling:**
   - Log every step with `run_id`, `step_index`, `agent_name`, `tool_name`, `duration_ms`, and error status (never log raw API keys).
   - Never silently swallow malformed LLM output: validate with Pydantic and feed concise validation error back (bounded retries <= 2) or fail explicitly.
3. **Testing & Smoke (`verify.sh`):**
   - Unit tests: tool validation, state transitions, budget/max-step cutoff, prompt rendering.
   - Integration test + `scripts/smoke.sh`: run the full `orchestrator` end-to-end with `FakeLLMClient` scripted responses (happy path + tool error recovery + max-step termination) and assert the final `FinalReport` schema and trace logs.
