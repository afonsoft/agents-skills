---
name: csharp-async-patterns
description: Master asynchronous programming in C# with proper async/await patterns, error handling, and performance optimization
---

# C# Async Patterns Skill

## When to Use This Skill

Use this skill when you need to:
- Implement async/await patterns correctly
- Handle asynchronous operations with proper error handling
- Optimize async code for performance
- Avoid common async programming pitfalls
- Design async APIs and services

## Prerequisites

- Understanding of C# async/await keywords
- Knowledge of Task and Task<T> types
- Familiarity with threading concepts
- Basic understanding of I/O operations

## Step-by-Step Workflows

### 1. Async Method Implementation

**Input**: Synchronous method that needs async conversion  
**Output**: Proper async implementation with error handling

```
Convert this synchronous method to async with proper patterns:

1. Identify I/O operations
2. Add async/await keywords
3. Handle exceptions properly
4. Consider cancellation tokens
5. Return appropriate Task types
```

### 2. Async API Design

**Input**: API requirements and data access patterns  
**Output**: Complete async API implementation

```
Design async APIs following these patterns:

1. Use async/await consistently
2. Implement proper error handling
3. Add cancellation support
4. ConfigureAwait appropriately
5. Document async behavior
```

### 3. Performance Optimization

**Input**: Async code with performance issues  
**Output**: Optimized async implementation

```
Optimize this async code for better performance:

1. Reduce unnecessary async calls
2. Use ConfigureAwait(false) in library code
3. Implement proper batching
4. Avoid async void methods
5. Use ValueTask where appropriate
```

## Core Async Patterns

### Basic Async/Await

```csharp
// Good async method
public async Task<string> GetDataAsync(int id)
{
    try
    {
        var data = await _database.GetDataAsync(id);
        return ProcessData(data);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to get data for ID: {Id}", id);
        throw;
    }
}

// Bad: async void (avoid in most cases)
public async void ProcessDataAsync() // Don't do this!
{
    var data = await _service.GetDataAsync();
    Process(data); // No error handling
}
```

### ConfigureAwait Guidelines

```csharp
// Library code - use ConfigureAwait(false)
public async Task<string> GetDataAsync()
{
    var data = await _database.GetDataAsync().ConfigureAwait(false);
    return data;
}

// Application code - can omit ConfigureAwait
public async Task<IActionResult> GetDataAsync(int id)
{
    var data = await _service.GetDataAsync(id);
    return Ok(data);
}
```

### Cancellation Token Support

```csharp
public async Task<List<Product>> GetProductsAsync(
    CancellationToken cancellationToken = default)
{
    var products = new List<Product>();
    
    await foreach (var product in _database.GetProductsStreamAsync(cancellationToken))
    {
        cancellationToken.ThrowIfCancellationRequested();
        products.Add(product);
    }
    
    return products;
}

// Usage with timeout
var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
try
{
    var products = await _service.GetProductsAsync(cts.Token);
}
catch (OperationCanceledException)
{
    _logger.LogInformation("Operation was cancelled");
}
```

## Advanced Patterns

### Async Streams (IAsyncEnumerable)

```csharp
public async IAsyncEnumerable<Product> GetProductsStreamAsync(
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    const int batchSize = 100;
    var offset = 0;
    
    while (true)
    {
        cancellationToken.ThrowIfCancellationRequested();
        
        var batch = await _database.GetBatchAsync(offset, batchSize, cancellationToken);
        if (batch.Count == 0)
            yield break;
            
        foreach (var product in batch)
        {
            yield return product;
        }
        
        offset += batchSize;
    }
}

// Consumption
await foreach (var product in _service.GetProductsStreamAsync())
{
    ProcessProduct(product);
}
```

### ValueTask for Performance

```csharp
// Use ValueTask for frequently called, fast async operations
public ValueTask<int> GetCountAsync()
{
    if (_cachedCount.HasValue)
        return new ValueTask<int>(_cachedCount.Value);
        
    return new ValueTask<int>(GetCountFromDatabaseAsync());
}

private async Task<int> GetCountFromDatabaseAsync()
{
    var count = await _database.GetCountAsync();
    _cachedCount = count;
    return count;
}
```

### Async Factory Pattern

```csharp
public static class ServiceFactory
{
    public static async Task<MyService> CreateAsync(
        IServiceProvider serviceProvider,
        CancellationToken cancellationToken = default)
    {
        var repository = serviceProvider.GetRequiredService<IRepository>();
        var logger = serviceProvider.GetRequiredService<ILogger<MyService>>();
        
        // Async initialization
        await repository.InitializeAsync(cancellationToken);
        
        return new MyService(repository, logger);
    }
}
```

## Error Handling Patterns

### Exception Propagation

```csharp
public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
{
    try
    {
        // Validate request
        await ValidateRequestAsync(request);
        
        // Create order
        var order = await _repository.CreateOrderAsync(request);
        
        // Notify
        await _notificationService.NotifyOrderCreated(order);
        
        return order;
    }
    catch (ValidationException ex)
    {
        _logger.LogWarning(ex, "Validation failed for order creation");
        throw; // Re-throw to preserve stack trace
    }
    catch (RepositoryException ex)
    {
        _logger.LogError(ex, "Repository error during order creation");
        throw new OrderCreationException("Failed to create order", ex);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Unexpected error during order creation");
        throw;
    }
}
```

### Retry Pattern

