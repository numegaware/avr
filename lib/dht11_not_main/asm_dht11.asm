.device ATMega16
.include "m16def.inc"
.org 0x00 
ldi r16, low (ramend)
out SPL, r16
ldi r16, high (ramend)
out SPH, r16
.cseg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;настройка портов
ldi r16,0b11111111
out ddrb,r16
nop
ldi r16,0b00000111
out ddrd,r16
nop
ldi r16,0b00000001
sbi porta,0
out ddra,r16
nop
;/Инициализация дисплея;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;0,5
call time
call time
;/2;;;;;;;;;;;;;;;;;;;;;;;;;вывод в контрллер
ldi r17, 0b00110000
ldi r18, 0b00000000
call strob
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4,1мс
ldi r16,0b00000101
out tccr0,r16; упр модулем таймера 
ldi r17,224
out tcnt0,r17 ; счетный рег
four: 
in r18,tifr
sbrs r18,tov0
jmp four
ldi r16, 0b00000000
out tccr0, r16
ldi r17, 0000000001
out tifr,r17
;;;;;;;;;;;;;;;;;;;;;;/4;;;;;;;;;;;;;;;;;;;;;;;;;;
ldi r17, 0b00110000
ldi r18, 0b00000000
call strob
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;100мкс
call z50
call z50
;;;;;;;;;;;;;;;;;;;;;;/6;;;;;;;;;;;;;;;;;;;;;;;;;/
ldi r17, 0b00110000
ldi r18, 0b00000000
call strob
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;/200
call z50
call z50
call z50
call z50
;;;;;;;;;;;;;;;;;;;;;;;;8;;;;;;;;;;;;;;;;;;;;;;;;;/
ldi r17, 0b00111100
ldi r18, 0b00000000
call strob
;;;;;;;;;;;;;;;;;;;;;;;;;;200;;;;;;;;;;;;;;;;;;;;;;;;;;
call z50
call z50
call z50
call z50
;;;;;;;;;;;;;;;;;;;;;;;;;;;/10;;;;;;;;;;;;;;;;;;;;;;;;;/
ldi r17, 0b00001110
ldi r18, 0b00000000
call strob
;;;;;;;;;;;;;;;;;;;200;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
call z50 
call z50
call z50 
call z50 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;12;;;;;;;;;;;;;;;;;;;;;;;;;/
ldi r17, 0b00000110
ldi r18, 0b00000000
call strob
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;/
ldi r25,0x80
ldi r26,0xc0
redr:
ldi r18, 0b00000100
mov r17,r25
call strob
call z50
ldi r18, 0b00000000
call strob
ldi r16,0b00000001
out tccr0,r16; упр модулем таймера 
ldi r17,0
out tcnt0,r17 ; счетный рег
f51: in r18,tifr
sbrs r18,tov0
jmp f51
ldi r16, 0b00000000
out tccr0, r16
ldi r17, 0000000001
out tifr,r17
 ldi r18, 0b00000101
 call strob 
 call z50
 ;;;;;;;;;;;;;;;;;;;;;;;;/учтановка кода символа;;;;;;;;; 
