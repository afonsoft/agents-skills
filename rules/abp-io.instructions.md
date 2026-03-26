---
description: 'Guidelines for developing applications with ABP.IO framework - the evolution of ASP.NET Boilerplate'
applyTo: '**/*.cs,**/Program.cs,**/appsettings.json,**/*.csproj,**/MyProjectModule.cs,**/MyProjectAbpModule.cs'
---

# ABP.IO Development Guidelines

## Framework Overview

ABP.IO is the modern evolution of ASP.NET Boilerplate, providing a complete application framework built on ASP.NET Core with enhanced modularity, better architecture, and improved developer experience. It bridges the gap between ASP.NET Core and real-world business application requirements.

## Key Differences from ASP.NET Boilerplate

### Architecture Improvements
- **Enhanced Modularity**: Better module system with dependency management
- **Modern .NET**: Built for .NET Core/5/6/7/8+ only (no legacy MVC 5.x support)
- **Improved UI**: Better theming system with LeptonX theme
- **Advanced Tooling**: ABP Studio, ABP Suite, and enhanced CLI
- **Better Testing**: Improved test project structure and integration

### New Features
- **Microservice Support**: Native microservice architecture templates
- **Enhanced Multi-Tenancy**: Improved multi-tenancy infrastructure
- **Better Performance**: Optimized for modern .NET performance patterns
- **Advanced Caching**: Distributed caching improvements
- **Modern Authentication**: Updated authentication and authorization system

## Solution Templates

### Template Types

#### 1. Application Template (app)
Default template for standard applications with layered architecture.

```bash
abp new Acme.BookStore -t app
```

**Options:**
- `--ui-framework` or `-u`: mvc, angular, blazor-webapp, blazor, blazor-server, no-ui
- `--database-provider` or `-d`: ef, mongodb
- `--mobile` or `-m`: none, react-native, maui
- `--tiered`: Creates tiered architecture (separate API and UI layers)
- `--theme` or `-th`: leptonx, leptonx-lite, basic

#### 2. Single-Layer Template (app-nolayers)
Simplified template for small applications.

```bash
abp new Acme.SimpleApp -t app-nolayers -u mvc -d ef
```

#### 3. Microservice Template (microservice)
For distributed microservice architectures.

```bash
abp new Acme.Microservice -t microservice -u angular -d ef
```

#### 4. Empty Template (empty)
Minimal template for custom solutions.

```bash
abp new Acme.Custom -t empty
```

### Template Selection Guide

**Use Single-Layer when:**
- Small project with simple requirements
- 1-3 developers team
- Temporary or POC projects
- No expected growth in complexity

**Use Layered when:**
- Medium to large projects
- Multiple developers or teams
- Long-term maintainability required
- Multiple UI applications needed
- Complex business domains

**Use Microservice when:**
- Very large distributed systems
- Independent deployment needed
- Multiple technology stacks
- High scalability requirements
- DevOps maturity

## Project Structure

### Layered Application Structure
```
Acme.BookStore.sln
├── src/
│   ├── Acme.BookStore.Application/
│   │   ├── BookStoreApplicationModule.cs
│   │   ├── Books/
│   │   │   ├── BookAppService.cs
│   │   │   └── IBookAppService.cs
│   │   └── Acme.BookStore.Application.csproj
│   ├── Acme.BookStore.Application.Contracts/
│   │   ├── Books/
│   │   │   ├── BookDto.cs
│   │   │   └── IBookAppService.cs
│   │   └── Acme.BookStore.Application.Contracts.csproj
│   ├── Acme.BookStore.Domain/
│   │   ├── BookStoreDomainModule.cs
│   │   ├── Books/
│   │   │   ├── Book.cs
│   │   │   └── IBookRepository.cs
│   │   └── Acme.BookStore.Domain.csproj
│   ├── Acme.BookStore.Domain.Shared/
│   │   ├── BookStoreDomainSharedModule.cs
│   │   └── Acme.BookStore.Domain.Shared.csproj
│   ├── Acme.BookStore.EntityFrameworkCore/
│   │   ├── BookStoreEntityFrameworkCoreModule.cs
│   │   ├── BookStoreDbContext.cs
│   │   ├── Configurations/
│   │   │   └── BookConfiguration.cs
│   │   └── Acme.BookStore.EntityFrameworkCore.csproj
│   ├── Acme.BookStore.HttpApi/
│   │   ├── BookStoreHttpApiModule.cs
│   │   ├── Controllers/
│   │   │   └── BooksController.cs
│   │   └── Acme.BookStore.HttpApi.csproj
│   ├── Acme.BookStore.HttpApi.Client/
│   │   └── Acme.BookStore.HttpApi.Client.csproj
│   ├── Acme.BookStore.Web/
│   │   ├── BookStoreWebModule.cs
│   │   ├── Pages/
│   │   ├── wwwroot/
│   │   └── Acme.BookStore.Web.csproj
│   └── Acme.BookStore.Web.Unified/
├── test/
│   ├── Acme.BookStore.Application.Tests/
│   ├── Acme.BookStore.Domain.Tests/
│   ├── Acme.BookStore.EntityFrameworkCore.Tests/
│   ├── Acme.BookStore.Web.Tests/
│   └── Acme.BookStore.HttpApi.Host.Tests/
└── etc/
    └── docker-compose.yml
```

