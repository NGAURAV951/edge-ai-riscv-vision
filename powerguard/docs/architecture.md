# Architecture and ECE Design Notes

## System flow

```text
Sensor or CSV source
        |
Validate and normalize values
        |
Calculate voltage × current (VA)
        |
Apply configurable prototype thresholds
        |
NORMAL or ALERT flags
        |
Terminal report / future telemetry
```

This version is simulation-first. Python reads CSV records; the embedded-C example uses a constant sample array representing readings returned by sensor drivers.

## A possible physical signal path

1. A sensor/transducer produces an electrical signal.
2. Analog conditioning scales and filters it for the ADC input range.
3. The ADC converts the signal to digital counts.
4. Firmware applies calibration/scaling.
5. A digital filter can reduce noise, with some response delay.
6. Threshold logic sets status flags.
7. UART or another communication interface sends timestamped data to a logger/dashboard.

The current repository starts after sensor acquisition and calibration; physical acquisition is a future step.

## Units and rules

- Voltage in volts (V), current in amperes (A), temperature in degrees Celsius (°C).
- Voltage × current is labelled apparent power in volt-amperes (VA), not watts. This demo does not measure power factor or synchronized voltage/current waveforms.
- Status is ALERT if one or more prototype thresholds is crossed.
- Rules are examples only; a real design must use documented system limits and a safety review.

## Why C and Python?

C models a compact, deterministic logic loop that could be adapted to a microcontroller. Python makes batch data inspection and automated test coverage accessible. Similar rules in both implementations help compare expected behavior.

## Employer relevance (independent learning project)

- **Texas Instruments:** embedded C, ADC/sensor interfaces, data validation, threshold logic.
- **BEL:** telemetry-style monitoring, deterministic fault flags, testable behavior.
- **Reliance Industries:** the general idea of equipment-condition and electrical-parameter monitoring.

The project is not affiliated with these companies and is not a certified or industrial product.

## Future steps

- Add a sensor interface abstraction and ADC scaling for a specific board.
- Implement and measure a moving-average filter.
- Add UART telemetry with sequence numbers and error detection.
- Compare readings against a suitable reference meter at safe low voltages.
- Document accuracy, repeatability, and limitations after physical testing.
- For real AC power, acquire appropriately synchronized waveforms and calculate average instantaneous power.
