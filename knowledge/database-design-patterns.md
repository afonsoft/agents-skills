# Database Design Patterns

This document contains patterns, best practices, and implementation guides for database design, optimization, and management across different database types.

## Overview

Comprehensive guide for relational database design, NoSQL data modeling, performance optimization, and database migration strategies.

## Quick Reference

| Pattern | Database Type | Use Case | Complexity |
|---------|---------------|----------|------------|
| **Normalization** | Relational | Data integrity, reduce redundancy | Medium |
| **Denormalization** | Relational | Read performance, analytics | Medium |
| **Event Sourcing** | NoSQL | Audit trails, temporal data | High |
| **CQRS** | Mixed | Read/write optimization | High |
| **Sharding** | Both | Scalability, performance | High |

## Relational Database Patterns

### Pattern 1: Normalization Hierarchy

- **When to use**: Transactional systems, data integrity requirements
- **Implementation**: 1NF → 2NF → 3NF → BCNF
- **Code Example**:
```sql
-- 1NF: Atomic values
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2NF: No partial dependencies
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY REFERENCES users(id),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    address TEXT
);

-- 3NF: No transitive dependencies
CREATE TABLE addresses (
    id INT PRIMARY KEY,
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(100)
);

CREATE TABLE user_addresses (
    user_id INT REFERENCES users(id),
    address_id INT REFERENCES addresses(id),
    address_type ENUM('billing', 'shipping'),
    PRIMARY KEY (user_id, address_id)
);
```

- **Pros**: Data integrity, reduced redundancy, consistency
- **Cons**: Query complexity, join overhead, performance impact

### Pattern 2: Indexing Strategy

- **When to use**: Query optimization, performance improvement
- **Implementation**: Strategic index placement based on query patterns
- **Code Example**:
```sql
-- Primary key index (automatically created)
ALTER TABLE orders ADD PRIMARY KEY (id);

-- Unique index for business constraints
CREATE UNIQUE INDEX idx_orders_order_number ON orders(order_number);

-- Composite index for common query patterns
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date DESC);

-- Partial index for filtered data
CREATE INDEX idx_active_users ON users(id) WHERE status = 'active';

-- Covering index for frequently accessed columns
CREATE INDEX idx_products_category_price ON products(category_id, price) 
INCLUDE (name, description);

-- Full-text search index
CREATE INDEX idx_products_search ON products USING gin(to_tsvector('english', name || ' ' || description));

-- JSON index for document storage
CREATE INDEX idx_user_metadata ON users USING gin(metadata);

-- Function-based index
CREATE INDEX idx_users_lower_email ON users(lower(email));

-- Partitioned table with local indexes
CREATE TABLE orders_partitioned (
    id BIGINT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2023_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');

CREATE INDEX idx_orders_2023_q1_customer ON orders_2023_q1(customer_id);
```

- **Pros**: Query performance, data retrieval speed
- **Cons**: Storage overhead, write performance impact

### Pattern 3: Database Views and Materialized Views

- **When to use**: Data abstraction, complex queries, performance optimization
- **Implementation**: Virtual and materialized views for different use cases
- **Code Example**:
```sql
-- Regular view for data abstraction
CREATE VIEW customer_orders_view AS
SELECT 
    c.id as customer_id,
    c.name as customer_name,
    c.email,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as total_spent,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email;

-- Materialized view for performance
CREATE MATERIALIZED VIEW customer_summary_mv AS
SELECT 
    c.id as customer_id,
    c.name as customer_name,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as total_spent,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.email
WITH DATA;

-- Create unique index for refresh capabilities
CREATE UNIQUE INDEX idx_customer_summary_mv_id ON customer_summary_mv(customer_id);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW CONCURRENTLY customer_summary_mv;

-- Recursive view for hierarchical data
CREATE RECURSIVE VIEW employee_hierarchy AS
SELECT 
    id,
    name,
    manager_id,
    0 as level,
    ARRAY[id] as path
FROM employees
WHERE manager_id IS NULL

UNION ALL

SELECT 
    e.id,
    e.name,
    e.manager_id,
    eh.level + 1,
    eh.path || e.id
FROM employees e
JOIN employee_hierarchy eh ON e.manager_id = eh.id
WHERE NOT e.id = ANY(eh.path); -- Prevent cycles
```