### Module Structure
```
Acme.BookStore/
├── Acme.BookStore.Application/
│   ├── BookStoreApplicationModule.cs
│   ├── Books/
│   │   ├── BookAppService.cs
│   │   ├── CreateUpdateBookDto.cs
│   │   └── BookDto.cs
├── Acme.BookStore.Domain/
│   ├── BookStoreDomainModule.cs
│   ├── Books/
│   │   ├── Book.cs
│   │   └── BookManager.cs
├── Acme.BookStore.Application.Contracts/
│   ├── Books/
│   │   ├── IBookAppService.cs
│   │   └── BookDto.cs
└── Acme.BookStore.EntityFrameworkCore/
    ├── Configurations/
    │   └── BookConfiguration.cs
    └── Migrations/
```

## Development Patterns

### Module Definition
```csharp
[DependsOn(
    typeof(BookStoreDomainModule),
    typeof(AbpAutoMapperModule)
)]
public class BookStoreApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAutoMapperObjectMapper<BookStoreApplicationModule>();

        Configure<AbpAutoMapperOptions>(options =>
        {
            options.AddMaps<BookStoreApplicationModule>();
        });
    }
}
```

### Entity Definition
```csharp
public class Book : FullAuditedAggregateRoot<Guid>
{
    public string Name { get; set; }
    public BookType Type { get; set; }
    public DateTime PublishDate { get; set; }
    public float Price { get; set; }

    protected Book() { }

    public Book(
        Guid id,
        string name,
        BookType type,
        DateTime publishDate,
        float price) : base(id)
    {
        Name = Check.NotNullOrWhiteSpace(name, nameof(name));
        Type = type;
        PublishDate = publishDate;
        Price = price;
    }
}
```

### Application Service
```csharp
public class BookAppService : ApplicationService, IBookAppService
{
    private readonly IRepository<Book, Guid> _bookRepository;

    public BookAppService(IRepository<Book, Guid> bookRepository)
    {
        _bookRepository = bookRepository;
    }

    public async Task<PagedResultDto<BookDto>> GetListAsync(GetBooksInput input)
    {
        var queryable = await _bookRepository.GetQueryableAsync();
        
        var books = await AsyncExecuter.ToListAsync(
            queryable
                .WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                    book => book.Name.Contains(input.Filter))
                .OrderBy(book => book.Name)
                .PageBy(input.SkipCount, input.MaxResultCount)
        );

        var totalCount = await AsyncExecuter.CountAsync(
            queryable.WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                book => book.Name.Contains(input.Filter))
        );

        return new PagedResultDto<BookDto>(
            totalCount,
            ObjectMapper.Map<List<Book>, List<BookDto>>(books)
        );
    }

    public async Task<BookDto> GetAsync(Guid id)
    {
        var book = await _bookRepository.GetAsync(id);
        return ObjectMapper.Map<Book, BookDto>(book);
    }

    public async Task<BookDto> CreateAsync(CreateUpdateBookDto input)
    {
        var book = new Book(
            GuidGenerator.Create(),
            input.Name,
            input.Type,
            input.PublishDate,
            input.Price
        );

        await _bookRepository.InsertAsync(book);
        return ObjectMapper.Map<Book, BookDto>(book);
    }

    public async Task<BookDto> UpdateAsync(Guid id, CreateUpdateBookDto input)
    {
        var book = await _bookRepository.GetAsync(id);
        
        book.Name = input.Name;
        book.Type = input.Type;
        book.PublishDate = input.PublishDate;
        book.Price = input.Price;

        await _bookRepository.UpdateAsync(book);
        return ObjectMapper.Map<Book, BookDto>(book);
    }

    public async Task DeleteAsync(Guid id)
    {
        await _bookRepository.DeleteAsync(id);
    }
}
```

