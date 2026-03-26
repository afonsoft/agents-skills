---
description: Guidelines for .NET project structure, solution organization, and architectural patterns
applyTo:
  - "**/*.sln"
  - "**/*.csproj"
  - "**/project.json"
  - "**/Directory.Build.props"
  - "**/Directory.Build.targets"
---

# .NET Project Structure Guidelines

## Overview

This document defines the standard structure and organization for .NET projects to ensure consistency, maintainability, and scalability across all solutions.

## Solution Structure

### Root Level Organization

```
MySolution/
├── src/                          # Source code
│   ├── MySolution.Api/           # Web API project
│   ├── MySolution.Core/          # Core domain logic
│   ├── MySolution.Infrastructure/ # Infrastructure concerns
│   ├── MySolution.Application/   # Application services
│   └── MySolution.Shared/        # Shared utilities
├── tests/                        # Test projects
│   ├── MySolution.Api.Tests/
│   ├── MySolution.Core.Tests/
│   ├── MySolution.Infrastructure.Tests/
│   └── MySolution.Application.Tests/
├── docs/                         # Documentation
├── scripts/                      # Build and deployment scripts
├── tools/                        # Development tools
├── artifacts/                    # Build outputs
├── .github/                      # GitHub workflows and templates
├── .vscode/                      # VS Code settings
├── docker/                       # Docker files
├── MySolution.sln               # Solution file
├── Directory.Build.props         # Shared MSBuild properties
├── README.md                     # Project documentation
└── .gitignore                    # Git ignore file
```

## Project Types and Responsibilities

### 1. API Project (MySolution.Api)

**Purpose**: Web API entry point, controllers, DTOs

**Structure**:
```
MySolution.Api/
├── Controllers/
│   ├── UsersController.cs
│   ├── ProductsController.cs
│   └── BaseController.cs
├── DTOs/
│   ├── Requests/
│   │   ├── CreateUserRequest.cs
│   │   └── UpdateUserRequest.cs
│   ├── Responses/
│   │   ├── UserResponse.cs
│   │   └── ProductResponse.cs
│   └── Common/
│       ├── BaseDto.cs
│       └── PagedResultDto.cs
├── Middleware/
│   ├── ExceptionHandlingMiddleware.cs
│   ├── RequestLoggingMiddleware.cs
│   └── AuthenticationMiddleware.cs
├── Filters/
│   ├── ValidateModelAttribute.cs
│   └── ApiExceptionFilterAttribute.cs
├── Extensions/
│   ├── ServiceCollectionExtensions.cs
│   └── MiddlewareExtensions.cs
├── Configuration/
│   ├── SwaggerConfiguration.cs
│   └── CorsConfiguration.cs
├── Program.cs
├── appsettings.json
├── appsettings.Development.json
├── appsettings.Production.json
└── MySolution.Api.csproj
```

**Key Responsibilities**:
- HTTP request/response handling
- Input validation and model binding
- API versioning and documentation
- Authentication and authorization
- Error handling and logging

### 2. Core Project (MySolution.Core)

**Purpose**: Domain entities, enums, interfaces, value objects

**Structure**:
```
MySolution.Core/
├── Entities/
│   ├── User.cs
│   ├── Product.cs
│   ├── Order.cs
│   └── BaseEntity.cs
├── ValueObjects/
│   ├── Email.cs
│   ├── Address.cs
│   └── Money.cs
├── Enums/
│   ├── OrderStatus.cs
│   ├── UserRole.cs
│   └── PaymentMethod.cs
├── Interfaces/
│   ├── Repositories/
│   │   ├── IUserRepository.cs
│   │   └── IProductRepository.cs
│   ├── Services/
│   │   ├── IUserService.cs
│   │   └── IProductService.cs
│   └── External/
│       ├── IEmailService.cs
│       └── IPaymentService.cs
├── Events/
│   ├── IDomainEvent.cs
│   ├── UserCreatedEvent.cs
│   └── OrderPlacedEvent.cs
├── Exceptions/
│   ├── DomainException.cs
│   ├── UserNotFoundException.cs
│   └── InsufficientInventoryException.cs
├── Specifications/
│   ├── UserSpecifications.cs
│   └── ProductSpecifications.cs
└── MySolution.Core.csproj
```

