#!/usr/bin/env bash
set -euo pipefail

# Benchmark script for cg search vs ripgrep (rg)
# See bench/README.md for methodology and usage

BENCH_ROOT="${BENCH_ROOT:-/home/borje/Documents/Personal/personal/arvora/arvora-os.git/os-distro}"
RESULTS_DIR="$BENCH_ROOT/bench"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
RESULT_MD="$RESULTS_DIR/results-$TIMESTAMP.md"
RESULT_CSV="$RESULTS_DIR/results-$TIMESTAMP.csv"

mkdir -p "$RESULTS_DIR"

QUERIES=(
  "pacman"
  "mkinitcpio"
  "linux-firmware"
  "base-devel"
  "archinstall"
  "GRUB"
  "systemd"
  "calamares"
  "airootfs profile"
  "HOOKS="
)

N_ITER=30
WARMUP_DISCARD=1

# Helper: print and run, capturing wall time
run_timed() {
  local cmd="$1"
  /usr/bin/time -f '%e' bash -c "$cmd" 2>&1 1>/dev/null
}

# 1. Ensure cg index exists and record index time/size
cd "$BENCH_ROOT"
CG_INDEX_TIME=$( ( /usr/bin/time -f '%e' cg index . ) 2>&1 )
CG_INDEX_SIZE=$(du -sh .code-grasp 2>/dev/null | awk '{print $1}')

# Check index file count
CG_STATUS=$(cg status .)
CG_INDEXED_FILES=$(echo "$CG_STATUS" | grep -Eo 'files: [0-9]+' | awk '{print $2}')
if [[ -z "$CG_INDEXED_FILES" || "$CG_INDEXED_FILES" == "0" ]]; then
  echo "ERROR: cg index reports 0 files. Diagnostics:" | tee "$RESULT_MD"
  echo "$CG_STATUS" | tee -a "$RESULT_MD"
  find . -type f | head -20 | tee -a "$RESULT_MD"
  exit 1
fi

# 2. Build rg glob list to approximate cg's indexed files
# (This is a simplification; see cg-core/src/walker/gitignore.rs for full logic)
RG_GLOBS=(
  "*.sh"
  "*.conf"
  "*.cfg"
  "*.md"
  "*.txt"
  "*.rules"
  "*.service"
  "*.hook"
  "*.preset"
  "*.d"
  "*.list"
  "*.json"
  "*.yml"
  "*.yaml"
  "*.rules"
  "*.profile"
  "*.motd"
  "*.hostname"
  "*.shadow"
  "*.passwd"
  "*.locale"
  "*.network"
  "*.bin"
  "*.local"
  "*.share"
)
RG_GLOB_ARGS=()
for g in "${RG_GLOBS[@]}"; do RG_GLOB_ARGS+=(--glob "$g"); done

# 3. Benchmark loop
METHODS=("cg" "rg")
echo "method,query_id,query,iter,elapsed_s" > "$RESULT_CSV"

for method in "${METHODS[@]}"; do
  for qid in "${!QUERIES[@]}"; do
    query="${QUERIES[$qid]}"
    for ((i=0;i<N_ITER+WARMUP_DISCARD;i++)); do
      if [[ "$method" == "cg" ]]; then
        CMD="cg search --limit 10 --path . \"$query\""
      else
        CMD="rg -F \"$query\" ${RG_GLOB_ARGS[*]} ."
      fi
      elapsed=$(run_timed "$CMD")
      if (( i >= WARMUP_DISCARD )); then
        echo "$method,$qid,\"$query\",$((i-WARMUP_DISCARD+1)),$elapsed" >> "$RESULT_CSV"
      fi
    done
  done
done

# 4. Compute percentiles and print Markdown summary
python3 - "$RESULT_CSV" "$RESULT_MD" <<'EOF'
import sys, csv, statistics, datetime
from collections import defaultdict

csv_path, md_path = sys.argv[1:3]
rows = []
with open(csv_path) as f:
    reader = csv.DictReader(f)
    for row in reader:
        row['elapsed_s'] = float(row['elapsed_s'])
        rows.append(row)

summary = defaultdict(list)
for row in rows:
    key = (row['method'], row['query_id'], row['query'])
    summary[key].append(row['elapsed_s'])

with open(md_path, 'w') as md:
    print(f"# Search Benchmark Results\n\nDate: {datetime.datetime.now().isoformat()}\n", file=md)
    print("| method | query_id | p50_s | p95_s | n | notes |", file=md)
    print("|--------|----------|-------|-------|---|-------|", file=md)
    for (method, qid, query), times in sorted(summary.items()):
        p50 = statistics.median(times)
        p95 = statistics.quantiles(times, n=20)[18] if len(times) >= 20 else max(times)
        print(f"| {method} | {qid} | {p50:.4f} | {p95:.4f} | {len(times)} | |", file=md)
    print("\n## Indexing\n", file=md)
    print(f"cg index wall time: {os.environ.get('CG_INDEX_TIME','N/A')} s", file=md)
    print(f"cg index .code-grasp/ size: {os.environ.get('CG_INDEX_SIZE','N/A')}", file=md)
    print("\n## Hardware/Software\n", file=md)
    import platform, subprocess, os
    print(f"OS: {platform.platform()}", file=md)
    print(f"Arch: {platform.machine()}", file=md)
    try:
        cpuinfo = subprocess.check_output(['lscpu'], text=True)
        for line in cpuinfo.splitlines():
            if 'Model name' in line:
                print(line.strip(), file=md)
                break
    except Exception:
        pass
    for tool in ['cg', 'rg']:
        try:
            ver = subprocess.check_output([tool, '--version'], text=True).splitlines()[0]
            print(f"{tool} version: {ver}", file=md)
        except Exception:
            pass
    print("\n---\n", file=md)
    print("See bench/README.md for methodology and caveats.", file=md)
EOF

cat "$RESULT_MD"