```csharp
public async Task<T> RetryAsync<T>(
    Func<Task<T>> operation,
    int maxRetries = 3,
    TimeSpan delay = default)
{
    if (delay == default)
        delay = TimeSpan.FromSeconds(1);
        
    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            return await operation();
        }
        catch (Exception ex) when (attempt < maxRetries && IsRetryable(ex))
        {
            _logger.LogWarning(ex, "Attempt {Attempt} failed, retrying in {Delay}ms", 
                attempt, delay.TotalMilliseconds);
                
            await Task.Delay(delay, CancellationToken.None);
            delay = TimeSpan.FromSeconds(delay.TotalSeconds * 2); // Exponential backoff
        }
    }
    
    // Final attempt without catching
    return await operation();
}

private bool IsRetryable(Exception exception)
{
    return exception is HttpRequestException ||
           exception is TimeoutException ||
           exception is OperationCanceledException == false;
}
```

## Performance Optimization

### Async Batching

```csharp
public async Task<List<Product>> GetProductsAsync(List<int> ids)
{
    const int batchSize = 10;
    var results = new List<Product>();
    
    for (int i = 0; i < ids.Count; i += batchSize)
    {
        var batch = ids.Skip(i).Take(batchSize).ToList();
        var batchResults = await Task.WhenAll(
            batch.Select(id => GetProductAsync(id)));
            
        results.AddRange(batchResults);
    }
    
    return results;
}

// Alternative: Concurrent processing
public async Task<List<Product>> GetProductsConcurrentAsync(List<int> ids)
{
    var semaphore = new SemaphoreSlim(Environment.ProcessorCount);
    var tasks = ids.Select(async id =>
    {
        await semaphore.WaitAsync();
        try
        {
            return await GetProductAsync(id);
        }
        finally
        {
            semaphore.Release();
        }
    });
    
    var results = await Task.WhenAll(tasks);
    return results.ToList();
}
```

### Async Lazy Loading

```csharp
public class OrderService
{
    private readonly Lazy<Task<IRepository>> _repositoryLazy;
    
    public OrderService(IServiceProvider serviceProvider)
    {
        _repositoryLazy = new Lazy<Task<IRepository>>(async () =>
        {
            var repository = serviceProvider.GetRequiredService<IRepository>();
            await repository.InitializeAsync();
            return repository;
        });
    }
    
    private async Task<IRepository> GetRepositoryAsync()
    {
        return await _repositoryLazy.Value;
    }
    
    public async Task<Order> GetOrderAsync(int id)
    {
        var repository = await GetRepositoryAsync();
        return await repository.GetOrderAsync(id);
    }
}
```

## Common Pitfalls and Solutions

### 1. Async Void Methods

```csharp
// Bad: async void
public async void Button_Click(object sender, EventArgs e)
{
    await DoSomethingAsync(); // No error handling
}

// Good: async Task with proper error handling
public async Task Button_ClickAsync(object sender, EventArgs e)
{
    try
    {
        await DoSomethingAsync();
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Button click failed");
        // Handle error appropriately
    }
}
```

### 2. Blocking Async Code

```csharp
// Bad: blocking on async code
public string GetData()
{
    return _service.GetDataAsync().Result; // Deadlock potential
}

// Good: make the method async
public async Task<string> GetDataAsync()
{
    return await _service.GetDataAsync();
}
```

### 3. Fire and Forget

```csharp
// Bad: fire and forget without error handling
public void ProcessData()
{
    _ = ProcessDataAsync(); // Errors are lost
}

// Good: proper fire and forget with error handling
public void ProcessData()
{
    _ = Task.Run(async () =>
    {
        try
        {
            await ProcessDataAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to process data");
        }
    });
}
```

## Testing Async Code

### Unit Testing with xUnit

```csharp
public class AsyncServiceTests
{
    [Fact]
    public async Task GetDataAsync_ValidId_ReturnsData()
    {
        // Arrange
        var mockRepository = new Mock<IRepository>();
        var expectedData = new Data { Id = 1 };
        mockRepository.Setup(r => r.GetDataAsync(1))
                    .ReturnsAsync(expectedData);
                    
        var service = new DataService(mockRepository.Object);
        
        // Act
        var result = await service.GetDataAsync(1);
        
        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(1);
    }
    
    [Fact]
    public async Task GetDataAsync_ThrowsException_ThrowsSameException()
    {
        // Arrange
        var mockRepository = new Mock<IRepository>();
        mockRepository.Setup(r => r.GetDataAsync(1))
                    .ThrowsAsync(new InvalidOperationException());
                    
        var service = new DataService(mockRepository.Object);
        
        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(
            () => service.GetDataAsync(1));
    }
}
```

## Best Practices Summary

### Do's
- ✅ Use async/await consistently
- ✅ Handle exceptions properly
- ✅ ConfigureAwait(false) in library code
- ✅ Support cancellation tokens
- ✅ Use ValueTask for frequently called operations
- ✅ Test async code thoroughly

### Don'ts
- ❌ Use async void methods (except event handlers)
- ❌ Block on async code with .Result or .Wait()
- ❌ Forget to handle exceptions
- ❌ Ignore cancellation tokens
- ❌ Mix synchronous and asynchronous code unnecessarily

## References

- [Async/Await Best Practices](https://docs.microsoft.com/en-us/archive/msdn-magazine/2013/march/async-await-best-practices-in-asynchronous-programming)
- [Task-based Asynchronous Pattern](https://docs.microsoft.com/en-us/dotnet/standard/asynchronous-programming-models/task-based-asynchronous-pattern-tap)
- [Async Streams](https://docs.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-8#async-streams)

---

**This skill provides comprehensive guidance for async programming in C#. Use it to write efficient, reliable, and maintainable asynchronous code.**