- **Pros**: Data abstraction, query simplification, performance
- **Cons**: Storage overhead, refresh complexity

## NoSQL Data Modeling Patterns

### Pattern 4: Document Database Design

- **When to use**: Flexible schemas, hierarchical data, rapid development
- **Implementation**: MongoDB document structure with embedding and referencing
- **Code Example**:
```javascript
// MongoDB Schema Design

// Embedded pattern for one-to-many relationships
const userSchema = {
  _id: ObjectId,
  username: String,
  email: String,
  profile: {
    firstName: String,
    lastName: String,
    avatar: String,
    preferences: {
      theme: String,
      notifications: Boolean,
      language: String
    }
  },
  addresses: [
    {
      type: String, // 'shipping', 'billing'
      street: String,
      city: String,
      state: String,
      zipCode: String,
      country: String,
      isDefault: Boolean
    }
  ],
  orders: [
    {
      orderId: ObjectId,
      orderDate: Date,
      status: String,
      totalAmount: Number,
      items: [
        {
          productId: ObjectId,
          name: String,
          price: Number,
          quantity: Number
        }
      ]
    }
  ],
  createdAt: Date,
  updatedAt: Date
};

// Reference pattern for large datasets
const orderSchema = {
  _id: ObjectId,
  orderNumber: String,
  customerId: ObjectId, // Reference to user
  shippingAddress: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String
  },
  items: [
    {
      productId: ObjectId, // Reference to product
      quantity: Number,
      price: Number,
      total: Number
    }
  ],
  subtotal: Number,
  tax: Number,
  shipping: Number,
  total: Number,
  status: String,
  paymentMethod: String,
  createdAt: Date,
  updatedAt: Date
};

// Hybrid pattern with some embedding and some references
const productSchema = {
  _id: ObjectId,
  name: String,
  description: String,
  category: {
    _id: ObjectId,
    name: String,
    slug: String
  },
  variants: [
    {
      sku: String,
      size: String,
      color: String,
      price: Number,
      inventory: Number,
      images: [String]
    }
  ],
  reviews: [
    {
      userId: ObjectId,
      rating: Number,
      comment: String,
      createdAt: Date
    }
  ],
  tags: [String],
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
};

// Indexes for performance
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "username": 1 }, { unique: true });
db.orders.createIndex({ "customerId": 1, "createdAt": -1 });
db.orders.createIndex({ "status": 1 });
db.products.createIndex({ "category._id": 1 });
db.products.createIndex({ "tags": 1 });
db.products.createIndex({ "name": "text", "description": "text" });
```

- **Pros**: Schema flexibility, read performance, natural data modeling
- **Cons**: Data duplication, query complexity for joins

### Pattern 5: Key-Value and Wide-Column Design

