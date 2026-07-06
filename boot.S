/* boot.S */
.global _start

.section .text.boot
_start:
    # Initialize the Stack Pointer to the TOP of the 4KB RAM (Base 0x2000 + 0x1000)
    li sp, 0x3000

    # Jump to the C main function
    jal ra, main

    # Fallback infinite loop just in case main returns
end_loop:
    j end_loop