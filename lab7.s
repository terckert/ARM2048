    .data
    .global uart_init
    .global draw_outline
    .global draw_board_internal

    .text
    .global lab7

lab7:
    push    {lr}
    
    
    bl      uart_init
    bl      draw_outline
    bl      draw_board_internal

    pop     {lr}
    mov     pc, lr

    .end