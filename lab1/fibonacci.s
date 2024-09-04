.data
	input_msg:	.asciiz "Please input a number: "
	output_msg:	.asciiz "The result of fibonacci(n) is "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure factorial)

# jump to procedure factorial
	jal 	fibonacci
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t0			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure fibonacci -----------------------------
# load argument n in $a0, return value in $v0. 
.text
fibonacci:	
	addi 	$sp, $sp, -12		# adiust stack for 2 items
	sw 		$ra, 8($sp)			# save the return address
	sw 		$a0, 4($sp)			# save the argument n
    sw      $s0, 0($sp)         # save $s0
    li      $t1, 1              # set t1 = 1
    beq     $a0, $zero, zero    # if n == 0, return 0
    beq     $a0, $t1, one       # if n == 1, return 1
    addi    $a0, $a0, -1        # n - 1
    jal     fibonacci           # calculate fibonacci(n-1)
    move    $s0, $v0            # t3 = fibonacci(n-1)
    lw      $a0, 4($sp)         # get n
    addi    $a0, $a0, -2        # n - 2
    jal     fibonacci           # calculate fibonacci(n-2)
    add     $v0, $v0, $s0       # v0 = fibonacci(n-2) + fibonacci(n-1)
    j       end

zero:
    add     $v0, $zero, $zero   # return 0
    j       end                 # jump to end of function

one:
    li      $v0, 1

end:		
	lw 		$s0, 0($sp)			# return from jal, restore argument n
	lw 		$a0, 4($sp)			# restore the return address
    lw      $ra, 8($sp)
	addi 	$sp, $sp, 12	    # adjust stack pointer to pop 2 items
	jr 		$ra					# return to the caller