---
name: rust
description: Rust engineering expertise covering idiomatic patterns, ownership best practices, code organization, error handling, testing, performance, and production-ready Rust
---

## Rust Engineering

Load this skill when writing, reviewing, or debugging Rust code.

## Ownership & Borrowing

### The Three Rules
1. Each value has exactly **one owner**
2. When the owner goes out of scope, the value is **dropped**
3. You can have **either** one `&mut T` **or** any number of `&T` -- never both simultaneously

### Borrowing Best Practices
- Accept `&str` not `&String`, `&[T]` not `&Vec<T>`, `&Path` not `&PathBuf` -- borrow the slice, not the container
- Return owned types (`String`, `Vec<T>`) from constructors and builders; return borrows from accessors
- Prefer borrowing in function parameters unless the function needs to store the value
- Use `Cow<'_, str>` when a function sometimes borrows and sometimes needs to allocate

### Borrow Checker Escape Hatches (in order of preference)
1. **Restructure code** so borrows don't overlap -- most common real fix
2. **Clone** -- acceptable for prototyping or infrequent paths; profile before optimizing away
3. **`Rc<T>`** / **`Arc<T>`** -- shared ownership; Arc for cross-thread
4. **Interior mutability** (`RefCell<T>`, `Mutex<T>`) -- when you need mutation through a shared reference
5. **Lifetime annotations** -- when returning references tied to input lifetimes

### Lifetime Guidelines
- Trust elision rules first -- only annotate when the compiler asks
- Named lifetimes should describe *what* they're tied to, not just `'a`: `'input`, `'conn`, `'src`
- Avoid `'static` unless the data truly lives forever (leaked allocations, constants, `lazy_static`)
- If a struct holds a reference, it almost always needs a lifetime parameter -- consider whether you should own the data instead

## Error Handling

### Strategy
- **Applications**: Use `anyhow::Result<T>` -- automatic context chaining, no custom types needed
- **Libraries**: Use `thiserror` to derive custom error enums -- callers can match on variants
- **`?` operator**: Default propagation mechanism; add `.context("msg")?` for actionable error messages
- **`unwrap()` / `expect()`**: Only in tests, examples, or when invariants are provably upheld (document why)
- **`panic!`**: Only for unrecoverable programmer errors, never for expected failure modes

```rust
// Application-style error handling with anyhow
use anyhow::{Context, Result};

fn load_config(path: &Path) -> Result<Config> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read config from {}", path.display()))?;
    let config: Config = toml::from_str(&text)
        .context("failed to parse config TOML")?;
    Ok(config)
}
```

```rust
// Library-style error types with thiserror
#[derive(Debug, thiserror::Error)]
pub enum ParseError {
    #[error("invalid header at byte {offset}")]
    InvalidHeader { offset: usize },
    #[error("unsupported version: {0}")]
    UnsupportedVersion(u32),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}
```

## Idiomatic Patterns

### Newtype Pattern
```rust
// Wrap primitive types for type safety -- prevents mixing up IDs, indices, etc.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct UserId(u64);

impl UserId {
    pub fn new(id: u64) -> Self { Self(id) }
    pub fn as_u64(self) -> u64 { self.0 }
}
```

### Builder Pattern
```rust
// Use for structs with many optional fields
#[derive(Debug)]
pub struct ServerConfig {
    host: String,
    port: u16,
    max_connections: usize,
    tls: bool,
}

#[derive(Default)]
pub struct ServerConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    max_connections: Option<usize>,
    tls: Option<bool>,
}

impl ServerConfigBuilder {
    pub fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    pub fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    pub fn build(self) -> Result<ServerConfig, &'static str> {
        Ok(ServerConfig {
            host: self.host.ok_or("host is required")?,
            port: self.port.unwrap_or(8080),
            max_connections: self.max_connections.unwrap_or(100),
            tls: self.tls.unwrap_or(false),
        })
    }
}
```

### `From` / `Into` Conversions
```rust
// Implement From for clean type conversions -- Into is auto-derived
impl From<UserId> for u64 {
    fn from(id: UserId) -> Self { id.0 }
}

// Accept impl Into<String> for ergonomic APIs
pub fn set_name(&mut self, name: impl Into<String>) {
    self.name = name.into();  // Accepts &str, String, Cow, etc.
}
```

### Type-State Pattern
```rust
// Use zero-sized types to encode state transitions at compile time
pub struct Connection<S> { inner: TcpStream, _state: S }
pub struct Disconnected;
pub struct Connected;
pub struct Authenticated;

impl Connection<Disconnected> {
    pub fn connect(addr: &str) -> Result<Connection<Connected>> { /* ... */ }
}

impl Connection<Connected> {
    pub fn authenticate(self, creds: &Credentials) -> Result<Connection<Authenticated>> { /* ... */ }
}

impl Connection<Authenticated> {
    pub fn query(&self, sql: &str) -> Result<Rows> { /* ... */ }
}
// Compile error: can't call .query() on Connection<Connected>
```

### Option/Result Combinators
```rust
// Prefer combinators over nested match for simple transformations
let name = user.map(|u| u.name.as_str()).unwrap_or("anonymous");

// Chain fallible operations
let config = find_local_config()
    .or_else(find_global_config)
    .ok_or_else(|| anyhow!("no config file found"))?;

// Convert between Option and Result
let user = find_user(id).ok_or(AppError::NotFound)?;
```

## Code Organization

### Module Structure
```
src/
  lib.rs              # Public API surface, re-exports
  main.rs             # Binary entry point (thin -- calls into lib)
  config.rs           # Small module = single file
  server/             # Larger module = directory
    mod.rs            # Module root, pub re-exports
    handler.rs        # Internal submodule
    middleware.rs
  error.rs            # Crate-wide error types
tests/
  integration_test.rs # Integration tests (only test public API)
benches/
  benchmarks.rs       # Criterion benchmarks
```

### Visibility Rules
- **`pub`**: Part of your public API -- commit to maintaining it
- **`pub(crate)`**: Visible within the crate but not to consumers -- use liberally for internal sharing
- **`pub(super)`**: Visible to parent module only -- for tightly coupled submodules
- **private** (default): Prefer this; expose only what's necessary
- Use `pub use` re-exports in `lib.rs` to flatten module hierarchy for consumers

### When to Split Into Crates (Workspace)
- Code is reusable across multiple binaries
- You want independent compilation for build speed
- A logical boundary exists (e.g., `myapp-core`, `myapp-cli`, `myapp-server`)

## Structs, Traits & Derives

### Derive Strategy
```rust
// Minimum useful set for most types
#[derive(Debug)]                            // Always -- enables {:?} formatting
#[derive(Clone)]                            // When copies make sense
#[derive(PartialEq, Eq)]                   // When equality comparison needed
#[derive(Hash)]                             // When used as HashMap/HashSet key
#[derive(serde::Serialize, serde::Deserialize)]  // For serialization
```

### Trait Design
- Keep traits small and focused -- prefer multiple small traits over one large one
- Provide default implementations where a sensible default exists
- Use associated types over generic parameters when there's only one sensible implementation per type
- `#[non_exhaustive]` on public enums and structs to allow future additions without breaking changes

### Display vs Debug
```rust
// Debug (#[derive(Debug)]): For developers, verbose, auto-derivable
// Display (manual impl): For users/logs, concise, human-readable

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NotFound(id) => write!(f, "resource {id} not found"),
            Self::Unauthorized => write!(f, "authentication required"),
        }
    }
}
```

## Iterators

```rust
// Prefer iterator chains over manual loops -- zero-cost, more readable
let active_emails: Vec<&str> = users.iter()
    .filter(|u| u.is_active)
    .map(|u| u.email.as_str())
    .collect();

// Use collect() turbofish when type isn't clear from context
let lookup = users.iter()
    .map(|u| (u.id, u))
    .collect::<HashMap<_, _>>();

// Fallible iteration -- collect into Result to short-circuit on first error
let parsed: Result<Vec<Config>, _> = lines.iter()
    .map(|line| parse_config(line))
    .collect();
```

### Iterator Best Practices
- `.iter()` for `&T`, `.iter_mut()` for `&mut T`, `.into_iter()` for owned `T`
- Prefer `for item in &collection` over `.iter()` in for loops (idiomatic sugar)
- Use `.enumerate()` instead of manual index tracking
- Use `.zip()` to iterate two collections in parallel
- Avoid `.collect()` when you only need one value -- use `.find()`, `.any()`, `.position()`

## Concurrency

### Async (Tokio)
```rust
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let handle = tokio::spawn(async { fetch_data().await });
    let result = handle.await??;  // JoinError? then inner error?
    Ok(())
}
```

- Prefer `tokio::spawn` for independent work, `tokio::join!` for concurrent awaits
- Use `tokio::select!` for racing futures (first one wins)
- **Never block** inside async: use `tokio::task::spawn_blocking` for CPU-heavy or synchronous I/O
- `Arc<Mutex<T>>` for shared mutable state; prefer `tokio::sync::Mutex` over `std::sync::Mutex` if you hold the lock across `.await`

### Send + Sync
- Most types are `Send + Sync` automatically -- the compiler tells you when they aren't
- `Rc<T>` is not Send -- use `Arc<T>` for cross-thread sharing
- `RefCell<T>` is not Sync -- use `Mutex<T>` or `RwLock<T>` for shared mutable access

