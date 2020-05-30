#studentName: Anne-Sophie Fratzscher
#studentID: 260705446

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 
	str1: .asciiz "Word Count"
	str2: .asciiz "\nEnter the text segment:\n\t"
	str3: .asciiz "\nEnter the search word:\n\t"
	str4: .asciiz "\nThe word '"
	str5: .asciiz "' occured "
	str6: .asciiz " time(s)\n"
	str7: .asciiz "Press 'e' to enter another segment of text or 'q' to quit\n"
	str8: .asciiz "Finished running word count program"
	sentence: .space 600 		#space for 600 bytes/ 600 chars for sentence
	wordGiven: .space 600		#space for word
	counter: .space 3		#space for counter (b/c max 600 chars = 3 digits)
	
	.text
	.globl main

main:	# all subroutines you create must come below "main"
########################################################################################################
#print"Word count"
		la $a1, str1		#load address into $a1
	print1: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print1	#if not equal to null character, continue to print
##################################################################################################
#print "Enter the text segment: \n"
	print2Start:
		la $a1, str2		#load address into $a1
	print2: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print2	#if not equal to null character, continue to print	
	
#get sentence from MMIO, print to screen until "Enter" pressed, and save to "sentence"
	la $t2, sentence
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
		beq $v0, 10, print3Start#if key pressed is "Enter", go to print3Start
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
#print "Enter the search word: \n"
	print3Start:
		la $a1, str3		#load address into $a1
	print3: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print3	#if not equal to null character, continue to print	
	
#get sentence from MMIO, print to screen until "Enter" pressed, and save to "sentence"
	la $t2, wordGiven
	echo2:	jal Read2		# reading and writing using MMIO
		add $a0,$v0,$zero	# in an infinite loop until press "Enter"
		jal Write2	
		add $a0, $v0, $zero
		jal Copy2		#copy input to sentence
		j echo2

	Read2: 	lui $t0, 0xffff 	#ffff0000
	Loop12:	lb $t1, 0($t0) 		#load from input control register
		andi $t1,$t1,0x0001	#reset all bits except LSB
		beq $t1,$zero,Loop12	#if not ready, loop back
		lb $v0, 4($t0) 		#read
		beq $v0, 10, wordsearch #if key pressed is "Enter", go to wordsearch
		jr $ra

	Write2:  lui $t0, 0xffff 	#ffff0000
	Loop22: lb $t1, 8($t0) 		#load output control register
		andi $t1,$t1,0x0001	#reset all bits except LSB
		beq $t1,$zero,Loop22	#if not ready, loop back
		sb $a0, 12($t0)		#else, write to screen
		jr $ra
		
	Copy2:	sb $a0, 0($t2)		#store byte in $t2
		addi $t2, $t2, 1	#increment address by 1 byte
		jr $ra
		
########################################################################################################
#check for number of counts of word
wordsearch:
	la $t0, sentence		#load address of sentence
	la $t1, wordGiven		#load address of wordGiven
	addi $t4, $0, 0			#set t4 to 0
	
#compare letters until reach space OR null
	check:
		lb $t2, 0($t0)		#load byte of sentence
		lb $t3, 0($t1)		#load byte of word
		bne $t2, $t3, inc	#if not equal, go to start of next word
		beq $t2, '\0', lastcheck#if last character of sentence, go to count
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j check			#if equal, go to next letter of word and sentence
	
	inc:	bne $t2, 32, nextWord	#if not end of word in sentence (space), go to nextWord
		#if is space
		beq $t2, '\0', count
		beq $t3, '\0', addcount	#if last letter of wordGiven, add to counter
		#if not last letter of word
		la $t1, wordGiven	#reset to beginning of word
		j nextWord
		
	#loop sentence until start of next word
	nextWord: 
		lb $t2, 0($t0)
		beq $t2, 32, quick	#if space, go to quick
		beq $t2, '\0', count	#if end, go to count
		addi $t0, $t0, 1	#next letter
		la $t1, wordGiven	#go to start of wordGiven
		j nextWord		#repeat until reach space
	
	quick:	addi $t0, $t0, 1	#if space, go to next character and go back to check
		j check	
	
	addcount:  
		addi $t4, $t4, 1	#increment counter
		la $t1, wordGiven	#go to first letter of word
		addi $t0, $t0, 1
		j check		#go to nextWord
	
	lastcheck:
		bne $t3, '\0', count	#if NOT last letter of word, go to count
		#if is last letter of word and sentence, add to counter and then go to count
		addi $t4, $t4, 1
		j count
		
	#put counts (in $a0) into counter
	count: 	la $a0, counter
		addi $t5, $0, 10	#set $t5=10
		div $t4, $t4, 10	#divide by 10 
		mfhi $t6		#lowest digit (mod) in t6
		div $t4, $t4, 10	
		mfhi $t7		#second digit in t7
		div $t4, $t4, 10	
		mfhi $t8		#highest digit in t8
		addi $t6, $t6, 48	#to ascii
		addi $t7, $t7, 48
		addi $t8, $t8, 48
		beq $t8, 48, put2
		sb $t8, 0($a0)		#store first digit
		sb $t7, 1($a0)		#store second digit
		sb $t6, 2($a0)		#store last digit
		j removeSentence
	put2:	beq $t7, 48, put1	#if second digit also 0, go to put1
		sb $t6, 1($a0)		#store last digit
		sb $t7, 0($a0)		#store second digit
		j removeSentence
	put1:	sb $t6, 0($a0)		#store last digit
		j removeSentence

