---
description: RESTful API design guidelines, HTTP best practices, and API versioning strategies for .NET applications
applyTo:
  - "**/Controllers/**.cs"
  - "**/DTOs/**.cs"
  - "**/Models/**.cs"
  - "**/Api/**.cs"
---

# API Design Guidelines

## Overview

This document defines the standards and best practices for designing and implementing RESTful APIs in .NET applications to ensure consistency, maintainability, and proper HTTP semantics.

## RESTful Principles

### Resource Naming

```csharp
// Good: Use nouns for resources
GET /api/users           // Get all users
GET /api/users/{id}      // Get specific user
POST /api/users          // Create new user
PUT /api/users/{id}      // Update user
DELETE /api/users/{id}   // Delete user

// Bad: Use verbs in URLs
GET /api/getUsers
POST /api/createUser
```

### HTTP Methods

| Method | Purpose | Safe | Idempotent |
|--------|---------|------|------------|
| GET | Retrieve resource | ✅ | ✅ |
| POST | Create resource | ❌ | ❌ |
| PUT | Update resource (replace) | ❌ | ✅ |
| PATCH | Update resource (partial) | ❌ | ❌ |
| DELETE | Delete resource | ❌ | ✅ |

### Status Codes

```csharp
// Success codes
200 OK              // GET, PUT, PATCH
201 Created         // POST
204 No Content      // DELETE

// Client error codes
400 Bad Request     // Validation errors
401 Unauthorized    // Authentication required
403 Forbidden       // Authorization failed
404 Not Found       // Resource not found
409 Conflict        // Resource conflict
422 Unprocessable Entity // Validation errors

// Server error codes
500 Internal Server Error // Unexpected errors
502 Bad Gateway     // Upstream service error
503 Service Unavailable // Service temporarily unavailable
```

## URL Structure

### Hierarchical Resources

```csharp
// Good: Hierarchical relationships
GET /api/users/{userId}/orders
GET /api/users/{userId}/orders/{orderId}
POST /api/users/{userId}/orders
PUT /api/users/{userId}/orders/{orderId}
DELETE /api/users/{userId}/orders/{orderId}

// Alternative: Separate resources
GET /api/orders?userId={userId}
POST /api/orders
PUT /api/orders/{orderId}
DELETE /api/orders/{orderId}
```

### Query Parameters

```csharp
// Filtering
GET /api/users?status=active&role=admin

// Pagination
GET /api/users?page=1&pageSize=10

// Sorting
GET /api/users?sort=name&order=asc

// Searching
GET /api/users?search=john&fields=name,email

// Date ranges
GET /api/orders?startDate=2024-01-01&endDate=2024-01-31
```

## Request/Response Design

### DTOs vs Entities

```csharp
// Entity (internal)
public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public string PasswordHash { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }
}

// DTOs (external)
public class UserDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }
}

public class CreateUserRequest
{
    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Name { get; set; }

    [Required]
    [EmailAddress]
    public string Email { get; set; }

    [Required]
    [StringLength(100, MinimumLength = 8)]
    public string Password { get; set; }
}

public class UpdateUserRequest
{
    [StringLength(100, MinimumLength = 2)]
    public string? Name { get; set; }

    [EmailAddress]
    public string? Email { get; set; }

    public bool? IsActive { get; set; }
}
```

### Response Format

