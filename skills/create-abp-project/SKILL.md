---
name: create-abp-project
description: 'Create a new ABP.IO project with proper template selection, configuration, and setup. Supports all ABP templates including layered, single-layer, microservice, and modular architectures.'
---

# Create ABP.IO Project

Create a new ABP.IO project using the ABP CLI with proper template selection, configuration, and initial setup.

## Primary Directive

Your goal is to create a new ABP.IO project with the appropriate template, configuration, and setup based on the specified requirements.

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

## Template Selection Guide

### Decision Tree

1. **Project Size & Complexity**
   - Small/Simple → Single-Layer
   - Medium/Complex → Layered
   - Large/Distributed → Microservice

2. **Team Size**
   - 1-3 developers → Single-Layer
   - 4+ developers → Layered
   - Multiple teams → Microservice

3. **UI Requirements**
   - Web only → MVC
   - SPA experience → Angular
   - Modern web → Blazor
   - No UI needed → no-ui

4. **Database Needs**
   - Relational → EF Core
   - Document → MongoDB

## Implementation Workflow

### Step 1: Template Selection
Analyze requirements and select appropriate template based on:
- Project complexity
- Team size and experience
- Long-term maintenance needs
- UI requirements
- Database preferences

### Step 2: Project Creation
Execute ABP CLI command with appropriate options:

```bash
# Example: Layered MVC application with EF Core
abp new Acme.BookStore -t app -u mvc -d ef

# Example: Angular application with tiered architecture
abp new Acme.BookStore -t app -u angular -d ef --tiered

# Example: Microservice solution
abp new Acme.Microservice -t microservice -u mvc -d ef
```

### Step 3: Initial Setup
1. **Install ABP CLI** (if not already installed):
```bash
dotnet tool install -g Volo.Abp.Cli
```

2. **Navigate to project directory** and restore packages:
```bash
cd Acme.BookStore
dotnet restore
```

3. **Run database migrations**:
```bash
dotnet ef database update
```

4. **Run the application**:
```bash
dotnet run --project src/Acme.BookStore.Web
```

### Step 4: Configuration Customization
Update configuration files as needed:
- `appsettings.json`: Basic configuration
- `appsettings.Development.json`: Development settings
- `appsettings.Production.json`: Production settings

### Step 5: Initial Development Setup
1. **Create first entity** in Domain layer
2. **Generate CRUD pages** using ABP Suite
3. **Define permissions** for new entities
4. **Create application services** for business logic
5. **Add unit tests** for new functionality

## Common Project Templates

### Standard Web Application
```bash
abp new Acme.BookStore -t app -u mvc -d ef --theme leptonx-lite
```

**Structure:**
- Layered architecture
- MVC UI with LeptonX theme
- Entity Framework Core
- Standard authentication and authorization

### SPA Application
```bash
abp new Acme.BookStore -t app -u angular -d ef --tiered
```

**Structure:**
- Layered architecture
- Angular SPA
- Separate Auth Server (tiered)
- Entity Framework Core

### Simple API Project
```bash
abp new Acme.Api -t app-nolayers -u no-ui -d ef
```

**Structure:**
- Single layer
- API-only
- Entity Framework Core
- No UI components

### Microservice Solution
```bash
abp new Acme.Microservice -t microservice -u mvc -d ef
```

**Structure:**
- Multiple services
- API Gateway
- Identity Service
- Shared services

## Post-Creation Tasks

### 1. Configuration Updates
```json
// appsettings.json
{
  "ConnectionStrings": {
    "Default": "Server=localhost;Database=AcmeBookStore;Trusted_Connection=true"
  },
  "App": {
    "SelfUrl": "https://localhost:44300"
  }
}
```

### 2. Database Setup
```bash
# Create initial migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update
```

### 3. First Entity Creation
Create your first entity in the Domain layer:
```csharp
// src/Acme.BookStore.Domain/Books/Book.cs
public class Book : FullAuditedAggregateRoot<Guid>
{
    public string Name { get; set; }
    public BookType Type { get; set; }
    public DateTime PublishDate { get; set; }
    public float Price { get; set; }
}
```

### 4. Application Service
Create corresponding application service:
```csharp
// src/Acme.BookStore.Application/Books/BookAppService.cs
public class BookAppService : ApplicationService, IBookAppService
{
    private readonly IRepository<Book, Guid> _bookRepository;

    public BookAppService(IRepository<Book, Guid> bookRepository)
    {
        _bookRepository = bookRepository;
    }

    // CRUD operations implementation
}
```

## Migration from ASP.NET Boilerplate

### Migration Commands
```bash
# Create new ABP solution
abp new Acme.BookStore -t app -u mvc -d ef

# Copy domain entities from old project
# Migrate application services
# Update namespaces
# Migrate configurations
```

### Key Migration Points
1. **Entity Base Classes**: Change from `FullAuditedEntity` to `FullAuditedAggregateRoot<Guid>`
2. **Application Services**: Update to use async patterns and new ABP conventions
3. **Namespaces**: Update from `Abp.*` to `Volo.Abp.*`
4. **Dependencies**: Update package references
5. **Configuration**: Adapt to new configuration system

## Troubleshooting

### Common Issues

1. **CLI Not Found**
```bash
# Install ABP CLI
dotnet tool install -g Volo.Abp.Cli
```

2. **Database Connection Issues**
```bash
# Update connection string in appsettings.json
dotnet ef database update
```

3. **Permission Errors**
```bash
# Run as administrator or use appropriate permissions
```

4. **Package Restore Issues**
```bash
# Clear NuGet cache
dotnet nuget locals all --clear
dotnet restore
```

### Validation Checklist
- [ ] ABP CLI installed and updated
- [ ] Correct template selected for requirements
- [ ] Database connection string configured
- [ ] Initial migrations applied
- [ ] Application starts successfully
- [ ] Default login page accessible
- [ ] Basic CRUD operations working

## Best Practices

### Project Organization
- Use meaningful project names (Company.Product)
- Follow ABP conventions for folder structure
- Keep domain logic in Domain layer
- Use dependency injection properly

### Configuration Management
- Use environment-specific configuration files
- Store sensitive data in user secrets
- Use ABP's setting system for application settings

### Development Workflow
- Use ABP Suite for CRUD generation
- Implement proper unit tests
- Follow ABP's naming conventions
- Use version control from the start

This skill provides comprehensive guidance for creating ABP.IO projects with the right template and configuration for your specific needs.
