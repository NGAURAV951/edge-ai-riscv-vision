# Embedded Industrial Equipment Health Monitor

A practical final-year B.Tech ECE portfolio project combining portable embedded C, sensor-data processing, fault rules, a CSV telemetry analyser, and an optional SystemVerilog fault guard.

> Scope note: the project uses simulated telemetry and software/RTL tests. It does not claim a deployed industrial product, physical sensor measurements, or affiliation with Texas Instruments, BEL, or Reliance Industries.

## Problem statement

Small motors, pumps, and lab equipment can develop abnormal conditions such as over-current, unusual temperature, supply-voltage deviation, or excess vibration. This prototype turns sample readings into a health status and fault code.

## Features

- Portable C API for voltage, current, temperature, and vibration samples.
- Apparent power calculation: RMS voltage × RMS current, reported in VA.
- Input validation for null pointers, non-finite readings, negative values, and implausible ranges.
- Rule-based fault classification with documented priority.
- CSV telemetry analyser written with Python's standard library only.
- C test harness with no third-party testing framework.
- Optional synthesizable SystemVerilog threshold guard and testbench.

## Demo thresholds

| Condition | Demo threshold | Fault code |
|---|---:|---|
| Invalid or implausible reading | Out-of-range or non-finite input | INVALID_DATA |
| Under-voltage | Below 180 V RMS | UNDER_VOLTAGE |
| Over-voltage | Above 250 V RMS | OVER_VOLTAGE |
| Over-current | Above 12 A RMS | OVER_CURRENT |
| High temperature | Above 80 °C | OVER_TEMPERATURE |
| High vibration | Above 3.0 mm/s RMS | HIGH_VIBRATION |
| Otherwise | Within demo ranges | NORMAL |

These values are for an educational demonstration, not equipment protection settings. If several faults occur together, the C firmware returns the first match according to the order in firmware/monitor.c.

## Folder structure

    industrial-health-monitor/
    ├── firmware/monitor.h
    ├── firmware/monitor.c
    ├── firmware/demo.c
    ├── tests/test_monitor.c
    ├── tools/analyze_log.py
    ├── data/sample_telemetry.csv
    ├── rtl/fault_guard.sv
    ├── rtl/fault_guard_tb.sv
    ├── docs/architecture.md
    ├── run_tests.sh
    └── run_tests.ps1

## Run on Windows

Install GCC and make sure it is available from PowerShell. From this folder:

    .\run_tests.ps1

## Run on Linux, MSYS2, or Git Bash

    bash ./run_tests.sh

The scripts build into a local build directory. Generated binaries should not be committed.

## Analyse the sample log

Python 3.9 or later is recommended. No pip dependencies are required.

    python tools/analyze_log.py data/sample_telemetry.csv

If Python is installed through the Windows Python launcher, use:

    py tools/analyze_log.py data/sample_telemetry.csv

The report prints apparent power, a status for each row, and a summary of the number of events. This is rule-based analysis, not machine learning.

## Optional RTL simulation

If Icarus Verilog is installed:

    mkdir -p build
    iverilog -g2012 -o build/fault_guard_sim rtl/fault_guard.sv rtl/fault_guard_tb.sv
    vvp build/fault_guard_sim

A FAULT_GUARD_PASS message means the simulated test cases matched expected results. It is not physical validation.

## Possible physical extension

A lab prototype could add a microcontroller, a temperature sensor, a suitable current-sensing front end, and an accelerometer. Add and calibrate one channel at a time, comparing it with a trusted instrument. A TI LaunchPad or another MCU could be selected for a future port; the current firmware is portable host-compiled C, not firmware built for a TI device.

Safety: Never connect mains voltage directly to a microcontroller, breadboard, or non-isolated sensor. Use correctly rated isolated measurement modules and qualified supervision. This demo is not protection equipment and must not control or protect real machinery.

## Skills demonstrated

Embedded C, input validation, threshold-based fault detection, sensor-data handling, basic electrical calculations, CSV processing, automated tests, SystemVerilog combinational logic, and simulation-based verification.

## Transferable relevance

- Texas Instruments: embedded C, sensor interfaces, and power/electronics concepts.
- BEL: digital logic, verification, instrumentation, and technical documentation.
- Reliance Industries: industrial monitoring concepts, telemetry records, and condition-based maintenance workflows.

These are transferable skills, not claims that the project replicates an employer's internal systems.

## Resume description

Embedded Industrial Equipment Health Monitor — Built a portable C-based monitoring prototype that evaluates voltage, current, temperature, and vibration readings, calculates apparent power, and flags threshold-based faults. Added a CSV telemetry analyser, C test harness, and optional SystemVerilog fault-guard simulation.

Run the tests yourself and be prepared to explain the thresholds, assumptions, and limitations before including this project on a resume.