##########  Data segment  ######################################################

.data
    x:                 .space     4        # create 4 bytes 
    com_sym:      .space     4        # create 4 bytes of memory to store the symbol for complex
    com_trig:       .space     4        # create 4 bytes of memory to detect if complex is triggered
    roots_of_x:     .space     8        # create 8 bytes, one for each part of the root
    array:           .space    12       # create 12 bytes, uninitialized for 3 floats
    disp_arr:        .space    12       # create 12 bytes used for storing {b^2-4ac}, {-b},  {2a}, in order 
	
    is_a_two:       .float       2.0       # used for the denominator of quadratic function
    is_a_four:      .float       4.0       # used for the discriminant
    is_a_one:       .float       1.0       # used as a guess for newtons algorithm
    is_a_zero:      .float       0.0       # used to load register for branching if less than zero	
    variance:      .float       0.0001  # used to compare variance with newtons algorithm for looping
	
	
    func:            .asciiz   "\n\tf(x) = a*x^2 + b*x + c \n\n"
    func_solved1: .asciiz   "\n\tf(x) = "
    func_solved2: .asciiz   "*x^2 + "
    func_solved3: .asciiz   "*x + "
    func_solved4: .asciiz   " = "
	
    prompt1:       .asciiz   "\tEnter coefficient [ ] :  "	
    promptx:       .asciiz   "\tEnter input value [x] :  "

    roots:           .asciiz   "\n\tThe Roots of the polynomial are : "
    prompt_root:  .asciiz   "\tx = "	
	
    root_ex_bot:    .asciiz   " \n\t    ¯¯¯¯¯¯¯¯¯¯¯¯¯" 		# UTF-8 macron character
    root_ex_bot2:  .asciiz   "\n\t\t"	
	

################################################################################
# Macro Name:    root
# Description:   This macro is used to display the roots of the polynomial called
#		by print_roots
################################################################################

    .macro    root    (%x , %y,  %z, %sol, %operator)

    #  references . . . 
    #  x is -b
    #  y is b^2 - 4ac
    #  z is 2 * a
    #  sol is solution
    #  operator would be for + or a -
			
	li		$v0,    11                           # system code for character from int at location $a0
        la		$a0,    '\n'                          # load a newline
            syscall                                    # print the newline

        la 		$s1,    roots_of_x                 # load the parts of roots of x from memory
        la		$s5,    com_sym                  # load the symbol for complex roots
        la		$s6,    com_trig                  # load the trigger for complex roots
	
        li 		$v0,    4                          # system code for printing null terminated string at location $a0
        la		$a0,    prompt_root           # load x = into $a0
            syscall                                   # print the message
					
        li		$v0,    2                         # system code for printing float at $f12
        mov.s		$f12,   %x                       # move -b to $f12 for printing
            syscall                                  # print -b
				
        li		$v0,	11			# system code for printing character at $a0
        la		$a0,	' '			# load a space
            syscall					# print the space
        la		$a0,	(%operator)		# load the ascii symbol for + or - 
            syscall					# print + or -
        la		$a0,	' '			# load a space
            syscall					# print the space
				
        la		$a0,	'('			# load a ( into  $a0 for printing
            syscall					# print the (
						
							
        li		$v0,	2			# system code for printing float at $f12
        mov.s		$f12,	%y			# move b^2-4ac to $f12 for printing
            syscall					# print b^2-4ac
				
        li		$v0,	11			# system code for character from int at location $a0
        la		$a0,	')'			# load a ) into  $a0 for printing
            syscall					# print the )
				
        la		$a0,	'½'			# load the 1/2 power for square roots
            syscall					# print the 1/2 power
        la		$a0,	' '			# load a space
            syscall					# print the space
				
        li		$v0,	11			# system code for character from int at location $a0
        lb		$a0,	0 ($s5)			# load the complex ( or space )symbol for printing	
            syscall					# print the symbol
				
				
        la		$a0,	' '			# load a space
            syscall					# print the space
        la		$a0,	'='			# load an equal sign
            syscall					# print the equal sign
        la		$a0,	' '			# load a space
            syscall					# print the space
				
        lb		$t2,	($s6)
        beq		$t2,	0,	root_real
        beq		$t2,	1,	root_complex

