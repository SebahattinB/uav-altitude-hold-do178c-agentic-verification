#!/usr/bin/env bash
# Runs Polyspace Bug Finder (MISRA C:2023 + CWE) on the Embedded-Coder-
# generated uav_altitude_hold.c and writes results to
# evidence/bug_finder_r2026a/.
#
# The Polyspace MCP server on this machine points at a standalone
# Polyspace Bug Finder/Code Prover Desktop install (no "Polyspace As You
# Code" component), so this uses the classic polyspace-bug-finder CLI
# directly rather than the MCP run_polyspace_as_you_code tool.
#
# Usage: POLYSPACE_ROOT="/c/Program Files/Polyspace/R2026a" ./run_bug_finder.sh
set -euo pipefail

: "${POLYSPACE_ROOT:?Set POLYSPACE_ROOT to the Polyspace installation root}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$PROJECT_ROOT/evidence/bug_finder_r2026a"

rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

"$POLYSPACE_ROOT/polyspace/bin/polyspace-bug-finder-nodesktop.exe" \
  -sources "$PROJECT_ROOT/scripts/uav_altitude_hold_ert_rtw/uav_altitude_hold.c" \
  -I "$PROJECT_ROOT/scripts/uav_altitude_hold_ert_rtw" \
  -misra-c-2023 all \
  -cwe all \
  -results-dir "$RESULTS_DIR" \
  -prog uav_altitude_hold

"$POLYSPACE_ROOT/polyspace/bin/polyspace-results-export.exe" \
  -format csv -results-dir "$RESULTS_DIR" \
  -output-name "$RESULTS_DIR/findings.csv" -set-language-english
