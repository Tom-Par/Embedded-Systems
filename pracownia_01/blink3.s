.org 0x0000
	jmp start		; Reset handler
.org 0x0040
	jmp timer0_ovf_irq 	; Timer0 Overflow Handler

.include "include/atmega328p.s"
.include "include/macros.s"

.set timer_cycles_per_second, 6250
.section .text

; Interrupt handler
timer0_ovf_irq:
	sbiw Z, 1
	brne timer0_ovf_irq_exit
	load_register_Z timer_cycles_per_second
	
	ror r23
	ror r23
	dec r23
	lsl r23
	lsl r23
	sts PORTB, r23
	 
timer0_ovf_irq_exit:
	reti

; Interrupt handler
start:
	load_register_16 SPH, SPL, _stack_top
	load_register_8 DDRB, 0x3C

	ldi r23, 0x04
	com r23
	sts PORTB, r23
	
	load_register_8 TCCR0B, 0x01
	load_register_8 TIMSK0, 0x01
	load_register_8 TCNT0, 0x00
	load_register_Z timer_cycles_per_second
	sei

sleep:
	sleep
	jmp sleep