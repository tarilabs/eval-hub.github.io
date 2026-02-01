# Quick Start

Get up and running with EvalHub in minutes. This guide uses GuideLLM as an example, but the same workflow applies to any evaluation provider.

## Step 1: Start Model Server

=== "OpenShift (vLLM)"

    Deploy vLLM on OpenShift:

    ```bash
    # Example vLLM deployment
    oc apply -f - <<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: vllm-server
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: vllm
      template:
        metadata:
          labels:
            app: vllm
        spec:
          containers:
          - name: vllm
            image: vllm/vllm-openai:latest
            args:
            - --model
            - meta-llama/Llama-3.2-1B-Instruct
            - --port
            - "8000"
            ports:
            - containerPort: 8000
    EOF
    ```

=== "Local (Ollama)"

    Start Ollama for local development:

    ```bash
    # Install Ollama (if not already installed)
    curl -fsSL https://ollama.com/install.sh | sh

    # Pull and run a model
    ollama run qwen2.5:1.5b
    ```

    Ollama serves at `http://localhost:11434/v1` (OpenAI-compatible).

## Step 2: Install Client SDK

```bash
pip install eval-hub-sdk[client]
```

## Step 3: Submit Evaluation

Use the Python client to submit an evaluation:

```python
from evalhub.client import EvalHubClient
from evalhub.models.api import ModelConfig, BenchmarkSpec

# Connect to EvalHub server
client = EvalHubClient(base_url="http://localhost:8080")

# Submit evaluation
job = client.submit_evaluation(
    model=ModelConfig(
        url="http://localhost:11434/v1",  # or http://vllm-server:8000/v1 for k8s
        name="qwen2.5:1.5b"
    ),
    benchmarks=[
        BenchmarkSpec(
            benchmark_id="performance_test",
            provider_id="guidellm",
            config={
                "profile": "constant",
                "rate": 5,
                "max_seconds": 10,
                "max_requests": 20,
                "data": "prompt_tokens=50,output_tokens=20",
                "warmup": "0"
            }
        )
    ]
)

print(f"Job submitted: {job.job_id}")
```

## Step 4: View Results

Check the job status and retrieve results:

```python
# Get job status
status = client.get_job_status(job.job_id)
print(f"Status: {status.status}")
print(f"Progress: {status.progress}")

# Wait for completion and get results
if status.status == "completed":
    results = client.get_job_results(job.job_id)
    print(f"Results: {results}")
```

Example REST response:

```json
{
  "job_id": "quickstart-001",
  "status": "completed",
  "progress": 1.0,
  "results": {
    "benchmark_id": "performance_test",
    "provider_id": "guidellm",
    "metrics": {
      "requests_per_second": 5.0,
      "input_tokens_per_second": 263.2,
      "output_tokens_per_second": 105.3,
      "total_requests": 20,
      "mean_ttft_ms": 45.3,
      "mean_itl_ms": 12.1
    },
    "overall_score": 0.95
  }
}
```

## Next Steps

### Explore Other Providers

EvalHub supports multiple evaluation frameworks:

- **lm_evaluation_harness**: Standard LLM benchmarks (MMLU, HellaSwag, ARC, etc.)
- **guidellm**: Performance benchmarking
- **ragas**: RAG evaluation
- **garak**: LLM vulnerability scanning

```python
# List all available providers
providers = client.list_providers()
for provider in providers:
    print(f"{provider.provider_id}: {provider.description}")
```

### Try Different Benchmarks

Each provider offers multiple benchmarks:

```python
# List benchmarks for a provider
benchmarks = client.list_benchmarks(provider_id="lm_evaluation_harness")
for benchmark in benchmarks:
    print(f"{benchmark.benchmark_id}: {benchmark.name}")
```

### Use Collections

Run curated benchmark collections:

```python
# Submit evaluation using a collection
job = client.submit_evaluation(
    model=ModelConfig(url="...", name="..."),
    collection_id="healthcare_safety_v1"
)
```

## Troubleshooting

### Model Server Not Responding

=== "vLLM"

    Check vLLM pod status:

    ```bash
    # Check pod status
    oc get pods -l app=vllm

    # Check logs
    oc logs -l app=vllm --tail=50

    # Check service
    oc get svc vllm-server
    ```

=== "Ollama"

    Check if Ollama is running:

    ```bash
    # Check if Ollama is running
    curl http://localhost:11434/v1/models

    # Check Ollama service
    ollama list

    # Restart Ollama
    ollama serve
    ```

### Job Stuck in Pending

Check server logs:

```bash
# Local
eval-hub-server --log-level=debug

# Kubernetes
kubectl logs -n evalhub deployment/evalhub-server
```

## Learn More

- [Installation Guide](installation.md) - Complete installation instructions
- [Server Configuration](../server/index.md) - Configure the EvalHub server
- [API Reference](../reference/api.md) - REST API documentation
- [Provider Configuration](installation.md#provider-configuration) - Add custom providers
