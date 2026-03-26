---
name: blazor-components
description: Complete Blazor component development with modern patterns, state management, and best practices
---

# Blazor Components Skill

## When to Use This Skill

Use this skill when you need to:
- Design and implement reusable Blazor components
- Apply modern Blazor patterns and best practices
- Implement proper state management and data flow
- Create responsive and accessible UI components
- Optimize component performance and rendering
- Handle component lifecycle and events properly

## Prerequisites

- .NET 6+ Blazor project (Server, WebAssembly, or Hybrid)
- Understanding of Razor syntax and C#
- Familiarity with HTML, CSS, and JavaScript concepts
- Knowledge of component lifecycle and state management

## Step-by-Step Workflows

### 1. Component Design

**Input**: UI requirements and component specifications  
**Output: Complete Blazor component with proper structure

```
Create a Blazor component with these requirements:

1. Design component interface and parameters
2. Implement proper Razor syntax and markup
3. Add event handlers and user interactions
4. Include CSS styling and responsive design
5. Implement accessibility features
6. Add error handling and validation
7. Create component documentation
```

### 2. State Management

**Input**: Component state requirements and data flow  
**Output: Proper state management with patterns

```
Implement state management for this component:

1. Choose appropriate state management approach
2. Implement parameter binding and cascading parameters
3. Handle component lifecycle events
4. Manage local vs. shared state
5. Implement proper data flow patterns
6. Add state validation and error handling
7. Optimize state updates and re-renders
```

### 3. Performance Optimization

**Input**: Component performance requirements  
**Output: Optimized component with efficient rendering

```
Optimize this Blazor component for better performance:

1. Implement proper component lifecycle management
2. Use virtualization for large datasets
3. Optimize event handling and debouncing
4. Implement lazy loading and code splitting
5. Use proper disposal patterns
6. Minimize unnecessary re-renders
7. Add performance monitoring and debugging
```

## Core Component Patterns

### Basic Component Structure

```csharp
@* Component file: UserCard.razor *@

@* Directives *@
@implements IDisposable
@inject IUserService UserService
@inject ILogger<UserCard> Logger

@* Parameters *@
@typeparam TItem
@* [Parameter] public TItem User { get; set; } *@

@* Cascading parameters *@
@* [CascadingParameter] public Theme CurrentTheme { get; set; } *@

@* Fields and properties *@
@{
    var userClass = $"user-card {(User.IsActive ? "active" : "inactive")}";
    var avatarUrl = $"/api/users/{User.Id}/avatar";
}

<div class="@userClass" @onclick="OnCardClick">
    <div class="user-avatar">
        <img src="@avatarUrl" alt="@User.Name" class="avatar-image" />
        @if (User.IsOnline)
        {
            <div class="online-indicator"></div>
        }
    </div>
    
    <div class="user-info">
        <h3 class="user-name">@User.Name</h3>
        <p class="user-email">@User.Email</p>
        <div class="user-status">
            <span class="status-dot status-@User.Status.ToString().ToLower()"></span>
            <span class="status-text">@User.Status</span>
        </div>
    </div>
    
    <div class="user-actions">
        <button class="btn btn-primary" @onclick="EditUser">Edit</button>
        <button class="btn btn-secondary" @onclick="SendMessage">Message</button>
    </div>
</div>

@* Code block *@
@code {
    [Parameter]
    public User User { get; set; } = default!;

    [Parameter]
    public EventCallback<User> OnUserSelected { get; set; }

    [Parameter]
    public bool ShowActions { get; set; } = true;

    [CascadingParameter]
    public Theme CurrentTheme { get; set; } = default!;

    private bool isLoading = false;

    protected override void OnInitialized()
    {
        Logger.LogInformation("UserCard component initialized for user {UserId}", User.Id);
    }

    protected override void OnParametersSet()
    {
        // Handle parameter changes
        Logger.LogDebug("UserCard parameters updated for user {UserId}", User.Id);
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            // Perform one-time operations
            await LoadAdditionalUserData();
        }
    }

    private async Task LoadAdditionalUserData()
    {
        try
        {
            isLoading = true;
            StateHasChanged();
            
            // Load additional data
            await UserService.GetUserDetailsAsync(User.Id);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Failed to load additional user data for {UserId}", User.Id);
        }
        finally
        {
            isLoading = false;
            StateHasChanged();
        }
    }

    private async Task OnCardClick()
    {
        await OnUserSelected.InvokeAsync(User);
    }

    private async Task EditUser()
    {
        // Navigate to edit page or open modal
        Logger.LogInformation("Edit user clicked for {UserId}", User.Id);
    }

    private async Task SendMessage()
    {
        // Open message dialog
        Logger.LogInformation("Send message clicked for {UserId}", User.Id);
    }

    public void Dispose()
    {
        Logger.LogInformation("UserCard component disposed for user {UserId}", User.Id);
    }
}
```

