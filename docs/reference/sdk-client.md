# Python Client SDK

The EvalHub Python SDK provides a high-level interface for interacting with the EvalHub REST API. The SDK supports both synchronous and asynchronous operations through separate client classes.

## Installation

Install the SDK from PyPI:

```bash
pip install eval-hub-sdk[client]
```

For development installations:

```bash
git clone https://github.com/eval-hub/eval-hub-sdk.git
cd eval-hub-sdk
pip install -e .[client]
```

## Quick Start

=== "Synchronous"

    ```python
    from evalhub.client import SyncEvalHubClient
    from evalhub.models.api import ModelConfig, EvaluationRequest

    # Create client
    with SyncEvalHubClient(base_url="http://localhost:8080") as client:
        # List available benchmarks
        benchmarks = client.benchmarks.list()
        print(f"Found {len(benchmarks)} benchmarks")

        # Submit evaluation job
        job = client.jobs.submit(
            EvaluationRequest(
                benchmark_id="mmlu",
                model=ModelConfig(
                    url="https://api.openai.com/v1",
                    name="gpt-4"
                )
            )
        )

        # Monitor job status
        status = client.jobs.get(job.job_id)
        print(f"Job {job.job_id}: {status.status}")
    ```

=== "Asynchronous"

    ```python
    from evalhub.client import AsyncEvalHubClient
    from evalhub.models.api import ModelConfig, EvaluationRequest

    # Create async client
    async with AsyncEvalHubClient(base_url="http://localhost:8080") as client:
        # List available benchmarks
        benchmarks = await client.benchmarks.list()
        print(f"Found {len(benchmarks)} benchmarks")

        # Submit evaluation job
        job = await client.jobs.submit(
            EvaluationRequest(
                benchmark_id="mmlu",
                model=ModelConfig(
                    url="https://api.openai.com/v1",
                    name="gpt-4"
                )
            )
        )

        # Monitor job status
        status = await client.jobs.get(job.job_id)
        print(f"Job {job.job_id}: {status.status}")
    ```

## Client Configuration

Both `SyncEvalHubClient` and `AsyncEvalHubClient` support the following configuration options:

```python
client = SyncEvalHubClient(
    base_url="http://localhost:8080",      # EvalHub service URL
    auth_token=None,                        # Optional authentication token
    timeout=30.0,                           # Request timeout in seconds
    max_retries=3,                          # Maximum retry attempts
    verify_ssl=True,                        # SSL certificate verification
    retry_initial_delay=1.0,                # Initial retry delay
    retry_max_delay=60.0,                   # Maximum retry delay
    retry_backoff_factor=2.0,               # Exponential backoff multiplier
    retry_randomization=True                # Add jitter to retries
)
```

## Resource Operations

The SDK provides a resource-based API for interacting with different EvalHub entities:

### Providers

List and retrieve evaluation providers:

```python
# List all providers
providers = client.providers.list()

# Get specific provider
provider = client.providers.get("lm_evaluation_harness")

# Get provider with benchmarks
provider = client.providers.get("lm_evaluation_harness", include_benchmarks=True)
```

### Benchmarks

Discover and filter available benchmarks:

```python
# List all benchmarks
benchmarks = client.benchmarks.list()

# Filter by category
math_benchmarks = client.benchmarks.list(category="math")

# Filter by provider
lmeval_benchmarks = client.benchmarks.list(provider_id="lm_evaluation_harness")

# Get specific benchmark
benchmark = client.benchmarks.get("mmlu")
```

### Collections

Work with benchmark collections:

```python
# List all collections
collections = client.collections.list()

# Get specific collection
collection = client.collections.get("healthcare_safety_v1")

# Collections include benchmark lists
for benchmark_id in collection.benchmark_ids:
    print(f"  - {benchmark_id}")
```

### Jobs

Submit and manage evaluation jobs:

