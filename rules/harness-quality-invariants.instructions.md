---
applyTo: '**/*.cs,**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.razor'
description: 'Quality invariants and "golden rules" for agent-generated code following OpenAI harness engineering principles'
---

# Harness Quality Invariants

## Golden Principles

### 1. No "YOLO Data Probing"

**PROHIBITED:**
- Parsing data without validation
- Assuming data structure without checks
- "Trust me, it's fine" data access
- Skipping validation for performance

**REQUIRED:**
- Validate data at boundaries
- Use typed SDKs when available
- Validate limits and constraints
- Never build on guessed data shapes

**Example:**

```typescript
// WRONG - YOLO data probing
const user = JSON.parse(data);
const name = user.name;  // No validation

// CORRECT - Validate at boundary
interface User {
  name: string;
  email: string;
}
const user: User = validateAndParse<User>(data);
const name = user.name;  // Type-safe
```

### 2. Structured Logging is Mandatory

**REQUIRED:**
- All logs must be structured (JSON, key-value pairs)
- Include correlation IDs
- Include relevant context
- No free-form text logs

**Example:**

```csharp
// WRONG - Free-form log
logger.LogInformation("User logged in");

// CORRECT - Structured log
logger.LogInformation("UserLogin", new {
    UserId = user.Id,
    Timestamp = DateTime.UtcNow,
    CorrelationId = correlationId,
    IpAddress = request.IpAddress
});
```

### 3. Naming Conventions

**Schemas and Types:**
- PascalCase for public types
- camelCase for private/local variables
- Prefix interfaces with 'I'
- Descriptive, meaningful names
- No abbreviations unless widely known

**File Names:**
- kebab-case for files
- Match class/component name
- No special characters
- Meaningful names, not generic

**Example:**

```csharp
// CORRECT
public interface IUserService { }
public class UserService : IUserService { }
private readonly IUserService _userService;

// WRONG
public interface IUsrSvc { }
public class usrservice { }
```

### 4. File Size Limits

**Maximum File Sizes:**
- Skill files (SKILL.md): 500 lines
- Rule files (.instructions.md): 300 lines
- Knowledge files: 1000 lines
- Source code files: 500 lines (split if larger)

**Rationale:**
- Large files are hard to maintain
- Large files indicate need for refactoring
- Agents struggle with large context
- Easier to review and test smaller files

### 5. Platform-Specific Reliability

**.NET Applications:**
- All async methods must use CancellationToken
- All HTTP calls must have timeout
- All database operations must have retry policy
- All external service calls must have circuit breaker

**TypeScript/JavaScript:**
- All async functions must handle errors
- All fetch calls must have timeout
- All state updates must be immutable
- All side effects must be explicit

**Example:**

```csharp
// REQUIRED - .NET reliability pattern
public async Task<User> GetUserAsync(
    Guid userId,
    CancellationToken cancellationToken = default)
{
    using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    using var cts = CancellationTokenSource.CreateLinkedTokenSource(
        cancellationToken, 
        timeout.Token);
    
    return await _repository
        .GetUserAsync(userId, cts.Token)
        .WaitAsync(TimeSpan.FromSeconds(30), cts.Token);
}
```

## Utility Packages Preference

### Prefer Shared Utilities Over Custom Helpers

**REQUIRED:**
- Use shared utility packages when available
- Keep invariants centralized
- Avoid creating custom helpers for common operations

**Example:**

```typescript
// PREFER - Use shared utility
import { mapConcurrent } from '@shared/utils';

// AVOID - Custom helper
async function customMap(items, fn) { /* ... */ }
```

### When to Reimplement

Only reimplement when:
- Existing library has opaque behavior
- Library doesn't integrate with observability
- Library doesn't match execution environment expectations
- Cost of working around library exceeds reimplement cost

## Error Handling

### Always Handle Errors

**REQUIRED:**
- All async operations must have error handling
- All external calls must have fallback
- All validation errors must be user-friendly
- All system errors must be logged

**Example:**

