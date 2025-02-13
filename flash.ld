ENTRY(_start)

MEMORY
{
    FLASH(rx) : ORIGIN = 0x08000000, LENGTH = 256k
    RAM(rw)   : ORIGIN = 0x20000000, LENGTH =  64k
}

PROVIDE( _estack = ORIGIN(RAM)+LENGTH(RAM) );
    
SECTIONS {
    .text : {
    	*(.isr_vector_table)
    	*(.text*) 
    } > FLASH

    .rodata : { 
        *(.rodata*) 
    } > FLASH
    
    .data : {
        *(.bss*) 
    } > RAM AT > FLASH

    .bss : {
        *(.bss*)
    } > RAM    
}
