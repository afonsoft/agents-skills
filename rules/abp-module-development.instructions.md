---
description: 'ABP module development best practices for reusable modules including virtual methods, database independence, extensibility, configuration options, and testing'
applyTo: '**/*Module.cs,**/I*Repository.cs,**/I*AppService.cs,**/I*Service.cs,**/ModuleOptions.cs,**/*ExtensionConfigurator.cs'
---

# ABP Module Development

## Module Development Overview

This rule establishes best practices for developing reusable ABP modules that can be distributed and consumed by other solutions. The key principle is **extensibility** - module consumers must be able to override and customize behavior.

## Core Requirements

### 1. Virtual Methods (Critical for Reusability)
**Rule**: All public and protected methods in reusable modules must be `virtual`

```csharp
// ✅ Correct - All public methods are virtual
public class BookAppService : ApplicationService, IBookAppService
{
    public virtual async Task<BookDto> CreateAsync(CreateBookDto input)
    {
        var book = await CreateBookEntityAsync(input);
        await _bookRepository.InsertAsync(book);
        return ObjectMapper.Map<BookDto>(book);
    }

    // ✅ Use protected virtual for helper methods
    protected virtual Task<Book> CreateBookEntityAsync(CreateBookDto input)
    {
        return Task.FromResult(new Book(
            GuidGenerator.Create(),
            input.Name,
            input.Price
        ));
    }
}

// ❌ Wrong - Private methods cannot be overridden
public class BookAppService : ApplicationService, IBookAppService
{
    public async Task<BookDto> CreateAsync(CreateBookDto input) // Not virtual
    {
        var book = CreateBookEntity(input); // Private helper
        await _bookRepository.InsertAsync(book);
        return ObjectMapper.Map<BookDto>(book);
    }

    private Book CreateBookEntity(CreateBookDto input) // Cannot be overridden
    {
        return new Book(GuidGenerator.Create(), input.Name, input.Price);
    }
}
```

### 2. Database Independence
**Rule**: Support both EF Core and MongoDB with separate implementations

```csharp
// ✅ Correct - Database-agnostic repository interface
public interface IBookRepository : IRepository<Book, Guid>
{
    Task<Book> FindByNameAsync(string name);
    Task<List<Book>> GetBooksByAuthorAsync(Guid authorId);
}

// ✅ Correct - EF Core implementation
public class EfCoreBookRepository : EfCoreRepository<MyModuleDbContext, Book, Guid>, IBookRepository
{
    public async Task<Book> FindByNameAsync(string name)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.FirstOrDefaultAsync(b => b.Name == name);
    }

    public async Task<List<Book>> GetBooksByAuthorAsync(Guid authorId)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.Where(b => b.AuthorId == authorId).ToListAsync();
    }
}

// ✅ Correct - MongoDB implementation
public class MongoBookRepository : MongoDbRepository<MyModuleMongoDbContext, Book, Guid>, IBookRepository
{
    public async Task<Book> FindByNameAsync(string name)
    {
        var queryable = await GetQueryableAsync();
        return await queryable.FirstOrDefaultAsync(b => b.Name == name);
    }

    public async Task<List<Book>> GetBooksByAuthorAsync(Guid authorId)
    {
        var queryable = await GetQueryableAsync();
        return await queryable.Where(b => b.AuthorId == authorId).ToListAsync();
    }
}
```

### 3. Table/Collection Prefix Configuration
**Rule**: Allow customization of table/collection names to avoid conflicts

```csharp
// ✅ Correct - Configurable table prefix
public static class MyModuleDbProperties
{
    public static string DbTablePrefix { get; set; } = "MyModule";
    public static string DbSchema { get; set; } = null;
    public const string ConnectionStringName = "MyModule";
}

// Usage in EF Core configuration
builder.Entity<Book>(b =>
{
    b.ToTable(MyModuleDbProperties.DbTablePrefix + "Books", MyModuleDbProperties.DbSchema);
});

// Usage in MongoDB configuration
BsonClassMap.RegisterClassMap<Book>(cm =>
{
    cm.AutoMap();
    cm.SetCollectionName(MyModuleDbProperties.DbTablePrefix + "Books");
});
```

