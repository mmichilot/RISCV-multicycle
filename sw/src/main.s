.equ VALUE, 0xDEADBEEF

.global main 
.type main, @function
main:
	li s0, VALUE
	addi sp, sp, -4
	sw   s0, 0(sp)

	lw   s1, 0(sp)
	addi sp, sp, 4

	ret 