################################################################################
# Function Name:	root_real
# Description:		This function is used to display the root if they are  
#			real roots
################################################################################
				
    root_real:
																											
        li		$v0,	2			# system code for printing float at $f12
        mov.s		$f12,	%sol			# move the solution to $f12
            syscall					# print print the solution		
        
        j skip
 
################################################################################
# Function Name:	root_complex
# Description:		This function is used to print the roots if they are 
#			complex because real and complex numbers need to be 
#			separate from the real
################################################################################
  
    root_complex:
										
        l.s		$f1,	  ($s1)		# get the first part of the root
        l.s		$f2,	4 ($s1)		# get the second part of the root
				
        li		$v0,	2			# system code for printing float at $f12
        mov.s		$f12, $f2			# move the first part to $f12 for printing
            syscall				# print  part 1
				
        li		$v0,	11			# system code for printing character at $a0
        la		$a0,	' '			# load a space
            syscall					# print the space
        la		$a0,	(%operator)		# load the ascii symbol for + or - 
            syscall				# print + or -
        la		$a0,	' '			# load a space
            syscall					# print the space
					
				
        li		$v0,	2			# system code for printing float at $f12
        mov.s		$f12, $f1			# move the second part to $f12 for printing
            syscall				# print  part two
################################################################################
# Function Name:	skip
# Description:		This function is used to skip over complex roots when
#			the roots are solely real
################################################################################		
    skip:	
        li		$v0,	11			# system code for character from int at location $a0
        la		$a0,	' '			# load a space
            syscall					# print the space

        lb		$a0,	0 ($s5)			# load the complex ( or space )symbol for printing		
            syscall					# print the symbol
				
        li		$v0,	4			# system code for printing null terminated string at location $a0
        la		$a0,	root_ex_bot		# load the message for exact roots bottom
            syscall					# print the stuff
				
				
        li		$v0,	4			# system code for printing null terminated string at location $a0
        la		$a0,	root_ex_bot2		# load the message for exact roots bottom
            syscall					# print the stuff
			
        li		$v0,	2			# system code for printing float at $f12
        mov.s		$f12,	%z			# move 2 * a to $f12
            syscall					# print 2 * a
						

    .end_macro
	

	
##########  Code segment  ######################################################

.text

	.globl main
	
################################################################################
# Function Name:          Main
# Description:               Works as the main caller for the other functions
################################################################################

main:                  # Program entry point
		
	
	jal		get_input			# read into the array the polynomial
				
	jal		compute_f_of_x			# compute f evaluted at x
	jal		display_f_of_x			# display f evaluted at x
				
	jal		quadratic_formula		# evalute the roots of the polynomial
	jal		print_roots			# display the roots of the polynomial
			
	
	j 		Exit				# exit the program
			
################################################################################
# Function Name:		Exit
# Description:		This function is used to exit the program and return 
#				control to the system
################################################################################
		
Exit:
	li 		$v0, 10				# system code for exiting the program'
		syscall					# and returing control back to the system
	
	
################################################################################
# Function Name:		get_input
# Description:		This function get's the coef and calls the sub-procedure 
#					get_x for getting x value			
################################################################################

get_input:
		
	li 		$v0, 4				# system code for printing null terminated string at position $a0
	la		$a0, func			# load the string func into the $a0 register
		syscall
					
	la		$s0, 	array			# initialize address parameter
	li		$s1, 	3			# set the length of the array
	li 		$t1, 	1			# initialized the loop counter		
									
loop1:
	bgt		$t1, $s1, 	get_x		# If ($t1 > $s1) branch to get_x

	li		$v0, 	4			# system code for printing null terminated string at position $a0
	la 		$a0, prompt1			# load the prompt into address $a0
				
	add		$t2, $t1, 96	        	# Calculate ASCII value a, $t1 contains value of 1 for looping
				
	sb		$t2, 20 ($a0)			# store byte in prompt1[20], the message is a string and it inserts the $t2 value into it
		syscall					# print the prompt1 message
	
						
	li		$v0,	6			# system code for reading floats to location $f0
		syscall					# get the float
					
	s.s		$f0,	($s0)			# store float to array
				
	addi		$s0, $s0, 4			# increment array pointer to next word
	addi		$t1, $t1, 1			# increment loop counter
			
	j		loop1				# jump to loop1
			
