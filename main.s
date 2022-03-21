#include <xc.inc>

extrn	Record_Timer_Setup, Record_Int_Hi

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	start

int_hi:	org	0x0008	; high vector, no low vector
	goto	Record_Int_Hi
	
start:	call	Record_Timer_Setup
    
	
	goto	$	; Sit in infinite loop

	end	rst
