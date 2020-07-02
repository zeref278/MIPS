#STRINGS
.data
fileNameInput: .asciiz "input_sort.txt"
fileNameOutput: .asciiz "testout.txt"
fileWords: .space 1024
characterSpace: .asciiz " "

array:  .word 0:1000
strNl: .asciiz "\t"
number: .word 8

.text
	.globl main
	
main:


	#Open file to read
	
	li $v0,13        
    	la $a0,fileNameInput
    	li $a1,0
    	syscall
    	move $s0,$v0        	# save the file descriptor. $s0 = file
	
	#Read file
	li $v0, 14
	move $a0,$s0
	la $a1,fileWords
	la $a2,1024
	syscall

	#Convert char* to int array
	jal Parse

	#Close file
    	li $v0, 16         		
    	move $a0,$s0      		
    	syscall


    	
	la $t0, array # Moves the address of array into register $t0.
	addi $a0, $t0, 0 #the array.
	addi $a1, $0, 0 #(low = 0)
	addi $a2, $t8, -1 #(last index in array)

	addi $sp,$sp,-4
	sw $t8,0($sp) 

	li $t1,0
	li $t2,0
	li $t3,0
	li $t4,0
	li $t5,0
	li $t6,0
	li $t7,0


	jal QuickSort
	jal WriteToFile


	#Exit
	li $v0, 10
	syscall

###
Swap:

	addi $sp, $sp, -8	# Init stack

	sw $ra,0($sp)		# store $ra
	sw $t2,4($sp)

	sll $t1, $a1, 2 	#t1 = 4a
	add $t1, $a0, $t1	#t1 = array + 4a (address)
	lw $s3, 0($t1)		#s3 = array[a]

	sll $t2, $a2, 2		#t2 = 4b
	add $t2, $a0, $t2	#t2 = arr + 4b (address)
	lw $s4, 0($t2)		#s4 = arr[b]

	sw $s4, 0($t1)		#swap
	sw $s3, 0($t2)

 	lw $ra, 0($sp)
	lw $t2,4($sp)

 	addi $sp, $sp, 8	#restore the stack

 	jr $ra
	


Partition:

	addi $sp, $sp, -16	#Init stack

	sw $a0, 0($sp)		#store a0
	sw $a1, 4($sp)		#store a1
	sw $a2, 8($sp)		#store a2
	sw $ra, 12($sp)		#store return address
	
	move $s1, $a1		#s1 = low
	move $s2, $a2		#s2 = high

	sll $t1, $s2, 2		# t1 = 4*high
	add $t1, $a0, $t1	# t1 = arr + 4*high
	lw $t2, 0($t1)		# t2 = arr[high] //pivot

	addi $t3, $s1, -1 	#t3, i=low -1
	move $t4, $s1		#t4, j=low
	addi $t5, $s2, -1	#t5 = high - 1

	forloop: 
		slt $t6, $t5, $t4	#t6=1 if j>high-1, t6=0 if j<=high-1
		bne $t6, $0, endfor	#if t6=1 then branch to endfor

		sll $t1, $t4, 2		#t1 = j*4
		add $t1, $t1, $a0	#t1 = arr + 4j
		lw $t7, 0($t1)		#t7 = arr[j]

		slt $t8, $t2, $t7	#t8 = 1 if pivot < arr[j], t8=0 if arr[j]<=pivot
		bne $t8, $0, endfif	#if t8=1 then branch to endfif
		addi $t3, $t3, 1	#i=i+1

		move $a1, $t3		#a1 = i
		move $a2, $t4		#a2 = j
		jal Swap		#Swap(arr, i, j)
		
		addi $t4, $t4, 1	#j++

		j forloop

	    endfif:
		addi $t4, $t4, 1	#j++
		j forloop		#junp back to forloop

	endfor:
		addi $a1, $t3, 1		#a1 = i+1
		move $a2, $s2			#a2 = high
				
		jal Swap			#Swap arr[i+1] arr[high]
		lw $a0, 0($sp)		
		lw $a2, 8($sp)
		lw $ra, 12($sp)
		addi $sp, $sp, 16

		addi $v0, $t3, 1		#return i+1

		jr $ra

QuickSort:

	addi $sp, $sp, -16

	sw $a0, 0($sp)			# a0
	sw $a1, 4($sp)			# low
	sw $a2, 8($sp)			# high
	sw $ra, 12($sp)			# return address

	move $t0, $a2			#saving high in t0

	slt $t1, $a1, $t0		# t1=1 if low < high, else 0
	beq $t1, $0, endif		# if low >= high, endif

	jal Partition			# call Partition 
	move $s0, $v0			# index pivot

	lw $a1, 4($sp)			#a1 = low
	addi $a2, $s0, -1		#a2 = ip -1
	jal QuickSort

	addi $a1, $s0, 1		#a1 = ip + 1
	lw $a2, 8($sp)			#a2 = high
	jal QuickSort

 endif:

 	lw $a0, 0($sp)
 	lw $a1, 4($sp)
 	lw $a2, 8($sp)
 	lw $ra, 12($sp)
 	addi $sp, $sp, 16
 	jr $ra
