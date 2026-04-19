/*
 * test.c — HY-SoC Lab1: Default Slave (unmapped address -> HardFault) test
 *
 * Based on ARM CMSDK default_slaves_tests pattern.
 *
 * Test items:
 *   1~3. SRAM word/byte/counter verification (same as Lab0)
 *   4.   Write to unmapped address -> verify HardFault
 *   5.   Read from unmapped address -> verify HardFault
 *
 * HardFault handling (CMSDK pattern):
 *   Naked functions (address_test_read/write) access the faulting address.
 *   HardFault_Handler_c() replaces stacked R0 with a valid address (&temp_data).
 *   Faulting instruction re-executes -> completes normally on valid address.
 */

#include "C:\Users\dsald\Desktop\hy-soc\common\include\hy_soc.h"

#define DONE_ADDR  (*(volatile uint32_t *)0x00007FFCu)
#define PASS_CODE  0x900DD00Du
#define FAIL_CODE  0xDEADDEADu

/* Naked functions defined in assembly */
extern uint32_t address_test_read(uint32_t addr);
extern void     address_test_write(uint32_t addr, uint32_t wdata);

/* HardFault state */
volatile int      hardfault_occurred;
volatile int      hardfault_expected;
volatile uint32_t temp_data;

/*
 * HardFault C handler (CMSDK pattern)
 *   hardfault_args[0] = stacked R0 (the address that caused the fault)
 *   Replace with &temp_data so re-execution of the faulting instruction succeeds.
 */
void HardFault_Handler_c(uint32_t *hardfault_args) {
    hardfault_occurred++;
    hardfault_args[0] = (uint32_t)&temp_data;
}

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

    /* --- Test 4: Unmapped write → HardFault --- */
    temp_data = 0u;
    hardfault_occurred = 0;
    hardfault_expected = 1;
    address_test_write(0x20000000u, 0x3456789Au);
    if (hardfault_occurred != 1) fail();

    /* --- Test 5: Unmapped read → HardFault --- */
    hardfault_occurred = 0;
    address_test_read(0x20000000u);
    if (hardfault_occurred != 1) fail();

    hardfault_expected = 0;

    DONE_ADDR = PASS_CODE;
    while (1);
    return 0;
}
