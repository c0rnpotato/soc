/*
 * startup_cm0.S — Cortex-M0 startup for HY-SoC Lab1 (Arm Compiler 6 / armclang)
 *
 * HardFault handler: MSP/PSP discrimination + C handler call (CMSDK pattern).
 * address_test_read/write: naked functions for fault-tolerant memory access.
 */
    .syntax unified
    .cpu cortex-m0
    .thumb

/* ---------- Stack top (matches scatter.sct ARM_LIB_STACK) ---------- */
    .equ    __initial_sp, 0x00010000    /* SRAM 64 KB top */
    .globl  __initial_sp

/* ---------- Vector Table (RESET area) ---------- */
    .section RESET, "a", %progbits
    .p2align 3
    .globl  __Vectors
    .globl  __Vectors_End
    .globl  __Vectors_Size

__Vectors:
    .word   __initial_sp        /* 0x00: Initial Stack Pointer          */
    .word   Reset_Handler       /* 0x04: Reset                          */
    .word   Default_Handler     /* 0x08: NMI                            */
    .word   HardFault_Handler   /* 0x0C: Hard Fault                     */
    .rept   12
    .word   Default_Handler     /* 0x10-0x3C: reserved + SysTick        */
    .endr
    .rept   16
    .word   Default_Handler     /* 0x40-0x7C: IRQ0-15                   */
    .endr
__Vectors_End:

    .equ __Vectors_Size, __Vectors_End - __Vectors

/* ---------- Reset Handler ---------- */
    .section .text
    .p2align 2
    .thumb_func
    .globl  Reset_Handler
    .type   Reset_Handler, %function
Reset_Handler:
    ldr     r0, =__main         /* Arm C library: scatter-load + __rt_entry -> main() */
    bx      r0

/* ---------- HardFault Handler (CMSDK pattern) ---------- */
    .thumb_func
    .globl  HardFault_Handler
    .type   HardFault_Handler, %function
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

/* ---------- address_test_read / address_test_write (CMSDK pattern) ---------- */
    .thumb_func
    .globl  address_test_read
    .type   address_test_read, %function
address_test_read:
    ldr     r1, [r0]
    dsb
    movs    r0, r1
    bx      lr

    .thumb_func
    .globl  address_test_write
    .type   address_test_write, %function
address_test_write:
    str     r1, [r0]
    dsb
    bx      lr

/* ---------- Default Handler (weak) ---------- */
    .thumb_func
    .weak   Default_Handler
    .type   Default_Handler, %function
Default_Handler:
    b       .

    .end
