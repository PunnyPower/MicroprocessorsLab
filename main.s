#include <xc.inc>

extrn	Record_Timer_Setup, Record_Int_Low,Record_Count_Up_Setup ; timer modules
extrn   Record_Beat_Setup ; record beat modules 
extrn	Record_Output_Setup
extrn   Button_Int_Setup,B_Int_Hi
extrn	UART_Setup, UART_Transmit_Byte

psect	code, abs
rst:	org	0x0000	; reset vector
	goto	setup

int_hi:	org	0x0008	; high vector, no low vector
	call	B_Int_Hi
	retfie f
int_low: org	0x0018	; high vector, no low vector
	call	Record_Int_Low
	retfie f
setup:
	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call UART_Setup
	banksel PADCFG1
        bsf REPU
        clrf LATE
          ;sets up port E pull up resistors 
	banksel INTCON2
	bcf RBPU
	clrf LATB  
	movlw 0xCF
	movwf TRISB,A
	banksel	0
	  ; sets up PORTB 
	clrf	TRISH, A	; Set PORTH as all outputs
	clrf	LATH, A		; Clear PORTH outputs
	clrf	TRISJ, A	; Set PORTJ as all outputs
	clrf	LATJ, A		; Clear PORTJ outputs
	clrf	TRISD, A	; Set PORTD as all outputs
	clrf	LATD, A		; Clear PORTD outputs
	call Button_Int_Setup
	
	


start:	
	call Record_Beat_Setup
	;call Record_Output_Setup
	
	
	goto $	; Sit in infinite loop

	end	rst
