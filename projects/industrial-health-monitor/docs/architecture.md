# Architecture and design notes

## Data flow

    Simulated sensors / future sensor drivers
                     |
                     v
           SensorReadings structure
                     |
                     v
       Input validation (finite + range checks)
                     |
                     v
       Apparent power: Vrms x Irms (VA)
                     |
                     v
        Threshold-based fault evaluation
                     |
              +------+------+
              |             |
              v             v
         C status       CSV log analyser
              |             |
              v             v
          Report       Row status + counts

Optional hardware concept:
Fixed-point sensor values -> SystemVerilog fault_guard -> fault_code

## Interface decisions

- SensorReadings keeps the monitor independent of a specific MCU ADC, timer, or serial driver.
- monitor_evaluate() returns a MonitorResult, which makes the decision logic easy to test on a host before porting to an MCU.
- The C function handles null pointers, NaN/infinite values, negative sensor values, and implausible ranges.
- The sample calculates apparent power in VA from RMS voltage and current. It does not estimate real power in watts because power factor is not measured.
- Only the first matching fault is returned. A future revision could use a bit mask to record simultaneous faults.
- SystemVerilog inputs use scaled integer values. Read the source comments for the units.

## Suggested physical prototype (future work)

1. Begin with low-voltage, current-limited bench power and one temperature sensor.
2. Add a suitably rated and isolated current-measurement channel; validate its scale with a trusted meter.
3. Add an accelerometer and document sample rate, axis, filtering, and calibration.
4. Send timestamped measurements over UART to a host tool.
5. Port sensor acquisition to a selected MCU after checking ADC, I2C/SPI/UART, timer, and voltage-level requirements.

Never connect mains voltage directly to a development board or breadboard. This is a teaching prototype, not certified industrial or safety equipment.