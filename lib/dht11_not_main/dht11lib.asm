
;==========		SUBROUTINES =======================

			




;============	DHD11 INIT =======================================
; после инициализации сразу !!!! надо считать ответ контроллера и собственно данные
DHT_INIT:
	push r16
		CLI	; еще раз, на всякий случай - критичная ко времени секция

		; сохранили X для использования в READ_CYCLES - там нет времени инициализировать
		LDI XH, High(CYCLES)	; загрузили старший байт адреса Cycles
		LDI XL, Low (CYCLES)	; загрузили младший байт адреса Cycles


		LDI r16, (1<<DHT_Direction_Pin)
		OUT DHT_Direction, r16			; порт D, Пин 2 на выход

		LDI r16, (0<<DHT_Pin)
		OUT DHT_Port, r16			; выставили 0 

		;ldi		r16, 20
		;rcall	WaitMiliseconds ;
		
		rcall delay10mcs_16MHz;
		rcall delay10mcs_16MHz;
		;RCALL DELAY_20MS		; ждем 20 миллисекунд

		LDI r16, (1<<DHT_Pin)		; освободили линию - выставили 1
		OUT DHT_Port, r16	

		rcall delay10mcs_16MHz;
		;RCALL DELAY_10US		; ждем 10 микросекунд
	
		LDI r16, (0<<DHT_Direction_Pin)		; порт D, Pin 2 на вход
		OUT DHT_Direction, r16	
		LDI r16,(1<<DHT_Pin)		; подтянули pull-up вход на вместе с внешним резистором на линии
		OUT DHT_Port, r16		


		; ждем ответа от сенсора - он должен положить линию в ноль на 80 us и отпустить на 80 us
		; если не происходит - выходим по ошибке или о тайм ауту с ошибкой - нет ответа от сенсора. TODO - сделать
		; потом по переходу с единицы на ноль читаем 40 бит подряд для этого 
		; ждем falling edge с 1 на 0, после этого:
		; Expect_1 (мы в нуле) И начинанаем считать такты до обратного перехода в 1 - первые пол бита - всегда около 50 us
		; Expect_0 (мы в единице) Потом начинанаем считать такты до перехода в ноль - вторые полбита

		RCALL EXPECT_FROM1TO0
		RCALL EXPECT_1		; Открутился 0
		; Здесь надо бы Сохранить число циклов  - первый ответ контроллера			
		RCALL EXPECT_FROM1TO0	; и здесь тоже - второй полу ответ контролера			
		; Здесь старт передачи битов переходим на чтение битов
	pop r16
RET



;============== READ CYCLES ====================================
; читаем биты контроллера и сохраняем в Cycles 
READ_CYCLES:
	push r16	
		LDI r16, 80			; читаем 80 циклов
		READ:	
			RCALL EXPECT_1				; Открутился 0
			ST X+, Cycles_Counter		; Сохранили число циклов 
		
			RCALL EXPECT_0
			ST X+, Cycles_Counter		; Сохранили число циклов 

			DEC r16				; уменьшили счетчик
		BRNE READ					
	pop r16	
RET							; все циклы считали





;========		COPY STRINGS TO RAM ==================================
; копируем строки из флеша в RAM
COPY_STRINGS:
	push r16
	push r17
		LDI ZH, HIGH(TEMPER*2)
		LDI ZL, LOW(TEMPER*2)
		LDI XH, HIGH(TEMPER_D)
		LDI XL, LOW(TEMPER_D)
			
		LDI r16, 14		; для 14 байт
		CP_L1:			
			LPM r17, Z+		; из Z 
			ST X+, r17			; в X
			DEC r16
		BRNE CP_L1
		NOP

		LDI ZH, HIGH(HUMID*2)
		LDI ZL, LOW(HUMID*2)
		LDI XH, HIGH(HUMID_D)
		LDI XL, LOW(HUMID_D)
		
		LDI r16, 14		; для 14 байт
		CP_L2:			
			LPM r17, Z+
			ST X+, r17
			DEC r16
		BRNE CP_L2
		NOP
	pop r17
	pop r16
