---
applyTo: '**/*.cs,**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py'
description: 'Strict prohibition of "YOLO data probing" - all data must be validated at boundaries with typed SDKs or explicit validation'
---

# No YOLO Data Probing

## Principle

Never parse or access data without validation. "Trust me, it's fine" is not acceptable. All data must be validated at boundaries using typed SDKs or explicit validation.

## Prohibited Patterns

### 1. Unvalidated JSON Parsing

**WRONG:**

```typescript
// YOLO - assumes structure without validation
const data = JSON.parse(jsonString);
const name = data.user.name;  // No validation, could crash
```

```csharp
// YOLO - assumes structure without validation
var data = JsonSerializer.Deserialize<dynamic>(jsonString);
var name = data.user.name;  // No validation
```

```python
# YOLO - assumes structure without validation
data = json.loads(json_string)
name = data['user']['name']  # No validation
```

### 2. Direct Property Access Without Checks

**WRONG:**

```typescript
// YOLO - no null checks
const user = getUser();
const email = user.email;  // Could be null/undefined
```

```csharp
// YOLO - no null checks
var user = GetUser();
var email = user.Email;  // Could be null
```

### 3. Array Access Without Bounds Checking

**WRONG:**

```typescript
// YOLO - no bounds checking
const item = items[index];  // Could be out of bounds
```

```csharp
// YOLO - no bounds checking
var item = items[index];  // Could throw exception
```

### 4. Type Assertions Without Validation

**WRONG:**

```typescript
// YOLO - type assertion without validation
const user = data as User;  // Assumes shape without checking
```

```csharp
// YOLO - cast without validation
var user = (User)data;  // Assumes shape without checking
```

## Required Patterns

### 1. Validate at Boundaries

**CORRECT:**

```typescript
// Validate at boundary with schema
interface User {
  name: string;
  email: string;
}

function parseUser(data: unknown): User {
  const result = userSchema.parse(data);
  return result;
}

const user = parseUser(jsonString);
const name = user.name;  // Type-safe, validated
```

```csharp
// Validate at boundary with schema
public class UserValidator
{
    public static User Validate(string json)
    {
        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };
        var user = JsonSerializer.Deserialize<User>(json, options);
        
        if (user == null)
            throw new ValidationException("Invalid user data");
            
        if (string.IsNullOrWhiteSpace(user.Name))
            throw new ValidationException("Name is required");
            
        return user;
    }
}

var user = UserValidator.Validate(jsonString);
var name = user.Name;  // Validated
```

### 2. Use Typed SDKs

**CORRECT:**

```typescript
// Use typed SDK
import { UserClient } from '@api/client';

const client = new UserClient();
const user = await client.getUser(userId);  // Type-safe
```

```csharp
// Use typed SDK
var user = await _userClient.GetUserAsync(userId);  // Type-safe
```

### 3. Defensive Programming

**CORRECT:**

```typescript
// Defensive with null checks
const user = getUser();
const email = user?.email ?? 'default@example.com';
```

```csharp
// Defensive with null checks
var user = GetUser();
var email = user?.Email ?? "default@example.com";
```

### 4. Array Access with Bounds Checking

**CORRECT:**

```typescript
// Bounds checking
const item = index < items.length ? items[index] : null;
```

```csharp
// Bounds checking
var item = index < items.Count ? items[index] : null;
```

## Validation Libraries

### TypeScript/JavaScript

**Recommended:**
- Zod - Schema validation
- Joi - Schema validation
- Yup - Schema validation
- io-ts - Runtime type validation

**Example with Zod:**

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().min(0).max(150)
});

type User = z.infer<typeof UserSchema>;

function parseUser(data: unknown): User {
  return UserSchema.parse(data);
}
```

### C#

**Recommended:**
- System.Text.Json with validation
- FluentValidation
- DataAnnotations

**Example with DataAnnotations:**

```csharp
public class User
{
    [Required]
    [StringLength(100)]
    public string Name { get; set; }
    
    [Required]
    [EmailAddress]
    public string Email { get; set; }
}

