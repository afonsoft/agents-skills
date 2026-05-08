# Microservices Architecture Patterns

This document contains patterns, best practices, and implementation guides for microservices architecture and distributed systems.

## Overview

Comprehensive guide for designing, implementing, and maintaining microservices architectures with focus on scalability, resilience, and maintainability.

## Quick Reference

| Pattern | Problem | Solution | Complexity |
|---------|---------|----------|------------|
| **API Gateway** | Service discovery, routing | Single entry point | Medium |
| **Circuit Breaker** | Cascading failures | Fault tolerance | Medium |
| **Event Sourcing** | Data consistency | Immutable event log | High |
| **CQRS** | Read/write optimization | Separate models | High |
| **Saga Pattern** | Distributed transactions | Compensation | High |

## Core Microservices Patterns

### Pattern 1: API Gateway

- **When to use**: Multiple microservices, cross-cutting concerns
- **Implementation**: Single entry point with routing, authentication, rate limiting
- **Code Example**:
```typescript
// API Gateway with Express.js
import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';

const app = express();

// Authentication middleware
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization;
  if (!validateToken(token)) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
};

// Service routes
app.use('/api/users', authMiddleware, createProxyMiddleware({
  target: 'http://user-service:3001',
  changeOrigin: true
}));

app.use('/api/orders', authMiddleware, createProxyMiddleware({
  target: 'http://order-service:3002',
  changeOrigin: true
}));

app.use('/api/products', createProxyMiddleware({
  target: 'http://product-service:3003',
  changeOrigin: true
}));

app.listen(3000, () => {
  console.log('API Gateway running on port 3000');
});
```

- **Pros**: Centralized management, security, monitoring
- **Cons**: Single point of failure, complexity, performance bottleneck

### Pattern 2: Service Discovery

- **When to use**: Dynamic service instances, containerized environments
- **Implementation**: Service registry with health checking
- **Code Example**:
```python
# Service Registry with Consul
import consul
import requests
import time
import socket

class ServiceRegistry:
    def __init__(self, consul_host='localhost', consul_port=8500):
        self.consul = consul.Consul(host=consul_host, port=consul_port)
        self.hostname = socket.gethostname()
        self.ip = socket.gethostbyname(self.hostname)
    
    def register_service(self, service_name, port, health_check_url):
        """Register service with Consul"""
        service_id = f"{service_name}-{self.hostname}-{port}"
        
        self.consul.agent.service.register(
            name=service_name,
            service_id=service_id,
            address=self.ip,
            port=port,
            check=consul.Check.http(
                url=f"http://{self.ip}:{port}{health_check_url}",
                interval="10s",
                timeout="3s"
            )
        )
        return service_id
    
    def discover_service(self, service_name):
        """Discover service instances"""
        services = self.consul.health.service(service_name, passing=True)[1]
        if not services:
            raise Exception(f"No healthy instances of {service_name} found")
        
        # Simple round-robin selection
        service = services[0]
        return f"http://{service['Service']['Address']}:{service['Service']['Port']}"
    
    def deregister_service(self, service_id):
        """Deregister service"""
        self.consul.agent.service.deregister(service_id)

# Usage in a microservice
registry = ServiceRegistry()
service_id = registry.register_service('user-service', 3001, '/health')

try:
    # Service logic here
    app.run(port=3001)
finally:
    registry.deregister_service(service_id)
```

- **Pros**: Dynamic scaling, resilience, load balancing
- **Cons**: Additional infrastructure, consistency challenges

### Pattern 3: Circuit Breaker

