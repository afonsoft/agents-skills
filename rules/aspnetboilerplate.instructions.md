---
description: 'Guidelines for developing applications with ASP.NET Boilerplate framework'
applyTo: '**/*.cs,**/Startup.cs,**/Program.cs,**/appsettings.json,**/*.csproj'
---

# ASP.NET Boilerplate Development Guidelines

## Framework Overview

ASP.NET Boilerplate (ABP) is an open source application framework that provides a strong architectural model based on Domain Driven Design (DDD) with best practices built-in. It works with ASP.NET Core & EF Core and provides a complete infrastructure for modern web applications.

## Architecture Model

### Core Layers
ASP.NET Boilerplate follows a layered architecture with these fundamental layers:

#### 1. Client Applications
- Remote clients using HTTP APIs (SPA, mobile, 3rd-party consumers)
- Handle localization and navigation
- Consume REST, OData, or GraphQL endpoints

#### 2. Presentation Layer
- ASP.NET Core MVC controllers and views
- Can be physical (HTTP APIs) or logical (direct injection)
- Handles: Authorization, Session, Features, Exception Handling
- Manages: Localization, Navigation, Object Mapping, Caching, Configuration

#### 3. Distributed Service Layer
- Serves application functionality via remote APIs
- Translates HTTP requests to domain interactions
- Delegates to application services
- Includes: Authorization, Caching, Audit Logging, Object Mapping

#### 4. Application Layer
- **Application Services**: Main components for use cases
- Uses Data Transfer Objects (DTOs) for data transfer
- Orchestrates domain objects to perform application tasks
- Handles: Authorization, Caching, Audit Logging, Session

#### 5. Domain Layer
- **Entities**: Business objects with identity
- **Value Objects**: Immutable objects without identity
- **Domain Services**: Stateless services for complex business logic
- **Specifications**: Encapsulated business rules
- **Domain Events**: Business-significant state changes
- **Repository Interfaces**: Data access abstractions

#### 6. Infrastructure Layer
- Implements repository interfaces (EF Core)
- Integrates with external services (email, SMS, etc.)
- Provides technical capabilities for higher layers

## Core ABP Features

### Application Services
```csharp
public class TaskAppService : ApplicationService, ITaskAppService
{
    private readonly IRepository<Task> _taskRepository;

    public TaskAppService(IRepository<Task> taskRepository)
    {
        _taskRepository = taskRepository;
    }

    [AbpAuthorize(MyPermissions.UpdateTasks)]
    public async Task UpdateTask(UpdateTaskInput input)
    {
        Logger.Info("Updating a task for input: " + input);
        
        var task = await _taskRepository.FirstOrDefaultAsync(input.TaskId);
        if (task == null)
        {
            throw new UserFriendlyException(L("CouldNotFindTheTaskMessage"));
        }
        
        ObjectMapper.MapTo(input, task);
    }
}
```

### Key Features
- **Dependency Injection**: Conventional DI infrastructure
- **Repository Pattern**: Automatic repository creation for entities
- **Authorization**: Declarative permission checking
- **Validation**: Automatic input validation
- **Audit Logging**: Automatic request/response logging
- **Unit of Work**: Transactional application service methods
- **Exception Handling**: Automatic exception management

## Project Structure Standards

### Solution Organization
```
MyProject.sln
├── src/
│   ├── MyProject.Application/
│   │   ├── Interfaces/
│   │   └── Services/
│   ├── MyProject.Application.Shared/
│   │   └── DTOs/
│   ├── MyProject.Core/
│   │   ├── Entities/
│   │   ├── ValueObjects/
│   │   ├── DomainServices/
│   │   └── Repositories/
│   ├── MyProject.EntityFrameworkCore/
│   │   ├── Configurations/
│   │   ├── Migrations/
│   │   └── Repositories/
│   ├── MyProject.Web/
│   │   ├── Controllers/
│   │   ├── Views/
│   │   └── wwwroot/
│   └── MyProject.Web.Shared/
└── test/
    ├── MyProject.Application.Tests/
    └── MyProject.EntityFrameworkCore.Tests/
```

