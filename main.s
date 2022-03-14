#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message,LCD_delay_ms,LCD_Write_Hex,LCD_Shift
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
prev_b: ds 1
b_hldr:	ds 1
b1:	ds 1
b2:	ds 1 
b3:	ds 1 
b4:	ds 1 
b5:	ds 1
b6:	ds 1 
b7:	ds 1 
b8:	ds 1 
check_hldr: ds 1
prev_hldr: ds 1
prev_b1:	ds 1
prev_b2:	ds 1 
prev_b3:	ds 1 
prev_b4:	ds 1 
prev_b5:	ds 1
prev_b6:	ds 1 
prev_b7:	ds 1 
prev_b8:	ds 1 
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
        banksel PADCFG1
        bsf REPU
        clrf LATE
        banksel	0 
	movlw 0xff
	movwf TRISE
	movlw 0x00
	movwf TRISD
	movlw 0x00
	movwf TRISJ
	movff PORTE, WREG 
	movwf prev_b
	lfsr 0 , myArray 
	movlw 40
	movwf counter
	goto main
	
	; ******* Main programme ****************************************
main:
    movlw 0
    CPFSGT counter
    call read_setup
    call loop
    bra main
loop:
    	comf PORTE ,W 
	movwf b_hldr
	movff prev_b,WREG
	call Button_check
	movff b_hldr,prev_b
	return

read_setup:
    lfsr 1, myArray
    movlw 40
    movwf counter
    call read
    return 
read:
    movlw 0 
    CPFSGT counter
    goto endloop
    call read_Loop
    bra read
read_Loop:
    movlw 1000
    call    LCD_delay_ms
    call    LCD_delay_ms
    call    LCD_delay_ms
    movff POSTINC1,PORTD
    decf    counter
    return
    
endloop:
    bra endloop
Store_Press:
    movff check_hldr ,POSTINC0
    return
    
test:
    pop
    return
   
Button_check:    
andwf b_hldr ,W
movwf check_hldr
comf check_hldr ,W
andwf b_hldr, W
movwf check_hldr
movlw 0
cpfsgt check_hldr
call test
movff check_hldr,WREG
movff check_hldr,PORTD
call LCD_Write_Hex
call Store_Press
DECF counter
return


Button_Read:
	movlw 00000001B
	andwf b_hldr, W
	movwf b1
	movlw 00000010B
	andwf b_hldr, W
	movwf b2
	movlw 00000100B
	andwf b_hldr, W
	movwf b3
	movlw 00001000B
	andwf b_hldr, W
	movwf b4
	movlw 00010000B
	andwf b_hldr, W
	movwf b5
	movlw 00100000B
	andwf b_hldr, W
	movwf b6
	movlw 01000000B
	andwf b_hldr, W
	movwf b7
	movlw 10000000B
	andwf b_hldr, W
	movwf b8
	return

	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst