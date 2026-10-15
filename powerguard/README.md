# PowerGuard — Embedded Power & Equipment Health Monitor

A student-built ECE portfolio project demonstrating embedded C, sensor-data handling, simple fault detection, Python analysis, unit tests, and continuous integration.

> **Status:** simulation-first prototype. All supplied CSV readings are synthetic. It has not been tested with physical sensors or deployed in an industrial environment.

## What it does

- Reads voltage, current, and temperature values from CSV.
- Calculates apparent power as voltage × current, reported in VA.
- Flags under-voltage, over-voltage, high current, and high temperature.
- Includes portable C firmware-style logic and a Python batch analyzer.
- Includes automated tests and a GitHub Actions workflow.

## Relevance to target employers

- **Texas Instruments:** embedded C, ADC/sensor data paths, threshold logic, and validation.
- **BEL:** deterministic monitoring, telemetry-style data, fault flags, and test evidence.
- **Reliance Industries:** a foundation for industrial equipment and electrical-parameter monitoring.

These are learning connections only. This independent student project is not affiliated with or validated by those companies.

## Project structure

```text
powerguard/
├── README.md
├── powerguard.py
├── data/sample_readings.csv
├── firmware/power_monitor.c
├── tests/test_powerguard.py
├── docs/architecture.md
├── docs/test-plan.md
└── .github/workflows/powerguard-ci.yml
```

## Run the Python demo

Python 3.10+; no third-party packages are required.

From the `powerguard` directory:

```powershell
py powerguard.py --input data/sample_readings.csv
py -m unittest discover -s tests -v
```

Linux/macOS:

```bash
python3 powerguard.py --input data/sample_readings.csv
python3 -m unittest discover -s tests -v
```

## Compile the C demo

GCC is required:

```bash
gcc -std=c99 -Wall -Wextra -pedantic firmware/power_monitor.c -o power_monitor
```

PowerShell: `.\power_monitor.exe`  
Linux/macOS: `./power_monitor`

The C program uses a small in-code sample array that stands in for sensor-driver readings, so no microcontroller SDK is needed for the demo.

## Prototype thresholds

| Signal | Rule in this demo |
|---|---:|
| Voltage | Below 207 V → under-voltage flag |
| Voltage | Above 253 V → over-voltage flag |
| Current | Above 1.50 A → high-current flag |
| Temperature | 60 °C or higher → high-temperature flag |

These values are illustrative software thresholds, **not safety limits**. Real limits must come from the equipment and sensor specifications and a proper engineering safety review.

## Important engineering notes

- (V × I) is reported as apparent power in VA, not real power in watts. Real AC power requires appropriate power-factor measurement or synchronized voltage/current waveform sampling.
- Input values are checked for missing, non-numeric, non-finite, and negative voltage/current data.
- The existing inputs are synthetic. Do not claim physical accuracy or live hardware validation until you test and document it yourself.
- Never connect a microcontroller or breadboard directly to mains. Use a suitable isolated, rated sensing interface and qualified supervision.

## What to explain in an interview

1. How sensor readings would flow through conditioning, ADC conversion, calibration, filtering, and firmware.
2. How threshold rules become explicit fault flags.
3. Why apparent power is expressed in VA.
4. Why a small embedded-C decision loop and a Python data-analysis tool serve different needs.
5. How the automated tests cover normal values, boundary faults, invalid numbers, and multiple simultaneous faults.

See [architecture](docs/architecture.md) and [test plan](docs/test-plan.md).
