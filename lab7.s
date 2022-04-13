    .data
    
    .global uart_init
    .global uart_interrupt_init
    .global timer0_interrupt_init
    .global reset_game

direction:  .byte 0

    .text

    .global lab7


ptr_to_direction: .word direction

lab7:
    push    {lr}
    
    bl      uart_init
    ldr     r0, ptr_to_direction
    bl      uart_interrupt_init
    ldr     r0, ptr_to_direction
    bl      timer0_interrupt_init
    bl      reset_game

infinite_loop:
    mov     r0, #1
    cmp     r0, #0 
    bne     infinite_loop

    pop     {lr}
    mov     pc, lr

    .end