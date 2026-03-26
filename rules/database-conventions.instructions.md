---
description: Database design conventions, naming standards, and Entity Framework Core best practices
applyTo:
  - "**/Context/**.cs"
  - "**/Entities/**.cs"
  - "**/Models/**.cs"
  - "**/Migrations/**.cs"
  - "**/Configurations/**.cs"
  - "**/*.edmx"
  - "**/*.dbml"
---

# Database Conventions

## Overview

This document defines the standards and conventions for database design, naming, Entity Framework Core implementation, and data access patterns to ensure consistency and maintainability across all database-related code.

## Naming Conventions

### Database Objects

#### Tables
- **Format**: `PascalCase` with plural nouns
- **Examples**: `Users`, `Products`, `Orders`, `OrderItems`, `UserRoles`
- **Prefixes**: Avoid prefixes like `tbl_` or `dbo_`

#### Columns
- **Format**: `PascalCase` for standard columns
- **Primary Keys**: `Id` (integer) or `[TableName]Id` for composite keys
- **Foreign Keys**: `[TableName]Id` (e.g., `UserId`, `ProductId`)
- **Boolean columns**: Prefix with `Is`, `Has`, `Can` (e.g., `IsActive`, `HasDiscount`)
- **Date columns**: Suffix with `At` or `Date` (e.g., `CreatedAt`, `BirthDate`)
- **Amount/Money columns**: Use `Amount`, `Price`, `Cost` with decimal precision

#### Schemas
- **Format**: `PascalCase`
- **Examples**: `dbo`, `app`, `audit`, `reporting`
- **Usage**: Separate concerns and permissions

#### Indexes
- **Format**: `IX_[TableName]_[ColumnName1]_[ColumnName2]`
- **Examples**: `IX_Users_Email`, `IX_Orders_CustomerId_OrderDate`
- **Unique indexes**: `UX_[TableName]_[ColumnName]`

#### Constraints
- **Primary Keys**: `PK_[TableName]`
- **Foreign Keys**: `FK_[TableName]_[ReferencedTable]`
- **Unique Constraints**: `UX_[TableName]_[ColumnName]`
- **Check Constraints**: `CK_[TableName]_[Condition]`

### Entity Framework Core Naming

#### Entity Classes
```csharp
// Good: PascalCase, singular
public class User { }
public class Product { }
public class OrderItem { }

// Bad: Plural entities
public class Users { } // Don't do this
```

#### Properties
```csharp
// Primary key
public int Id { get; set; } // Standard

// Foreign keys
public int UserId { get; set; } // Navigation property reference
public User User { get; set; } // Navigation property

// Boolean properties
public bool IsActive { get; set; }
public bool HasDiscount { get; set; }
public bool CanDelete { get; set; }

// Date properties
public DateTime CreatedAt { get; set; }
public DateTime? UpdatedAt { get; set; }
public DateTime BirthDate { get; set; }

// Money properties
public decimal Price { get; set; }
public decimal TotalAmount { get; set; }
public decimal DiscountAmount { get; set; }
```

#### DbSet Properties
```csharp
public class ApplicationDbContext : DbContext
{
    // Good: Plural DbSet names
    public DbSet<User> Users { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    // Bad: Singular DbSet names
    public DbSet<User> User { get; set; } // Don't do this
}
```

## Data Types

### SQL Server Data Types