### Component Base Class

```csharp
// BaseComponent.cs
public abstract class BaseComponent : ComponentBase, IDisposable
{
    [Inject]
    protected ILogger<BaseComponent> Logger { get; set; } = default!;

    protected bool IsLoading { get; set; }
    protected string? ErrorMessage { get; set; }

    protected override async Task OnInitializedAsync()
    {
        try
        {
            await InitializeComponentAsync();
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error initializing component {ComponentType}", GetType().Name);
            ErrorMessage = ex.Message;
        }
    }

    protected virtual Task InitializeComponentAsync()
    {
        return Task.CompletedTask;
    }

    protected async Task ExecuteWithErrorHandling(Func<Task> operation, string operationName)
    {
        try
        {
            IsLoading = true;
            ErrorMessage = null;
            StateHasChanged();

            await operation();
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error in {OperationName}", operationName);
            ErrorMessage = ex.Message;
        }
        finally
        {
            IsLoading = false;
            StateHasChanged();
        }
    }

    protected async Task<T> ExecuteWithErrorHandling<T>(Func<Task<T>> operation, string operationName)
    {
        try
        {
            IsLoading = true;
            ErrorMessage = null;
            StateHasChanged();

            return await operation();
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Error in {OperationName}", operationName);
            ErrorMessage = ex.Message;
            return default(T)!;
        }
        finally
        {
            IsLoading = false;
            StateHasChanged();
        }
    }

    public virtual void Dispose()
    {
        // Cleanup resources
    }
}
```

### Reusable Component with Templates

```csharp
@* DataList.razor *@

@typeparam TItem

@if (Items != null && Items.Any())
{
    <div class="data-list">
        @if (HeaderTemplate != null)
        {
            <div class="data-list-header">
                @HeaderTemplate
            </div>
        }

        <div class="data-list-items">
            @foreach (var item in Items)
            {
                <div class="data-list-item" @onclick="() => OnItemClick?.Invoke(item)">
                    @if (ItemTemplate != null)
                    {
                        @ItemTemplate(item)
                    }
                    else
                    {
                        <div class="default-item-template">
                            @item.ToString()
                        </div>
                    }
                </div>
            }
        </div>

        @if (FooterTemplate != null)
        {
            <div class="data-list-footer">
                @FooterTemplate
            </div>
        }
    </div>
}
else
{
    @if (EmptyTemplate != null)
    {
        @EmptyTemplate
    }
    else
    {
        <div class="data-list-empty">
            <p>No items to display</p>
        </div>
    }
}

@code {
    [Parameter]
    public IEnumerable<TItem>? Items { get; set; }

    [Parameter]
    public RenderFragment<TItem>? ItemTemplate { get; set; }

    [Parameter]
    public RenderFragment? HeaderTemplate { get; set; }

    [Parameter]
    public RenderFragment? FooterTemplate { get; set; }

    [Parameter]
    public RenderFragment? EmptyTemplate { get; set; }

    [Parameter]
    public EventCallback<TItem>? OnItemClick { get; set; }
}
```

## State Management Patterns

### Component State

```csharp
@* Counter.razor *@

@page "/counter"

<PageTitle>Counter</PageTitle>

<h1>Counter</h1>

<p role="status">Current count: @currentCount</p>

<button class="btn btn-primary" @onclick="IncrementCount">Click me</button>

@code {
    private int currentCount = 0;

    private void IncrementCount()
    {
        currentCount++;
    }
}
```

