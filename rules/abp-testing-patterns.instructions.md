---
description: 'ABP testing patterns and best practices for integration tests, test data seeding, assertions, mocking, and test project structure'
applyTo: '**/*Tests.cs,**/*TestBase.cs,**IDataSeedContributor.cs,**/TestData.cs'
---

# ABP Testing Patterns

## Testing Philosophy Overview

ABP emphasizes integration tests over unit tests for application services, domain services, and repositories. Tests should run with real services and an in-memory database to ensure the entire stack works correctly.

## Test Project Structure

### Standard Test Projects
| Project | Purpose | Base Class |
|---------|---------|------------|
| `*.Domain.Tests` | Domain logic, entities, domain services | `*DomainTestBase` |
| `*.Application.Tests` | Application services | `*ApplicationTestBase` |
| `*.EntityFrameworkCore.Tests` | Repository implementations | `*EntityFrameworkCoreTestBase` |

**Rule**: Each test project should inherit from the appropriate base class and use integration testing approach.

```csharp
// ✅ Correct - Application service test
public class BookAppService_Tests : MyProjectApplicationTestBase
{
    private readonly IBookAppService _bookAppService;

    public BookAppService_Tests()
    {
        _bookAppService = GetRequiredService<IBookAppService>();
    }
}

// ❌ Wrong - Unit test approach for ABP
public class BookAppService_Tests
{
    [Fact]
    public void Should_Create_Book()
    {
        var mockRepo = new Mock<IRepository<Book, Guid>>(); // Don't mock ABP services
        var service = new BookAppService(mockRepo.Object);
    }
}
```

## Integration Test Patterns

### 1. Application Service Testing
**Rule**: Use `GetRequiredService<T>()` to resolve services, no mocking of internal ABP services

```csharp
// ✅ Correct - Integration test approach
public class BookAppService_Tests : MyProjectApplicationTestBase
{
    private readonly IBookAppService _bookAppService;

    public BookAppService_Tests()
    {
        _bookAppService = GetRequiredService<IBookAppService>();
    }

    [Fact]
    public async Task Should_Get_List_Of_Books()
    {
        // Act
        var result = await _bookAppService.GetListAsync(
            new PagedAndSortedResultRequestDto()
        );

        // Assert
        result.TotalCount.ShouldBeGreaterThan(0);
        result.Items.ShouldContain(b => b.Name == "Test Book");
    }

    [Fact]
    public async Task Should_Create_Book()
    {
        // Arrange
        var input = new CreateBookDto
        {
            Name = "New Book",
            Price = 19.99m
        };

        // Act
        var result = await _bookAppService.CreateAsync(input);

        // Assert
        result.Id.ShouldNotBe(Guid.Empty);
        result.Name.ShouldBe("New Book");
        result.Price.ShouldBe(19.99m);
    }

    [Fact]
    public async Task Should_Not_Create_Book_With_Invalid_Name()
    {
        // Arrange
        var input = new CreateBookDto
        {
            Name = "", // Invalid
            Price = 10m
        };

        // Act & Assert
        await Should.ThrowAsync<AbpValidationException>(async () =>
        {
            await _bookAppService.CreateAsync(input);
        });
    }
}
```

### 2. Domain Service Testing
**Rule**: Test domain logic and business rules with real repositories

```csharp
// ✅ Correct - Domain service test
public class BookManager_Tests : MyProjectDomainTestBase
{
    private readonly BookManager _bookManager;
    private readonly IBookRepository _bookRepository;

    public BookManager_Tests()
    {
        _bookManager = GetRequiredService<BookManager>();
        _bookRepository = GetRequiredService<IBookRepository>();
    }

    [Fact]
    public async Task Should_Create_Book()
    {
        // Act
        var book = await _bookManager.CreateAsync("Test Book", 29.99m);

        // Assert
        book.ShouldNotBeNull();
        book.Name.ShouldBe("Test Book");
        book.Price.ShouldBe(29.99m);
    }

    [Fact]
    public async Task Should_Not_Allow_Duplicate_Book_Name()
    {
        // Arrange
        await _bookManager.CreateAsync("Existing Book", 10m);

        // Act & Assert
        var exception = await Should.ThrowAsync<BusinessException>(async () =>
        {
            await _bookManager.CreateAsync("Existing Book", 20m);
        });

        exception.Code.ShouldBe("MyProject:BookNameAlreadyExists");
    }
}
```