## Testing

### Conventions
```rust
// Unit tests live in the same file, inside #[cfg(test)]
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_valid_input() {
        let result = parse("42").unwrap();
        assert_eq!(result, 42);
    }

    #[test]
    fn parse_invalid_input_returns_error() {
        assert!(parse("abc").is_err());
    }

    #[test]
    #[should_panic(expected = "out of bounds")]
    fn index_out_of_bounds_panics() {
        let v = vec![1, 2, 3];
        let _ = v[5];
    }
}
```

### Testing Best Practices
- **Doc tests**: Code examples in `///` comments are compiled and run -- keep them working
- **Integration tests** in `tests/` directory only test the public API
- **`assert_eq!` over `assert!`**: Better error messages showing both values
- **`proptest`** / **`quickcheck`**: Property-based testing for parsers, serialization roundtrips
- **Test names**: `test_<fn>_<scenario>_<expected>` (e.g., `test_parse_empty_string_returns_error`)
- **`#[ignore]`**: Mark slow tests, run with `cargo test -- --ignored`
- **`cargo-nextest`**: Faster parallel test runner, better output

## Clippy & Code Quality

### Recommended Lints
```toml
# Cargo.toml or clippy.toml
[lints.clippy]
pedantic = { level = "warn", priority = -1 }
# Selectively allow overly strict pedantic lints
module_name_repetitions = "allow"
must_use_candidate = "allow"
```

### Key Attributes
- **`#[must_use]`**: On functions whose return value should not be ignored (Result-returning fns, builders)
- **`#[non_exhaustive]`**: On public enums/structs to allow additions without semver breaks
- **`#[inline]`**: Only when profiling shows it helps -- compiler usually inlines correctly
- **`#[cfg(feature = "...")]`**: For optional functionality behind feature flags

### `cargo fmt` + `cargo clippy` in CI
```bash
cargo fmt -- --check           # Fail if not formatted
cargo clippy -- -D warnings    # Treat warnings as errors
```

## Performance Considerations

- **`Cow<'_, str>`**: Avoids allocation when input is already the right type
- **`Box<dyn Trait>`** vs generics: Dynamic dispatch for heterogeneous collections; generics for monomorphized hot paths
- **`SmallVec`** / **`tinyvec`**: Stack-allocated for small, known-size collections
- **Avoid unnecessary `.clone()`**: Profile first, but prefer borrowing in hot loops
- **`String` reuse**: Use `.clear()` + `.push_str()` instead of allocating new strings in loops
- **`with_capacity()`**: Pre-allocate `Vec`, `String`, `HashMap` when size is known
- **`criterion`** for benchmarks -- statistical analysis, regression detection

## Unsafe Guidelines

- **Minimize surface area**: Wrap unsafe in a safe function with documented invariants
- **Comment every `unsafe` block** explaining why it's sound
- **Never** use unsafe to bypass the borrow checker -- it means the design is wrong
- Use `#[deny(unsafe_code)]` at crate level; `#[allow(unsafe_code)]` only on specific modules that need it
- Prefer existing safe abstractions (`crossbeam`, `rayon`, `parking_lot`) over hand-rolled unsafe

## Essential Crates

| Crate | Purpose |
|-------|---------|
| `serde` + `serde_json` / `toml` | Serialization/deserialization |
| `tokio` | Async runtime |
| `reqwest` | HTTP client |
| `axum` | Web framework |
| `clap` | CLI argument parsing |
| `anyhow` | Error handling (applications) |
| `thiserror` | Error types (libraries) |
| `tracing` + `tracing-subscriber` | Structured logging & diagnostics |
| `sqlx` | Async SQL with compile-time query checking |
| `proptest` | Property-based testing |
| `criterion` | Benchmarking |

## Cargo Workflows

```bash
cargo new myproject              # Create project
cargo add serde --features derive # Add dependency
cargo check                      # Fast type checking (no codegen)
cargo build                      # Debug build
cargo build --release            # Optimized build
cargo test                       # Run all tests
cargo test -- --nocapture        # Show println! output in tests
cargo clippy -- -D warnings      # Lint strictly
cargo fmt                        # Format code
cargo doc --open                 # Generate & view docs
cargo udeps                      # Find unused dependencies (cargo-udeps)
cargo audit                      # Check for known vulnerabilities (cargo-audit)
```

## When to Use This Skill

- Writing or reviewing Rust code
- Debugging ownership, borrow checker, or lifetime errors
- Designing module structure or public APIs
- Choosing patterns (newtype, builder, type-state, error types)
- Optimizing Rust performance or reducing allocations
- Setting up Rust CI/CD (clippy, fmt, test, audit)
