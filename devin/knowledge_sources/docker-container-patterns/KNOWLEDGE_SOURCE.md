# Docker & Container Orchestration Patterns

## Dockerfile .NET

```dockerfile
# Build stage
FROM dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY ["*.sln", "./"]
COPY ["src/**/*.csproj", "./"]
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime stage
FROM dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app

# Datadog .NET Tracer
ENV DD_DOTNET_TRACER_VERSION=3.27.0
RUN apk add --no-cache curl && \
    curl -L https://github.com/DataDog/dd-trace-dotnet/releases/download/v${DD_DOTNET_TRACER_VERSION}/datadog-dotnet-apm-${DD_DOTNET_TRACER_VERSION}-musl.tar.gz | tar xzf - -C /opt/datadog

# Non-root user
RUN adduser -D -u 1000 appuser
USER appuser

# CORECLR profiling for APM
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_DOTNET_TRACER_HOME=/opt/datadog

# GC server optimization
ENV DOTNET_gcServer=1

EXPOSE 8085
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MyApp.WebApi.dll"]
```

## Docker Compose - Desenvolvimento Local

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8085:8085"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    depends_on:
      wiremock:
        condition: service_healthy
      localstack:
        condition: service_healthy

  wiremock:
    image: wiremock/wiremock:3.3.1
    ports:
      - "8080:8080"
    volumes:
      - ./wiremock/mappings:/home/wiremock/mappings
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/__admin"]
      interval: 10s
      timeout: 5s
      retries: 3

  localstack:
    image: localstack/localstack:3.0
    ports:
      - "4566:4566"
    environment:
      - SERVICES=secretsmanager,sqs,sns
    volumes:
      - ./localstack/init:/etc/localstack/init/ready.d
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4566/_localstack/health"]
      interval: 10s
      timeout: 5s
      retries: 3
```

## Docker Compose - Testes de Integração

```yaml
version: '3.8'
services:
  # Profile: wiremock
  wiremock:
    image: wiremock/wiremock:3.3.1
    profiles: ["wiremock", "all"]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/__admin"]

  # Profile: localstack
  localstack:
    image: localstack/localstack:3.0
    profiles: ["localstack", "all"]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4566/_localstack/health"]

  # Profile: kafka
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    profiles: ["kafka", "all"]

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    profiles: ["kafka", "all"]
    depends_on:
      - zookeeper

  schema-registry:
    image: confluentinc/cp-schema-registry:7.5.0
    profiles: ["kafka", "all"]
    depends_on:
      - kafka

  # Profile: database
  postgres:
    image: postgres:15-alpine
    profiles: ["database", "all"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]

  # Profile: cache
  redis:
    image: redis:7-alpine
    profiles: ["cache", "all"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
```

## Regras Importantes

- Health checks são **obrigatórios** em todos os serviços
- Usar profiles para selecionar stacks específicas nos testes
- Non-root user obrigatório no Dockerfile de produção
- Multi-stage build obrigatório (SDK → Runtime)