### 4. Module Options Pattern
**Rule**: Provide configuration options for customization

```csharp
// ✅ Correct - Options class
public class MyModuleOptions
{
    public bool EnableFeatureX { get; set; } = true;
    public int MaxItemCount { get; set; } = 100;
    public string CustomSetting { get; set; } = "Default";
}

// Configuration in module
public override void ConfigureServices(ServiceConfigurationContext context)
{
    Configure<MyModuleOptions>(options =>
    {
        options.EnableFeatureX = true;
        options.MaxItemCount = 100;
    });
}

// Usage in services
public class MyService : ITransientDependency
{
    private readonly MyModuleOptions _options;

    public MyService(IOptions<MyModuleOptions> options)
    {
        _options = options.Value;
    }

    public async Task<List<Book>> GetBooksAsync()
    {
        var maxItems = _options.MaxItemCount;
        return await _bookRepository.GetListAsync(maxItems);
    }
}
```

### 5. Entity Extension Support
**Rule**: Support object extension system for extensibility

```csharp
// ✅ Correct - Extension configurator
public static class MyModuleExtensionConfigurator
{
    private static readonly OneTimeRunner OneTimeRunner = new OneTimeRunner();

    public static void Configure()
    {
        OneTimeRunner.Run(() =>
        {
            ObjectExtensionManager.Instance.Modules()
                .ConfigureMyModule(module =>
                {
                    module.ConfigureBook(book =>
                    {
                        book.AddOrUpdateProperty<string>("CustomProperty");
                        book.AddOrUpdateProperty<int>("CustomRating");
                    });
                });
        });
    }
}

// Call in module initialization
public override void PreConfigureServices(ServiceConfigurationContext context)
{
    MyModuleExtensionConfigurator.Configure();
}

// Usage in entities
public class Book : FullAuditedAggregateRoot<Guid>, IHasExtraProperties
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    
    public string GetCustomProperty()
    {
        return this.GetExtraProperty<string>("CustomProperty");
    }
    
    public void SetCustomProperty(string value)
    {
        this.SetExtraProperty("CustomProperty", value);
    }
}
```

### 6. Localization Configuration
**Rule**: Proper localization setup with virtual JSON support

```csharp
// ✅ Correct - Localization resource
[LocalizationResourceName("MyModule")]
public class MyModuleResource
{
}

// Configuration in module
public override void ConfigureServices(ServiceConfigurationContext context)
{
    Configure<AbpLocalizationOptions>(options =>
    {
        options.Resources
            .Add<MyModuleResource>("en")
            .AddVirtualJson("/Localization/MyModule");
    });
}

// Localization files structure
// MyModule.Domain.Shared/Localization/MyModule/en.json
// MyModule.Domain.Shared/Localization/MyModule/pt-BR.json
```

### 7. Permission Definition
**Rule**: Define permissions with proper grouping and localization

```csharp
// ✅ Correct - Permission constants
public static class MyModulePermissions
{
    public const string GroupName = "MyModule";

    public static class Books
    {
        public const string Default = GroupName + ".Books";
        public const string Create = Default + ".Create";
        public const string Edit = Default + ".Edit";
        public const string Delete = Default + ".Delete";
    }
}

// Permission definition provider
public class MyModulePermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(
            MyModulePermissions.GroupName,
            L("Permission:MyModule")
        );

        var booksPermission = myGroup.AddPermission(
            MyModulePermissions.Books.Default,
            L("Permission:Books")
        );

        booksPermission.AddChild(
            MyModulePermissions.Books.Create,
            L("Permission:Books.Create")
        );
    }
}
```

## Module Structure Requirements

### Standard Module Structure
```
MyModule/
├── src/
│   ├── MyModule.Domain.Shared/      # Constants, enums, localization
│   ├── MyModule.Domain/             # Entities, repository interfaces, domain services
│   ├── MyModule.Application.Contracts/ # DTOs, service interfaces
│   ├── MyModule.Application/        # Service implementations
│   ├── MyModule.EntityFrameworkCore/ # EF Core implementation
│   ├── MyModule.MongoDB/            # MongoDB implementation
│   ├── MyModule.HttpApi/            # REST controllers
│   ├── MyModule.HttpApi.Client/     # Client proxies
│   ├── MyModule.Web/                # MVC/Razor Pages UI
│   └── MyModule.Blazor/             # Blazor UI
├── test/
│   └── MyModule.Tests/
└── host/
    └── MyModule.HttpApi.Host/       # Test host application
```

