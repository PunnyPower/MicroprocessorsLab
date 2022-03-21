#include <xc.inc>
	
global	Check_End

psect	udata_acs   ; reserve data space in access ram
b_hldr:ds 1 ; var for tthe current button press
prev_b: ds 1 ; var for previous button press
check_hldr: ds 1 ; var that checks for unique button presses
c3:ds 1
c2:ds 1
end_c3:ds 1
end_c2:ds 1
	

    
    
    
psect	Record_Input_code, class=CODE

Record_Output_Setup:
    lfsr 1, 0x400

Check_End:
    movlw end_c3
    cpfseq c3
    return
    call Check_End_Lower
    return
Check_End_Lower:
    movlw end_c2
    cpfseq c2
    return
    call Quad_return
    


	end

