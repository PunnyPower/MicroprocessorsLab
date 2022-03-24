#include <xc.inc>
	
global	Record_Beat_Setup
global  Beat_Length
extrn Record_Timer_Setup
extrn c1,c2,c3,c4,end_c2,end_c3,Count_Over
psect	udata_acs   ; reserve data space in access ram
b_hldr:ds 1 ; var for tthe current button press
prev_b: ds 1 ; var for previous button press
check_hldr: ds 1 ; var that checks for unique button presses
Beat_Length:ds 1 ; var for the length of a beat	  

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
Loop_Start_Location:    ds 0xff ; reserve 256 bytes for beat data
 
    
    
    
psect	Record_Input_code, class=CODE

Record_Beat_Setup:
    movlw 0 
    movwf Beat_Length; initialises beat length 
    
    movlw 8
    movwf end_c3
    movlw 0
    movwf end_c2    ; sets timer to count for 5 seconds 
    movwf b_hldr
    movwf prev_b		; initialises button presses
    lfsr 0 ,Loop_Start_Location	    ; sets up the fsr0 with the beat location in memeory 
    ; sets up the variables 
    call Record_Timer_Setup	    ; starts timer
    call Record_Beat		    ; starts recording 
    return
Triple_return:
        pop
	pop
	return		
Double_return:
        pop
	return
	
Store_Press:	; stores beat and time stamp in memory
    movff check_hldr ,POSTINC0
    movff c3,POSTINC0
    movff c2,POSTINC0
    incf Beat_Length
    return
Unique_Input_Check:    ; uses an algorithum to check for unique button presses 
    andwf b_hldr ,W; previous button presses needs to be in WREG
    movwf check_hldr
    comf check_hldr ,W
    andwf b_hldr, W
    movwf check_hldr
    movlw 0
    cpfsgt check_hldr
    call Double_return
    movf check_hldr,W
    movff check_hldr ,PORTD
    call Store_Press
    return
    
    
Record_Beat:
    comf PORTE,W
    movwf b_hldr
    movlw 0x0F
    andwf b_hldr,F ; only uses bottom 4 buttons for beat  
    
   
    movf prev_b ,W
    call Unique_Input_Check  ; checks for unique button presses
    call Check_End	    ; checks to see if the end timer var is set 
    movff b_hldr,prev_b
    bra Record_Beat	    ; continues loop

    return

Check_End:
    movlw 0xFF
    cpfseq Count_Over
    return
    call Triple_return   ; if bit is set stop recording 
   
    


	end