### Module Dependencies
```csharp
// ✅ Correct - Proper module dependencies
[DependsOn(
    typeof(AbpDddDomainModule),
    typeof(AbpDddApplicationModule),
    typeof(AbpEntityFrameworkCoreModule),
    typeof(AbpAspNetCoreMvcModule),
    typeof(AbpAutofacModule)
)]
public class MyModuleModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Module configuration
    }
}
```

## Testing Requirements

### Test Host Application
**Rule**: Include a test host application for module validation

```csharp
// ✅ Correct - Test host module
[DependsOn(
    typeof(MyModuleEntityFrameworkCoreModule),
    typeof(MyModuleApplicationModule),
    typeof(AbpAspNetCoreMvcModule),
    typeof(AbpAutofacModule)
)]
public class MyModuleTestHostModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        Configure<AbpDbContextOptions>(options =>
        {
            options.UseSqlServer();
        });
    }

    public override void OnApplicationInitialization(ApplicationInitializationContext context)
    {
        // Test-specific configuration
    }
}
```

### Integration Tests
```csharp
// ✅ Correct - Module integration tests
public class MyModuleIntegrationTests : MyModuleTestBase
{
    [Fact]
    public async Task Should_Create_Book()
    {
        // Arrange
        var bookAppService = GetRequiredService<IBookAppService>();
        var input = new CreateBookDto { Name = "Test Book", Price = 19.99m };

        // Act
        var result = await bookAppService.CreateAsync(input);

        // Assert
        result.ShouldNotBeNull();
        result.Name.ShouldBe("Test Book");
    }
}
```

## Validation Rules

### Required Checks
- [ ] All public methods in reusable modules are `virtual`
- [ ] All protected helper methods are `virtual`
- [ ] Database-agnostic repository interfaces
- [ ] Configurable table/collection prefix
- [ ] Module options pattern implemented
- [ ] Entity extension support configured
- [ ] Proper localization setup
- [ ] Permission definitions with grouping
- [ ] Test host application included
- [ ] Integration tests written

### Extensibility Validation
- [ ] Consumers can override public methods
- [ ] Custom repositories can be injected
- [ ] Module options can be configured
- [ ] Entities can be extended
- [ ] Permissions can be customized
- [ ] Localization can be overridden

### Performance Considerations
- [ ] No database-specific code in domain layer
- [ ] Proper dependency injection patterns
- [ ] Efficient query implementations
- [ ] Minimal module dependencies

## Common Anti-Patterns

### 1. Non-Virtual Methods
```csharp
// ❌ Wrong - Cannot be overridden by consumers
public class BookAppService : ApplicationService
{
    public async Task<BookDto> CreateAsync(CreateBookDto input) // Not virtual
    {
        // Implementation
    }
}
```

### 2. Hardcoded Configuration
```csharp
// ❌ Wrong - Not configurable
public class BookService
{
    private const int MaxBooks = 100; // Hardcoded
}
```

### 3. Database-Specific Code in Domain
```csharp
// ❌ Wrong - EF Core specific in domain layer
public class BookRepository : IRepository<Book, Guid>
{
    private readonly MyDbContext _context; // Don't reference EF Core in domain
}
```

### 4. Missing Extension Support
```csharp
// ❌ Wrong - No extensibility
public class Book : FullAuditedAggregateRoot<Guid>
{
    public string Name { get; set; }
    // No extension properties support
}
```

## Migration Guidelines

When migrating existing code to module patterns:

1. **Make Methods Virtual**: Add `virtual` to all public/protected methods
2. **Extract Interfaces**: Define repository interfaces for custom queries
3. **Add Configuration**: Implement options pattern for customization
4. **Setup Extensions**: Configure object extension system
5. **Write Tests**: Create integration tests with test host
6. **Document Usage**: Provide consumer documentation

This rule ensures that ABP modules are properly designed for reusability, extensibility, and maintainability across different consumer applications.