### Module Structure
```
MyModule/
├── MyModule.Application/
│   ├── MyModuleApplicationModule.cs
│   ├── Interfaces/
│   │   └── IMyModuleAppService.cs
│   ├── Services/
│   │   └── MyModuleAppService.cs
│   └── DTOs/
│       ├── MyModuleDto.cs
│       └── CreateUpdateMyModuleDto.cs
├── MyModule.Domain/
│   ├── MyModuleDomainModule.cs
│   ├── Entities/
│   │   └── MyModuleEntity.cs
│   └── DomainServices/
│       └── MyModuleDomainService.cs
├── MyModule.EntityFrameworkCore/
│   ├── MyModuleEntityFrameworkCoreModule.cs
│   ├── Configurations/
│   │   └── MyModuleEntityConfiguration.cs
│   └── Migrations/
└── MyModule.Web/
    ├── MyModuleWebModule.cs
    ├── Controllers/
    │   └── MyModuleController.cs
    └── Pages/
        └── Index.cshtml
```

## Development Guidelines

### Entity Definition
```csharp
public class Task : FullAuditedAggregateRoot<Guid>
{
    public string Title { get; set; }
    public string Description { get; set; }
    public DateTime? DueDate { get; set; }
    public TaskStatus Status { get; set; }

    protected Task() { }

    public Task(Guid id, string title, string description) : base(id)
    {
        Title = Check.NotNullOrWhiteSpace(title, nameof(title));
        Description = Check.NotNullOrWhiteSpace(description, nameof(description));
        Status = TaskStatus.Open;
    }

    public void Complete()
    {
        Status = TaskStatus.Completed;
    }
}
```

### Application Service Patterns
```csharp
public class TaskAppService : ApplicationService, ITaskAppService
{
    private readonly IRepository<Task, Guid> _taskRepository;

    public TaskAppService(IRepository<Task, Guid> taskRepository)
    {
        _taskRepository = taskRepository;
    }

    public async Task<PagedResultDto<TaskDto>> GetListAsync(GetTasksInput input)
    {
        var queryable = await _taskRepository.GetQueryableAsync();
        
        var tasks = await AsyncExecuter.ToListAsync(
            queryable
                .WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                    t => t.Title.Contains(input.Filter) || t.Description.Contains(input.Filter))
                .OrderBy(t => t.CreationTime)
                .PageBy(input.SkipCount, input.MaxResultCount)
        );

        var totalCount = await AsyncExecuter.CountAsync(
            queryable.WhereIf(!input.Filter.IsNullOrWhiteSpace(), 
                t => t.Title.Contains(input.Filter) || t.Description.Contains(input.Filter))
        );

        return new PagedResultDto<TaskDto>(
            totalCount,
            ObjectMapper.Map<List<Task>, List<TaskDto>>(tasks)
        );
    }

    public async Task<TaskDto> GetAsync(Guid id)
    {
        var task = await _taskRepository.GetAsync(id);
        return ObjectMapper.Map<Task, TaskDto>(task);
    }

    public async Task<TaskDto> CreateAsync(CreateUpdateTaskDto input)
    {
        var task = new Task(
            GuidGenerator.Create(),
            input.Title,
            input.Description
        );

        await _taskRepository.InsertAsync(task);
        return ObjectMapper.Map<Task, TaskDto>(task);
    }

    public async Task<TaskDto> UpdateAsync(Guid id, CreateUpdateTaskDto input)
    {
        var task = await _taskRepository.GetAsync(id);
        
        task.Title = input.Title;
        task.Description = input.Description;
        task.DueDate = input.DueDate;

        await _taskRepository.UpdateAsync(task);
        return ObjectMapper.Map<Task, TaskDto>(task);
    }

    public async Task DeleteAsync(Guid id)
    {
        await _taskRepository.DeleteAsync(id);
    }
}
```

