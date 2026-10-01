#ifndef ACCELERATOR_DRIVER_H
#define ACCELERATOR_DRIVER_H

#include <stdint.h>

/*
 * Memory-mapped accelerator register map
 *
 * A0-A3   : Vector A elements
 * B0-B3   : Vector B elements
 * CTRL    : Write 1 to start
 * STATUS  : Busy / Done
 * RESULT  : Low 8 bits of result
 */

#define ACCEL_ADDR_A0       0x00
#define ACCEL_ADDR_A1       0x01
#define ACCEL_ADDR_A2       0x02
#define ACCEL_ADDR_A3       0x03

#define ACCEL_ADDR_B0       0x04
#define ACCEL_ADDR_B1       0x05
#define ACCEL_ADDR_B2       0x06
#define ACCEL_ADDR_B3       0x07

#define ACCEL_ADDR_CTRL     0x08
#define ACCEL_ADDR_STATUS   0x09
#define ACCEL_ADDR_RESULT   0x0A

#define ACCEL_CTRL_START    0x01

#define ACCEL_STATUS_BUSY   0x01
#define ACCEL_STATUS_DONE   0x02

/*
 * Driver interface.
 *
 * These functions represent the operations a CPU firmware
 * would perform through the memory-mapped accelerator registers.
 */

void accelerator_write(uint8_t address, uint8_t value);
uint8_t accelerator_read(uint8_t address);

void accelerator_load_vectors(const int8_t *a, const int8_t *b);
void accelerator_start(void);
uint8_t accelerator_status(void);
uint8_t accelerator_read_result(void);

#endif
