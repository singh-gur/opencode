---
name: postgresql
description: Advanced PostgreSQL expertise for query optimization, indexing strategies, schema design, EXPLAIN analysis, and Alembic migration patterns
---

## PostgreSQL Expertise

Load this skill when working on database schema design, query optimization, migrations, or debugging performance issues.

## Query Optimization

### EXPLAIN ANALYZE
```sql
-- Always use ANALYZE for actual execution times (not just estimates)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...;
```

**Reading EXPLAIN output:**
- **Seq Scan**: Full table scan - fine for small tables, bad for large ones
- **Index Scan**: Uses index to find rows, then fetches from heap
- **Index Only Scan**: Best case - all data from index, no heap access (check `Heap Fetches`)
- **Bitmap Index Scan + Bitmap Heap Scan**: Index narrows results, then batch heap fetch - good for medium selectivity
- **Nested Loop**: Good for small outer sets; watch for large outer * inner
- **Hash Join**: Good for equi-joins on larger datasets; watch `Batches` > 1 (spilling to disk)
- **Merge Join**: Good for pre-sorted data or large joins
- **`actual time=X..Y`**: X is startup time, Y is total time - big gap means late-producing nodes
- **`rows=N` vs `Rows Removed by Filter`**: Large ratio means poor selectivity or missing index
- **`Buffers: shared hit=X read=Y`**: `read` means disk I/O; high read = cold cache or missing index

### Common Optimization Patterns
- **Covering indexes**: `CREATE INDEX idx ON t(a, b) INCLUDE (c)` - avoid heap lookups
- **Partial indexes**: `CREATE INDEX idx ON orders(status) WHERE status = 'pending'` - smaller, faster
- **Expression indexes**: `CREATE INDEX idx ON users(lower(email))` for case-insensitive lookups
- **`EXISTS` over `IN` for subqueries**: `WHERE EXISTS (SELECT 1 FROM ...)` often faster than `IN (SELECT ...)`
- **Avoid `SELECT *`**: Fetch only needed columns to enable index-only scans
- **`LIMIT` with `ORDER BY`**: Ensure the ORDER BY column is indexed for top-N queries
- **CTEs are optimization fences (pre-PG12)**: In PG12+ CTEs can be inlined; use `MATERIALIZED` to force old behavior

## Indexing Strategies

### B-tree (default)
- Equality and range queries (`=`, `<`, `>`, `BETWEEN`, `IS NULL`)
- Multi-column: leftmost prefix rule applies - `(a, b, c)` supports queries on `a`, `a+b`, `a+b+c`
- Column order matters: put equality columns first, range columns last

### GIN (Generalized Inverted Index)
- **JSONB**: `CREATE INDEX idx ON t USING gin(data jsonb_path_ops)` for `@>` containment
- **Full-text search**: `CREATE INDEX idx ON t USING gin(to_tsvector('english', body))`
- **Arrays**: `CREATE INDEX idx ON t USING gin(tags)` for `@>`, `&&` operators
- **Trigram**: `CREATE EXTENSION pg_trgm; CREATE INDEX idx ON t USING gin(name gin_trgm_ops)` for `LIKE '%query%'`
- Slower to update than B-tree; consider `fastupdate = off` for write-heavy tables

### GiST (Generalized Search Tree)
- Range types, geometric data, PostGIS spatial queries
- Full-text search (alternative to GIN - smaller but slower for lookups)
- Exclusion constraints: `EXCLUDE USING gist (room WITH =, period WITH &&)` for no-overlap booking

### BRIN (Block Range Index)
- For naturally ordered data (timestamps, auto-increment IDs)
- Tiny index size, but only useful when physical row order correlates with column value
- Good for append-only time-series tables

## Schema Design

### Data Types
- **`uuid`** over `serial` for distributed-safe primary keys (use `gen_random_uuid()`)
- **`timestamptz`** always, never `timestamp` - avoid timezone ambiguity
- **`text`** over `varchar(n)` - no performance difference in Postgres, less migration friction
- **`numeric`** for money/financial data, never `float`/`double`
- **`jsonb`** over `json` - indexable, faster operations, slight storage overhead
- **`inet`/`cidr`** for IP addresses, not text
- **`int4range`/`tstzrange`** for range data with proper exclusion constraints

