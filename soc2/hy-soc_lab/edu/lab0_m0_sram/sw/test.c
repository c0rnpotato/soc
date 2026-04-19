/*
 * test.c — HY-SoC Lab0: basic memory test
 *
 * Test items:
 *   1. Word read/write verification
 *   2. Byte read/write verification
 *   3. Counter accumulation verification
 *
 * Completion signal (testbench handshake):
 *   PASS -> write 0x900D_D00D to 0x0000_7FFC
 *   FAIL -> write 0xDEAD_DEAD to 0x0000_7FFC
 */

#include "hy_soc.h"

#define DONE_ADDR  (*(volatile uint32_t *)0x00007FFCu)
#define PASS_CODE  0x900DD00Du
#define FAIL_CODE  0xDEADDEADu

static void fail(void) {
    DONE_ADDR = FAIL_CODE;
    while (1);
}

int main(void) {
    volatile uint32_t *wptr = (volatile uint32_t *)0x00001000u;
    volatile uint8_t  *bptr = (volatile uint8_t  *)0x00002000u;
    int i;

    /* --- Test 1: Word write/read --- */
    wptr[0] = 0xA5A5A5A5u;
    wptr[1] = 0x12345678u;
    wptr[2] = 0xDEADBEEFu;
    wptr[3] = 0x00000000u;

    if (wptr[0] != 0xA5A5A5A5u) fail();
    if (wptr[1] != 0x12345678u) fail();
    if (wptr[2] != 0xDEADBEEFu) fail();

    /* --- Test 2: Byte write/read --- */
    bptr[0] = 0x11u;
    bptr[1] = 0x22u;
    bptr[2] = 0x33u;
    bptr[3] = 0x44u;

    if (bptr[0] != 0x11u) fail();
    if (bptr[1] != 0x22u) fail();
    if (bptr[2] != 0x33u) fail();
    if (bptr[3] != 0x44u) fail();

    /* --- Test 3: Counter accumulation --- */
    wptr[3] = 0u;
    for (i = 0; i < 10; i++)
        wptr[3]++;
    if (wptr[3] != 10u) fail();

    DONE_ADDR = PASS_CODE;
    while (1);
    return 0;
}
