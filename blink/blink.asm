;blink.asm
;blinker program using timers
;connect led between pb2 (d10) and gnd


.nolist
.include "../include/m328Pdef.inc"
.list

.org	0x0000			;reset int vector
	rjmp	Reset
.org	0x0020			;timer0 overflow int vector
	rjmp	overflow_h


Reset:	
	ldi 	r16, 0b00000101
	out	TCCR0B, r16
	ldi	r16, 0b00000001
	sts	TIMSK0, r16
	sei
	clr	r16
	out	TCNT0, r16
	sbi	DDRB, 2
blink:
	sbi 	PortB, 2
	ldi	r19, 3
	rcall	delay
	cbi 	PortB, 2
	ldi	r19, 1
	rcall	delay
	rjmp	blink


overflow_h:
	inc 	r17
	cpi	r17, 30
	brne 	overflow_r
	clr	r17
	inc 	r18
overflow_r:
	reti


delay:
	clr 	r18
cnt:	
	cp 	r18, r19
	brne	cnt
	ret








