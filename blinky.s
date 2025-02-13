// adapted from https://gist.github.com/postspectacular/a2f73e3125ad818769c3
// see also https://github.com/cpq/bare-metal-programming-guide.git

// target device: stm32l432kc on Nucleo-32 board, User LED on pin PB3
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
    ldr     r0, =0x40021000     // load address of RCC peripheral block to r0
    ldr     r1, [r0, #0x4C]     // load content of RCC AHB2ENR register to r1
    movs    r2, #2              // load bit mask for GPIO port B to register r2
    orrs    r1, r2              // set bit to enable clock for GPIOB
    str     r1, [r0, #0x4C]     // store modified value to RCC AHB2ENR register

    ldr     r0, =0x48000400     // load address of GPIOB peripheral block to r0
    ldr     r1, [r0, #0x00]     // load content of GPIOB MODER register to r1
    movs    r2, 0xC0            // load bit mask for pin PB3 mode bits to r2
    bics    r1, r2              // clear all mode bits for pin PB3 (only)
    movs    r2, 0x40            // load output mode bits for pin PB3 to r2
    orrs    r1, r2              // set mode bits for pin PB3 (only) to GPIO output mode
    str     r1, [r0, #0x00]     // store modified value to GPIOB MODER register
    
blink:
    ldr     r1, [r0, 0x14]      // load content of GPIOB ODR register to r1
    movs    r2, #8              // load bit mask for pin PB3 output level to r2
    eors    r1, r2              // xor with bit mask to toggle PB3 (LED) output level
    str     r1, [r0, 0x14]      // store modified value to GPIOB ODR register
    bl      delay               // call the delay function (see below) 
    b       blink               // branch to (goto) label blink (infinite loop)


.global   delay
.type     delay, %function
delay:                          // delay function, waste some time by counting down
    ldr     r2, =500000         // load a larger value to register r2
loop:
    subs    r2, #1              // subtract 1 from register r2
    bne     loop                // branch to lable 'loop' if result of subs was not 0
    bx      lr                  // return to caller (when r2 reaches 0)
