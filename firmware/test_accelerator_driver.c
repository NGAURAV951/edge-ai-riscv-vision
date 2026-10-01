#include <stdio.h>
#include <stdint.h>

#include "accelerator_driver.h"

int main(void)
{
    const int8_t a[4] = {1, 2, 3, 4};
    const int8_t b[4] = {10, 20, 30, 40};

    accelerator_load_vectors(a, b);

    printf("A = [%d, %d, %d, %d]\n",
           a[0], a[1], a[2], a[3]);

    printf("B = [%d, %d, %d, %d]\n",
           b[0], b[1], b[2], b[3]);

    accelerator_start();

    printf("CTRL = 0x%02X\n",
           accelerator_read(ACCEL_ADDR_CTRL));

    printf("STATUS = 0x%02X\n",
           accelerator_status());

    uint16_t result = accelerator_read_result();

    printf("RESULT REGISTER = 0x%04X\n", result);

    if (result == 300)
        printf("DRIVER_TEST_PASS result=%u\n", result);
    else
        printf("DRIVER_TEST_FAIL result=%u expected=300\n", result);

    return 0;
}