#### Common Types
```sql
-- Primary keys
INT IDENTITY(1,1) NOT NULL    -- Standard primary key
BIGINT IDENTITY(1,1) NOT NULL -- For large tables

-- Strings
NVARCHAR(50) NOT NULL        -- Short text (names, codes)
NVARCHAR(255) NOT NULL       -- Medium text (emails, URLs)
NVARCHAR(MAX) NULL          -- Long text (descriptions, content)
VARCHAR(50) NOT NULL         -- ASCII-only text
CHAR(10) NOT NULL            -- Fixed-length text

-- Numbers
DECIMAL(18,2) NOT NULL       -- Money/amounts
DECIMAL(10,4) NOT NULL       -- Precise calculations
INT NOT NULL                 -- Whole numbers
BIGINT NOT NULL              -- Large whole numbers
FLOAT NOT NULL               -- Approximate numbers

-- Dates
DATETIME2 NOT NULL           -- General dates (recommended)
DATE NOT NULL                -- Date only
TIME NOT NULL                -- Time only
DATETIMEOFFSET NOT NULL      -- Timezone-aware dates

-- Boolean
BIT NOT NULL                 -- True/False values

-- Binary
VARBINARY(MAX) NULL          -- Large binary data (files, images)
UNIQUEIDENTIFIER NULL        -- GUIDs
```

#### Type Mapping Examples
```csharp
// Entity Framework Core property mappings
public class Product
{
    public int Id { get; set; }                    // INT IDENTITY
    public string Name { get; set; }                 // NVARCHAR(100)
    public string Description { get; set; }          // NVARCHAR(MAX)
    public decimal Price { get; set; }               // DECIMAL(18,2)
    public int StockQuantity { get; set; }           // INT
    public bool IsActive { get; set; }               // BIT
    public DateTime CreatedAt { get; set; }          // DATETIME2
    public Guid? CategoryId { get; set; }            // UNIQUEIDENTIFIER
}
```

## Entity Framework Core Configuration

### Model Configuration

#### Fluent API Configuration
```csharp
public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        // Primary key
        builder.HasKey(p => p.Id);

        // Property configurations
        builder.Property(p => p.Name)
               .IsRequired()
               .HasMaxLength(100)
               .IsUnicode(true);

        builder.Property(p => p.Price)
               .HasPrecision(18, 2)
               .IsRequired();

        builder.Property(p => p.Description)
               .HasMaxLength(2000)
               .IsUnicode(true);

        // Indexes
        builder.HasIndex(p => p.Name)
               .HasDatabaseName("IX_Product_Name");

        builder.HasIndex(p => new { p.CategoryId, p.IsActive })
               .HasDatabaseName("IX_Product_Category_Active");

        // Unique constraints
        builder.HasIndex(p => p.Sku)
               .IsUnique()
               .HasDatabaseName("UX_Product_Sku");

        // Default values
        builder.Property(p => p.CreatedAt)
               .HasDefaultValueSql("GETUTCDATE()");

        builder.Property(p => p.IsActive)
               .HasDefaultValue(true);

        // Relationships
        builder.HasOne(p => p.Category)
               .WithMany(c => c.Products)
               .HasForeignKey(p => p.CategoryId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
```

#### Data Annotations
```csharp
public class User
{
    [Key]
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string Name { get; set; }

    [Required]
    [EmailAddress]
    [StringLength(255)]
    public string Email { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal Balance { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public DateTime CreatedAt { get; set; }

    [NotMapped]
    public string FullName => $"{FirstName} {LastName}";
}
```

### Relationship Configuration

#### One-to-Many
```csharp
public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    
    // Navigation property
    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();
}

public class Order
{
    public int Id { get; set; }
    public DateTime OrderDate { get; set; }
    
    // Foreign key
    public int UserId { get; set; }
    
    // Navigation property
    public User User { get; set; }
}

// Configuration
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.HasOne(o => o.User)
               .WithMany(u => u.Orders)
               .HasForeignKey(o => o.UserId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
```

#### Many-to-Many
```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

public class Order
{
    public int Id { get; set; }
    public DateTime OrderDate { get; set; }
    
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    
    public Order Order { get; set; }
    public Product Product { get; set; }
}

// Configuration
public class OrderItemConfiguration : IEntityTypeConfiguration<OrderItem>
{
    public void Configure(EntityTypeBuilder<OrderItem> builder)
    {
        builder.HasKey(oi => oi.Id);

        builder.HasOne(oi => oi.Order)
               .WithMany(o => o.OrderItems)
               .HasForeignKey(oi => oi.OrderId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(oi => oi.Product)
               .WithMany(p => p.OrderItems)
               .HasForeignKey(oi => oi.ProductId)
               .OnDelete(DeleteBehavior.Restrict);

        // Composite unique index
        builder.HasIndex(oi => new { oi.OrderId, oi.ProductId })
               .IsUnique()
               .HasDatabaseName("UX_OrderItem_Order_Product");
    }
}
```

