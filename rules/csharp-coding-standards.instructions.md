---
description: C# coding standards and conventions for consistent, maintainable code
applyTo:
  - "**/*.cs"
  - "**/*.csx"
---

# C# Coding Standards

## Overview

This document defines the coding standards and conventions for C# projects to ensure consistency, readability, and maintainability across all codebases.

## Naming Conventions

### General Rules

- **Use meaningful names** that describe the purpose
- **Avoid abbreviations** except for commonly known ones (e.g., ID, URL, HTML)
- **Be consistent** with naming throughout the project
- **Use American English** spelling

### Specific Conventions

```csharp
// Classes: PascalCase
public class CustomerService { }
public class OrderRepository { }

// Interfaces: PascalCase with 'I' prefix
public interface IRepository<T> { }
public interface ILogger { }

// Methods: PascalCase
public async Task<Customer> GetCustomerAsync(int id) { }
public void ProcessOrder(Order order) { }

// Properties: PascalCase
public string CustomerName { get; set; }
public int OrderCount { get; private set; }

// Fields: camelCase (private), _camelCase (private readonly)
private readonly ILogger<CustomerService> _logger;
private string _customerName;
private static readonly int MaxRetries = 3;

// Constants: PascalCase
public const int DefaultTimeout = 30;
public const string ApiVersion = "v1";

// Enums: PascalCase
public enum OrderStatus { Pending, Processing, Shipped, Delivered }

// Local variables: camelCase
var customerName = "John Doe";
var orderTotal = CalculateTotal(order);

// Parameters: camelCase
public void CreateOrder(string customerName, decimal amount) { }

// Async methods: End with "Async"
public async Task<Customer> GetCustomerAsync(int id) { }
public async Task SaveOrderAsync(Order order) { }
```

## File Organization

### File Naming

- **Class files**: `[ClassName].cs` (e.g., `CustomerService.cs`)
- **Interface files**: `[IInterfaceName].cs` (e.g., `IRepository.cs`)
- **Enum files**: `[EnumName].cs` (e.g., `OrderStatus.cs`)
- **Test files**: `[ClassName]Tests.cs` (e.g., `CustomerServiceTests.cs`)

### File Structure

```csharp
// 1. Using statements (alphabetical, grouped)
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MyProject.Domain.Entities;
using MyProject.Infrastructure.Data;

// 2. Namespace
namespace MyProject.Application.Services
{
    // 3. Class documentation
    /// <summary>
    /// Service for managing customer operations and business logic.
    /// </summary>
    public class CustomerService
    {
        // 4. Fields (readonly first, then mutable)
        private readonly ICustomerRepository _repository;
        private readonly ILogger<CustomerService> _logger;
        private string _lastOperation;

        // 5. Constructor
        public CustomerService(
            ICustomerRepository repository,
            ILogger<CustomerService> logger)
        {
            _repository = repository ?? throw new ArgumentNullException(nameof(repository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        // 6. Properties (if any)
        public string LastOperation => _lastOperation;

        // 7. Public methods
        public async Task<Customer> GetCustomerAsync(int id)
        {
            // Implementation
        }

        // 8. Private methods
        private void ValidateCustomerId(int id)
        {
            // Implementation
        }
    }
}
```

## Code Formatting

### Indentation and Spacing

```csharp
// Use 4 spaces for indentation (no tabs)
if (condition)
{
    // Indented with 4 spaces
    DoSomething();
}

// Space after keywords
if (condition) { }
while (condition) { }
for (int i = 0; i < 10; i++) { }

// Space around operators
var result = a + b * c;
if (x > 0 && y < 10) { }

// No space before method parentheses
public void MethodName() { }

// Space after commas in method calls
Method(param1, param2, param3);

// Line breaks for long parameter lists
public void Method(
    string parameter1,
    int parameter2,
    bool parameter3)
{
    // Implementation
}
```

### Braces and Line Breaks

```csharp
// Always use braces, even for single statements
if (condition)
{
    DoSomething();
}

// Opening brace on same line for methods, classes, etc.
public class ClassName
{
    public void MethodName()
    {
        if (condition)
        {
            DoSomething();
        }
    }
}

// One statement per line
var customer = new Customer();
customer.Name = "John";
customer.Email = "john@example.com";

// NOT:
var customer = new Customer(); customer.Name = "John"; // Bad
```

## Modern C# Features

### Use Modern Language Features