```csharp
// Success response
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-01T00:00:00Z",
    "isActive": true
  },
  "message": "User retrieved successfully"
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      },
      {
        "field": "name",
        "message": "Name must be at least 2 characters"
      }
    ]
  }
}

// Paginated response
{
  "data": [
    { "id": 1, "name": "John Doe", "email": "john@example.com" },
    { "id": 2, "name": "Jane Smith", "email": "jane@example.com" }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 10,
    "totalItems": 25,
    "totalPages": 3,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

## Controller Implementation

### Base Controller

```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public abstract class BaseController : ControllerBase
{
    protected IActionResult Ok<T>(T data, string message = "Operation completed successfully")
    {
        return Ok(new ApiResponse<T>
        {
            Success = true,
            Data = data,
            Message = message
        });
    }

    protected IActionResult Created<T>(T data, string message = "Resource created successfully")
    {
        return Created(string.Empty, new ApiResponse<T>
        {
            Success = true,
            Data = data,
            Message = message
        });
    }

    protected IActionResult BadRequest(string message, Dictionary<string, string>? errors = null)
    {
        return BadRequest(new ApiResponse
        {
            Success = false,
            Message = message,
            Errors = errors
        });
    }

    protected IActionResult NotFound(string message = "Resource not found")
    {
        return NotFound(new ApiResponse
        {
            Success = false,
            Message = message
        });
    }

    protected IActionResult InternalServerError(string message = "An internal server error occurred")
    {
        return StatusCode(StatusCodes.Status500InternalServerError, new ApiResponse
        {
            Success = false,
            Message = message
        });
    }
}
```

### Specific Controller

```csharp
[Route("api/[controller]")]
public class UsersController : BaseController
{
    private readonly IUserService _userService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserService userService, ILogger<UsersController> logger)
    {
        _userService = userService ?? throw new ArgumentNullException(nameof(userService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResult<UserDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetUsers(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? search = null,
        [FromQuery] string? status = null)
    {
        try
        {
            var result = await _userService.GetUsersAsync(page, pageSize, search, status);
            return Ok(result, "Users retrieved successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving users");
            return InternalServerError("Failed to retrieve users");
        }
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<UserDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetUser(int id)
    {
        try
        {
            var user = await _userService.GetUserAsync(id);
            if (user == null)
                return NotFound("User not found");

            return Ok(user, "User retrieved successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving user {UserId}", id);
            return InternalServerError("Failed to retrieve user");
        }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<UserDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState
                    .Where(x => x.Value.Errors.Any())
                    .ToDictionary(
                        kvp => kvp.Key,
                        kvp => string.Join(", ", kvp.Value.Errors.Select(e => e.ErrorMessage))
                    );
                return BadRequest("Validation failed", errors);
            }

            var user = await _userService.CreateUserAsync(request);
            return Created(user, "User created successfully");
        }
        catch (ValidationException ex)
        {
            _logger.LogWarning(ex, "Validation failed while creating user");
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating user");
            return InternalServerError("Failed to create user");
        }
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(ApiResponse<UserDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserRequest request)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState
                    .Where(x => x.Value.Errors.Any())
                    .ToDictionary(
                        kvp => kvp.Key,
                        kvp => string.Join(", ", kvp.Value.Errors.Select(e => e.ErrorMessage))
                    );
                return BadRequest("Validation failed", errors);
            }

            var user = await _userService.UpdateUserAsync(id, request);
            if (user == null)
                return NotFound("User not found");

            return Ok(user, "User updated successfully");
        }
        catch (ValidationException ex)
        {
            _logger.LogWarning(ex, "Validation failed while updating user {UserId}", id);
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user {UserId}", id);
            return InternalServerError("Failed to update user");
        }
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteUser(int id)
    {
        try
        {
            var result = await _userService.DeleteUserAsync(id);
            if (!result)
                return NotFound("User not found");

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting user {UserId}", id);
            return InternalServerError("Failed to delete user");
        }
    }
}
```

## Validation

### Model Validation

```csharp
using System.ComponentModel.DataAnnotations;

public class CreateUserRequest
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
    public string Name { get; set; }

    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; }

    [Required(ErrorMessage = "Password is required")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "Password must be between 8 and 100 characters")]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]", 
        ErrorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character")]
    public string Password { get; set; }
}
```

### Custom Validation

```csharp
public class UniqueEmailAttribute : ValidationAttribute
{
    private readonly IUserService _userService;

    public UniqueEmailAttribute(IUserService userService)
    {
        _userService = userService;
    }

    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        if (value == null)
            return ValidationResult.Success;

        var email = value.ToString();
        
        var existingUser = _userService.GetUserByEmailAsync(email).Result;
        if (existingUser != null)
        {
            return new ValidationResult("Email is already in use");
        }

        return ValidationResult.Success;
    }
}

