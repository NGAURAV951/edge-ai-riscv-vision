/*
 * Edge-AI RISC-V Vision
 * Accelerator driver verification
 */

#include "accelerator_driver.h"

#include <stdint.h>
#include <stdio.h>

int main(void)
{
    /*
     * Signed INT8 test:
     *
     * A = [1, -2, 3, -4]
     * B = [1,  2, 3,  4]
     *
     * Result:
     * 1*1 + (-2)*2 + 3*3 + (-4)*4
     * = 1 - 4 + 9 - 16
     * = -10
     */
    const int8_t a[4] = {1, -2, 3, -4};
    const int8_t b[4] = {1, 2, 3, 4};

    accelerator_load_vectors(a, b);

    accelerator_start();

    uint8_t status = accelerator_status();
    uint16_t raw_result = accelerator_read_result();

    int16_t signed_result = (int16_t)raw_result;

    printf("A = [%d, %d, %d, %d]\n",
           a[0], a[1], a[2], a[3]);

    printf("B = [%d, %d, %d, %d]\n",
           b[0], b[1], b[2], b[3]);

    printf("STATUS = 0x%02X\n", status);
    printf("RAW RESULT = 0x%04X\n", raw_result);
    printf("SIGNED RESULT = %d\n", signed_result);

    if ((status & ACCEL_STATUS_DONE) == 0)
    {
        printf("DRIVER_TEST_FAIL status did not report DONE\n");
        return 1;
    }

    if (signed_result != -10)
    {
        printf(
            "DRIVER_TEST_FAIL result=%d expected=-10\n",
            signed_result
        );
        return 1;
    }

    printf("SIGNED_DRIVER_TEST_PASS result=%d\n", signed_result);

    return 0;
}