- **When to use**: External service calls, fault tolerance
- **Implementation**: Failure detection and fallback mechanisms
- **Code Example**:
```python
import time
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60, expected_exception=Exception):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.expected_exception = expected_exception
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
    
    def __call__(self, func):
        def wrapper(*args, **kwargs):
            if self.state == CircuitState.OPEN:
                if time.time() - self.last_failure_time > self.timeout:
                    self.state = CircuitState.HALF_OPEN
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            try:
                result = func(*args, **kwargs)
                if self.state == CircuitState.HALF_OPEN:
                    self.state = CircuitState.CLOSED
                    self.failure_count = 0
                return result
            except self.expected_exception as e:
                self.failure_count += 1
                self.last_failure_time = time.time()
                
                if self.failure_count >= self.failure_threshold:
                    self.state = CircuitState.OPEN
                
                raise e
        
        return wrapper

# Usage
@CircuitBreaker(failure_threshold=3, timeout=30)
def call_external_service(url):
    response = requests.get(url)
    response.raise_for_status()
    return response.json()
```

- **Pros**: Fault tolerance, prevents cascading failures
- **Cons**: Added complexity, latency during failures

## Data Management Patterns

### Pattern 4: Database per Service

- **When to use**: Independent data models, different access patterns
- **Implementation**: Each service owns its database
- **Code Example**:
```python
# Database configuration per service
class DatabaseConfig:
    def __init__(self, service_name):
        self.service_name = service_name
        self.config = self.get_service_db_config()
    
    def get_service_db_config(self):
        configs = {
            'user-service': {
                'host': 'user-db',
                'database': 'users',
                'username': 'user_service',
                'password': os.getenv('USER_DB_PASSWORD')
            },
            'order-service': {
                'host': 'order-db',
                'database': 'orders',
                'username': 'order_service',
                'password': os.getenv('ORDER_DB_PASSWORD')
            }
        }
        return configs.get(self.service_name)

# Repository pattern per service
class UserRepository:
    def __init__(self):
        self.db_config = DatabaseConfig('user-service')
        self.connection = self.create_connection()
    
    def create_connection(self):
        return psycopg2.connect(
            host=self.db_config.config['host'],
            database=self.db_config.config['database'],
            user=self.db_config.config['username'],
            password=self.db_config.config['password']
        )
    
    def create_user(self, user_data):
        query = "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id"
        with self.connection.cursor() as cursor:
            cursor.execute(query, (user_data['name'], user_data['email']))
            user_id = cursor.fetchone()[0]
            self.connection.commit()
            return user_id
```

- **Pros**: Data isolation, independent scaling, technology diversity
- **Cons**: Data consistency challenges, operational complexity

### Pattern 5: Event Sourcing

- **When to use**: Audit trails, temporal data, complex business logic
- **Implementation**: Immutable event store with state reconstruction
- **Code Example**:
```python
import json
from datetime import datetime
from typing import List, Dict, Any

class Event:
    def __init__(self, aggregate_id: str, event_type: str, data: Dict[str, Any]):
        self.aggregate_id = aggregate_id
        self.event_type = event_type
        self.data = data
        self.timestamp = datetime.utcnow()
        self.event_id = str(uuid.uuid4())

class EventStore:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def save_events(self, aggregate_id: str, events: List[Event], expected_version: int = None):
        with self.db.cursor() as cursor:
            # Check version for optimistic concurrency
            if expected_version is not None:
                cursor.execute(
                    "SELECT version FROM aggregates WHERE aggregate_id = %s FOR UPDATE",
                    (aggregate_id,)
                )
                result = cursor.fetchone()
                if result and result[0] != expected_version:
                    raise Exception("Concurrency conflict")
            
            # Save events
            for event in events:
                cursor.execute(
                    """INSERT INTO events (event_id, aggregate_id, event_type, data, timestamp)
                       VALUES (%s, %s, %s, %s, %s)""",
                    (event.event_id, event.aggregate_id, event.event_type, 
                     json.dumps(event.data), event.timestamp)
                )
            
            # Update aggregate version
            new_version = expected_version + len(events) if expected_version is not None else len(events)
            cursor.execute(
                """INSERT INTO aggregates (aggregate_id, version)
                   VALUES (%s, %s)
                   ON CONFLICT (aggregate_id) DO UPDATE SET version = %s""",
                (aggregate_id, new_version, new_version)
            )
            
            self.db.commit()
    
    def get_events(self, aggregate_id: str) -> List[Event]:
        cursor = self.db.cursor()
        cursor.execute(
            "SELECT event_id, event_type, data, timestamp FROM events WHERE aggregate_id = %s ORDER BY timestamp",
            (aggregate_id,)
        )
        
        events = []
        for row in cursor.fetchall():
            event = Event(aggregate_id, row[1], json.loads(row[2]))
            event.event_id = row[0]
            event.timestamp = row[3]
            events.append(event)
        
        return events

class AggregateRoot:
    def __init__(self, aggregate_id: str):
        self.aggregate_id = aggregate_id
        self.version = 0
        self.pending_events = []
    
    def apply_event(self, event: Event):
        self.pending_events.append(event)
        self.apply(event)
    
    def apply(self, event: Event):
        # Override in subclasses
        pass
    
    def get_uncommitted_events(self) -> List[Event]:
        return self.pending_events.copy()
    
    def mark_events_as_committed(self):
        self.pending_events.clear()
        self.version += len(self.pending_events)

class User(AggregateRoot):
    def __init__(self, aggregate_id: str, name: str = None, email: str = None):
        super().__init__(aggregate_id)
        self.name = name
        self.email = email
    
    def apply(self, event: Event):
        if event.event_type == "UserCreated":
            self.name = event.data["name"]
            self.email = event.data["email"]
        elif event.event_type == "UserUpdated":
            self.name = event.data.get("name", self.name)
            self.email = event.data.get("email", self.email)
    
    def create_user(self, name: str, email: str):
        event = Event(self.aggregate_id, "UserCreated", {"name": name, "email": email})
        self.apply_event(event)
    
    def update_user(self, name: str = None, email: str = None):
        event = Event(self.aggregate_id, "UserUpdated", {"name": name, "email": email})
        self.apply_event(event)
```