### Parameter Binding

```csharp
@* UserProfile.razor *@

<div class="user-profile">
    <h3>@User.Name</h3>
    <p>Email: @User.Email</p>
    <p>Role: @User.Role</p>
    
    <button class="btn btn-sm" @onclick="ToggleEditMode">
        @(isEditMode ? "Cancel" : "Edit")
    </button>
</div>

@if (isEditMode)
{
    <div class="edit-form">
        <EditForm Model="@User" OnValidSubmit="HandleValidSubmit">
            <DataAnnotationsValidator />
            <ValidationSummary />
            
            <div class="form-group">
                <label for="name">Name:</label>
                <InputText id="name" @bind-Value="User.Name" class="form-control" />
                <ValidationMessage For="@(() => User.Name)" />
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <InputText id="email" @bind-Value="User.Email" class="form-control" />
                <ValidationMessage For="@(() => User.Email)" />
            </div>
            
            <button type="submit" class="btn btn-primary">Save</button>
        </EditForm>
    </div>
}

@code {
    [Parameter]
    public User User { get; set; } = default!;

    [Parameter]
    public EventCallback<User> OnUserUpdated { get; set; }

    private bool isEditMode = false;

    private void ToggleEditMode()
    {
        isEditMode = !isEditMode;
    }

    private async Task HandleValidSubmit()
    {
        await OnUserUpdated.InvokeAsync(User);
        isEditMode = false;
    }
}
```

### Cascading Parameters

```csharp
@* ThemeProvider.razor *@

<CascadingValue Value="@currentTheme" IsFixed="false">
    @ChildContent
</CascadingValue>

@code {
    [Parameter]
    public RenderFragment? ChildContent { get; set; }

    private Theme currentTheme = new Theme();

    protected override void OnInitialized()
    {
        // Initialize theme from user preferences or system
        currentTheme = Theme.LoadFromPreferences();
    }

    public void UpdateTheme(Theme newTheme)
    {
        currentTheme = newTheme;
        StateHasChanged();
    }
}

@* ThemedComponent.razor *@

<div class="themed-component @GetThemeClass()">
    <h3>Themed Component</h3>
    <p>Current theme: @CurrentTheme.Name</p>
    <p>Primary color: @CurrentTheme.PrimaryColor</p>
</div>

@code {
    [CascadingParameter]
    public Theme CurrentTheme { get; set; } = default!;

    private string GetThemeClass()
    {
        return CurrentTheme.IsDark ? "dark-theme" : "light-theme";
    }
}
```

## Event Handling

### Event Callbacks

```csharp
@* ButtonComponent.razor *@

<button class="@GetButtonClass()" @onclick="OnClick" disabled="@IsDisabled">
    @if (IsLoading)
    {
        <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
        <span class="sr-only">Loading...</span>
    }
    else
    {
        @Text
    }
</button>

@code {
    [Parameter]
    public string Text { get; set; } = "Button";

    [Parameter]
    public ButtonVariant Variant { get; set; } = ButtonVariant.Primary;

    [Parameter]
    public ButtonSize Size { get; set; } = ButtonSize.Medium;

    [Parameter]
    public bool IsDisabled { get; set; }

    [Parameter]
    public bool IsLoading { get; set; }

    [Parameter]
    public EventCallback OnClick { get; set; }

    private string GetButtonClass()
    {
        var classes = new List<string> { "btn" };
        
        classes.Add($"btn-{Variant.ToString().ToLower()}");
        classes.Add($"btn-{Size.ToString().ToLower()}");
        
        if (IsDisabled) classes.Add("disabled");
        if (IsLoading) classes.Add("loading");

        return string.Join(" ", classes);
    }

    private async Task HandleClick()
    {
        if (!IsDisabled && !IsLoading)
        {
            await OnClick.InvokeAsync();
        }
    }
}
```

### Custom Events

