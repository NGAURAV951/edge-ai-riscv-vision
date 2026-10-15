#!/usr/bin/env python3
"""Analyse a CSV telemetry log using simple prototype thresholds."""

import argparse
import csv
import math
import sys
from pathlib import Path

FIELDNAMES = ("timestamp", "voltage_rms_v", "current_rms_a", "temperature_c", "vibration_rms_mm_s")


def classify(voltage: float, current: float, temperature: float, vibration: float) -> str:
    values = (voltage, current, temperature, vibration)
    if not all(math.isfinite(value) for value in values):
        return "INVALID_DATA"
    if not (0 <= voltage <= 300 and 0 <= current <= 100 and -40 <= temperature <= 200 and 0 <= vibration <= 100):
        return "INVALID_DATA"
    if voltage < 180:
        return "UNDER_VOLTAGE"
    if voltage > 250:
        return "OVER_VOLTAGE"
    if current > 12:
        return "OVER_CURRENT"
    if temperature > 80:
        return "OVER_TEMPERATURE"
    if vibration > 3:
        return "HIGH_VIBRATION"
    return "NORMAL"


def analyse(path: Path) -> int:
    counts: dict[str, int] = {}
    rows = 0
    print(f"Telemetry report: {path}")
    print("-" * 96)
    print(f"{'Timestamp':20} {'Voltage(V)':>11} {'Current(A)':>11} {'Temp(C)':>9} {'Vibration':>11} {'Power(VA)':>11}  Status")
    print("-" * 96)

    try:
        with path.open("r", newline="", encoding="utf-8-sig") as handle:
            reader = csv.DictReader(handle)
            missing = set(FIELDNAMES) - set(reader.fieldnames or [])
            if missing:
                print(f"Error: missing required CSV column(s): {', '.join(sorted(missing))}", file=sys.stderr)
                return 2
            for row in reader:
                try:
                    voltage = float(row["voltage_rms_v"])
                    current = float(row["current_rms_a"])
                    temperature = float(row["temperature_c"])
                    vibration = float(row["vibration_rms_mm_s"])
                except (TypeError, ValueError):
                    status = "INVALID_DATA"
                    voltage = current = temperature = vibration = math.nan
                else:
                    status = classify(voltage, current, temperature, vibration)

                power = voltage * current if math.isfinite(voltage) and math.isfinite(current) else math.nan
                print(f"{(row.get('timestamp') or 'n/a')[:20]:20} {voltage:11.1f} {current:11.2f} {temperature:9.1f} {vibration:11.2f} {power:11.1f}  {status}")
                counts[status] = counts.get(status, 0) + 1
                rows += 1
    except OSError as exc:
        print(f"Error opening {path}: {exc}", file=sys.stderr)
        return 2

    print("-" * 96)
    print(f"Rows analysed: {rows}")
    print("Status counts: " + (", ".join(f"{key}={counts[key]}" for key in sorted(counts)) if counts else "no data rows"))
    print("Note: thresholds are for a student demo, not equipment protection.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_file", type=Path, help="CSV file with the required sensor columns")
    args = parser.parse_args()
    return analyse(args.csv_file)


if __name__ == "__main__":
    raise SystemExit(main())