- **Pros**: Complete audit trail, temporal queries, business logic clarity
- **Cons**: Complexity, storage requirements, learning curve

### Pattern 6: CQRS (Command Query Responsibility Segregation)

- **When to use**: Different read/write models, high scalability requirements
- **Implementation**: Separate models for commands and queries
- **Code Example**:
```python
# Command side (write model)
class CreateUserCommand:
    def __init__(self, user_id: str, name: str, email: str):
        self.user_id = user_id
        self.name = name
        self.email = email

class UserCommandHandler:
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
    
    def handle_create_user(self, command: CreateUserCommand):
        user = User(command.user_id)
        user.create_user(command.name, command.email)
        
        # Save events
        self.event_store.save_events(
            command.user_id, 
            user.get_uncommitted_events(),
            expected_version=0
        )
        
        user.mark_events_as_committed()
        
        return command.user_id

# Query side (read model)
class UserReadModel:
    def __init__(self, db_connection):
        self.db = db_connection
        self.create_read_model_table()
    
    def create_read_model_table(self):
        with self.db.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS user_read_model (
                    user_id VARCHAR(255) PRIMARY KEY,
                    name VARCHAR(255),
                    email VARCHAR(255),
                    updated_at TIMESTAMP
                )
            """)
            self.db.commit()
    
    def update_from_event(self, event: Event):
        with self.db.cursor() as cursor:
            if event.event_type == "UserCreated":
                cursor.execute(
                    """INSERT INTO user_read_model (user_id, name, email, updated_at)
                       VALUES (%s, %s, %s, %s)
                       ON CONFLICT (user_id) DO UPDATE SET
                       name = EXCLUDED.name,
                       email = EXCLUDED.email,
                       updated_at = EXCLUDED.updated_at""",
                    (event.aggregate_id, event.data["name"], 
                     event.data["email"], event.timestamp)
                )
            elif event.event_type == "UserUpdated":
                cursor.execute(
                    """UPDATE user_read_model SET
                       name = COALESCE(%s, name),
                       email = COALESCE(%s, email),
                       updated_at = %s
                       WHERE user_id = %s""",
                    (event.data.get("name"), event.data.get("email"),
                     event.timestamp, event.aggregate_id)
                )
            
            self.db.commit()
    
    def get_user(self, user_id: str) -> Dict:
        with self.db.cursor() as cursor:
            cursor.execute(
                "SELECT user_id, name, email FROM user_read_model WHERE user_id = %s",
                (user_id,)
            )
            result = cursor.fetchone()
            if result:
                return {
                    "user_id": result[0],
                    "name": result[1],
                    "email": result[2]
                }
            return None

# Event projector to update read model
class UserEventProjector:
    def __init__(self, event_store: EventStore, read_model: UserReadModel):
        self.event_store = event_store
        self.read_model = read_model
    
    def project_events(self):
        # Get unprojected events
        with self.event_store.db.cursor() as cursor:
            cursor.execute(
                """SELECT event_id, aggregate_id, event_type, data 
                   FROM events WHERE projected = FALSE ORDER BY timestamp"""
            )
            events = cursor.fetchall()
            
            for event_data in events:
                event = Event(event_data[1], event_data[2], json.loads(event_data[3]))
                event.event_id = event_data[0]
                
                # Update read model
                self.read_model.update_from_event(event)
                
                # Mark as projected
                cursor.execute(
                    "UPDATE events SET projected = TRUE WHERE event_id = %s",
                    (event.event_id,)
                )
            
            self.event_store.db.commit()
```

