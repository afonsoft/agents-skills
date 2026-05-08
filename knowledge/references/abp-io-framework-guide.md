# ABP.IO Framework Guide

This comprehensive guide provides detailed information about ABP.IO framework, its features, architecture, and best practices for enterprise application development.

## Framework Overview

ABP.IO is a modern application framework built on ASP.NET Core that provides a complete infrastructure for developing enterprise applications. It follows Domain-Driven Design (DDD) principles and includes pre-built modules for common business requirements.

## Key Features

### Core Architecture
- **Modular Architecture**: Built-in module system with dependency management
- **Domain-Driven Design**: Complete DDD implementation with patterns and practices
- **Multi-Tenancy**: Built-in multi-tenancy support with shared or separate schemas
- **Authentication & Authorization**: Modern authentication with OpenID Connect and JWT
- **Caching**: Distributed caching with Redis and in-memory options
- **Event Bus**: Distributed and local event bus for decoupled architecture
- **Background Jobs**: Hangfire integration for background processing
- **Audit Logging**: Automatic audit logging with configurable options

### Development Tools
- **ABP CLI**: Command-line tool for project creation and management
- **ABP Suite**: Visual tool for CRUD page generation
- **ABP Studio**: Advanced IDE for ABP development
- **Template System**: Multiple project templates for different architectures

## Architecture Patterns

### Layered Architecture
ABP.IO follows a clean layered architecture:

```
┌─────────────────────────────────────┐
│        Presentation Layer           │
│  (Controllers, Views, API Endpoints) │
├─────────────────────────────────────┤
│       Application Layer            │
│    (Application Services, DTOs)     │
├─────────────────────────────────────┤
│         Domain Layer               │
│ (Entities, Value Objects, Services) │
├─────────────────────────────────────┤
│      Infrastructure Layer          │
│  (Data Access, External Services)   │
└─────────────────────────────────────┘
```

### Module System
ABP.IO modules are self-contained units that can be developed, tested, and deployed independently:

```csharp
[DependsOn(
    typeof(AbpAspNetCoreMvcModule),
    typeof(AbpAutofacModule),
    typeof(AbpEntityFrameworkCoreModule)
)]
public class MyProjectModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Module-specific services configuration
    }
}
```

## Project Templates

### Application Template (app)
Standard layered application for most enterprise scenarios.

**Features:**
- Complete layered architecture
- Entity Framework Core integration
- Authentication and authorization
- Multi-tenancy support
- UI framework options (MVC, Angular, Blazor)

**Use Cases:**
- Enterprise applications
- Business management systems
- Multi-user applications
- Long-term maintainable projects

### Single-Layer Template (app-nolayers)
Simplified template for small applications and prototypes.

**Features:**
- Single project structure
- Simplified architecture
- Quick development
- Reduced complexity

**Use Cases:**
- Small applications
- Proof of concepts
- Learning projects
- Temporary applications

### Microservice Template (microservice)
Distributed architecture template for large-scale systems.

**Features:**
- Multiple services
- API Gateway
- Distributed configuration
- Service discovery
- Inter-service communication

**Use Cases:**
- Large enterprise systems
- Microservice architectures
- Scalable applications
- Independent deployment needs

## Development Patterns

### Entity Definition
```csharp
public class Product : FullAuditedAggregateRoot<Guid>
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public ProductCategory Category { get; set; }
    
    protected Product() { }
    
    public Product(
        Guid id, 
        string name, 
        decimal price, 
        ProductCategory category) : base(id)
    {
        Name = Check.NotNullOrWhiteSpace(name, nameof(name));
        Price = price;
        Category = category;
    }
}
```

### Application Service
```csharp
public class ProductAppService : ApplicationService, IProductAppService
{
    private readonly IRepository<Product, Guid> _productRepository;

    public ProductAppService(IRepository<Product, Guid> productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<PagedResultDto<ProductDto>> GetListAsync(GetProductsInput input)
    {
        var queryable = await _productRepository.GetQueryableAsync();
        
        var products = await AsyncExecuter.ToListAsync(
            queryable
                .WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                    p => p.Name.Contains(input.Filter))
                .OrderBy(p => p.Name)
                .PageBy(input.SkipCount, input.MaxResultCount)
        );

        var totalCount = await AsyncExecuter.CountAsync(
            queryable.WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                p => p.Name.Contains(input.Filter))
        );

        return new PagedResultDto<ProductDto>(
            totalCount,
            ObjectMapper.Map<List<Product>, List<ProductDto>>(products)
        );
    }
}
```

### Permission System
```csharp
public static class ProductPermissions
{
    public const string GroupName = "Product";

    public static class Products
    {
        public const string Default = GroupName + ".Products";
        public const string Create = Default + ".Create";
        public const string Edit = Default + ".Edit";
        public const string Delete = Default + ".Delete";
    }
}

public class ProductPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var productGroup = context.AddGroup(ProductPermissions.GroupName);

        var productsPermission = productGroup.AddPermission(
            ProductPermissions.Products.Default, 
            L("Permission:Products")
        );
        
        productsPermission.AddChild(ProductPermissions.Products.Create, L("Permission:Products.Create"));
        productsPermission.AddChild(ProductPermissions.Products.Edit, L("Permission:Products.Edit"));
        productsPermission.AddChild(ProductPermissions.Products.Delete, L("Permission:Products.Delete"));
    }
}
```

## Database Integration

### Entity Framework Core
ABP.IO provides seamless Entity Framework Core integration:

```csharp
public class MyProjectDbContext : AbpDbContext<MyProjectDbContext>
{
    public DbSet<Product> Products { get; set; }

    public MyProjectDbContext(DbContextOptions<MyProjectDbContext> options) 
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        
        builder.ConfigureProductManagement();
    }
}
```