### Normalization & Denormalization
- Start normalized (3NF); denormalize only when profiling proves a bottleneck
- **Materialized views** for expensive aggregations: `REFRESH MATERIALIZED VIEW CONCURRENTLY` for no-lock refresh
- **Generated columns**: `ALTER TABLE t ADD COLUMN full_name text GENERATED ALWAYS AS (first || ' ' || last) STORED`

### Partitioning
```sql
-- Partition by range for time-series data
CREATE TABLE events (
    id         uuid DEFAULT gen_random_uuid(),
    created_at timestamptz NOT NULL,
    data       jsonb
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2025_q1 PARTITION OF events
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
```
- **When**: Tables > 10M rows with clear partition key (usually timestamp)
- **Pruning**: Queries with partition key in WHERE clause skip irrelevant partitions
- **Maintenance**: Use `pg_partman` for automatic partition creation/cleanup

## Alembic Migration Patterns

### Safe Migrations (Zero-Downtime)
- **Add column**: Always `nullable=True` first, backfill, then add `NOT NULL` constraint
- **Add index**: Use `op.create_index(..., postgresql_concurrently=True)` and set `autocommit=True` in migration context
- **Rename column**: Don't - add new column, migrate data, drop old (or use views for transition)
- **Drop column**: Remove from application code first, deploy, then drop column
- **Add NOT NULL**: Add as `CHECK` constraint first with `NOT VALID`, then `VALIDATE CONSTRAINT` separately

### Migration Structure
```python
# Always include both upgrade and downgrade
def upgrade() -> None:
    op.add_column("users", sa.Column("email_verified", sa.Boolean(), nullable=True))
    # Backfill in batches for large tables
    op.execute("UPDATE users SET email_verified = false WHERE email_verified IS NULL")

def downgrade() -> None:
    op.drop_column("users", "email_verified")
```

### Best Practices
- **One concern per migration**: Don't mix schema changes with data migrations
- **Test downgrades**: Run `alembic downgrade -1` in CI to catch broken rollbacks
- **Lock timeout**: Set `statement_timeout` in migrations to avoid long locks
- **`--autogenerate` with review**: Always review generated migrations - autogenerate misses constraints, indexes, and data migrations

## SQLAlchemy 2.0+ Patterns

### Typed Query Patterns
```python
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

async def get_user_by_email(session: AsyncSession, email: str) -> User | None:
    stmt = select(User).where(User.email == email)
    result = await session.execute(stmt)
    return result.scalar_one_or_none()

# Eager loading to avoid N+1
stmt = select(User).options(selectinload(User.orders)).where(User.active == True)
```

### Session Management
- **FastAPI**: Use `async_sessionmaker` with dependency injection, one session per request
- **Scoped sessions**: Never share sessions across threads/tasks
- **`expire_on_commit=False`**: Set when returning objects after commit to avoid lazy load errors

## Performance Monitoring

### Key Queries
```sql
-- Slow queries (requires pg_stat_statements)
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 20;

-- Unused indexes (candidates for removal)
SELECT indexrelname, idx_scan FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND indexrelname NOT LIKE '%pkey%' ORDER BY pg_relation_size(indexrelid) DESC;

-- Table bloat estimation
SELECT relname, n_dead_tup, last_autovacuum FROM pg_stat_user_tables
WHERE n_dead_tup > 1000 ORDER BY n_dead_tup DESC;

-- Cache hit ratio (should be > 99%)
SELECT sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read), 0) AS ratio
FROM pg_statio_user_tables;
```

### Connection Management
- **PgBouncer** for connection pooling in production (transaction mode)
- **`pool_size` + `max_overflow`** in SQLAlchemy for application-level pooling
- Monitor `pg_stat_activity` for connection count and long-running queries

## When to Use This Skill

- Optimizing slow queries or analyzing EXPLAIN output
- Designing database schemas or choosing appropriate data types
- Writing Alembic migrations, especially for production zero-downtime deploys
- Choosing indexing strategies for specific query patterns
- Debugging PostgreSQL performance issues or connection problems