- **Pros**: Optimized read/write models, scalability, flexibility
- **Cons**: Complexity, eventual consistency, development overhead

## Distributed Transaction Patterns

### Pattern 7: Saga Pattern

- **When to use**: Distributed transactions, long-running business processes
- **Implementation**: Sequence of local transactions with compensation
- **Code Example**:
```python
from abc import ABC, abstractmethod
from enum import Enum

class SagaStepStatus(Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    COMPENSATED = "compensated"

class SagaStep(ABC):
    def __init__(self, name: str):
        self.name = name
        self.status = SagaStepStatus.PENDING
    
    @abstractmethod
    def execute(self, context: Dict) -> bool:
        """Execute the step"""
        pass
    
    @abstractmethod
    def compensate(self, context: Dict) -> bool:
        """Compensate the step"""
        pass

class CreateUserStep(SagaStep):
    def __init__(self, user_service):
        super().__init__("CreateUser")
        self.user_service = user_service
    
    def execute(self, context: Dict) -> bool:
        try:
            user_id = self.user_service.create_user(context["user_data"])
            context["user_id"] = user_id
            self.status = SagaStepStatus.COMPLETED
            return True
        except Exception as e:
            self.status = SagaStepStatus.FAILED
            return False
    
    def compensate(self, context: Dict) -> bool:
        try:
            self.user_service.delete_user(context["user_id"])
            self.status = SagaStepStatus.COMPENSATED
            return True
        except Exception:
            return False

class CreateOrderStep(SagaStep):
    def __init__(self, order_service):
        super().__init__("CreateOrder")
        self.order_service = order_service
    
    def execute(self, context: Dict) -> bool:
        try:
            order_data = {
                "user_id": context["user_id"],
                "items": context["order_items"]
            }
            order_id = self.order_service.create_order(order_data)
            context["order_id"] = order_id
            self.status = SagaStepStatus.COMPLETED
            return True
        except Exception as e:
            self.status = SagaStepStatus.FAILED
            return False
    
    def compensate(self, context: Dict) -> bool:
        try:
            self.order_service.cancel_order(context["order_id"])
            self.status = SagaStepStatus.COMPENSATED
            return True
        except Exception:
            return False

class ProcessPaymentStep(SagaStep):
    def __init__(self, payment_service):
        super().__init__("ProcessPayment")
        self.payment_service = payment_service
    
    def execute(self, context: Dict) -> bool:
        try:
            payment_data = {
                "order_id": context["order_id"],
                "amount": context["amount"],
                "payment_method": context["payment_method"]
            }
            payment_id = self.payment_service.process_payment(payment_data)
            context["payment_id"] = payment_id
            self.status = SagaStepStatus.COMPLETED
            return True
        except Exception as e:
            self.status = SagaStepStatus.FAILED
            return False
    
    def compensate(self, context: Dict) -> bool:
        try:
            self.payment_service.refund_payment(context["payment_id"])
            self.status = SagaStepStatus.COMPENSATED
            return True
        except Exception:
            return False

class Saga:
    def __init__(self, saga_id: str):
        self.saga_id = saga_id
        self.steps = []
        self.context = {}
        self.current_step_index = 0
    
    def add_step(self, step: SagaStep):
        self.steps.append(step)
    
    def execute(self, initial_context: Dict) -> bool:
        self.context = initial_context
        
        # Execute steps in order
        for i, step in enumerate(self.steps):
            self.current_step_index = i
            
            if not step.execute(self.context):
                # Step failed, start compensation
                self.compensate()
                return False
        
        return True
    
    def compensate(self):
        # Compensate in reverse order
        for i in range(self.current_step_index, -1, -1):
            step = self.steps[i]
            if step.status == SagaStepStatus.COMPLETED:
                step.compensate(self.context)

# Usage
def create_order_saga(user_data, order_items, amount, payment_method):
    saga = Saga(f"order-{uuid.uuid4()}")
    
    # Add steps
    saga.add_step(CreateUserStep(user_service))
    saga.add_step(CreateOrderStep(order_service))
    saga.add_step(ProcessPaymentStep(payment_service))
    
    # Set initial context
    context = {
        "user_data": user_data,
        "order_items": order_items,
        "amount": amount,
        "payment_method": payment_method
    }
    
    return saga.execute(context)
```