################################################################################
# Function Name:		get_x
# Description:		this sub_procedure is called by get_input for getting x value
################################################################################			
			
get_x:		
	la		$s2, 	x 			# initialize x for storage
				
	li		$v0, 	4			# system code for printing null terminated string at position $a0
	la 		$a0, promptx			# load the prompt into address $a0
		syscall					# print the prompt x message
						
	li		$v0,	6			# system code for reading floats at location $f0	
		syscall

	s.s		$f0, 0 ($s2)			# store the inpuit for x in the register that was initialized with x, $s2
				
	jr		$ra				#return to main
		
################################################################################
# Function Name:		computer_f_of_x
# Description:		solves the polynomial given an x value
################################################################################
	
compute_f_of_x:
	move		$a3, $ra			# move the return address for temporary storage to $a3
					
	la		$s0, 	array			# Initialize address parameter
	li		$s1,	3			# set length of array
				
	la		$s2, 	x			# Initialize address parameter for x
loop2:
			
	blez		$s1,	ret			# If (s1 <= 0) branch to return
				
	addi		$s1,	$s1,	-1		# decrement loop counter
				
				
	l.s		$f1,	($s0)			# get value from array and store it into $f1
	l.s		$f3, 	($s2)			# get the value of x and store it into $f3

	addi		$s0,	$s0,	4		# Increment array pointer to next number
				
	beq		$s1, 2, x_squared		# sub-procedure for squaring x

	beq		$s1, 1, times_x			# sub-procedure for doing (b * x) 

	add.s		$f6, 	$f5, 	$f7		# add $f5 and $f7
				
	add.s		$f6,	$f1, 	$f6		# add $f1 and $f6
				
			
	j		loop2				# jump to loop2 label

################################################################################
# Function Name:		x_squared:
# Description:		sub_procedure to compute_f_of_x for squaring x
################################################################################
												
x_squared:
			
	mul.s		$f6, $f3, $f3			# x ^ 2 and store into $f6
				
	mul.s		$f6, $f1, $f6			# a times x ^ 2
					
	mov.s		$f5, $f6			# store the result in $f5 for later use
		
	j		loop2				# return back to loop2

################################################################################
# Function Name:		times_x
# Description:		sub_procedure to compute_f_of_x for mutliplying by x
################################################################################				
						
times_x:
				
	mul.s 		$f6, $f1, $f3			# multiply b times x
	mov.s		$f7, $f6			# store the value of (b * x ) in $f7
			
	j		loop2				# return back to loop2	

################################################################################
# Function Name:		ret
# Description:		returns back to main
################################################################################		
						
ret:
	
	move		$ra, $a3			# move the return address back for returning to main
	jr		$ra
		
################################################################################
# Function Name:		display_f_of_x
# Description:		displays the polynomial and result evaluted at x
################################################################################	
																										
display_f_of_x:


	la		$s0, 	array			# Initialize address parameter
	li		$s1,	3			# set length of array
				
	li		$v0, 4				# system code for printing null terminated string at position $a0
	la 		$a0,	func_solved1		# load the first part of the message into the $a0 register
		syscall					# print the message
				
	l.s		$f12,	($s0)			# get the first value from the array
	li		$v0, 	2			# system code 2 for printing float at position $f12
		syscall					# print a value
					
					
	addi		$s0, $s0, 4			# increment to the next value in the array
				
				
	li		$v0, 4				# system code for printing null terminated string at position $a0
	la 		$a0,	func_solved2		# load the second part of the message into the $a0 register
		syscall					# print the message
					
	l.s		$f12,	($s0)			# get the first value from the array
	li		$v0, 	2			# system code 2 for printing float at position $f12
		syscall					# print b value
						
					
	addi		$s0, $s0, 4			# increment to the next value in the array
				
				
	li		$v0, 4				# system code for printing null terminated string at position $a0
	la 		$a0,	func_solved3		# load the third part of the message into the $a0 register
		syscall					# print the message
					
	l.s		$f12,	($s0)			# get the first value from the array
	li		$v0, 	2			# system code 2 for printing float at position $f12
		syscall					# print c value																																	
																																												
	li		$v0, 4				# system code for printing null terminated string at position $a0
	la 		$a0,	func_solved4		# load the fourth part of the message into the $a0 register
		syscall					# print the message
					
	mov.s 	$f12, 	$f6				# load the value of solving for x into f12
				
	li		$v0, 	2			# system code for printing floats at position $f12
		syscall					# print the value
					
					
	li		$v0,	11			# system code for printing characters from $a0
	la		$a0,	'\n'			# load a newline into $a0 for printing
		syscall					# print a newline
					
	jr		$ra				# return back to main