- **When to use**: High-performance access, time-series data, caching
- **Implementation**: Redis for caching, Cassandra for distributed data
- **Code Example**:
```python
# Redis Data Structures
import redis
import json
from datetime import timedelta

class RedisDataModel:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6379, db=0)
    
    def cache_user_session(self, user_id: str, session_data: dict, ttl: int = 3600):
        """Cache user session with TTL"""
        key = f"session:{user_id}"
        self.redis_client.setex(key, ttl, json.dumps(session_data))
    
    def store_user_profile(self, user_id: str, profile_data: dict):
        """Store user profile as hash"""
        key = f"profile:{user_id}"
        self.redis_client.hset(key, mapping=profile_data)
    
    def track_user_activity(self, user_id: str, activity: str):
        """Track user activities in sorted set"""
        key = f"activity:{user_id}"
        timestamp = int(time.time())
        self.redis_client.zadd(key, {activity: timestamp})
        # Keep only last 100 activities
        self.redis_client.zremrangebyrank(key, 0, -101)
    
    def implement_rate_limiting(self, user_id: str, limit: int = 100, window: int = 3600):
        """Implement rate limiting with sliding window"""
        key = f"rate_limit:{user_id}"
        current_time = int(time.time())
        
        # Remove old entries
        self.redis_client.zremrangebyscore(key, 0, current_time - window)
        
        # Add current request
        self.redis_client.zadd(key, {str(current_time): current_time})
        
        # Check limit
        current_count = self.redis_client.zcard(key)
        return current_count <= limit

# Cassandra Table Design
class CassandraDataModel:
    def create_tables(self):
        """Create optimized tables for different query patterns"""
        
        # User table optimized by user_id
        users_table = """
        CREATE TABLE users (
            user_id UUID PRIMARY KEY,
            username TEXT,
            email TEXT,
            created_at TIMESTAMP
        );
        """
        
        # Orders by customer query pattern
        orders_by_customer = """
        CREATE TABLE orders_by_customer (
            customer_id UUID,
            order_id TIMEUUID,
            order_date TIMESTAMP,
            status TEXT,
            total_amount DECIMAL,
            PRIMARY KEY ((customer_id), order_date, order_id)
        ) WITH CLUSTERING ORDER BY (order_date DESC, order_id DESC);
        """
        
        # Orders by date query pattern
        orders_by_date = """
        CREATE TABLE orders_by_date (
            order_date DATE,
            order_id TIMEUUID,
            customer_id UUID,
            status TEXT,
            total_amount DECIMAL,
            PRIMARY KEY ((order_date), order_id)
        ) WITH CLUSTERING ORDER BY (order_id DESC);
        """
        
        # Product catalog with materialized view
        products = """
        CREATE TABLE products (
            product_id UUID PRIMARY KEY,
            name TEXT,
            category TEXT,
            price DECIMAL,
            inventory INT,
            created_at TIMESTAMP
        );
        """
        
        products_by_category = """
        CREATE MATERIALIZED VIEW products_by_category AS
        SELECT * FROM products
        WHERE category IS NOT NULL
        PRIMARY KEY ((category), product_id);
        """
        
        return [users_table, orders_by_customer, orders_by_date, products, products_by_category]
```

- **Pros**: High performance, scalability, low latency
- **Cons**: Limited query capabilities, eventual consistency

## Performance Optimization Patterns

### Pattern 6: Query Optimization

- **When to use**: Slow queries, performance bottlenecks
- **Implementation**: Query analysis, execution plan optimization
- **Code Example**:
```sql
-- Analyze query performance
EXPLAIN ANALYZE 
SELECT o.id, o.order_date, c.name, c.email
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.order_date >= '2023-01-01'
  AND o.status = 'completed'
ORDER BY o.order_date DESC
LIMIT 100;

-- Optimized query with proper indexing
CREATE INDEX idx_orders_status_date ON orders(status, order_date DESC);
CREATE INDEX idx_customers_id ON customers(id);

-- Use CTEs for complex queries
WITH customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) as order_count,
        SUM(total_amount) as total_spent
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '1 year'
    GROUP BY customer_id
),
high_value_customers AS (
    SELECT customer_id
    FROM customer_stats
    WHERE total_spent > 1000
)
SELECT 
    c.id,
    c.name,
    c.email,
    cs.order_count,
    cs.total_spent
FROM customers c
JOIN customer_stats cs ON c.id = cs.customer_id
WHERE c.id IN (SELECT customer_id FROM high_value_customers)
ORDER BY cs.total_spent DESC;

-- Window functions for analytics
SELECT 
    id,
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as order_rank,
    LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as prev_order_amount,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
FROM orders
WHERE order_date >= '2023-01-01';

-- Optimized pagination
-- Bad: OFFSET becomes slow for large offsets
SELECT * FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

-- Good: Keyset pagination
SELECT * FROM orders 
WHERE created_at < '2023-01-15 10:30:00'
ORDER BY created_at DESC 
LIMIT 20;

-- Batch processing with cursor
DECLARE order_cursor CURSOR FOR
SELECT id, customer_id, total_amount
FROM orders
WHERE status = 'pending'
FOR UPDATE;

LOOP
    FETCH order_cursor INTO order_id, customer_id, amount;
    EXIT WHEN NOT FOUND;
    
    -- Process order
    UPDATE orders SET status = 'processing' WHERE id = order_id;
END LOOP;

CLOSE order_cursor;
```