- **Pros**: Distributed transaction management, fault tolerance
- **Cons**: Complexity, compensation logic challenges

## Communication Patterns

### Pattern 8: Event-Driven Architecture

- **When to use**: Loose coupling, real-time updates, scalability
- **Implementation**: Message brokers, event buses, pub/sub
- **Code Example**:
```python
import asyncio
import json
from typing import Dict, Callable, List

class EventBus:
    def __init__(self):
        self.handlers: Dict[str, List[Callable]] = {}
    
    def subscribe(self, event_type: str, handler: Callable):
        if event_type not in self.handlers:
            self.handlers[event_type] = []
        self.handlers[event_type].append(handler)
    
    def publish(self, event: Dict):
        event_type = event["type"]
        if event_type in self.handlers:
            for handler in self.handlers[event_type]:
                try:
                    # In production, use message queue for async processing
                    asyncio.create_task(self._handle_event(handler, event))
                except Exception as e:
                    print(f"Error in event handler: {e}")
    
    async def _handle_event(self, handler: Callable, event: Dict):
        await handler(event)

# Event handlers
class UserEventHandler:
    def __init__(self, notification_service, analytics_service):
        self.notification_service = notification_service
        self.analytics_service = analytics_service
    
    async def handle_user_created(self, event: Dict):
        # Send welcome email
        await self.notification_service.send_welcome_email(event["data"]["email"])
        
        # Track analytics
        await self.analytics_service.track_user_registration(event["data"])
    
    async def handle_user_updated(self, event: Dict):
        # Update analytics
        await self.analytics_service.track_user_update(event["data"])

class OrderEventHandler:
    def __init__(self, inventory_service, notification_service):
        self.inventory_service = inventory_service
        self.notification_service = notification_service
    
    async def handle_order_created(self, event: Dict):
        # Update inventory
        await self.inventory_service.reserve_items(event["data"]["items"])
        
        # Send confirmation
        await self.notification_service.send_order_confirmation(event["data"])

# Setup event bus
event_bus = EventBus()

# Register handlers
user_handler = UserEventHandler(notification_service, analytics_service)
order_handler = OrderEventHandler(inventory_service, notification_service)

event_bus.subscribe("UserCreated", user_handler.handle_user_created)
event_bus.subscribe("UserUpdated", user_handler.handle_user_updated)
event_bus.subscribe("OrderCreated", order_handler.handle_order_created)

# Publishing events
def create_user(user_data):
    # Business logic to create user
    user_id = user_service.create_user(user_data)
    
    # Publish event
    event = {
        "type": "UserCreated",
        "data": {
            "user_id": user_id,
            "name": user_data["name"],
            "email": user_data["email"]
        },
        "timestamp": datetime.utcnow().isoformat()
    }
    
    event_bus.publish(event)
    return user_id
```

