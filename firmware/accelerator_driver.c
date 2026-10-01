#include "accelerator_driver.h"

/*
 * Software model of the memory-mapped accelerator registers.
 *
 * On a real RISC-V SoC, these would point to hardware addresses.
 * For now, we use an array so the driver can be compiled and tested
 * safely on a normal computer.
 */

static uint8_t accelerator_regs[16];

void accelerator_write(uint8_t address, uint8_t value)
{
    if (address < 16)
        accelerator_regs[address] = value;
}

uint8_t accelerator_read(uint8_t address)
{
    if (address < 16)
        return accelerator_regs[address];

    return 0;
}

void accelerator_load_vectors(const int8_t *a, const int8_t *b)
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
    accelerator_write(ACCEL_ADDR_CTRL, ACCEL_CTRL_START);
}

uint8_t accelerator_status(void)
{
    return accelerator_read(ACCEL_ADDR_STATUS);
}

uint8_t accelerator_read_result(void)
{
    return accelerator_read(ACCEL_ADDR_RESULT);
}
