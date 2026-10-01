/*
 * Portable C99 reference implementation.
 * Replace platform I/O with MCU/FPGA drivers for a hardware target.
 */
#include <stdint.h>
#include <stdio.h>

typedef struct {
    int16_t mean;
    int16_t active_percent;
    int16_t peak;
} features_t;

static int32_t score(features_t x)
{
    const int16_t w0 = 3;
    const int16_t w1 = 5;
    const int16_t w2 = 2;
    const int16_t bias = -420;

    return (int32_t)x.mean * w0 +
           (int32_t)x.active_percent * w1 +
           (int32_t)x.peak * w2 +
           bias;
}

int main(void)
{
    features_t x = {55, 25, 120};
    int32_t s = score(x);

    printf("score=%ld label=%s\n",
           (long)s, s >= 0 ? "ALERT" : "SAFE");
    return 0;
}