### 3. Test Naming Convention
**Rule**: Use descriptive names following the pattern `Should_ExpectedBehavior_When_Condition`

```csharp
// ✅ Correct naming patterns
public async Task Should_Create_Book_When_Input_Is_Valid()
public async Task Should_Throw_BusinessException_When_Name_Already_Exists()
public async Task Should_Return_Empty_List_When_No_Books_Exist()
public async Task Should_Update_Book_Price_When_Valid_Price_Provided()
public async Task Should_Not_Delete_Book_When_User_Not_Authorized()

// ❌ Poor naming patterns
public async Task TestCreateBook()
public async Task BookTest1()
public async Task Create()
```

### 4. Arrange-Act-Assert (AAA) Pattern
**Rule**: Structure tests with clear Arrange, Act, and Assert sections

```csharp
// ✅ Correct - Clear AAA structure
[Fact]
public async Task Should_Update_Book_Price()
{
    // Arrange
    var bookId = await CreateTestBookAsync();
    var newPrice = 39.99m;

    // Act
    var result = await _bookAppService.UpdateAsync(bookId, new UpdateBookDto
    {
        Price = newPrice
    });

    // Assert
    result.Price.ShouldBe(newPrice);
}

// Helper method for test data
private async Task<Guid> CreateTestBookAsync()
{
    var input = new CreateBookDto
    {
        Name = "Test Book",
        Price = 19.99m
    };
    var result = await _bookAppService.CreateAsync(input);
    return result.Id;
}
```

## Assertion Patterns

### 1. Shouldly Assertions
**Rule**: Use Shouldly library for readable assertions

```csharp
// ✅ Correct - Shouldly assertions
result.ShouldNotBeNull();
result.Name.ShouldBe("Expected Name");
result.Price.ShouldBeGreaterThan(0);
result.Items.ShouldContain(x => x.Id == expectedId);
result.Items.ShouldBeEmpty();
result.Items.Count.ShouldBe(5);

// Exception assertions
await Should.ThrowAsync<BusinessException>(async () =>
{
    await _service.DoSomethingAsync();
});

var ex = await Should.ThrowAsync<BusinessException>(async () =>
{
    await _service.DoSomethingAsync();
});
ex.Code.ShouldBe("MyProject:ErrorCode");

// ❌ Wrong - Classic assertions
Assert.IsNotNull(result);
Assert.AreEqual("Expected Name", result.Name);
Assert.IsTrue(result.Price > 0);
```

### 2. Collection Assertions
```csharp
// ✅ Correct - Collection assertions
result.Items.ShouldAllBe(item => item.Price > 0);
result.Items.ShouldNotBeEmpty();
result.Items.ShouldContain(item => item.Name.Contains("Test"));
result.Items.Count.ShouldBeInRange(1, 100);

// Order assertions
result.Items.ShouldBeInAscendingOrder(item => item.Name);
result.Items.ShouldBeInDescendingOrder(item => item.Price);
```

## Test Data Management

### 1. Data Seed Contributors
**Rule**: Use `IDataSeedContributor` for test data setup

```csharp
// ✅ Correct - Test data seeder
public class MyProjectTestDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    public static readonly Guid TestBookId = Guid.Parse("2b5d1b8d-6b5a-4d5e-8b5a-1b5d1b8d6b5a");

    private readonly IBookRepository _bookRepository;
    private readonly IGuidGenerator _guidGenerator;

    public MyProjectTestDataSeedContributor(
        IBookRepository bookRepository,
        IGuidGenerator guidGenerator)
    {
        _bookRepository = bookRepository;
        _guidGenerator = guidGenerator;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        await _bookRepository.InsertAsync(
            new Book(TestBookId, "Test Book", 19.99m, Guid.Empty),
            autoSave: true
        );

        await _bookRepository.InsertAsync(
            new Book(_guidGenerator.Create(), "Another Book", 29.99m, Guid.Empty),
            autoSave: true
        );
    }
}
```

### 2. Test Data Constants
```csharp
// ✅ Correct - Test data constants
public static class TestData
{
    public static readonly Guid UserId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567890");
    public static readonly Guid TenantId = Guid.Parse("b2c3d4e5-f6a7-8901-bcde-f234567890ab");
    public static readonly string TestUserName = "test.user";
    public static readonly string TestBookName = "Test Book";
}
```

## Authorization in Tests

### 1. Disabling Authorization
**Rule**: Disable authorization for testing with `AddAlwaysAllowAuthorization()`

```csharp
// ✅ Correct - Disable authorization in test base
public override void ConfigureServices(ServiceConfigurationContext context)
{
    context.Services.AddAlwaysAllowAuthorization();
}

// Or in specific test class
public override void ConfigureServices(ServiceConfigurationContext context)
{
    Configure<AbpAuthorizationOptions>(options =>
    {
        options.IsEnabled = false;
    });
}
```

### 2. Testing with Specific Users
**Rule**: Use `CurrentUser.Change()` to test with specific user context

```csharp
// ✅ Correct - Test with specific user
[Fact]
public async Task Should_Get_Current_User_Books()
{
    // Login as specific user
    await WithUnitOfWorkAsync(async () =>
    {
        using (CurrentUser.Change(TestData.UserId))
        {
            var result = await _bookAppService.GetMyBooksAsync();
            result.Items.ShouldAllBe(b => b.CreatorId == TestData.UserId);
        }
    });
}

// ✅ Correct - Test permissions
[Fact]
public async Task Should_Allow_Create_Book_When_User_Has_Permission()
{
    using (CurrentUser.Change(TestData.UserId))
    {
        // Setup user with required permissions
        await SetPermissionsAsync(TestData.UserId, MyProjectPermissions.Books.Create);

        // Act
        var result = await _bookAppService.CreateAsync(new CreateBookDto
        {
            Name = "Test Book",
            Price = 19.99m
        });

        // Assert
        result.ShouldNotBeNull();
    }
}
```

## Multi-Tenancy Testing

### 1. Tenant Context Testing
**Rule**: Use `CurrentTenant.Change()` to test tenant filtering

```csharp
// ✅ Correct - Test tenant filtering
[Fact]
public async Task Should_Filter_Books_By_Tenant()
{
    // Create books in different tenants
    using (CurrentTenant.Change(TestData.TenantId))
    {
        await _bookAppService.CreateAsync(new CreateBookDto
        {
            Name = "Tenant1 Book",
            Price = 19.99m
        });
    }

    using (CurrentTenant.Change(Guid.Parse("c3d4e5f6-a7b8-9012-cdef-34567890abcd")))
    {
        await _bookAppService.CreateAsync(new CreateBookDto
        {
            Name = "Tenant2 Book",
            Price = 29.99m
        });
    }

    // Test filtering
    using (CurrentTenant.Change(TestData.TenantId))
    {
        var result = await _bookAppService.GetListAsync(new GetBookListDto());
        result.Items.ShouldAllBe(b => b.TenantId == TestData.TenantId);
        result.Items.ShouldContain(b => b.Name == "Tenant1 Book");
        result.Items.ShouldNotContain(b => b.Name == "Tenant2 Book");
    }
}
```

## Mocking External Services

### 1. NSubstitute Usage
**Rule**: Mock only external services, not ABP internal services