RET




;=============	CREATE TEST DATA ===================================
; создаем dummy данные для тестового вывода
TEST_DATA:		
	push r16
		LDI XH, HIGH(TEMPER_ASCII)
		LDI XL, LOW(TEMPER_ASCII)
		LDI r16, '6'
		ST X+, r16
		LDI r16, '7'
		ST X+, r16
		LDI r16, '.'
		ST X+, r16
		LDI r16, '5'
		ST X+, r16
		LDI r16, '1'
		ST X+, r16

		LDI XH, HIGH(HUMID_ASCII)
		LDI XL, LOW(HUMID_ASCII)
		LDI r16, '8'
		ST X+, r16
		LDI r16, '5'
		ST X+, r16
		LDI r16, '.'
		ST X+, r16
		LDI r16, '4'
		ST X+, r16
		LDI r16, '7'
		ST X+, r16
	pop r16
RET




;=============	EXPECT 1 =========================================
; крутимся в цикле ждем нужного состояния на пине
; когда появилось - выходим
; сообщаем сколько циклов ждали
; или сообщение об ошибке тайм оута если не дождались
EXPECT_1:
	push r16
	push r17
		LDI Cycles_Counter, 0	; загрузили счетчик циклов
		LDI ERR_CODE, 2			; Ошибка 2 - выход по тайм Out

		ldi  r16, 2			; Загрузили 
		ldi  r17, 169			; задержку 80 us

	EXP1L1:			
		INC Cycles_Counter		; увеличили счетчик циклов

		IN r18, DHT_InPort		; читаем порт
		SBRC r18, DHT_Pin		; Если уже 1 
		RJMP EXIT_EXPECT_1		; То выходим
		dec  r17				; если нет то крутимся в задержке
		brne EXP1L1
		dec  r16
		brne EXP1L1
									; Здесь выход по тайм out
	pop r17
	pop r16
RET



EXIT_EXPECT_1:	
	LDI ERR_CODE, 1				; ошибка 1, все нормально, в Cycles_Counter счетчик циклов
RET






;==============	EXPECT 0 =========================================
; крутимся в цикле ждем нужного состояния на пине
; когда появилось - выходим
; сообщаем сколько циклов ждали
; или сообщение об ошибке тайм оута если не дождались
EXPECT_0:
	push r16
	push r17
	push r18

	LDI Cycles_Counter, 0			; загрузили счетчик циклов
	LDI ERR_CODE, 2			; Ошибка 2 - выход по тайм Out

	ldi  r16, 2			; Загрузили 
	ldi  r17, 169			; задержку 80 us

	EXP0L1:			
		INC Cycles_Counter				; увеличили счетчик циклов

		IN r18, DHT_InPort		; читаем порт
		SBRS r18, DHT_Pin		; Если 0 
		RJMP EXIT_EXPECT_0		; То выходим
		dec  r17
		brne EXP0L1
		dec  r16
		brne EXP0L1
		NOP					; Здесь выход по тайм out
	pop r18
	pop r17
	pop r16
RET



EXIT_EXPECT_0:	
	LDI ERR_CODE, 1			; ошибка 1, все нормально, в Cycles_Counter сколько циклов насчитали
RET




;============	EXPECT 1->0 FALLING EDGE - START DHT11 RESPONSE ==========================
EXPECT_FROM1TO0:
	push r16

	WLOW1:			
		IN r16, DHT_InPort	; читаем порт D, ждем low
		SBRC r16, DHT_Pin	; если 1 то крутимся на WLOW, если ноль, то пошла передача.
	RJMP WLOW1;
		
	NOP; Типа здесь старт передачи (подтвержение контроллера) - потупим пару тактов
	NOP
	NOP
	;RCALL DELAY_10US		; ждем 10 микросекунд и выходим

	pop r16
