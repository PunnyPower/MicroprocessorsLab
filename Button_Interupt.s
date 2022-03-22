#include <xc.inc>
global Button_Int_Setup,B_Int_Hi
extrn  UART_Transmit_Byte
extrn  delay_ms

psect	udata_acs   ; reserve data space in access ram

	
	
psect	Button_Interupt_code, class=CODE
	
B_Int_Hi:; load end number into working function	
	;btfss	INT1IF		; check that this is timer0 interrupt
	;retfie	f		; if not then return
	incf PORTD
	movlw 0x99
	call UART_Transmit_Byte
	movlw 0x26
	call UART_Transmit_Byte
	movlw 120
	call UART_Transmit_Byte
	movlw 1000
	call delay_ms
	movlw 0x89
	call UART_Transmit_Byte
	movlw 0x26
	call UART_Transmit_Byte	
	movlw 0x00
	call UART_Transmit_Byte
	
				;read by the other modules 
	bcf	INT1IF		; clear interrupt flag
	retfie	f		; fast return from interrupt

Button_Int_Setup:
	movlw 01001000B
	movwf INTCON3,A 
	movlw 00000000B
	movwf INTCON2,A 
	bsf	GIE		; Enable all interrupts
	return

	end

