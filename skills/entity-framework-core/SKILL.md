---
name: entity-framework-core
description: Master Entity Framework Core with best practices, performance optimization, and proper data access patterns
---

# Entity Framework Core Skill

## When to Use This Skill

Use this skill when you need to:
- Design EF Core models and relationships
- Optimize database queries for performance
- Implement proper data access patterns
- Handle migrations and database updates
- Troubleshoot EF Core performance issues

## Prerequisites

- Understanding of relational database concepts
- Knowledge of C# and LINQ
- Familiarity with EF Core basics
- Basic understanding of database design

## Step-by-Step Workflows

### 1. Model Design and Relationships

**Input**: Entity requirements and business rules  
**Output**: Complete EF Core model with proper relationships

```
Design EF Core models with these requirements:

1. Define entities and properties
2. Configure relationships (one-to-many, many-to-many)
3. Set up primary and foreign keys
4. Add indexes for performance
5. Configure data annotations and fluent API
```

### 2. Query Optimization

**Input**: Slow EF Core queries or performance issues  
**Output**: Optimized queries with better performance

```
Optimize these EF Core queries for better performance:

1. Identify N+1 query problems
2. Add proper includes and projections
3. Use AsNoTracking for read-only operations
4. Implement proper indexing
5. Optimize LINQ expressions
```

### 3. Migration Management

**Input**: Database schema changes  
**Output**: Proper migrations with data preservation

```
Create EF Core migrations for these schema changes:

1. Generate migration files
2. Review migration code
3. Handle data transformations
4. Test migrations safely
5. Deploy with rollback strategy
```

## Core EF Core Patterns

### Model Configuration

```csharp
// Entity with data annotations
public class Customer
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [EmailAddress]
    public string? Email { get; set; }
    
    [Column(TypeName = "decimal(18,2)")]
    public decimal Balance { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
}

// Fluent API configuration
public class CustomerConfiguration : IEntityTypeConfiguration<Customer>
{
    public void Configure(EntityTypeBuilder<Customer> builder)
    {
        builder.HasKey(c => c.Id);
        
        builder.Property(c => c.Name)
               .IsRequired()
               .HasMaxLength(100);
               
        builder.Property(c => c.Email)
               .HasMaxLength(255);
               
        builder.Property(c => c.Balance)
               .HasPrecision(18, 2);
               
        builder.HasIndex(c => c.Email)
               .IsUnique()
               .HasDatabaseName("IX_Customer_Email");
               
        builder.Property(c => c.CreatedAt)
               .HasDefaultValueSql("GETUTCDATE()");
    }
}
```

### Relationships

```csharp
// One-to-many relationship
public class Order
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    
    // Foreign key
    public int CustomerId { get; set; }
    
    // Navigation properties
    public Customer Customer { get; set; } = null!;
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

// Many-to-many relationship (EF Core 5+)
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    
    public Order Order { get; set; } = null!;
    public Product Product { get; set; } = null!;
}

// Configuration
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.HasKey(o => o.Id);
        
        builder.Property(o => o.OrderNumber)
               .IsRequired()
               .HasMaxLength(50);
               
        builder.HasOne(o => o.Customer)
               .WithMany(c => c.Orders)
               .HasForeignKey(o => o.CustomerId)
               .OnDelete(DeleteBehavior.Restrict);
               
        builder.HasIndex(o => o.OrderNumber)
               .IsUnique();
    }
}
```

## Query Optimization

### Eager Loading

```csharp
// Good: Use Include for related data
var orders = await _context.Orders
    .Include(o => o.Customer)
    .Include(o => o.OrderItems)
        .ThenInclude(oi => oi.Product)
    .Where(o => o.CustomerId == customerId)
    .ToListAsync();

// Better: Use Select for specific data
var orderDtos = await _context.Orders
    .Where(o => o.CustomerId == customerId)
    .Select(o => new OrderDto
    {
        Id = o.Id,
        OrderNumber = o.OrderNumber,
        OrderDate = o.OrderDate,
        CustomerName = o.Customer.Name,
        CustomerEmail = o.Customer.Email,
        Items = o.OrderItems.Select(oi => new OrderItemDto
        {
            ProductName = oi.Product.Name,
            Quantity = oi.Quantity,
            UnitPrice = oi.UnitPrice,
            TotalPrice = oi.Quantity * oi.UnitPrice
        }).ToList()
    })
    .ToListAsync();
```

### AsNoTracking

