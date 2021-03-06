#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
	org		0x0000							# first processor p0
	ori		$sp, $zero, 0x3ffc	# stack
	jal		mainp0							# go to program

bmerge0:
	ori   $12, $zero, 0x01	
	ori		$18, $zero, flagz
	sw    $12, 0($18)
	# spin until p1 finished
	ori		$18, $zero, flago
wait0:
	lw   	$12, 0($18)
	beq  	$12, $zero, wait0

	# proceed with merge
	ori		$13, $zero,	0 #i_m
	ori		$14, $zero, 200 # = 4 * 50 		#i_n
	ori		$17, $zero,	0	#i_res_p0

merge0:
	#store M(i_m) to $10
	addiu	$10, $13, data
	lw		$10, 0($10)
	#store N(i_n) to $11
	addiu	$11, $14, data
	lw		$11, 0($11) 		# already offset by 50
	slt 	$12, $11, $10		# M > N
	bne 	$12, $zero, else0

	#---get lock on result---
	ori		$6, $zero, l1		# move lock to argument register
	jal		lock							# try to aquire the lock

	# critical code segment
	#store $10 to result(i_res_p0)
  addiu $16, $17, result
	sw		$10,	0($16)
	# unlock
	ori		$6, $zero, l1			# move lock to arguement register
	jal		unlock						# release the lock

	addiu	$13, $13, 4				# i_m += 1
	j check0

else0:
	#--get lock on result ---
	ori		$6, $zero, l1		# move lock to arguement register
	jal		lock							# try to aquire the lock

	# critical code segment
	#store $11 to result(i_res_p0)
	addiu $16, $17, result
	sw		$11,	0($16)
	#unlock
	ori		$6, $zero, l1		# move lock to arguement register
	jal		unlock						# release the lock

	addiu	$14, $14, 4			# i_n += 1

check0:
	addiu	$17, $17, 4			# i_res_p0 += 1
	ori		$12, $zero, ires0 
	sw		$17, 0($12)
	ori		$18, $zero, ires1	
	lw		$18, 0($18)

	#subu	$12, $17, $18
	#ori		$5, $zero, 4
	#bne		$12, $5, merge0
	bne	  $17, $18, merge0	# if indicies in result register are equal, we are done
	halt

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
	ll              $12, 0($6)       					# load lock location
  bne             $12, $0, aquire   					# wait on lock to be open
  addiu           $12, $12, 1
  sc              $12, 0($6)
  beq             $12, $0, lock     					# if sc failed retry
  jr              $ra
	
# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock: 
	sw              $0, 0($6)
  jr              $ra

# do insertion sort
mainp0:
	#push	$ra		        		# save return address
	addiu $sp, $sp, -4
	sw		$ra, 0($sp)
	#push	0xF0							# addr of first half of data stack
	ori 	$12, $zero, data
	addiu $sp, $sp, -4
	sw		$12, 0($sp)
	
	# main sort algorithm
	jal		sort
	#pop		$ra								# get return address
	lw		$ra, 0($sp)
	addiu $sp, $sp, 4
	jr		$ra									# return to caller

l1:
	cfw	0x0

#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200									# second processor p1
	ori		$sp, $zero, 0x7ffc		# stack
	jal		mainp1								# go to program
	ori   $12, $zero, 0x01
	ori		$18, $zero, flago
	sw    $12, 0($18)
	# spin until p0 finished
	ori		$18, $zero, flagz
wait1:
	lw    $12, 0($18)
	beq   $12, $zero, wait1

	# proceed with merge
	ori		$13, $zero,	196		#i_m
	ori		$14, $zero, 396 	#i_n
	ori		$17, $zero,	396		#i_res_p1
merge1:
	#store M(i_m) to $10
	addiu	$10, $13, data
	lw		$10, 0($10)
	#store N(i_n) to $11
	addiu	$11, $14, data
	lw		$11, 0($11) 		# already offset by 50
	slt 	$12, $10, $11		# M < N
	bne 	$12, $zero, else1

	#---get lock on result---
	ori		$6, $zero, l1		# move lock to argument register
	jal		lock							# try to aquire the lock

	# critical code segment
	#store $10 to result(i_res_p0)
  addiu $16, $17, result
	sw		$10,	0($16)
	# unlock
	ori		$6, $zero, l1			# move lock to arguement register
	jal		unlock						# release the lock

	addiu	$13, $13, -4				# i_m -= 1
	j check1

else1:
	#--get lock on result ---
	ori		$6, $zero, l1		# move lock to arguement register
	jal		lock							# try to aquire the lock

	# critical code segment
	#store $11 to result(i_res_p1)
	addiu $16, $17, result
	sw		$11,	0($16)
	#unlock
	ori		$6, $zero, l1		# move lock to arguement register
	jal		unlock						# release the lock

	addiu	$14, $14, -4			# i_n -= 1

check1:
	addiu	$17, $17, -4			# i_res_p1 -= 1
	ori		$12, $zero, ires1 
	sw		$17,	0($12)
	ori		$18, $zero, ires0	
	lw		$18,	0($18)
	
	subu	$12, $18, $17
	ori		$5, $zero, 4
	bne		$12, $5, merge1
	#bne	  $17, $18, merge1	# if indicies in result register are equal, we are done
	halt

