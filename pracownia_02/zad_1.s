.org 0x0000
	jmp start		; Reset handler
.org 0x0040
	jmp timer0_ovf_irq 	; Timer0 Overflow Handler

.include "include/atmega328p.s"
.include "include/macros.s"

; 7 segment controller mc74hc595
; SDI - portb 0
; SHIFT CLK - portd 7
; LATCH CLK - portd 4

.set timer_cycles_per_half_second, 62500

.section .data
screen_data:
	.space 2

screen_bit:
	.space 1

shift_clk:
	.space 1

stopwatch_value:
	.space 2

stopwatch_seconds:
	.space 1

segments_digit:
	.space 1

segments_data:
	.space 2

.section .text

;; Interrupt handlers

; Timer0 Overflow Interrupt handler
timer0_ovf_irq:
	call stopwatch_refresh
	call segments_refresh
	reti


; Reset Interrupt handler
start:
	load_register_16 SPH, SPL, _stack_top

	lds r16, DDRB
	sbr r16, 0x21
	sts DDRB, r16

	lds r16, DDRD
	sbr r16, 0x90
	sts DDRD, r16

	load_register_8 TCCR0B, 0x01
	load_register_8 TIMSK0, 0x01
	load_register_8 TCNT0, 0x00

	load_register_Z shift_clk
	ldi r16, 0xFF
	st Z, r16

	load_register_Z segments_digit
	ldi r16, 0x08
	st Z, r16

	load_register_Z segments_data
	ldi r16, 0xA4
	st Z+, r16
	st Z+, r16

	load_register_Z screen_bit
	ldi r16, -1
	st Z, r16

	load_register_Z stopwatch_seconds
	ldi r16, 0
	st Z, r16

	ldi r24, 2	; 2 seconds

	call stopwatch_reset

	sei
sleep:
	sleep
	jmp sleep

;; Functions
segments_toggle_shift_clk:
	load_register_Z shift_clk
	ld r16, Z
	com r16
	st Z, r16
	lds r17, PORTD
	andi r17, 0x7F
	andi r16, 0x80
	or r17, r16
	sts PORTD, r17
	ret


segments_put_sdi:
	; Rotate screen data, oldest bit in r18
	load_register_Z screen_data
	ld r16, Z+
	ld r17, Z+
	clr r18
	clc
	rol r16
	rol r17
	rol r18
	st -Z, r17
	st -Z, r16

	; Put correct data on sdi
	lds r16, PORTB
	sbrc r18, 0
	sbr r16, 0x01
	sbrs r18, 0
	cbr r16, 0x01
	sts PORTB, r16

	ret

segments_next_digit:
	load_register_X segments_data
	load_register_Y segments_digit
	ld r16, Y
	ldi r17, 0xA4
	call segments_update

	ret


segments_refresh:
	load_register_Z screen_bit
	ld r16, Z
	tst r16
	brmi segments_refresh_next_digit
	
	dec r16
	st Z, r16
	brmi segments_refresh_one_latch_clk
	call segments_toggle_shift_clk

	tst r16
	brne segments_refresh_end
	call segments_put_sdi
	jmp segments_refresh_end

segments_refresh_next_digit:
	call segments_next_digit
	jmp segments_refresh_zero_latch_clk

segments_refresh_one_latch_clk:
	lds r16, PORTD
	sbr r16, 0x10
	sts PORTD, r16

segments_refresh_zero_latch_clk:
	lds r16, PORTD
	cbr r16, 0x10
	sts PORTD, r16

segments_refresh_end:
	ret

segments_update:
	load_register_Z screen_data
	st Z+, r16
	st Z+, r17
	load_register_Z screen_bit
	ldi r16, 33
	st Z, r16

	ret

stopwatch_reset:
	load_register_Z stopwatch_value
	ldi r16, lo8(timer_cycles_per_half_second)
	st Z+, r16
	ldi r16, hi8(timer_cycles_per_half_second)
	st Z, r16

stopwatch_refresh:
	load_register_Z stopwatch_value
	ld r26, Z+
	ld r27, Z+
	sbiw r26, 1
	st -Z, r27
	st -Z, r26	
	brne stopwatch_refresh_exit
	dec r24
	brne stopwatch_refresh_exit
	ldi r24, 2

	call stopwatch_reset
	call stopwatch_next
stopwatch_refresh_exit:
	ret

; back to start state
reset_loop:
	load_register_Z segments_digit
	ld r16, Z
	ldi r16, 0x10
	st Z, r16
	call back


stopwatch_next:
; shift digit segment
	load_register_Z segments_digit
	ld r16, Z
	;sec
	lsr r16
	st Z, r16
	cpi r16, 0
	breq reset_loop
back:

	; Toggle led
	lds r16, PORTB
	ldi r17, 0x20
	eor r16, r17
	sts PORTB, r16

	; If led is zero, wait next 500ms
	sbrc r16, 5
	jmp stopwatch_next_end

	; Increment current seconds count (wrap at 4)
	load_register_Z stopwatch_seconds
	ld r16, Z
	inc r16
	cpi r16, 4
	brne stopwatch_next_less_than_four
	ldi r16, 0
	
stopwatch_next_less_than_four:
	st Z, r16

	; Update display data
	load_register_Z segments_data
	st Z, r16
stopwatch_next_end:
	ret