```csharp
// Read-only queries - use AsNoTracking
var customers = await _context.Customers
    .AsNoTracking()
    .Where(c => c.IsActive)
    .ToListAsync();

// For large datasets, use AsNoTrackingWithIdentityResolution
var customers = await _context.Customers
    .AsNoTrackingWithIdentityResolution()
    .Where(c => c.IsActive)
    .ToListAsync();
```

### Split Queries

```csharp
// For complex queries with multiple includes
var orders = await _context.Orders
    .Include(o => o.Customer)
    .Include(o => o.OrderItems)
        .ThenInclude(oi => oi.Product)
    .AsSplitQuery() // Split into separate SQL queries
    .Where(o => o.OrderDate >= startDate)
    .ToListAsync();
```

### Raw SQL Queries

```csharp
// For complex queries that can't be expressed in LINQ
var orders = await _context.Orders
    .FromSqlInterpolated($@"
        SELECT * FROM Orders 
        WHERE CustomerId = {customerId} 
        AND OrderDate >= {startDate}
        ORDER BY OrderDate DESC")
    .Include(o => o.Customer)
    .ToListAsync();

// Parameterized queries
var orders = await _context.Orders
    .FromSqlRaw("EXEC GetCustomerOrders @CustomerId, @StartDate", 
        customerId, startDate)
    .ToListAsync();
```

## Performance Optimization

### Indexing Strategy

```csharp
public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        // Primary key index (automatic)
        builder.HasKey(p => p.Id);
        
        // Unique index for product SKU
        builder.HasIndex(p => p.Sku)
               .IsUnique()
               .HasDatabaseName("IX_Product_Sku");
               
        // Composite index for search
        builder.HasIndex(p => new { p.CategoryId, p.IsActive })
               .HasDatabaseName("IX_Product_Category_Active");
               
        // Full-text search index
        builder.HasIndex(p => p.Name)
               .HasMethod("FULLTEXT")
               .HasDatabaseName("IX_Product_Name_FullText");
    }
}
```

### Query Batching

```csharp
// EF Core automatically batches multiple queries
public async Task<CustomerDashboardDto> GetCustomerDashboardAsync(int customerId)
{
    var tasks = new[]
    {
        GetCustomerInfoAsync(customerId),
        GetRecentOrdersAsync(customerId),
        GetOrderStatisticsAsync(customerId)
    };
    
    var results = await Task.WhenAll(tasks);
    
    return new CustomerDashboardDto
    {
        Customer = results[0],
        RecentOrders = results[1],
        Statistics = results[2]
    };
}

private async Task<Customer> GetCustomerInfoAsync(int customerId)
{
    return await _context.Customers
        .AsNoTracking()
        .FirstOrDefaultAsync(c => c.Id == customerId);
}
```

### Connection Resiliency

```csharp
// Configure in DbContext
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder.UseSqlServer(
        connectionString,
        options => options
            .EnableRetryOnFailure(
                maxRetryCount: 3,
                maxRetryDelay: TimeSpan.FromSeconds(30),
                errorNumbersToAdd: null)
            .CommandTimeout(30));
}
```

## Repository Pattern

```csharp
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<T>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<T>> FindAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken = default);
    Task<T> AddAsync(T entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(T entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(T entity, CancellationToken cancellationToken = default);
}

public class Repository<T> : IRepository<T> where T : class
{
    protected readonly DbContext _context;
    protected readonly DbSet<T> _dbSet;
    
    public Repository(DbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }
    
    public virtual async Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id }, cancellationToken);
    }
    
    public virtual async Task<IReadOnlyList<T>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.AsNoTracking().ToListAsync(cancellationToken);
    }
    
    public virtual async Task<IReadOnlyList<T>> FindAsync(
        Expression<Func<T, bool>> predicate, 
        CancellationToken cancellationToken = default)
    {
        return await _dbSet.AsNoTracking()
            .Where(predicate)
            .ToListAsync(cancellationToken);
    }
    
    public virtual async Task<T> AddAsync(T entity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return entity;
    }
    
    public virtual async Task UpdateAsync(T entity, CancellationToken cancellationToken = default)
    {
        _dbSet.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
    
    public virtual async Task DeleteAsync(T entity, CancellationToken cancellationToken = default)
    {
        _dbSet.Remove(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
```

## Unit of Work Pattern

