# API Reference

API reference for eval-hub adapters.

## Coming Soon

Detailed API documentation is in progress.

## Core Classes

### FrameworkAdapter

Base class for all adapters.

```python
class FrameworkAdapter:
    def run_benchmark_job(
        self,
        job_spec: JobSpec,
        callbacks: JobCallbacks
    ) -> JobResults:
        """Run a benchmark job."""
        pass
```

### JobSpec

Job configuration.

```python
@dataclass
class JobSpec:
    job_id: str
    benchmark_id: str
    model: ModelConfig
    benchmark_config: Dict[str, Any]
```

### JobResults

Evaluation results.

```python
@dataclass
class JobResults:
    job_id: str
    benchmark_id: str
    metrics: Dict[str, Any]
    overall_score: Optional[float]
```

For complete API documentation, see the [evalhub-sdk source](https://github.com/eval-hub/sdk).
