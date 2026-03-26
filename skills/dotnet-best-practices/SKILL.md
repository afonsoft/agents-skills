---
name: dotnet-best-practices
description: Ensures .NET/C# code follows modern best practices, SOLID principles, and industry standards for production-ready applications
---

# .NET Best Practices Skill

## When to Use This Skill

Use this skill when you need to:
- Review .NET code for adherence to best practices
- Implement new features following established patterns
- Refactor existing code to improve quality
- Ensure production-ready standards are met
- Validate architectural decisions

## Prerequisites

- .NET 6+ project
- Familiarity with C# modern features
- Understanding of SOLID principles
- Basic knowledge of Entity Framework Core

## Step-by-Step Workflows

### 1. Code Review and Validation

**Input**: C# code files or project structure  
**Output**: Detailed analysis with recommendations

```
Please review this .NET code for best practices compliance:

1. Check SOLID principles adherence
2. Verify modern C# feature usage
3. Validate error handling patterns
4. Assess performance considerations
5. Review security practices
6. Evaluate testability
```

### 2. New Feature Implementation

**Input**: Feature requirements and project context  
**Output**: Complete implementation following best practices

```
Implement [feature name] following .NET best practices:

1. Use appropriate design patterns
2. Apply SOLID principles
3. Include proper error handling
4. Add comprehensive documentation
5. Consider performance implications
6. Ensure testability
```

### 3. Refactoring Guidance

**Input**: Existing code that needs improvement  
**Output**: Refactored code with explanations

```
Refactor this code to follow .NET best practices:

1. Identify code smells and anti-patterns
2. Apply appropriate design patterns
3. Improve readability and maintainability
4. Optimize performance where applicable
5. Enhance error handling
6. Add missing documentation
```

## Core Principles

### SOLID Principles

1. **Single Responsibility Principle (SRP)**
   - Each class should have one reason to change
   - Methods should do one thing well
   - Keep classes focused and cohesive

2. **Open/Closed Principle (OCP)**
   - Open for extension, closed for modification
   - Use interfaces and abstractions
   - Leverage dependency injection

3. **Liskov Substitution Principle (LSP)**
   - Derived classes must be substitutable for base classes
   - Don't violate base class contracts
   - Maintain behavioral compatibility

4. **Interface Segregation Principle (ISP)**
   - Clients shouldn't depend on unused interfaces
   - Create focused, role-specific interfaces
   - Avoid fat interfaces

5. **Dependency Inversion Principle (DIP)**
   - Depend on abstractions, not concretions
   - Use dependency injection containers
   - Invert dependencies using interfaces

### Modern C# Features

1. **Null Safety**
   ```csharp
   // Use nullable reference types
   #nullable enable
   
   // Null checks
   ArgumentNullException.ThrowIfNull(value);
   
   // Null-coalescing operators
   string result = input ?? defaultValue;
   string? nullableResult = input?.ToString();
   ```

2. **Pattern Matching**
   ```csharp
   // Switch expressions
   string result = obj switch
   {
       string s => $"String: {s}",
       int i => $"Integer: {i}",
       null => "Null",
       _ => "Unknown"
   };
   
   // Property patterns
   if (person is { Age: >= 18 })
   {
       // Adult logic
   }
   ```

3. **Records and Init-Only Properties**
   ```csharp
   // Immutable records
   public record Person(string Name, int Age);
   
   // Init-only properties
   public class Product
   {
       public string Name { get; init; }
       public decimal Price { get; init; }
   }
   ```

4. **Async/Await Best Practices**
   ```csharp
   // ConfigureAwait for library code
   var result = await SomeAsyncMethod().ConfigureAwait(false);
   
   // Async all the way down
   public async Task<string> GetDataAsync()
   {
       var data = await _service.GetDataAsync();
       return ProcessData(data);
   }
   ```

## Code Quality Standards

### Naming Conventions

```csharp
// Classes: PascalCase
public class CustomerService { }

// Methods: PascalCase
public async Task<Customer> GetCustomerAsync(int id) { }

// Properties: PascalCase
public string CustomerName { get; set; }

// Fields: camelCase (private), _camelCase (private readonly)
private readonly ILogger<CustomerService> _logger;
private string _customerName;

// Constants: PascalCase
public const int MaxRetries = 3;

// Interfaces: PascalCase with I prefix
public interface IRepository<T> { }

// Enums: PascalCase
public enum OrderStatus { Pending, Processing, Shipped }
```

### Error Handling

```csharp
// Specific exceptions
throw new InvalidOperationException("Invalid operation state");

// Guard clauses
public void ProcessOrder(Order order)
{
    ArgumentNullException.ThrowIfNull(order);
    
    if (order.Items.Count == 0)
        throw new ArgumentException("Order cannot be empty");
    
    // Process order
}

// Try-catch with specific exceptions
try
{
    await _orderProcessor.ProcessAsync(order);
}
catch (OrderValidationException ex)
{
    _logger.LogError(ex, "Order validation failed");
    throw;
}
catch (Exception ex)
{
    _logger.LogError(ex, "Unexpected error processing order");
    throw new OrderProcessingException("Failed to process order", ex);
}
```

### Dependency Injection

```csharp
// Constructor injection
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly ILogger<OrderService> _logger;
    
    public OrderService(IOrderRepository repository, ILogger<OrderService> logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// Service registration
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddOrderServices(this IServiceCollection services)
    {
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IOrderService, OrderService>();
        
        return services;
    }
}
```

## Performance Guidelines

### Entity Framework Core

