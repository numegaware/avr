;
; 		DISPLAY hd44780
;
; Created: 24.09.2019 11:57:35
; Author : S.Adamovich 
; 
; Version 1



;==========		DEFINES =======================================
	.include "../avr_modules/Appnotes/m8def.inc";		m8def 	 m16def	  m168def
	.include "../avr_modules/lib/hd44780/hd44780def.inc";
	.DEF sys			=r20;
	.DEF Cycles_Counter	=R21; счетчик циклов в Expect_X
	.DEF ERR_CODE		=R22; возврат ошибок из подпрограмм
	.DEF ACCUM			=R24
;==========		END DEFINES =======================================	

.DSEG;	// Сегмент Данных


.cseg; Программный сегмент
.org 0; Начало программного сегмента
rjmp Reset; Перескакиваем на Reset

;==========		LIBS ===============================================; 
.include "../avr_modules/lib/hd44780/hd44780lib.asm"
;==========		END LIBS ===========================================;


Reset:
	ldi		r16, high(ramend);	// инициализация стека
	out		sph, r16;
	ldi		r16, low(ramend);
	out		spl, r16;
	
	CLI;						// прерывания не нужны
	
	rcall	getDataFromDHT11;			// Данные из DHT11
	
	rcall	initLCDHD44780;			// Вызываем Инициализацию дисплея
	rcall	setLCDHD44780Strings;
	rcall	clearSys;
rcall mainLoop;

mainLoop:
	rcall	updateLCDData;	
rjmp mainLoop;



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

getDataFromDHT11:
	push	r16;

	sbi		DDRD, 1;		// порт D пин 1 уст-ся на выход

	; // START 
	sbi		PORTD, 1;		// PD1 +5V

	cbi		PORTD, 1; 		// PD1 0V
	ldi		r16, 5;			// 18 mSec	
	rcall	mSecWait;

	sbi		PORTD, 1; 		// PD1 +5V
	ldi		r16, 4;			// 20 uSec
	rcall 	uSecWait;
	
	cbi		DDRD, 1;		// порт D пин 1 уст-ся на вход
	cbi		PORTD, 1; 		// PD1 0V

	; // Waiting for Signal
	pop		r16;
ret;

setLCDHD44780Strings:
	push	r16;
	push	r17;

	ldi		r16, 1;				// Линия 1
	ldi		r17, 1;				// Позиция 1
	rcall	setLCDHD44780CursorOn___R16_LineY___R17_PosX; // set_lcd_cursor_on_pos
	ldi		r16, 'h'
	rcall	setInLCDHD44780___R16_AsciiSymbol; // print_ASCII_symbol_to_LCD
	ldi		r16, 'u'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'm'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'i'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'd'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'i'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 't'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'y'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, ':'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	
	ldi		r16, 2;	// Линия 2
	ldi		r17, 1;	// Позиция 1
	rcall	setLCDHD44780CursorOn___R16_LineY___R17_PosX; // set_lcd_cursor_on_pos
	ldi		r16, 't'
	rcall	setInLCDHD44780___R16_AsciiSymbol; // print_ASCII_symbol_to_LCD
	ldi		r16, 'e'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'm'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'p'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'e'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'r'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'a'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 't'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'u'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'r'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, 'e'
	rcall	setInLCDHD44780___R16_AsciiSymbol
	ldi		r16, ':'
	rcall	setInLCDHD44780___R16_AsciiSymbol

	pop		r17;
	pop		r16;
ret;

addSys:
	inc		sys; Увеличиваем цифру на 1

	; //  isSysOutOfBound()
	cpi		sys, 0x3A;
	breq	clearSys;
ret

clearSys:
	ldi		sys, 0x30; 0x30 Соответствует цифре 0 в ASCII
ret

updateLCDData:
	push	r16
	push	r17

	ldi		r16, 1;		// line
	ldi		r17, 11;	// pos
	rcall	setLCDHD44780CursorOn___R16_LineY___R17_PosX
	
	mov		r16, sys; Копируем регистр sys, т.к. там наши цифры хранятся
	rcall	setInLCDHD44780___R16_AsciiSymbol ; Посылаем данные

	ldi		r16, 2;		// line
	ldi		r17, 14;	// pos
	rcall	setLCDHD44780CursorOn___R16_LineY___R17_PosX

	mov		r16, sys
	rcall	setInLCDHD44780___R16_AsciiSymbol
	
	ldi		r16, 255; задержку(чтобы не надоедать дисплею)
	rcall	WaitMiliseconds;

	rcall	addSys; Увеличиваем цифру на 1 (Для наглядности), ниже аналогично
	
	pop		r17;
	pop		r16;
ret;

; // ret r16, r17
getHDigit:
	; // вычитать 1010 и подсчитывать количество вычитаний
	clr		r17;
	getHDigitLoop:
		inc		r17;
		subi	r16, 0b00001010;
		cpi		r16, 0b00000000;
	brne	getHDigitLoop;
ret;



;============	EXPECT 1->0 FALLING EDGE - START DHT11 RESPONSE ==========================
EXPECT_FROM1TO0:
	push r16

	WLOW1:
		;IN r16, DHT_InPort	; читаем порт D, ждем low
		;SBRC r16, DHT_Pin	; если 1 то крутимся на WLOW, если ноль, то пошла передача.
	RJMP WLOW1;
		
	NOP; Типа здесь старт передачи (подтвержение контроллера) - потупим пару тактов
	NOP
	NOP
	;RCALL DELAY_10US		; ждем 10 микросекунд и выходим

	pop r16
RET
