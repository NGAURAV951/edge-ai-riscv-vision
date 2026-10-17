#include "monitor.h"

#include <math.h>
#include <stdio.h>

static int failures = 0;

#define CHECK(condition, name) do { \
    if (condition) { printf("PASS: %s\n", name); } \
    else { printf("FAIL: %s (line %d)\n", name, __LINE__); ++failures; } \
} while (0)

int main(void)
{
    SensorReadings nominal = {230.0f, 4.0f, 40.0f, 1.0f};
    SensorReadings low_voltage = {170.0f, 4.0f, 40.0f, 1.0f};
    SensorReadings high_voltage = {260.0f, 4.0f, 40.0f, 1.0f};
    SensorReadings high_current = {230.0f, 13.0f, 40.0f, 1.0f};
    SensorReadings high_temperature = {230.0f, 4.0f, 81.0f, 1.0f};
    SensorReadings high_vibration = {230.0f, 4.0f, 40.0f, 3.5f};
    SensorReadings bad_value = {230.0f, -1.0f, 40.0f, 1.0f};
    SensorReadings nan_value = {230.0f, NAN, 40.0f, 1.0f};
    MonitorResult result;

    result = monitor_evaluate(&nominal);
    CHECK(result.fault == FAULT_NORMAL, "nominal readings are normal");
    CHECK(fabsf(result.apparent_power_va - 920.0f) < 0.01f, "apparent power is V multiplied by I");
    CHECK(monitor_evaluate(&low_voltage).fault == FAULT_UNDER_VOLTAGE, "under-voltage detected");
    CHECK(monitor_evaluate(&high_voltage).fault == FAULT_OVER_VOLTAGE, "over-voltage detected");
    CHECK(monitor_evaluate(&high_current).fault == FAULT_OVER_CURRENT, "over-current detected");
    CHECK(monitor_evaluate(&high_temperature).fault == FAULT_OVER_TEMPERATURE, "high temperature detected");
    CHECK(monitor_evaluate(&high_vibration).fault == FAULT_HIGH_VIBRATION, "high vibration detected");
    CHECK(monitor_evaluate(&bad_value).fault == FAULT_INVALID_DATA, "negative current rejected");
    CHECK(monitor_evaluate(&nan_value).fault == FAULT_INVALID_DATA, "NaN reading rejected");
    CHECK(monitor_evaluate(0).fault == FAULT_INVALID_DATA, "null input rejected");

    if (failures != 0) {
        printf("\n%d test(s) failed.\n", failures);
        return 1;
    }

    puts("\nALL_C_TESTS_PASS");
    return 0;
}