################################################################################
# Function Name:		quadratic_formula
# Description:		solves f(x) = 0 with complex roots
################################################################################				
												
quadratic_formula:
	#References:
	#  a = $f3
	#  b = $f5
	#  c = $f7
 	#  $s5 storage for complex symbol if needed
				
				
	la		$s0, 	array			# initialize address parameter
	la		$s1, 	roots_of_x		# initialize the address for the roots
	la		$s2,	disp_arr		# initialize the address for the stuff specified in .data
	la		$s5, 	com_sym			# initialize address parameter for complex symbol
				
	la		$s6,	com_trig		# load the value for complex trigger
	li		$t3,	0			# load the value zero into $t3
	sb		$t3,	($s6)			# zero for no complex yet
		
	li		$t2,	' '
	sb		$t2,	($s5)			# load a space into $s5
				
	l.s		$f3,	0 ($s0)			# store the value of a into $f3
				
			
	l.s		$f5,	4 ($s0)			# store the value of b into $f5
						

		
	l.s		$f7,	8 ($s0)			# store the value of c into $f7
					
	
	mul.s		$f6,	$f5,	$f5		# b ^ 2 stored in $f6	
				
	mov.s		$f9,	$f6			# temporary storage for the value of b^2
				
			
			
	mul.s		$f6,	$f3,	$f7		# $f6 now contains the value of a * c
				
	
	mtc1		$zero, $f4			# load the value of zero into $f4
				
	l.s		$f4, is_a_four			# load the value 4.0 into $f4 for multiplication
				
	mul.s		$f6,	$f6,	$f4		# compute 4*a*c	and stores it into $f6
	
	sub.s		$f6, $f9, $f6			# compute b^2-4ac and store into $f6
				
				
	l.s		$f9, 	is_a_zero		# load a floating point zero into $f9
				
			
	c.le.s		$f6,	$f9			# if ( b^2-4ac < 0.0 ) is complex
	
																
	bc1t		complex				# branch to Complex procedure

					
################################################################################
# Function Name:	continue
# Description:		This function is used to continue after complex has been 
#			triggered -- sub-procedure to quadratic_formula
################################################################################					

continue:# continue back on calculating quadratic after negation ( for complex )
	
	s.s		$f6,	0 ($s2)			# store b^2-4ac	into first section of disp_arr
				
	mov.s		$f8,	$f6			# load $f6 into $f8 for square root	

	l.s		$f0 is_a_one			# starts our pivot (guess) for newtons algorithm, just at one
loop3:
			## location $f0 is our guess, 

			
	mul.s		$f6,	$f0,	$f0		# multiply the guess by itself and store into $f6
			
			
	sub.s		$f6, 	$f6, 	$f8		# $f6 now contains the result of x^2 - S Where S is starting value
			
			
	mov.s 	$f10 , $f6				# $f10 is new location for x^2 - S
				
				
	l.s 		$f2, is_a_two			#load the 2.0 for f prime
		
		
	mul.s		$f6,	$f2,	$f0		#$f6 contains the result of f prime
		
			
	div.s		$f6,	$f10,	$f6		# $f6 is the location of f(x)/fprime 
				
			
	sub.s		$f6,	$f0,	$f6		# $f6 contains the result of the algorithm
			

	mov.s 	$f0, $f6 				#Result of the aglorithm becomes the new guess
				
				
	mul.s		$f9,	$f6,	$f6		# mulitply the result by itself
	sub.s		$f9,	$f8,	$f9		# subtract the result squared from the number ( S ) 
	abs.s		$f9,	$f9			# whether negative or not, makes positive
	
				

	l.s		$f11, variance			# load the variance into $f11 for testing
				
	c.le.s		$f9,	$f11			# if the abs( $f9 ) is less than variance, set true
		
	bc1f		loop3	
										
	mov.s		$f9,	$f6			# load the result of the ?b^2-4ac in $f9 for temp storage
				
				
	l.s		$f2,	is_a_two  		# load a floating value for 2 into $f2
	

	mul.s		$f6,	$f2,	$f3		# result of 2 * a stored in $f6
				
	mov.s		$f11,	$f6			# temporary storage for 2 * a in $f11
			
			
				
	div.s		$f6,	$f9,	$f11		# ?b^2-4ac / (2 * a) stored in  $f6	
				
				
	mov.s		$f9,	$f6			# temporary storage for ?b^2-4ac / (2 * a)
				
	s.s		$f9,	($s1)			# store ?b^2-4ac / (2 * a) into $s1 for printing real and Im part
	addi		$s1,	$s1,	4		# increment to the next part of memory for $s3
				
	neg.s		$f5,	$f5			#  - b
				
	addi		$s2, $s2,	4		# increment to the next section of memory for disp_arr
	s.s		$f5,	($s2)			# store -b	into second section of disp_arr
				
	addi		$s2, $s2,	4		# increment to the next section of memory for disp_arr
	s.s		$f11,	($s2)			# store 2*a into third section of disp_arr
				
	div.s		$f6,	$f5,	$f11		# -b / 2a stored in $f6
	mov.s		$f11,	$f6			# move -b / 2a stored  to $f11
				
	s.s		$f11,	($s1)			# store  into -b / 2a $s3 for printing real and Im part
	

	jr		$ra				# return back to main
				
	