// Usage
public class CreateUserRequest
{
    [UniqueEmail]
    public string Email { get; set; }
}
```

## Error Handling

### Global Exception Handling

```csharp
public class ApiExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ApiExceptionHandlingMiddleware> _logger;

    public ApiExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ApiExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        _logger.LogError(exception, "An unhandled exception occurred");

        var response = exception switch
        {
            ValidationException validationEx => new
            {
                StatusCode = StatusCodes.Status400BadRequest,
                Message = validationEx.Message,
                Errors = validationEx.Errors
            },
            NotFoundException notFoundEx => new
            {
                StatusCode = StatusCodes.Status404NotFound,
                Message = notFoundEx.Message
            },
            UnauthorizedException unauthorizedEx => new
            {
                StatusCode = StatusCodes.Status401Unauthorized,
                Message = unauthorizedEx.Message
            },
            _ => new
            {
                StatusCode = StatusCodes.Status500InternalServerError,
                Message = "An internal server error occurred"
            }
        };

        context.Response.Clear();
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = response.StatusCode;

        await context.Response.WriteAsJsonAsync(response);
    }

    private class ErrorResponse
    {
        public int StatusCode { get; set; }
        public string Message { get; set; }
        public Dictionary<string, string>? Errors { get; set; }
    }
}
```

### Custom Exceptions

```csharp
public class ApiException : Exception
{
    public int StatusCode { get; }
    public Dictionary<string, string>? Errors { get; }

    public ApiException(int statusCode, string message, Dictionary<string, string>? errors = null)
        : base(message)
    {
        StatusCode = statusCode;
        Errors = errors;
    }
}

public class ValidationException : ApiException
{
    public ValidationException(string message, Dictionary<string, string>? errors = null)
        : base(StatusCodes.Status400BadRequest, message, errors)
    {
    }
}

public class NotFoundException : ApiException
{
    public NotFoundException(string message)
        : base(StatusCodes.Status404NotFound, message)
    {
    }
}

public class UnauthorizedException : ApiException
{
    public UnauthorizedException(string message)
        : base(StatusCodes.Status401Unauthorized, message)
    {
    }
}
```

## API Versioning

### URL Versioning

```csharp
[ApiController]
[Route("api/v1/[controller]")]
public class UsersControllerV1 : ControllerBase
{
    [HttpGet]
    public IActionResult GetUsers()
    {
        // V1 implementation
    }
}

[ApiController]
[Route("api/v2/[controller]")]
public class UsersControllerV2 : ControllerBase
{
    [HttpGet]
    public IActionResult GetUsers()
    {
        // V2 implementation with breaking changes
    }
}
```

### Header Versioning

```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    [HttpGet]
    public IActionResult GetUsers([FromHeader(Name = "Api-Version")] string apiVersion = "1.0")
    {
        return apiVersion switch
        {
            "1.0" => GetUsersV1(),
            "2.0" => GetUsersV2(),
            _ => BadRequest("Unsupported API version")
        };
    }

    private IActionResult GetUsersV1()
    {
        // V1 implementation
    }

    private IActionResult GetUsersV2()
    {
        // V2 implementation
    }
}
```

## OpenAPI/Swagger Documentation

### Configuration

```csharp
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "My API",
        Version = "v1",
        Description = "My API documentation",
        Contact = new OpenApiContact
        {
            Name = "API Support",
            Email = "support@example.com"
        },
        License = new OpenApiLicense
        {
            Name = "MIT License",
            Url = "https://opensource.org/licenses/MIT"
        }
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                Array.Empty<string>()
            }
        }
    });
});
```

### XML Documentation

```csharp
/// <summary>
/// Represents a user in the system
/// </summary>
/// <remarks>
/// This class contains user information including personal details and account status.
/// </remarks>
public class UserDto
{
    /// <summary>
    /// Gets or sets the unique identifier for the user
    /// </summary>
    /// <example>1</example>
    public int Id { get; set; }

    /// <summary>
    /// Gets or sets the user's full name
    /// </summary>
    /// <example>John Doe</example>
    public string Name { get; set; }

    /// <summary>
    /// Gets or sets the user's email address
    /// </summary>
    /// <example>john@example.com</example>
    public string Email { get; set; }