PrintArray:
	li $t9, 0
	lw $t8,0($sp)
	addi $sp,$sp,4
	sll $t8,$t8,2
	Loop1:

		beq $t9,$t8,ExitLoop1
		
		lw $t2, array($t9)

		
		add $v0,$0,1
		add $a0,$0,$t2
		syscall
		addi $v0, $0, 4
		la $a0, strNl
		syscall
		
		addi $t9,$t9,4
		
		j Loop1
	ExitLoop1:
		jr $ra

#######
Parse:
   	or $v0, $0, $0   # num = 0
.num:
    
	lb      $t0, 0($a1)
	slti    $t2, $t0, 58        # *str <= '9'
	slti    $t3, $t0, '0'       # *str < '0'
	beq     $t0,13, .numCount
	beq     $t0,10, .next
	beq     $t0, 32, .nextChar
	beq     $t2, $0, .out
	bne     $t3, $0, .out
	sll     $t2, $v0, 1
	sll     $v0, $v0, 3
	add     $v0, $v0, $t2       # num *= 10, using: num = (num << 3) + (num << 1)
	addi    $t0, $t0, -48
	add     $v0, $v0, $t0       # num += (*str - '0')
	addi    $a1, $a1, 1         # ++num
    
	j   .num

.next:
	addi    $a1, $a1, 1
	add $v0, $0,0

	j .num
.numCount:
	add $t8,$0,$v0 #so phan tu
	addi    $a1, $a1, 1
	add $v0, $0,0
	j .num
.nextChar:
	add $t7, $0, $v0
	sw $t7, array($s1)
	addi $s1, $s1, 4
	addi    $a1, $a1, 1
	add $v0, $0,0
	j .num
.out:
	add $t7, $0, $v0

	sw $t7, array($s1)
	addi $s1, $s1, 4
	jr $ra 

####
GetLength:
	li $t1,10
	li $t3,0 #kq

	beq $a1,0,.endif
	whileLoop:
		#$a1=intterger
		beqz $a1,endLoop
		addi $t3,$t3,1
		div $a1,$t1
		mflo $a1

		j whileLoop
	endLoop:
		move $v0,$t3
		jr $ra

	.endif:
		li $t3,1
		j endLoop

Convert:
	li $t1,10
	add $a3,$a3,$a2

	addi $sp,$sp,-4
	sw $ra,0($sp)

	beq $a1,0,.endif1
	whileLoop1:
		#$a1=intterger
		#$a0=address
		#$a2=so luong phan tu-1
		beqz $a1,endLoop1
		
		div $a1,$t1
		mflo $a1
		mfhi $t2 #so du
		addi $t2,$t2,48 #chuyen ve ascii
		sb $t2,0($a3)
		addi $a3,$a3,-1
		j whileLoop1
	endLoop1:
		addi $a3,$a3,1
		lw $ra,0($sp)
		addi $sp,$sp,4
		jr $ra

		.endif1:
			li $t2,48
			sb $t2,0($a3)
			lw $ra,0($sp)
		addi $sp,$sp,4
		jr $ra
			
WriteToFile:
	#Open file to write
	li $v0,13        
    	la $a0,fileNameOutput
    	li $a1,1
    	syscall
    	move $s0,$v0

	li $t9, 0
	lw $t8,0($sp)
	addi $sp,$sp,4
	sll $t8,$t8,2

	addi $t0,$t8,-4

	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	Loop2:

		beq $t9,$t8,ExitLoop2
		
		lw $t2, array($t9)
		move $a1,$t2 #a1
		
		jal GetLength
		move $t3,$v0 #so phan tu
		
		li $v0,9
		move $a0,$t3
		syscall

		move $a3,$v0 #$a0 buffer
		addi $a2,$t3,-1
		move $a1,$t2
		
		jal Convert

		li $v0,15
		move $a0,$s0
		move $a1,$a3
		move $a2,$t3
		syscall
		
		beq $t9,$t0,EndIf

		li $v0,15
		move $a0,$s0
		la $a1,characterSpace
		li $a2, 1
		syscall

		addi $t9,$t9,4
		
		j Loop2

		EndIf: #last element
			addi $t9,$t9,4
		
			j Loop2
	ExitLoop2:		
		li $v0, 16         		#close file
    		syscall

		lw $ra,0($sp)
		addi $sp,$sp,4
		jr $ra
