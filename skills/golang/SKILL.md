---
name: golang
description: Go engineering expertise covering idiomatic patterns, error handling, concurrency, project structure, interfaces, testing, and production tooling
---

## Go Engineering

Load this skill when writing, reviewing, or debugging Go code.

## Core Principles

- **Simplicity**: Go's strength is readability and lack of magic -- embrace it
- **Explicit error handling**: Every error is a value, handle it or propagate it
- **Composition over inheritance**: Embed interfaces and structs, no class hierarchies
- **Small interfaces**: Accept interfaces, return structs
- **Package-level design**: Packages are Go's primary abstraction boundary

## Project Structure

### Standard Layout
```
cmd/
  myapp/
    main.go           # Thin entry point -- parse flags, wire deps, start server
internal/             # Private packages (enforced by compiler)
  server/
    server.go         # HTTP server setup, routes
    handler.go        # Request handlers
  storage/
    postgres.go       # Database implementation
  config/
    config.go         # Configuration loading
pkg/                  # Public packages (importable by other projects) -- use sparingly
go.mod
go.sum
Makefile
```

### Package Design
- One package per directory, named after the directory
- Package name should describe what it provides, not what it contains (`http` not `httputils`)
- Avoid generic package names: `util`, `common`, `helpers`, `misc`
- `internal/` enforces encapsulation -- use it for anything not meant for external consumption
- Keep `main.go` thin -- just wiring, no business logic

## Error Handling

### Patterns
```go
// Always handle errors -- never use _ for errors in production code
result, err := doSomething()
if err != nil {
    return fmt.Errorf("doing something: %w", err)  // Wrap with context
}

// Sentinel errors for callers to check
var ErrNotFound = errors.New("not found")
var ErrConflict = errors.New("conflict")

// Check wrapped errors
if errors.Is(err, ErrNotFound) {
    // handle not found
}

// Custom error types for rich context
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}

// Check for custom error types
var valErr *ValidationError
if errors.As(err, &valErr) {
    // use valErr.Field, valErr.Message
}
```

### Best Practices
- **Wrap with context**: `fmt.Errorf("creating user: %w", err)` -- builds a readable error chain
- **Use `%w`** to allow callers to unwrap; use `%v` if you don't want the error inspectable
- **Sentinel errors** for expected conditions (not found, unauthorized)
- **Custom types** for errors that carry structured data
- **Don't log and return** -- do one or the other, not both
- **`panic`**: Only for truly unrecoverable programmer errors (violated invariants). Never for expected failures.
- **`defer`** for cleanup: `f, err := os.Open(...); if err != nil { return err }; defer f.Close()`

## Interfaces

### Design
```go
// Small interfaces -- often just one method
type Reader interface {
    Read(p []byte) error
}

// Accept interfaces, return structs
func NewService(repo UserRepository) *Service {
    return &Service{repo: repo}
}

// Define interfaces where they're used, not where they're implemented
// (consumer-side interfaces)
```

### Best Practices
- Interfaces with 1-3 methods are idiomatic; more than 5 is a smell
- Define the interface in the **consumer** package, not the provider
- Name single-method interfaces with `-er` suffix: `Reader`, `Writer`, `Closer`, `Stringer`
- Don't create interfaces preemptively -- extract when you have 2+ implementations or need testability
- Embed interfaces for composition: `type ReadCloser interface { Reader; Closer }`

## Concurrency

### Goroutines & Channels
```go
// Always use context for cancellation
func process(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)
    for _, item := range items {
        g.Go(func() error {
            return processItem(ctx, item)
        })
    }
    return g.Wait()
}

// Channels for communication between goroutines
func generator(ctx context.Context) <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)  // Always close channels from the sender side
        for i := 0; ; i++ {
            select {
            case ch <- i:
            case <-ctx.Done():
                return
            }
        }
    }()
    return ch
}
```

### Best Practices
- **`errgroup`** for concurrent tasks with error propagation (preferred over raw goroutines + WaitGroup)
- **Always pass `context.Context`** as first parameter to cancellable/long-running functions
- **Close channels from the sender**, never the receiver
- **`select` with `ctx.Done()`** in every goroutine loop to handle cancellation
- **`sync.Mutex`** for shared state; keep critical sections small
- **`sync.Once`** for lazy initialization (singletons, one-time setup)
- **Don't communicate by sharing memory; share memory by communicating** -- but use mutexes when channels add complexity

