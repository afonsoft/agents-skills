---
name: create-abp-io-template
description: 'Create a new ABP.IO project using CLI commands with proper template selection, configuration, and setup. Supports all ABP templates including layered, single-layer, microservice, and modular architectures.'
---

# Create ABP.IO Template

Create a new ABP.IO project using the ABP CLI with proper template selection, configuration, and initial setup.

## Primary Directive

Your goal is to create a new ABP.IO project using the CLI with the appropriate template, configuration, and setup based on the specified requirements.

## ABP CLI Installation

### Install ABP CLI
```bash
# Install ABP CLI globally
dotnet tool install -g Volo.Abp.Cli

# Verify installation
abp --version

# Update to latest version
abp update
```

### Alternative Installation Methods
```bash
# Install specific version
dotnet tool install -g Volo.Abp.Cli --version 8.0.0

# Install from local source
dotnet tool install -g Volo.Abp.Cli --add-source ./local-packages
```

## Available Templates

### 1. Application Template (app)
Standard layered application for most scenarios.

**Use Cases:**
- Medium to large applications
- Multiple developers or teams
- Long-term maintainability required
- Complex business domains

**Command:**
```bash
abp new <solution-name> -t app [options]
```

### 2. Single-Layer Template (app-nolayers)
Simplified template for small applications.

**Use Cases:**
- Small project with simple requirements
- 1-3 developers team
- Temporary or POC projects
- No expected growth in complexity

**Command:**
```bash
abp new <solution-name> -t app-nolayers [options]
```

### 3. Microservice Template (microservice)
For distributed microservice architectures.

**Use Cases:**
- Very large distributed systems
- Independent deployment needed
- Multiple technology stacks
- High scalability requirements

**Command:**
```bash
abp new <solution-name> -t microservice [options]
```

### 4. Empty Template (empty)
Minimal template for custom solutions.

**Use Cases:**
- Custom architecture requirements
- Learning ABP framework
- Minimal starting point

**Command:**
```bash
abp new <solution-name> -t empty [options]
```

## Configuration Options

### UI Framework Options (-u, --ui-framework)
- `mvc`: ASP.NET Core MVC (default)
- `angular`: Angular SPA
- `blazor-webapp`: Blazor Web App
- `blazor`: Blazor Server
- `blazor-server`: Blazor Server
- `no-ui`: No UI layer

### Database Provider Options (-d, --database-provider)
- `ef`: Entity Framework Core (default)
- `mongodb`: MongoDB

### Mobile Options (-m, --mobile)
- `none`: No mobile app (default)
- `react-native`: React Native
- `maui`: .NET MAUI

### Architecture Options
- `--tiered`: Creates tiered architecture (separate API and UI layers)
- `--separate-tenant-schema`: Different DbContext for tenant schema

### Theme Options (-th, --theme)
- `leptonx`: LeptonX Theme (premium)
- `leptonx-lite`: LeptonX-Lite Theme (default)
- `basic`: Basic Theme

### Additional Options
- `--connection-string`: Custom database connection string
- `--skip-migrations`: Skip initial database migration
- `--skip-migrator`: Skip database migrator
- `--public-website`: Add public website (PRO)
- `--without-cms-kit`: Exclude CmsKit module
- `--sample-crud-page`: Add sample CRUD page
- `--use-open-source-template`: Use open-source template

## Template Selection Guide

### Decision Tree

#### 1. Project Size & Complexity
- **Small/Simple** → Single-Layer
- **Medium/Complex** → Layered
- **Large/Distributed** → Microservice

#### 2. Team Size
- **1-3 developers** → Single-Layer
- **4+ developers** → Layered
- **Multiple teams** → Microservice

#### 3. UI Requirements
- **Web only** → MVC
- **SPA experience** → Angular
- **Modern web** → Blazor
- **No UI needed** → no-ui

#### 4. Database Needs
- **Relational** → EF Core
- **Document** → MongoDB

## Common Template Commands

### Standard Web Application
```bash
# Basic MVC application
abp new Acme.BookStore

# With specific options
abp new Acme.BookStore -t app -u mvc -d ef -th leptonx-lite

# With custom connection string
abp new Acme.BookStore -t app -u mvc -d ef --connection-string "Server=localhost;Database=BookStore;Trusted_Connection=true"
```

