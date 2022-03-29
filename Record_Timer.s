#include <xc.inc>
	
global	Record_Timer_Setup, Record_Int_Low,Record_Count_Up_Setup,Stop_Timer
global	c1,c2,c3,c4,end_c2,end_c3,Count_Over

psect	udata_acs   ; reserve data space in access ram
c1:	ds 1
c2:	ds 1 
c3:	ds 1 
c4:	ds 1 
end_c2: ds 1
end_c3: ds 1
Count_Over:   ds 1
	
	
	
psect	Record_Timer_code, class=CODE
	
Record_Int_Low:; load end number into working function	
	btfss	TMR2IF		; check that this is timer2 interrupt
	return		; if not then return
	call Count_Up
	call	Check_End
	movff c3,PORTH
	movff c2,PORTJ
				;read by the other modules 
	bcf	TMR2IF		; clear interrupt flag
	return		; fast return from interrupt

Record_Timer_Setup:
	movlw 0x00
	movwf Count_Over
	movlw	0xA0 ; =  approx 10 microsec rollover   
	movwf PR2
	; =  approx 10 microsec rollover
	movlw	00000100B	; Set timer2 to 16-bit, Fosc/4
	movwf	T2CON, A	; =  approx 10 microsec rollover
	movlw 0xC0
	movwf INTCON,A ;g p enable global interrupt
	bsf	TMR2IE		; Enable timer2 interrupt
	bsf	GIE		; Enable all interrupts
	bcf TMR2IP ; place TMR2 interrupt at high priority
	bcf TMR2IF ;
	bsf IPEN
 
	call Record_Count_Up_Setup
	return
Stop_Timer:  ;deactivates the interupt flag for the timer 
    clrf	T2CON, A	
    movlw 0xff
    movwf Count_Over
    movff Count_Over , 0x20F
    return
Record_Count_Up_Setup:
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
    
Check_End:   ; checks to see if the timer is at its end value
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

