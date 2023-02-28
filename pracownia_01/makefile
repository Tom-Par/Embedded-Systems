PORT	= /dev/ttyACM0
MAKEFLAGS += --no-builtin-rules
.PRECIOUS: %.o %.bin %.hex

BINARIES  = $(basename $(wildcard *.c))
BINARIES += $(basename $(wildcard *.s))

EXAMPLES  = blink1 blink2 blink3

%.o: %.c
	avr-gcc -mmcu=atmega32a -Os -c $< -o $@ -nostdlib

%.o: %.s
	avr-as -m atmega32a $< -o $@

%.bin: %.o script.ld
	avr-ld $< -o $@ -T script.ld

%.hex: %.bin
	avr-objcopy -j .text -j .data -O ihex $< $@

%: %.hex
	avrdude -p m328p -c arduino -P $(PORT) -b 115200 -U flash:w:$<:i -F

clean:
	rm -rf *.o *.bin *.hex $(EXAMPLES)