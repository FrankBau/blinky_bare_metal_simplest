// adapted from https://gist.github.com/postspectacular/a2f73e3125ad818769c3
// see also https://github.com/cpq/bare-metal-programming-guide.git

// target device: stm32l432kc
// it is actually cortex-m4, but we restrict ourselves to cortex-m0 instructions

.syntax unified
.cpu cortex-m0
.thumb


.section .isr_vector_table, "a", %progbits
.global  isr_vectors
.type    isr_vectors, %object
isr_vectors:
    .word   _estack             // reset value of sp (stack pointer)
    .word   _start              // reset value of pc (program counter)


.section  .text, "ax", %progbits
.global   _start
.type     _start, %function
_start:
    ldr     r0, =0x40021000   	// load MMIO address of RCC peripheral block to register r0
    ldr     r1, [r0, #0x4C]	    // load content of RCC AHB2ENR register to r1
    movs	r2, 2	            // load bit mask for GPIO port B to register r2
    orrs    r1, r2       		// set bit to enable clock for GPIOB
    str     r1, [r0, #0x4C]		// store (indirect) modified value to RCC AHB2ENR register

    ldr     r0, =0x48000400     // load address of GPIOB peripheral block to register r0
    movs    r1, 0x40            // load bitmask 1<<(2*3) to register r1
    str     r1, [r0, #0x00]     // set pin PB3 to output mode in GPIOB MODER register 
	
blink:
    movs    r1, 8	            // load bit mask for pin PB3 to register r1
    ldr     r2, [r0, 0x14]      // load (indirect) GPIOB ODR register value to r2
    eors    r2, r1              // xor with bit mask to toggle PB3 (LED)
    str     r2, [r0, 0x14]      // store (indirect) modified value to GPIOB ODR register
    bl      delay               // call the delay function below 
    b       blink               // branch to (goto) label blink (infinite loop)


.section  .text
.global   delay
.type     delay, %function
delay:                          // delay function, waste some time by counting down
    ldr     r2, =0x80000        // load a larger value to register r2
loop:
    subs    r2, #1              // subtract 1 from register r2 (count down)
    bne     loop				// branch to lable loop if result of subs was not 0 (loop)
    bx      lr                  // return to caller
