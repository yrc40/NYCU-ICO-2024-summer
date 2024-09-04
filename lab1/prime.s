.data
	input_msg:	.asciiz "Please input a number: "
	output_prime:	.asciiz "It's a prime"
    output_not_prime:   .asciiz "It's not a prime"
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

# jump to procedure prime
	jal 	prime
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_prime on the console interface if the number is prime
    beq     $t0, $zero, N
	li      $v0, 4				# call system call: print string
	la      $a0, output_prime	# load address of string into $a0
	syscall                 	# run the syscall
    j       Exit                # end the program

# print output_not_prime on the console interface if the number is not prime
N:
	li      $v0, 4				    # call system call: print string
	la      $a0, output_not_prime	# load address of string into $a0
	syscall 					    # run the syscall

# print a newline at the end
Exit:
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program	
    li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure prime -----------------------------
# load argument n in $a0, return value in $v0. 
.text
prime:	
	addi 	$sp, $sp, -8		# adiust stack for 2 items
	sw 		$ra, 4($sp)			# save the return address
	sw 		$a0, 0($sp)			# save the argument n
    li      $t0, 1              # let $t0 = 1 to test n == 1 or not
    beq     $a0, $t0, NP        # if n == 1, return 0
    li      $t1, 2              # set i = 2, start to loop

loop:
    mul     $t0, $t1, $t1       # let $t0 = i*i
    slt     $t2, $a0, $t0       # if n < i*i, set $t2 to 1
    bne     $t2, $zero, P       # if n < i*i, return 1
    rem     $t3, $a0, $t1       # calculate n % i
    beq     $t3, $zero, NP      # if n % i == 0, return 0
    addi    $t1, $t1, 1         # i++
    j       loop

P:
    li      $v0, 1              # set result to 1
    j       end

NP:
    li      $v0, 0              # set result to 0

end:
    lw      $a0, 0($sp)          # restore return address
    lw      $ra, 4($sp)          # restore argument n
    addi    $sp, $sp, 8          # deallocate stack space
    jr      $ra                  # return to caller


	