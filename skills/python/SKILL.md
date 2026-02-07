---
name: python
description: Python engineering expertise for production systems -- modern toolchain, FastAPI, SQLAlchemy, async patterns, type safety, and quality gates
---

## Python Engineering

Load this skill when working on Python projects.

## Modern Toolchain

- **Python 3.13+** with strict type hints and modern syntax (`type` statements, `match/case`)
- **uv** for package management, virtual environments, and lockfiles
- **ruff** for linting and formatting (replaces flake8, isort, black) -- configure with strict rules
- **basedpyright** (preferred) or **mypy** for static type checking in strict mode
- **pytest** with coverage, hypothesis for property-based testing
- **pre-commit hooks** for automated quality gates (ruff, pyright, pytest)

## Type Safety

### Principles
- Type-hint every function signature, including return types
- Use `TypedDict` for structured dicts, `dataclass` or Pydantic `BaseModel` over raw dicts
- Prefer `Literal["a", "b"]` over `str` for known value sets
- Use `Protocol` for structural subtyping (duck-typing with type safety)
- Use `TypeVar` and `Generic` for reusable typed containers
- `from __future__ import annotations` for forward references

### Common Patterns
```python
from dataclasses import dataclass, field
from typing import Protocol, TypeVar

# Immutable config with validation
@dataclass(frozen=True, slots=True)
class AppConfig:
    host: str
    port: int = 8080
    debug: bool = False

    def __post_init__(self) -> None:
        if not 1 <= self.port <= 65535:
            raise ValueError(f"Invalid port: {self.port}")

# Protocol for duck-typing with type safety
class Serializable(Protocol):
    def to_dict(self) -> dict[str, object]: ...

# Pydantic for external data validation
from pydantic import BaseModel, Field, ConfigDict

class UserCreate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, strict=True)
    name: str = Field(min_length=1, max_length=100)
    email: str = Field(pattern=r'^[\w.-]+@[\w.-]+\.\w+$')
```

## Production Stack

### FastAPI
- Async endpoints for I/O-bound operations
- Pydantic models for request/response validation
- Dependency injection for DB sessions, auth, config
- `lifespan` context manager for startup/shutdown (not deprecated `on_event`)
- Exception handlers for consistent error responses
- OpenAPI schema generation with proper descriptions

### SQLAlchemy 2.0+
- `mapped_column()` with type annotations (not legacy `Column()`)
- Async sessions with `async_sessionmaker`
- Alembic for migrations -- one concern per migration, test downgrades
- Eager loading (`selectinload`, `joinedload`) to prevent N+1 queries
- `expire_on_commit=False` when returning objects after commit

### Async Patterns
```python
# Proper async context management
from contextlib import asynccontextmanager
from collections.abc import AsyncGenerator

@asynccontextmanager
async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

# Concurrency with semaphore control
async def fetch_all(urls: list[str], max_concurrent: int = 10) -> list[Response]:
    semaphore = asyncio.Semaphore(max_concurrent)
    async def fetch(url: str) -> Response:
        async with semaphore:
            return await client.get(url)
    return await asyncio.gather(*(fetch(u) for u in urls))
```

### Observability
- **structlog** for structured JSON logging with bound context
- **Sentry** for error tracking with proper DSN and environment config
- Correlation IDs propagated through request lifecycle
- Prometheus metrics via `prometheus-client` or `starlette-prometheus`

```python
import structlog

logger = structlog.get_logger()

# Bind context once, use everywhere in the request
log = logger.bind(request_id=request_id, user_id=user.id)
log.info("processing_order", order_id=order.id, total=order.total)
```

## Code Standards

### Naming & Style
- snake_case for functions/variables, PascalCase for classes, UPPER_CASE for constants
- Descriptive names over abbreviations (`user_repository` not `usr_repo`)
- Private methods with single underscore prefix (`_validate_input`)
- Module-level `__all__` to control public API surface

### Error Handling
```python
# Custom exception hierarchy
class AppError(Exception):
    """Base application error."""

class NotFoundError(AppError):
    """Resource not found."""
    def __init__(self, resource: str, id: str) -> None:
        super().__init__(f"{resource} {id} not found")
        self.resource = resource
        self.id = id

# Never catch bare Exception unless re-raising
try:
    result = await process(data)
except NotFoundError:
    return Response(status_code=404)
except ValidationError as e:
    logger.warning("validation_failed", errors=e.errors())
    return Response(status_code=422)
```

### Security
- Parameterized queries always -- never f-string SQL
- Input validation via Pydantic before any processing
- Secrets via environment variables, never hardcoded
- `bandit` for static security analysis
- `secrets` module for token generation, not `random`

## Quality Gates

Before code is production-ready:

1. `ruff check` -- zero violations
2. `basedpyright --strict` -- zero type errors
3. `pytest --cov` -- 90%+ coverage target
4. `bandit -r src/` -- zero high-severity issues
5. All public APIs have docstrings

## Project Structure

```
src/
  myapp/
    __init__.py
    main.py           # FastAPI app factory, lifespan
    config.py          # Settings via pydantic-settings
    models/            # SQLAlchemy models
    schemas/           # Pydantic request/response models
    routes/            # API route handlers
    services/          # Business logic layer
    repositories/      # Data access layer
    exceptions.py      # Custom exception hierarchy
tests/
  conftest.py          # Shared fixtures
  test_routes/
  test_services/
pyproject.toml         # Single config file (ruff, pytest, pyright)
```

## pyproject.toml Essentials

```toml
[tool.ruff]
line-length = 88
target-version = "py313"
select = ["E", "W", "F", "I", "B", "C4", "UP", "ARG", "SIM", "TCH", "PTH", "PERF", "RUF"]

[tool.basedpyright]
typeCheckingMode = "strict"
pythonVersion = "3.13"

[tool.pytest.ini_options]
addopts = "-ra -q --strict-markers --strict-config"
asyncio_mode = "auto"
```

## When to Use This Skill

- Writing or reviewing Python code
- Setting up Python project structure and tooling
- Building FastAPI services or async applications
- Configuring linting, type checking, or testing pipelines
- Debugging Python-specific issues (async, imports, type errors)