public class UserValidator
{
    public static void Validate(User user)
    {
        var context = new ValidationContext(user);
        var results = new List<ValidationResult>();
        
        if (!Validator.TryValidateObject(user, context, results, true))
        {
            throw new ValidationException(results);
        }
    }
}
```

### Python

**Recommended:**
- Pydantic - Data validation
- Marshmallow - Serialization/validation
- Cerberus - Schema validation

**Example with Pydantic:**

```python
from pydantic import BaseModel, EmailStr, validator

class User(BaseModel):
    name: str
    email: EmailStr
    age: int
    
    @validator('age')
    def age_must_be_positive(cls, v):
        if v < 0:
            raise ValueError('age must be positive')
        return v

user = User.parse_obj(data)
```

## Error Handling

### Validation Errors Must Be Handled

**CORRECT:**

```typescript
try {
  const user = parseUser(data);
} catch (error) {
  if (error instanceof z.ZodError) {
    logger.error('ValidationError', { 
      errors: error.errors,
      data 
    });
    throw new UserFriendlyError('Invalid user data');
  }
  throw error;
}
```

```csharp
try
{
    var user = UserValidator.Validate(json);
}
catch (ValidationException ex)
{
    _logger.LogError(ex, "Validation failed");
    throw new UserFriendlyException("Invalid user data");
}
```

## Linter Rules

### Implement Custom Linters

**TypeScript ESLint:**

```javascript
{
  "rules": {
    "no-unsafe-assignment": "error",
    "no-unsafe-member-access": "error",
    "no-unsafe-call": "error",
    "no-explicit-any": "error",
    "@typescript-eslint/no-unnecessary-type-assertion": "error"
  }
}
```

**C# Analyzer:**

```xml
<AnalyzerConfig>
  <Rule>
    <Id>CA1062</Id> <!-- Validate arguments -->
    <Action>Error</Action>
  </Rule>
  <Rule>
    <Id>CA2201</Id> <!-- Do not raise reserved exception types -->
    <Action>Error</Action>
  </Rule>
</AnalyzerConfig>
```

## Common Violations and Fixes

### Violation 1: Dynamic Type Access

**Problem:**
```typescript
const data = JSON.parse(json);
const value = data.some.nested.property;  // YOLO
```

**Fix:**
```typescript
interface Data {
  some: {
    nested: {
      property: string;
    };
  };
}

const data: Data = validateAndParse<Data>(json);
const value = data.some.nested.property;  // Type-safe
```

### Violation 2: Array Index Assumption

**Problem:**
```typescript
const first = items[0];  // Assumes array has items
```

**Fix:**
```typescript
const first = items[0] ?? null;  // Safe access
// or
const first = items.at(0);  // Returns undefined if out of bounds
```

### Violation 3: Optional Chaining Without Validation

**Problem:**
```typescript
const value = obj?.nested?.property;  // Still assumes structure
```

**Fix:**
```typescript
const schema = z.object({
  nested: z.object({
    property: z.string()
  })
});

const validated = schema.parse(obj);
const value = validated.nested.property;  // Validated
```

## Testing

### Test Validation Logic

Always test validation logic:

```typescript
describe('parseUser', () => {
  it('should validate valid data', () => {
    const data = { name: 'John', email: 'john@example.com' };
    const user = parseUser(data);
    expect(user).toBeDefined();
  });
  
  it('should reject invalid email', () => {
    const data = { name: 'John', email: 'invalid' };
    expect(() => parseUser(data)).toThrow();
  });
  
  it('should reject missing name', () => {
    const data = { email: 'john@example.com' };
    expect(() => parseUser(data)).toThrow();
  });
});
```

## Enforcement

### CI Checks

Add CI checks to detect YOLO probing:

1. Scan for `JSON.parse` without schema validation
2. Scan for type assertions without validation
3. Scan for dynamic property access
4. Scan for array access without bounds checking
5. Scan for `any` type usage

### Pre-commit Hooks

Add pre-commit hooks to prevent YOLO probing:

```bash
#!/bin/bash
# Check for YOLO data probing patterns
if git diff --cached | grep -q "JSON.parse"; then
  echo "Warning: JSON.parse found - ensure schema validation is used"
fi
```

## Success Criteria

Codebase is compliant when:
- No unvalidated JSON parsing
- No type assertions without validation
- No dynamic property access
- All data validated at boundaries
- Typed SDKs used where available
- Validation tests exist for all parsing logic
- Linters enforce validation patterns
- CI checks prevent YOLO probing violations
