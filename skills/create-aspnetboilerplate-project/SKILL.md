---
name: create-aspnetboilerplate-project
description: 'Create a new ASP.NET Boilerplate project with proper template selection, configuration, and setup. Supports all ASP.NET Boilerplate templates including MVC, Angular, and module-zero templates.'
---

# Create ASP.NET Boilerplate Project

Create a new ASP.NET Boilerplate project using the official templates with proper configuration and initial setup.

## Primary Directive

Your goal is to create a new ASP.NET Boilerplate project with the appropriate template, configuration, and setup based on the specified requirements.

## Available Templates

### 1. ASP.NET Core MVC Template
Standard MVC application with ASP.NET Core integration.

**Use Cases:**
- Traditional web applications
- Server-side rendered applications
- Multi-tenant applications
- Enterprise applications

**Download URL:** https://aspnetboilerplate.com/Templates

### 2. ASP.NET Core Angular Template
Single Page Application with Angular frontend.

**Use Cases:**
- Modern SPA applications
- Rich client-side applications
- Mobile-responsive applications
- API-driven applications

**Download URL:** https://aspnetboilerplate.com/Templates

### 3. Module Zero Core Template
Template with pre-built user, role, and permission management.

**Use Cases:**
- Applications requiring authentication
- Multi-user systems
- Permission-based access control
- Tenant management

**Download URL:** https://aspnetboilerplate.com/Templates

## Template Selection Guide

### Decision Matrix

| Requirement | MVC Template | Angular Template | Module Zero |
|-------------|--------------|------------------|------------|
| Traditional Web UI | ✅ | ❌ | ✅ |
| SPA Experience | ❌ | ✅ | ❌ |
| Authentication Built-in | ❌ | ❌ | ✅ |
| Multi-Tenancy | ❌ | ❌ | ✅ |
| Rapid Development | ❌ | ❌ | ✅ |
| Custom UI Control | ✅ | ✅ | ✅ |

### Selection Criteria

#### Choose MVC Template when:
- Building traditional web applications
- Need server-side rendering
- Require SEO optimization
- Want full control over UI
- Team has MVC experience

#### Choose Angular Template when:
- Building modern SPA applications
- Need rich client-side interactions
- Mobile-first design required
- API-first architecture
- Team has Angular experience

#### Choose Module Zero when:
- Need built-in authentication
- Require user management
- Multi-tenancy needed
- Rapid development priority
- Want standard enterprise features

## Implementation Workflow

### Step 1: Template Download and Setup

#### Download from Website
1. Navigate to https://aspnetboilerplate.com/Templates
2. Select template type (MVC, Angular, or Module Zero)
3. Configure options:
   - Project name
   - Database provider (EF Core, MongoDB)
   - UI framework
   - Authentication options
4. Download template ZIP file

#### Extract and Setup
```bash
# Extract downloaded template
unzip AspNetBoilerplate-template.zip
cd AspNetBoilerplate-template

# Rename project folders and files
# Update solution name in .sln file
# Update project names in .csproj files
```

### Step 2: Project Configuration

#### Update Configuration Files
```json
// appsettings.json
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=MyProjectDb;Trusted_Connection=true"
  },
  "App": {
    "WebSiteRootAddress": "http://localhost:62114/"
  }
}
```

```json
// appsettings.Development.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}
```

#### Database Setup
```bash
# Navigate to EntityFrameworkCore project
cd src/MyProject.EntityFrameworkCore

# Add initial migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update
```

### Step 3: Initial Development Setup

#### Restore Packages
```bash
# Restore all packages
dotnet restore

# Build solution
dotnet build
```

#### Run Application
```bash
# Run web application
dotnet run --project src/MyProject.Web

# Or use Visual Studio
# Set MyProject.Web as startup project
# Press F5 to run
```

## Template Configurations

### MVC Template Configuration

