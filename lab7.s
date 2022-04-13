    .data
    .global uart_init
    .global draw_outline
    .global draw_board_internal
    .global shift_left
    .global shift_right
    .global shift_up
    .global shift_down

    .text
    .global lab7

lab7:
    push    {lr}
    
    
    bl      uart_init
    bl      draw_outline
    bl      draw_board_internal

    and     r1, r1, r1
    bl      shift_down
    bl      draw_board_internal

    and     r1, r1, r1
    bl      shift_down
    bl      draw_board_internal

    and     r1, r1, r1
    bl      shift_down
    bl      draw_board_internal

    and     r1, r1, r1
    bl      shift_down
    bl      draw_board_internal

    pop     {lr}
    mov     pc, lr

    .end