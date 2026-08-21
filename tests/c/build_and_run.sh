#!/usr/bin/env bash
# Builds and runs the PSTUnit C unit tests against the Embedded-Coder-
# generated uav_altitude_hold_step() implementation.
#
# Usage: POLYSPACE_ROOT="/c/Program Files/Polyspace/R2026a" ./build_and_run.sh
set -euo pipefail

: "${POLYSPACE_ROOT:?Set POLYSPACE_ROOT to the Polyspace installation root (contains polyspace/)}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GEN_CODE_DIR="$PROJECT_ROOT/scripts/uav_altitude_hold_ert_rtw"
BUILD_DIR="$SCRIPT_DIR/build"

mkdir -p "$BUILD_DIR"

gcc "$SCRIPT_DIR/test_uav_altitude_hold.c" \
    "$GEN_CODE_DIR/uav_altitude_hold.c" \
    "$POLYSPACE_ROOT/polyspace/pstest/pstunit/src/pstunit.c" \
    -I"$POLYSPACE_ROOT/polyspace/pstest/pstunit/include" \
    -I"$GEN_CODE_DIR" \
    -lm \
    -o "$BUILD_DIR/test_uav_altitude_hold.exe"

"$BUILD_DIR/test_uav_altitude_hold.exe"
