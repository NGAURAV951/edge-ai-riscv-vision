# Embedded Industrial Equipment Health Monitor

I built this project to practise a few ECE skills together: writing embedded-style C, checking sensor readings, working with logged data, and testing a small piece of digital logic. The example is an equipment monitor for a motor or pump. It reads sample voltage, current, temperature, and vibration values, then reports whether one of the demo limits has been crossed.

This is a software prototype, not a finished industrial product. The readings are sample data; no physical sensors or machinery are connected.

## What it does

- Checks the input values and rejects missing, non-finite, negative, or out-of-range readings.
- Calculates apparent power using RMS voltage × RMS current, in volt-amperes (VA).
- Applies a set of simple rules to label a reading as normal or report a fault.
- Reads a CSV log and prints the status of each row, along with a count of the results.
- Includes a small C test program and an optional SystemVerilog module with a testbench.

The Python analyser uses only the Python standard library, so it does not need extra packages installed with pip.

## Demo limits

These limits are just values chosen for the demonstration. They are **not** recommended settings for protecting real equipment.

| Condition | Demo rule | Reported status |
|---|---:|---|
| Invalid reading | Missing, non-finite, or outside the accepted input range | `INVALID_DATA` |
| Low voltage | Below 180 V RMS | `UNDER_VOLTAGE` |
| High voltage | Above 250 V RMS | `OVER_VOLTAGE` |
| High current | Above 12 A RMS | `OVER_CURRENT` |
| High temperature | Above 80 °C | `OVER_TEMPERATURE` |
| High vibration | Above 3.0 mm/s RMS | `HIGH_VIBRATION` |
| No rule triggered | Reading is inside the demo limits | `NORMAL` |

When more than one fault is present, the C function reports the first match in the order defined in `firmware/monitor.c`. It does not currently report several faults at once.

## Files

```text
industrial-health-monitor/
├── firmware/
│   ├── monitor.h
│   ├── monitor.c
│   └── demo.c
├── tests/
│   └── test_monitor.c
├── tools/
│   └── analyze_log.py
├── data/
│   └── sample_telemetry.csv
├── rtl/
│   ├── fault_guard.sv
│   └── fault_guard_tb.sv
├── docs/
│   └── architecture.md
├── run_tests.sh
└── run_tests.ps1
```

## Run it on Windows

Install GCC and make sure PowerShell can find it. Open PowerShell in this folder and run:

```powershell
.\run_tests.ps1
```

If you use the Windows Python launcher, the script tries `py` to run the CSV analyser. Otherwise, it checks for `python`.

## Run it on Linux, MSYS2, or Git Bash

With GCC and Python installed, run:

```bash
bash ./run_tests.sh
```

The scripts put compiled files in `build/` so generated binaries do not need to be committed.

## Run the CSV analyser on its own

From this folder:

```powershell
py tools/analyze_log.py data/sample_telemetry.csv
```

Or, on a system where Python is available as `python3`:

```bash
python3 tools/analyze_log.py data/sample_telemetry.csv
```

The sample log includes normal readings and examples that trigger the demo rules. The script prints the calculated apparent power, the status for each row, and a short count of the statuses. This is rule-based analysis, not machine learning.

## Run the optional SystemVerilog test

If Icarus Verilog is installed, run these commands from this folder:

```bash
mkdir -p build
iverilog -g2012 -o build/fault_guard_sim rtl/fault_guard.sv rtl/fault_guard_tb.sv
vvp build/fault_guard_sim
```

A `FAULT_GUARD_PASS` result means the testbench's simulated cases matched their expected values. It does not prove that the design works with physical sensors or real equipment.

## What I practised

This project gave me a way to work through input validation in C, basic electrical calculations, threshold checks, CSV parsing, small test cases, and a SystemVerilog testbench. Keeping the monitoring rules separate from the demo program also makes the C logic easier to test on a computer before considering a microcontroller port.

## What is still missing

The next step would be to connect a microcontroller to properly selected and calibrated sensors, then compare its readings with a trusted instrument. That work has **not** been done in this version. The C code currently runs as a host-compiled program, and the RTL is tested in simulation; there is no physical FPGA or microcontroller integration.

For any future hardware version, mains measurements would need appropriately rated, isolated measurement equipment and qualified supervision. Do not connect mains voltage directly to a development board or breadboard. This prototype is not safety equipment and must not be used to protect real machinery.

## Resume summary

Built a C-based equipment-monitoring prototype that validates sample voltage, current, temperature, and vibration readings, calculates apparent power, and flags threshold-based faults. Added a Python CSV log analyser, C tests, sample data, and an optional SystemVerilog testbench. The current version uses simulated readings and host-side tests; physical sensor integration remains future work.
