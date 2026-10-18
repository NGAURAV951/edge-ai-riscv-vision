#!/usr/bin/env bash
# Reproducible RTL regression for the Edge-AI RISC-V Vision project.
# Run from any directory with: bash scripts/run_rtl_regression.sh
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build/rtl-regression}"
IVERILOG_BIN="${IVERILOG:-iverilog}"
VVP_BIN="${VVP:-vvp}"

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

for command_name in "$IVERILOG_BIN" "$VVP_BIN"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        fail "Required command '$command_name' was not found in PATH. Install Icarus Verilog and ensure both iverilog and vvp are available."
    fi
done

for source_file in \
    "$ROOT_DIR/rtl/dot_product.s" \
    "$ROOT_DIR/rtl/tb_dot_product.s" \
    "$ROOT_DIR/rtl/tb_dot_product_random.s" \
    "$ROOT_DIR/rtl/accelerator_regs.s" \
    "$ROOT_DIR/rtl/tb_accelerator_regs.s"; do
    [[ -f "$source_file" ]] || fail "Required RTL source file is missing: $source_file"
done

mkdir -p "$BUILD_DIR"

run_case() {
    local case_name="$1"
    shift
    local top_module="$1"
    shift

    # Accept any number of RTL source files; -- separates them from pass markers.
    local source_files=()
    while (($#)); do
        if [[ "$1" == "--" ]]; then
            shift
            break
        fi
        source_files+=("$1")
        shift
    done
    (( ${#source_files[@]} > 0 )) || fail "No source files supplied for '$case_name'."

    local required_markers=("$@")
    local executable="$BUILD_DIR/$case_name.vvp"
    local compile_log="$BUILD_DIR/$case_name.compile.log"
    local simulation_log="$BUILD_DIR/$case_name.sim.log"

    printf '\n============================================================\n'
    printf 'RTL CASE: %s\n' "$case_name"
    printf 'Top module: %s\n' "$top_module"
    printf 'Source files: %s\n' "${#source_files[@]}"
    printf '============================================================\n'

    if ! "$IVERILOG_BIN" -g2012 -Wall -s "$top_module" \
        -o "$executable" "${source_files[@]}" >"$compile_log" 2>&1; then
        cat "$compile_log" >&2
        fail "Compilation failed for '$case_name'. See $compile_log"
    fi

    if [[ -s "$compile_log" ]]; then
        printf '%s\n' 'Compiler output (warnings, if any):'
        cat "$compile_log"
    fi

    if ! "$VVP_BIN" "$executable" >"$simulation_log" 2>&1; then
        cat "$simulation_log" >&2
        fail "Simulation process failed for '$case_name'. See $simulation_log"
    fi

    cat "$simulation_log"

    if grep -Eiq 'FAIL|FATAL|ERROR|WATCHDOG_TIMEOUT' "$simulation_log"; then
        fail "Failure marker detected in '$case_name'. See $simulation_log"
    fi

    local marker
    for marker in "${required_markers[@]}"; do
        if ! grep -Fq -- "$marker" "$simulation_log"; then
            fail "Required marker '$marker' was not found in '$case_name'. See $simulation_log"
        fi
        printf 'Verified marker: %s\n' "$marker"
    done

    printf 'CASE_PASS: %s\n' "$case_name"
}

run_case \
    "dot_product" \
    "tb_dot_product" \
    "$ROOT_DIR/rtl/dot_product.s" \
    "$ROOT_DIR/rtl/tb_dot_product.s" \
    -- \
    "SIGNED_DOT_PRODUCT_PASS result=-136" \
    "LATENCY_PASS cycles=16"

run_case \
    "dot_product_random" \
    "tb_dot_product_random" \
    "$ROOT_DIR/rtl/dot_product.s" \
    "$ROOT_DIR/rtl/tb_dot_product_random.s" \
    -- \
    "RANDOMIZED_DOT_PRODUCT_PASS cases=105 random_cases=100 directed_cases=5"

run_case \
    "accelerator_regs" \
    "tb_accelerator_regs" \
    "$ROOT_DIR/rtl/dot_product.s" \
    "$ROOT_DIR/rtl/accelerator_regs.s" \
    "$ROOT_DIR/rtl/tb_accelerator_regs.s" \
    -- \
    "STATUS_PASS" \
    "FULL_32BIT_RESULT_PASS" \
    "REGISTER_LATENCY_PASS cycles=17" \
    "ALL_REGISTER_TESTS_PASS"


printf '\n============================================================\n'
printf 'RTL_REGRESSION_PASS: 3/3 testbenches passed\n'
printf 'Build output: %s\n' "$BUILD_DIR"
printf '============================================================\n'
