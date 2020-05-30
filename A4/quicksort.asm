#studentName: Anne-Sophie Fratzscher
#studentID: 260705446

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
#any any data you need be after this line 
	str1: .asciiz "Welcome to QuickSort"
	str2: .asciiz "\nThe sorted array is: "
	str3: .asciiz "\nThe array is re-initialized"
	str4: .asciiz "\n"
	str8: .asciiz "Finished running QuickSort program"
	arrayinput: .space 100	#space to store max 10 elements (extra space for possible invalid inputs) 
	array: .word 40		#space to store ints
	arraysorted: .space 100  #stores sorted array for printing
	size: .space 4 		#array size
	first: .space 4		#holds FIRST element as char
	bytesAdded: .space 4	#holds number of bytes added to arraysorted
	.text
	.globl main

main:	# all subroutines you create must come below "main"
########################################################################################################
#print "Welcome to QuickSort"
		la $a1, str1		#load address into $a1
	print1: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print1	#if not equal to null character, continue to print
		
#clear arraysorted first
	la $a0, arraysorted
clearArraySorted:
	lw $t0, 0($a0)		#load word
	beq $t0, '\0', startsort#if empty, go to start
	add $t0, $0, $0		#t0=0
	sw $t0, 0($a0)		#store null
	addi $a0, $a0, 4	#increment array
	j clearArraySorted
	
##################################################################################################
#get array from MMIO, print to screen until s, c, or q pressed, and save to array
startsort:
	#print new line
		la $a1, str4		#load address into $a1
	print4: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print4	#if not equal to null character, continue to print
		
	#get array from MMIO and save to arrayinput
		la $t2, arrayinput	#load address of array
	start:
		lb $t1, 0($t2)		#load byte into $t1
		beq $t1, '\0', echo	#if equal to '\0', go to echo
		addi $t2, $t2, 1	#else, increment by 1 byte
		j start
		
	echo:	jal Read		# reading and writing using MMIO
		add $a0,$v0,$zero	# in an infinite loop until press "Enter"
		jal Write	
		add $a0, $v0, $zero
		jal Copy		#copy input to sentence
		j echo

	Read:  	lui $t0, 0xffff 	#ffff0000
	Loop1:	lb $t1, 0($t0) 		#load from input control register
		andi $t1,$t1,0x0001	#reset all bits except LSB
		beq $t1,$zero,Loop1	#if not ready, loop back
		lb $v0, 4($t0) 		#read
		beq $v0, 113, printQuit#if key pressed is "q", go to printQuit
		beq $v0, 99, clear 	#if key pressed is "c", go to clear
		beq $v0, 115, sort 	#if key pressed is "s", go to sort
		blt $v0, 32, Loop1	#if less than space, loop
		bgt $v0, 57, Loop1	#if greater than '9', loop
		jr $ra

	Write:  lui $t0, 0xffff 	#ffff0000
	Loop2: 	lb $t1, 8($t0) 		#load output control register
		andi $t1,$t1,0x0001	#reset all bits except LSB
		beq $t1,$zero,Loop2	#if not ready, loop back
		sb $a0, 12($t0)		#else, write to screen
		jr $ra
		
	Copy:	sb $a0, 0($t2)		#store byte in $t2
		addi $t2, $t2, 1	#increment address by 1 byte
		jr $ra
##################################################################################################			
#if press c
clear:
#print "The array is re-initialized"
		la $a1, str3		#load address into $a1
	print3: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print3	#if not equal to null character, continue to print

#clear arrayinput (set all to 0s)
clearArrayInput:
	la $a0, arrayinput
clearLoop:
	lb $t1, 0($a0)			#load byte into $t1
	beq $t1, '\0', startsort	#if null/ all cleared, go back to quicksort
	add $t0, $0, $0			#set $t0=0
	sb $t0, 0($a0)			#store 0
	addi $a0, $a0, 1		#go to next byte
	j clearLoop	
	
##################################################################################################			
#if press s
sort:	
#print "The sorted array is:"
		la $a1, str2		#load address into $a1
	print2: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print2	#if not equal to null character, continue to print

#clear array 
	la $a0, array
clearArray:
	lw $t0, 0($a0)		#load word
	beq $t0, '\0', fillA	#if empty, fill array
	add $t0, $0, $0	#t0=0
	sw $t0, 0($a0)		#store null
	addi $a0, $a0, 4	#increment array
	j clearArray