- **Pros**: Loose coupling, scalability, real-time processing
- **Cons**: Complexity, debugging challenges, eventual consistency

## Deployment & Operations

### Container Orchestration
```yaml
# docker-compose.yml for microservices
version: '3.8'

services:
  api-gateway:
    build: ./api-gateway
    ports:
      - "3000:3000"
    environment:
      - USER_SERVICE_URL=http://user-service:3001
      - ORDER_SERVICE_URL=http://order-service:3002
    depends_on:
      - user-service
      - order-service

  user-service:
    build: ./user-service
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=postgresql://user:password@user-db:5432/users
    depends_on:
      - user-db

  order-service:
    build: ./order-service
    ports:
      - "3002:3002"
    environment:
      - DATABASE_URL=postgresql://order:password@order-db:5432/orders
    depends_on:
      - order-db

  user-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=users
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - user_db_data:/var/lib/postgresql/data

  order-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=orders
      - POSTGRES_USER=order
      - POSTGRES_PASSWORD=password
    volumes:
      - order_db_data:/var/lib/postgresql/data

volumes:
  user_db_data:
  order_db_data:
```

### Monitoring & Observability
```python
# Metrics collection for microservices
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time
import functools

# Define metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Active database connections')

def monitor_requests(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        
        try:
            result = func(*args, **kwargs)
            REQUEST_COUNT.labels(method='GET', endpoint=func.__name__, status='200').inc()
            return result
        except Exception as e:
            REQUEST_COUNT.labels(method='GET', endpoint=func.__name__, status='500').inc()
            raise
        finally:
            REQUEST_DURATION.observe(time.time() - start_time)
    
    return wrapper

# Usage in microservice
@monitor_requests
def get_user(user_id):
    # Business logic
    return user_service.get_user(user_id)

# Start metrics server
start_http_server(8000)
```

## Best Practices

### Design Principles
1. **Single Responsibility**: Each service has one business capability
2. **Bounded Context**: Clear service boundaries and data ownership
3. **API Versioning**: Maintain backward compatibility
4. **Configuration Externalization**: Environment-specific configurations
5. **Graceful Degradation**: Handle service failures gracefully

### Security Considerations
- Implement OAuth 2.0/JWT for authentication
- Use API keys for service-to-service communication
- Encrypt sensitive data in transit and at rest
- Implement rate limiting and throttling
- Regular security audits and penetration testing

### Performance Optimization
- Implement caching strategies (Redis, Memcached)
- Use connection pooling for databases
- Optimize database queries and indexing
- Implement CDN for static assets
- Monitor and optimize resource utilization

## Common Pitfalls

### Architecture Pitfalls
- **Distributed Monolith**: Services that are too tightly coupled
- **Over-engineering**: Unnecessary complexity for simple problems
- **Inconsistent Data**: Lack of proper data synchronization
- **Service Sprawl**: Too many fine-grained services

### Operational Pitfalls
- **Insufficient Monitoring**: Lack of observability
- **Poor Error Handling**: Inadequate failure management
- **Deployment Complexity**: Difficult deployment processes
- **Resource Management**: Inefficient resource utilization

## Tools & Resources

### Service Mesh
- **Istio**: Feature-rich service mesh
- **Linkerd**: Lightweight service mesh
- **Consul Connect**: Built-in service mesh

### API Gateway
- **Kong**: Feature-rich API gateway
- **Tyk**: Open source API gateway
- **Zuul**: Netflix API gateway

### Message Brokers
- **Apache Kafka**: High-throughput streaming
- **RabbitMQ**: Feature-rich message broker
- **Apache Pulsar**: Cloud-native messaging

### Monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **Jaeger**: Distributed tracing
- **ELK Stack**: Log aggregation

This guide provides comprehensive patterns for microservices architecture and should be adapted to specific organizational requirements and constraints.