- **Pros**: Improved query performance, reduced resource usage
- **Cons**: Complexity, maintenance overhead

### Pattern 7: Connection Pooling and Caching

- **When to use**: High-traffic applications, database load reduction
- **Implementation**: Connection pools, query result caching
- **Code Example**:
```python
# PostgreSQL Connection Pooling
import psycopg2
from psycopg2 import pool
import redis
import json
from functools import wraps

class DatabaseManager:
    def __init__(self, min_conn=1, max_conn=20, redis_host='localhost'):
        # PostgreSQL connection pool
        self.connection_pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=min_conn,
            maxconn=max_conn,
            host='localhost',
            database='myapp',
            user='app_user',
            password='password'
        )
        
        # Redis client for caching
        self.redis_client = redis.Redis(host=redis_host, port=6379, db=0)
    
    def get_connection(self):
        return self.connection_pool.getconn()
    
    def release_connection(self, conn):
        self.connection_pool.putconn(conn)
    
    def cache_result(self, key: str, data, ttl: int = 300):
        """Cache query result"""
        self.redis_client.setex(key, ttl, json.dumps(data))
    
    def get_cached_result(self, key: str):
        """Get cached result"""
        cached = self.redis_client.get(key)
        if cached:
            return json.loads(cached)
        return None
    
    def query_with_cache(self, query: str, params: tuple = None, cache_key: str = None, ttl: int = 300):
        """Execute query with caching"""
        if cache_key:
            cached_result = self.get_cached_result(cache_key)
            if cached_result:
                return cached_result
        
        conn = self.get_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                result = cursor.fetchall()
                
                if cache_key:
                    self.cache_result(cache_key, result, ttl)
                
                return result
        finally:
            self.release_connection(conn)

# Decorator for method caching
def cache_method(ttl: int = 300, key_prefix: str = ""):
    def decorator(func):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            # Generate cache key
            cache_key = f"{key_prefix}:{func.__name__}:{hash(str(args) + str(kwargs))}"
            
            # Try to get from cache
            cached = self.redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            
            # Execute function
            result = func(self, *args, **kwargs)
            
            # Cache result
            self.redis_client.setex(cache_key, ttl, json.dumps(result))
            
            return result
        return wrapper
    return decorator

class UserService:
    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager
    
    @cache_method(ttl=600, key_prefix="user")
    def get_user_by_id(self, user_id: int):
        query = "SELECT id, name, email, created_at FROM users WHERE id = %s"
        return self.db.query_with_cache(query, (user_id,))
    
    @cache_method(ttl=300, key_prefix="user_orders")
    def get_user_orders(self, user_id: int, limit: int = 10):
        query = """
        SELECT id, order_date, total_amount, status 
        FROM orders 
        WHERE customer_id = %s 
        ORDER BY order_date DESC 
        LIMIT %s
        """
        return self.db.query_with_cache(query, (user_id, limit))
    
    def invalidate_user_cache(self, user_id: int):
        """Invalidate all user-related cache"""
        pattern = f"user:*:{user_id}:*"
        keys = self.db.redis_client.keys(pattern)
        if keys:
            self.db.redis_client.delete(*keys)
```

- **Pros**: Reduced database load, improved response times
- **Cons**: Cache invalidation complexity, memory usage

## Database Migration Patterns

### Pattern 8: Schema Evolution

