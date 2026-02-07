---
name: ai-engineering
description: AI/ML engineering expertise for building production-ready agentic applications with LangChain, LangGraph, RAG pipelines, and modern AI tooling
---

## AI Engineering Expertise

Load this skill when building or working on AI/ML applications, agentic systems, RAG pipelines, or LLM integrations.

## Core Frameworks

- **LangChain** v0.3+: LLM orchestration, prompt management, tool integration, chains
- **LangGraph** v0.2+: Stateful multi-agent workflows, state machines, checkpointing
- **LLM Providers**: OpenAI, Anthropic, Google - with proper fallback strategies
- **Vector Stores**: Chroma, Pinecone, Weaviate for semantic search and RAG
- **Embedding Models**: OpenAI, Sentence Transformers, Cohere

## Agentic Design Patterns

### ReAct (Reasoning + Acting)
- Agent reasons about what to do, takes action, observes result, repeats
- Use LangGraph `StateGraph` with typed state (TypedDict), proper node/edge definitions
- Implement execution count limits to prevent infinite loops
- Always handle error states explicitly in the graph

### Multi-Agent Collaboration
- Specialized agents with focused capabilities (researcher, writer, reviewer)
- Orchestrator pattern for routing tasks to appropriate agents
- Shared state management across agents
- Clear handoff protocols and error propagation

### RAG (Retrieval-Augmented Generation)
- Document chunking strategies (semantic, recursive, token-based)
- Embedding selection based on use case and language
- Retriever tuning (k value, similarity threshold, MMR for diversity)
- Context window management and prompt construction
- Hybrid search (keyword + semantic) for better recall

## State Management

- **Immutable updates**: Return new state objects, never mutate in place
- **Typed state**: Use TypedDict or Pydantic models with strict validation
- **Checkpointing**: MemorySaver for dev, persistent backends (PostgreSQL, Redis) for production
- **Thread management**: Use thread_id for conversation persistence across invocations

## Production Patterns

### Resilience
- LLM fallback chains: primary model -> fallback model -> error response
- Retry with exponential backoff (tenacity or custom) for transient failures
- Circuit breaker pattern for external service calls
- Graceful degradation when AI components fail

### Observability
- **LangSmith** integration for prompt debugging, trace analysis, and optimization
- Structured logging with correlation IDs for request tracing
- Token usage and cost tracking per request/session
- Prometheus metrics: call counts, latency histograms, error rates, active sessions

### Performance
- LLM response caching (InMemoryCache for dev, Redis for production)
- Batch processing with semaphore-controlled concurrency
- Async/await throughout the stack for I/O-bound LLM calls
- Connection pooling for vector stores and databases

### Security
- Input sanitization: Remove injection patterns, enforce length limits
- Content moderation: Filter harmful content before and after LLM processing
- Rate limiting per user/session to control costs
- Secrets management: API keys via environment, never hardcoded

## Testing Strategy

- **Unit tests**: Mock LLM responses, test individual nodes/tools in isolation
- **Integration tests**: Test full workflow execution with controlled inputs
- **Behavior tests**: Validate agent decision-making with representative scenarios
- **Use pytest-asyncio** for async agent testing
- **Snapshot testing** for prompt templates to catch unintended changes

## Quality Gates for AI Code

1. `ruff check` with strict rules - zero violations
2. `basedpyright --strict` - zero type errors
3. `pytest --cov` - 90%+ coverage on non-LLM code
4. `bandit` - zero high-severity security issues
5. LangSmith evaluation scores above threshold for key behaviors

## When to Use This Skill

- Building LangChain/LangGraph agents or workflows
- Implementing RAG pipelines or semantic search
- Designing multi-agent systems
- Optimizing LLM usage (caching, batching, fallbacks)
- Adding observability to AI applications
