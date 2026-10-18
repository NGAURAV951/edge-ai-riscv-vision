#!/usr/bin/env bash
# Produce a preliminary generic Yosys synthesis/statistics report.
# Run from any directory with: bash scripts/run_yosys_synthesis.sh
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build/synthesis}"
YOSYS_BIN="${YOSYS:-yosys}"

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

command -v "$YOSYS_BIN" >/dev/null 2>&1 || fail "Required command '$YOSYS_BIN' not found. Install Yosys and ensure it is in PATH."
[[ -f "$ROOT_DIR/rtl/dot_product.s" ]] || fail "Missing rtl/dot_product.s"
[[ -f "$ROOT_DIR/rtl/accelerator_regs.s" ]] || fail "Missing rtl/accelerator_regs.s"

mkdir -p "$BUILD_DIR"
REPORT="$BUILD_DIR/yosys-stat.log"

cd "$ROOT_DIR"
printf 'Running preliminary generic synthesis for accelerator_regs...\n'
printf 'Report: %s\n' "$REPORT"

# This is a generic logic/statistics pass, not FPGA place-and-route or timing closure.
if ! "$YOSYS_BIN" -Q -l "$REPORT" -p '
read_verilog -sv rtl/dot_product.s rtl/accelerator_regs.s
hierarchy -check -top accelerator_regs
proc
opt
check
stat
' ; then
    printf 'ERROR: Yosys synthesis failed. Review %s\n' "$REPORT" >&2
    exit 1
fi

if ! grep -Fq '=== accelerator_regs ===' "$REPORT"; then
    fail "Expected accelerator_regs statistics were not found in $REPORT"
fi

printf '\nYOSYS_SYNTHESIS_PASS: generic synthesis/statistics report generated\n'
printf 'This report is a preliminary generic estimate; it is not FPGA-specific area, timing, or power data.\n'
printf 'Report: %s\n' "$REPORT"
