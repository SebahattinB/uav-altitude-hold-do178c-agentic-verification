#!/usr/bin/env bash
# Runs Polyspace Code Prover on the Embedded-Coder-generated
# uav_altitude_hold.c and writes results to
# evidence/code_prover_r2026a/.
#
# Uses -main-generator (the .c file has no main() of its own) and
# drs.xml to bound alt_cmd/alt_meas/vz_meas to a physically realistic
# sensor range; without that bound Code Prover cannot rule out float
# overflow for the full double range and reports 2 Orange checks.
#
# Usage: POLYSPACE_ROOT="/c/Program Files/Polyspace/R2026a" ./run_code_prover.sh
set -euo pipefail

: "${POLYSPACE_ROOT:?Set POLYSPACE_ROOT to the Polyspace installation root}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$PROJECT_ROOT/evidence/code_prover_r2026a"

rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

"$POLYSPACE_ROOT/polyspace/bin/polyspace-code-prover-nodesktop.exe" \
  -sources "$PROJECT_ROOT/scripts/uav_altitude_hold_ert_rtw/uav_altitude_hold.c" \
  -I "$PROJECT_ROOT/scripts/uav_altitude_hold_ert_rtw" \
  -main-generator \
  -data-range-specifications "$SCRIPT_DIR/drs.xml" \
  -results-dir "$RESULTS_DIR" \
  -prog uav_altitude_hold_cp

"$POLYSPACE_ROOT/polyspace/bin/polyspace-results-export.exe" \
  -format csv -results-dir "$RESULTS_DIR" \
  -output-name "$RESULTS_DIR/findings.csv" -set-language-english