### Authorization
```csharp
public class BookAppService : ApplicationService, IBookAppService
{
    [Authorize(BookStorePermissions.Books.Default)]
    public async Task<PagedResultDto<BookDto>> GetListAsync(GetBooksInput input)
    {
        // Implementation
    }

    [Authorize(BookStorePermissions.Books.Create)]
    public async Task<BookDto> CreateAsync(CreateUpdateBookDto input)
    {
        // Implementation
    }

    [Authorize(BookStorePermissions.Books.Edit)]
    public async Task<BookDto> UpdateAsync(Guid id, CreateUpdateBookDto input)
    {
        // Implementation
    }

    [Authorize(BookStorePermissions.Books.Delete)]
    public async Task DeleteAsync(Guid id)
    {
        // Implementation
    }
}
```

### Permission Definition
```csharp
public static class BookStorePermissions
{
    public const string GroupName = "BookStore";

    public static class Books
    {
        public const string Default = GroupName + ".Books";
        public const string Create = Default + ".Create";
        public const string Edit = Default + ".Edit";
        public const string Delete = Default + ".Delete";
    }
}

public class BookStorePermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var bookStoreGroup = context.AddGroup(BookStorePermissions.GroupName);

        var booksPermission = bookStoreGroup.AddPermission(
            BookStorePermissions.Books.Default, 
            L("Permission:Books")
        );
        
        booksPermission.AddChild(BookStorePermissions.Books.Create, L("Permission:Books.Create"));
        booksPermission.AddChild(BookStorePermissions.Books.Edit, L("Permission:Books.Edit"));
        booksPermission.AddChild(BookStorePermissions.Books.Delete, L("Permission:Books.Delete"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<BookStoreResource>(name);
    }
}
```

## NuGet Packages

### Core ABP Packages
```xml
<PackageReference Include="Volo.Abp.AspNetCore.Mvc" Version="8.0.0" />
<PackageReference Include="Volo.Abp.Autofac" Version="8.0.0" />
<PackageReference Include="Volo.Abp.AutoMapper" Version="8.0.0" />
<PackageReference Include="Volo.Abp.EntityFrameworkCore" Version="8.0.0" />
<PackageReference Include="Volo.Abp.Identity.AspNetCore" Version="8.0.0" />
<PackageReference Include="Volo.Abp.TenantManagement" Version="8.0.0" />
```

### Database Providers
```xml
<!-- Entity Framework Core -->
<PackageReference Include="Volo.Abp.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Volo.Abp.EntityFrameworkCore.PostgreSql" Version="8.0.0" />
<PackageReference Include="Volo.Abp.EntityFrameworkCore.Sqlite" Version="8.0.0" />

<!-- MongoDB -->
<PackageReference Include="Volo.Abp.MongoDB" Version="8.0.0" />
```

### UI Frameworks
```xml
<!-- MVC -->
<PackageReference Include="Volo.Abp.AspNetCore.Mvc.UI.Theme.LeptonX" Version="8.0.0" />

<!-- Blazor -->
<PackageReference Include="Volo.Abp.AspNetCore.Components.WebAssembly.LeptonXTheme" Version="8.0.0" />

<!-- Angular -->
<PackageReference Include="Volo.Abp.AspNetCore.Serilog" Version="8.0.0" />
```

### Development Tools
```xml
<!-- Testing -->
<PackageReference Include="Volo.Abp.AspNetCore.TestBase" Version="8.0.0" />
<PackageReference Include="Volo.Abp.TestBase" Version="8.0.0" />
<PackageReference Include="Volo.Abp.EntityFrameworkCore.Sqlite" Version="8.0.0" />

<!-- Swagger -->
<PackageReference Include="Volo.Abp.Swashbuckle" Version="8.0.0" />
```

## CLI Commands

### Installation
```bash
dotnet tool install -g Volo.Abp.Cli
```

### Create New Solution
```bash
# Basic MVC application
abp new Acme.BookStore

# Angular with EF Core
abp new Acme.BookStore -t app -u angular -d ef

# Blazor with tiered architecture
abp new Acme.BookStore -t app -u blazor -d ef --tiered

# Microservice solution
abp new Acme.Microservice -t microservice -u mvc -d ef
```

