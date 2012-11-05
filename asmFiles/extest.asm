#------------------------------------------
# Originally Test and Set example by Eric Villasenor
# Modified to be LL and SC example by Yue Du
#------------------------------------------

#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
	org		0x0000							# first processor p0
	ll              $t0, 0($a0)       					# load lock location
  sc              $t0, 0($a0)
	halt

	cfw	0x0


#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200							# second processor p1
	ll              $t0, 0($a0)       					# load lock location
  sc              $t0, 0($a0)
	halt

	cfw 0x0									# end result should be 3