RET






;=============	GET BITS ===============================================
; Из Cycles делаем байты в  BITS				
GET_BITS:
	push r16
	push r17
	push r18
	push r19

	LDI r16, 5			; для пяти байт - готовим счетчики
	LDI r17, 8			; для каждого бита
	LDI ZH, High(CYCLES)	; загрузили старший байт адреса Cycles
	LDI ZL, Low (CYCLES)	; загрузили младший байт адреса Cycles
	LDI YH, High(BITS)	; загрузили старший байт адреса BITS
	LDI YL, Low (BITS)	; загрузили младший байт адреса BITS

	ACC:			
		LDI r24, 0			; акамулятор инициализировали
		LDI r17, 8			; для каждого бита

		TO_ACC:			
			LSL r24				; сдвинули влево
			LD r18, Z+			    ; считали данные [i]
			LD r19, Z+			    ; о циклах и [i+1]
			CP r18, r19			; сравнить первые пол бита с второй половину бита если положительно - то BITS=0, если отрицительно то BITS=1
			BRPL J_SHIFT		    ; если положительно (0) то просто сдвиг	
			ORI r24, 1			; если отрицательно (1) то добавили 1
		
			J_SHIFT:		
			DEC r17				; повторить для 8 бит
		BRNE TO_ACC;

		ST Y+, r24			; сохранили акамулятор
		DEC r16				; для пяти байт
	
	BRNE ACC

	pop r19
	pop r18
	pop r17
	pop r16
RET




;============	GET HnT DATA =========================================
; из BITS вытаскиваем цифры H10...
; чуть хакнули, потому что H10 и дальше лежат последовательно в памяти
GET_HnT_DATA:
	push r16
		NOP
		LDI ZH, HIGH(BITS)
		LDI ZL, LOW(BITS)
		LDI XH, HIGH(H10)
		LDI XL, LOW(H10)
										; TODO - перевести на счетчик таки
		LD r16, Z+			; Считали
		ST X+, r16			; сохранили
		LD r16, Z+			; Считали
		ST X+, r16			; сохранили
		LD r16, Z+			; Считали
		ST X+, r16			; сохранили
		LD r16, Z+			; Считали
		ST X+, r16			; сохранили
	pop r16
RET





;=============	CREATE ASCII DATA with ITOA
HnT_ASCII_DATA_EX:
	push r16
		NOP

		LDI XH, HIGH(TEMPER_ASCII)
		LDI XL, LOW(TEMPER_ASCII)
		
		LDI YH, HIGH(T10)
		LDI YL, LOW(T10) 

		LD r16, Y
		RCALL ITOA_99

		LDI R24, '.'	
		ST X+, R24			; saved  '.' TODO - rebuild with Tmp4

		LDS R24, T01
		;INC R24				; тестовое увеличение дробной части +.01
		STS T01, R24


		LDI YH, HIGH(T01)
		LDI YL, LOW(T01) 

		LD r16, Y
		RCALL ITOA_99
		
		; the same for humid
		LDI XH, HIGH(HUMID_ASCII)
		LDI XL, LOW(HUMID_ASCII)
		
		LDI YH, HIGH(H10)
		LDI YL, LOW(H10) 

		LD r16, Y
		RCALL ITOA_99

		LDI R24, '.'	
		ST X+, R24			; saved  '.' TODO - rebuild with Tmp4

		LDS R24, H01
		;INC R24				; тестовое увеличение дробной части +.01
		STS H01, R24

		LDI YH, HIGH(H01)
		LDI YL, LOW(H01) 

		LD r16, Y
		RCALL ITOA_99
	pop r16
RET




