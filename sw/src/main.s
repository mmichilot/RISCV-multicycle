.equ COUNT, 100

.global main 
.type main, @function
main:
	li s0, 0
	li s1, COUNT
loop:
	add s0,s0,s1
	addi s1,s1,-1
	bnez s1, loop 