#### Project Structure
```
MyProject.sln
├── src/
│   ├── MyProject.Application/
│   │   ├── MyProjectApplicationModule.cs
│   │   ├── Services/
│   │   └── MyProject.Application.csproj
│   ├── MyProject.Application.Shared/
│   │   └── MyProject.Application.Shared.csproj
│   ├── MyProject.Core/
│   │   ├── MyProjectCoreModule.cs
│   │   ├── Entities/
│   │   └── MyProject.Core.csproj
│   ├── MyProject.EntityFrameworkCore/
│   │   ├── MyProject.EntityFrameworkCoreModule.cs
│   │   ├── Migrations/
│   │   └── MyProject.EntityFrameworkCore.csproj
│   ├── MyProject.Web/
│   │   ├── Startup.cs
│   │   ├── Program.cs
│   │   ├── Controllers/
│   │   ├── Views/
│   │   ├── wwwroot/
│   │   └── MyProject.Web.csproj
│   └── MyProject.Web.Shared/
└── test/
    ├── MyProject.Application.Tests/
    ├── MyProject.Core.Tests/
    ├── MyProject.EntityFrameworkCore.Tests/
    └── MyProject.Web.Tests/
```

#### Key Configuration Files
```csharp
// src/MyProject.Web/Startup.cs
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddApplication<MyProjectWebModule>();
    }

    public void Configure(IApplicationBuilder app, ILoggerFactory loggerFactory)
    {
        app.InitializeApplication();
    }
}
```

```csharp
// src/MyProject.Web/Program.cs
public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    internal static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
}
```

### Angular Template Configuration

#### Project Structure
```
MyProject.sln
├── angular/
│   ├── src/
│   │   ├── app/
│   │   ├── assets/
│   │   ├── environments/
│   │   └── package.json
│   ├── angular.json
│   └── tsconfig.json
├── host/
│   ├── MyProject.Host/
│   │   ├── MyProject.Host.csproj
│   │   ├── Program.cs
│   │   └── Startup.cs
└── shared/
    └── MyProject.Application.Shared/
```

#### Angular Configuration
```json
// angular/package.json
{
  "name": "my-project",
  "version": "0.0.0",
  "scripts": {
    "ng": "ng",
    "start": "ng serve --port 4200",
    "build": "ng build",
    "test": "ng test"
  },
  "dependencies": {
    "@angular/animations": "^12.0.0",
    "@angular/common": "^12.0.0",
    "@angular/compiler": "^12.0.0",
    "@angular/core": "^12.0.0",
    "@angular/forms": "^12.0.0",
    "@angular/platform-browser": "^12.0.0",
    "@angular/platform-browser-dynamic": "^12.0.0",
    "@angular/router": "^12.0.0"
  }
}
```

### Module Zero Template Configuration

#### Enhanced Authentication Setup
```csharp
// src/MyProject.Web/Startup.cs
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddApplication<MyProjectWebModule>();
        
        // Configure authentication
        services.AddAuthentication()
            .AddIdentityCookies();
    }

    public void Configure(IApplicationBuilder app, IApplicationBuilder env)
    {
        app.InitializeApplication();
    }
}
```

#### Pre-built Features
- User management
- Role management
- Permission management
- Tenant management
- Multi-tenancy support
- Localization
- Feature management

## Common Project Templates

### Standard MVC Application
**Configuration:**
- Database: Entity Framework Core
- UI: ASP.NET Core MVC
- Authentication: None (custom)
- Multi-tenancy: No

**Setup Commands:**
```bash
# Download from website
# Extract and rename
dotnet restore
dotnet ef database update
dotnet run --project src/MyProject.Web
```

### Module Zero Application
**Configuration:**
- Database: Entity Framework Core
- UI: ASP.NET Core MVC
- Authentication: Built-in
- Multi-tenancy: Yes

**Setup Commands:**
```bash
# Download Module Zero template
dotnet restore
dotnet ef database update
# Default admin: admin / 123qwe
dotnet run --project src/MyProject.Web
```

### Angular SPA Application
**Configuration:**
- Database: Entity Framework Core
- UI: Angular 12+
- Authentication: JWT
- Multi-tenancy: Optional

**Setup Commands:**
```bash
# Backend setup
cd host
dotnet restore
dotnet ef database update
dotnet run --project MyProject.Host

# Frontend setup
cd angular
npm install
ng serve
```