    /// <summary>
    /// Gets or sets the date when the user account was created
    /// </summary>
    /// <example>2024-01-01T00:00:00Z</example>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Gets or sets whether the user account is active
    /// </summary>
    /// <example>true</example>
    public bool IsActive { get; set; }
}
```

## Security

### Authentication

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetUsers()
    {
        // Requires authentication
    }

    [HttpGet("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetUser(int id)
    {
        // Requires Admin role
    }

    [HttpPost]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        // No authentication required
    }
}
```

### Rate Limiting

```csharp
[ApiController]
[Route("api/[controller]")]
[RateLimit(100, 60)] // 100 requests per minute
public class UsersController : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetUsers()
    {
        // Rate limited endpoint
    }
}
```

## Testing

### Unit Testing Controllers

```csharp
public class UsersControllerTests
{
    private readonly Mock<IUserService> _userServiceMock;
    private readonly Mock<ILogger<UsersController>> _loggerMock;
    private readonly UsersController _controller;

    public UsersControllerTests()
    {
        _userServiceMock = new Mock<IUserService>();
        _loggerMock = new Mock<ILogger<UsersController>>();
        _controller = new UsersController(_userServiceMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task GetUsers_ReturnsOkResult()
    {
        // Arrange
        var users = new List<UserDto>
        {
            new() { Id = 1, Name = "John Doe", Email = "john@example.com" },
            new() { Id = 2, Name = "Jane Smith", Email = "jane@example.com" }
        };

        _userServiceMock.Setup(s => s.GetUsersAsync(1, 10, null, null))
                      .ReturnsAsync(new PagedResult<UserDto>(users, 1, 10, 2, 1));

        // Act
        var result = await _controller.GetUsers();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var apiResponse = Assert.IsType<ApiResponse<PagedResult<UserDto>>>(okResult.Value);
        apiResponse.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data.Items.Should().HaveCount(2);
    }

    [Fact]
    public async Task CreateUser_ValidRequest_ReturnsCreatedResult()
    {
        // Arrange
        var request = new CreateUserRequest
        {
            Name = "John Doe",
            Email = "john@example.com",
            Password = "Password123!"
        };

        var createdUser = new UserDto
        {
            Id = 1,
            Name = request.Name,
            Email = request.Email,
            CreatedAt = DateTime.UtcNow,
            IsActive = true
        };

        _userServiceMock.Setup(s => s.CreateUserAsync(request))
                      .ReturnsAsync(createdUser);

        // Act
        var result = await _controller.CreateUser(request);

        // Assert
        var createdResult = Assert.IsType<CreatedResult>(result.Result);
        var apiResponse = Assert.IsType<ApiResponse<UserDto>>(createdResult.Value);
        apiResponse.Success.Should().BeTrue();
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data.Id.Should().Be(1);
    }
}
```

## Best Practices

### Do's
- ✅ Use proper HTTP methods and status codes
- ✅ Implement comprehensive validation
- ✅ Use DTOs for data transfer
- ✅ Add proper error handling
- ✅ Include API documentation
- ✅ Implement authentication and authorization
- ✅ Use pagination for large datasets
- ✅ Add comprehensive logging
- ✅ Write unit tests for all endpoints
- ✅ Follow RESTful conventions

### Don'ts
- ❌ Use verbs in URL paths
- ❌ Return entities directly from database
- ❌ Ignore error handling
- ❌ Skip validation
- ❌ Use synchronous operations for I/O
- ❌ Return sensitive data
- ❌ Ignore security best practices
- ❌ Skip documentation
- ❌ Use inconsistent response formats

## References

- [RESTful API Design Guidelines](https://restfulapi.net/)
- [Microsoft REST API Guidelines](https://github.com/Microsoft/api-guidelines/blob/vNext/Guidelines.md)
- [OpenAPI Specification](https://swagger.io/specification/)
- [ASP.NET Core Web API Best Practices](https://docs.microsoft.com/en-us/aspnet/core/web-api/)

---

**Follow these guidelines to create consistent, secure, and maintainable RESTful APIs.**
