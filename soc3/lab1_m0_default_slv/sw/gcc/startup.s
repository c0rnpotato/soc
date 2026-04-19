/* startup.s — Cortex-M0 startup (v02: includes HardFault handler)
 *
 * HardFault handling: ARM CMSDK default_slaves_tests pattern.
 *   - Determine MSP/PSP, then call C handler
 *   - C handler replaces stacked R0 with a valid address
 *   - Faulting instruction re-executes, succeeds on valid address
 */
    .syntax unified
    .cpu cortex-m0
    .thumb

    /* Vector table */
    .section .vectors, "a"
    .word   _stack_top          /* 0x00: Initial SP */
    .word   Reset_Handler       /* 0x04: Reset vector */
    .word   Default_Handler     /* 0x08: NMI */
    .word   HardFault_Handler   /* 0x0C: HardFault */
    .rept   12
    .word   Default_Handler     /* 0x10~0x3C: reserved */
    .endr
    .rept   16
    .word   Default_Handler     /* 0x40~0x7C: IRQ0~15 */
    .endr

    .section .text
    .thumb_func
    .global Reset_Handler
Reset_Handler:
    /* Initialize stack pointer */
    ldr     r0, =_stack_top
    mov     sp, r0

    /* Clear BSS section to zero */
    ldr     r0, =_bss_start
    ldr     r1, =_bss_end
    movs    r2, #0
bss_loop:
    cmp     r0, r1
    bge     bss_done
    str     r2, [r0]
    adds    r0, r0, #4
    b       bss_loop
bss_done:
    bl      main
    /* Infinite loop on main return */
    b       .

    /* -------------------------------------------------------------------
     * HardFault Handler (CMSDK pattern)
     *
     * Determine MSP/PSP via EXC_RETURN[2], pass stack frame pointer in R0
     * and EXC_RETURN value in R1 to the C handler.
     * ------------------------------------------------------------------- */
    .thumb_func
    .global HardFault_Handler
HardFault_Handler:
    movs    r0, #4
    mov     r1, lr
    tst     r0, r1
    beq     stacking_used_msp
    mrs     r0, psp             /* stacking was using PSP */
    ldr     r1, =HardFault_Handler_c
    bx      r1
stacking_used_msp:
    mrs     r0, msp             /* stacking was using MSP */
    ldr     r1, =HardFault_Handler_c
    bx      r1
    .pool

    /* -------------------------------------------------------------------
     * address_test_read / address_test_write (CMSDK pattern)
     *
     * Naked functions: access memory directly using R0 as address.
     * On HardFault, the C handler replaces stacked R0 with a valid address,
     * so the faulting instruction re-executes and completes normally.
     * ------------------------------------------------------------------- */
    .thumb_func
    .global address_test_read
address_test_read:
    ldr     r1, [r0]
    dsb
    movs    r0, r1
    bx      lr

    .thumb_func
    .global address_test_write
address_test_write:
    str     r1, [r0]
    dsb
    bx      lr

    .thumb_func
Default_Handler:
    b       .