- **When to use**: Database schema changes, version management
- **Implementation**: Version-controlled migrations with rollback capability
- **Code Example**:
```python
# Database Migration Framework
import os
import hashlib
from abc import ABC, abstractmethod
from typing import List, Dict, Any

class Migration(ABC):
    def __init__(self, version: str, description: str):
        self.version = version
        self.description = description
        self.checksum = self._calculate_checksum()
    
    def _calculate_checksum(self) -> str:
        """Calculate migration checksum for integrity"""
        content = f"{self.version}:{self.description}:{self.up_sql if hasattr(self, 'up_sql') else ''}"
        return hashlib.md5(content.encode()).hexdigest()
    
    @abstractmethod
    def up(self, conn):
        """Apply migration"""
        pass
    
    @abstractmethod
    def down(self, conn):
        """Rollback migration"""
        pass

class CreateUsersTable(Migration):
    def __init__(self):
        super().__init__("001", "Create users table")
        self.up_sql = """
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE INDEX idx_users_username ON users(username);
        CREATE INDEX idx_users_email ON users(email);
        """
        
        self.down_sql = "DROP TABLE users;"
    
    def up(self, conn):
        with conn.cursor() as cursor:
            cursor.execute(self.up_sql)
            conn.commit()
    
    def down(self, conn):
        with conn.cursor() as cursor:
            cursor.execute(self.down_sql)
            conn.commit()

class AddUserProfile(Migration):
    def __init__(self):
        super().__init__("002", "Add user profile")
        self.up_sql = """
        CREATE TABLE user_profiles (
            user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            first_name VARCHAR(50),
            last_name VARCHAR(50),
            phone VARCHAR(20),
            avatar_url VARCHAR(500),
            bio TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE INDEX idx_user_profiles_name ON user_profiles(first_name, last_name);
        """
        
        self.down_sql = "DROP TABLE user_profiles;"
    
    def up(self, conn):
        with conn.cursor() as cursor:
            cursor.execute(self.up_sql)
            conn.commit()
    
    def down(self, conn):
        with conn.cursor() as cursor:
            cursor.execute(self.down_sql)
            conn.commit()

class MigrationManager:
    def __init__(self, db_connection):
        self.conn = db_connection
        self.migrations: List[Migration] = []
        self._create_migration_table()
    
    def _create_migration_table(self):
        """Create migration tracking table"""
        with self.conn.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS schema_migrations (
                    version VARCHAR(50) PRIMARY KEY,
                    description TEXT,
                    checksum VARCHAR(32),
                    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            self.conn.commit()
    
    def register_migration(self, migration: Migration):
        """Register a migration"""
        self.migrations.append(migration)
    
    def get_applied_migrations(self) -> Dict[str, Dict[str, Any]]:
        """Get list of applied migrations"""
        with self.conn.cursor() as cursor:
            cursor.execute("SELECT version, description, checksum, applied_at FROM schema_migrations ORDER BY version")
            return {
                row[0]: {
                    'description': row[1],
                    'checksum': row[2],
                    'applied_at': row[3]
                }
                for row in cursor.fetchall()
            }
    
    def get_pending_migrations(self) -> List[Migration]:
        """Get list of pending migrations"""
        applied = self.get_applied_migrations()
        return [m for m in self.migrations if m.version not in applied]
    
    def migrate_up(self, target_version: str = None):
        """Apply pending migrations"""
        pending = self.get_pending_migrations()
        
        if target_version:
            pending = [m for m in pending if m.version <= target_version]
        
        for migration in pending:
            print(f"Applying migration {migration.version}: {migration.description}")
            
            try:
                migration.up(self.conn)
                
                # Record migration
                with self.conn.cursor() as cursor:
                    cursor.execute(
                        "INSERT INTO schema_migrations (version, description, checksum) VALUES (%s, %s, %s)",
                        (migration.version, migration.description, migration.checksum)
                    )
                    self.conn.commit()
                
                print(f"Migration {migration.version} applied successfully")
            except Exception as e:
                print(f"Migration {migration.version} failed: {e}")
                self.conn.rollback()
                raise
    
    def migrate_down(self, target_version: str):
        """Rollback to target version"""
        applied = self.get_applied_migrations()
        
        # Get migrations to rollback
        to_rollback = [
            m for m in self.migrations 
            if m.version in applied and m.version > target_version
        ]
        
        # Sort in reverse order for rollback
        to_rollback.sort(key=lambda x: x.version, reverse=True)
        
        for migration in to_rollback:
            print(f"Rolling back migration {migration.version}: {migration.description}")
            
            try:
                migration.down(self.conn)
                
                # Remove migration record
                with self.conn.cursor() as cursor:
                    cursor.execute("DELETE FROM schema_migrations WHERE version = %s", (migration.version,))
                    self.conn.commit()
                
                print(f"Migration {migration.version} rolled back successfully")
            except Exception as e:
                print(f"Rollback of migration {migration.version} failed: {e}")
                self.conn.rollback()
                raise
    
    def verify_integrity(self) -> bool:
        """Verify migration integrity"""
        applied = self.get_applied_migrations()
        
        for migration in self.migrations:
            if migration.version in applied:
                if applied[migration.version]['checksum'] != migration.checksum:
                    print(f"Migration {migration.version} checksum mismatch!")
                    return False
        
        return True
```

