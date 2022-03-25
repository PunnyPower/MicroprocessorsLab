#include <xc.inc>
global Button_Int_Setup,B_Int_Hi,Button_Action,b1,b2,b3,b4,b5,b6,b7,b8
extrn  UART_Transmit_Byte
extrn  delay_ms
extrn  Record_Beat_Setup,Record_Output_Setup

psect	udata_acs   ; reserve data space in access ram
b_hldr:ds 1
b1:	ds 1
b2:	ds 1 
b3:	ds 1 
b4:	ds 1 
b5:	ds 1
b6:	ds 1 
b7:	ds 1 
b8:	ds 1
	
psect	Button_Interupt_code, class=CODE
	
B_Int_Hi:; load end number into working function	
	btfss	INT1IF		; check that this is timer0 interrupt
	return  		; if not then return
	call Read_input
	call Button_Read
	call Button_Action
	
				;read by the other modules 

	bcf	INT1IF		; clear interrupt flag
	return		; fast return from interrupt

Button_Int_Setup:
	bsf	GIEH
	bsf INT1IP
	bsf INT1IE
	bcf INTEDG1
	bsf	GIE		; Enable all interrupts
	return
Read_input:
    comf PORTE,W
    movwf b_hldr

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
	
Button_Action:
    call b1_Action
    call b2_Action
    call b3_Action
    call b4_Action
    call b5_Action
    call b6_Action
    call b7_Action
    call b8_Action
    return
b1_Action:
    movlw 0 
    cpfsgt b1
    return
    movlw 0x99
    call UART_Transmit_Byte
    movlw 44
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    return
b2_Action:
    movlw 0 
    cpfsgt b2
    return
    movlw 0x99
    call UART_Transmit_Byte
    movlw 45
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    return
b3_Action:
    movlw 0 
    cpfsgt b3
    return
    movlw 0x99
    call UART_Transmit_Byte
    movlw 46
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    return
b4_Action:
    movlw 0 
    cpfsgt b4
    return
    movlw 0x99
    call UART_Transmit_Byte
    movlw 47
    call UART_Transmit_Byte
    movlw 120
    call UART_Transmit_Byte
    return
b5_Action:
    movlw 0 
    cpfsgt b5
    return
    call Record_Beat_Setup
    return
b6_Action:
    movlw 0 
    cpfsgt b6
    return
    call Record_Output_Setup
    return
b7_Action:
    movlw 0 
    cpfsgt b7
    return
    return
b8_Action:
    movlw 0 
    cpfsgt b8
    return
    return
	end

