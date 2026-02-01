# Performance Metrics

GuideLLM collects comprehensive performance metrics for LLM inference evaluation.

## Core Metrics

### Requests Per Second

**Definition**: Number of successful requests processed per second

**Use case**: Overall system throughput measurement

**Typical values**:
- Small models (1-3B): 10-50 req/s
- Medium models (7-13B): 3-15 req/s
- Large models (30B+): 1-5 req/s

**Extracted metric**: `requests_per_second`

---

### Time to First Token (TTFT)

**Definition**: Latency from request submission until the first generated token

**Use case**: User experience - measures perceived responsiveness

**Typical values**:
- Fast: < 100ms
- Good: 100-500ms
- Slow: > 1000ms

**Extracted metric**: `mean_ttft_ms`

**Important for**: Interactive applications, chatbots, real-time systems

---

### Inter-Token Latency (ITL)

**Definition**: Time between consecutive generated tokens

**Use case**: Streaming quality - measures generation smoothness

**Typical values**:
- Fast: < 20ms
- Good: 20-50ms
- Slow: > 100ms

**Extracted metric**: `mean_itl_ms`

**Important for**: Streaming responses, user experience

---

### Token Throughput

**Definition**: Tokens generated per second

**Types**:
- **Prompt tokens/sec**: Input processing rate
- **Output tokens/sec**: Generation rate
- **Total tokens/sec**: Combined throughput

**Extracted metrics**:
- `prompt_tokens_per_second`
- `output_tokens_per_second`

**Use case**: Cost estimation, capacity planning

---

### Request Latency

**Definition**: End-to-end time from request to complete response

**Calculation**: `TTFT + (num_tokens × ITL)`

**Use case**: Overall performance measurement

**Typical values**:
- Interactive: < 2s
- Batch processing: 5-30s

---

### Total Requests

**Definition**: Count of successful requests processed

**Extracted metric**: `total_requests`

**Use case**: Validation, sample size verification

## Statistical Measures

All metrics include statistical measures:

- **Mean**: Average value
- **Median**: Middle value (50th percentile)
- **Standard Deviation**: Variability measure
- **Percentiles**: Distribution (p50, p75, p90, p95, p99)

## Metric Extraction

The adapter extracts summary statistics from GuideLLM's nested output structure:

```python
{
  "framework": "guidellm",
  "benchmark_id": "performance_quick",
  "requests_per_second": 4.99,
  "prompt_tokens_per_second": 263.17,
  "output_tokens_per_second": 105.27,
  "mean_ttft_ms": 0.0,
  "mean_itl_ms": 0.0,
  "total_requests": 20,
  "benchmark_count": 1
}
```

## Interpreting Results

### Good Performance Indicators

✓ **Low TTFT** (< 200ms) - Responsive feel
✓ **Consistent ITL** (low std dev) - Smooth streaming
✓ **High token throughput** - Efficient generation
✓ **Stable request rate** - No saturation

### Performance Issues

⚠ **High TTFT** (> 1s) - Poor responsiveness
⚠ **Variable ITL** (high std dev) - Stuttering generation
⚠ **Low throughput** - Under-utilised resources
⚠ **Increasing latency** - Approaching saturation

## Benchmark Output

GuideLLM generates multiple output formats with detailed metrics:

### JSON Output

Complete authoritative record with all metrics and sample requests.

**File**: `benchmarks.json`

**Contains**:
- All statistical measures
- Request-level data
- System metadata
- Configuration details

### CSV Output

Tabular view for spreadsheets and BI tools.

**File**: `benchmarks.csv`

**Columns**: All metrics flattened with mean/median/std/percentiles

### HTML Output

Visual summary with latency distributions and interactive charts.

**File**: `benchmarks.html`

**Includes**:
- Performance summary tables
- Latency distribution graphs
- Token throughput visualisations
- Request timeline

### YAML Output

Human-readable alternative to JSON format.

**File**: `benchmarks.yaml`

**Use case**: Configuration review, documentation

## Example Output

Here's a sample benchmark result:

```
Token Metrics (Completed Requests)
┌────────────┬──────┬──────┬──────┬──────┬──────┬──────┬───────┬──────┬─────────┬────────┐
│ Benchmark  │ Prompt Tokens  ││ Generated Tokens ││ Total Tokens   ││ Iterations       ││
│ Strategy   │ Per Request    ││ Per Request      ││ Per Request    ││ Per Request      ││
│            │ Mdn  │ p95  │ Mdn  │ p95  │ Mdn  │ p95  │ Mdn   │ p95  │ Mdn     │ p95    │
├────────────┼──────┼──────┼──────┼──────┼──────┼──────┼───────┼──────┼─────────┼────────┤
│ constant   │ 50.0 │ 50.0 │ 20.0 │ 20.0 │ 70.0 │ 70.0 │ 1.0   │ 1.0  │ 20.0    │ 20.0   │
└────────────┴──────┴──────┴──────┴──────┴──────┴──────┴───────┴──────┴─────────┴────────┘

Server Throughput Statistics
┌────────────┬──────┬───────┬─────────┬───────┬─────────┬────────┬──────────┬────────┐
│ Benchmark  │ Requests      ││ Input Tokens ││ Output Tokens ││ Total Tokens      ││
│ Strategy   │ Per Sec       ││ Per Sec      ││ Per Sec       ││ Per Sec           ││
│            │ Mdn  │ Mean  │ Mdn    │ Mean  │ Mdn     │ Mean  │ Mdn     │ Mean    │
├────────────┼──────┼───────┼────────┼───────┼─────────┼────────┼─────────┼─────────┤
│ constant   │ 5.0  │ 5.0   │ 250.3  │ 263.2 │ 100.1   │ 105.3  │ 350.5   │ 368.4   │
└────────────┴──────┴───────┴────────┴───────┴─────────┴────────┴─────────┴─────────┘
```

## Metric Persistence

All metrics are:

1. **Sent to eval-hub service**: Summary metrics for tracking and comparison
2. **Persisted as OCI artifacts**: Complete results for detailed analysis
3. **Logged**: Real-time visibility during benchmark execution

!!! note "Payload Optimization"
    The adapter sends only summary metrics to the service to reduce payload size. Full raw results are available in the OCI artifacts.