## Database Design Patterns

### Base Entity Pattern
```csharp
public abstract class BaseEntity
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public bool IsActive { get; set; } = true;
}

public class User : BaseEntity
{
    public string Name { get; set; }
    public string Email { get; set; }
}

// Configuration
public class BaseEntityConfiguration<T> : IEntityTypeConfiguration<T> where T : BaseEntity
{
    public void Configure(EntityTypeBuilder<T> builder)
    {
        builder.HasKey(e => e.Id);

        builder.Property(e => e.CreatedAt)
               .HasDefaultValueSql("GETUTCDATE()");

        builder.Property(e => e.IsActive)
               .HasDefaultValue(true);

        builder.Property(e => e.UpdatedAt)
               .ValueGeneratedOnAddOrUpdate()
               .HasDefaultValueSql("GETUTCDATE()");
    }
}
```

### Soft Delete Pattern
```csharp
public abstract class SoftDeletableEntity : BaseEntity
{
    public DateTime? DeletedAt { get; set; }
    public string DeletedBy { get; set; }
    public bool IsDeleted => DeletedAt.HasValue;
}

// Global query filter
public class ApplicationDbContext : DbContext
{
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>().HasQueryFilter(u => !u.IsDeleted);
        modelBuilder.Entity<Product>().HasQueryFilter(p => !p.IsDeleted);
    }
}

// Soft delete service
public class SoftDeleteService
{
    public async Task SoftDeleteAsync<T>(T entity, string deletedBy) where T : SoftDeletableEntity
    {
        entity.DeletedAt = DateTime.UtcNow;
        entity.DeletedBy = deletedBy;
        entity.IsActive = false;
    }
}
```

### Audit Trail Pattern
```csharp
public class AuditEntry
{
    public int Id { get; set; }
    public string TableName { get; set; }
    public string EntityId { get; set; }
    public string Operation { get; set; } // INSERT, UPDATE, DELETE
    public string OldValues { get; set; }
    public string NewValues { get; set; }
    public string ChangedColumns { get; set; }
    public string UserId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

// Audit interceptor
public class AuditInterceptor : SaveChangesInterceptor
{
    public override InterceptionResult<int> SavingChanges(DbContextEventData eventData, InterceptionResult<int> result)
    {
        var context = eventData.Context;
        
        foreach (var entry in context.ChangeTracker.Entries())
        {
            if (entry.Entity is BaseEntity entity)
            {
                if (entry.State == EntityState.Added)
                {
                    entity.CreatedAt = DateTime.UtcNow;
                }
                else if (entry.State == EntityState.Modified)
                {
                    entity.UpdatedAt = DateTime.UtcNow;
                }
            }
        }

        return base.SavingChanges(eventData, result);
    }
}
```

## Migration Best Practices

### Migration Structure
```csharp
public partial class AddProductTable : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Products",
            schema: "dbo",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false)
                    .Annotation("SqlServer:Identity", "1, 1"),
                Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                IsActive = table.Column<bool>(type: "bit", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                CategoryId = table.Column<int>(type: "int", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Products", x => x.Id);
                table.ForeignKey(
                    name: "FK_Products_Categories_CategoryId",
                    column: x => x.CategoryId,
                    principalTable: "Categories",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Restrict);
            });

        // Indexes
        migrationBuilder.CreateIndex(
            name: "IX_Products_Name",
            table: "Products",
            column: "Name");

        migrationBuilder.CreateIndex(
            name: "IX_Products_CategoryId",
            table: "Products",
            column: "CategoryId");

        // Unique index
        migrationBuilder.CreateIndex(
            name: "UX_Products_Sku",
            table: "Products",
            column: "Sku",
            unique: true);

        // Seed data
        migrationBuilder.Sql(@"
            INSERT INTO Products (Name, Description, Price, CreatedAt)
            VALUES 
            ('Laptop', 'High-performance laptop', 999.99, GETUTCDATE()),
            ('Mouse', 'Wireless optical mouse', 29.99, GETUTCDATE())
        ");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "Products",
            schema: "dbo");
    }
}
```