```csharp
@* FileUpload.razor *@

<div class="file-upload" @ondragover="HandleDragOver" @ondragleave="HandleDragLeave" @ondrop="HandleDrop">
    <input type="file" @ref="fileInput" @onchange="HandleFileSelect" multiple hidden />
    
    <div class="upload-area @GetUploadClass()" @onclick="SelectFiles">
        @if (IsDragging)
        {
            <p>Drop files here</p>
        }
        else
        {
            <p>Click to select files or drag and drop</p>
        }
    </div>

    @if (Files.Any())
    {
        <div class="file-list">
            @foreach (var file in Files)
            {
                <div class="file-item">
                    <span class="file-name">@file.Name</span>
                    <span class="file-size">@FormatFileSize(file.Size)</span>
                    <button class="btn btn-sm btn-danger" @onclick="() => RemoveFile(file)">Remove</button>
                </div>
            }
        </div>
    }
</div>

@code {
    private ElementReference fileInput;
    private List<FileInfo> Files = new();
    private bool isDragging = false;

    [Parameter]
    public EventCallback<List<FileInfo>> OnFilesChanged { get; set; }

    [Parameter]
    public string[] AllowedExtensions { get; set; } = { ".jpg", ".jpeg", ".png", ".gif", ".pdf" };

    [Parameter]
    public long MaxFileSize { get; set; } = 10 * 1024 * 1024; // 10MB

    public bool IsDragging => isDragging;

    private async Task SelectFiles()
    {
        await fileInput.InvokeAsync("click");
    }

    private async Task HandleFileSelect(ChangeEventArgs e)
    {
        var files = (IEnumerable<FileInfo>)e.Value;
        await AddFiles(files);
    }

    private void HandleDragOver(DragEventArgs e)
    {
        isDragging = true;
    }

    private void HandleDragLeave(DragEventArgs e)
    {
        isDragging = false;
    }

    private async Task HandleDrop(DragEventArgs e)
    {
        isDragging = false;
        
        var files = e.DataTransfer.GetFiles();
        await AddFiles(files);
    }

    private async Task AddFiles(IEnumerable<FileInfo> files)
    {
        var validFiles = new List<FileInfo>();

        foreach (var file in files)
        {
            if (IsValidFile(file))
            {
                validFiles.Add(file);
            }
        }

        Files.AddRange(validFiles);
        await OnFilesChanged.InvokeAsync(Files);
    }

    private bool IsValidFile(FileInfo file)
    {
        var extension = Path.GetExtension(file.Name).ToLowerInvariant();
        return AllowedExtensions.Contains(extension) && file.Size <= MaxFileSize;
    }

    private async Task RemoveFile(FileInfo file)
    {
        Files.Remove(file);
        await OnFilesChanged.InvokeAsync(Files);
    }

    private string GetUploadClass()
    {
        return isDragging ? "dragging" : "";
    }

    private string FormatFileSize(long bytes)
    {
        string[] suffixes = { "B", "KB", "MB", "GB" };
        int counter = 0;
        decimal number = bytes;
        while (Math.Round(number / 1024) >= 1)
        {
            number /= 1024;
            counter++;
        }
        return $"{number:n1} {suffixes[counter]}";
    }
}
```

## Performance Optimization

### Virtualization

```csharp
@* VirtualizedList.razor *@

@using Microsoft.AspNetCore.Components.Web.Virtualization

<div class="virtualized-list" style="height: @Height">
    <Virtualize Items="@Items" OverscanCount="10" Context="item">
        <div class="list-item">
            @ItemTemplate(item)
        </div>
    </Virtualize>
</div>

@code {
    [Parameter]
    public IEnumerable<TItem> Items { get; set; } = default!;

    [Parameter]
    public RenderFragment<TItem> ItemTemplate { get; set; } = default!;

    [Parameter]
    public string Height { get; set; } = "400px";
}
```

### Lazy Loading

