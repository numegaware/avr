; Created by S.Adamovich

; Display: lcd1602(04)a
; Controller: hd44780


;movlw       .16               ;сдвиг экрана влево на 16 позиций
;movwf       tmp               ;
;met_1         movlw       b'00011000'       ;команда сдвига экрана влево
;call        lcd_comm          ;вызов подпрограммы передачи команды
;decfsz      tmp,F             ;
;goto        met_1             ;
;ldi r16,0b00011000       ;команда сдвига экрана влево
;di r16,0b00011100       ;команда сдвига экрана вправо
;di r16,0b00001000       ;Команда включения подсветки 3-й бит в 1
;di r16,0b00000000       ;Команда выключения подсветки 3-й бит в 0
;rcall prvt_LCD_Com 
;di r16,0b00000000       ;Команда выключения подсветки 3-й бит в 0
;call prvt_LCD_Com
;b'00001100'       ;включить дисплей, выключить курсор, выключить мигание курсора
;b'00000110'       ;направление движения курсора- вправо (инкремент адреса), запретить сдвиг экрана
;movlw       b'00000001'       ;Передача команды очистки дисплея 00000001
;movlw       b'00001000'       ;выключить дисплей, выключить курсор, выключить мигание курсора                 
;b'00101000'       ; 4-х битный режим, использовать 2 строки дисплея, шрифт 5x8

;ldi		r16, 255; задержку(чтобы не надоедать дисплею)
;rcall	WaitMiliseconds ; 

;// ---------- Diaplay Initialisation Subroutine --------------
initLCDHD44780:
	
	push r16
	push r17
	
	ldi r16, 0xff ; Порт B на выход на всякий случай
	out DDRB, r16 
	
	sbi		LCD_DDR, LCD_D4 ; Говорим всем ногам порта, что они на выход
	sbi		LCD_DDR, LCD_D5
	sbi		LCD_DDR, LCD_D6
	sbi		LCD_DDR, LCD_D7	
	sbi		LCD_DDR, LCD_RS
	sbi		LCD_DDR, LCD_EN
	cbi		LCD_PORT, LCD_RS ; Опрокидываем RS и EN на землю
	cbi		LCD_PORT, LCD_EN
	
	ldi		r16, 100
	rcall	WaitMiliseconds ; Ждем 15-40 мс, чтобы дисплей успел включится от питания
	
	ldi		r17, 3
	InitLoop:
		ldi		r16, 0x03 ; D4 и D5 поднимаем на +5, остальные 0
		rcall	prvt_LCD_WriteNibble ; Отправляем в порт
		ldi		r16, 5
		rcall	WaitMiliseconds
		dec		r17
	brne InitLoop ; Переходим если не равно 0 (Этот кусок надо проделать 3 раза)
	
	ldi		r16, 0x02 ; D5 на +5, остальные 0
	rcall	prvt_LCD_WriteNibble ; Отправляем в порт
	
	ldi		r16, 1
	rcall	WaitMiliseconds ; ждем
	
	
	
	; С данными настройками разбираться по даташиту
	; ( разных конфигурациях...	)
	
	ldi		r16, HD44780_FUNCTION_SET | HD44780_FONT5x7 | HD44780_TWO_LINE | HD44780_4_BIT
	rcall	prvt_LCD_Com;
	
	ldi		r16, HD44780_DISPLAY_ONOFF | HD44780_DISPLAY_OFF;
	rcall	prvt_LCD_Com;
	
	ldi		r16, HD44780_CLEAR;
	rcall	prvt_LCD_Com;
	
	ldi		r16, HD44780_ENTRY_MODE | HD44780_EM_SHIFT_CURSOR | HD44780_EM_INCREMENT
	rcall	prvt_LCD_Com;
	
	ldi		r16, HD44780_DISPLAY_ONOFF | HD44780_DISPLAY_ON | HD44780_CURSOR_OFF | HD44780_CURSOR_NOBLINK
	rcall	prvt_LCD_Com; 
	
	pop r17;
	pop r16;
	
ret;