```csharp
// File-scoped namespaces (C# 10+)
namespace MyProject.Application.Services;

// Primary constructors (C# 12+)
public class CustomerService(ICustomerRepository repository, ILogger<CustomerService> logger)
{
    private readonly ICustomerRepository _repository = repository;
    private readonly ILogger<CustomerService> _logger = logger;
}

// Expression-bodied members
public string FullName => $"{FirstName} {LastName}";
public int CalculateTotal() => Items.Sum(item => item.Price * item.Quantity);

// Pattern matching
string result = obj switch
{
    Customer customer => $"Customer: {customer.Name}",
    Order order => $"Order: {order.Id}",
    null => "Unknown",
    _ => "Other"
};

// Switch expressions
var status = order switch
{
    { IsPaid: true, IsShipped: false } => OrderStatus.Paid,
    { IsShipped: true } => OrderStatus.Shipped,
    _ => OrderStatus.Pending
};

// Null-coalescing operators
string name = customer?.Name ?? "Unknown";
int count = items?.Count ?? 0;

// Using declarations
using var scope = serviceProvider.CreateScope();
var service = scope.ServiceProvider.GetRequiredService<IMyService>();

// Records
public record Customer(int Id, string Name, string Email);
public record Order(int Id, DateTime OrderDate, Customer Customer);

// Init-only properties
public class Product
{
    public string Name { get; init; }
    public decimal Price { get; init; }
}
```

## Comments and Documentation

### XML Documentation

```csharp
/// <summary>
/// Creates a new customer with the specified details.
/// </summary>
/// <param name="name">The customer's full name. Must not be null or empty.</param>
/// <param name="email">The customer's email address. Must be a valid email format.</param>
/// <param name="cancellationToken">Cancellation token for the operation.</param>
/// <returns>The created customer with generated ID.</returns>
/// <exception cref="ArgumentException">Thrown when name is null or empty.</exception>
/// <exception cref="FormatException">Thrown when email is not a valid format.</exception>
/// <example>
/// <code>
/// var customer = await customerService.CreateCustomerAsync("John Doe", "john@example.com");
/// </code>
/// </example>
public async Task<Customer> CreateCustomerAsync(string name, string email, CancellationToken cancellationToken = default)
{
    // Implementation
}
```

### Inline Comments

```csharp
// Use comments to explain WHY, not WHAT
public void ProcessOrder(Order order)
{
    // Validate order before processing to prevent invalid data
    ValidateOrder(order);
    
    // Calculate total with tax for accurate billing
    var total = CalculateTotalWithTax(order);
    
    // Save order before sending notification to ensure data consistency
    await _repository.SaveAsync(order);
    
    // Send notification after successful save
    await _notificationService.NotifyCustomer(order);
}

// TODO: Add input validation for customer phone number
// FIXME: This method has performance issues with large datasets
// NOTE: This is a temporary solution until we implement the new payment system
```

## Error Handling

### Exception Handling Patterns

```csharp
// Use specific exceptions
throw new ArgumentException("Customer ID cannot be zero", nameof(customerId));
throw new InvalidOperationException("Order cannot be modified after shipping");

// Guard clauses
public void ProcessCustomer(Customer customer)
{
    ArgumentNullException.ThrowIfNull(customer);
    
    if (string.IsNullOrWhiteSpace(customer.Name))
        throw new ArgumentException("Customer name is required", nameof(customer));
        
    if (customer.Age < 18)
        throw new InvalidOperationException("Customer must be at least 18 years old");
        
    // Process customer
}

// Try-catch with specific exceptions
try
{
    await _orderService.ProcessOrderAsync(order);
}
catch (ValidationException ex)
{
    _logger.LogWarning(ex, "Order validation failed for order {OrderId}", order.Id);
    throw; // Re-throw to preserve stack trace
}
catch (Exception ex)
{
    _logger.LogError(ex, "Unexpected error processing order {OrderId}", order.Id);
    throw new OrderProcessingException("Failed to process order", ex);
}
```

## Async/Await Patterns

### Async Best Practices

```csharp
// Async method suffix
public async Task<Customer> GetCustomerAsync(int id) { }

// ConfigureAwait for library code
public async Task<string> GetDataAsync()
{
    var data = await _database.GetDataAsync().ConfigureAwait(false);
    return data;
}

// Don't use async void (except for event handlers)
public async void Button_Click(object sender, EventArgs e) // Event handler - OK
{
    try
    {
        await ProcessDataAsync();
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Button click failed");
    }
}

// Don't block on async code
public string GetData() // Bad
{
    return _service.GetDataAsync().Result; // Can cause deadlock
}

public async Task<string> GetDataAsync() // Good
{
    return await _service.GetDataAsync();
}
```

## LINQ Guidelines

### LINQ Best Practices