- **Pros**: Version control, rollback capability, team collaboration
- **Cons**: Migration complexity, downtime management

## Multi-Tenant Architecture

### Pattern 9: Database per Tenant vs Shared Database

- **When to use**: SaaS applications, multi-tenant systems
- **Implementation**: Different strategies for tenant data isolation
- **Code Example**:
```python
# Multi-tenant Database Manager
import psycopg2
from contextlib import contextmanager

class MultiTenantDBManager:
    def __init__(self, strategy='shared'):
        self.strategy = strategy
        self.connections = {}
    
    @contextmanager
    def get_tenant_connection(self, tenant_id: str):
        """Get database connection for tenant"""
        if self.strategy == 'database_per_tenant':
            conn = self._get_tenant_database(tenant_id)
        elif self.strategy == 'schema_per_tenant':
            conn = self._get_tenant_schema(tenant_id)
        else:  # shared database
            conn = self._get_shared_connection(tenant_id)
        
        try:
            yield conn
        finally:
            conn.close()
    
    def _get_tenant_database(self, tenant_id: str):
        """Database per tenant strategy"""
        if tenant_id not in self.connections:
            db_name = f"tenant_{tenant_id}"
            self.connections[tenant_id] = psycopg2.connect(
                host='localhost',
                database=db_name,
                user='app_user',
                password='password'
            )
        return self.connections[tenant_id]
    
    def _get_tenant_schema(self, tenant_id: str):
        """Schema per tenant strategy"""
        conn = psycopg2.connect(
            host='localhost',
            database='multi_tenant_db',
            user='app_user',
            password='password'
        )
        
        # Set search path to tenant schema
        with conn.cursor() as cursor:
            cursor.execute(f"SET search_path TO tenant_{tenant_id}, public")
            conn.commit()
        
        return conn
    
    def _get_shared_connection(self, tenant_id: str):
        """Shared database with tenant_id column"""
        conn = psycopg2.connect(
            host='localhost',
            database='shared_db',
            user='app_user',
            password='password'
        )
        return conn

# Row Level Security (RLS) implementation
class RLSSetup:
    @staticmethod
    def setup_rls_for_tenant(conn):
        """Setup Row Level Security for multi-tenancy"""
        with conn.cursor() as cursor:
            # Enable RLS on tables
            cursor.execute("ALTER TABLE users ENABLE ROW LEVEL SECURITY;")
            cursor.execute("ALTER TABLE orders ENABLE ROW LEVEL SECURITY;")
            
            # Create policies
            cursor.execute("""
                CREATE POLICY tenant_isolation_users ON users
                FOR ALL TO app_user
                USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
            """)
            
            cursor.execute("""
                CREATE POLICY tenant_isolation_orders ON orders
                FOR ALL TO app_user
                USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
            """)
            
            conn.commit()
    
    @staticmethod
    def set_tenant_context(conn, tenant_id: str):
        """Set tenant context for current session"""
        with conn.cursor() as cursor:
            cursor.execute(f"SET app.current_tenant_id = '{tenant_id}';")
            conn.commit()

# Usage examples
tenant_manager = MultiTenantDBManager(strategy='schema_per_tenant')

# Query tenant data
def get_tenant_users(tenant_id: str):
    with tenant_manager.get_tenant_connection(tenant_id) as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id, name, email FROM users")
            return cursor.fetchall()

# Create new tenant
def create_new_tenant(tenant_id: str, tenant_name: str):
    if tenant_manager.strategy == 'database_per_tenant':
        # Create new database
        conn = psycopg2.connect(
            host='localhost',
            database='postgres',
            user='admin_user',
            password='admin_password'
        )
        
        with conn.cursor() as cursor:
            cursor.execute(f"CREATE DATABASE tenant_{tenant_id};")
            conn.commit()
        
        conn.close()
        
        # Run migrations on new database
        new_db_conn = psycopg2.connect(
            host='localhost',
            database=f"tenant_{tenant_id}",
            user='app_user',
            password='password'
        )
        
        # Run migration scripts...
        new_db_conn.close()
    
    elif tenant_manager.strategy == 'schema_per_tenant':
        # Create new schema
        conn = psycopg2.connect(
            host='localhost',
            database='multi_tenant_db',
            user='app_user',
            password='password'
        )
        
        with conn.cursor() as cursor:
            cursor.execute(f"CREATE SCHEMA tenant_{tenant_id};")
            
            # Set search path and create tables
            cursor.execute(f"SET search_path TO tenant_{tenant_id}, public;")
            # Run table creation scripts...
            
            conn.commit()
        conn.close()
```