**Key Responsibilities**:
- Domain model and business logic
- Entity definitions and relationships
- Domain events and specifications
- Business rules and validation
- Core interfaces and abstractions

### 3. Infrastructure Project (MySolution.Infrastructure)

**Purpose**: Data access, external services, cross-cutting concerns

**Structure**:
```
MySolution.Infrastructure/
├── Data/
│   ├── Context/
│   │   └── ApplicationDbContext.cs
│   ├── Configurations/
│   │   ├── UserConfiguration.cs
│   │   ├── ProductConfiguration.cs
│   │   └── OrderConfiguration.cs
│   ├── Repositories/
│   │   ├── UserRepository.cs
│   │   ├── ProductRepository.cs
│   │   └── BaseRepository.cs
│   ├── Migrations/
│   │   ├── 20240101000000_InitialCreate.cs
│   │   └── 20240102000000_AddProducts.cs
│   └── Seeds/
│       ├── DataSeeder.cs
│       └── DevelopmentSeedData.cs
├── Services/
│   ├── Email/
│   │   ├── SmtpEmailService.cs
│   │   └── IEmailService.cs
│   ├── Payment/
│   │   ├── StripePaymentService.cs
│   │   └── IPaymentService.cs
│   └── Storage/
│       ├── AzureBlobStorageService.cs
│       └── IStorageService.cs
├── Caching/
│   ├── MemoryCacheService.cs
│   ├── RedisCacheService.cs
│   └── ICacheService.cs
├── Logging/
│   ├── SerilogLogger.cs
│   └── ICustomLogger.cs
├── Security/
│   ├── JwtTokenService.cs
│   ├── PasswordHasher.cs
│   └── IPasswordHasher.cs
└── MySolution.Infrastructure.csproj
```

**Key Responsibilities**:
- Database operations and Entity Framework
- External service integrations
- Caching and logging implementations
- Security and authentication services
- File storage and messaging

### 4. Application Project (MySolution.Application)

**Purpose**: Application services, DTOs, business logic orchestration

**Structure**:
```
MySolution.Application/
├── Services/
│   ├── UserService.cs
│   ├── ProductService.cs
│   ├── OrderService.cs
│   └── BaseAppService.cs
├── DTOs/
│   ├── Commands/
│   │   ├── CreateUserCommand.cs
│   │   ├── UpdateUserCommand.cs
│   │   └── DeleteUserCommand.cs
│   ├── Queries/
│   │   ├── GetUserQuery.cs
│   │   ├── GetUsersQuery.cs
│   │   └── GetProductsQuery.cs
│   └── Responses/
│       ├── UserDto.cs
│       ├── ProductDto.cs
│       └── OrderDto.cs
├── Mappings/
│   ├── UserMappingProfile.cs
│   ├── ProductMappingProfile.cs
│   └── OrderMappingProfile.cs
├── Validators/
│   ├── CreateUserValidator.cs
│   ├── UpdateUserValidator.cs
│   └── FluentValidationExtensions.cs
├── Behaviors/
│   ├── ValidationBehavior.cs
│   ├── LoggingBehavior.cs
│   └── TransactionBehavior.cs
├── Interfaces/
│   ├── IApplicationUserRepository.cs
│   └── IApplicationProductRepository.cs
└── MySolution.Application.csproj
```

**Key Responsibilities**:
- Application business logic
- Command and query handling
- DTO mapping and validation
- Service orchestration
- Cross-cutting concerns

### 5. Shared Project (MySolution.Shared)

**Purpose**: Common utilities, extensions, shared types

**Structure**:
```
MySolution.Shared/
├── Extensions/
│   ├── StringExtensions.cs
│   ├── DateTimeExtensions.cs
│   ├── IEnumerableExtensions.cs
│   └── ObjectExtensions.cs
├── Utilities/
│   ├── ValidationHelper.cs
│   ├── CryptographyHelper.cs
│   └── FileHelper.cs
├── Constants/
│   ├── ApplicationConstants.cs
│   ├── ErrorMessages.cs
│   └── ValidationMessages.cs
├── Enums/
│   ├── CommonEnums.cs
│   └── StatusEnums.cs
├── Types/
│   ├── Result.cs
│   ├── PagedResult.cs
│   └── ApiResponse.cs
└── MySolution.Shared.csproj
```

