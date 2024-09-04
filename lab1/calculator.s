.data
	input_msg:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
    first_num:  .asciiz "Please enter the first number: "
    sec_num:    .asciiz "Please enter the second number: "
	output_msg:	.asciiz "The calculation result is: "
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
	move    $a1, $v0      		# store input in $a0 (set arugument of procedure calculator)

# ask first number
    li      $v0, 4				# call system call: print string
	la      $a0, first_num		# load address of string into $a1
	syscall                 	# run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a1(set arugument of procedure calculator)

# ask second number 
    li      $v0, 4				# call system call: print string
	la      $a0, sec_num	    # load address of string into $a2
	syscall                 	# run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a2(set arugument of procedure calculator)

# jump to procedure calculator
	jal 	calculator
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

#------------------------- procedure calculator -----------------------------
# load argument n in $a0, return value in $v0. 
.text
calculator:	
	addi 	$sp, $sp, -16		# adiust stack for 4 items
    sw      $ra, 12($sp)        # save the return address
    sw      $a1, 8($sp)         # save the argument op
	sw 		$a2, 4($sp)			# save the argument 1st number
	sw 		$a0, 0($sp)			# save the argument 2nd number
    li      $t0, 2              # op=2
    li      $t1, 3              # op=3
    beq     $a1, $t0, Sub       # if op == 2, sub
    beq     $a1, $t1, Mul       # if op == 3, mul
Add:
    add     $v0, $a2, $a0       #  1 + 2
	j       end  				# end the calculation
Sub:
    sub     $v0, $a2, $a0       # 1 - 2
    j       end                 # end the calculation
Mul:
    mul     $v0, $a2, $a0       # 1 * 2
end:
    lw      $a0, 0($sp)         # restore argument 2nd number
    lw      $a2, 4($sp)         # restore argument ist number
    lw      $a1, 8($sp)         # restore argument op
	lw      $ra, 12($sp)        # restore return address
    addi    $sp, $sp, 16        # deallocate stack space
    jr      $ra                 # return to caller
