/*
 * Edge-AI RISC-V Vision
 * Software model of the accelerator driver.
 *
 * This file models the memory-mapped register behavior that
 * the future RISC-V/FPGA implementation will expose.
 */

#include "accelerator_driver.h"

#include <stdio.h>

static uint8_t registers[16];

void accelerator_write(uint8_t address, uint8_t value)
{
    registers[address] = value;
}

uint8_t accelerator_read(uint8_t address)
{
    return registers[address];
}

void accelerator_load_vectors(
    const int8_t *a,
    const int8_t *b
)
{
    accelerator_write(ACCEL_ADDR_A0, (uint8_t)a[0]);
    accelerator_write(ACCEL_ADDR_A1, (uint8_t)a[1]);
    accelerator_write(ACCEL_ADDR_A2, (uint8_t)a[2]);
    accelerator_write(ACCEL_ADDR_A3, (uint8_t)a[3]);

    accelerator_write(ACCEL_ADDR_B0, (uint8_t)b[0]);
    accelerator_write(ACCEL_ADDR_B1, (uint8_t)b[1]);
    accelerator_write(ACCEL_ADDR_B2, (uint8_t)b[2]);
    accelerator_write(ACCEL_ADDR_B3, (uint8_t)b[3]);
}

void accelerator_start(void)
{
    int8_t a[4];
    int8_t b[4];

    int32_t result;

    a[0] = (int8_t)accelerator_read(ACCEL_ADDR_A0);
    a[1] = (int8_t)accelerator_read(ACCEL_ADDR_A1);
    a[2] = (int8_t)accelerator_read(ACCEL_ADDR_A2);
    a[3] = (int8_t)accelerator_read(ACCEL_ADDR_A3);

    b[0] = (int8_t)accelerator_read(ACCEL_ADDR_B0);
    b[1] = (int8_t)accelerator_read(ACCEL_ADDR_B1);
    b[2] = (int8_t)accelerator_read(ACCEL_ADDR_B2);
    b[3] = (int8_t)accelerator_read(ACCEL_ADDR_B3);

    result =
        (int32_t)a[0] * b[0] +
        (int32_t)a[1] * b[1] +
        (int32_t)a[2] * b[2] +
        (int32_t)a[3] * b[3];

    accelerator_write(
        ACCEL_ADDR_RESULT,
        (uint8_t)(result & 0xFF)
    );

    accelerator_write(
        ACCEL_ADDR_RESULT_HIGH,
        (uint8_t)((result >> 8) & 0xFF)
    );

    accelerator_write(
        ACCEL_ADDR_CTRL,
        ACCEL_CTRL_START
    );

    accelerator_write(
        ACCEL_ADDR_STATUS,
        ACCEL_STATUS_DONE
    );
}

uint8_t accelerator_status(void)
{
    return accelerator_read(ACCEL_ADDR_STATUS);
}

uint16_t accelerator_read_result(void)
{
    uint16_t low;
    uint16_t high;

    low = accelerator_read(ACCEL_ADDR_RESULT);
    high = accelerator_read(ACCEL_ADDR_RESULT_HIGH);

    return (uint16_t)(low | (high << 8));
}
