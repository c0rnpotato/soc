/*
 * test.c — HY-SoC Lab2: SysTick interrupt-based LED blink
 *
 * Change BLINK_PERIOD_SEC to adjust the blink period (in seconds).
 *
 * Build modes (-DSIMULATION / undefined):
 *   SIMULATION  : shortened SysTick period (prioritize simulation speed)
 *   (undefined) : BLINK_PERIOD_SEC period at 50 MHz
 *
 * SysTick_Config(ticks) -- CMSIS Core API:
 *   Fires SysTick interrupt every 'ticks' clocks.
 *   SIMULATION  : 1,000 clocks x BLINK_TICKS(5) = 5,000 clocks/toggle
 *   FPGA 50MHz  : 500,000 clocks(10ms) x BLINK_TICKS(100) = 1s/toggle
 *
 * PASS criteria: write 0x900DD00D to 0x7FFC after PASS_BLINK_COUNT toggles
 */

#include "C:\Users\dsald\Desktop\hy-soc\common\include\hy_soc.h"

/* -- User configuration ---------------------------------------- */
#define BLINK_PERIOD_SEC   1u    /* FPGA: blink period (seconds) */
#define PASS_BLINK_COUNT   3u    /* PASS after this many toggles  */
/* -------------------------------------------------------------- */

/* Completion signal (testbench handshake) */
#define DONE_ADDR  (*(volatile uint32_t *)0x00007FFCu)
#define PASS_CODE  0x900DD00Du

#ifdef SIMULATION
  #define SYSTICK_TICKS   1000u   /* ISR every 1,000 clocks      */
  #define BLINK_TICKS        5u   /* LED toggle every 5,000 clk  */
#else
  #define SYSTICK_TICKS  500000u  /* 500,000 clocks = 10ms @ 50MHz */
  #define BLINK_TICKS    (100u * BLINK_PERIOD_SEC)
#endif

/* -- ISR shared variables ------------------------------------- */
static volatile uint32_t tick_cnt  = 0u;
static volatile uint32_t blink_cnt = 0u;
static          uint32_t led_state = 0x0Fu;  /* initial: all ON */

/* -- SysTick ISR ---------------------------------------------- */
void SysTick_Handler(void)
{
    tick_cnt++;
    if (tick_cnt >= BLINK_TICKS) {
        tick_cnt   = 0u;
        led_state ^= 0x0Fu;
        HY_LED->DATA = led_state;
        blink_cnt++;
    }
}

/* -- main ----------------------------------------------------- */
int main(void)
{
    led_state = 0x0Fu;
		tick_cnt = 0u;
	  blink_cnt = 0u;
	  HY_LED->DATA = led_state;
	
    SysTick_Config(SYSTICK_TICKS);  /* CMSIS: SysTick ISR every SYSTICK_TICKS clocks */

    while (blink_cnt < PASS_BLINK_COUNT);   /* wait for ISR to increment counter */

    SysTick->CTRL = 0u;             /* stop SysTick */
    DONE_ADDR = PASS_CODE;
    while (1);
    return 0;
}