##################################################################################################
#clear buffer for sentence
removeSentence:
	la $a0, sentence
removeSentLoop:
	lb $t1, 0($a0)			#load byte into $t1
	beq $t1, '\0', print4Start	#if null, go to print
	add $t0, $0, $0			#set $t0=0
	sb $t0, 0($a0)			#store 0
	addi $a0, $a0, 1		#go to next byte		
	j removeSentLoop
												
##################################################################################################																																				
#print "\nThe word '"
	print4Start:
		la $a1, str4		#load address into $a1
	print4: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print4	#if not equal to null character, continue to print

#print "wordGiven' (inputed from user) 
	printWord:
		la $a1, wordGiven		#load address into $a1
	printW: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', printW	#if not equal to null character, continue to print
	
#print "' occured '"
	print5Start:
		la $a1, str5		#load address into $a1
	print5: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print5	#if not equal to null character, continue to print
#print counter
		la $a1, counter		#load address into $a1
	printC: lb $a0, 0($a1)		#load word into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb  $a0, 0($a1)		#load next word
		bne $a0, '\0', printC
	
#print "' time(s) '"
	print6Start:
		la $a1, str6		#load address into $a1
	print6: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print6	#if not equal to null character, continue to print
##################################################################################################			
#print "press 'e' to enter another segment of text or 'q' to quit\n"
	la $a1, str7		#load address into $a1
	print7: lb $a0, 0($a1)		#load byte into $a0
		lui $t0, 0xffff		#send char to mmio
		sb $a0, 12($t0)		#print char
		addi $a1, $a1, 1	#go to next letter
		lb $a0, 0($a1)		#load next byte
		bne $a0, '\0', print7	#if not equal to null character, continue to print	
#print to screen asking for next choice
	echo3:  jal Read3		# reading and writing using MMIO
		add $a0,$v0,$zero	# in an infinite loop until press "Enter"
		j echo3

	Read3:  lui $t0, 0xffff 	#ffff0000
	Loop5:	lb $t1, 0($t0) 		#load from input control register
		andi $t1,$t1,0x0001	#reset all bits except LSB
		beq $t1,$zero,Loop5	#if not ready, loop back
		lb $v0, 4($t0) 		#read
		beq $v0, 113, print8Start #if pressed 'q', quit
		beq $v0, 101, removeWord #if press 'e', clear buffer for word, then enter new word
		jr $ra
		
#clear buffer for word
removeWord:
	la $a0, wordGiven
removeLoop:
	lb $t1, 0($a0)			#load byte into $t1
	beq $t1, '\0', removeCount	#if null, go to enter new word
	add $t0, $0, $0			#set $t0=0
	sb $t0, 0($a0)			#store 0
	addi $a0, $a0, 1		#go to next byte	
	j removeLoop

#clear counter 
removeCount:
	la $a0, counter
removeCountLoop:
	lb $t1, 0($a0)			#load byte into $t1
	beq $t1, '\0', print2Start	#if null, go to enter new word
	add $t0, $0, $0			#set $t0=0
	sb $t0, 0($a0)			#store 0
	addi $a0, $a0, 1		#go to next byte	
	j removeCountLoop
		
#print "Finished running program" if pressed 'q'
	print8Start:
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