# do insertion sort
mainp1:
	#push	$ra								# save return address
	addiu $sp, $sp, -4
	sw		$ra, 0($sp)

	#push	0xF0 + 50					#addr of second half of data stack	
	ori		$12, $zero, data
	addiu $12, $12, 200
	addiu $sp, $sp, -4
	sw		$12, 0($sp)

	# main sort algorithm
  jal		sort

	#pop		$ra								# get return address
	lw		$ra, 0($sp)
	addiu	$sp, $sp, 4 
	jr		$ra								# return to caller
	
	halt	

 flago:
	cfw 0x0
 flagz:
	cfw 0x0

 ires0:
	cfw 0x0
 ires1:
	cfw 400

# insertion sort algorithm
	org 0x0C00
#---------------------------------------------------------
sort:        
	ori	$13,$zero,50			# 50 values
	ori	$10,$zero,1
	#pop $14		# start of data
	lw	$14, 0($sp)
	addiu	$sp, $sp, 4

	beq	$zero,$zero,L2
	nop
	
	#inside of while
	L6:
	ori	$10, $zero, 0
	ori	$11, $zero, 1
	beq	$zero,$zero,L3
	nop
	
	L5:

	sll	$15,$11,2
	addiu	$2,$15,-4
	addu	$2,$2,$14
	lw	$3, 0($2)
	
	sll	$15,$11,2
	addu	$2,$15,$14
	lw	$2, 0($2)
	nop
	slt	$2,$2,$3
	
	beq	$2,$0,L4
	nop
	
	sll	$15,$11,2
	addiu	$2,$15,-4
	addu	$2,$2,$14
	lw	$12,0($2)
	nop
	sll	$15,$11,2
	addu	$3, $15, $14
	lw	$3,0($3)
	nop
	sw	$3,0($2)
	nop
	sll	$15,$11,2
	addu	$3, $15, $14
	sw	$12,0($3)
	nop
	ori	$10,$zero,1
	
	L4:
	addiu	$11,$11,1
	
	# i < count
	L3:
	slt	$2,$11,$13
	bne	$2,$0,L5
	nop
	
	#while(swapped == 1)
	L2:
	ori	$2, $zero, 1
	beq	$10,$2,L6
	nop
	
  # return to processor main loop
  jr	$ra

halt
# Start of data to sort

org 0x1000
data:
cfw 0x087d
cfw 0x5fcb
cfw 0xa41a
cfw 0x4109
cfw 0x4522
cfw 0x700f
cfw 0x766d
cfw 0x6f60
cfw 0x8a5e
cfw 0x9580
cfw 0x70a3
cfw 0xaea9
cfw 0x711a
cfw 0x6f81
cfw 0x8f9a
cfw 0x2584
cfw 0xa599
cfw 0x4015
cfw 0xce81
cfw 0xf55b
cfw 0x399e
cfw 0xa23f
cfw 0x3588
cfw 0x33ac
cfw 0xbce7
cfw 0x2a6b
cfw 0x9fa1
cfw 0xc94b
cfw 0xc65b
cfw 0x0068
cfw 0xf499
cfw 0x5f71
cfw 0xd06f
cfw 0x14df
cfw 0x1165
cfw 0xf88d
cfw 0x4ba4
cfw 0x2e74
cfw 0x5c6f
cfw 0xd11e
cfw 0x9222
cfw 0xacdb
cfw 0x1038
cfw 0xab17
cfw 0xf7ce
cfw 0x8a9e
cfw 0x9aa3
cfw 0xb495
cfw 0x8a5e
cfw 0xd859
cfw 0x0bac
cfw 0xd0db
cfw 0x3552
cfw 0xa6b0
cfw 0x727f
cfw 0x28e4
cfw 0xe5cf
cfw 0x163c
cfw 0x3411
cfw 0x8f07
cfw 0xfab7
cfw 0x0f34
cfw 0xdabf
cfw 0x6f6f
cfw 0xc598
cfw 0xf496
cfw 0x9a9a
cfw 0xbd6a
cfw 0x2136
cfw 0x810a
cfw 0xca55
cfw 0x8bce
cfw 0x2ac4
cfw 0xddce
cfw 0xdd06
cfw 0xc4fc
cfw 0xfb2f
cfw 0xee5f
cfw 0xfd30
cfw 0xc540
cfw 0xd5f1
cfw 0xbdad
cfw 0x45c3
cfw 0x708a
cfw 0xa359
cfw 0xf40d
cfw 0xba06
cfw 0xbace
cfw 0xb447
cfw 0x3f48
cfw 0x899e
cfw 0x8084
cfw 0xbdb9
cfw 0xa05a
cfw 0xe225
cfw 0xfb0c
cfw 0xb2b2
cfw 0xa4db
cfw 0x8bf9
cfw 0x12f7

org 0x800
result:


#-------------------------------------------------------------------