```typescript
// CORRECT - Comprehensive error handling
try {
    const result = await apiCall();
    return result;
} catch (error) {
    if (error instanceof NetworkError) {
        logger.error('NetworkError', { error, context });
        return fallbackValue;
    }
    if (error instanceof ValidationError) {
        logger.warn('ValidationError', { error });
        throw new UserFriendlyError('Invalid input');
    }
    logger.error('UnexpectedError', { error });
    throw error;
}
```

### Error Messages

**User-Facing Errors:**
- Clear, actionable messages
- No technical jargon
- Suggest next steps
- Preserve security (no sensitive data)

**System Errors:**
- Include full context
- Include correlation ID
- Include stack trace (in logs, not user-facing)
- Structured format

## Performance Requirements

### Response Time Requirements

- **API endpoints**: < 200ms p95
- **Database queries**: < 100ms p95
- **UI interactions**: < 100ms perceived
- **Page load**: < 3 seconds

### Resource Limits

- **Memory**: < 512MB per process
- **CPU**: < 80% sustained
- **Database connections**: < 100 per service
- **Concurrent requests**: < 1000 per service

## Security Requirements

### Input Validation

- Validate all inputs at boundaries
- Use type-safe parsing
- Sanitize user input
- Never trust client-side validation

### Output Encoding

- Encode all output to prevent XSS
- Use parameterized queries
- Never concatenate SQL
- Use safe serialization

### Authentication/Authorization

- Always validate authentication
- Always check authorization
- Use principle of least privilege
- Log all auth failures

## Testing Requirements

### Test Coverage

- **Unit tests**: > 80% coverage
- **Integration tests**: Critical paths covered
- **E2E tests**: User journeys covered
- **All tests**: Must pass before merge

### Test Quality

- Tests must be deterministic
- Tests must be fast (< 5 seconds each)
- Tests must be independent
- Tests must have clear names

## Code Quality

### Code Review Checklist

Before merging code, verify:
- [ ] No YOLO data probing
- [ ] Structured logging used
- [ ] Naming conventions followed
- [ ] File size within limits
- [ ] Platform reliability patterns applied
- [ ] Errors handled properly
- [ ] Performance acceptable
- [ ] Security requirements met
- [ ] Tests added/updated
- [ ] Documentation updated

### Linter Configuration

Configure linters to enforce:
- No any types (use specific types)
- No console.log (use structured logging)
- No unused variables
- No implicit any
- Maximum complexity per function
- Maximum lines per function

## Mechanical Enforcement

### Automated Checks

Implement CI checks for:
- File size limits
- Naming conventions
- Structured logging usage
- Error handling patterns
- Test coverage thresholds
- Security vulnerability scans

### Custom Linters

Create custom linters for:
- YOLO data probing detection
- Structured logging validation
- Naming convention enforcement
- Reliability pattern compliance

## Violation Handling

### Severity Levels

**Critical:**
- Security vulnerabilities
- Data loss potential
- Performance degradation > 2x
- Blocking agent execution

**Important:**
- Code quality violations
- Missing error handling
- Performance degradation < 2x
- Test coverage below threshold

**Suggestion:**
- Style improvements
- Naming convention violations
- Documentation gaps
- Minor performance improvements

### Fix Requirements

- **Critical**: Must fix before merge
- **Important**: Should fix before merge, can request exception
- **Suggestion**: Nice to have, can defer

## Continuous Improvement

### Golden Principles Evolution

Golden principles are living documents:
- Update based on agent execution patterns
- Update based on community feedback
- Update based on security requirements
- Update based on platform changes

### Garbage Collection

Regular cleanup of violations:
- Weekly automated scans
- Monthly manual review
- Quarterly comprehensive audit
- Annual principle revision

## Success Criteria

Codebase is compliant when:
- No critical violations in CI
- < 5 important violations in CI
- All violations tracked and addressed
- Linters pass on all PRs
- Tests meet coverage thresholds
- Performance requirements met
- Security scans clean
