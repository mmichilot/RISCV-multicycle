.equ SRAM_ADDR, 0x80000000

.text
main:
    li t0, SRAM_ADDR
    jr t0