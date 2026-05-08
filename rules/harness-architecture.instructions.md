---
applyTo: '**/*.cs,**/*.csproj,**/Program.cs,**/*.razor,**/*.ts,**/*.tsx,**/*.js,**/*.jsx'
description: 'Rigid architecture rules following OpenAI harness engineering principles - layered domain architecture with forward-only dependencies'
---

# Harness Architecture Rules

## Layered Domain Architecture

### Required Layer Structure

For framework-specific code (ABP, Angular, .NET applications), each business domain MUST follow this fixed layer structure:

```
Within each business domain:
Types → Config → Repo → Service → Runtime → UI
```

### Dependency Rules

**FORWARD-ONLY DEPENDENCIES:**
- Code can ONLY depend on layers to its LEFT in the sequence
- Types depends on nothing (or external types only)
- Config depends on Types
- Repo depends on Config and Types
- Service depends on Repo, Config, and Types
- Runtime depends on Service, Repo, Config, and Types
- UI depends on Runtime, Service, Repo, Config, and Types

**PROHIBITED DEPENDENCIES:**
- No backward dependencies (e.g., UI cannot depend on Service directly if Runtime exists)
- No skipping layers (e.g., Service cannot depend directly on Types without going through Config)
- No circular dependencies between any layers
- No dependencies between sibling layers in different domains

### Cross-Cutting Concerns

**SINGLE ENTRY POINT:**
- All cross-cutting concerns (authentication, connectors, telemetry, feature flags, logging) MUST enter via **Providers** interface
- Providers is the ONLY explicit interface for cross-cutting concerns
- No direct imports of cross-cutting modules outside of Providers

**PROHIBITED:**
- Direct imports of auth modules in business logic
- Direct imports of telemetry modules in service layer
- Direct imports of feature flag modules in UI components
- Any cross-cutting concern injection outside of Providers

## Architecture Enforcement

### Mechanical Validation

Implement linters to validate:
- Import statements follow layer dependencies
- No backward dependencies detected
- No circular dependencies between layers
- Cross-cutting concerns only imported via Providers
- File placement matches layer structure

### Structural Tests

Create structural tests to verify:
- Each domain has all required layers
- Dependency graph is acyclic
- No violations of forward-only rule
- Providers interface is used for all cross-cutting concerns

## File Organization

### Domain Structure

```
src/
├── domains/
│   ├── user-management/
│   │   ├── Types/
│   │   ├── Config/
│   │   ├── Repo/
│   │   ├── Service/
│   │   ├── Runtime/
│   │   ├── UI/
│   │   └── Providers/
│   └── product-catalog/
│       ├── Types/
│       ├── Config/
│       ├── Repo/
│       ├── Service/
│       ├── Runtime/
│       ├── UI/
│       └── Providers/
└── shared/
    └── Providers/  # Shared providers for cross-domain concerns
```

### Layer Responsibilities

**Types:**
- Data structures, interfaces, DTOs
- No business logic
- No dependencies on other layers

**Config:**
- Configuration objects, settings
- Validation rules for config
- Depends only on Types

**Repo:**
- Data access, repository patterns
- Database operations
- Depends on Config and Types

**Service:**
- Business logic, domain services
- Orchestrates repo operations
- Depends on Repo, Config, and Types

**Runtime:**
- Runtime services, execution contexts
- Background workers, schedulers
- Depends on Service, Repo, Config, and Types

**UI:**
- User interface components
- View models, controllers
- Depends on Runtime, Service, Repo, Config, and Types

**Providers:**
- Cross-cutting concern implementations
- Auth, telemetry, logging, feature flags
- Injected into layers as needed

## Code Examples

### Correct Dependency

```csharp
// Service layer correctly depending on Repo
public class UserService {
    private readonly IUserRepository _repo;
    private readonly IUserConfig _config;
    
    public UserService(IUserRepository repo, IUserConfig config) {
        _repo = repo;
        _config = config;
    }
}
```

### Incorrect Dependency (Backward)

```csharp
// VIOLATION: UI depending directly on Service (should go through Runtime)
public class UserController {
    private readonly IUserService _service;  // WRONG - skip Runtime layer
    
    public UserController(IUserService service) {
        _service = service;
    }
}
```

### Correct Cross-Cutting Concern

```csharp
// Correct: Using Providers for authentication
public class UserService {
    private readonly IAuthProvider _authProvider;  // From Providers
    
    public UserService(IAuthProvider authProvider) {
        _authProvider = authProvider;
    }
}
```

### Incorrect Cross-Cutting Concern

```csharp
// VIOLATION: Direct import of auth module
using SomeAuthLibrary;  // WRONG - should use Providers interface

public class UserService {
    private readonly AuthService _auth;  // WRONG - direct dependency
}
```

## Quality Invariants

### Static Enforcement

- Structured logging is statically enforced
- Naming conventions for schemas and types
- File size limits per layer
- Platform-specific reliability requirements

### Custom Code Checks

Implement custom linters with agent-friendly error messages:
- "Layer violation: {file} imports {import} which violates forward-only dependency rule"
- "Cross-cutting concern: {file} directly imports {module} - use Providers interface instead"
- "Circular dependency detected: {cycle} - refactor to remove circular reference"

## Migration Guide

When applying these rules to existing code:

1. **Analyze current dependencies** - Build dependency graph
2. **Identify violations** - Find backward dependencies and cross-cutting direct imports
3. **Plan refactoring** - Create execution plan in exec-plans/active/
4. **Restructure layers** - Move code to appropriate layers
5. **Introduce Providers** - Extract cross-cutting concerns to Providers
6. **Update imports** - Fix all import statements
7. **Add tests** - Create structural tests for validation
8. **Validate** - Run linters and tests to ensure compliance

## Exceptions

Only allow architecture violations with:
- Explicit architectural decision record (ADR)
- Approval from architecture review
- Documented justification in knowledge/design-docs/
- Temporary exemption with planned removal date

## Error Messages

Provide specific, actionable error messages:

**Layer Violation:**
```
Layer dependency violation in {file}:
  - Imports {import} from {layer}
  - Current layer: {current_layer}
  - Allowed dependencies: {allowed_layers}
  - Fix: Move {import} to appropriate layer or remove dependency
```

**Cross-Cutting Concern:**
```
Cross-cutting concern violation in {file}:
  - Direct import of {module}
  - Must use Providers interface instead
  - Available provider: {provider_interface}
  - Fix: Replace direct import with provider injection
```

## Success Criteria

Architecture is compliant when:
- All dependencies follow forward-only rule
- No circular dependencies exist
- All cross-cutting concerns use Providers interface
- Linters validate structure mechanically
- Structural tests pass
- No architecture violations in CI/CD
