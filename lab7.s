    .data
    
    .global uart_init
    .global uart_interrupt_init
    .global timer0_interrupt_init
    .global reset_game
    .global timer1_init
    .global initialize_daughter_board
    .global gpio_interrupt_init
    .global return_game_state
    .global return_stored_character
    .global output_string


main_menu:          .string 0xC, 27, "[?25l","Welcome to 2048, Crappy Console Edition!", 0xA, 0xD
                    .string "You use the WASD keys to slide the board. When two", 0xA, 0xD
                    .string "pieces of the same value collide, they add together", 0xA, 0xD
                    .string "and form a new piece. The goal of this game is create", 0xA, 0xD
                    .string "a tile with a value of 2048. You can press SW1 on the", 0xA, 0xD
                    .string "TIVA to pause the game. There is a hidden DEAN NEEDS", 0xA, 0xD
                    .string "HELP cheat menu that will allow you to change this", 0xA, 0xD
                    .string "goal if it is too hard.", 0xA, 0xD
                    .string "W - Shift Up", 0xA, 0xD
                    .string "A - Shift Left", 0xA, 0xD
                    .string "S - Shift Down", 0xA, 0xD
                    .string "D - Shift Right", 0xA, 0xD
                    .string "Press SPACE to start!", 0

quit_msg:           .string 0xC, 27, "[37;40m", 27, "[1;1H", 27, "[J"
                    .string "Exiting...", 0xA, 0xD


direction:  .byte 0

    .text


    .global lab7

ptr_to_direction: 	.word direction
ptr_to_main_menu: 	.word main_menu
ptr_to_quit_msg:	.word quit_msg


lab7:
    push    {lr}
    
    ; Initializes all peripherals
    bl      timer1_init
    bl      uart_init

    bl      initialize_daughter_board
    ldr     r0, ptr_to_direction
    bl      uart_interrupt_init
    ldr     r0, ptr_to_direction
    bl      timer0_interrupt_init
    
    ldr     r0, ptr_to_main_menu        ; Print main menu
    bl      output_string

    ;set r1 to timer 1 base address
	MOV     r1, #0x1000
	MOVT    r1, #0x4003
	;start timer
	LDRB    r0, [r1, #0x00C]
	ORR     r0, r0, #0x3		        ; set bit 0 to 1, set bit 1 to 1 to allow debugger to stop timer
	STRB    r0, [r1, #0x00C]            ; enable timer 1 (A) for use

    ; Polls mydata to get keypress to start game
lab7_main_menu_loop:
    bl      return_stored_character
    cmp     r0, #0
    beq     lab7_main_menu_loop

    bl      gpio_interrupt_init

    bl      reset_game



lab7_gameplay_loop:
    bl      return_game_state
    cmp     r0, #0 
    beq     lab7_gameplay_loop

	;game was quit so display message
	LDR r0, ptr_to_quit_msg
	BL output_string

	;set r1 to timer 1 base address
	MOV     r1, #0x1000
	MOVT    r1, #0x4003
	;stop timer
	LDRB    r0, [r1, #0x00C]
	ORR     r0, r0, #0x0		        ; set bit 0 to 0r
	STRB    r0, [r1, #0x00C]            ; disbale timer 1 (A) for use

	;set r1 to timer 1 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003
	;stop timer
	LDRB    r0, [r1, #0x00C]
	ORR     r0, r0, #0x0		        ; set bit 0 to 0
	STRB    r0, [r1, #0x00C]            ; disable timer 0 (A) for use


    pop     {lr}
    mov     pc, lr

    .end
