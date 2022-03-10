#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex,LCD_Clear_Display,LCD_delay_ms,LCD_Shift_Display,LCD_Send_Byte_D; external LCD subroutines
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
ARG1L:	    ds 1    ; reserve 8 bytes for low arg
ARG1H:	    ds 1    ; reserve 8 bytes for high arg
ARG2L:	    ds 1    ; reserve 8 bytes for low arg
ARG2H:	    ds 1    ; reserve 8 bytes for high arg
ARG2U:	    ds 1    ; reserve 8 bytes for upper arg
RES0:	    ds 1    ; reserve 8 bytes for lower part of prod
RES1:	    ds 1    ; reserve 8 bytes for higher part of prod
RES2:	    ds 1    ; reserve 8 bytes for lower part of prod
RES3:	    ds 1    ; reserve 8 bytes for lower part of prod
Dec0:	    ds 1    ; reserve 1 byte for the first dec digit
Dec1:	    ds 1    ; reserve 1 byte for the first dec digit
Dec2:	    ds 1    ; reserve 1 byte for the first dec digit
Dec3:	    ds 1    ; reserve 1 byte for the first dec digit
    
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	goto	start
	
	; ******* Main programme ****************************************
start: 	
goto measure_loop
	
measure_loop:
	call	ADC_Read
	movf	ADRESH, W, A
	call	LCD_Write_Hex
	movf	ADRESL, W, A
	call	LCD_Write_Hex
	movlw	1000
	call	LCD_delay_ms
	call LCD_Shift_Display
	call Hex_to_Dec
	call Hex_to_Dec_to_ascii
	movff Dec0 , WREG
	call LCD_Send_Byte_D
	movff Dec1 , WREG
	call LCD_Send_Byte_D
	movff Dec2 , WREG
	call LCD_Send_Byte_D
	movff Dec3 , WREG
	call LCD_Send_Byte_D
	movlw	1000
	call	LCD_delay_ms
	call	LCD_delay_ms
	call	LCD_Clear_Display
	goto	measure_loop		; goto current line in code
	
	
	

Setup_Hex_to_Dec:
	movff	ADRESL, ARG2L	
	movff	ADRESH, ARG2H
	movlw	0x8A
	movwf	ARG1L
	movlw	0x41
	movwf	ARG1H
	return

Multiply16x16:
    MOVF ARG1L, W
    MULWF ARG2L ; ARG1L * ARG2L->
    ; PRODH:PRODL
    MOVFF PRODH, RES1 ;
    MOVFF PRODL, RES0 ;
    ;
    MOVF ARG1H, W
    MULWF ARG2H ; ARG1H * ARG2H->
    ; PRODH:PRODL
    MOVFF PRODH, RES3 ;
    MOVFF PRODL, RES2 ;
    ;
    MOVF ARG1L, W
    MULWF ARG2H ; ARG1L * ARG2H->
    ; PRODH:PRODL
    MOVF PRODL, W ;
    ADDWF RES1, F ; Add cross
    MOVF PRODH, W ; products
    ADDWFC RES2, F ;
    CLRF WREG ;
    ADDWFC RES3, F ;
    ;
    MOVF ARG1H, W ;
    MULWF ARG2L ; ARG1H * ARG2L->
    ; PRODH:PRODL
    MOVF PRODL, W ;
    ADDWF RES1, F ; Add cross
    MOVF PRODH, W ; products
    ADDWFC RES2, F ;
    CLRF WREG ;
    ADDWFC RES3, F ; 
	return

Multiply8x24:
	MOVF ARG1L, W
	MULWF ARG2L ; ARG1L * ARG2L->
	; PRODH:PRODL
	MOVFF PRODH, RES1 ; 
	MOVFF PRODL, RES0 ;
	;
	MOVF ARG1L, W
	MULWF ARG2H ; ARG1H * ARG2H->
	; PRODH:PRODL
	MOVF PRODL, W
	ADDWF RES1, F	; PRODL + RES1--> RES1
	MOVFF PRODH, RES2 ;
	; 
	MOVF ARG1L, W
	MULWF ARG2U ; ARG1H * ARG2H->
	; PRODH:PRODL
	MOVF PRODL, W
	ADDWFC RES2, F ; PRODL + RES2 + carry bit --> RES2
	MOVLW 0x0
	ADDWFC	PRODH, F ; add the carry bit to RES3 (highest byte)
	MOVFF PRODH, RES3 ; 
	return
    
Hex_to_Dec:
	; Setup 16x16
	call	Setup_Hex_to_Dec
	; Do 16x16 mult
	call	Multiply16x16
	; Set first digit
	movf	RES3, W
	movwf	Dec0, F

	; Setup 8x24
	movlw	0x0A
	movwf	ARG1L, F
	
	movf	RES0, W
	movwf	ARG2L, F
	movf	RES1, W
	movwf	ARG2H, F
	movf	RES2, W
	movwf	ARG2U, F
	; Do 8x24 mult and set each digit three times
	call	Multiply8x24
	;  set digit
	movf	RES3, W
	movwf	Dec1, F
	
	movf	RES0, W
	movwf	ARG2L, F
	movf	RES1, W
	movwf	ARG2H, F
	movf	RES2, W
	movwf	ARG2U, F
	call	Multiply8x24
	;  set digit
	movf	RES3, W
	movwf	Dec2, F
	
	movf	RES0, W
	movwf	ARG2L, F
	movf	RES1, W
	movwf	ARG2H, F
	movf	Dec2, W
	movwf	ARG2U, F
	call	Multiply8x24
	;  set digit
	movf	RES3, W
	movwf	Dec3, F

    return    
Hex_to_Dec_to_ascii:
	movlw	48
	addwf	Dec0, F
	addwf	Dec1, F
	addwf	Dec2, F
	addwf	Dec3, F
	return   
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst