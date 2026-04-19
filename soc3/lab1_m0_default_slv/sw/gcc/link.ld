/* Cortex-M0 linker script: single SRAM (code+data+stack) */
MEMORY {
    SRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

ENTRY(Reset_Handler)

SECTIONS {
    .vectors 0x00000000 : {
        KEEP(*(.vectors))
    } > SRAM

    .text : {
        *(.text*)
        *(.rodata*)
    } > SRAM

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > SRAM

    . = ALIGN(4);
    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);  /* 0x00010000 */
}