### Angular SPA Application
```bash
# Angular application
abp new Acme.BookStore -t app -u angular -d ef

# Angular with tiered architecture
abp new Acme.BookStore -t app -u angular -d ef --tiered

# Angular with PWA
abp new Acme.BookStore -t app -u angular -d ef --progressive-web-app
```

### Blazor Application
```bash
# Blazor Web App
abp new Acme.BookStore -t app -u blazor-webapp -d ef

# Blazor Server
abp new Acme.BookStore -t app -u blazor-server -d ef

# Blazor with tiered architecture
abp new Acme.BookStore -t app -u blazor-webapp -d ef --tiered
```

### Microservice Solution
```bash
# Basic microservice
abp new Acme.Microservice -t microservice -u mvc -d ef

# Microservice with Angular
abp new Acme.Microservice -t microservice -u angular -d ef

# Microservice with multiple services
abp new Acme.Microservice -t microservice -u mvc -d ef --tiered
```

### Simple API Project
```bash
# Single-layer API
abp new Acme.Api -t app-nolayers -u no-ui -d ef

# API with sample CRUD
abp new Acme.Api -t app-nolayers -u no-ui -d ef --sample-crud-page
```

## Implementation Workflow

### Step 1: CLI Preparation
```bash
# Ensure ABP CLI is installed
abp --version

# Update to latest version
abp update

# Verify available templates
abp list-templates
```

### Step 2: Project Creation
```bash
# Create project with selected template
abp new <solution-name> [options]

# Example: Create layered MVC application
abp new Acme.BookStore -t app -u mvc -d ef -th leptonx-lite
```

### Step 3: Initial Setup
```bash
# Navigate to project directory
cd <solution-name>

# Restore packages
dotnet restore

# Create and apply database migrations
dotnet ef database update

# Run the application
dotnet run --project src/<solution-name>.Web
```

### Step 4: Verification
```bash
# Verify solution builds
dotnet build

# Run tests
dotnet test

# Check application startup
# Navigate to https://localhost:44300
```

## Project Structure Examples

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

### Single-Layer Application Structure
```
Acme.SimpleApp.sln
├── src/
│   ├── Acme.SimpleApp.Application/
│   │   ├── SimpleAppApplicationModule.cs
│   │   ├── Books/
│   │   │   ├── BookAppService.cs
│   │   │   └── Book.cs
│   │   └── Acme.SimpleApp.Application.csproj
│   ├── Acme.SimpleApp.Application.Contracts/
│   │   └── Acme.SimpleApp.Application.Contracts.csproj
│   ├── Acme.SimpleApp.Domain.Shared/
│   │   └── Acme.SimpleApp.Domain.Shared.csproj
│   ├── Acme.SimpleApp.EntityFrameworkCore/
│   │   ├── SimpleAppDbContext.cs
│   │   └── Acme.SimpleApp.EntityFrameworkCore.csproj
│   ├── Acme.SimpleApp.HttpApi/
│   │   └── Acme.SimpleApp.HttpApi.csproj
│   └── Acme.SimpleApp.Web/
│       ├── Program.cs
│       ├── Pages/
│       └── Acme.SimpleApp.Web.csproj
└── test/
    ├── Acme.SimpleApp.Application.Tests/
    ├── Acme.SimpleApp.EntityFrameworkCore.Tests/
    └── Acme.SimpleApp.Web.Tests/
```

## Advanced Configuration

### Database Provider Configuration

#### SQL Server (Default)
```bash
abp new Acme.BookStore -t app -u mvc -d ef
```

#### PostgreSQL
```bash
abp new Acme.BookStore -t app -u mvc -d ef
# Then manually update to PostgreSQL in appsettings.json
```

#### SQLite
```bash
abp new Acme.BookStore -t app -u mvc -d ef
# Then manually update to SQLite in DbContext
```

#### MongoDB
```bash
abp new Acme.BookStore -t app -u mvc -d mongodb
```

### Authentication Configuration