### Migration Naming
```bash
# Good migration names
AddProductTable
CreateUserAndRoleTables
AddIndexesToOrders
UpdateProductPricePrecision
AddSoftDeleteToUsers

# Bad migration names
Migration1
Update
Fix
Changes
```

### Data Seeding
```csharp
public class ApplicationDbContext : DbContext
{
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Seed data
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Electronics", CreatedAt = DateTime.UtcNow },
            new Category { Id = 2, Name = "Books", CreatedAt = DateTime.UtcNow },
            new Category { Id = 3, Name = "Clothing", CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<Product>().HasData(
            new Product { Id = 1, Name = "Laptop", CategoryId = 1, Price = 999.99m, CreatedAt = DateTime.UtcNow },
            new Product { Id = 2, Name = "Programming Book", CategoryId = 2, Price = 49.99m, CreatedAt = DateTime.UtcNow }
        );
    }
}
```

## Performance Optimization

### Indexing Strategy
```csharp
public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        // Primary key index (automatic)
        builder.HasKey(o => o.Id);

        // Foreign key indexes
        builder.HasIndex(o => o.CustomerId)
               .HasDatabaseName("IX_Orders_CustomerId");

        // Composite indexes for common queries
        builder.HasIndex(o => new { o.CustomerId, o.OrderDate })
               .HasDatabaseName("IX_Orders_Customer_OrderDate");

        builder.HasIndex(o => new { o.Status, o.OrderDate })
               .HasDatabaseName("IX_Orders_Status_OrderDate");

        // Unique indexes
        builder.HasIndex(o => o.OrderNumber)
               .IsUnique()
               .HasDatabaseName("UX_Orders_OrderNumber");

        // Full-text search indexes
        builder.HasIndex(o => o.CustomerNotes)
               .HasMethod("FULLTEXT")
               .HasDatabaseName("IX_Orders_CustomerNotes_FullText");
    }
}
```

### Query Optimization
```csharp
public class OrderRepository
{
    // Good: Use AsNoTracking for read-only queries
    public async Task<List<Order>> GetOrdersAsync(int customerId)
    {
        return await _context.Orders
            .AsNoTracking()
            .Where(o => o.CustomerId == customerId)
            .OrderByDescending(o => o.OrderDate)
            .ToListAsync();
    }

    // Good: Use projection for specific data
    public async Task<List<OrderSummaryDto>> GetOrderSummariesAsync(int customerId)
    {
        return await _context.Orders
            .AsNoTracking()
            .Where(o => o.CustomerId == customerId)
            .Select(o => new OrderSummaryDto
            {
                Id = o.Id,
                OrderNumber = o.OrderNumber,
                OrderDate = o.OrderDate,
                TotalAmount = o.OrderItems.Sum(oi => oi.Quantity * oi.UnitPrice),
                Status = o.Status
            })
            .ToListAsync();
    }

    // Good: Use split queries for complex includes
    public async Task<List<Order>> GetOrdersWithDetailsAsync(int customerId)
    {
        return await _context.Orders
            .AsNoTracking()
            .Include(o => o.Customer)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
            .AsSplitQuery()
            .Where(o => o.CustomerId == customerId)
            .ToListAsync();
    }
}
```

## Security Best Practices