```csharp
public interface IUnitOfWork : IDisposable
{
    IRepository<Customer> Customers { get; }
    IRepository<Order> Orders { get; }
    IRepository<Product> Products { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync(CancellationToken cancellationToken = default);
    Task CommitTransactionAsync(CancellationToken cancellationToken = default);
    Task RollbackTransactionAsync(CancellationToken cancellationToken = default);
}

public class UnitOfWork : IUnitOfWork
{
    private readonly DbContext _context;
    private IDbContextTransaction? _transaction;
    
    public UnitOfWork(DbContext context)
    {
        _context = context;
        Customers = new Repository<Customer>(_context);
        Orders = new Repository<Order>(_context);
        Products = new Repository<Product>(_context);
    }
    
    public IRepository<Customer> Customers { get; }
    public IRepository<Order> Orders { get; }
    public IRepository<Product> Products { get; }
    
    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }
    
    public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
    {
        _transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
    }
    
    public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }
    
    public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }
    
    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
```

## Migration Best Practices

### Migration Generation

```bash
# Add migration
dotnet ef migrations add AddCustomerTable --project MyProject.Data --startup-project MyProject.API

# Generate script
dotnet ef migrations script --project MyProject.Data --startup-project MyProject.API

# Update database
dotnet ef database update --project MyProject.Data --startup-project MyProject.API
```

### Custom Migration Logic

```csharp
public partial class AddCustomerData : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Customers",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false)
                    .Annotation("SqlServer:Identity", "1, 1"),
                Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Customers", x => x.Id);
                table.UniqueConstraint("UK_Customers_Email", x => x.Email);
            });
            
        migrationBuilder.CreateIndex(
            name: "IX_Customers_Email",
            table: "Customers",
            column: "Email",
            unique: true);
            
        // Seed data
        migrationBuilder.Sql(@"
            INSERT INTO Customers (Name, Email, CreatedAt) VALUES
            ('John Doe', 'john@example.com', GETUTCDATE()),
            ('Jane Smith', 'jane@example.com', GETUTCDATE())
        ");
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "Customers");
    }
}
```

## Testing EF Core

### In-Memory Database

```csharp
public class OrderServiceTests
{
    private readonly DbContextOptions<ApplicationDbContext> _options;
    
    public OrderServiceTests()
    {
        _options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
    }
    
    [Fact]
    public async Task CreateOrder_ValidOrder_ReturnsOrderId()
    {
        // Arrange
        await using var context = new ApplicationDbContext(_options);
        
        var customer = new Customer { Name = "John Doe", Email = "john@example.com" };
        context.Customers.Add(customer);
        await context.SaveChangesAsync();
        
        var service = new OrderService(context);
        
        // Act
        var orderId = await service.CreateOrderAsync(new CreateOrderRequest
        {
            CustomerId = customer.Id,
            Items = new List<OrderItemRequest>
            {
                new() { ProductId = 1, Quantity = 2 }
            }
        });
        
        // Assert
        orderId.Should().BeGreaterThan(0);
        
        var order = await context.Orders.FindAsync(orderId);
        order.Should().NotBeNull();
        order.CustomerId.Should().Be(customer.Id);
    }
}
```

## Common Pitfalls and Solutions

### 1. N+1 Query Problem

```csharp
// Bad: N+1 queries
var orders = await _context.Orders.ToListAsync();
foreach (var order in orders)
{
    var customer = await _context.Customers.FindAsync(order.CustomerId); // N+1!
}

// Good: Eager loading
var orders = await _context.Orders
    .Include(o => o.Customer)
    .ToListAsync();
```

### 2. Tracking Unnecessary Entities

```csharp
// Bad: Tracking read-only data
var customers = await _context.Customers.ToListAsync();

// Good: AsNoTracking for read-only
var customers = await _context.Customers
    .AsNoTracking()
    .ToListAsync();
```

### 3. Large Result Sets

```csharp
// Bad: Loading all data
var allProducts = await _context.Products.ToListAsync();

// Good: Pagination
var products = await _context.Products
    .Skip(page * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

## Performance Monitoring

```csharp
// Enable sensitive data logging in development
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(connectionString)
               .EnableSensitiveDataLogging()
               .EnableDetailedErrors()
               .LogTo(Console.WriteLine, LogLevel.Information));
}

// Query logging
public class ApplicationDbContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
    }
}
```

## References

- [EF Core Documentation](https://docs.microsoft.com/en-us/ef/core/)
- [Performance Best Practices](https://docs.microsoft.com/en-us/ef/core/performance/)
- [Modeling Relationships](https://docs.microsoft.com/en-us/ef/core/modeling/relationships)

---

**This skill provides comprehensive guidance for Entity Framework Core development. Use it to build efficient, maintainable, and performant data access layers.**