```python
from evalhub.models.api import EvaluationRequest, ModelConfig

# Submit evaluation job
job = client.jobs.submit(
    EvaluationRequest(
        benchmark_id="mmlu",
        model=ModelConfig(
            url="https://api.openai.com/v1",
            name="gpt-4"
        ),
        num_examples=100,                    # Optional: limit examples
        benchmark_config={                   # Optional: custom config
            "num_few_shot": 5,
            "random_seed": 42
        }
    )
)

# Get job status
status = client.jobs.get(job.job_id)

# List all jobs
all_jobs = client.jobs.list()

# Filter jobs by status
from evalhub.models.api import JobStatus

running_jobs = client.jobs.list(status=JobStatus.RUNNING)
completed_jobs = client.jobs.list(status=JobStatus.COMPLETED)

# Wait for job completion (blocking)
final_status = client.jobs.wait_for_completion(
    job.job_id,
    timeout=3600,        # Maximum wait time in seconds
    poll_interval=5.0    # Check every 5 seconds
)

# Cancel a job
client.jobs.cancel(job.job_id)
```

## Complete Examples

### Example 1: Run Evaluation and Get Results

```python
from evalhub.client import SyncEvalHubClient
from evalhub.models.api import ModelConfig, EvaluationRequest, JobStatus

with SyncEvalHubClient(base_url="http://localhost:8080") as client:
    # Submit evaluation
    job = client.jobs.submit(
        EvaluationRequest(
            benchmark_id="mmlu",
            model=ModelConfig(
                url="https://api.openai.com/v1",
                name="gpt-4"
            ),
            num_examples=100
        )
    )

    print(f"Job submitted: {job.job_id}")

    # Wait for completion
    try:
        result = client.jobs.wait_for_completion(
            job.job_id,
            timeout=3600,
            poll_interval=10.0
        )

        if result.status == JobStatus.COMPLETED:
            print(f"✅ Evaluation completed!")
            print(f"Results: {result.results}")
        elif result.status == JobStatus.FAILED:
            print(f"❌ Evaluation failed: {result.error}")

    except TimeoutError:
        print(f"⏱️ Job did not complete within timeout")
        client.jobs.cancel(job.job_id)
```

### Example 2: List Available Benchmarks

```python
from evalhub.client import SyncEvalHubClient

with SyncEvalHubClient(base_url="http://localhost:8080") as client:
    # Get all providers
    providers = client.providers.list()

    print("Available Evaluation Providers:")
    print("=" * 50)

    for provider in providers:
        print(f"\n{provider.name}")
        print(f"  ID: {provider.id}")
        print(f"  Type: {provider.type}")

        # Get benchmarks for this provider
        benchmarks = client.benchmarks.list(provider_id=provider.id)
        print(f"  Benchmarks ({len(benchmarks)}):")

        for benchmark in benchmarks[:5]:  # Show first 5
            print(f"    - {benchmark.id}: {benchmark.name}")
```

### Example 3: Monitor Multiple Jobs

```python
from evalhub.client import SyncEvalHubClient
from evalhub.models.api import ModelConfig, EvaluationRequest, JobStatus
import time

with SyncEvalHubClient(base_url="http://localhost:8080") as client:
    # Submit multiple evaluations
    benchmarks = ["mmlu", "hellaswag", "truthfulqa"]
    jobs = []

    for benchmark_id in benchmarks:
        job = client.jobs.submit(
            EvaluationRequest(
                benchmark_id=benchmark_id,
                model=ModelConfig(
                    url="https://api.openai.com/v1",
                    name="gpt-4"
                )
            )
        )
        jobs.append(job)
        print(f"Submitted {benchmark_id}: {job.job_id}")

    # Monitor all jobs
    while jobs:
        for job in jobs[:]:  # Copy list to allow removal
            status = client.jobs.get(job.job_id)

            if status.status in [JobStatus.COMPLETED, JobStatus.FAILED, JobStatus.CANCELLED]:
                print(f"✓ {status.benchmark_id}: {status.status}")
                jobs.remove(job)
            else:
                print(f"⋯ {status.benchmark_id}: {status.status} ({status.progress:.0%})")

        if jobs:
            time.sleep(10)  # Wait before next check
```

### Example 4: Async Client with Multiple Concurrent Jobs

