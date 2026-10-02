/*
 * Edge-AI RISC-V Vision
 * Memory-mapped accelerator driver interface
 *
 * The RTL accelerator uses signed 8-bit operands and
 * a 32-bit accumulation path.
 */

#ifndef ACCELERATOR_DRIVER_H
#define ACCELERATOR_DRIVER_H

#include <stdint.h>

#define ACCEL_TILE_SIZE 16

/*
 * Register map
 *
 * Current software model exposes four elements per vector.
 * The RTL MAC itself is parameterized and currently verified
 * with a 16-element tile.
 */
#define ACCEL_ADDR_A0          0x00
#define ACCEL_ADDR_A1          0x01
#define ACCEL_ADDR_A2          0x02
#define ACCEL_ADDR_A3          0x03

#define ACCEL_ADDR_B0          0x04
#define ACCEL_ADDR_B1          0x05
#define ACCEL_ADDR_B2          0x06
#define ACCEL_ADDR_B3          0x07

#define ACCEL_ADDR_CTRL        0x08
#define ACCEL_ADDR_STATUS      0x09
#define ACCEL_ADDR_RESULT      0x0A
#define ACCEL_ADDR_RESULT_HIGH 0x0B

#define ACCEL_CTRL_START       0x01

#define ACCEL_STATUS_BUSY      0x01
#define ACCEL_STATUS_DONE      0x02

void accelerator_write(uint8_t address, uint8_t value);
uint8_t accelerator_read(uint8_t address);

void accelerator_load_vectors(
    const int8_t *a,
    const int8_t *b
);

void accelerator_start(void);

uint8_t accelerator_status(void);

uint16_t accelerator_read_result(void);

#endif