### Common Pitfalls
- **Goroutine leak**: Always ensure goroutines can exit (context cancellation, channel close, done signal)
- **Race conditions**: Run tests with `-race` flag always (`go test -race ./...`)
- **Closure capture in loops**: Go 1.22+ fixes the loop variable issue; for earlier versions, shadow the variable

## Structs & Methods

```go
// Use struct embedding for composition (not inheritance)
type Server struct {
    config Config
    logger *slog.Logger
    db     *sql.DB
}

// Constructor function -- validates and returns ready-to-use struct
func NewServer(cfg Config, logger *slog.Logger, db *sql.DB) (*Server, error) {
    if cfg.Port == 0 {
        return nil, errors.New("port is required")
    }
    return &Server{config: cfg, logger: logger, db: db}, nil
}

// Pointer receiver for methods that modify state or are expensive to copy
func (s *Server) Start(ctx context.Context) error { /* ... */ }

// Value receiver for small immutable types
func (c Config) Validate() error { /* ... */ }
```

### When to Use Pointer vs Value Receiver
- **Pointer** (`*T`): Method modifies the receiver, or the struct is large
- **Value** (`T`): Small structs, immutable operations, must be consistent per type (don't mix)

## Testing

### Table-Driven Tests
```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
    }{
        {name: "valid", input: `{"port": 8080}`, want: &Config{Port: 8080}},
        {name: "empty", input: "", wantErr: true},
        {name: "invalid json", input: "{bad", wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("ParseConfig() error = %v, wantErr %v", err, tt.wantErr)
            }
            if diff := cmp.Diff(tt.want, got); diff != "" {
                t.Errorf("ParseConfig() mismatch (-want +got):\n%s", diff)
            }
        })
    }
}
```

### Best Practices
- **`t.Helper()`**: Call in helper functions for better failure output
- **`t.Parallel()`**: Add to independent tests for faster execution
- **`t.Cleanup(func())`**: Register cleanup instead of `defer` in tests
- **`go-cmp`**: Prefer over `reflect.DeepEqual` for struct comparison -- better diffs
- **`httptest`**: For testing HTTP handlers and clients
- **`t.TempDir()`**: Auto-cleaned temp directory per test
- **Build tags**: `//go:build integration` to separate test types
- **`testcontainers-go`**: For integration tests against real databases
- **Run with `-race`**: Always: `go test -race -count=1 ./...`

## Logging

```go
// Use slog (stdlib, Go 1.21+) for structured logging
logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
    Level: slog.LevelInfo,
}))

// Bind context
logger = logger.With("service", "myapp", "version", version)

// Log with structured fields
logger.Info("request handled",
    "method", r.Method,
    "path", r.URL.Path,
    "status", status,
    "duration", time.Since(start),
)
```

## Common Standard Library Patterns

- **`context.Context`**: First parameter on every API boundary, carries cancellation and values
- **`io.Reader` / `io.Writer`**: Accept these for maximum composability
- **`encoding/json`**: Use struct tags; `omitempty` for optional fields; custom `MarshalJSON` for complex cases
- **`net/http`**: Use `http.NewServeMux()` (Go 1.22+ with method routing) or `chi`/`gin` for routing
- **`time.Duration`**: For timeouts and intervals, never raw `int` seconds
- **`filepath`** over `path` for OS file paths

## Linting & Quality

```bash
go vet ./...                  # Built-in static analysis
golangci-lint run             # Comprehensive linter (replaces many individual linters)
go test -race -count=1 ./...  # Tests with race detector
go build ./...                # Verify everything compiles
```

### golangci-lint Config
```yaml
# .golangci.yml
linters:
  enable:
    - errcheck
    - govet
    - staticcheck
    - unused
    - gosimple
    - ineffassign
    - revive
    - gocritic
    - errorlint      # Proper error wrapping
    - exhaustive      # Exhaustive enum switches
```

## When to Use This Skill

- Writing or reviewing Go code
- Designing package structure or public APIs
- Implementing concurrent or async patterns
- Writing table-driven tests or integration tests
- Debugging goroutine leaks, race conditions, or error handling issues
- Setting up Go CI/CD (linting, testing, building)
