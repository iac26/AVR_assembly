;btn.asm
;author: Iacopo Sprenger
;simple button control for atmega 328p 
;and blinker also
;should be sort of debounced
;connect led between pb2 (d10) and gnd
;connect btn between pd2 (int0) (d2) and gnd



.nolist
.include "../include/m328Pdef.inc"
.list

.org 	0x0000
	rjmp 	reset
.org	0x0002
	rjmp 	int0_h
.org	0x0020
	rjmp	overflow0_h
.org 	0x001a
	rjmp	overflow1_h
.org 	0x34

; r16 is a tmp register
; r20 is the led state register
; r18 is the blinker state register



reset:
	ldi	r16, 0b00100100
	out 	DDRB, r16		;output for pb2 & pb5
	sbi	PortB, 2		;HIGH for pb2
	cbi 	PortB, 5		;LOW for pb5
	cbi	DDRD, 2			;input fot int0
	sbi	PortD, 2		;pullup on int0
	ldi	r16, 0b00000010 
	sts	EICRA, r16		;int0 set for falling edge
	ldi	r16, 0b00000001
	out 	EIMSK, r16		;enable int0 interrupts
	ldi 	r16, 0b00000101
	out	TCCR0B, r16		;choose clkio/1024 prescaler for timer0
	ldi 	r16, 0b00000011
	sts 	TCCR1B, r16		;choose clkio/64 prescaler for timer1
	ldi	r16, 0b00000000 	
	sts	TIMSK0, r16		;disable timer0 overflow interrupts
	ldi	r16, 0b00000001 
	sts	TIMSK1, r16		;enable timer1 overflow interrupts
	clr 	r16
	sts 	TCNT1L, r16
	sts 	TCNT1H, r16
	clr	r20
	clr 	r18
	sei 				;enable global interrupts
loop:
	rjmp 	loop			;infinite loop


int0_h:	
	clr	r16
	out 	EIMSK, r16		;disable int0 interrupts (avoid detecting bounces)				
	ldi	r16, 0b00000001 	
	sts	TIMSK0, r16		;enable timer0 overflow interrupts
	clr	r16
	out	TCNT0, r16		;set timer0 to 0
	reti


overflow0_h:
	clr	r16
	sts	TIMSK0, r16		;disable timer0 overflow interrupts
	sbic 	PinD, 2			;if pd2 is cleared skip next instruction
	rjmp	exit			;if pd2 is set means it wasnt really pressed 
	com 	r20			;toggle r20 (led status)
	cpi	r20, 0				
	breq	off			
	sbi	PortB, 2		;set pb2
	rjmp	exit
off:	
	cbi	PortB, 2		;clear pb2
exit:	
	ldi	r16, 0b00000001
	out 	EIMSK, r16		;enable int0 interrupts
	reti



overflow1_h:
	com 	r18
	cpi 	r18, 0
	breq 	next
	sbi 	PortB, 5
	rjmp 	sortie
next: 	
	cbi	PortB, 5
sortie:
	reti