### MongoDB Support
For document-based databases, ABP.IO provides MongoDB integration:

```csharp
[DependsOn(typeof(AbpMongoDbModule))]
public class MyProjectMongoDbModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddMongoDbContext<MyProjectMongoDbContext>(options =>
        {
            options.ConnectionString = GetMongoConnectionString();
        });
    }
}
```

## UI Frameworks

### ASP.NET Core MVC
Traditional server-side rendered applications with Razor views:

```csharp
public class ProductsController : AbpControllerBase
{
    private readonly IProductAppService _productAppService;

    public ProductsController(IProductAppService productAppService)
    {
        _productAppService = productAppService;
    }

    public async Task<IActionResult> Index()
    {
        var products = await _productAppService.GetListAsync(new GetProductsInput());
        return View(products);
    }
}
```

### Angular
Modern single-page applications with Angular:

```typescript
@Injectable({
  providedIn: 'root'
})
export class ProductService {
  constructor(private http: HttpClient) {}

  getList(input: GetProductsInput): Observable<PagedResultDto<ProductDto>> {
    return this.http.get<PagedResultDto<ProductDto>>('/api/products', {
      params: new HttpParams({ fromObject: input })
    });
  }
}
```

### Blazor
Modern web applications using Blazor components:

```razor
@page "/products"
@inject IProductAppService ProductAppService

<h3>Product List</h3>

<AntList TItem="ProductDto" DataSource="@products">
    <PropertyColumn Property="@nameof(ProductDto.Name)" />
    <PropertyColumn Property="@nameof(ProductDto.Price)" />
</AntList>

@code {
    private PagedResultDto<ProductDto> products;

    protected override async Task OnInitializedAsync()
    {
        products = await ProductAppService.GetListAsync(new GetProductsInput());
    }
}
```

## Best Practices

### Performance Optimization
- Use `IQueryable` for complex database queries
- Implement proper caching strategies
- Use distributed caching for multi-instance deployments
- Optimize entity configurations and indexes

### Security Considerations
- Always use permission attributes on application services
- Implement proper input validation and sanitization
- Use HTTPS in production environments
- Configure proper CORS policies

### Code Organization
- Follow ABP's naming conventions
- Keep business logic in the domain layer
- Use dependency injection properly
- Implement proper exception handling

### Testing Strategies
- Write unit tests for domain logic
- Create integration tests for application services
- Use in-memory databases for testing
- Implement proper test data management

## Configuration Management

### Application Configuration
```json
{
  "App": {
    "SelfUrl": "https://localhost:44300",
    "CorsOrigins": "https://localhost:44300"
  },
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=MyProjectDb;Trusted_Connection=true"
  },
  "AuthServer": {
    "Authority": "https://localhost:44300",
    "RequireHttpsMetadata": "false"
  },
  "StringLocalizations": {
    "Languages": [
      {
        "CultureName": "en",
        "DisplayName": "English"
      },
      {
        "CultureName": "pt-BR",
        "DisplayName": "Português"
      }
    ]
  }
}
```

### Module Configuration
```csharp
public override void ConfigureServices(ServiceConfigurationContext context)
{
    var configuration = context.Services.GetConfiguration();
    
    Configure<AbpDbContextOptions>(options =>
    {
        options.Configure(abpDbContextConfigurationContext =>
        {
            abpDbContextConfigurationContext.UseSqlServer();
        });
    });
    
    Configure<AbpLocalizationOptions>(options =>
    {
        options.Languages.Add(new LanguageInfo("en", "en", "English"));
        options.Languages.Add(new LanguageInfo("pt-BR", "pt-BR", "Português"));
    });
}
```

## Migration from ASP.NET Boilerplate

### Key Differences
- **Modern Architecture**: Built for .NET Core/5/6/7/8+ only
- **Enhanced Modularity**: Better module system with dependency management
- **Improved Tooling**: ABP Studio, ABP Suite, enhanced CLI
- **Better Performance**: Optimized for modern .NET performance patterns

### Migration Steps
1. **Assessment**: Analyze current ASP.NET Boilerplate project
2. **Preparation**: Set up development environment and tools
3. **Creation**: Create new ABP.IO project with appropriate template
4. **Migration**: Migrate domain entities, application services, and UI
5. **Testing**: Validate functionality and performance
6. **Deployment**: Deploy to production environment

### Common Migration Patterns
- Entity base classes: `FullAuditedEntity` → `FullAuditedAggregateRoot<Guid>`
- Namespaces: `Abp.*` → `Volo.Abp.*`
- Application services: Updated to async patterns
- Configuration: Modern configuration system

## Resources and Documentation

### Official Documentation
- [ABP.IO Documentation](https://abp.io/docs/latest) - Comprehensive framework documentation
- [ABP.IO Samples](https://abp.io/docs/latest/samples) - Sample applications and tutorials
- [ABP.IO Blog](https://abp.io/blog) - Latest updates and best practices

### Community Resources
- [GitHub Repository](https://github.com/abpframework/abp) - Source code and issues
- [Discord Community](https://discord.gg/abpframework) - Community support and discussions
- [Stack Overflow](https://stackoverflow.com/questions/tagged/abp) - Technical questions and answers

### Development Tools
- [ABP CLI](https://abp.io/docs/latest/cli) - Command-line interface
- [ABP Suite](https://abp.io/docs/latest/suite) - Visual development tool
- [ABP Studio](https://abp.io/docs/latest/studio) - Advanced IDE

This guide provides a comprehensive overview of ABP.IO framework capabilities and serves as a reference for developing enterprise applications with modern best practices.
