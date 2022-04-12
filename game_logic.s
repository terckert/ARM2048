    .data
    
    .global get_sprite
    .global output_string

board_outline:  .string 0xC, 27, "[?25l", 27, "[37;40m"
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

shadow_board:   .word   0, 2, 4, 0, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 0, 1024, 0
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

    .text
    .global     draw_outline
    .global     draw_board_internal

ptr_to_board_outline:   .word   board_outline
ptr_to_shadow_board:    .word   shadow_board

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

    .end