**Key Responsibilities**:
- Common extension methods
- Utility functions and helpers
- Shared constants and enums
- Common types and patterns

## Project File Standards

### .csproj File Template

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <NoWarn>$(NoWarn);1591</NoWarn>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
    <PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
    <PackageReference Include="Serilog.Sinks.Console" Version="5.0.0" />
    <PackageReference Include="Serilog.Sinks.File" Version="5.0.0" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\MySolution.Core\MySolution.Core.csproj" />
    <ProjectReference Include="..\MySolution.Application\MySolution.Application.csproj" />
    <ProjectReference Include="..\MySolution.Infrastructure\MySolution.Infrastructure.csproj" />
  </ItemGroup>

</Project>
```

### Directory.Build.props

```xml
<Project>
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <NoWarn>$(NoWarn);1591;CS1591</NoWarn>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.SourceLink.GitHub" Version="1.1.1" PrivateAssets="All" />
    <PackageReference Include="Microsoft.CodeAnalysis.NetAnalyzers" Version="7.0.4" PrivateAssets="All" />
    <PackageReference Include="SonarAnalyzer.CSharp" Version="9.25.0.88731" PrivateAssets="All" />
  </ItemGroup>

  <PropertyGroup Condition="'$(Configuration)' == 'Debug'">
    <DefineConstants>$(DefineConstants);DEBUG;TRACE</DefineConstants>
  </PropertyGroup>

  <PropertyGroup Condition="'$(Configuration)' == 'Release'">
    <DefineConstants>$(DefineConstants);RELEASE;TRACE</DefineConstants>
    <Optimize>true</Optimize>
  </PropertyGroup>
</Project>
```

## Naming Conventions

### Projects

- **API Projects**: `[SolutionName].Api`
- **Core Projects**: `[SolutionName].Core`
- **Infrastructure Projects**: `[SolutionName].Infrastructure`
- **Application Projects**: `[SolutionName].Application`
- **Shared Projects**: `[SolutionName].Shared`
- **Test Projects**: `[ProjectName].Tests`

### Namespaces

```csharp
// Core project
namespace MySolution.Core.Entities
namespace MySolution.Core.Interfaces.Repositories
namespace MySolution.Core.ValueObjects

// Infrastructure project
namespace MySolution.Infrastructure.Data.Context
namespace MySolution.Infrastructure.Repositories
namespace MySolution.Infrastructure.Services.Email

// Application project
namespace MySolution.Application.Services
namespace MySolution.Application.DTOs.Commands
namespace MySolution.Application.Validators

// API project
namespace MySolution.Api.Controllers
namespace MySolution.Api.DTOs.Requests
namespace MySolution.Api.Middleware
```

### File Naming

- **Classes**: `PascalCase.cs` (e.g., `UserService.cs`)
- **Interfaces**: `I[PascalCase].cs` (e.g., `IUserRepository.cs`)
- **Tests**: `[ClassName]Tests.cs` (e.g., `UserServiceTests.cs`)
- **Configurations**: `[EntityName]Configuration.cs` (e.g., `UserConfiguration.cs`)
- **Extensions**: `[Target]Extensions.cs` (e.g., `StringExtensions.cs`)

## Dependency Management

### Package References

```xml
<!-- Use central package management -->
<ItemGroup>
  <PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.0" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
  <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.0" />
</ItemGroup>

<!-- Use PrivateAssets for development-only packages -->
<ItemGroup>
  <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" PrivateAssets="All" />
  <PackageReference Include="Microsoft.VisualStudio.Web.CodeGeneration.Design" Version="8.0.0" PrivateAssets="All" />
</ItemGroup>
```

### Project References

```xml
<!-- Core project - no external dependencies -->
<ItemGroup>
  <!-- No external dependencies -->
</ItemGroup>

<!-- Infrastructure project - depends on Core -->
<ItemGroup>
  <ProjectReference Include="..\MySolution.Core\MySolution.Core.csproj" />