#### Built-in Authentication
```bash
abp new Acme.BookStore -t app -u mvc -d ef
# Default includes OpenIddict authentication
```

#### Custom Authentication
```bash
abp new Acme.BookStore -t app -u mvc -d ef
# Configure custom authentication in WebModule
```

### Multi-Tenancy Configuration

#### Shared Database
```bash
abp new Acme.BookStore -t app -u mvc -d ef
# Default multi-tenancy with shared database
```

#### Separate Tenant Schema
```bash
abp new Acme.BookStore -t app -u mvc -d ef --separate-tenant-schema
# Different schema for each tenant
```

## Post-Creation Customization

### 1. Package Management
```bash
# Add additional packages
abp add-package Volo.Abp.Emailing
abp add-package Volo.Abp.Sms
abp add-package Volo.Abp.Caching

# Add module
abp add-module Volo.CmsKit
```

### 2. Configuration Updates
```json
// appsettings.json
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=AcmeBookStore;Trusted_Connection=true"
  },
  "App": {
    "SelfUrl": "https://localhost:44300",
    "CorsOrigins": "https://localhost:44300"
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

### 3. Database Configuration
```bash
# Create initial migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# Add new migration
dotnet ef migrations add AddedBookEntity
```

### 4. First Entity Creation
```csharp
// src/Acme.BookStore.Domain/Books/Book.cs
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

### 5. Application Service
```csharp
// src/Acme.BookStore.Application/Books/BookAppService.cs
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
}
```

## Development Tools Integration

### ABP Suite Integration
```bash
# Install ABP Suite (separate tool)
# Generate CRUD pages automatically
# Create entities with visual designer
# Manage application settings
```

### ABP Studio Integration
```bash
# Open project in ABP Studio
# Visual module management
# Advanced debugging tools
# Performance monitoring
```

### Docker Support
```bash
# Build Docker image
docker build -t acme/bookstore .

# Run with Docker Compose
docker-compose up -d

# Database migrations in Docker
docker-compose exec web dotnet ef database update
```

## Troubleshooting

### Common Issues and Solutions

#### 1. CLI Not Found
```bash
# Install ABP CLI
dotnet tool install -g Volo.Abp.Cli

# Check PATH
echo $PATH

# Reinstall if corrupted
dotnet tool uninstall -g Volo.Abp.Cli
dotnet tool install -g Volo.Abp.Cli
```

#### 2. Template Creation Fails
```bash
# Check .NET SDK version
dotnet --version

# Clear NuGet cache
dotnet nuget locals all --clear

# Use specific template version
abp new Acme.BookStore -t app --use-open-source-template
```

#### 3. Database Issues
```bash
# Check connection string
dotnet ef database update --verbose

# Recreate database
dotnet ef database drop
dotnet ef database update

# Check migrations
dotnet ef migrations list
```

#### 4. Build Errors
```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build

# Check for package conflicts
dotnet list package --outdated
```

## Validation Checklist

### Pre-Development Validation
- [ ] ABP CLI installed and updated
- [ ] Correct template selected for requirements
- [ ] Project created successfully
- [ ] Solution builds without errors
- [ ] Database connection configured
- [ ] Initial migrations applied
- [ ] Application starts successfully

### Development Readiness
- [ ] Default login page accessible
- [ ] User registration working
- [ ] Basic CRUD operations functional
- [ ] API endpoints responding
- [ ] Test projects compile
- [ ] Localization working
- [ ] Theme applied correctly

## Best Practices

### Template Selection
- Choose the simplest template that meets requirements
- Consider future growth and scalability
- Factor in team expertise and experience
- Plan for multi-tenancy if needed

### Configuration Management
- Use environment-specific configuration files
- Store sensitive data in user secrets
- Leverage ABP's setting system
- Implement proper logging

### Development Workflow
- Use ABP CLI for all project operations
- Follow ABP conventions and patterns
- Implement proper unit tests
- Use version control from the start

### Performance Optimization
- Choose appropriate database provider
- Implement proper caching strategies
- Use async operations consistently
- Monitor application performance

This skill provides comprehensive guidance for creating ABP.IO projects using the CLI with the right template and configuration for your specific needs.
