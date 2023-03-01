OUTPUT_FORMAT("elf32-avr", "elf32-avr", "elf32-avr")

MEMORY {
    flash(rx) 	    : ORIGIN = 0x000000, LENGTH = 32K
    ram(rw!x)	    : ORIGIN = 0x800100, LENGTH = 2K
    eeprom(rw!x)    : ORIGIN = 0x810000, LENGTH = 1K
    fuse(rw!x)      : ORIGIN = 0x820000, LENGTH = 1K
    lock(rw!x)      : ORIGIN = 0x830000, LENGTH = 1K
}

stack_size = 256;

SECTIONS {
    .text : {
        *(.text)
        *(.text*)
    } > flash

    .data : {
        *(.data)
        *(.data*)
        _stack_end = .;
        . = . + stack_size;
        _stack_top = .;
    } > ram AT > flash

    .eeprom  : {
        KEEP(*(.eeprom*))
        __eeprom_end = . ;
    } > eeprom

    .fuse  : {
        KEEP(*(.fuse))
        KEEP(*(.lfuse))
        KEEP(*(.hfuse))
        KEEP(*(.efuse))
    } > fuse
}