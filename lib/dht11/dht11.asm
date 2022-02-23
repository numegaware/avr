; Created by S.Adamovich
; 31 jan 2022

; Датчик температуры и влажности


dht11_get:
	push	r16;

    rcall   makeRequestSignal;
	; // Waiting for an Answer Signal
	pop		r16;
ret;

makeRequestSignal:
	sbi		DDRD, 1;		// порт D пин 1 уст-ся на выход

	; _____                                        .
    ;      |                                       |
    ;      |                                       |
    ;      |_______________________________________|____ ...
    ;
    ; +5V                  18mSec                 20uSec    Answer...

	sbi		PORTD, 1;		// PD1 +5V

	cbi		PORTD, 1; 		// PD1 0V
	ldi		r16, 5;			// 18 mSec	
	rcall	mSecWait;

	sbi		PORTD, 1; 		// PD1 +5V
	ldi		r16, 4;			// 20 uSec
	rcall 	uSecWait;
	
	cbi		DDRD, 1;		// порт D пин 1 уст-ся на вход
	cbi		PORTD, 1; 		// PD1 0V
ret;


;-------Задержка uSec------
; 4: 	21 uSec
;function uSecWait(r16)
uSecWait: 
	push r16;

	uSecWaitLoop:	
		nop;
		nop;
		nop;
		nop;
		nop;
		dec    r16; 	// Понижаем r16 на 1
	brne uSecWaitLoop;

	pop r16;
ret;

;-------Задержка mSec------
; 1: 	3,62(3,64) mSec
; 10:	36,22 mSec;
;function mSecWait(r16)
mSecWait: 
   push r16;
   
	mSecWaitLoop: 
	   ldi    XH, HIGH(FREQ/17777) 	; Засовываем число в старший регистр
	   ldi    XL, LOW(FREQ/17777) 	; Засовываем число в младший регистр
	   rcall  prvt_fourCyclesWaiting;  // Вызываем задержку
	   ldi    XH, HIGH(FREQ/17777) 	; Засовываем число в старший регистр
	   ldi    XL, LOW(FREQ/17777) 	; Засовываем число в младший регистр
	   rcall  prvt_fourCyclesWaiting; 	// Вызываем задержку
	   dec    r16; 					// Понижаем r16 на 1
	brne mSecWaitLoop; 				//Перейти на метку, если не равно 0
	
   pop r16;
ret;

;---------Задержка в 4 цикла-----------
;function prvt_fourCyclesWaiting(X)
prvt_fourCyclesWaiting:
	fourCyclesWaitingLoop:
		sbiw	XH:XL, 1;		// Понижаем регистровую пару на 1
	brne fourCyclesWaitingLoop;	// Переходим если не равно 0
ret;
