#include <xc.inc>
	
global	Record_Beat_Setup
extrn Record_Timer_Setup
psect	udata_acs   ; reserve data space in access ram
b_hldr:ds 1 ; var for tthe current button press
prev_b: ds 1 ; var for previous button press
check_hldr: ds 1 ; var that checks for unique button presses
c3:ds 1
c2:ds 1
end_c3:ds 1
end_c2:ds 1
	
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
Loop_Start_Location:    ds 0xff ; reserve 256 bytes for beat data
    
    
    
psect	Record_Input_code, class=CODE

Record_Beat_Setup:
    movlw 8
    movlw PORTD
    movwf end_c3
    movlw 0
    movwf end_c2
    movff end_c3, 0x104
    movff end_c2, 0x105
    movwf b_hldr
    movwf prev_b
    lfsr 0 ,Loop_Start_Location
    ; sets up the variables 
    ;call Record_Timer_Setup
    ;call Record_Beat
    return
Double_return:
        pop
	return
Quad_return:
        pop
	pop
	pop
	return	
	
Store_Press:
    movff check_hldr ,POSTINC0
    movff c3,POSTINC0
    movff c2,POSTINC0
    return
Unique_Input_Check:    
    andwf b_hldr ,W
    movwf check_hldr
    comf check_hldr ,W
    andwf b_hldr, W
    movwf check_hldr
    movlw 0
    cpfsgt check_hldr
    call Double_return
    movf check_hldr,W
    call Store_Press
    return
    
    
Record_Beat:
    movff 0x102,c3
    movff 0x103,c2
    comf PORTE,W
    movwf b_hldr
    movf prev_b ,W
    call Unique_Input_Check
    call Check_End
    movff b_hldr,prev_b
    bra Record_Beat

    return

Check_End:
    movlw 0xff
    cpfseq c3
    return
    call Check_End_Lower
    return
Check_End_Lower:
    movlw 0x0
    cpfseq c2
    return
    call Quad_return
    


	end
