ENTRY(_start)

MEMORY
{
    FLASH(rx) : ORIGIN = 0x08000000, LENGTH = 256k
    RAM(rw)   : ORIGIN = 0x20000000, LENGTH =  64k
}

PROVIDE( _estack = ORIGIN(RAM)+LENGTH(RAM) );   
    
SECTIONS {
    .isr_vector :   # must be at the beginning of the flash
    {
    	KEEP(*(.isr_vector))    # keep interrupt vector table
    } > FLASH

    .text : {       # machine code goes here
    	*(.text*)
    } > FLASH

    .rodata : {     # read only (const) global/static variables
        *(.rodata*) 
    } > FLASH
    
    .data : {       # initialized global/static variables
        *(.bss*) 
    } > RAM AT > FLASH

    .bss : {        # uninitialized global/static variables
        *(.bss*)
    } > RAM    
}
