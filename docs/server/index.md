# EvalHub Server

REST API orchestration service for managing LLM evaluation workflows.

## What is the EvalHub Server?

The EvalHub Server is an open source Go application that provides a versioned REST API for evaluation job management, orchestrates Kubernetes Job creation and lifecycle management, and maintains a registry for discovering evaluation providers and benchmarks. It supports curated benchmark collections with weighted scoring, uses SQLite for local development and PostgreSQL for production, and includes structured logging, Prometheus metrics, and health checks for observability.

## Core Capabilities

### Evaluation Job Management

The server manages evaluation jobs through REST API endpoints, supporting job creation from benchmark specifications or curated collections, status monitoring, result retrieval, and job cancellation.

### Provider and Benchmark Discovery

The provider registry enables discovery of evaluation providers and their benchmarks, allowing clients to list registered providers, retrieve provider metadata, enumerate benchmarks, and access benchmark configuration schemas.

### Collection Management

Collections provide curated benchmark sets with weighted scoring, supporting provider-based grouping and domain-specific configurations such as healthcare or finance compliance, all executable through a single API call.


## REST API

The server exposes a versioned REST API at `/api/v1/` following RESTful resource-oriented design with JSON request and response bodies, standard HTTP status codes, and an OpenAPI 3.1.0 specification.

### Core Endpoints

**Evaluation Jobs**:
```
POST   /api/v1/evaluations/jobs        # Create evaluation job
GET    /api/v1/evaluations/jobs        # List jobs
GET    /api/v1/evaluations/jobs/{id}   # Get job details
DELETE /api/v1/evaluations/jobs/{id}   # Cancel job
```

**Providers & Benchmarks**:
```
GET /api/v1/providers               # List providers
GET /api/v1/providers/{id}          # Get provider details
GET /api/v1/benchmarks              # List all benchmarks
GET /api/v1/benchmarks/{id}         # Get benchmark details
```

**Collections**:
```
GET /api/v1/collections             # List collections
GET /api/v1/collections/{id}        # Get collection details
```

**Health & Metrics**:
```
GET /api/v1/health    # Health check
GET /metrics          # Prometheus metrics
```

See [API Reference](api-reference.md) for complete endpoint documentation.

## Configuration

Configuration loads from multiple sources with precedence: base configuration from `config/config.yaml`, environment variable overrides, and secrets from files for sensitive data.

### Example Configuration

**config/config.yaml**:
```yaml
service:
  port: 8080

database:
  host: localhost
  port: 5432
  name: eval_hub
  user: eval_hub

env:
  mappings:
    service.port: PORT
    database.host: DB_HOST

secrets:
  dir: /var/secrets
  mappings:
    database.password: db_password
```

See [Configuration](configuration.md) for comprehensive reference.

## Observability

### Logging

The server uses structured JSON logging with automatic request enrichment, including timestamp, log level, message, request correlation ID, HTTP method and path, and client details. Each log entry captures the full request context for debugging and tracing.

### Health Checks

The server provides health check endpoints at `/api/v1/health` for Kubernetes liveness and readiness probes, verifying server responsiveness and database connectivity to ensure the pod is ready to receive traffic.

## Next Steps

- [API Reference](api-reference.md) - Complete API documentation
