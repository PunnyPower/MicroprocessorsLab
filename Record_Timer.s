#include <xc.inc>
	
global	Record_Timer_Setup, Record_Int_Hi

psect	udata_acs   ; reserve data space in access ram
c1:	ds 1
c2:	ds 1 
c3:	ds 1 
c4:	ds 1 
end_c2: ds 1
end_c3: ds 1
	
	
	
psect	Record_Timer_code, class=CODE
	
Record_Int_Hi:; load end number into working function	
	btfss	TMR2IF		; check that this is timer0 interrupt
	retfie	f		; if not then return
	call Count_Up
	movff c4,PORTD
	movff c3,PORTE
	movff c2,PORTH
	movff c1,PORTJ
	call	Check_End
	bcf	TMR2IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

Record_Timer_Setup:
	clrf	TRISD, A	; Set PORTD as all outputs
	clrf	LATD, A		; Clear PORTD outputs
	clrf	TRISE, A	; Set PORTE as all outputs
	clrf	LATE, A		; Clear PORTE outputs
	clrf	TRISH, A	; Set PORTH as all outputs
	clrf	LATH, A		; Clear PORTH outputs
	clrf	TRISJ, A	; Set PORTJ as all outputs
	clrf	LATJ, A		; Clear PORTJ outputs
	movlw	0xA0
	movwf PR2
	movlw	00000100B	; Set timer2 to 16-bit, Fosc/4
	movwf	T2CON, A	; =  approx 10 microsec rollover
	movlw 0xC0
	movwf INTCON,A ;g p enable global interrupt
	bsf	TMR2IE		; Enable timer2 interrupt
	bsf	GIE		; Enable all interrupts
	bsf TMR2IP ; place TMR2 interrupt at high priority
	bcf TMR2IF ; 
	movlw 01100110B
	movwf end_c2
	movwf end_c3
	call Count_Up_Setup
	return
Stop_Timer:
    clrf	T2CON, A	; =  approx 10 microsec rollover   
    return
Count_Up_Setup:
    movlw 0
    movwf c1
    movwf c2
    movwf c3
    movwf c4
	
Count_Up:
    movlw 0xff
    incf c1
    cpfseq c1
    return
    call Count_Up_2
    movlw 0
    movwf c1
    return
	
Count_Up_2:	
    movlw 0xff
    incf c2
    cpfseq c2
    return
    call Count_Up_3
    movlw 0
    movwf c2
    return
Count_Up_3:	
    movlw 0xff
    incf c3
    cpfseq c3
    return
    call Count_Up_4
    movlw 0
    movwf c3
    return
Count_Up_4:	
    movlw 0xff
    incf c4
    cpfseq c4
    return
    movlw 0
    movwf c4
    return
    
Check_End:
    movf end_c3,W
    cpfseq c3
    return
    call Check_End_Lower
    return
Check_End_Lower:
    movf end_c2,W
    cpfseq c2
    return
    call Stop_Timer
    return
	end

