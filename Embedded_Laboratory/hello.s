.include "include/stm32f411ve.s"
.include "include/macro.s"

.global reset

.section .data

.section .text

.thumb_func
reset:
    store32 rcc_ahb1enr, 0x00000008
    store32 gpiod_moder, 0x55000000
loop:
    store32 gpiod_bsrr,  0x0000F000
    store32 gpiod_bsrr,  0xF0000000
    b loop