#store elements as words into array from arrayinput
	fillA:
		add $t9, $0, $0		#$t9 will hold counter
		la $a0, arrayinput
		la $a1, array
		addi $t2, $0, 0		#accumulator for if 2 digits
		addi $t3, $0, 0		#t3 = 0
		addi $t4, $0, 9		#t4 = 9
	convert: 
		lb $t0, 0($a0)		#load byte
		beq $t0, '\0', sortlist	#if null, go to sortlist
		addi $t0, $t0, -48	#convert to digit 
		blt $t0, $t3, next	#if less than 0, go to next
		bgt $t0, $t4, next	#if greater than 9, go to next
		add $t2, $t2, $t0	#add to accumulator
		addi $a0, $a0, 1	#increment array to next byte
		lb $t0, 0($a0)		#load next byte
		addi $t0, $t0, -48
		blt $t0, $t3, save	#if less than 0, go to save
		bgt $t0, $t4, save	#if greater than 9, go to save
		#else, add 
		mul $t2, $t2, 10	#multiply accumulator by 10
		add $t2, $t2, $t0	#add to accumulator
		move $t0, $t2		#move to $t0
		add $t2, $0, $0 	#reset accumulator
		sw $t0, 0 ($a1)		#store
		addi $a1, $a1, 4	#increment
		addi $a0, $a0, 1
		addi $t9, $t9, 1	#increment counter
		j convert		
	
	next:	
		addi $a0, $a0, 1	#next byte in array
		j convert
		
	save:	
		sw $t2, 0($a1)
		addi $t2, $0, 0		#reset accumulator
		addi $a1, $a1, 4	#increment arrayword by 4
		addi $a0, $a0, 1	#go to next byte in array
		addi $t9, $t9, 1	#increment counter
		j convert

sortlist:   
#save number of elements in array_size
	la $t0, size
	sw $t9, 0($t0)			#save number of elements in array_size

#set array, hi, lo, then call quicksort 			
	la $a0, array			#load address of array (words)
	li $a1, 0			#a1 = 0
	lw $t0, size			#load size
	addi $t0, $t0, -1		#set a2 = size-1 (last index of array)
	move $a2, $t0
	jal quicksort			#go to quick sort   	
	
#convert to ascii
	la $s0, array
	la $s1, arraysorted
	lw $t0, size
	addi $t0, $t0, -1		#size - 1
	lw $s2, 0($s0)			#save first int into t7
	la $t7, first
	addi $t9, $0, 32		#t9 = space
	addi $t8, $0, 10		#t8 = 10

convertFirstInt:
	addi $t1, $0, 0
	addi $t2, $0, 0
	div $s2, $t8  			#divide
	mflo $t1			#quotient
	mfhi $t2			#remainder
	add $t1, $t1, '0'
	add $t2, $t2, '0'		#convert to ascii
	bne $t1, 48, doubleConvertFirst	#if quotient !=0, have 2 digits
	sb $t2, 0($t7)
	sb $t9, 1($t7)	
	j convertInt
	
doubleConvertFirst:
	sb $t1, 0($t7)			#save number
	sb $t2, 1($t7)
	sb $t9, 2($t7)			#save space
	
convertInt:
	addi $t1, $0, 0
	addi $t2, $0, 0
	beq $t0, $zero, printFirst	#when through all elements, go to print
	lw $a0, 4($s0)			#load SECOND word
	div $a0, $t8  			#divide
	mflo $t1			#quotient
	mfhi $t2			#remainder
	add $t1, $t1, '0'
	add $t2, $t2, '0'		#convert to ascii
	bne $t1, 48, doubleConvert	#if quotient !=0, have 2 digits
	sb $t2, 0($s1)
	sb $t9, 1($s1)	
	addi $t0, $t0, -1		#decrement number of elements added
	addi $s0, $s0, 4		#increment array
	addi $s1, $s1, 2		#increment arraysorted
	j convertInt
	
doubleConvert:
	sb $t1, 0($s1)			#save number
	sb $t2, 1($s1)
	sb $t9, 2($s1)			#save space
	addi $t0, $t0, -1		#decrement number of elements added
	addi $s0, $s0, 4		#increment array
	addi $s1, $s1, 3		#increment arraysorted
	j convertInt
	
printFirst:	
	la $a1, first			#load address into $a1
printFirstS: 
	lb $a0, 0($a1)			#load byte into $a0
	lui $t0, 0xffff			#send char to mmio
	sb $a0, 12($t0)			#print char
	addi $a1, $a1, 1		#go to next letter
	lb $a0, 0($a1)			#load next byte
	bne $a0,'\0', printFirstS	#if not equal to null character, continue to print
       		
	
print:	
	la $a1, arraysorted		#load address into $a1
printAS: 
	lb $a0, 0($a1)			#load byte into $a0
	lui $t0, 0xffff			#send char to mmio
	sb $a0, 12($t0)			#print char
	addi $a1, $a1, 1		#go to next letter
	lb $a0, 0($a1)			#load next byte
	bne $a0, '\0', printAS		#if not equal to null character, continue to print
       		