</ItemGroup>

<!-- Application project - depends on Core -->
<ItemGroup>
  <ProjectReference Include="..\MySolution.Core\MySolution.Core.csproj" />
</ItemGroup>

<!-- API project - depends on Application and Infrastructure -->
<ItemGroup>
  <ProjectReference Include="..\MySolution.Core\MySolution.Core.csproj" />
  <ProjectReference Include="..\MySolution.Application\MySolution.Application.csproj" />
  <ProjectReference Include="..\MySolution.Infrastructure\MySolution.Infrastructure.csproj" />
</ItemGroup>
```

## Configuration Management

### appsettings.json Structure

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore.Database.Command": "Information"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MySolutionDb;Trusted_Connection=true;MultipleActiveResultSets=true"
  },
  "Jwt": {
    "Issuer": "MySolution",
    "Audience": "MySolutionUsers",
    "Key": "ThisIsASecretKeyForJWTTokenGeneration123456789",
    "ExpirationMinutes": 60
  },
  "Email": {
    "SmtpServer": "smtp.example.com",
    "Port": 587,
    "Username": "noreply@example.com",
    "Password": "email-password"
  },
  "AllowedHosts": "*"
}
```

### Environment-Specific Configuration

```json
// appsettings.Development.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MySolutionDevDb;Trusted_Connection=true;MultipleActiveResultSets=true"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}

// appsettings.Production.json
{
  "ConnectionStrings": {
    "DefaultConnection": "${PRODUCTION_CONNECTION_STRING}"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

## Git Workflow

### Branch Strategy

```
main                 # Production branch
├── develop            # Development branch
├── feature/user-auth  # Feature branches
├── feature/api-v2
├── hotfix/security-patch
└── release/v1.0.0     # Release branches
```

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Examples:
```
feat(api): add user authentication endpoint

- Implement JWT token generation
- Add login and register endpoints
- Include password hashing
- Add unit tests for authentication service

Closes #123

fix(core): resolve null reference exception in user service

- Add null checks in User constructor
- Update validation logic
- Add regression tests

BREAKING CHANGE: User constructor now requires email parameter
```

## Build and Deployment

### Docker Support

```dockerfile
# Multi-stage build for production
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MySolution.Api/MySolution.Api.csproj", "MySolution.Api/"]
COPY ["MySolution.Api/", "MySolution.Api/"]
COPY ["MySolution.Core/MySolution.Core.csproj", "MySolution.Core/"]
COPY ["MySolution.Core/", "MySolution.Core/"]
RUN dotnet restore "MySolution.Api/MySolution.Api.csproj"
RUN dotnet build "MySolution.Api/MySolution.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MySolution.Api/MySolution.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MySolution.Api.dll"]
```

### CI/CD Pipeline

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      - name: Restore dependencies
        run: dotnet restore
      - name: Build
        run: dotnet build --no-restore
      - name: Test
        run: dotnet test --no-build --verbosity normal
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to production
        run: |
          # Deployment commands
```

## Best Practices

### Do's
- ✅ Follow Clean Architecture principles
- ✅ Use dependency injection consistently
- ✅ Implement proper error handling
- ✅ Add comprehensive logging
- ✅ Write unit tests for all business logic
- ✅ Use async/await for I/O operations
- ✅ Validate all inputs
- ✅ Use meaningful variable and method names
- ✅ Keep methods small and focused
- ✅ Document public APIs

### Don'ts
- ❌ Mix business logic with data access
- ❌ Use static dependencies in services
- ❌ Ignore error handling
- ❌ Skip logging important operations
- ❌ Write tests without assertions
- ❌ Use synchronous operations for I/O
- ❌ Trust user input without validation
- ❌ Use unclear naming conventions
- ❌ Create large, complex methods
- ❌ Skip documentation for public APIs

## References

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture/)
- [.NET Project Structure](https://docs.microsoft.com/en-us/dotnet/standard/project-layout/)
- [ASP.NET Core Best Practices](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/best-practices/)
- [Entity Framework Core Best Practices](https://docs.microsoft.com/en-us/ef/core/performance/)

---

**Follow these guidelines to maintain consistent, scalable, and maintainable .NET project structures.**