```csharp
@* LazyImage.razor *@

<div class="lazy-image @GetImageClass()" @onscroll="HandleScroll" @onload="OnImageLoad">
    @if (!isVisible)
    {
        <div class="placeholder">
            <div class="spinner"></div>
            <p>Loading...</p>
        </div>
    }
    else if (!hasLoaded)
    {
        <img src="@PlaceholderSrc" alt="@Alt" class="placeholder-image" />
    }
    else
    {
        <img src="@Src" alt="@Alt" class="loaded-image" @onload="OnImageLoad" />
    }
</div>

@code {
    [Parameter]
    public string Src { get; set; } = default!;

    [Parameter]
    public string PlaceholderSrc { get; set; } = "/images/placeholder.png";

    [Parameter]
    public string Alt { get; set; } = "";

    [Parameter]
    public string Height { get; set; } = "200px";

    private bool isVisible = false;
    private bool hasLoaded = false;

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await CheckVisibility();
        }
    }

    private async Task HandleScroll()
    {
        await CheckVisibility();
    }

    private async Task CheckVisibility()
    {
        // Implement intersection observer logic
        // For simplicity, we'll make it visible immediately
        isVisible = true;
        StateHasChanged();
    }

    private void OnImageLoad()
    {
        hasLoaded = true;
        StateHasChanged();
    }

    private string GetImageClass()
    {
        if (!isVisible) return "not-visible";
        if (!hasLoaded) return "loading";
        return "loaded";
    }
}
```

### Debouncing

```csharp
@* SearchBox.razor *@

<div class="search-box">
    <input 
        type="text" 
        class="form-control" 
        placeholder="@Placeholder"
        @bind-value="searchText" 
        @bind-value:event="oninput"
        @oninput="OnSearchInput" />
    
    @if (IsSearching)
    {
        <div class="search-indicator">
            <span class="spinner-border spinner-border-sm"></span>
        </div>
    }
</div>

@code {
    [Parameter]
    public string Placeholder { get; set; } = "Search...";

    [Parameter]
    public int DebounceMs { get; set; } = 300;

    [Parameter]
    public EventCallback<string> OnSearch { get; set; }

    private string searchText = string.Empty;
    private bool isSearching = false;
    private Timer? debounceTimer;

    public bool IsSearching => isSearching;

    private void OnSearchInput(ChangeEventArgs e)
    {
        searchText = e.Value?.ToString() ?? string.Empty;
        
        // Cancel previous timer
        debounceTimer?.Dispose();
        
        // Start new timer
        debounceTimer = new Timer(async _ =>
        {
            await InvokeAsync(async () =>
            {
                isSearching = true;
                StateHasChanged();
                
                await OnSearch.InvokeAsync(searchText);
                
                isSearching = false;
                StateHasChanged();
            });
        }, null, TimeSpan.FromMilliseconds(DebounceMs), Timeout.InfiniteTimeSpan);
    }

    public void Dispose()
    {
        debounceTimer?.Dispose();
    }
}
```

## Accessibility

### Accessible Component

```csharp
@* AccessibleButton.razor *@

<button 
    class="accessible-button @GetButtonClass()" 
    @onclick="OnClick"
    disabled="@IsDisabled"
    aria-label="@AriaLabel"
    aria-describedby="@AriaDescribedBy"
    @onclick:preventDefault="@PreventDefault">
    
    @if (ShowIcon && !string.IsNullOrEmpty(Icon))
    {
        <span class="button-icon" aria-hidden="true">@Icon</span>
    }
    
    <span class="button-text">@Text</span>
    
    @if (ShowLoading && IsLoading)
    {
        <span class="loading-indicator" aria-label="Loading" aria-live="polite">
            <span class="spinner-border spinner-border-sm"></span>
            <span class="sr-only">Loading...</span>
        </span>
    }
</button>

@if (!string.IsNullOrEmpty(AriaDescribedById))
{
    <div id="@AriaDescribedById" class="sr-only">
        @AriaDescription
    </div>
}

@code {
    [Parameter]
    public string Text { get; set; } = string.Empty;

    [Parameter]
    public string? Icon { get; set; }

    [Parameter]
    public bool ShowIcon { get; set; } = true;

    [Parameter]
    public ButtonVariant Variant { get; set; } = ButtonVariant.Primary;

    [Parameter]
    public bool IsDisabled { get; set; }

    [Parameter]
    public bool IsLoading { get; set; }

    [Parameter]
    public bool ShowLoading { get; set; } = true;

    [Parameter]
    public bool PreventDefault { get; set; } = false;

    [Parameter]
    public string AriaLabel { get; set; } = string.Empty;

    [Parameter]
    public string? AriaDescription { get; set; }

    [Parameter]
    public string? AriaDescribedById { get; set; }

    [Parameter]
    public EventCallback OnClick { get; set; }

    private string GetButtonClass()
    {
        var classes = new List<string> { "btn" };
        classes.Add($"btn-{Variant.ToString().ToLower()}");
        
        if (IsDisabled) classes.Add("disabled");
        if (IsLoading) classes.Add("loading");

        return string.Join(" ", classes);
    }

    protected override void OnParametersSet()
    {
        // Generate unique ID for aria-describedby if not provided
        if (!string.IsNullOrEmpty(AriaDescription) && string.IsNullOrEmpty(AriaDescribedById))
        {
            AriaDescribedById = $"button-desc-{Guid.NewGuid():N}";
        }
    }
}
```

## Testing

### Component Testing

```csharp
// UserCardTests.cs
public class UserCardTests : TestContext
{
    [Fact]
    public void UserCard_RendersCorrectly_WithValidUser()
    {
        // Arrange
        var user = new User
        {
            Id = 1,
            Name = "John Doe",
            Email = "john@example.com",
            IsActive = true,
            Status = UserStatus.Online
        };

        // Act
        var component = RenderComponent<UserCard>(parameters => parameters
            .Add(p => p.User, user));

        // Assert
        component.Find("h3").TextContent.Should().Be("John Doe");
        component.Find(".user-email").TextContent.Should().Be("john@example.com");
        component.Find(".user-card").ClassList.Should().Contain("active");
        component.Find(".status-online").Should().NotBeNull();
    }

    [Fact]
    public void UserCard_TriggerOnUserSelected_WhenClicked()
    {
        // Arrange
        var user = new User { Id = 1, Name = "John Doe" };
        var clickedUser = new User();
        
        var component = RenderComponent<UserCard>(parameters => parameters
            .Add(p => p.User, user)
            .Add(p => p.OnUserSelected, EventCallback<User>.Create(
                (User u) => clickedUser = u)));

        // Act
        component.Find(".user-card").Click();

        // Assert
        clickedUser.Should().Be(user);
    }

    [Fact]
    public void UserCard_ShowsActions_WhenShowActionsIsTrue()
    {
        // Arrange
        var user = new User { Id = 1, Name = "John Doe" };

        // Act
        var component = RenderComponent<UserCard>(parameters => parameters
            .Add(p => p.User, user)
            .Add(p => p.ShowActions, true));

        // Assert
        component.Find(".user-actions").Should().NotBeNull();
        component.FindAll("button").Count.Should().Be(2);
    }
}
```

## Best Practices

### Do's
- ✅ Use semantic HTML elements
- ✅ Implement proper accessibility features
- ✅ Handle component lifecycle correctly
- ✅ Use proper state management patterns
- ✅ Optimize performance with virtualization
- ✅ Implement proper error handling
- ✅ Use CSS isolation for styling
- ✅ Create reusable and composable components
- ✅ Test components thoroughly
- ✅ Document component APIs

### Don'ts
- ❌ Ignore accessibility requirements
- ❌ Mix business logic with UI logic
- ❌ Create monolithic components
- ❌ Ignore performance implications
- ❌ Forget to dispose resources
- ❌ Use global CSS without isolation
- ❌ Skip error handling
- ❌ Create tightly coupled components
- ❌ Forget to test components
- ❌ Skip documentation

## References

- [Blazor Documentation](https://docs.microsoft.com/en-us/aspnet/core/blazor/)
- [ASP.NET Core Component Best Practices](https://docs.microsoft.com/en-us/aspnet/core/blazor/components/)
- [Blazor Performance Best Practices](https://docs.microsoft.com/en-us/aspnet/core/blazor/performance/)
- [Web Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**This skill provides comprehensive guidance for building modern, accessible, and performant Blazor components. Use it to create reusable UI components that follow best practices and provide excellent user experiences.**