################################################################################
# Function Name:		complex
# Description:		negates and "triggers" output if b^2-4ac is negative (complex)
################################################################################
										
complex:

	li		$t2,	'i'			# load an i into t2 register
	sb		$t2,	($s5)			# load i into $s5 for printing complex
	li		$t3,	1			# load 1 into $t3
	sb		$t3,	($s6)			# 1 for complex has been triggered
				
	neg.s		$f6,	$f6			# make $f6 positive 
				
				
	j		continue 			# jump back to quadratic formula
				
			
	
################################################################################
# Function Name:		print_roots
# Description:		Displays the roots of f(x) both real and complex
################################################################################				
										
print_roots:
		
	la		$s5, 	com_sym		# initialize address parameter for complex symbol
	la		$s1, 	roots_of_x		# initialize the address for the roots
			
	la		$s2,	disp_arr		# initialized the address of disp_arr
				
	la		$a0,	roots			# load the message into $a0
	li		$v0,	4			# system code 4 for printing null terminated string at $a0
		syscall
		
		
	l.s		$f1,	($s1)			# Load the value from memory into $f1
	l.s		$f5,	4 ($s1)		# load the second value from memory into $f5
				
			
				
	add.s		$f7, $f1, $f5
	sub.s		$f9, $f5, $f1
				

	l.s		$f2, 	($s2)			# get b^2-4ac from $s2 and load into $f2
	addi		$s2, $s2, 4
	l.s		$f3, 	($s2)			# get -b c from $s2 and load into $f3
	addi		$s2, $s2, 4
	l.s		$f4, 	($s2)			# get 2a from $s2 and load into $f4


	li		$t1, 	43			# load 43 for + into $t1
				
	li		$v0,	11			# system code for printing characters at $a0
	li		$a0,	'\n'			# load a newline for printing		
		syscall					# print the newline
					
	root ($f3, $f2, $f4, $f7, $t1)			# references the macro in .data for the printing roots
				
	li		$v0,	11			# system code for printing characters at $a0
	li		$a0,	'\n'			# load a newline for printing	
		syscall					# print the newline
	
	## NOTICE: disp_arr address being dropped for complex
	la		$s2,	disp_arr		# initialized the address of disp_arr
	
	l.s		$f2, 	($s2)			# get b^2-4ac from $s2 and load into $f2
	addi		$s2, $s2, 4
	l.s		$f3, 	($s2)			# get -b c from $s2 and load into $f3
	addi		$s2, $s2, 4
	l.s		$f4, 	($s2)			# get 2a from $s2 and load into $f4
	
	## SEE NOTICE
	 
	li		$t1, 45				# load 45 for - into $t1
	
										
	root ($f3, $f2, $f4, $f9, $t1)			# references the macro in .data for the printing roots
				
	li		$v0,	11			# system code for printing characters at $a0
	li		$a0,	'\n'			# load a newline for printing	
		syscall					# print the newline
				
				
	jr		$ra				# return back to main
																													
