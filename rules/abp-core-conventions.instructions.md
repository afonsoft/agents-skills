---
description: 'ABP Framework core conventions and best practices for module system, dependency injection, base classes, time handling, business exceptions, and localization'
applyTo: '**/*.cs,**/Program.cs,**/appsettings.json,**/*.csproj,**/MyProjectModule.cs,**/MyProjectAbpModule.cs'
---

# ABP Core Conventions

## Framework Overview

ABP Framework provides a comprehensive infrastructure for building enterprise applications with ASP.NET Core. This rule establishes the core conventions and best practices that should be followed when working with ABP projects.

## Core Conventions

### Time Handling
**Rule**: Always use `IClock` service instead of `DateTime.Now` or `DateTime.UtcNow`

```csharp
// ✅ Correct - Use IClock in base classes
public class BookAppService : ApplicationService
{
    public void DoSomething()
    {
        var now = Clock.Now; // Available as property
    }
}

// ✅ Correct - Inject IClock in other services
public class MyService : ITransientDependency
{
    private readonly IClock _clock;
    public MyService(IClock clock) => _clock = clock;
}

// ❌ Wrong - Never use DateTime directly
public class WrongService
{
    public void DoSomething()
    {
        var now = DateTime.Now; // Not testable, ignores timezone
    }
}
```

### Dependency Injection
**Rule**: Use ABP's marker interfaces instead of manual service registration

```csharp
// ✅ Correct - Automatic registration
public class MyService : ITransientDependency { }
public class MySingletonService : ISingletonDependency { }
public class MyScopedService : IScopedDependency { }

// ❌ Wrong - Manual registration in modules
public override void ConfigureServices(ServiceConfigurationContext context)
{
    services.AddTransient<IMyService, MyService>(); // Don't do this
}
```

### Repository Usage
**Rule**: Use generic `IRepository<T, TKey>` for simple CRUD, custom interfaces only for complex queries

```csharp
// ✅ Correct - Generic repository for simple operations
public class BookAppService : ApplicationService
{
    private readonly IRepository<Book, Guid> _bookRepository;
    
    public async Task<BookDto> GetAsync(Guid id)
    {
        return await _bookRepository.GetAsync(id);
    }
}

// ✅ Correct - Custom repository for complex queries
public interface IBookRepository : IRepository<Book, Guid>
{
    Task<Book> FindByNameAsync(string name);
    Task<List<Book>> GetBooksByAuthorAsync(Guid authorId);
}

// ❌ Wrong - Injecting DbContext directly
public class WrongAppService : ApplicationService
{
    private readonly MyProjectDbContext _context; // Don't inject DbContext
}
```

### Base Class Properties
**Rule**: Check base class properties before injecting services

```csharp
// ✅ Correct - Use available properties
public class BookAppService : ApplicationService
{
    public async Task CreateBookAsync(CreateBookDto input)
    {
        // These are already available as properties
        var userId = CurrentUser.Id;
        var tenantId = CurrentTenant.Id;
        var now = Clock.Now;
        var guid = GuidGenerator.Create();
        
        // Only inject services not available in base classes
    }
}

// ❌ Wrong - Injecting already available services
public class WrongAppService : ApplicationService
{
    private readonly ICurrentUser _currentUser; // Already available as CurrentUser
    private readonly IClock _clock; // Already available as Clock
    private readonly IGuidGenerator _guidGenerator; // Already available as GuidGenerator
}
```

### Business Exceptions
**Rule**: Use `BusinessException` with namespaced error codes for domain rule violations

```csharp
// ✅ Correct - BusinessException with namespaced code
throw new BusinessException("MyModule:BookNameAlreadyExists")
    .WithData("Name", bookName);

// ❌ Wrong - Generic exceptions
throw new Exception("Book name already exists"); // Not localized, no error code
throw new InvalidOperationException("Book name already exists"); // Not for business rules
```

### Localization
**Rule**: Always localize user-facing messages using `L["Key"]` in base classes

```csharp
// ✅ Correct - Use L property in base classes
public class BookAppService : ApplicationService
{
    public async Task<BookDto> CreateAsync(CreateBookDto input)
    {
        if (string.IsNullOrEmpty(input.Name))
        {
            throw new BusinessException(L["Validation:BookNameRequired"]);
        }
    }
}

// ✅ Correct - Inject IStringLocalizer in other services
public class MyService : ITransientDependency
{
    private readonly IStringLocalizer<MyResource> _localizer;
    
    public MyService(IStringLocalizer<MyResource> localizer)
    {
        _localizer = localizer;
    }
}

// ❌ Wrong - Hardcoded strings
throw new BusinessException("Book name is required"); // Not localizable
```

### Async Patterns
**Rule**: All async methods must end with `Async` suffix and never use `.Result` or `.Wait()`

```csharp
// ✅ Correct - Proper async patterns
public async Task<BookDto> GetAsync(Guid id)
{
    return await _bookRepository.GetAsync(id);
}

// ❌ Wrong - Blocking calls
public BookDto Get(Guid id)
{
    return _bookRepository.GetAsync(id).Result; // Deadlock risk
}

// ❌ Wrong - Missing Async suffix
public async Task<BookDto> Get(Guid id) // Should be GetAsync
{
    return await _bookRepository.GetAsync(id);
}
```

### Module Configuration
**Rule**: Middleware configuration only in host applications, not in reusable modules

```csharp
// ✅ Correct - Service configuration in modules
public override void ConfigureServices(ServiceConfigurationContext context)
{
    Configure<MyModuleOptions>(options =>
    {
        options.EnableFeatureX = true;
    });
}

// ❌ Wrong - Middleware in reusable modules
public override void OnApplicationInitialization(ApplicationInitializationContext context)
{
    // Don't configure middleware in reusable modules
    app.UseMiddleware<CustomMiddleware>();
}
```

## Anti-Patterns to Avoid

### Never Use These Patterns
| Anti-Pattern | Correct Approach |
|-------------|-----------------|
| Minimal APIs | ABP Controllers or Auto API Controllers |
| MediatR | Application Services |
| DbContext directly in App Services | `IRepository<T>` |
| `AddScoped/AddTransient/AddSingleton` | `ITransientDependency`, `ISingletonDependency` |
| `DateTime.Now` | `IClock` / `Clock.Now` |
| Custom UnitOfWork | ABP's `IUnitOfWorkManager` |
| Manual HTTP calls from UI | ABP client proxies (`generate-proxy`) |
| Hardcoded role checks | Permission-based authorization |
| Business logic in Controllers | Application Services |

### Common Mistakes

#### 1. Injecting Available Properties
```csharp
// ❌ Wrong
public class BookAppService : ApplicationService
{
    private readonly ICurrentUser _currentUser; // Already available
    private readonly IClock _clock; // Already available
}

// ✅ Correct
public class BookAppService : ApplicationService
{
    // Use CurrentUser, Clock, GuidGenerator properties directly
}
```

#### 2. Missing Virtual Methods in Modules
```csharp
// ❌ Wrong for reusable modules
public class BookAppService : ApplicationService
{
    public async Task<BookDto> CreateAsync(CreateBookDto input) // Not virtual
    {
        // Implementation
    }
}

// ✅ Correct for reusable modules
public class BookAppService : ApplicationService
{
    public virtual async Task<BookDto> CreateAsync(CreateBookDto input) // Virtual
    {
        // Implementation
    }
}
```

#### 3. Incorrect Exception Handling
```csharp
// ❌ Wrong
try
{
    await _bookRepository.InsertAsync(book);
}
catch (Exception ex)
{
    // Catching all exceptions
    throw new Exception("Failed to create book");
}

// ✅ Correct
try
{
    await _bookRepository.InsertAsync(book);
}
catch (BusinessException)
{
    // Re-throw business exceptions
    throw;
}
catch (Exception ex)
{
    // Log and wrap unexpected exceptions
    Logger.LogError(ex, "Unexpected error creating book");
    throw new BusinessException("MyModule:UnexpectedError");
}
```

## Validation Rules

### Required Checks
- [ ] All async methods end with `Async` suffix
- [ ] No usage of `DateTime.Now` or `DateTime.UtcNow`
- [ ] All user-facing messages are localized
- [ ] Business exceptions use namespaced error codes
- [ ] Repository usage follows patterns
- [ ] Base class properties are checked before injection
- [ ] No blocking async calls (.Result, .Wait)

### Performance Considerations
- [ ] Use `IQueryable` for complex database queries
- [ ] Implement proper caching strategies
- [ ] Avoid N+1 query problems
- [ ] Use pagination for large result sets

### Security Considerations
- [ ] All application services check permissions
- [ ] Input validation on all DTOs
- [ ] Sensitive data is not logged
- [ ] Proper error handling without information disclosure

## Configuration Examples

### Localization Setup
```csharp
Configure<AbpLocalizationOptions>(options =>
{
    options.Resources
        .Add<MyProjectResource>("en")
        .AddVirtualJson("/Localization/MyProject");
});
```

### Exception Localization
```csharp
Configure<AbpExceptionLocalizationOptions>(options =>
{
    options.MapCodeNamespace("MyProject", typeof(MyProjectResource));
});
```

### Module Options
```csharp
public class MyModuleOptions
{
    public bool EnableFeatureX { get; set; } = true;
    public int MaxItemCount { get; set; } = 100;
}

Configure<MyModuleOptions>(options =>
{
    options.EnableFeatureX = configuration.GetValue<bool>("MyModule:EnableFeatureX");
});
```

This rule ensures consistent ABP Framework usage across all projects and maintains the architectural integrity of ABP-based applications.
