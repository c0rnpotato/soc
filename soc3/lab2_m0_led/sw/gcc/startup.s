/* startup.s — Cortex-M0 startup (Lab2: SysTick interrupt support) */
    .syntax unified
    .cpu cortex-m0
    .thumb

    /* Vector table
     * Cortex-M0 exception layout (ARMv6-M):
     *   0x00 Initial SP
     *   0x04 Reset
     *   0x08 NMI
     *   0x0C HardFault
     *   0x10~0x38 reserved (11 entries)
     *   0x3C SysTick (exception #15)
     *   0x40~0x7C IRQ0~15
     */
    .section .vectors, "a"
    .word   _stack_top          /* 0x00: Initial SP */
    .word   Reset_Handler       /* 0x04: Reset */
    .word   Default_Handler     /* 0x08: NMI */
    .word   Default_Handler     /* 0x0C: HardFault */
    .rept   11
    .word   Default_Handler     /* 0x10~0x38: reserved */
    .endr
    .word   SysTick_Handler     /* 0x3C: SysTick */
    .rept   16
    .word   Default_Handler     /* 0x40~0x7C: IRQ0~15 */
    .endr

    /* SysTick_Handler is defined in the C file (test.c).
     * The linker resolves this slot to the C function. */
    .extern SysTick_Handler

    .section .text
    .thumb_func
    .global Reset_Handler
Reset_Handler:
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
    b       .

    .thumb_func
    .weak   Default_Handler
Default_Handler:
    b       .
