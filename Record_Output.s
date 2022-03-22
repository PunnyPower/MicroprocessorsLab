#include <xc.inc>
	
global	Record_Output_Setup
extrn Record_Timer_Setup
psect	udata_acs   ; reserve data space in access ram
b_hldr:ds 1 ; var for tthe current button press
Beat_Length: ds 1 ; var that checks for unique button presses
c3:ds 1
c2:ds 1
c3_hldr:ds 1
c2_hldr:ds 1
prev_c3_hldr:ds 1
prev_c2_hldr:ds 1
end_c3:ds 1
end_c2:ds 1
Loop_Break_hldr:ds 1 ; a variable to contain a loop break condition
	

    
    
    
psect	Record_Input_code, class=CODE

Record_Output_Setup:
    lfsr 1, 0x400
    ;movff 0x11F, Beat_Length
    movlw 5
    movwf Beat_Length
    movlw 0
    movlw prev_c3_hldr
    movlw prev_c2_hldr
    movlw Loop_Break_hldr
    movlw 1
    movwf end_c3
    call Read
    return
    
Read:
   ; movff b_hldr, POSTINC1
   ; movff c3_hldr,POSTINC1
    ;movff c2_hldr,POSTINC1
    ;movf prev_c3_hldr,W
    ;subwf c3_hldr ,W
    ;movwf end_c3
    movff end_c3,0x203
    ;movf prev_c2_hldr,W
    ;subwf c2_hldr ,W
    movlw 0
    movwf end_c2
    movff end_c2,0x202  ; reads in the correct button and time stamp
			; and converts it into a useable end count value 
    		
    call Record_Timer_Setup ; starts counting 
    call Read_Loop	    ; initiates the check functions 
    movff Beat_Length,PORTD ; outputs results at correct time 
    movlw 0
    movwf Loop_Break_hldr   ; resets break condition 
    movwf PORTD
    dcfsnz Beat_Length
    return
    ;movff c3_hldr,prev_c3_hldr	; moves timestamp to previous time stamp
    ;movff c2_hldr,prev_c2_hldr
    incf end_c3
    bra Read
    
Read_Loop:
    movff 0x102,c3
    movff 0x103,c2
    movff c3,PORTH
    movff c2,PORTJ
    call Check_End
    movlw 0xff
    cpfseq Loop_Break_hldr
    bra Read_Loop
    return
    
Check_End: ; checks if the timer has counted to the right value
    movlw end_c3
    cpfseq c3
    return
    call Check_End_Lower
    return
Check_End_Lower:
    movlw end_c2
    cpfseq c2
    return
    call Loop_Break
    return
Loop_Break:; sets the loop break condition 
    movlw 0xff
    movwf PORTD
    movwf Loop_Break_hldr
	return

	end

