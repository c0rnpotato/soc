/* startup.s — Cortex-M0 minimal startup */
    .syntax unified
    .cpu cortex-m0
    .thumb

    /* Vector table */
    .section .vectors, "a"
    .word   _stack_top          /* 0x00: Initial SP */
    .word   Reset_Handler       /* 0x04: Reset vector */
    .word   Default_Handler     /* 0x08: NMI */
    .word   Default_Handler     /* 0x0C: HardFault */
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

    .thumb_func
Default_Handler:
    b       .
