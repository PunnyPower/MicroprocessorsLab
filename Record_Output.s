#include <xc.inc>
	
global	Record_Output_Setup
extrn Record_Timer_Setup,Stop_Timer
extrn	c1,c2,c3,c4,end_c2,end_c3,Count_Over
extrn Beat_Length
psect	udata_acs   ; reserve data space in access ram
b_hldr:ds 1 ; var for tthe current button press
c3_hldr:ds 1
c2_hldr:ds 1
prev_c3_hldr:ds 1
prev_c2_hldr:ds 1

	

    
    
    
psect	Record_Input_code, class=CODE

Record_Output_Setup:
    lfsr 1, 0x400
    ;movff 0x11F, Beat_Length
    movlw 5
    movwf Beat_Length
    movlw 0
    movlw prev_c3_hldr
    movlw prev_c2_hldr
    movlw 10
    movwf end_c3
    movlw 0
    movwf end_c2
    call Read
    return
    
Read:
    movff end_c3, PORTD
    call Record_Timer_Setup ; starts counting 
    call Read_Loop	    ; initiates the check functions 
    ;movff Beat_Length,PORTD ; outputs results at correct time 
    dcfsnz Beat_Length
    return
    incf end_c3
    bra Read
    
Read_Loop:
    call Check_End
    bra Read_Loop
  
    
Check_End: ; checks if the timer has counted to the right value
    movlw 0xFF
    cpfseq Count_Over
    return
    call Triple_return
Triple_return:
	pop
        pop
	return
	

	end

