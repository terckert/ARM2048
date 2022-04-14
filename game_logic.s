    .data
    
    .global get_sprite
    .global output_string
    .global int2string

board_outline:  .string 27, "[?25l", 27, "[37;40m", 27, "[1;1H", 27, "[J"
                .string "SCORE:             TIME:     ", 0xA, 0xD
                .string "-----------------------------", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|------|------|------|------|", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|------|------|------|------|", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|------|------|------|------|", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "|      |      |      |      |", 0xA, 0xD
                .string "-----------------------------", 0xA, 0xD, 0

shadow_board:   .word   0, 2, 0, 128, 0, 128, 0, 64, 2, 128, 0, 1024, 128, 0, 0, 1024
grid_zero:      .string 27, "[3;2H",0
grid_one:       .string 27, "[3;9H",0
grid_two:       .string 27, "[3;16H",0
grid_three:     .string 27, "[3;23H",0
grid_four:      .string 27, "[7;2H",0
grid_five:      .string 27, "[7;9H",0
grid_six:       .string 27, "[7;16H",0
grid_seven:     .string 27, "[7;23H",0
grid_eight:     .string 27, "[11;2H",0
grid_nine:      .string 27, "[11;9H",0
grid_ten:       .string 27, "[11;16H",0
grid_eleven:    .string 27, "[11;23H",0
grid_twelve:    .string 27, "[15;2H",0
grid_thirteen:  .string 27, "[15;9H",0
grid_fourteen:  .string 27, "[15;16H",0
grid_fifteen:   .string 27, "[15;23H",0
grid_score:     .string 27, "[1;8H",0
grid_time:      .string 27, "[1;26H",0

win_score:      .word   2048
tick:           .byte   1
score:          .word   0
time:           .word   0
empty_spaces:   .word   16
movement:       .byte   0
score_string:   .string "           ",0
time_string:    .string "           ",0
white_on_black: .string 27, "[37;40m",0

    .text
    .global     draw_outline
    .global     draw_board_internal
    .global     shift_left
    .global     shift_right
    .global     shift_up
    .global     shift_down
    .global     print_time_score
    .global     update_time
    .global     reset_game
    .global     set_new_block

ptr_to_board_outline:   .word board_outline
ptr_to_shadow_board:    .word shadow_board
ptr_to_score:           .word score
ptr_to_time:            .word time
ptr_to_empty_spaces:    .word empty_spaces
ptr_to_score_string:    .word score_string
ptr_to_time_string:     .word time_string 
ptr_to_white_on_black:  .word white_on_black
ptr_to_tick:            .word tick
ptr_to_win_score:       .word win_score

;************************************* PTR_TO_GRID_OFFSETS *****************************************
ptr_to_grid_zero:       .word grid_zero
ptr_to_grid_one:        .word grid_one
ptr_to_grid_two:        .word grid_two
ptr_to_grid_three:      .word grid_three
ptr_to_grid_four:       .word grid_four
ptr_to_grid_five:       .word grid_five
ptr_to_grid_six:        .word grid_six
ptr_to_grid_seven:      .word grid_seven
ptr_to_grid_eight:      .word grid_eight
ptr_to_grid_nine:       .word grid_nine
ptr_to_grid_ten:        .word grid_ten
ptr_to_grid_eleven:     .word grid_eleven
ptr_to_grid_twelve:     .word grid_twelve
ptr_to_grid_thirteen:   .word grid_thirteen
ptr_to_grid_fourteen:   .word grid_fourteen
ptr_to_grid_fifteen:    .word grid_fifteen
ptr_to_grid_score:      .word grid_score
ptr_to_grid_time:       .word grid_time

;***************************************************************************************************
; Function name: draw_outline
; Function behavior: Draws the board outline to screen
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : Holds board outline starting byte
; 
; Subroutines called: 
; output_string
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
draw_outline:
    push    {lr}
    ldr     r0, ptr_to_board_outline
    bl      output_string
    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: draw_board_internal