### DTO Patterns
```csharp
public class TaskDto : EntityDto<Guid>
{
    public string Title { get; set; }
    public string Description { get; set; }
    public DateTime? DueDate { get; set; }
    public TaskStatus Status { get; set; }
    public DateTime CreationTime { get; set; }
}

public class CreateUpdateTaskDto
{
    [Required]
    [StringLength(TaskConsts.MaxTitleLength)]
    public string Title { get; set; }

    [StringLength(TaskConsts.MaxDescriptionLength)]
    public string Description { get; set; }

    public DateTime? DueDate { get; set; }
}

public class GetTasksInput : PagedAndSortedResultRequestDto
{
    public string Filter { get; set; }
}
```

### Permission Definition
```csharp
public static class MyPermissions
{
    public const string GroupName = "MyProject";

    public static class Tasks
    {
        public const string Default = GroupName + ".Tasks";
        public const string Create = Default + ".Create";
        public const string Edit = Default + ".Edit";
        public const string Delete = Default + ".Delete";
    }
}

public class MyPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(MyPermissions.GroupName);

        var tasksPermission = myGroup.AddPermission(MyPermissions.Tasks.Default, L("Permission:Tasks"));
        tasksPermission.AddChild(MyPermissions.Tasks.Create, L("Permission:Tasks.Create"));
        tasksPermission.AddChild(MyPermissions.Tasks.Edit, L("Permission:Tasks.Edit"));
        tasksPermission.AddChild(MyPermissions.Tasks.Delete, L("Permission:Tasks.Delete"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<MyProjectResource>(name);
    }
}
```

### Entity Framework Configuration
```csharp
public class TaskConfiguration : IEntityTypeConfiguration<Task>
{
    public void Configure(EntityTypeBuilder<Task> builder)
    {
        builder.ToTable(MyProjectConsts.DbTablePrefix + "Tasks", MyProjectConsts.DbSchema);

        builder.Property(x => x.Title)
            .IsRequired()
            .HasMaxLength(TaskConsts.MaxTitleLength);

        builder.Property(x => x.Description)
            .HasMaxLength(TaskConsts.MaxDescriptionLength);

        builder.Property(x => x.Status)
            .HasDefaultValue(TaskStatus.Open);

        builder.HasIndex(x => x.Title);
        builder.HasIndex(x => x.CreationTime);
    }
}
```

## Module Development

### Module Definition
```csharp
[DependsOn(
    typeof(MyProjectDomainModule),
    typeof(AbpAutoMapperModule)
)]
public class MyProjectApplicationModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAutoMapperObjectMapper<MyProjectApplicationModule>();

        Configure<AbpAutoMapperOptions>(options =>
        {
            options.AddMaps<MyProjectApplicationModule>();
        });
    }
}
```

## Testing Standards

### Unit Tests
```csharp
public class TaskAppService_Tests : MyProjectApplicationTestBase
{
    private readonly ITaskAppService _taskAppService;

    public TaskAppService_Tests()
    {
        _taskAppService = GetRequiredService<ITaskAppService>();
    }

    [Fact]
    public async Task Should_Get_List_Of_Tasks()
    {
        // Arrange
        await WithUnitOfWorkAsync(async () =>
        {
            await _taskAppService.CreateAsync(
                new CreateUpdateTaskDto
                {
                    Title = "Test Task 1",
                    Description = "Test Description 1"
                }
            );
        });

        // Act
        var result = await _taskAppService.GetListAsync(new GetTasksInput());

        // Assert
        result.TotalCount.ShouldBeGreaterThan(0);
        result.Items.ShouldContain(t => t.Title == "Test Task 1");
    }
}
```

## Best Practices

### Performance Optimization
- Use EF Core's `AsNoTracking()` for read-only queries
- Implement proper caching strategies
- Use pagination for large datasets
- Optimize database queries with proper indexes

### Security Considerations
- Always use permission attributes on application services
- Validate all input DTOs
- Use parameterized queries (handled by repositories)
- Implement proper audit logging

### Code Organization
- Follow the module-based architecture
- Keep domain logic in the domain layer
- Use DTOs for data transfer between layers
- Implement proper exception handling

### Configuration Management
- Use environment-specific configuration files
- Implement feature flags for conditional functionality
- Use ABP's setting system for configurable parameters
- Secure sensitive configuration values

This framework provides a solid foundation for enterprise applications with built-in best practices and a comprehensive architecture model.
