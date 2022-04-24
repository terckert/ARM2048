    .data
    
    .global get_sprite
    .global output_string
    .global int2string
    .global illuminate_RGB_LED
    .global read_from_push_btns

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

score_line:     .string 27, "[?25l", 27, "[37;40m", 27, "[1;1H", 27, "[J"
                .string "SCORE:             TIME:     ", 0xA, 0xD, 0

you_lose_loser: .string 27, "[2;1H"
                .string "          GAME OVER          ", 0xA, 0xD
                .string "          YOU LOST!          ", 0xA, 0xD, 0

you_cheated:    .string 27, "[2;1H"
                .string "          GAME OVER          ", 0xA, 0xD
                .string "          YOU WON!           ", 0xA, 0xD, 0 

game_paused:    .string 27, "[?25l", 27, "[37;40m", 27, "[1;1H", 27, "[J"
                .string "           PAUSED            ", 0xA, 0xD, 0

save_cursor_pos:.string 27, "[s", 0
rest_cursor_pos:.string 27, "[u", 0

main_pause_menu:.string 27, "[4;1H"
                .string "        SW2: Quit            ", 0xA, 0xD
                .string "        SW3: Reset           ", 0xA, 0xD
                .string "        SW4: Continue        ", 0xA, 0xD
                .string "        SW5: Cheat           ", 0xA, 0xD, 0

sub_pause_menu: .string 27, "[4;1H"
                .string "        SW2: 2048            ", 0xA, 0xD
                .string "        SW3: 1024            ", 0xA, 0xD
                .string "        SW4: 512             ", 0xA, 0xD
                .string "        SW5: 256             ", 0xA, 0xD, 0

screencap:      .string 27,"[?47h", 0
screenres:      .string 27,"[?47l", 0

shadow_board:   .word   0, 2, 0, 128, 0, 128, 0, 64, 2, 128, 0, 1024, 128, 0, 0, 1024
cascade:        .word   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

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

