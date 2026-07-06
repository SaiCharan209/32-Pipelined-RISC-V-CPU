/* link.ld - 8KB ROM / 4KB RAM */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    /* 8KB Instruction Memory */
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 0x2000 
    /* 4KB Data Memory */
    RAM (rwx) : ORIGIN = 0x00002000, LENGTH = 0x1000
}

SECTIONS
{
    .text : {
        *(.text.boot)
        *(.text)
        *(.text.*)
    } > ROM

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } > ROM

    .data : {
        *(.data)
    } > RAM

    .bss : {
        *(.bss)
    } > RAM
}