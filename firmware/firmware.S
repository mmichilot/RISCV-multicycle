.equ LEDS_ADDR, 0x02010000
.equ CLINT_ADDR, 0x02000000
.equ MTIME_ADDR, CLINT_ADDR + 0x4000
.equ MTIMECMP_ADDR, CLINT_ADDR + 0xBFF8
.equ TIMER_INT_CODE, 0x80000007

.text
main:
    # Since clock operates at 25 MHz, every
    # 25,000,000 cycles is 1 second
    li s0, 6250000
    la s1, MTIME_ADDR
    la s2, MTIMECMP_ADDR
    la s3, LEDS_ADDR
    li s4, 0    # Count

    call inc_mtimecmp

    # Setup interrupts
    la t0, isr
    csrw mtvec, t0  # Set mtvec to ISR

    li t0, 1 << 7
    csrs mie, t0    # Enable timer interrupt

    # Enable global interrupts!
    csrsi mstatus, 1 << 3

loop:
    j loop

#  Subroutine to increment mtimecmp
inc_mtimecmp:
    # Get current MTIME (a1:a0)
    lw a0, 0(s1) # MTIME_LO
    lw a1, 4(s1) # MTIME_HI

    # http://blog.flingos.co.uk/posts/217
    # Add MTIME_LO (a0) and count (s0) -> t0
    add t0, a0, s0

    # Increment MTIME_HI if there is a carry
    sltu t1, t0, a0
    beqz t1, no_carry
    add  a1, a1, t1
no_carry:
    # Put the sum back to t0
    mv a0, t0

    # Set MTIMECMP
    li t0, -1
    sw t0, 0(s2)
    sw a1, 4(s2)
    sw a0, 0(s2)

    ret

isr:
    csrr t0, mcause

    li t1, TIMER_INT_CODE
    beq t0, t1, timer_int
    mret

timer_int:
    # Increment count
    addi s4, s4, 1
    sw s4, 0(s3)
    call inc_mtimecmp
    mret