### Connection String Security
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyApp;User Id=myapp_user;Password=secure_password;TrustServerCertificate=false;Encrypt=true;"
  }
}
```

### SQL Injection Prevention
```csharp
// Good: Use parameterized queries
var users = await _context.Users
    .FromSqlInterpolated($"SELECT * FROM Users WHERE Email = {email}")
    .ToListAsync();

// Good: Use LINQ
var users = await _context.Users
    .Where(u => u.Email == email)
    .ToListAsync();

// Bad: String concatenation (SQL injection risk)
var sql = $"SELECT * FROM Users WHERE Email = '{email}'"; // Don't do this
```

### Data Encryption
```csharp
public class User
{
    public int Id { get; set; }
    
    [Required]
    [Encrypted] // Custom attribute for encryption
    public string Email { get; set; }
    
    [Required]
    [Encrypted]
    public string PhoneNumber { get; set; }
    
    // Non-sensitive data
    public string Name { get; set; }
}
```

## Testing Database Operations

### In-Memory Database Testing
```csharp
public class UserRepositoryTests
{
    private readonly ApplicationDbContext _context;
    private readonly UserRepository _repository;

    public UserRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _repository = new UserRepository(_context);
    }

    [Fact]
    public async Task AddUser_ValidUser_ReturnsUserWithId()
    {
        // Arrange
        var user = new User
        {
            Name = "John Doe",
            Email = "john@example.com"
        };

        // Act
        var result = await _repository.AddAsync(user);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().BeGreaterThan(0);
        result.Name.Should().Be("John Doe");
        result.Email.Should().Be("john@example.com");
    }
}
```

### Integration Testing
```csharp
public class DatabaseIntegrationTests : IClassFixture<SqliteDatabaseFixture>
{
    private readonly SqliteDatabaseFixture _fixture;

    public DatabaseIntegrationTests(SqliteDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task UserRepository_ConcurrentUpdates_HandlesConcurrency()
    {
        // Arrange
        var user = new User { Name = "John Doe", Email = "john@example.com" };
        await _fixture.Context.Users.AddAsync(user);
        await _fixture.Context.SaveChangesAsync();

        var user1 = await _fixture.Context.Users.FindAsync(user.Id);
        var user2 = await _fixture.Context.Users.FindAsync(user.Id);

        // Act
        user1.Name = "Jane Doe";
        await _fixture.Context.SaveChangesAsync();

        user2.Email = "jane@example.com";
        
        // Assert
        await Assert.ThrowsAsync<DbUpdateConcurrencyException>(
            () => _fixture.Context.SaveChangesAsync());
    }
}
```

## Best Practices Summary

### Do's
- ✅ Use consistent naming conventions
- ✅ Implement proper indexing strategy
- ✅ Use parameterized queries
- ✅ Implement soft delete where appropriate
- ✅ Add audit trails for sensitive data
- ✅ Use migrations for schema changes
- ✅ Test database operations
- ✅ Optimize queries with AsNoTracking and projections
- ✅ Implement proper error handling
- ✅ Use connection pooling

### Don'ts
- ❌ Use reserved words for object names
- ❌ Ignore indexing for frequently queried columns
- ❌ Use string concatenation for SQL queries
- ❌ Store sensitive data in plain text
- ❌ Forget to handle concurrency conflicts
- ❌ Skip database testing
- ❌ Use SELECT * in production code
- ❌ Ignore connection string security
- ❌ Forget to dispose DbContext properly
- ❌ Use synchronous database operations

## References

- [Entity Framework Core Documentation](https://docs.microsoft.com/en-us/ef/core/)
- [SQL Server Naming Conventions](https://docs.microsoft.com/en-us/sql/relational-databases/naming-conventions)
- [Database Design Best Practices](https://docs.microsoft.com/en-us/sql/relational-databases/database-design)
- [EF Core Performance Best Practices](https://docs.microsoft.com/en-us/ef/core/performance/)

---

**Follow these conventions to maintain consistent, secure, and performant database implementations.**