game_state:     .byte   0x7B
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
    .global     check_game_status
    .global     pause_game
    .global     return_game_state
    .global     reset_cascade

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
ptr_to_score_line:      .word score_line
ptr_to_lose:            .word you_lose_loser
ptr_to_win:             .word you_cheated
ptr_to_pause:           .word game_paused
ptr_to_save:            .word save_cursor_pos
ptr_to_rest:            .word rest_cursor_pos
ptr_to_main_pause_menu: .word main_pause_menu
ptr_to_sub_pause_menu:  .word sub_pause_menu
ptr_to_screencap:       .word screencap
ptr_to_screenres:       .word screenres
ptr_to_game_state:      .word game_state
ptr_to_cascade:         .word cascade

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
    ;============================== CASCADE START =================================
    ldr     r3, [r5, #60]               ; Get cascade board address to see if possible to merge
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_left_inner_loop_end   ; Increment and reloop
    ldr     r3, [r5, #64]               ; Check if current spot is result of merger
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_left_inner_loop_end   ; Increment and reloop
    add     r3, #1                      ; Store a 1 at previous cascade index
    str     r3, [r5, #60]               ; This prevents cascade tile mergers in a move action
    ;=============================== CASCADE END ==================================
    add     r2, r2, r2                  ; Double value
    add     r9, r9, r2                  ; Update score
    add     r11, r11, #1                ; Update free spaces
    str     r2, [r5, #-4]               ; Store new value
    movw    r2, #0                      ; 0 out r2
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
; Function name: shift_right
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
    ;============================== CASCADE START =================================
    ldr     r3, [r5, #68]               ; Get cascade board address to see if possible to merge
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_right_inner_loop_end   ; Increment and reloop
    ldr     r3, [r5, #64]               ; Check if current spot is result of merger
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_right_inner_loop_end   ; Increment and reloop
    add     r3, #1                      ; Store a 1 at previous cascade index
    str     r3, [r5, #68]               ; This prevents cascade tile mergers in a move action
    ;=============================== CASCADE END ==================================
    add     r2, r2, r2                  ; Add values together
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
    ;============================== CASCADE START =================================
    ldr     r3, [r5, #48]               ; Get cascade board address to see if possible to merge
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_up_inner_loop_end   ; Increment and reloop
    ldr     r3, [r5, #64]               ; Check if current spot is result of merger
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_up_inner_loop_end   ; Increment and reloop
    add     r3, #1                      ; Store a 1 at previous cascade index
    str     r3, [r5, #48]               ; This prevents cascade tile mergers in a move action
    ;=============================== CASCADE END ==================================
    add     r2, r2, r2                  ; Add values together
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
    ;============================== CASCADE START =================================
    ldr     r3, [r5, #80]               ; Get cascade board address to see if possible to merge
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_down_inner_loop_end   ; Increment and reloop
    ldr     r3, [r5, #64]               ; Check if current spot is result of merger
    cmp     r3, #0                      ; If value is 0, values can be merged
    bne     shift_down_inner_loop_end   ; Increment and reloop
    add     r3, #1                      ; Store a 1 at previous cascade index
    str     r3, [r5, #80]               ; This prevents cascade tile mergers in a move action
    ;=============================== CASCADE END ==================================
    add     r2, r2, r2                  ; Add values together
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
; Function inputs: 
; r0 : direction variable for reset
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
    ; Reset shift direction to null
    movw    r1, #0
    strb    r1, [r0]


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
    
    ; Reset cascade to 0
    bl      reset_cascade


	;set r6 to 2048 to recognize inital state (used by set_new_block)
	MOV r6, #2048

    ; Generate starting values
    bl      set_new_block
    bl      set_new_block

    ;reset to 0 to allow 4 generation
    MOV r6, #0

    ; Draw board to screen
    bl      draw_outline
    bl      draw_board_internal
    bl      print_time_score
    bl      shine_little_light

    ;Start frame timer
	;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;load current status
	LDRB    r0, [r1, #0x00C]
	ORR     r0, r0, #0x3		        ; set bit 0 to 1, set bit 1 to 1 to allow debugger to stop timer
	STRB    r0, [r1, #0x00C]            ; enable timer 0 (A) for use

	;set game state back to 0
	MOV 	r0, #0
	LDR    	r1, ptr_to_game_state
    STRB    r0, [r1]


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

    ; Edge case. No empty spaces available, but there is still valid moves to be made
    ldr     r0, ptr_to_empty_spaces
    ldr     r0, [r0]
    cmp     r0, #0
    beq     set_new_block_edge_case

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

	;if initally at the beginning at the game, the two beginning tiles must be value 2
	;let r6 be the value of a new game or not
	CMP r6, #2048
	BEQ inital_restart

    ; Once index is found we can use modulus to determine value. If result of mod is
    ; 0 - 3  : generate a 4
    ; 4 - 15 : generate a 2
    ; n mod m = n - (m * floor(n/m))
    ldr     r1, [r1]                    ; Get current timer value
    udiv    r3, r1, r4                  ; floor (n/m)
    mul     r3, r3, r4                  ; m * floor(n/m)
    sub     r1, r1, r3                  ; n - m * floor(n/m)
    cmp     r1, #3                      ; mod <= 3
    ble     set_new_block_generate_four
inital_restart:
    mov     r1, #2
    b       set_new_block_store_and_return

set_new_block_generate_four:
    mov     r1, #4

set_new_block_store_and_return:
    str     r1, [r0, r5]                ; Store at found index
    ldr     r0, ptr_to_empty_spaces     ; Decrement empty spaces
    ldr     r1, [r0]                    ; Get current value
    sub     r1, #1                      ; Decrement
    str     r1, [r0]                    ; Store new value

    ; If we cannot generate a block and the user selects a bad direction, this stops infinite looping
set_new_block_edge_case:   

    pop     {r4-r5, lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: check_game_status
; Function behavior: Checks win/lose conditions. Returns a 1 if game is over and player lost, a 2 if
; game is over and player won (HA!), and a 0 if game is not over.
; WIN: Player has met the score threshold
; LOSE: No more valid moves (board is full)
; Function inputs: none
; 
; Function returns: 
; r0 : 0 - game ongoing, 1 - game over lost, 2 - game over won
; 
; Registers used: 
; r0 : Holds win score
; r1 : Shadow board base address
; r2 : Loop counter
; r3 : Shadow board index value
; r4 : Outer loop counter, valid move loops
; r5 : Inner loop counter, valid move loops
; r6 : Current index value for comparison
; r7 : Next index value for comparison
;
; Subroutines called: none 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
check_game_status:
    push    {r4-r7}
    ; Scan board to see if target tile has been created.
    ldr     r0, ptr_to_win_score
    ldr     r0, [r0]                    ; Load win score
    ldr     r1, ptr_to_shadow_board     
    movw    r2, #0                      ; Initialize loop counter
    
    ; for (int i = 0; i <=60; i += 4)
check_game_status_win_loop:
    ldr     r3, [r1, r2]                ; Load current index value
    cmp     r0, r3                      ; If win score == index value, user has won
    beq     check_game_status_return_2
    add     r2, #4                      ; Increment loop counter
    cmp     r2, #60                     ; i <= 60, reloop
    ble     check_game_status_win_loop

    ; Check if there are empty spaces for new block generation
    ldr     r0, ptr_to_empty_spaces     ; Check if board is full
    ldr     r0, [r0]                    ; Get empty spaces value
    cmp     r0, #0                      ; empty space != 0?
    bne     check_game_status_return_0  ; Return 0, game not over.
    
    ; Loop through shadow board to find a valid move (tiles of equal value next to each other)
    ; If valid move can be found, game can continue, return 0, otherwise returns 1
    ; Checking rows
    ldr     r0, ptr_to_shadow_board
    movw    r4, #0                      ; i = 0
    ; for (int i = 0; i < 4; i++)
check_game_status_row_outer_loop:
    lsl     r1, r4, #4                  ; i * 16
    add     r2, r1, r0                  ; ptr + offset(i * 16)
    movw    r5, #0                      ; j = 0
    ; for (int j = 0; j < 3; j++)
check_game_status_row_inner_loop:
    lsl     r1, r5, #2                  ; j * 4
    add     r1, r1, r2                  ; ptr + offset(i * 16) + (j * 4)
    ldr     r6, [r1]                    ; Current index
    ldr     r7, [r1, #4]                ; Next index
    cmp     r6, r7                      ; If values are equal, game continues
    beq     check_game_status_return_0  ; return 0
    add     r5, #1                      ; j++
    cmp     r5, #3                      ; j < 3
    blt     check_game_status_row_inner_loop
    add     r4, #1                      ; i++
    cmp     r4, #4                      ; i < 3
    blt     check_game_status_row_outer_loop

    ; Check columns, if match is not found in this loop then return 1, no more valid moves
    movw    r4, #0                      ; i = 0
    ; for (int i = 0; i < 4; i++)
check_game_status_column_outer_loop:
    lsl     r1, r4, #2                  ; i * 4
    add     r2, r1, r0                  ; ptr + offset(i * 4)
    movw    r5, #0                      ; j = 0
    ; for (int j = 0; j < 3; j++)
check_game_status_column_inner_loop:
    lsl     r1, r5, #4                  ; j * 16
    add     r1, r1, r2                  ; ptr + offset(i * 4) + (j * 16)
    ldr     r6, [r1]                    ; Current index
    ldr     r7, [r1, #16]                ; Next index
    cmp     r6, r7                      ; If values are equal, game continues
    beq     check_game_status_return_0  ; return 0
    add     r5, #1                      ; j++
    cmp     r5, #3                      ; j < 3
    blt     check_game_status_column_inner_loop
    add     r4, #1                      ; i++
    cmp     r4, #4                      ; i < 4
    blt     check_game_status_column_outer_loop    

    ; No more valid moves. User has lost game.
    movw    r0, #1     
    b       check_game_status_return
    ; User has won game
check_game_status_return_2:
    movw    r0, #2
    b       check_game_status_return
    ; Game is still ongoing, return 0
check_game_status_return_0:
    movw    r0, #0

check_game_status_return:
    pop     {r4-r7}
    mov     pc, lr

;***************************************************************************************************
; Function name: pause_game
; Function behavior: Function prints message based on parameter passed in (see below). Then presents
; user with options. User uses switches on daughter board to navigate the menu. 
; Parameter values:
; 0 - Normal Pause menu
; 1 - Game lost menu
; 2 - Game won menu
; 
; Function inputs: 
; r0 : pause menu value
; 
; Function returns: none 
; 
; Registers used: 
; r0 : 
; r1 : 
; r2 : 
; 
; Subroutines called: 
; illuminate_rgb_led | output_string | print_time_and_score | reset_game | shine_little_light
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
pause_game:
    push    {lr}

    ; Turn TIMER0 off
    movw    r1, #0x000c                 ; load lower address
    movt    r1, #0x4003                 ; load upper address
    ldrb    r2, [r1]                    ; get current value
    eor     r2, #3                      ; Turns off bit 0 and 1
    strb    r2, [r1]                    ; store new value

    ; Store parameter to stack since we're about to go on a subroutine spree!
    push    {r0}                        

    movw    r0, #0                      ; RGB turn off value
    bl      illuminate_RGB_LED          ; Turn that bish the fugg awph

    ; Save current cursor position
    ldr     r0, ptr_to_save             ; Save cursor position
    bl      output_string               ; Save that bish
    
    ; Save current screen               
    ldr     r0, ptr_to_screencap        ; Save screen before printint new shiz
    bl      output_string

    pop     {r0}
    ; Switch statement to print reason for pause (Game won/lost or standard pause)
    ; Game ongoing
    cmp     r0, #0
    bne     pause_game_lost    
    ldr     r0, ptr_to_pause            ; Print pause message
    bl      output_string
    b       pause_game_main_menu

pause_game_lost:
    ; Game lost (HA! Loser!)
    cmp     r0, #1
    bne     pause_game_won
    mov     r0, #2                      ; Load value for red
    bl      illuminate_RGB_LED          ; Turn on red light
    ldr     r0, ptr_to_score_line       ; Print score line
    bl      output_string          
    bl      print_time_score            ; Print time and score
    ldr     r0, ptr_to_lose             ; Print lose message
    bl      output_string               
    b       pause_game_main_menu

pause_game_won:
    mov     r0, #8                      ; Load value for green
    bl      illuminate_RGB_LED          ; Turn on green light
    ldr     r0, ptr_to_score_line       ; Print score line
    bl      output_string   
    bl      print_time_score            ; Print time and score        
    ldr     r0, ptr_to_win              ; Print win message
    bl      output_string               

pause_game_main_menu:
    ldr     r0, ptr_to_main_pause_menu  ; Print main pause menu
    bl      output_string               

    ; Loop until sw2-5 polling returns a value.
pause_game_main_menu_loop:
    bl      read_from_push_btns
    cmp     r0, #0
    beq     pause_game_main_menu_loop

    cmp     r0, #8                      ; SW2 - quit
    bne     pause_game_main_menu_sw3
    ldr     r0, ptr_to_game_state       ; Update game state variable.
    movw    r1, #1                      ; 1 -> game end
    strb    r1, [r0]                    ; Update game state
    ldr     r0, ptr_to_screenres        ; Clear stored screen to avoid ub
    bl      output_string
    b       pause_game_return           ; End subroutine

pause_game_main_menu_sw3:
    cmp     r0, #4                      ; SW3 - restart
    bne     pause_game_main_menu_sw4
    ldr     r0, ptr_to_screenres        ; Clear stored screen to avoid ub
    bl      output_string
    bl      reset_game                  
    b       pause_game_return           ; End subroutine

pause_game_main_menu_sw4:
    cmp     r0, #2                      ; SW4 - Continue
    bne     pause_game_main_menu_sw5
    b       pause_game_restore          ; Restore board state

pause_game_main_menu_sw5:               
    ; Print submenu allowing the user to change the win condition
    ldr     r0, ptr_to_sub_pause_menu   ; Print submenu
    bl      output_string

    ; Loop until sw2-5 polling returns a value
pause_game_sub_menu_loop:
    bl      read_from_push_btns
    cmp     r0, #0
    bne     pause_game_sub_menu_loop

pause_game_sub_menu_second_loop:
	bl 		read_from_push_btns
	cmp 	r0, #0
	beq		pause_game_sub_menu_second_loop

    ldr     r1, ptr_to_win_score
    cmp     r0, #8                      ; SW2 - 2048
    bne     pause_game_sub_menu_sw3
    movw    r0, #2048
    str     r0, [r1]
    b       pause_game_debounce_SW

pause_game_sub_menu_sw3:
    cmp     r0, #4                      ; SW2 - 1024
    bne     pause_game_sub_menu_sw4
    movw    r0, #1024
    str     r0, [r1]
    b       pause_game_debounce_SW
    
pause_game_sub_menu_sw4:
    cmp     r0, #2                      ; SW2 - 512
    bne     pause_game_sub_menu_sw5
    movw    r0, #512
    str     r0, [r1]
    b       pause_game_debounce_SW
    
pause_game_sub_menu_sw5:                ; SW5 - 256
    movw    r0, #256
    str     r0, [r1]

pause_game_debounce_SW:
	bl      read_from_push_btns
    cmp     r0, #0
    bne     pause_game_debounce_SW
	b pause_game_main_menu

pause_game_restore:
    bl      shine_little_light
    

    ; Restore cursor
    ldr     r0, ptr_to_rest
    bl      output_string

    ; Restore screen
    ldr     r0, ptr_to_screenres
    bl      output_string
    
    ;Start frame timer if needed, does nothing if already started by reset
	;set r1 to timer 0 base address
	MOV     r1, #0x000c
	MOVT    r1, #0x4003

	;load current status
	LDRB    r0, [r1]
	ORR     r0, r0, #0x3		        ; set bit 0 to 1, set bit 1 to 1 to allow debugger to stop timer
	STRB    r0, [r1]                    ; enable timer 0 (A) for use

pause_game_return:

    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: shine_little_light
; Function behavior: Turns on the LED based on the score needed to win the game.
; 2048 - Yellow (6)
; 1024 - Purple (10)
; 512  - White (14)
; 256  - Cyan (12)
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : holds win_score for comparison, passes color into illuminate rgb
; 
; Subroutines called: 
; illuminate_RGB_LED
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
shine_little_light:
    push    {lr}
    ; Get current target score
    ldr     r0, ptr_to_win_score
    ldr     r0, [r0]
    cmp     r0, #2048
    bne     shine_little_light_1024
    mov     r0, #10
    b       shine_little_light_return
shine_little_light_1024:
    cmp     r0, #1024
    bne     shine_little_light_512
    mov     r0, #6
    b       shine_little_light_return
shine_little_light_512:
    cmp     r0, #512
    bne     shine_little_light_256
    mov     r0, #14
    b       shine_little_light_return
shine_little_light_256:
    mov     r0, #12

shine_little_light_return:
    bl      illuminate_RGB_LED
    pop     {lr}
    mov     pc, lr

;***************************************************************************************************
; Function name: return_game_state
; Function behavior: Returns game_state value. If value is 1, user has selected to quit program. Used
; in main function to pause until user is done playing game.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : value of game state variable
; 
; Registers used: 
; r0 : uses address to get value
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
return_game_state:
    ldr     r0, ptr_to_game_state
    ldrb    r0, [r0]

    mov     pc, lr

;***************************************************************************************************
; Function name: reset_cascade
; Function behavior: Resets all values in cascade array to 0. Cascade board is used to manage mergers
; on main game board.
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : base address of cascade
; r1 : loop counter
; r2 : holds 0 to store in each index
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
reset_cascade:
    ldr     r0, ptr_to_cascade          ; Set ptr to cascade array 0 index
    movw    r1, #0                      ; Set counter
    movw    r2, #0                      ; Set value to store

    ; for (int i = 0; i < 16; i++)
reset_cascade_loop:
    str     r2, [r0, r1, lsl #2]        ; Set 0 at index
    add     r1, #1                      ; Increment counter
    cmp     r1, #16                     ; i < 16?
    blt     reset_cascade_loop          ; Restart loop

    mov     pc, lr
    .end

