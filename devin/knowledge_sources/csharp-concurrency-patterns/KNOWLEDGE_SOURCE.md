# C# Concurrency Patterns - Async/Await, Channels e Paralelismo

## Visao Geral

Padroes de concorrencia em C#/.NET cobrindo async/await, System.Threading.Channels, Parallel.ForEachAsync e decisoes arquiteturais sobre quando usar cada abordagem. Foco em evitar locks e sincronizacao manual.

## Arvore de Decisao de Concorrencia

```text
Preciso de concorrencia?
├── I/O-bound (HTTP, DB, files)?
│   └── async/await
│       ├── Unica operacao → await Task
│       ├── Multiplas independentes → Task.WhenAll
│       └── Streaming → IAsyncEnumerable<T>
├── CPU-bound (calculo, processamento)?
│   └── Parallel.ForEachAsync / Task.Run
│       ├── Colecao finita → Parallel.ForEachAsync
│       └── Operacao unica → Task.Run (offload)
├── Producer/Consumer?
│   └── System.Threading.Channels
│       ├── Bounded → Channel.CreateBounded<T>
│       └── Unbounded → Channel.CreateUnbounded<T>
└── Stateful Entity Management?
    └── Akka.NET / Orleans
```

## Async/Await Patterns

### Basico Correto

```csharp
// ✅ Sempre propagar CancellationToken
public async Task<UserDto> GetUserAsync(int id, CancellationToken cancellationToken = default)
{
    var user = await _dbContext.Users
        .AsNoTracking()
        .FirstOrDefaultAsync(u => u.Id == id, cancellationToken)
        ?? throw new NotFoundException($"Usuario {id} nao encontrado");

    return user.ToDto();
}

// ✅ Multiplas operacoes independentes em paralelo
public async Task<DashboardDto> GetDashboardAsync(CancellationToken cancellationToken)
{
    var usersTask = _userService.GetActiveUsersCountAsync(cancellationToken);
    var ordersTask = _orderService.GetTodayOrdersAsync(cancellationToken);
    var revenueTask = _revenueService.GetMonthlyRevenueAsync(cancellationToken);

    await Task.WhenAll(usersTask, ordersTask, revenueTask);

    return new DashboardDto(
        ActiveUsers: await usersTask,
        TodayOrders: await ordersTask,
        MonthlyRevenue: await revenueTask);
}

// ❌ NUNCA bloquear thread async
public UserDto GetUser(int id)
{
    // ERRADO - pode causar deadlock
    return GetUserAsync(id).Result;
    // ERRADO - pode causar deadlock
    return GetUserAsync(id).GetAwaiter().GetResult();
}
```

### ValueTask para Hot Paths

```csharp
// ✅ ValueTask quando resultado geralmente ja esta disponivel (cache)
public ValueTask<ProductDto?> GetProductAsync(int id, CancellationToken cancellationToken)
{
    if (_cache.TryGetValue(id, out var cached))
    {
        return ValueTask.FromResult<ProductDto?>(cached); // Sem alocacao
    }

    return GetProductFromDatabaseAsync(id, cancellationToken);
}

private async ValueTask<ProductDto?> GetProductFromDatabaseAsync(
    int id, CancellationToken cancellationToken)
{
    var product = await _dbContext.Products
        .AsNoTracking()
        .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);

    if (product is not null)
    {
        _cache.Set(id, product.ToDto(), TimeSpan.FromMinutes(5));
    }

    return product?.ToDto();
}
```

### IAsyncEnumerable para Streaming

```csharp
// ✅ Streaming de dados grandes sem carregar tudo em memoria
public async IAsyncEnumerable<UserDto> StreamUsersAsync(
    [EnumeratorCancellation] CancellationToken cancellationToken = default)
{
    await foreach (var user in _dbContext.Users
        .AsNoTracking()
        .AsAsyncEnumerable()
        .WithCancellation(cancellationToken))
    {
        yield return user.ToDto();
    }
}

// Consumo no endpoint
app.MapGet("/v1/usuarios/stream", async (
    IUserRepository repository,
    CancellationToken cancellationToken) =>
{
    return Results.Ok(repository.StreamUsersAsync(cancellationToken));
});
```

## System.Threading.Channels

### Producer/Consumer Pattern

```csharp
// Background service com Channel para processamento de eventos
public sealed class EventProcessingService : BackgroundService
{
    private readonly Channel<DomainEvent> _channel;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<EventProcessingService> _logger;

    public EventProcessingService(
        IServiceScopeFactory scopeFactory,
        ILogger<EventProcessingService> logger)
    {
        _channel = Channel.CreateBounded<DomainEvent>(new BoundedChannelOptions(1000)
        {
            FullMode = BoundedChannelFullMode.Wait,
            SingleReader = false,
            SingleWriter = false,
        });
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    // Producer - chamado por qualquer servico
    public async ValueTask PublishAsync(DomainEvent @event, CancellationToken cancellationToken)
    {
        await _channel.Writer.WriteAsync(@event, cancellationToken);
    }

    // Consumer - processa eventos em background
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        // Multiplos consumers para paralelismo
        var consumers = Enumerable.Range(0, Environment.ProcessorCount)
            .Select(_ => ConsumeAsync(stoppingToken));

        await Task.WhenAll(consumers);
    }

    private async Task ConsumeAsync(CancellationToken stoppingToken)
    {
        await foreach (var @event in _channel.Reader.ReadAllAsync(stoppingToken))
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var handler = scope.ServiceProvider
                    .GetRequiredService<IEventHandler<DomainEvent>>();

                await handler.HandleAsync(@event, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao processar evento: {EventType}",
                    @event.GetType().Name);
            }
        }
    }
}
```

