#include <xc.inc>
	
global	Record_Timer_Setup, Record_Int_Hi,Record_Count_Up_Setup

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
	call	Check_End
	;movff c3,PORTH
	;movff c2,PORTJ
	movff c3,0x102
	movff c2,0x103         ; moves c2,c3 to ports so they can be 
				;read by the other modules 
	bcf	TMR2IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

Record_Timer_Setup:
	movff 0x203,end_c3
	movff 0x202,end_c2 ; record for only aprox 5 seconds
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
	call Record_Count_Up_Setup
	return
Stop_Timer:
    clrf	T2CON, A	; =  approx 10 microsec rollover   
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

