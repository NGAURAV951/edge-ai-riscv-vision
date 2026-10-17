#include "monitor.h"

#include <stdio.h>

int main(void)
{
    const struct {
        const char *name;
        SensorReadings readings;
    } cases[] = {
        {"Nominal pump", {230.0f, 4.2f, 42.0f, 1.1f}},
        {"Low supply", {165.0f, 4.1f, 45.0f, 1.2f}},
        {"High current", {230.0f, 14.0f, 55.0f, 1.5f}},
        {"Hot enclosure", {230.0f, 4.0f, 92.0f, 1.3f}},
        {"Excess vibration", {230.0f, 4.0f, 48.0f, 4.4f}}
    };
    const unsigned int count = (unsigned int)(sizeof(cases) / sizeof(cases[0]));
    unsigned int i;

    puts("Industrial Equipment Health Monitor - C demo");
    puts("Demo data only; not connected to physical sensors.\n");

    for (i = 0; i < count; ++i) {
        MonitorResult result = monitor_evaluate(&cases[i].readings);
        printf("%-18s V=%6.1f V I=%5.1f A T=%5.1f C vibration=%4.1f mm/s | power=%7.1f VA | %s\n",
               cases[i].name,
               cases[i].readings.voltage_rms_v,
               cases[i].readings.current_rms_a,
               cases[i].readings.temperature_c,
               cases[i].readings.vibration_rms_mm_s,
               result.apparent_power_va,
               monitor_fault_name(result.fault));
    }

    return 0;
}