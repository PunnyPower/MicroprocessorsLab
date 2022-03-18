#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message,UART_Transmit_Byte  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message,LCD_delay_ms,LCD_Write_Hex,LCD_Shift
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
counter_hldr: ds 1
read_b:	ds 1
read_c3: ds 1
read_c2: ds 1
end_c3: ds 1
end_c2: ds 1
end_c3_write: ds 1
end_c2_write: ds 1
count_over: ds 1
count_over_read:ds 1
prev_read_c3: ds 1
prev_read_c2: ds 1
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
c1:	ds 1
c2:	ds 1 
c3:	ds 1 
c4:	ds 1 
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
	movwf TRISH
	movwf TRISJ
	movff PORTE, WREG 
	movwf prev_b
	lfsr 0 , myArray 
	movlw 0
	movwf counter
	movlw 0x0
	movwf PORTD
	movwf c1
	movwf c2
	movwf c3
	movwf c4
	movwf prev_read_c2
	movwf prev_read_c3
	movwf count_over
	movwf count_over_read
	movlw 00110001B
	movwf end_c2_write 
	movlw 00011000B
	movwf end_c3_write 
	movwf end_c2
	movlw 00011000B
	movwf end_c3 
	movlw 1000
	call LCD_delay_ms
	goto main
	
	; ******* Main programme ****************************************
main:
    call Button_Read
    movff b3,PORTH
    movff b4,PORTJ
    movlw 1
    cpfslt b8
    call make_sound_1
    cpfslt b7
    call make_sound_2
    cpfslt b6
    call make_sound_3
    cpfslt b5
    call make_sound_4
    movlw 1
    ;cpfslt b3
    ;call read_setup
    bra main
    

    ;call read_setup
make_sound_1:
    movff b_hldr,PORTD
    movlw 0x99
    call UART_Transmit_Byte
    movlw 44
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    movlw 1000
    call LCD_delay_ms
    movlw 0x89
    call UART_Transmit_Byte
    return
    make_sound_2:
    movff b_hldr,PORTD
    movlw 0x99
    call UART_Transmit_Byte
    movlw 43
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    movlw 1000
    call LCD_delay_ms
    movlw 0x89
    call UART_Transmit_Byte
    return
    make_sound_3:
    movff b_hldr,PORTD
    movlw 0x99
    call UART_Transmit_Byte
    movlw 41
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    movlw 1000
    call LCD_delay_ms
    movlw 0x89
    call UART_Transmit_Byte
    return
    make_sound_4:
    movff b_hldr,PORTD
    movlw 0x99
    call UART_Transmit_Byte
    movlw 49
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    movlw 1000
    call LCD_delay_ms
    movlw 0x89
    call UART_Transmit_Byte
    return
timer_check_loop_write:
    movlw 0xff
    cpfseq count_over 
    call    timer_check_1_write
    movlw 0xff
    cpfseq count_over 
    bra	    timer_check_loop_write
    return

timer_check_1_write:
    movff end_c2_write, WREG
    cpfseq c2 
    call Count_Up
    movff end_c2_write, WREG
    cpfseq c2
    call Write_loop
    movff end_c2_write, WREG
    cpfseq c2
    return
    call timer_check_2_write
    return
 
timer_check_2_write:
    movff end_c3_write, WREG
    cpfseq c3 
    call Count_Up
    movff end_c3_write, WREG
    cpfseq c3
    call Write_loop
    movff end_c3_write, WREG
    cpfseq c3 
    return
    
    call timer_check_3_write
    return
    
 timer_check_3_write:   
    movlw 0xff
    movwf count_over
    return
    
 
 
    
Write_loop:
    	comf PORTE ,W 
	movwf b_hldr
	movff prev_b,WREG
	call Button_check
	movff b_hldr,prev_b
	movlw 0xff
	return
	
Count_Up_Setup:
    movlw 0
    movwf c1
    movwf c2
    movwf c3
    movwf c4
	
Count_Up:
    movff c3,PORTH
    movff c2,PORTJ
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
    
 timer_check_loop_read:
    movlw 0xff
    cpfseq count_over_read 
    call    timer_check_1_read
    movlw 0xff
    cpfseq count_over_read 
    bra	    timer_check_loop_read
    return

timer_check_1_read:
    movff end_c2, WREG
    cpfseq c2 
    call Count_Up

    movff end_c2, WREG
    cpfseq c2
    return
    call timer_check_2_read
    return
 
timer_check_2_read:
    movff end_c3, WREG
    cpfseq c3 
    call Count_Up
    movff end_c3, WREG
    cpfseq c3 
    return
    
    call timer_check_3_read
    return
    
 timer_check_3_read:   
    movlw 0xff
    movwf count_over_read
    return
    
    
    
    
read_setup:
    lfsr 1, myArray
    movff counter, counter_hldr
    movlw 0
    movwf end_c2
    movwf end_c3
    movwf prev_read_c2
    movwf prev_read_c3
    call read
    bra read_setup
    return 
read:
    movlw 0 
    call read_Loop
    cpfsgt counter_hldr
    return
    bra read
read_Loop:
    movff POSTINC1,read_b
    movff POSTINC1,read_c3
    movff POSTINC1,read_c2
    movff prev_read_c2 ,WREG
    subwf read_c2, f
    movff prev_read_c3,WREG
    subwf read_c3, f
    movff read_c2,end_c2
    movff read_c3,end_c3
    call Count_Up_Setup
    call    timer_check_loop_read
    
    movff read_b , PORTD
    movlw 0
    movwf count_over_read
    movff read_c3,prev_read_c3
    movff read_c2,prev_read_c2
    decf    counter_hldr
    return
    
endloop:
    bra endloop
Store_Press:
    movff check_hldr ,POSTINC0
    movff c3,POSTINC0
    movff c2,POSTINC0
    incf counter
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
return


Button_Read:
        comf PORTE ,W 
	movwf b_hldr
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



	end	rst