### Add to Existing Solution
```bash
# Add new module
abp add-module Volo.CmsKit

# Add package
abp add-package Volo.Abp.Emailing

# Generate proxy
abp generate-proxy -t angular
```

### Update and Maintenance
```bash
# Update ABP packages
abp update

# Clean solution
abp clean

# Switch versions
abp switch-to-preview
abp switch-to-stable
```

## Migration from ASP.NET Boilerplate

### Migration Strategy

#### 1. Assessment Phase
- Evaluate current ASP.NET Boilerplate version
- Identify customizations and third-party integrations
- Assess team readiness for migration
- Plan migration timeline

#### 2. Preparation Phase
- Create new ABP solution using appropriate template
- Set up development environment
- Install necessary ABP packages
- Configure basic settings

#### 3. Migration Phase
**Domain Layer Migration:**
```csharp
// ASP.NET Boilerplate Entity
public class Book : FullAuditedEntity
{
    public string Name { get; set; }
    public BookType Type { get; set; }
}

// ABP Entity
public class Book : FullAuditedAggregateRoot<Guid>
{
    public string Name { get; set; }
    public BookType Type { get; set; }
    
    protected Book() { }
    
    public Book(Guid id, string name, BookType type) : base(id)
    {
        Name = Check.NotNullOrWhiteSpace(name, nameof(name));
        Type = type;
    }
}
```

**Application Service Migration:**
```csharp
// ASP.NET Boilerplate
public class BookAppService : ApplicationService, IBookAppService
{
    public async Task<ListResultDto<BookDto>> GetAll(GetAllBooksInput input)
    {
        var books = await _bookRepository.GetAllListAsync();
        return new ListResultDto<BookDto>(
            ObjectMapper.Map<List<Book>, List<BookDto>>(books)
        );
    }
}

// ABP
public class BookAppService : ApplicationService, IBookAppService
{
    public async Task<PagedResultDto<BookDto>> GetListAsync(GetBooksInput input)
    {
        var queryable = await _bookRepository.GetQueryableAsync();
        var books = await AsyncExecuter.ToListAsync(
            queryable.PageBy(input.SkipCount, input.MaxResultCount)
        );
        
        var totalCount = await AsyncExecuter.CountAsync(queryable);
        
        return new PagedResultDto<BookDto>(
            totalCount,
            ObjectMapper.Map<List<Book>, List<BookDto>>(books)
        );
    }
}
```

**Namespace Changes:**
```csharp
// ASP.NET Boilerplate namespaces
using Abp.Application.Services;
using Abp.Domain.Repositories;
using Abp.Authorization;
using Abp.UI;

// ABP namespaces
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Authorization;
using Volo.Abp;
```

#### 4. Testing Phase
- Migrate unit tests
- Update integration tests
- Test UI functionality
- Performance testing

#### 5. Deployment Phase
- Update deployment scripts
- Configure production environment
- Monitor application performance
- Rollback planning

### Key Changes Summary

| Feature | ASP.NET Boilerplate | ABP.IO |
|---------|-------------------|--------|
| Base Class | `ApplicationService` | `ApplicationService` |
| Entity Base | `FullAuditedEntity` | `FullAuditedAggregateRoot<T>` |
| Repository | `IRepository<TEntity>` | `IRepository<TEntity, TKey>` |
| Authorization | `AbpAuthorize` | `Authorize` |
| Localization | `L()` method | `L()` method (same) |
| Dependency Injection | Conventional | Enhanced conventional |
| Module System | Basic | Advanced with dependencies |
| UI Themes | Basic | LeptonX theme system |

## Best Practices

### Performance Optimization
- Use `IQueryable` for complex queries
- Implement proper caching strategies
- Use `AsyncExecuter` for database operations
- Optimize entity configurations

### Security
- Always use permission attributes
- Implement proper input validation
- Use ABP's built-in security features
- Configure proper CORS policies

### Testing
- Use ABP's integrated test base classes
- Mock external dependencies
- Test all layers independently
- Use in-memory databases for testing

### Modular Development
- Create reusable modules
- Define clear module boundaries
- Use dependency injection properly
- Follow ABP's module conventions

This framework provides a modern, robust foundation for enterprise applications with enhanced features and better developer experience compared to ASP.NET Boilerplate.
