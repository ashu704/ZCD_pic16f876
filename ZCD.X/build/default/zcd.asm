    LIST p = 16F876  
    #include p16f876.inc
    __CONFIG _FOSC_XT & _WDTE_ON & _PWRTE_OFF & _CP_OFF & _BOREN_ON & _LVP_ON & _CPD_OFF & _WRT_ON

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

MAIN_PROG CODE                      ; let linker place main program

START	    BSF		STATUS,	    RP0		    ; Bank 1
	    MOVLW	0x03			    ; 0b00000011
	    MOVWF	TRISA			    ; Set RA0,1 as i/p
	    MOVLW	0x0000			    ;
	    MOVWF	TRISB			    ; Set PORTB as o/p
	    MOVLW	0x0000			    ;
	    MOVWF	TRISC			    ; Set PORTB as o/p
	    MOVLW	0x0E			    ; 0b00001110
	    MOVWF	ADCON1			    ; Left justified, RA0(analog) RA1(digital)	     
	    BCF		STATUS,	    RP0		    ; Bank 0
	    BSF		ADCON0,	    ADON	    ; A/D converter module is operating, AN0 is chose by default
	    BSF		STATUS,	    RP0		    ; Bank 1
	    MOVLW	0x14			    ;
	    MOVWF	PR2			    ; TMR2 Delay 20 us 
	    BCF		STATUS,	    RP0		    ; Bank 0	    
TMRSTART    COMF	PORTC
	    BSF		T2CON,	    TMR2ON	    ; Start TMR2	    
LOOP 	    BTFSS	PIR1,	    TMR2IF	    ; Wait for TMR2 == PR2
	    GOTO	LOOP			    ;
	    BCF		PIR1,	    TMR2IF	    ; Clear Interrupt flag
	    BSF		ADCON0,	    GO_DONE	    ; Start A/D conversion	    
ADC_PARSE   BTFSS	PIR1,	    ADIF	    ; Wait for A/D conversion
	    GOTO	ADC_PARSE		    ;
	    BCF		PIR1,	    ADIF	    ; Clear Interrupt flag
	    MOVF	ADRESH,	    0		    ;
	    BTFSS	PORTA,	    1		    ; RA1 tells if user wants 2.5V or 0V reference
	    GOTO	DIGITAL	
	    ANDLW	0xF8			    ; Masking most significant 7 bits of Wreg 
	    XORLW	0x80			    ; W xor 0b10000000
DIGITAL	    BTFSC	STATUS,	    Z		    ; skip if Z == 0
	    GOTO	PULLUP			    ; 
	    BCF		PORTB,	    RB0		    ; set RB0 as low
	    GOTO	TMRSTART		    ;	    	    
PULLUP	    BSF		PORTB,	    RB0		    ;
	    GOTO	TMRSTART		    ;

	    END
	    