	#include <xc.inc>
psect	udata_acs   ; named variables in access ram
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
    
psect	code, abs
rst: 	org 0x0
 	goto	setup

setup:
        banksel PADCFG1
        bsf REPU
        clrf LATE
        banksel	0 
	movlw 0xff
	movwf TRISE
	movlw 0x00
	movwf TRISD
	movff PORTE, WREG 
	movwf prev_b
	lfsr 0 , myArray 
	goto main
	
main:
    	comf PORTE ,W 
	movwf b_hldr
	call Button_check
	movff b_hldr,prev_b
	bra main
	
Store_Press:
    movff check_hldr ,POSTINC0
    return
    
Button_check:    
movff prev_b , WREG
andwf b_hldr ,W
movwf check_hldr
comf check_hldr ,W
andwf b_hldr, W
movwf check_hldr
movlw 0
cpfsgt check_hldr
return
call Store_Press
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

	end	main