### Pipeline Pattern com Channels

```csharp
// Pipeline de processamento de dados em etapas
public sealed class DataPipeline
{
    public async Task<int> ProcessAsync(
        IAsyncEnumerable<RawData> source,
        CancellationToken cancellationToken)
    {
        var validated = CreateStage<RawData, ValidatedData>(
            source, ValidateAsync, maxConcurrency: 4, cancellationToken);

        var transformed = CreateStage<ValidatedData, TransformedData>(
            validated, TransformAsync, maxConcurrency: 8, cancellationToken);

        var saved = CreateStage<TransformedData, SaveResult>(
            transformed, SaveAsync, maxConcurrency: 2, cancellationToken);

        var count = 0;
        await foreach (var result in saved.WithCancellation(cancellationToken))
        {
            count++;
        }

        return count;
    }

    private static async IAsyncEnumerable<TOut> CreateStage<TIn, TOut>(
        IAsyncEnumerable<TIn> source,
        Func<TIn, CancellationToken, Task<TOut>> processor,
        int maxConcurrency,
        [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        var channel = Channel.CreateBounded<TOut>(maxConcurrency * 2);

        _ = Task.Run(async () =>
        {
            try
            {
                await Parallel.ForEachAsync(
                    source,
                    new ParallelOptions
                    {
                        MaxDegreeOfParallelism = maxConcurrency,
                        CancellationToken = cancellationToken,
                    },
                    async (item, ct) =>
                    {
                        var result = await processor(item, ct);
                        await channel.Writer.WriteAsync(result, ct);
                    });
            }
            finally
            {
                channel.Writer.Complete();
            }
        }, cancellationToken);

        await foreach (var item in channel.Reader.ReadAllAsync(cancellationToken))
        {
            yield return item;
        }
    }
}
```

## Parallel.ForEachAsync

```csharp
// ✅ Processamento paralelo de colecao com controle de concorrencia
public async Task ProcessUsersAsync(
    IReadOnlyCollection<int> userIds,
    CancellationToken cancellationToken)
{
    await Parallel.ForEachAsync(
        userIds,
        new ParallelOptions
        {
            MaxDegreeOfParallelism = 10,
            CancellationToken = cancellationToken,
        },
        async (userId, ct) =>
        {
            var user = await _userService.GetUserAsync(userId, ct);
            await _notificationService.SendAsync(user, ct);
        });
}

// ✅ Com rate limiting
public async Task CallExternalApiAsync(
    IReadOnlyCollection<Request> requests,
    CancellationToken cancellationToken)
{
    using var semaphore = new SemaphoreSlim(5); // Max 5 chamadas simultaneas

    var tasks = requests.Select(async request =>
    {
        await semaphore.WaitAsync(cancellationToken);
        try
        {
            return await _httpClient.PostAsJsonAsync("/api/process", request, cancellationToken);
        }
        finally
        {
            semaphore.Release();
        }
    });

    await Task.WhenAll(tasks);
}
```

## Padroes para Evitar

```csharp
// ❌ NUNCA usar lock com async
private readonly object _lock = new();
public async Task BadAsync()
{
    lock (_lock)
    {
        await Task.Delay(100); // ERRO DE COMPILACAO - e bom!
    }
}

// ✅ Usar SemaphoreSlim para exclusao mutua async
private readonly SemaphoreSlim _semaphore = new(1, 1);
public async Task GoodAsync(CancellationToken cancellationToken)
{
    await _semaphore.WaitAsync(cancellationToken);
    try
    {
        await DoWorkAsync(cancellationToken);
    }
    finally
    {
        _semaphore.Release();
    }
}

// ❌ NUNCA usar Task.Run para wrapping de metodo sync em web API
public async Task<IResult> BadEndpoint()
{
    var result = await Task.Run(() => SyncComputation()); // Desperdicando thread
    return Results.Ok(result);
}

// ✅ Se o metodo e sync, mantenha sync no endpoint
public IResult GoodEndpoint()
{
    var result = SyncComputation();
    return Results.Ok(result);
}
```

## Timeout e Cancelamento

```csharp
// ✅ Timeout composto com CancellationTokenSource
public async Task<HttpResponseMessage> CallWithTimeoutAsync(
    string url,
    CancellationToken cancellationToken)
{
    using var timeoutCts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(
        cancellationToken, timeoutCts.Token);

    try
    {
        return await _httpClient.GetAsync(url, linkedCts.Token);
    }
    catch (OperationCanceledException) when (timeoutCts.IsCancellationRequested)
    {
        throw new TimeoutException($"Timeout ao chamar {url}");
    }
}
```

---

## Boas Praticas

1. **async/await para I/O**: Usar async/await para operacoes de I/O, nunca para CPU-bound
2. **CancellationToken sempre**: Propagar CancellationToken em toda a cadeia async
3. **Channels para producer/consumer**: Usar System.Threading.Channels ao inves de BlockingCollection
4. **Parallel.ForEachAsync**: Usar para processar colecoes finitas com controle de concorrencia
5. **ValueTask para cache**: Usar ValueTask quando resultado frequentemente ja esta disponivel
6. **Evitar locks**: Preferir SemaphoreSlim, Channels ou patterns imutaveis
7. **Nunca bloquear async**: Nunca usar .Result ou .GetAwaiter().GetResult()
8. **Task.Run com cuidado**: Usar apenas para offload de CPU-bound, nunca para I/O
9. **IAsyncEnumerable**: Usar para streaming de dados grandes
10. **Bounded channels**: Preferir bounded channels para backpressure e controle de memoria