```csharp
// Use AsNoTracking for read-only queries
var customers = await _context.Customers
    .AsNoTracking()
    .Where(c => c.IsActive)
    .ToListAsync();

// Project only needed columns
var customerDtos = await _context.Customers
    .Where(c => c.IsActive)
    .Select(c => new CustomerDto
    {
        Id = c.Id,
        Name = c.Name,
        Email = c.Email
    })
    .ToListAsync();

// Use proper indexing
public class Customer
{
    [Key]
    public int Id { get; set; }
    
    [Indexed]
    public string Email { get; set; }
    
    public string Name { get; set; }
}
```

### Memory Management

```csharp
// Use using statements for IDisposable
using var scope = _serviceProvider.CreateScope();
var service = scope.ServiceProvider.GetRequiredService<IMyService>();

// Avoid memory leaks
public class ImageProcessor : IDisposable
{
    private readonly MemoryStream _stream;
    
    public ImageProcessor()
    {
        _stream = new MemoryStream();
    }
    
    public void Dispose()
    {
        _stream?.Dispose();
    }
}
```

## Security Best Practices

### Input Validation

```csharp
// Validate input parameters
public class CreateOrderRequest
{
    [Required]
    [StringLength(100, MinimumLength = 3)]
    public string CustomerName { get; set; }
    
    [Range(0.01, 10000.00)]
    public decimal Amount { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
}
```

### Authentication and Authorization

```csharp
// Use claims-based authorization
[Authorize]
[ApiController]
public class OrdersController : ControllerBase
{
    [HttpGet("{id}")]
    [Authorize(Policy = "CanReadOrders")]
    public async Task<ActionResult<Order>> GetOrder(int id)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var order = await _orderService.GetOrderAsync(id, userId);
        
        if (order == null)
            return NotFound();
            
        return Ok(order);
    }
}
```

## Testing Guidelines

### Unit Testing with xUnit

```csharp
public class OrderServiceTests
{
    private readonly Mock<IOrderRepository> _repositoryMock;
    private readonly Mock<ILogger<OrderService>> _loggerMock;
    private readonly OrderService _service;
    
    public OrderServiceTests()
    {
        _repositoryMock = new Mock<IOrderRepository>();
        _loggerMock = new Mock<ILogger<OrderService>>();
        _service = new OrderService(_repositoryMock.Object, _loggerMock.Object);
    }
    
    [Fact]
    public async Task CreateOrder_ValidOrder_ReturnsOrderId()
    {
        // Arrange
        var request = new CreateOrderRequest
        {
            CustomerName = "John Doe",
            Amount = 100.00m
        };
        
        var expectedOrder = new Order { Id = 1, CustomerName = request.CustomerName };
        _repositoryMock.Setup(r => r.AddAsync(It.IsAny<Order>()))
                      .ReturnsAsync(expectedOrder);
        
        // Act
        var result = await _service.CreateOrderAsync(request);
        
        // Assert
        result.Should().Be(1);
        _repositoryMock.Verify(r => r.AddAsync(It.IsAny<Order>()), Times.Once);
    }
}
```

## Troubleshooting

### Common Issues and Solutions

1. **Null Reference Exceptions**
   - Enable nullable reference types
   - Add proper null checks
   - Use null-coalescing operators

2. **Performance Issues**
   - Profile with Application Insights
   - Check for N+1 queries in EF Core
   - Optimize LINQ queries

3. **Memory Leaks**
   - Ensure IDisposable objects are properly disposed
   - Check for event handler subscriptions
   - Monitor with memory profilers

4. **Dependency Injection Issues**
   - Verify service registration
   - Check for circular dependencies
   - Use proper lifetime scopes

## References

- [.NET Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Entity Framework Core Performance](https://docs.microsoft.com/en-us/ef/core/performance/)
- [Dependency Injection in .NET](https://docs.microsoft.com/en-us/dotnet/core/extensions/dependency-injection)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

## Examples

### Complete Service Example

```csharp
public class OrderService : IOrderService
{
    private readonly IOrderRepository _repository;
    private readonly ILogger<OrderService> _logger;
    private readonly IOrderValidator _validator;
    
    public OrderService(
        IOrderRepository repository,
        ILogger<OrderService> logger,
        IOrderValidator validator)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _validator = validator ?? throw new ArgumentNullException(nameof(validator));
    }
    
    public async Task<int> CreateOrderAsync(CreateOrderRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);
        
        // Validate request
        var validationResult = await _validator.ValidateAsync(request);
        if (!validationResult.IsValid)
        {
            throw new ValidationException(validationResult.Errors);
        }
        
        // Create order
        var order = new Order
        {
            CustomerName = request.CustomerName,
            Amount = request.Amount,
            CreatedAt = DateTime.UtcNow,
            Status = OrderStatus.Pending
        };
        
        try
        {
            var orderId = await _repository.AddAsync(order);
            _logger.LogInformation("Order {OrderId} created successfully", orderId);
            return orderId;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create order");
            throw new OrderCreationException("Failed to create order", ex);
        }
    }
    
    public async Task<Order?> GetOrderAsync(int id, string userId)
    {
        if (id <= 0)
            throw new ArgumentException("Invalid order ID", nameof(id));
            
        if (string.IsNullOrWhiteSpace(userId))
            throw new ArgumentException("User ID is required", nameof(userId));
        
        var order = await _repository.GetByIdAsync(id);
        
        if (order == null || order.UserId != userId)
            return null;
            
        return order;
    }
}
```

---

**This skill provides comprehensive guidance for .NET development best practices. Use it to ensure your code meets industry standards and follows modern patterns.**
