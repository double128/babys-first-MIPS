# Car park MIPS assembly program
# Written by Ashley, 2017

.data 
						
	car_model: 	  .word 2, 3, 4, 5, 6, 6, 7, 3, 4, 3, 3, 3, 3, 1, 2, 1, 1, 1, 5, 7, 7, 7, 6, 5, 3, 3, 2, 2, 1, 1, 6, 6
	car_colour:   .word 2, 4, 6, 8, 7, 5, 3, 1, 2, 3, 1, 4, 5, 6, 7, 8, 7, 5, 3, 1, 2, 3, 5, 7, 8, 3, 5, 1, 3, 5, 7, 8
	car_year:     .word 2001, 2003, 2006, 2010, 2012, 2013, 2013, 2014, 2006, 2007, 2005, 2009, 2009, 2010, 2010, 2013, 2014, 2014, 2015, 2016, 2005, 2007, 2008, 2008, 2010, 2001, 2003, 2004, 2005, 2007, 2013, 2015

	title:		    .asciiz "//// CAR PARKING GARABGE DATABASE SEARCH /////\n\n"

	modinfo:	    .asciiz "CAR MODEL CODES:\nFord: 1\nBMW: 2\nAudi: 3\nHonda: 4\nInfinity: 5\nHyundai: 6\nToyota: 7\n"
	colinfo:	    .asciiz "\nCAR COLOUR CODES:\nBlack: 1\nBlue: 2\nYellow: 3\nRed: 4\nGray: 5\nWhite: 6\nGreen: 7\nSilver: 8\n"

	usrin: 		    .asciiz ">> Please enter the code for the MODEL, COLOUR, and YEAR of your vehicle.\n" 
	true: 		    .asciiz "From positions 0-31, your car is located in position #" 
	false: 		    .asciiz "We apologize for the inconvenience, your car is not in this parking lot."   

	usrmo:		    .word 0		# Variable to store user input for the car model
	usrco:    	  .word 0 	# Variable to store... yeah, you should know this
	usrye:		    .word 0 	# Please... you're better than this
  
                          # These must be .word values so we can get the actual values associated with them
                          # Rather than the memory address... kind of like dereferencing

.text

main: 
					                # I/O:
	li	  $v0, 4			
	la	  $a0, title		    # Load title string (it makes things neater)
	syscall			          	# Output it
					
	li 	  $v0, 4			
	la	  $a0, modinfo	    # Load car model database
	syscall				          # Output it
	
	li	  $v0, 4
	la	  $a0, colinfo		  # Load car colour database
	syscall				          # Output it
					
	li 	  $v0, 4 			      # Load value of 4 (print string) into register $v0,
	la	  $a0, usrin 		    # Load address of the initial output into $a0
	syscall 			          # Read register opcode, print string located in $a0 
				
					                # USER CAR MODEL INPUT:			
	li  	$v0, 5			      # Load value of 5 (read integer) into the register
	sw	  $v0, usrmo		    # Prepare register for later to store input in usrmo
	syscall				          # Ring... ring... take the user's call
	add	  $s0, $v0, 0		    # Push integer into $s0 for external use

					                # USER CAR COLOUR INPUT:
	li	  $v0, 5			      # Load value of 5 (read integer) into the register
	sw	  $v0, usrco		    # Prepare register for later use
	syscall				          # Ring ring, it's a (register) call for you
	add	  $s1, $v0, 0		    # Push integer into $s1 for external use
					
					                # USER CAR YEAR INPUT:
	li	  $v0, 5		        # Load value of 5 (read integer) into the register
	sw	  $v0, usrye		    # Prepare register for later use
	syscall				          # Ring ring, stop calling me!
	add	  $s2, $v0, 0		    # Push integer into $s2 for external use

	add 	$t0, $0, 0		    # int i = 0, first position of an array
	add	  $s7, $0, 32		    # int MAX_SIZE = 32, last position of an array
	
	add 	$s6, $0, 0        # int counter = 0; we need a counter for the parking lot position 
					                # (The i pointer relies on memory addresses, not integer values)
					                # (We'd get the wrong number if we output the parking lot position as i)
	
				                	# LET'S RECAP with a handy >> REGISTER MAP! <<
				                	# $s0 -> usrcar pointer
				            	    # $s1 -> usrcolour pointer
				                	# $s2 -> usryear pointer
					                #
					                # $t0 -> i
					                # $s7 -> 32
 
				                	# BEGIN FOR LOOP ##############################
					                # for (int i = 0; i < 32; i++)			
count:
	beq   $t0, $s7, exit 	  # Check if i < 32; if it is, branch to exit, presumably unable to find car
	
	lw	  $t1, car_model($t0)	  # Load car_model[i]
	bne	  $t1, $s0, update	    # Compare value stored at car_model[i] to the user's input 
	
	lw	  $t2, car_colour($t0)  # Load car_colour[i]
	bne	  $t2, $s1, update	    # Compare value stored at car_model[i] to the user's input
	
	lw	  $t3, car_year($t0)	  # Load car_colour[i]
	bne	  $t3, $s2, update	    # Compare value stored at car_model[i] to the user's input
	
					                # In all instances, we are reusing the same pointer (i) to iterate through the arrays
				                	# This value is saved between instances (so long as the input and array value are equal)

	jal 	found		        	# If all values are equal, then the car has been found!
  
update: 
	addi 	$t0, $t0, 4    	 	# Increment by 4 bytes (i++)
	add	  $s6, $s6, 1	      # Increment the counter by one (counter++)
	jal  	count         		# Return to the start of the loop

exit: 
	la    $a0, false      	# Car could not be found :( 
	li 	  $v0, 4	         	# Output this to the user 
	syscall 		          	# The worst call you'll ever have to make

	li    $v0, 10       		# Call value to exit program
	syscall 		          	# Goodbye!
 
 found: 
	la  	$a0, true 	      # Call address of true output string
	li 	  $v0, 4		        # String output call...
	syscall				          # Output string
	
	la 	  $a0, ($s6)	      # Call address of $s6, which is our counter
	add   $v0, $a0, 0		    # Now we output the value stored in counter, which increased by 1 each loop
	li	  $v0, 1		       	# This outputs the parking spot number that the car is located in
	syscall
	
	li    $v0, 10 	       	# Call value to exit program
  syscall 			          # Seeya!
