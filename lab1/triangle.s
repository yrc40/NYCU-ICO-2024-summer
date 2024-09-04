.data
	input_op:	.asciiz "Please enter option (1: triangle, 2: inverted triangle): "
	input_size:	.asciiz "Please input a triangle size: "
    star:       .asciiz "*"
    space:      .asciiz " "
	newline: 	.asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_op on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_op		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1 (set arugument of option)
    addi    $s1, $a1, -1        # shift op code -1 (0 for triangle, 1 for inverted)

# print input_size on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_size		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a2 (set arugument of size) 

# loop
    li      $s0, -1             # set i = -1
loop:
    addi    $s0, $s0, 1           # i++
    slt     $t0, $s0, $a2         # if i < n, set $t0 to be 1
    beq     $t0, $zero, end       # if i >= n, end the program
    beq     $s1, $zero, triangle  # if op == 0, print triangle
    bne     $s1, $zero, inverted  # if op != 0, print inverted triangle
    
# jump to procedure print triangle
triangle:
    move    $a0, $s0
	jal 	print
    j       loop                   

# jump to procedure print inverted triangle
inverted:
    sub     $a0, $a2, $s0        # n - i
    addi    $a0, $a0, -1         # n - i - 1
    jal     print
    j       loop      

# exit the program
end:
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure print layer -----------------------------
.text
print:	
	addi 	$sp, $sp, -12		# adiust stack for 3 items
    sw      $ra, 8($sp)         # save the return address
	sw 		$a2, 4($sp)			# save the argument n
	sw 		$a0, 0($sp)			# save the argument l
# Calculate spaces
    lw      $t1, 4($sp)         # t1 = n
    lw      $t2, 0($sp)         # t2 = l
    sub     $t3, $t1, $t2       # t3 = n - l
    addi    $t3, $t3, -1        # t3 = n - l - 1 (for spaces)

print_space:
# for j = 1 to n - l - 1, print space 
    beq     $t3, $zero, calculate_stars     # if n - l - 1 == 0, goes to print print_stars
    li		$v0, 4				            # call system call: print string
	la		$a0, space		                # load address of string into $a0
	syscall						            # run the syscall
    addi    $t3, $t3, -1                    # t3--
    j       print_space

calculate_stars:
# for j = n-l to n+l, print print_stars(2*l+1 stars)
    sll     $t4, $t2, 1         # t4 = 2 * l
    addi    $t4, $t4, 1         # t4 = 2 * l + 1

print_stars:
    beq     $t4, $zero, print_line
    li		$v0, 4				            # call system call: print string
	la		$a0, star		                # load address of string into $a0
	syscall						            # run the syscall
    addi    $t4, $t4, -1                    # t4--
    j       print_stars

print_line:
    li      $v0, 4
    la      $a0, newline
    syscall
    lw      $a0, 0($sp)         # restore argument l
    lw      $a2, 4($sp)         # restore argument n
    lw      $ra, 8($sp)         # restore return address
    addi    $sp, $sp, 12        # adjust stack back
    jr      $ra                 # return
