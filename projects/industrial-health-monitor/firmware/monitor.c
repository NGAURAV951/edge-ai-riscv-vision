#include "monitor.h"

#include <math.h>

#define MAX_VALID_VOLTAGE_V 300.0f
#define MAX_VALID_CURRENT_A 100.0f
#define MIN_VALID_TEMPERATURE_C (-40.0f)
#define MAX_VALID_TEMPERATURE_C 200.0f
#define MAX_VALID_VIBRATION_MM_S 100.0f

#define UNDER_VOLTAGE_LIMIT_V 180.0f
#define OVER_VOLTAGE_LIMIT_V 250.0f
#define OVER_CURRENT_LIMIT_A 12.0f
#define OVER_TEMPERATURE_LIMIT_C 80.0f
#define HIGH_VIBRATION_LIMIT_MM_S 3.0f

static int readings_are_valid(const SensorReadings *r)
{
    if (r == 0) {
        return 0;
    }

    if (!isfinite(r->voltage_rms_v) || !isfinite(r->current_rms_a) ||
        !isfinite(r->temperature_c) || !isfinite(r->vibration_rms_mm_s)) {
        return 0;
    }

    if (r->voltage_rms_v < 0.0f || r->voltage_rms_v > MAX_VALID_VOLTAGE_V ||
        r->current_rms_a < 0.0f || r->current_rms_a > MAX_VALID_CURRENT_A ||
        r->temperature_c < MIN_VALID_TEMPERATURE_C ||
        r->temperature_c > MAX_VALID_TEMPERATURE_C ||
        r->vibration_rms_mm_s < 0.0f ||
        r->vibration_rms_mm_s > MAX_VALID_VIBRATION_MM_S) {
        return 0;
    }

    return 1;
}

MonitorResult monitor_evaluate(const SensorReadings *readings)
{
    MonitorResult result = {0.0f, FAULT_INVALID_DATA};

    if (!readings_are_valid(readings)) {
        return result;
    }

    result.apparent_power_va = readings->voltage_rms_v * readings->current_rms_a;
    result.fault = FAULT_NORMAL;

    /* Priority: invalid data, electrical limits, temperature, vibration. */
    if (readings->voltage_rms_v < UNDER_VOLTAGE_LIMIT_V) {
        result.fault = FAULT_UNDER_VOLTAGE;
    } else if (readings->voltage_rms_v > OVER_VOLTAGE_LIMIT_V) {
        result.fault = FAULT_OVER_VOLTAGE;
    } else if (readings->current_rms_a > OVER_CURRENT_LIMIT_A) {
        result.fault = FAULT_OVER_CURRENT;
    } else if (readings->temperature_c > OVER_TEMPERATURE_LIMIT_C) {
        result.fault = FAULT_OVER_TEMPERATURE;
    } else if (readings->vibration_rms_mm_s > HIGH_VIBRATION_LIMIT_MM_S) {
        result.fault = FAULT_HIGH_VIBRATION;
    }

    return result;
}

const char *monitor_fault_name(FaultCode fault)
{
    switch (fault) {
    case FAULT_NORMAL: return "NORMAL";
    case FAULT_INVALID_DATA: return "INVALID_DATA";
    case FAULT_UNDER_VOLTAGE: return "UNDER_VOLTAGE";
    case FAULT_OVER_VOLTAGE: return "OVER_VOLTAGE";
    case FAULT_OVER_CURRENT: return "OVER_CURRENT";
    case FAULT_OVER_TEMPERATURE: return "OVER_TEMPERATURE";
    case FAULT_HIGH_VIBRATION: return "HIGH_VIBRATION";
    default: return "UNKNOWN_FAULT";
    }
}