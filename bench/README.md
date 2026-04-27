# Search Benchmarking for arvora-os.git/os-distro

This directory contains reproducible search benchmark results and scripts for comparing CodeGrasp (cg) search and ripgrep (rg) on the arvora-os.git/os-distro corpus.

## How to Run the Benchmark

```sh
BENCH_ROOT=/home/borje/Documents/Personal/personal/arvora/arvora-os.git/os-distro ./scripts/bench_search.sh
```

- By default, BENCH_ROOT is set to the path above. You may override it if benchmarking a different root.
- Results are written to `bench/results-<timestamp>.md` (summary) and `bench/results-<timestamp>.csv` (raw times).
- The script prints a Markdown summary table to stdout after completion.

## Methodology
- Each method/query is run for at least 30 iterations (after optional warmup discard).
- Median (p50) and 95th percentile (p95) wall-clock times are reported.
- All commands are run with BENCH_ROOT as the project root.
- For cg search, the index is built once before timing queries (unless testing cold index, which is labeled separately).
- For rg, file globs are chosen to approximate CodeGrasp's indexed file set. See script for details and caveats.
- Hardware/software details and tool versions are included in each result file.

## Interpreting Results
- If speedup ratios are reported, they are computed as the median ratio (cg/rg or rg/cg) with the formula printed in the summary.
- If cg index reports 0 files, the script aborts and prints diagnostics.

---

For questions or reproducibility issues, see the script header for contact info or troubleshooting steps.