```python
import asyncio
from evalhub.client import AsyncEvalHubClient
from evalhub.models.api import ModelConfig, EvaluationRequest

async def run_evaluation(client, benchmark_id):
    """Submit and wait for a single evaluation."""
    job = await client.jobs.submit(
        EvaluationRequest(
            benchmark_id=benchmark_id,
            model=ModelConfig(
                url="https://api.openai.com/v1",
                name="gpt-4"
            )
        )
    )

    print(f"Started {benchmark_id}: {job.job_id}")

    result = await client.jobs.wait_for_completion(
        job.job_id,
        timeout=3600,
        poll_interval=5.0
    )

    print(f"Completed {benchmark_id}: {result.status}")
    return result

async def main():
    async with AsyncEvalHubClient(base_url="http://localhost:8080") as client:
        # Run multiple evaluations concurrently
        benchmarks = ["mmlu", "hellaswag", "truthfulqa"]

        tasks = [
            run_evaluation(client, benchmark_id)
            for benchmark_id in benchmarks
        ]

        # Wait for all to complete
        results = await asyncio.gather(*tasks)

        # Process results
        for result in results:
            print(f"{result.benchmark_id}: {result.results}")

# Run async code
asyncio.run(main())
```

## Error Handling

The SDK raises standard HTTP exceptions for error cases:

```python
import httpx
from evalhub.client import SyncEvalHubClient, ClientError

with SyncEvalHubClient(base_url="http://localhost:8080") as client:
    try:
        job = client.jobs.get("nonexistent-job-id")
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            print("Job not found")
        elif e.response.status_code == 500:
            print("Server error")
        else:
            print(f"HTTP error: {e.response.status_code}")
    except httpx.RequestError as e:
        print(f"Connection error: {e}")
    except ClientError as e:
        print(f"Client error: {e}")
```

## API Reference

### Client Classes

- `AsyncEvalHubClient` - Asynchronous client (requires `await`)
- `SyncEvalHubClient` - Synchronous client (no `await` needed)
- `EvalHubClient` - Alias for `AsyncEvalHubClient`

### Resource Classes

Each client provides access to these resources:

- `client.providers` - Provider operations
- `client.benchmarks` - Benchmark discovery
- `client.collections` - Collection operations
- `client.jobs` - Job submission and monitoring

### Model Classes

Key model classes from `evalhub.models.api`:

- `ModelConfig` - Model server configuration
- `EvaluationRequest` - Evaluation job request
- `EvaluationJob` - Job status and results
- `JobStatus` - Job status enum (PENDING, RUNNING, COMPLETED, FAILED, CANCELLED)
- `Provider` - Provider information
- `Benchmark` - Benchmark metadata
- `Collection` - Benchmark collection

## Best Practices

### Use Context Managers

Always use context managers to ensure proper cleanup:

```python
# ✅ Good - automatic cleanup
with SyncEvalHubClient() as client:
    job = client.jobs.submit(request)

# ❌ Bad - manual cleanup required
client = SyncEvalHubClient()
job = client.jobs.submit(request)
client.close()  # Must remember to close
```

### Configure Retries

For production environments, configure retry behaviour:

```python
client = SyncEvalHubClient(
    base_url="https://evalhub.example.com",
    max_retries=5,
    retry_initial_delay=2.0,
    retry_max_delay=120.0,
    retry_backoff_factor=2.0,
    retry_randomization=True
)
```

### Handle Timeouts

Set appropriate timeouts for long-running evaluations:

```python
# Long timeout for complex benchmarks
result = client.jobs.wait_for_completion(
    job.job_id,
    timeout=7200,  # 2 hours
    poll_interval=30.0
)
```

### Use Async for Concurrency

For running multiple evaluations concurrently, use the async client:

```python
# Async allows concurrent operations
async with AsyncEvalHubClient() as client:
    jobs = await asyncio.gather(
        client.jobs.submit(request1),
        client.jobs.submit(request2),
        client.jobs.submit(request3)
    )
```

## See Also

- [REST API Reference](api.md) - Complete API documentation
- [Creating Adapters](../development/creating-adapters.md) - Build custom adapters
- [Architecture](../development/architecture.md) - System architecture overview