```csharp
// Use method syntax for complex queries
var customers = await _context.Customers
    .Where(c => c.IsActive && c.RegistrationDate >= startDate)
    .OrderBy(c => c.Name)
    .ThenBy(c => c.RegistrationDate)
    .Select(c => new CustomerDto
    {
        Id = c.Id,
        Name = c.Name,
        Email = c.Email,
        RegistrationDate = c.RegistrationDate
    })
    .ToListAsync();

// Use query syntax for simple queries
var activeCustomers = from c in _context.Customers
                     where c.IsActive
                     select c;

// Avoid materializing collections unnecessarily
// Bad:
var customerIds = customers.Select(c => c.Id).ToList();
var orders = _context.Orders.Where(o => customerIds.Contains(o.CustomerId)).ToList();

// Good:
var orders = await _context.Orders
    .Where(o => customers.Any(c => c.Id == o.CustomerId))
    .ToListAsync();
```

## Testing Standards

### Unit Testing Structure

```csharp
public class CustomerServiceTests
{
    private readonly Mock<ICustomerRepository> _repositoryMock;
    private readonly Mock<ILogger<CustomerService>> _loggerMock;
    private readonly CustomerService _service;

    public CustomerServiceTests()
    {
        _repositoryMock = new Mock<ICustomerRepository>();
        _loggerMock = new Mock<ILogger<CustomerService>>();
        _service = new CustomerService(_repositoryMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task CreateCustomer_ValidData_ReturnsCustomer()
    {
        // Arrange
        var request = new CreateCustomerRequest
        {
            Name = "John Doe",
            Email = "john@example.com"
        };

        var expectedCustomer = new Customer { Id = 1, Name = request.Name, Email = request.Email };
        _repositoryMock.Setup(r => r.AddAsync(It.IsAny<Customer>()))
                      .ReturnsAsync(expectedCustomer);

        // Act
        var result = await _service.CreateCustomerAsync(request);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(1);
        result.Name.Should().Be(request.Name);
        result.Email.Should().Be(request.Email);
        
        _repositoryMock.Verify(r => r.AddAsync(It.IsAny<Customer>()), Times.Once);
    }

    [Theory]
    [InlineData("")]
    [InlineData(" ")]
    [InlineData(null)]
    public async Task CreateCustomer_InvalidName_ThrowsArgumentException(string name)
    {
        // Arrange
        var request = new CreateCustomerRequest
        {
            Name = name,
            Email = "john@example.com"
        };

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(() => _service.CreateCustomerAsync(request));
    }
}
```

## Performance Guidelines

### Memory Management

```csharp
// Use using statements for IDisposable
using var scope = _serviceProvider.CreateScope();
var service = scope.ServiceProvider.GetRequiredService<IMyService>();

// Avoid memory leaks in events
public class EventPublisher : IDisposable
{
    private readonly List<EventHandler> _handlers = new();

    public event EventHandler SomethingHappened
    {
        add { _handlers.Add(value); }
        remove { _handlers.Remove(value); }
    }

    public void Dispose()
    {
        _handlers.Clear();
    }
}

// Use StringBuilder for string concatenation
var builder = new StringBuilder();
builder.Append("SELECT * FROM Customers WHERE ");
builder.Append("Name LIKE @Name AND ");
builder.Append("Email LIKE @Email");
var sql = builder.ToString();
```

## Security Guidelines

### Input Validation

```csharp
// Validate all inputs
public class CreateCustomerRequest
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    [StringLength(255, ErrorMessage = "Email cannot exceed 255 characters")]
    public string Email { get; set; } = string.Empty;
}

// SQL injection prevention
// Bad: string concatenation
var sql = $"SELECT * FROM Customers WHERE Name = '{name}'";

// Good: parameterized queries
var customers = await _context.Customers
    .Where(c => c.Name == name)
    .ToListAsync();
```

## Git Integration

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Examples:
```
feat(customers): add customer validation

- Add email validation using regex
- Implement name length validation
- Add unit tests for validation logic

Closes #123
```

## Tools and Configuration

### .editorconfig

```ini
# EditorConfig is awesome: https://EditorConfig.org

# top-most EditorConfig file
root = true

# All files
[*]
charset = utf-8
end_of_line = crlf
insert_final_newline = true
trim_trailing_whitespace = true

# C# files
[*.cs]
indent_style = space
indent_size = 4

# XML files
[*.{xml,xaml,csproj}]
indent_style = space
indent_size = 2
```

### .gitignore

```gitignore
# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
build/
bld/
[Bb]in/
[Oo]bj/

# Visual Studio cache files
.vs/
*.user
*.suo
*.userosscache
*.sln.docstates

# User-specific files
*.rsuser
*.suo
*.user
*.userosscache
*.sln.docstates

# Mono auto generated files
mono_crash.*

# Windows image file caches
Thumbs.db
ehthumbs.db

# Folder config file
Desktop.ini

# Recycle Bin used on file shares
$RECYCLE.BIN/

# Mac
.DS_Store
```

## References

- [Microsoft C# Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Framework Design Guidelines](https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/)
- [C# Best Practices](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)

---

**Follow these standards consistently to maintain high code quality across all projects.**