jmp DHT11
;;;;;;;;;;;;;;;;;;;;;;;;;50mks;;;;;;;;;;;;;;;;;;;;;;;
z50: ldi r16,0b00000001
out tccr0,r16; упр модулем таймера 
ldi r17,200
out tcnt0,r17 ; счетный рег
f50: in r18,tifr
sbrs r18,tov0
jmp f50
ldi r16, 0b00000000
out tccr0, r16
ldi r17, 0000000001
out tifr,r17
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;strob;;;;;;;;;;;;;;;;
strob: 
out portb,r17
out portd,r18
sbi portd, 2
nop
cbi portd, 2
nop
ret
DHT11:
prov:
cbi porta,0; уст  в 0
call time; сигнал старт 
sbi porta,0; уст в 1
ldi r16,0b00000000
out ddra,r16
call timer; ждем ответ от датчика сигнал "готовься к перадче" 
chek:
clr r17
clr r16
sbis pina,0;проверка закончился сигнал "готовься к передаче" или нет
jmp rep; да в таймер подсчета 50мкс   
jmp chek;иначе продолжаем ждать 
rep:
nop
nop
nop
sbis pina,0
jmp rep
shet:
nop
nop
nop 
inc r16
sbic pina,0
jmp shet
nop
nop
cpi r16,5
brlo zer
ori r25,1
zer: 
clr r16
inc r17
cpi r17,8
breq next
lsl r25
jmp rep
next:
clr r17 
clr r16
rep2:
nop
sbis pina,0
jmp rep2
shet2:
nop
inc r16
sbic pina,0
jmp shet2
nop    
cpi r16,5
brlo zer2
ori r24,1
zer2: 
clr r16
inc r17
cpi r17,8
breq next2
lsl r24
jmp rep2
next2: 
clr r17 
clr r16
rep3:
nop
sbis pina,0
jmp rep3
shet3:
nop 
inc r16
sbic pina,0
jmp shet3
nop
cpi r16,5
brlo zer3
ori r23,1
zer3: 
clr r16
inc r17
cpi r17,8
breq next3
lsl r23
jmp rep3
next3:
clr r17 
clr r16
rep4:
nop
sbis pina,0
jmp rep4
shet4:
nop
nop
inc r16
sbic pina,0
jmp shet4
cpi r16,5
brlo zer4
ori r22,1
zer4: 
clr r16
inc r17
cpi r17,8
breq next4
lsl r22
jmp rep4
next4:
clr r17 
clr r16
rep5:
nop
sbis pina,0
jmp rep5
shet5:
nop
inc r16
sbic pina,0
jmp shet5
cpi r16,5
brlo zer5
ori r21,1
zer5: 
clr r16
inc r17
cpi r17,8
breq preobr
lsl r21
jmp rep5
preobr:
CLR R28
CLR R29
.def RR3=r26
.def RR4=r27
.def RR1=r25
.def RR2=r24
.def RR31=r28
.def RR41=r29
.def RR11=r23
.def RR21=r22
LDI R21,0
AGAIN1:
lsl RR31
sbrc RR41,7
ORi RR31,1
lsl RR41
sbrc RR11,7
ORI RR41,1
lsl RR11
sbrc RR21,7
ORi RR11,1
lsl RR21
INC R21
CPI R21,16
BREQ ascii
;/пРОВЕРКА rr4;/
mov r20,RR41;проверка есть ли пять в младшем полубайте 
andi r20,0b00001111;1
LDI R19,3
cpi r20,5;сравнение с 5
BRLO PROVSTAR1
ADD R20,R19;Прибавить 3
;Проверить старший полубайт
PROVSTAR1: 
andi RR41,0b11110000;2
or RR41,R20
MOV R20,RR41;r5 <-r4
SWAP R20
ANDI R20,0B00001111;3
cpi r20,5;сравнение с 5
BRLO NEXT1
ADD R20,R19
NEXT1:
ANDI RR41,0B00001111;4
SWAP R20
OR RR41,R20
MOV R20,RR31
ANDI R20,0B00001111;5
CPI R20,5
BRLO NEXT21
ADD R20,R19
NEXT21: 
ANDI RR31,0B11110000;6
OR RR31,R20
MOV R20,RR31
SWAP R20
ANDI R20,0B00001111
CPI R20,5
BRLO NEXT31
ADD R20,R19
NEXT31:
ANDI RR31,0B00001111
SWAP R20
OR RR31,R20
jmp AGAIN1
time:
ldi r16,0b00000101
out tccr0,r16; упр модулем таймера 
ldi r17,238 ;18 ms
out tcnt0,r17 ; счетный рег
f35: in r18,tifr
sbrs r18,tov0
jmp f35
ldi r16, 0b00000000
out tccr0, r16
ldi r17, 0000000001
out tifr,r17
ret
timer:
ldi r16,110
out tcnt0,r16 ; счетный рег
ldi r16,0b00000001
out tccr0,r16; упр модулем таймера
k5: in r18,tifr
sbrs r18,tov0
jmp k5
ldi r16, 0b00000000
out tccr0, r16
ldi r16, 0000000001
out tifr,r16
ret
ascii:
call strob
call timer 
ldi r18, 0b00000100
ldi r17,0x80
call strob
call z50
ldi r17,0
ldi r18, 0b00000000
call z50
call z50
call strob
ldi r16,0b00000001
out tccr0,r16 
ldi r17,0
out tcnt0,r17 
f52: in r18,tifr
sbrs r18,tov0
jmp f52
ldi r16, 0b00000000
out tccr0, r16
ldi r17, 0000000001
out tifr,r17
ldi r18, 0b00000101
call strob 
call z50
;;/Вывод на экран...
LDI r17,0x54
call strob 
call timer 
ldi r17,0x45 
call strob 
call timer 
ldi r17,0x4d
call strob
call timer 
ldi r17,0x50 
call strob 
call timer 
ldi r17,0x45 
call strob 
call timer 
ldi r17,0x52 
call strob 
call timer 
ldi r17,0x41 
call strob 
call timer 
ldi r17,0x54 
call strob 
call timer 
ldi r17,0x55 
call strob 
call timer 
ldi r17,0x52 
call strob 
call timer 
ldi r17,0x41 
call strob 
call timer 
ldi r18, 0b00000100
ldi r17,0xc0
call strob
call z50
ldi r17,0x20 
call strob 
call timer
ldi r17,0x20 
call strob 
call timer
ldi r17,0x20 
call strob 
call timer
ldi r17,0x20 
call strob 
call timer
ldi r17,0x20 
call strob 
call timer
mov r17,RR31
andi r17,0b11110000
swap r17 
ldi r30,0x30 
add r17,r30 
cpi r17,0x30
breq l
call strob
l:call timer
mov r17,RR31
andi r17,0b00001111
ldi r30,0x30
add r17,r30 
cpi r17,0x30
breq lk
call strob
lk: call timer
mov r17,RR41
andi r17,0b11110000
swap r17 
ldi r30,0x30 
add r17,r30 
call strob
call timer
ldi r17, 0xdf
call strob
call timer 
ldi r17,0x43
call strob
call timer
call time 
call time
clr r26
clr r27
clr r28 
clr r29
clr r25
clr r24
clr r23
clr r22
clr r21
clr r20
clr r19 
clr r17
clr r16
clr r18
jmp DHT11