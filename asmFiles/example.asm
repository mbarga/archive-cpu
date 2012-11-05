#------------------------------------------
# Originally Test and Set example by Eric Villasenor
# Modified to be LL and SC example by Yue Du
#------------------------------------------

#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
	org		0x0000							# first processor p0
	ori		$sp, $zero, 0x3ffc			
	jal		mainp0							# go to program
	halt

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
	      ll              $5, 0($8)       					# load lock location
        bne             $5, $0, aquire   					# wait on lock to be open
        addiu           $5, $5, 1
        sc              $5, 0($8)
        beq             $5, $0, lock     					# if sc failed retry
        jr              $ra

	
# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock: 
	sw              $0, 0($8)
        jr              $ra

# main function does something ugly but demonstrates beautifully
mainp0:
#	push		$ra							# save return address
	addiu		$sp, $sp, -4
	sw			$ra, 0($sp)

	ori		$8, $zero, l1						# move lock to arguement register
	jal		lock							# try to aquire the lock
	# critical code segment
	ori		$7, $zero, res	
	lw		$5, 0($7)
	addiu		$6, $5, 2
	sw		$6, 0($7)
	# critical code segment
	ori		$8, $zero, l1						# move lock to arguement register
	jal		unlock							# release the lock
	#pop		$ra							# get return address
	lw 		$ra, 0($sp) 		
	addiu	$sp, $sp, 4

	jr		$ra							# return to caller
l1:
	cfw	0x0


#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200							# second processor p1
	ori		$sp, $zero, 0x7ffc					# stack
	jal		mainp1							# go to program
	halt

# main function does something ugly but demonstrates beautifully
mainp1:
# push		$ra							# save return address
	addiu		$sp, $sp, -4
	sw			$ra, 0($sp)

	ori		$8, $zero, l1						# move lock to arguement register
	jal		lock							# try to aquire the lock
	# critical code segment
	ori		$7, $zero, res	
	lw		$5, 0($7)
	addiu		$6, $5, 1
	sw		$6, 0($7)
	# critical code segment
	ori		$8, $zero, l1						# move lock to arguement register
	jal		unlock							# release the lock
	#pop		$ra							# get return address
	lw 		$ra, 0($sp) 		
	addiu	$sp, $sp, 4

	jr		$ra							# return to caller

res:
	cfw 0x0									# end result should be 3
