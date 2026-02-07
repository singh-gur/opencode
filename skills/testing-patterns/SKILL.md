---
name: testing-patterns
description: Comprehensive testing expertise for Python (pytest) and Go, covering fixtures, mocking, async testing, property-based testing, and test architecture
---

## Testing Patterns Expertise

Load this skill when writing tests, designing test architecture, or debugging test failures.

## Python Testing (pytest)

### Fixture Patterns
- **Factory fixtures**: Use `@pytest.fixture` returning a factory function for flexible test data creation
- **Scoped fixtures**: `session` for expensive setup (DB connections), `module` for shared state, `function` (default) for isolation
- **Fixture composition**: Small focused fixtures composed together, not monolithic setup fixtures
- **conftest.py hierarchy**: Project-level shared fixtures in root conftest, module-specific in local conftest
- **`tmp_path` / `tmp_path_factory`**: Always use pytest's built-in temp directories over manual tempfile
- **`autouse` sparingly**: Only for truly universal setup (e.g., reset global state); explicit is better

### Mocking Strategy
- **Prefer `monkeypatch` over `unittest.mock`** for attribute/env patching - it auto-reverts
- **Mock at the boundary**: Mock external services and I/O, not internal logic
- **`monkeypatch.setattr`**: For replacing functions/methods on objects
- **`monkeypatch.setenv` / `monkeypatch.delenv`**: For environment variables
- **`unittest.mock.AsyncMock`**: For async functions; `monkeypatch` doesn't handle async natively
- **`respx`** for httpx mocking, **`responses`** for requests mocking - prefer these over generic mocks for HTTP
- **Never mock what you don't own** without an adapter layer
- **`freezegun`** or **`time-machine`** for time-dependent tests

### Parametrize Patterns
```python
# Prefer parametrize over copy-pasted test functions
@pytest.mark.parametrize("input_val,expected", [
    ("valid@email.com", True),
    ("no-at-sign", False),
    ("", False),
])
def test_email_validation(input_val: str, expected: bool) -> None:
    assert validate_email(input_val) == expected

# Use ids for readable test names
@pytest.mark.parametrize("status_code", [400, 401, 403, 404, 500], ids=str)
```

### Async Testing
- **`pytest-asyncio`** with `mode = "auto"` in pyproject.toml to avoid decorating every test
- **`anyio`** for backend-agnostic async tests (supports both asyncio and trio)
- **`httpx.AsyncClient`** with FastAPI's `ASGITransport` for async API testing - no need for `TestClient`
- **Async fixtures**: Mark with `@pytest.fixture` and use `async def` - pytest-asyncio handles it

### Property-Based Testing (Hypothesis)
- **Use for**: Input validation, serialization roundtrips, mathematical properties, parsers
- **`@given(st.text())`**: Test with arbitrary strings instead of hand-picked examples
- **`@example("edge_case")`**: Pin known edge cases alongside generated ones
- **`st.builds(MyModel)`**: Auto-generate Pydantic/dataclass instances from their type hints
- **Settings**: `@settings(max_examples=200)` in CI, lower locally for speed
- **Stateful testing**: `RuleBasedStateMachine` for testing stateful APIs

### Test Architecture
- **Arrange-Act-Assert**: One logical assertion per test, clear separation of phases
- **Test naming**: `test_<unit>_<scenario>_<expected>` (e.g., `test_login_invalid_password_returns_401`)
- **Directory structure**: Mirror source layout - `src/auth/service.py` -> `tests/auth/test_service.py`
- **Markers**: Use `@pytest.mark.slow`, `@pytest.mark.integration`, `@pytest.mark.unit` and select with `-m`
- **Coverage**: `pytest-cov` with `--cov-fail-under=90`, exclude protocol classes and abstract methods

### Database Testing
- **Use transactions**: Wrap each test in a transaction and rollback - faster than recreating tables
- **`pytest-postgresql`** or testcontainers for real DB tests
- **Factory Boy**: `factory.Factory` with SQLAlchemy integration for model factories
- **Separate unit from integration**: Unit tests mock the DB layer, integration tests use real DB

### FastAPI Testing
```python
# Prefer async client for async endpoints
from httpx import ASGITransport, AsyncClient

@pytest.fixture
async def client(app: FastAPI) -> AsyncGenerator[AsyncClient, None]:
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac

async def test_create_user(client: AsyncClient) -> None:
    response = await client.post("/users", json={"name": "test"})
    assert response.status_code == 201
```

## Go Testing

### Table-Driven Tests
```go
func TestParseURL(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *URL
        wantErr bool
    }{
        {"valid http", "http://example.com", &URL{Scheme: "http"}, false},
        {"empty string", "", nil, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseURL(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("ParseURL() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            // Use go-cmp for struct comparison
            if diff := cmp.Diff(tt.want, got); diff != "" {
                t.Errorf("ParseURL() mismatch (-want +got):\n%s", diff)
            }
        })
    }
}
```

### Go Testing Patterns
- **`t.Helper()`**: Call in test helper functions so failures report the caller's line
- **`t.Parallel()`**: Add to independent tests for faster execution
- **`t.Cleanup(func())`**: Register cleanup instead of defer for better test lifecycle management
- **`testify/assert` vs stdlib**: Stdlib for simple projects, testify for complex assertions
- **`go-cmp`**: Prefer over `reflect.DeepEqual` for struct comparison - better diffs
- **`httptest.NewServer`**: For testing HTTP clients against a real server
- **`t.TempDir()`**: Auto-cleaned temp directory per test
- **Golden files**: Store expected output in `testdata/` and compare with `os.ReadFile`+`cmp.Diff`
- **Build tags**: `//go:build integration` to separate unit from integration tests

## When to Use This Skill

- Writing new tests or improving test coverage
- Designing test architecture for a new project
- Debugging flaky or slow tests
- Setting up test fixtures, factories, or mocking strategies
- Choosing between testing approaches (unit vs integration, mock vs real)
