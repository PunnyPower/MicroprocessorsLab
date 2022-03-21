#include <xc.inc>

extrn	Record_Timer_Setup, Record_Int_Hi,Record_Count_Up_Setup ; timer modules
extrn   Record_Beat_Setup ; record beat modules 

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	setup

int_hi:	org	0x0008	; high vector, no low vector
	goto	Record_Int_Hi
setup:
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	banksel PADCFG1
        bsf REPU
        clrf LATE
	clrf 0x102
	clrf 0x103
	clrf 0x114
	clrf 0x115
        banksel	0  ;sets up port E pull up resistors 
	clrf	TRISH, A	; Set PORTH as all outputs
	clrf	LATH, A		; Clear PORTH outputs
	clrf	TRISJ, A	; Set PORTJ as all outputs
	clrf	LATJ, A		; Clear PORTJ outputs
	clrf	TRISD, A	; Set PORTD as all outputs
	clrf	LATD, A		; Clear PORTD outputs
	;call	Record_Count_Up_Setup


start:	
	call Record_Beat_Setup
	goto $	; Sit in infinite loop

	end	rst
