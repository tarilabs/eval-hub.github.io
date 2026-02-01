# Creating Adapters

Guide for creating new eval-hub adapters.

## Coming Soon

Detailed adapter creation guide is in progress.

## Quick Template

```python
from evalhub.adapter import FrameworkAdapter, JobSpec, JobResults, JobCallbacks

class MyAdapter(FrameworkAdapter):
    def run_benchmark_job(
        self,
        job_spec: JobSpec,
        callbacks: JobCallbacks
    ) -> JobResults:
        # Your implementation here
        pass
```

For complete examples, see existing adapters:

- [GuideLLM Adapter](https://github.com/eval-hub/contrib/tree/main/adapters/guidellm)
- [LightEval Adapter](https://github.com/eval-hub/contrib/tree/main/adapters/lighteval)
