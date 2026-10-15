#ifndef INDUSTRIAL_HEALTH_MONITOR_H
#define INDUSTRIAL_HEALTH_MONITOR_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    float voltage_rms_v;
    float current_rms_a;
    float temperature_c;
    float vibration_rms_mm_s;
} SensorReadings;

typedef enum {
    FAULT_NORMAL = 0,
    FAULT_INVALID_DATA,
    FAULT_UNDER_VOLTAGE,
    FAULT_OVER_VOLTAGE,
    FAULT_OVER_CURRENT,
    FAULT_OVER_TEMPERATURE,
    FAULT_HIGH_VIBRATION
} FaultCode;

typedef struct {
    float apparent_power_va;
    FaultCode fault;
} MonitorResult;

/* Demo thresholds only; do not use as real equipment protection settings. */
MonitorResult monitor_evaluate(const SensorReadings *readings);
const char *monitor_fault_name(FaultCode fault);

#ifdef __cplusplus
}
#endif

#endif /* INDUSTRIAL_HEALTH_MONITOR_H */