```csharp
// ✅ Correct - Mock external email service
public override void ConfigureServices(ServiceConfigurationContext context)
{
    var emailSender = Substitute.For<IEmailSender>();
    emailSender.SendAsync(Arg.Any<string>(), Arg.Any<string>(), Arg.Any<string>())
        .Returns(Task.CompletedTask);

    context.Services.AddSingleton(emailSender);
}

// Test usage
[Fact]
public async Task Should_Send_Email_When_Book_Created()
{
    // Arrange
    var emailSender = GetRequiredService<IEmailSender>();
    var input = new CreateBookDto { Name = "Test Book", Price = 19.99m };

    // Act
    await _bookAppService.CreateAsync(input);

    // Assert
    await emailSender.Received(1).SendAsync(
        Arg.Any<string>(),
        Arg.Is<string>("Book Created"),
        Arg.Is<string>(s => s.Contains("Test Book"))
    );
}

// ❌ Wrong - Mocking ABP services
public override void ConfigureServices(ServiceConfigurationContext context)
{
    var bookRepository = Substitute.For<IRepository<Book, Guid>>(); // Don't mock ABP repos
    context.Services.AddSingleton(bookRepository);
}
```

## Unit of Work Testing

### 1. WithUnitOfWorkAsync
**Rule**: Use `WithUnitOfWorkAsync` for operations requiring explicit unit of work

```csharp
// ✅ Correct - Use unit of work for complex operations
[Fact]
public async Task Should_Perform_Complex_Operation_With_UnitOfWork()
{
    await WithUnitOfWorkAsync(async () =>
    {
        // Multiple operations within same unit of work
        var book1 = await _bookAppService.CreateAsync(new CreateBookDto
        {
            Name = "Book 1",
            Price = 19.99m
        });

        var book2 = await _bookAppService.CreateAsync(new CreateBookDto
        {
            Name = "Book 2",
            Price = 29.99m
        });

        // Both books should be in same transaction
        var books = await _bookAppService.GetListAsync(new GetBookListDto());
        books.Items.Count.ShouldBeGreaterThanOrEqualTo(2);
    });
}
```

## Validation Rules

### Required Checks
- [ ] Tests inherit from appropriate base classes
- [ ] Use `GetRequiredService<T>()` instead of mocking ABP services
- [ ] Follow `Should_ExpectedBehavior_When_Condition` naming convention
- [ ] Use Shouldly assertions for readability
- [ ] Test data is created via `IDataSeedContributor`
- [ ] Authorization is properly configured for tests
- [ ] Multi-tenancy tests use `CurrentTenant.Change()`
- [ ] External services are mocked with NSubstitute
- [ ] Each test is independent with fresh database

### Test Quality Checks
- [ ] Tests cover happy path scenarios
- [ ] Tests cover error conditions and edge cases
- [ ] Tests validate business rules
- [ ] Tests verify permissions and authorization
- [ ] Tests include multi-tenancy scenarios
- [ ] Test data is meaningful and realistic
- [ ] Tests are fast and reliable

### Performance Considerations
- [ ] Use in-memory SQLite database
- [ ] Avoid unnecessary database operations
- [ ] Reuse test data where appropriate
- [ ] Keep tests focused on single behavior

## Common Anti-Patterns

### 1. Mocking ABP Services
```csharp
// ❌ Wrong - Don't mock ABP internal services
var mockRepo = new Mock<IRepository<Book, Guid>>();
var service = new BookAppService(mockRepo.Object);
```

### 2. Poor Test Organization
```csharp
// ❌ Wrong - Multiple behaviors in one test
[Fact]
public async Task Test_Book_Operations()
{
    // Creating
    var created = await _bookAppService.CreateAsync(input);
    
    // Updating
    var updated = await _bookAppService.UpdateAsync(created.Id, updateInput);
    
    // Deleting
    await _bookAppService.DeleteAsync(created.Id);
    
    // Too many operations in one test
}
```

### 3. Missing Test Data Setup
```csharp
// ❌ Wrong - No test data setup
[Fact]
public async Task Should_Get_Books()
{
    var result = await _bookAppService.GetListAsync();
    result.Items.ShouldBeEmpty(); // Might fail if other tests left data
}
```

This rule ensures consistent, reliable, and maintainable tests for ABP applications following the framework's testing philosophy and best practices.