;/**
;* Set cursor on position
;*
;* @param r16 - line pos (1..4)
;* @param r17 - symb pos (from 1..)
;*
;* 128+0x00  cursor on 1 string , 1 symbol (128+0х01 first.. )
;* 128+0x40  cursor on 2 string , 1 symbol (128+0х41 first.. )
;* 128+0x14  cursor on 3 string , 1 symbol (128+0х15 first.. )
;* 128+0x54  cursor on 4 string , 1 symbol (128+0х55 first.. )
;* 128+0x10  cursor on 3 string , 1 symbol (128+0х10 first.. )(16x4)
;* 128+0x50  cursor on 4 string , 1 symbol (128+0х50 first.. )(16x4)
;*/
setLCDHD44780CursorOn___R16_LineY___R17_PosX:
	push r16
	push r17
	
	isLine1Picked:
		cpi		r16, 1
		brne	isLine2Picked
		ldi		r16, (128+0x00)
	rjmp breackAndSetLCDCursorOnPos
	
	isLine2Picked:
		cpi r16, 2
		brne isLine3Picked
		ldi r16, (128+0x40)
	rjmp breackAndSetLCDCursorOnPos
	
	isLine3Picked:
		cpi r16, 3
		brne isLine4Picked
		ldi r16, (128+0x14)
	rjmp breackAndSetLCDCursorOnPos
	
	isLine4Picked:
		cpi r16, 4
		brne notPickedAtAll
		ldi r16, (128+0x54)
	rjmp breackAndSetLCDCursorOnPos
	
	
	breackAndSetLCDCursorOnPos:
		dec r17
		add r16, r17
		rcall prvt_LCD_Com
	
	notPickedAtAll:
	
	pop r17
	pop r16
ret


;/**-----Print data on an HD44780 screen (symbols)-----
;*
;* can be use one after another!
;* @param r16 is an ASCII symbol (0x33 for example)
;*
;*/
setInLCDHD44780___R16_AsciiSymbol:
	push r16
	
	sbi		LCD_PORT, LCD_RS 	; Поднимаем RS на +5
	
	rcall 	prvt_LCD_write;
	
	clr		XH 					; Чистим XH
	ldi		XL, LOW(FREQ/80000) ; А сюда расчитанное число
	rcall	Wait4xCycles 		; Вызываем задержку
	
	pop r16
ret


;** Clear a Display, Set a Cursor's Position and so on.
;*
;* @param r16
;* @return void
prvt_LCD_Com:
	push r16
	
	cbi		LCD_PORT, LCD_RS;	// Опрокидываем RS на землю
	
	rcall	prvt_LCD_write;
	
	ldi		r16, 4;
	rcall	WaitMiliseconds;	// задерживаем
	
	pop r16
ret


prvt_LCD_write:
	push r16
	
	push	r16;					// r16 вставляем в стек
	swap	r16;					// Меняем тетрады r16
	rcall	prvt_LCD_WriteNibble;	// записываем
	pop		r16;					// Достаем r16 из стека
	rcall	prvt_LCD_WriteNibble;	// записываем	
	
	pop r16
ret


;----------- дергаем ноги порта - производим запись -------------
prvt_LCD_WriteNibble:
	push r16;
	
	sbi		LCD_PORT, LCD_EN; // Устанавливаем EN на +5V
	
	sbrs	r16, 0;
	cbi		LCD_PORT, LCD_D4;
	sbrc	r16, 0;
	sbi		LCD_PORT, LCD_D4;	
	sbrs	r16, 1;
	cbi		LCD_PORT, LCD_D5;
	sbrc	r16, 1;
	sbi		LCD_PORT, LCD_D5;	
	sbrs	r16, 2;
	cbi		LCD_PORT, LCD_D6;
	sbrc	r16, 2;
	sbi		LCD_PORT, LCD_D6;	
	sbrs	r16, 3;
	cbi		LCD_PORT, LCD_D7;
	sbrc	r16, 3;
	sbi		LCD_PORT, LCD_D7;
	
	cbi		LCD_PORT, LCD_EN; Устанавливаем EN на 0V
	
	pop r16;
ret;


;-------Задержка------
 WaitMiliseconds: 
   push r16;
   
	WaitMsLoop: 
	   ldi    XH, HIGH(FREQ/17777) 	; Засовываем число в старший регистр
	   ldi    XL, LOW(FREQ/17777) 	; Засовываем число в младший регистр
	   rcall  Wait4xCycles 			; Вызываем задержку
	   ldi    XH, HIGH(FREQ/17777) 	; Засовываем число в старший регистр
	   ldi    XL, LOW(FREQ/17777) 	; Засовываем число в младший регистр
	   rcall  Wait4xCycles 			; Вызываем задержку
	   dec    r16 					; Понижаем r16 на 1
	brne WaitMsLoop 				; Перейти на метку, если не равно 0
	
   pop r16;
ret;

;---------Задержка в 4 цикла----------------------------------------------
Wait4xCycles:
	Wait4xCyclesLoop:
		sbiw	XH:XL, 1;		// Понижаем регистровую пару на 1
	brne Wait4xCyclesLoop;		// Переходим если не равно 0
ret;