; Function behavior: Uses the shadowboard to draw the sprites to the board
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : Used to pass board value into get_sprite and as base register for strings
; r4 : Offset address of the shadowboard
; 
; Subroutines called: 
; get_sprite | output_string
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
draw_board_internal:
    push    {lr}
    push    {r4}

    ; Load shadowboard address
    ldr     r4, ptr_to_shadow_board

    ; Cycles through the grid, sets the pointer to the offset of the beginning first spot of the board,
    ; gets the board value of that spot and draws the sprite.
    ldr     r0, ptr_to_grid_zero
    bl      output_string
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_one     
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_two     
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_three   
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_four    
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_five    
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_six     
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_seven   
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_eight   
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_nine    
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_ten     
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_eleven  
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_twelve  
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_thirteen
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_fourteen
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string

    ldr     r0, ptr_to_grid_fifteen 
    bl      output_string    
    ldr     r0, [r4], #4                ; Gets value at current index and offsets by 4 for next run
    bl      get_sprite    
    bl      output_string
    
    pop     {r4}
    pop     {lr}
    
    mov     pc, lr

;***************************************************************************************************
; Function name: shift_left
;
; Function behavior: Shifts shadow board tiles to the left one space if possible. Keeps track of whether
; change was made to shadowboard and returns a 0 if no changes were made, indicating that move
; direction variable should be cleared.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : 1 indicates change was made to board, 0 indicates board is in final position
; 
; Registers used: 
; r0 : Return value
; r1 : points to shadow board base address
; r2 : current shadow board index value
; r3 : previous shadow board index value
; r4 : shadow board index + i * 16
; r5 : shadow board index + i * 16 + j * 4
; r6 : outer loop counter
; r7 : inner loop counter
; r8 : pointer to score
; r9 : value of score
; r10 : address of empty spaces
; r11 : value of empty spaces 
;
; Subroutines called: 
; none
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
shift_left:
    push    {lr}
    push    {r4-r11}

    movw    r0, #0                      ; Set default return value
    ldr     r1, ptr_to_shadow_board     ; Get shadow board position
    movw    r6, #0                      ; Outer loop control variable, cycles through rows
    ldr     r8, ptr_to_score            ; Load address of score
    ldr     r9, [r8]                    ; Get score value
    ldr     r10, ptr_to_empty_spaces    ; Load empty spaces addres
    ldr     r11, [r10]
; for (int i = 0; i < 4; i++)
shift_left_outer_loop:
    lsl     r4, r6, #4                  ; i * 16
    add     r4, r4, r1                  ; Base address + i * 16, row control
    movw    r7, #1                      ; Inner loop control variable, cycles columns
