# This program illustrates an exercise of capitalizing a string.
# The test string is hardcoded. The program should capitalize the input string
# Comment your work

# Name: Anne-Sophie Fratzscher
# ID: 260705446

	.data

inputstring: 	.asciiz "this is A StrinG"
outputstring:	.space 100
blank:		"\n"

	.text
	.globl main

main:	
	li $v0, 4			# system call code for print_str
	la $a0, inputstring		# print inputstring
	syscall					
       	
	li $t0, 0			#set t0 to 0 for looping through string
loop:
	lb $t1, inputstring($t0)	#load byte
	beq $t1, 0, exit		#if null character, go to exit
	blt $t1, 'a', uppercase		#if ascii code less than ascii for a, then letter is uppercase, so go to uppercase
	bgt $t1, 'z', uppercase		#if ascii code greater than for z, is uppercase, so go to uppercase
	sub $t1, $t1, 32		#if NOT uppercase, subtract 32 to make it uppercase  
	sb $t1, inputstring($t0)	#store uppercase letter
	
	
uppercase:
	addi $t0, $t0, 1		#if uppercase, go to next byte
	j loop
	
exit:   
	li  $v0, 4			# system call code for print_str
       	la  $a0, blank			# print blank
       	syscall 
       	
	li $v0, 4			# system call code for print_str
	la $a0, inputstring		# print capitalized string
	syscall
	
	li $v0, 10			# exit code
	syscall
		