## Post-Creation Tasks

### 1. Database Configuration
```bash
# Update connection string in appsettings.json
"ConnectionStrings": {
  "Default": "Server=localhost;Database=MyProjectDb;Trusted_Connection=true"
}

# Create and apply migrations
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### 2. First Entity Creation
```csharp
// src/MyProject.Core/Entities/Product.cs
public class Product : FullAuditedEntity
{
    public string Name { get; set; }
    public decimal Price { get; set; }
    public ProductCategory Category { get; set; }
}
```

### 3. Application Service
```csharp
// src/MyProject.Application/Services/ProductAppService.cs
public class ProductAppService : ApplicationService, IProductAppService
{
    private readonly IRepository<Product> _productRepository;

    public ProductAppService(IRepository<Product> productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<ListResultDto<ProductDto>> GetAll(GetAllProductsInput input)
    {
        var products = await _productRepository.GetAllListAsync();
        return new ListResultDto<ProductDto>(
            ObjectMapper.Map<List<Product>, List<ProductDto>>(products)
        );
    }
}
```

### 4. Web Controller
```csharp
// src/MyProject.Web/Controllers/ProductsController.cs
public class ProductsController : AbpControllerBase
{
    private readonly IProductAppService _productAppService;

    public ProductsController(IProductAppService productAppService)
    {
        _productAppService = productAppService;
    }

    public async Task<ActionResult> Index()
    {
        var products = await _productAppService.GetAll(new GetAllProductsInput());
        return View(products);
    }
}
```

## Customization Options

### UI Customization
```css
/* wwwroot/css/main.css */
.navbar-brand {
    font-weight: bold;
}

.page-header {
    background-color: #f8f9fa;
    padding: 1rem 0;
}
```

### Database Provider Changes
```bash
# Switch to PostgreSQL
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL

# Update DbContext to use PostgreSQL
services.AddDbContext<MyProjectDbContext>(options =>
    options.UseNpgsql(Configuration.GetConnectionString("Default")));
```

### Authentication Configuration
```csharp
// Configure custom authentication
services.Configure<IdentityOptions>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 6;
    options.Password.RequireNonAlphanumeric = false;
});
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Errors
```bash
# Check connection string
# Verify database server is running
# Test connection manually
dotnet ef database update --verbose
```

#### 2. Package Restore Issues
```bash
# Clear NuGet cache
dotnet nuget locals all --clear

# Restore packages
dotnet restore --force
```

#### 3. Migration Issues
```bash
# Drop and recreate database
dotnet ef database drop
dotnet ef migrations add InitialCreate
dotnet ef database update
```

#### 4. Authentication Issues
```bash
# Check user roles and permissions
# Verify database tables created
# Test login with default credentials
```

## Validation Checklist

### Pre-Development Validation
- [ ] Template downloaded and extracted
- [ ] Project renamed appropriately
- [ ] Connection string configured
- [ ] Database created and migrated
- [ ] Application starts successfully
- [ ] Default pages accessible
- [ ] Authentication working (if applicable)

### Development Readiness
- [ ] NuGet packages restored
- [ ] Solution builds without errors
- [ ] Test projects compile
- [ ] Database connectivity verified
- [ ] Basic CRUD operations working
- [ ] Logging configured
- [ ] Localization working

## Best Practices

### Project Organization
- Use meaningful project names (Company.Product)
- Follow ASP.NET Boilerplate conventions
- Keep domain logic in Core layer
- Use dependency injection properly
- Implement proper exception handling

### Database Management
- Use Entity Framework migrations
- Implement proper indexing
- Use appropriate data types
- Consider soft delete patterns
- Implement audit logging

### Security Considerations
- Implement proper authentication
- Use authorization attributes
- Validate all inputs
- Implement proper CORS policies
- Use HTTPS in production

### Performance Optimization
- Use caching appropriately
- Optimize database queries
- Implement pagination
- Use async operations
- Monitor application performance

This skill provides comprehensive guidance for creating ASP.NET Boilerplate projects with the right template and configuration for your specific needs.