- **Pros**: Data isolation, scalability, security
- **Cons**: Complexity, resource overhead

## Best Practices

### Database Design
1. **Normalization First**: Normalize data, then denormalize for performance
2. **Index Strategy**: Index based on query patterns, not all columns
3. **Data Types**: Use appropriate data types for storage efficiency
4. **Constraints**: Use constraints for data integrity
5. **Naming Conventions**: Consistent naming for tables and columns

### Performance Optimization
1. **Query Analysis**: Regularly analyze slow queries
2. **Connection Pooling**: Use connection pools for high-traffic apps
3. **Caching Strategy**: Implement multi-level caching
4. **Partitioning**: Partition large tables for better performance
5. **Monitoring**: Monitor database performance metrics

### Security
1. **Least Privilege**: Grant minimum necessary permissions
2. **Encryption**: Encrypt sensitive data at rest and in transit
3. **Audit Logging**: Log all database access and changes
4. **Parameterized Queries**: Prevent SQL injection
5. **Regular Updates**: Keep database software updated

## Common Pitfalls

### Design Pitfalls
- **Over-normalization**: Excessive joins hurting performance
- **Under-indexing**: Missing indexes causing slow queries
- **Data Duplication**: Inconsistent data across tables
- **Poor Naming**: Inconsistent or unclear naming conventions

### Performance Pitfalls
- **N+1 Query Problem**: Multiple queries instead of joins
- **Missing Indexes**: Full table scans on large tables
- **Large Transactions**: Long-running transactions blocking others
- **Inefficient Queries**: Complex queries without optimization

## Tools & Resources

### Relational Databases
- **PostgreSQL**: Advanced features, extensibility
- **MySQL**: Popular, easy to use
- **SQL Server**: Microsoft ecosystem integration
- **Oracle**: Enterprise features, high performance

### NoSQL Databases
- **MongoDB**: Document database, flexible schema
- **Cassandra**: Distributed, high availability
- **Redis**: In-memory, high performance
- **DynamoDB**: Managed NoSQL service

### Database Tools
- **pgAdmin**: PostgreSQL administration
- **DBeaver**: Universal database tool
- **DataGrip**: JetBrains database IDE
- **MongoDB Compass**: MongoDB GUI

### Monitoring Tools
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **New Relic**: APM and monitoring
- **Datadog**: Infrastructure monitoring

This guide provides comprehensive database design patterns and should be adapted to specific application requirements and constraints.
