.equ VALUE, 0xDEADBEEF
.equ COUNT, 5

.global main 
.type main, @function
main:
	li s0, VALUE
	addi sp, sp, -4
	sw   s0, 0(sp)

	lw   s1, 0(sp)
	addi sp, sp, 4

	li s0, 0
	li s1, COUNT

loop:
	add s0,s0,s1
	addi s1,s1,-1
	bnez s1, loop 

	ret 
