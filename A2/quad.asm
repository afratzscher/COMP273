# This program gets values for a, b, and c from user and outputs each value of 
# x for which the congurenece holds
# NOTE: int a stored in $t0, int b stored in $t1, int c stored in $t2, and 
# solutions (x) stored in $t3

# Name: Anne-Sophie Fratzscher
# ID: 260705446

	.data
strA:		.asciiz "Enter value for a: "
strB:		.asciiz "Enter value for b: "
strC:		.asciiz "Enter value for c: "
strX:		.asciiz "\nValues of x are: "
blank:		.asciiz "\n"
nosolution:	.asciiz "No solutions"

	.text
	.globl main

main:	
	#get a from user
	li $v0, 4		# system call code for print_str
	la $a0, strA		# print strA
	syscall
	li $v0,5		# read integer a
	syscall
	add $t0, $zero, $v0     # copy input from $v0 to $t0
	
	#get b from user
	li $v0, 4		# system call code for print_str
	la $a0, strB		# print strB
	syscall
	li $v0,5		# read integer b
	syscall
	add $t1, $zero, $v0     # copy input from $v0 to $t1
	
	#get c from user
	li $v0, 4		# system call code for print_str
	la $a0, strC		# print strC
	syscall
	li $v0,5		# read integer c
	syscall
	add $t2, $zero, $v0     # copy input from $v0 to $t2
	
	#set max x value
	add $t3, $t2, $0	# sets x (stored in $t3) to c ($t2)
	
	#print string saying "values of x are:
	li $v0, 4		# print strX saying what values of x are
	la $a0, strX
	syscall  
	
	#make counter for number of solutions (if 0, print "no solution" later)
	add $t6, $0, $0 	# counter for number of solutions

loop:
	blt $t3, $0, end	# if x less than 0, go to end
	mul $t4, $t3, $t3	# squares x and puts into $t4
	rem $t5, $t4, $t1	# divides x^2 ($t4) by b ($t1) and gets remainder ($t5)
	beq $t5, $t0, print	# if remainder equal to a (is congruent), go to print that value of x
	add $t3, $t3, -1	# decrease x ($t3) by 1
	j loop			# loop until x less than 0

print:
	li  $v0, 4		# system call code for print_str
       	la  $a0, blank		# print a blank line
       	syscall 
       	
	li $v0, 1		# system call code for print_int
	add $a0, $0, $t3	# print x value for which congruence holds
	syscall	
	
	add $t3, $t3, -1	# decrease x ($t3) by 1
	
	add $t6, $t6, 1		# increase counter for number of solutions
	j loop
	
end:	
	beq $t6, $0, nosol	# if number of solutions is 0, go to nosol
	
	li $v0, 10		# exit code
	syscall

nosol:	
	li  $v0, 4		# print a line saying no solutions
       	la  $a0, nosolution
       	syscall 
       	
       	li $v0, 10		# exit code
	syscall
		
