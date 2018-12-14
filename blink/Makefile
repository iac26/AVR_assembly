#makefile
FN=blink.asm
FNH=flash:w:blink.hex

all:
	avra $(FN)
	avrdude -p m328p -c stk500v1 -b 57600 -P /dev/ttyUSB0 -U $(FNH)