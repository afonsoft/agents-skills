# Coding Standards Compendium

This document consolidates coding standards and best practices from across the repository rules.

## Universal Principles

### Code Quality Standards
- **Clean Code**: Descriptive names, single responsibility, DRY principle
- **Function Size**: Keep functions small and focused (< 20-30 lines)
- **Nesting**: Avoid deeply nested code (max 3-4 levels)
- **Magic Values**: Use constants instead of magic numbers/strings
- **Self-Documenting**: Code should be self-documenting; comments only when necessary

### Error Handling
- Proper error handling at appropriate levels
- Meaningful error messages
- No silent failures or ignored exceptions
- Fail fast: validate inputs early
- Use appropriate error types/exceptions

### Security Standards
- **Sensitive Data**: No passwords, API keys, tokens, or PII in code/logs
- **Input Validation**: All user inputs validated and sanitized
- **SQL Injection**: Use parameterized queries, never string concatenation
- **Authentication**: Proper authentication checks before accessing resources
- **Authorization**: Verify user has permission to perform action

## Language-Specific Standards

### C# (.NET)

#### Naming Conventions
- **PascalCase**: Component names, method names, public members
- **camelCase**: Private fields and local variables
- **Interface Prefix**: Prefix with "I" (e.g., `IUserService`)
- **Async Suffix**: Use 'Async' suffix for async methods

#### Code Structure
- Use latest C# version (C# 14)
- File-scoped namespace declarations
- Single-line using directives
- Newline before opening curly brace
- Pattern matching and switch expressions preferred
- Use `nameof` instead of string literals

#### Async Programming
- Return `Task<T>` for value-returning async methods
- Return `Task` for void async methods
- Consider `ValueTask<T>` for high-performance scenarios
- Avoid `async void` except for event handlers
- Use `ConfigureAwait(false)` in library code
- Never use `.Wait()`, `.Result`, or `.GetAwaiter().GetResult()`

#### Null Safety
- Declare variables non-nullable by default
- Use `is null` / `is not null` instead of `== null`
- Trust C# null annotations
- Check for null at entry points

#### Testing
- Test naming: `MethodName_Condition_ExpectedResult()`
- No "Arrange/Act/Assert" comments
- Follow existing test style
- Include test cases for critical paths

### JavaScript/TypeScript

#### Naming Conventions
- **camelCase**: Variables and functions
- **PascalCase**: Classes and interfaces
- **UPPER_SNAKE_CASE**: Constants
- **kebab-case**: File names

#### Code Structure
- Use modern ES6+ features
- Prefer `const` and `let` over `var`
- Use arrow functions for callbacks
- Implement proper error handling with try/catch
- Use TypeScript for type safety

#### Async Programming
- Use Promises with async/await
- Avoid callback hell
- Handle promise rejections
- Use `Promise.all()` for parallel execution

### Python

#### Naming Conventions
- **snake_case**: Variables and functions
- **PascalCase**: Classes
- **UPPER_SNAKE_CASE**: Constants
- **snake_case**: File names

#### Code Structure
- Follow PEP 8 style guide
- Use type hints where appropriate
- Implement proper exception handling
- Use list comprehensions when appropriate
- Follow explicit is better than implicit

#### Testing
- Use `pytest` framework
- Test naming: `test_function_name_condition`
- Use descriptive test names
- Mock external dependencies

## Architecture Standards

### SOLID Principles
1. **Single Responsibility**: Each class has one reason to change
2. **Open/Closed**: Open for extension, closed for modification
3. **Liskov Substitution**: Subtypes substitutable for base types
4. **Interface Segregation**: No forced dependency on unused methods
5. **Dependency Inversion**: Depend on abstractions, not concretions

### Domain-Driven Design (DDD)
- **Ubiquitous Language**: Consistent business terminology
- **Bounded Contexts**: Clear service boundaries
- **Aggregates**: Consistency boundaries and transactional integrity
- **Domain Events**: Capture business-significant occurrences
- **Rich Domain Models**: Business logic in domain layer

### Layer Architecture
- **Domain Layer**: Business logic and entities
- **Application Layer**: Use cases and orchestration
- **Infrastructure Layer**: External systems and persistence
- **Presentation Layer**: UI and API endpoints

## Testing Standards

### Test Categories
- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions
- **Acceptance Tests**: Test complete user scenarios
- **Performance Tests**: Test system performance

### Test Quality
- **Coverage**: Minimum 85% for critical code
- **Naming**: Descriptive names following conventions
- **Structure**: Clear Arrange-Act-Assert pattern
- **Independence**: Tests should not depend on each other
- **Deterministic**: Same results on every run

### Test Data Management
- Use test factories for object creation
- Mock external dependencies
- Test edge cases and boundary conditions
- Clean up test data after tests

## Performance Standards

### Database Operations
- Avoid N+1 queries
- Use proper indexing
- Implement pagination for large result sets
- Use connection pooling
- Cache frequently accessed data

### Memory Management
- Properly dispose of resources
- Avoid memory leaks
- Use appropriate data structures
- Monitor memory usage
- Implement caching strategies

### Algorithm Efficiency
- Consider time/space complexity
- Use appropriate data structures
- Implement lazy loading where beneficial
- Optimize hot paths
- Measure and profile performance

## Documentation Standards

### Code Documentation
- Document public APIs
- Explain complex algorithms
- Provide usage examples
- Include parameter and return value descriptions
- Use consistent documentation format

### API Documentation
- Use OpenAPI/Swagger for REST APIs
- Document all endpoints
- Include request/response examples
- Document authentication requirements
- Provide error response documentation

### README Standards
- Project overview and purpose
- Installation and setup instructions
- Usage examples
- Contributing guidelines
- License information

## Security Standards

### Data Protection
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Implement proper access controls
- Follow data retention policies
- Comply with relevant regulations (GDPR, LGPD, etc.)

### Authentication & Authorization
- Implement strong authentication
- Use role-based access control
- Implement proper session management
- Use secure password storage
- Implement multi-factor authentication where appropriate

### Input Validation
- Validate all user inputs
- Sanitize data to prevent injection attacks
- Use parameterized queries
- Implement proper error handling
- Log security events

## DevOps Standards

### Version Control
- Use semantic versioning
- Write descriptive commit messages
- Use feature branches
- Implement code reviews
- Maintain clean commit history

### CI/CD Pipeline
- Automated testing on all commits
- Automated security scanning
- Automated deployment to staging
- Manual approval for production
- Rollback capabilities

### Infrastructure as Code
- Use Terraform or similar tools
- Version control infrastructure definitions
- Implement proper tagging
- Use modular templates
- Document infrastructure decisions

## Code Review Standards

### Review Process
- Review for correctness, security, and maintainability
- Provide constructive feedback
- Suggest specific improvements
- Acknowledge good practices
- Focus on code, not the author

### Review Priorities
1. **Critical**: Security vulnerabilities, logic errors, breaking changes
2. **Important**: Code quality issues, missing tests, performance problems
3. **Suggestions**: Readability improvements, optimizations, conventions

### Review Comments
- Be specific and reference exact lines
- Explain why something is an issue
- Provide concrete suggestions
- Include code examples when helpful
- Group related comments

This compendium serves as a comprehensive reference for coding standards across all languages and frameworks used in the repository.