;=============	CONVERT DEC to ASCII ==============================
; convert DEC stored in r16 to CHAR stored in r17 DEC is 0<=DEC<=99 
ITOA_99:
	push r16
	push r17
	push r18	
		NOP
		;LDS r16, T10		
		LDI ZL, LOW (DECTAB*2)
		LDI ZH, HIGH  (DECTAB*2)

		ITOA_NEXT:		
			LDI r17, '0'-1
			LPM r18, z+		; загружаем вычитатели 10, 1 ...
							
			ITOA_NUM:		
				INC r17		
				SUB r16, r18				
			BRSH ITOA_NUM

			ADD r16, r18
			ST X+, r17

			CPI r18, 1
		BRNE ITOA_NEXT
	pop r18
	pop r17
	pop r16
RET


;=============	DELAY 1200 mil sec ================================
; Delay 19 199 999 cycles
; 1s 199ms 999us 937 1/2 ns
; at 16.0 MHz
DELAY_1200MS:
	push r16
	push r17
	push r18
		NOP
		ldi  r16, 98
		ldi  r17, 103
		ldi  r18, 206
	DL1:			
		dec  r18
		brne DL1
		dec  r17
		brne DL1
		dec  r16
		brne DL1
		nop
	pop r18
	pop r17
	pop r16
RET


;=================================
; Delay 20 ms
; Delay 320 000 cycles
; 20ms at 16 MHz
DELAY_20MS:
	push r16
	push r17
	push r18
		ldi  r16, 2
		ldi  r17, 160
		ldi  r18, 147
	L20MS1:			dec  r18
		brne L20MS1
		dec  r17
		brne L20MS1
		dec  r16
		brne L20MS1
		nop
	pop r18
	pop r17
	pop r16
RET



;==================================
; Delay 160 cycles
; 10us at 16.0 MHz
DELAY_10US:
	push r16		
		ldi  r16, 53
		L10MS1:			
			dec  r16
		brne L10MS1
		nop
	pop r16
RET

; Задержка 6 mcs
delay6mcs_16MHz: 
	ldi XH, high(FREQ/1500000)
	ldi XL, low(FREQ/1500000)
	rcall doDelay_16MHz
ret

; Задержка 9 mcs
delay9mcs_16MHz: 
	ldi XH, high(FREQ/600000)
	ldi XL, low(FREQ/600000)
	rcall doDelay_16MHz
ret

; Задержка 10 mcs
delay10mcs_16MHz: 
	ldi XH, high(FREQ/600000)
	ldi XL, low(FREQ/600000)
	rcall doDelay_16MHz
ret

; Задержка 55 mcs
delay55mcs_16MHz: 
	ldi XH, high(FREQ/76000)
	ldi XL, low(FREQ/76000)
	rcall doDelay_16MHz
ret

; Задержка 60 mcs
delay60mcs_16MHz: 
	ldi XH, high(FREQ/70000)
	ldi XL, low(FREQ/70000)
	rcall doDelay_16MHz
ret

; Задержка 64 mcs
delay64mcs_16MHz:
	ldi XH, high(FREQ/65000)
	ldi XL, low(FREQ/65000)
	rcall doDelay_16MHz
ret

; Задержка 70 mcs
delay70mcs_16MHz: 
	ldi XH, high(FREQ/58000)
	ldi XL, low(FREQ/58000)
	rcall doDelay_16MHz
ret

delay410mcs_16MHz: ; Задержка 410 mcs
	ldi XH, high(FREQ/9756)
	ldi XL, low(FREQ/9756)
	rcall doDelay_16MHz
ret

delay480mcs_16MHz: ; Задержка 480 mcs
	ldi XH, high(FREQ/8332)
	ldi XL, low(FREQ/8332)
	rcall doDelay_16MHz
ret

doDelay_16MHz: ; Подпрограмма воспроизведения задержки
	sbiw XH:XL, 1 ; Вычитаем единицу из регистровой пары
	brne doDelay_16MHz ; Если не равно 0 крутимся в цикле
ret
;========		SUBS END ==========================================