; for (int j = 1; j < 4; j++)           
shift_left_inner_loop:
    lsl     r5, r7, #2                   ; j * 4
    add     r5, r5, r4                  ; index + i* 16 + j*4
    ldr     r2, [r5]                    ; Get current index value
    ldr     r3, [r5, #-4]               ; Load previous index value
    ; Compare train
    cmp     r2, #0                      ; Is current index == 0?                     
    beq     shift_left_inner_loop_end   ; Increment and reloop
    cmp     r3, #0                      ; Is previous index == 0?
    bne     shift_left_inner_loop_not_zero
    ; If here, then current index needs to be shifted left because empty value to left
    ; previous index == current index
    ; current index == 0
    str     r2, [r5, #-4]               ; Store current value into previous index
    str     r3, [r5]                    ; Store 0 at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made
    b       shift_left_inner_loop_end   ; Increment and reloop
shift_left_inner_loop_not_zero:
    ; If values are equal, add together, update score, otherwise do nothing
    cmp     r2, r3                      ; r2 == r3
    bne     shift_left_inner_loop_end   ; If not equal, increment loop and continue
    add     r2, r2, r3                  ; Add values together
    add     r9, r9, r2                  ; Update score
    add     r11, r11, #1                ; Update free spaces
    str     r2, [r5, #-4]               ; Store new value
    movw    r2, #0                       ; 0 out r2
    str     r2, [r5]                    ; Store zero at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made

shift_left_inner_loop_end:    
    ; Loop control logic
    add     r7, #1                      ; increment inner loop
    cmp     r7, #4                      ; j < 4
    bne     shift_left_inner_loop       ; Return to inner loop start
    add     r6, #1                      ; increment outer loop
    cmp     r6, #4                      ; i < 4
    bne     shift_left_outer_loop       ; Return to outer loop start

    str     r9, [r8]                    ; Store updated score
    str		r11, [r10]					; Store updated empty space count
    ; Pop it like it's haaaawt
    pop     {r4-r11}
    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: shift_left
;
; Function behavior: Shifts shadow board tiles to the right one space if possible. Keeps track of whether
; change was made to shadowboard and returns a 0 if no changes were made, indicating that move
; direction variable should be cleared.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : 1 indicates change was made to board, 0 indicates board is in final position
; 
; Registers used: 
; r0 : Return value
; r1 : points to shadow board base address
; r2 : current shadow board index value
; r3 : previous shadow board index value
; r4 : shadow board index + i * 16
; r5 : shadow board index + i * 16 + j * 4
; r6 : outer loop counter
; r7 : inner loop counter
; r8 : pointer to score
; r9 : value of score
; r10 : address of empty spaces
; r11 : value of empty spaces 
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
shift_right:
    push    {lr}
    push    {r4-r11}

    movw    r0, #0                      ; Set default return value
    ldr     r1, ptr_to_shadow_board     ; Get shadow board position
    movw    r6, #0                      ; Outer loop control variable, cycles through rows
    ldr     r8, ptr_to_score            ; Load address of score
    ldr     r9, [r8]                    ; Get score value
    ldr     r10, ptr_to_empty_spaces    ; Load empty spaces addres
    ldr     r11, [r10]
; for (int i = 0; i < 4 0; i++)
shift_right_outer_loop:
    lsl     r4, r6, #4                  ; i * 16
    add     r4, r4, r1                  ; Base address + i * 16, row control
    movw    r7, #2                      ; Inner loop control variable, cycles columns
; for (int j = 2; j >= 0; j--)           
shift_right_inner_loop:
    lsl     r5, r7, #2                  ; j * 4
    add     r5, r5, r4                  ; index + i* 16 + j*4
    ldr     r2, [r5]                    ; Get current index value
    ldr     r3, [r5, #4]                ; Load previous index value
    ; Compare train
    cmp     r2, #0                      ; Is current index == 0?                     
    beq     shift_right_inner_loop_end  ; Increment and reloop
    cmp     r3, #0                      ; Is previous index == 0?
    bne     shift_right_inner_loop_not_zero
    ; If here, then current index needs to be shifted left because empty value to left
    ; previous index == current index
    ; current index == 0
    str     r2, [r5, #4]                ; Store current value into previous index
    str     r3, [r5]                    ; Store 0 at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made
    b       shift_right_inner_loop_end  ; Increment and reloop
shift_right_inner_loop_not_zero:
    ; If values are equal, add together, update score, otherwise do nothing
    cmp     r2, r3                      ; r2 == r3
    bne     shift_right_inner_loop_end  ; If not equal, increment loop and continue
    add     r2, r2, r3                  ; Add values together
    add     r9, r9, r2                  ; Update score
    add     r11, r11, #1                ; Update free spaces
    str     r2, [r5, #4]                ; Store new value
    movw    r2, #0                      ; 0 out r2
    str     r2, [r5]                    ; Store zero at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made

shift_right_inner_loop_end:    
    ; Loop control logic
    sub     r7, #1                      ; decrement inner loop
    cmp     r7, #0                      ; j >= 0
    bge     shift_right_inner_loop      ; Return to inner loop start
    add     r6, #1                      ; increment outer loop
    cmp     r6, #4                      ; i < 4
    bne     shift_right_outer_loop      ; Return to outer loop start

    str     r9, [r8]                    ; Store updated score
    str		r11, [r10]					; Store updated empty space count
    ; Pop it like it's haaaawt
    pop     {r4-r11}
    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: shift_up
;
; Function behavior: Shifts shadow board tiles up one space if possible. Keeps track of whether
; change was made to shadowboard and returns a 0 if no changes were made, indicating that move
; direction variable should be cleared.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : 1 indicates change was made to board, 0 indicates board is in final position
; 
; Registers used: 
; r0 : Return value
; r1 : points to shadow board base address
; r2 : current shadow board index value
; r3 : previous shadow board index value
; r4 : shadow board index + i * 4
; r5 : shadow board index + i * 4 + j * 16
; r6 : outer loop counter
; r7 : inner loop counter
; r8 : pointer to score
; r9 : value of score
; r10 : address of empty spaces
; r11 : value of empty spaces 
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
shift_up:
    push    {lr}
    push    {r4-r11}

    movw    r0, #0                      ; Set default return value
    ldr     r1, ptr_to_shadow_board     ; Get shadow board position
    movw    r6, #0                      ; Outer loop control variable, cycles through rows
    ldr     r8, ptr_to_score            ; Load address of score
    ldr     r9, [r8]                    ; Get score value
    ldr     r10, ptr_to_empty_spaces    ; Load empty spaces addres
    ldr     r11, [r10]
; for (int i = 0; i < 4; i++)
shift_up_outer_loop:
    lsl     r4, r6, #2                  ; i * 4
    add     r4, r4, r1                  ; Base address + i * 16, row control
    movw    r7, #1                      ; Inner loop control variable, cycles columns
; for (int j = 1; j < 4; j++)           
shift_up_inner_loop:
    lsl     r5, r7, #4                  ; j * 16
    add     r5, r5, r4                  ; index + i* 4 + j*16
    ldr     r2, [r5]                    ; Get current index value
    ldr     r3, [r5, #-16]              ; Load previous index value
    ; Compare train
    cmp     r2, #0                      ; Is current index == 0?                     
    beq     shift_up_inner_loop_end     ; Increment and reloop
    cmp     r3, #0                      ; Is previous index == 0?
    bne     shift_up_inner_loop_not_zero
    ; If here, then current index needs to be shifted left because empty value to left
    ; previous index == current index
    ; current index == 0
    str     r2, [r5, #-16]              ; Store current value into previous index
    str     r3, [r5]                    ; Store 0 at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made
    b       shift_up_inner_loop_end     ; Increment and reloop
shift_up_inner_loop_not_zero:
    ; If values are equal, add together, update score, otherwise do nothing
    cmp     r2, r3                      ; r2 == r3
    bne     shift_up_inner_loop_end     ; If not equal, increment loop and continue
    add     r2, r2, r3                  ; Add values together
    add     r9, r9, r2                  ; Update score
    add     r11, r11, #1                ; Update free spaces
    str     r2, [r5, #-16]              ; Store new value
    movw    r2, #0                      ; 0 out r2
    str     r2, [r5]                    ; Store zero at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made

shift_up_inner_loop_end:    
    ; Loop control logic
    add     r7, #1                      ; decrement inner loop
    cmp     r7, #4                      ; j < 4
    bne     shift_up_inner_loop         ; Return to inner loop start
    add     r6, #1                      ; increment outer loop
    cmp     r6, #4                      ; i < 4
    bne     shift_up_outer_loop         ; Return to outer loop start

    str     r9, [r8]                    ; Store updated score
    str		r11, [r10]					; Store updated empty space count
    ; Pop it like it's haaaawt
    pop     {r4-r11}
    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: shift_down
;
; Function behavior: Shifts shadow board tiles down one space if possible. Keeps track of whether
; change was made to shadowboard and returns a 0 if no changes were made, indicating that move
; direction variable should be cleared.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : 1 indicates change was made to board, 0 indicates board is in final position
; 
; Registers used: 
; r0 : Return value
; r1 : points to shadow board base address
; r2 : current shadow board index value
; r3 : previous shadow board index value
; r4 : shadow board index + i * 4
; r5 : shadow board index + i * 4 + j * 16
; r6 : outer loop counter
; r7 : inner loop counter
; r8 : pointer to score
; r9 : value of score
; r10 : address of empty spaces
; r11 : value of empty spaces 
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;***************************************************************************************************
shift_down:
    push    {lr}
    push    {r4-r11}

    movw    r0, #0                      ; Set default return value
    ldr     r1, ptr_to_shadow_board     ; Get shadow board position
    movw    r6, #0                      ; Outer loop control variable, cycles through rows
    ldr     r8, ptr_to_score            ; Load address of score
    ldr     r9, [r8]                    ; Get score value
    ldr     r10, ptr_to_empty_spaces    ; Load empty spaces addres
    ldr     r11, [r10]
; for (int i = 0; i < 4; i++)
shift_down_outer_loop:
    lsl     r4, r6, #2                  ; i * 4
    add     r4, r4, r1                  ; Base address + i * 16, row control
    movw    r7, #2                      ; Inner loop control variable, cycles columns
; for (int j = 2; j >= 0; j++)           
shift_down_inner_loop:
    lsl     r5, r7, #4                  ; j * 16
    add     r5, r5, r4                  ; index + i * 4 + j * 16
    ldr     r2, [r5]                    ; Get current index value
    ldr     r3, [r5, #16]               ; Load previous index value
    ; Compare train
    cmp     r2, #0                      ; Is current index == 0?                     
    beq     shift_down_inner_loop_end   ; Increment and reloop
    cmp     r3, #0                      ; Is previous index == 0?
    bne     shift_down_inner_loop_not_zero
    ; If here, then current index needs to be shifted left because empty value to left
    ; previous index == current index
    ; current index == 0
    str     r2, [r5, #16]               ; Store current value into previous index
    str     r3, [r5]                    ; Store 0 at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made
    b       shift_down_inner_loop_end   ; Increment and reloop
shift_down_inner_loop_not_zero:
    ; If values are equal, add together, update score, otherwise do nothing
    cmp     r2, r3                      ; r2 == r3
    bne     shift_down_inner_loop_end   ; If not equal, increment loop and continue
    add     r2, r2, r3                  ; Add values together
    add     r9, r9, r2                  ; Update score
    add     r11, r11, #1                ; Update free spaces
    str     r2, [r5, #16]               ; Store new value
    movw    r2, #0                      ; 0 out r2
    str     r2, [r5]                    ; Store zero at current index
    movw    r0, #1                      ; Change return value to 1 indicating move made

shift_down_inner_loop_end:    
    ; Loop control logic
    sub     r7, #1                      ; decrement inner loop
    cmp     r7, #0                      ; j >= 0
    bge     shift_down_inner_loop       ; Return to inner loop start
    add     r6, #1                      ; increment outer loop
    cmp     r6, #4                      ; i < 4
    bne     shift_down_outer_loop       ; Return to outer loop start

    str     r9, [r8]                    ; Store updated score
    str		r11, [r10]					; Store updated empty space count
    ; Pop it like it's haaaawt
    pop     {r4-r11}
    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: print_time_score
; Function behavior: Converts score and time elapsed to strings and prints them to proper place on
; board
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : Used to pass variables to called subroutions
; r1 : Holds string address for int2string
; 
; Subroutines called: 
; output_string | int2string
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
print_time_score:
    push    {lr}
    ; Reset ANSI for black background, white text
    ldr     r0, ptr_to_white_on_black
    bl      output_string

    ; Move cursor to score position
    ldr     r0, ptr_to_grid_score
    bl      output_string

    ; Convert score to string and print.
    ldr     r0, ptr_to_score
    ldr     r0, [r0]
    ldr     r1, ptr_to_score_string
    bl      int2string
    ldr     r0, ptr_to_score_string
    bl      output_string

    ; Move cursor to time position
    ldr     r0, ptr_to_grid_time
    bl      output_string

    ; Convert time to string and print
    ldr     r0, ptr_to_time
    ldr     r0, [r0]
    ldr     r1, ptr_to_time_string
    bl      int2string
    ldr     r0, ptr_to_time_string
    bl      output_string
    
    pop     {lr}

;***************************************************************************************************
; Function name: update_time
; Function behavior: Toggles tick between 1 and 0, adds value to timer
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : address of tick 
; r1 : address of time
; r2 : value of tick
; r3 : value of time
;
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
update_time:
    ldr     r0, ptr_to_tick
    ldrb    r2, [r0]
    eor     r2, #1
    strb    r2, [r0]
    ldr     r1, ptr_to_time
    ldr     r3, [r1]
    add     r3, r3, r2
    str     r3, [r1]
    mov     pc, lr

;***************************************************************************************************
; Function name: reset_game
; Function behavior: Resets the game to its start value. Resets board indices to all 0's. Draws
; initial two tiles. Starts timer.
;
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 - r2 : scratch usages
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
reset_game:
    push    {lr}

    ; Reset game control variables to their defaults
    movw    r1, #1
    ; Tick starts a 1 (initial half second sets to 0, first second sets to 1)
    ldr     r0, ptr_to_tick
    strb    r1, [r0]

    ; Score and time get set to 0
    movw    r1, #0
    ldr     r0, ptr_to_score
    str     r1, [r0]
    ldr     r0, ptr_to_time
    str     r1, [r0]

    ; Empty spaces gets reset to 16
    movw    r1, #16
    ldr     r0, ptr_to_empty_spaces
    str     r1, [r0]

    ; Set all indices of shadow board to 0
    ldr     r0, ptr_to_shadow_board
    movw    r1, #0
    movw    r2, #0
    ; for (int i = 0; i <= 60; i+=4)
reset_game_loop:
    str     r2, [r0, r1]
    add     r1, #4
    cmp     r1, #60
    ble     reset_game_loop    
    
    ; Generate starting values
    bl      set_new_block
    bl      set_new_block

    ; Draw board to screen
    bl      draw_outline
    bl      draw_board_internal
    bl      print_time_score

    ;Start frame timer
	;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;load current status
	LDRB    r0, [r1, #0x00C]
	ORR     r0, r0, #0x3		        ; set bit 0 to 1, set bit 1 to 1 to allow debugger to stop timer
	STRB    r0, [r1, #0x00C]            ; enable timer 0 (A) for use

    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: set_new_block
; Function behavior: Creates a new block and assigns it a value of 2 or 4. Pushes value onto the 
; shadow board.
;
; Function inputs: none
; 
; Function returns: none
; 
; Registers used:
; r0 : Address of shadow board
; r1 : Timer 1 GPTMTAV address (0x4003.1050)
; r2 : Used in modulus function  
; r3 : Used in modulus function
; r4 : Holds value of 16 for modulus function
; r5 : Holds index value from modulus
; 
; Subroutines called: none
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
set_new_block:
    push    {r4-r5, lr}
    ; Load address of shadow board
    ldr     r0, ptr_to_shadow_board
    ; Load address of timer 1 counter. Uses register GPTMTAV (0x050) which shows the free running value
    ; of Timer 1A. This will be used with the modulus formula as a random number generator. Timer is always
    ; running.
    movw    r1, #0x1050
    MOVT    r1, #0x4003
    
    movw    r4, #16                     ; Load 16 for multiplication and division
    ; Uses modulus against timer1 current value to get index of shadowboard where we want to place new
    ; piece
set_new_block_index:
    ; n mod m = n - (m * floor(n/m))
    ldr     r2, [r1]                    ; Get current timer value
    udiv    r3, r2, r4                  ; floor (n/m)
    mul     r3, r3, r4                  ; m * floor(n/m)
    sub     r5, r2, r3                  ; n - m * floor(n/m)
    lsl     r5, #2                      ; index * 4 (word array)
    ldr     r2, [r0, r5]                ; Get index value
    cmp     r2, #0                      ; If value is not equal to 0 on board, find new index
    bne     set_new_block_index

    ; Once index is found we can use modulus to determine value. If result of mod is
    ; 0 - 3  : generate a 4
    ; 4 - 15 : generate a 2
    ; n mod m = n - (m * floor(n/m))
    ldr     r1, [r1]                    ; Get current timer value
    udiv    r3, r1, r4                  ; floor (n/m)
    mul     r3, r3, r4                  ; m * floor(n/m)
    sub     r1, r1, r3                  ; n - m * floor(n/m)
    cmp     r1, #3                      ; mod <= 3
    ble     generate_four           
    mov     r1, #2
    b       set_new_block_store_and_return

generate_four:
    mov     r1, #4

set_new_block_store_and_return:
    str     r1, [r0, r5]                ; Store at found index
    ldr     r0, ptr_to_empty_spaces     ; Decrement empty spaces
    ldr     r1, [r0]                    ; Get current value
    sub     r1, #1                      ; Decrement
    str     r1, [r0]                    ; Store new value   

    pop     {r4-r5, lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: check_game_status
; Function behavior: Checks win/lose conditions. Returns a 1 if game is over and player lost, a 2 if
; game is over and player won (HA!), and a 0 if game is not over.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : 0 - game ongoing, 1 - game over lost, 2 - game over won
; 
; Registers used: 
; 
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
check_game_status:


    .end