j startsort
##################################################################################################	
#sort list using quicksort	
## quick sort
quicksort:
	addi $sp, $sp, -24		# Adjust sp
	sw $s0, 0($sp)			# store s0
	sw $s1, 4($sp)			# store s1
	sw $s2, 8($sp)			# store s2
	sw $a1, 12($sp)			# store a1
	sw $a2, 16($sp)			# store a2
	sw $ra, 20($sp)			# store ra

# set s (right, left, pivot)
	move	$s0, $a1		# l = left
	move	$s1, $a2		# r = right
	move	$s2, $a1		# p = pivot

# while (l < r), go to quick2
quick1:
	bge $s0, $s1, quick1Done

# while (arr[l] <= arr[p] && l < right)
quick2:
	li $t7, 4			# t7 = 4
	# t0 = &arr[l]
	mult $s0, $t7
	mflo $t0			# t0 =  l * 4bit
	add $t0, $t0, $a0		# t0 = &arr[l]
	lw $t0, 0($t0)
	# t1 = &arr[p]
	mult $s2, $t7
	mflo $t1			# t1 =  p * 4bit
	add $t1, $t1, $a0		# t1 = &arr[p]
	lw $t1, 0($t1)
	# check arr[l] <= arr[p]
	bgt $t0, $t1, quick2Done
	# check l < right
	bge $s0, $a2, quick2Done
	# l++
	addi $s0, $s0, 1
	j quick2
	
quick2Done:

# while (arr[r] >= arr[p] && r > left)
quick3:
	li $t7, 4			# t7 = 4
	# t0 = &arr[r]
	mult $s1, $t7
	mflo $t0			# t0 =  r * 4bit
	add $t0, $t0, $a0		# t0 = &arr[r]
	lw $t0, 0($t0)
	# t1 = &arr[p]
	mult $s2, $t7
	mflo $t1			# t1 =  p * 4bit
	add $t1, $t1, $a0	 	# t1 = &arr[p]
	lw $t1, 0($t1)
	# check arr[r] >= arr[p]
	blt $t0, $t1, quick3Done
	# check r > left
	ble $s1, $a1, quick3Done
	# r--
	addi $s1, $s1, -1
	j quick3
	
quick3Done:
# if (l >= r)
	blt $s0, $s1, quick1Jump
# SWAP (arr[p], arr[r])
	li $t7, 4			# t7 = 4
	# t0 = &arr[p]
	mult $s2, $t7
	mflo $t6			# t6 =  p * 4bit
	add $t0, $t6, $a0		# t0 = &arr[p]
	# t1 = &arr[r]
	mult $s1, $t7
	mflo $t6			# t6 =  r * 4bit
	add $t1, $t6, $a0	# t1 = &arr[r]
	# Swap
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	sw $t2, 0($t1)
	
# quick(arr, left, r - 1)
	# set arguments
	move $a2, $s1
	addi $a2, $a2, -1		# a2 = r - 1
	jal quicksort
	
	# pop stack
	lw $a1, 12($sp)			# load a1
	lw $a2, 16($sp)			# load a2
	lw $ra, 20($sp)			# load ra
	
# quick(arr, r + 1, right)
	# set arguments
	move $a1, $s1
	addi $a1, $a1, 1		# a1 = r + 1
	jal quicksort
	# pop stack
	lw $a1, 12($sp)			# load a1
	lw $a2, 16($sp)			# load a2
	lw $ra, 20($sp)			# load ra
	
# return
	lw $s0, 0($sp)			# load s0
	lw $s1, 4($sp)			# load s1
	lw $s2, 8($sp)			# load s2
	addi $sp, $sp, 24		# adjust sp
	jr $ra

quick1Jump:

# SWAP (arr[l], arr[r])
	li $t7, 4			# t7 = 4
	# t0 = &arr[l]
	mult $s0, $t7
	mflo $t6			# t6 =  l * 4bit
	add $t0, $t6, $a0		# t0 = &arr[l]
	# t1 = &arr[r]
	mult $s1, $t7
	mflo $t6			# t6 =  r * 4bit
	add $t1, $t6, $a0 		# t1 = &arr[r]
	# Swap
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	sw $t2, 0($t1)
	j quick1
	
quick1Done:
# return to stack
	lw $s0, 0($sp)			# load s0
	lw $s1, 4($sp)			# load s1
	lw $s2, 8($sp)			# load s2
	addi $sp, $sp, 24		# adjust sp
	jr $ra

##################################################################################################	
#print "Finished running program" if pressed 'q'
printQuit:
	la $a1, str8		#load address into $a1
print8: lb $a0, 0($a1)		#load byte into $a0
	lui $t0, 0xffff		#send char to mmio
	sb $a0, 12($t0)		#print char
	addi $a1, $a1, 1	#go to next letter
	lb $a0, 0($a1)		#load next byte		
	bne $a0, '\0', print8	#if not equal to null character, continue to print
	li $v0, 10
	syscall				#syscall to exit
##################################################################################################			
