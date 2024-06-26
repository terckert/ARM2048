    .data
    
    .global     draw_outline
    .global     draw_board_internal
    .global     shift_left
    .global     shift_right
    .global     shift_up
    .global     shift_down
    .global     print_time_score
    .global     update_time
	.global		set_new_block
	.global 	check_game_status
	.global 	pause_game
	.global 	reset_cascade
	.global return_game_state

shift_direction:    .word   0
frames:				.word 	0


    .text
    
    .global GameClock_Handler
    .global Timer_Handler
    .global timer0_interrupt_init
	.global timer1_init

ptr_to_shift_direction:     .word shift_direction
ptr_to_frames:				.word frames


;TIMER OFFSETS
RCGCTIMER: 	    .equ 0x604 	            ;Timer Run Mode Clock Gating Control
GPTMCTL:	    .equ 0x00C 	            ;Timer Control Register
GPTMTAMR: 	    .equ 0x004	            ;Timer A Mode Register
GPTMTAILR:	    .equ 0x028	            ;Timer Interval Load Register
GPTMIMR:	    .equ 0x018	            ;Timer Interrupt Mask Register
GPTMICR:	    .equ 0x024      	    ;Timer Interrupt Clear Register
EN0: 		    .equ 0x100	            ;NVIC Interrupt Enable Register

;***************************************************************************************************
; Function name: timer0_interrupt_init
; Function behavior: Initializes timer 0 for 32-bit mode, half second intervals. Sets address of 
; shared variable from lab7.s
; 
; Function inputs:
; r0 : Address of local variable from main 
;
; Function returns: none
; 
; Registers used: 
; r0: value manipulation
; r1: holds base address of timer 0
; 
; Subroutines called: none
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
timer0_interrupt_init:
	PUSH    {lr}

    ; Copy address of shared variable
    ldr     r1, ptr_to_shift_direction
    str     r0, [r1]

	;set r1 to clock settings base address
	MOV     r1, #0xE000
	MOVT    r1, #0x400F

	;load in current value of the timer clock settings
	LDRB    r0, [r1, #RCGCTIMER]
	ORR     r0, r0, #0x1
	STRB    r0, [r1, #RCGCTIMER]        ;enable clock for timer 0 (A)

	;TIMER SETUP

	;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;Disable the timer
	;load current status
	LDRB    r0, [r1, #GPTMCTL]
	AND     r0, r0, #0x0		        ;set bit 0 to 1
	STRB    r0, [r1, #GPTMCTL]          ;disable timer 0 (A) for setup

	;set 32-bit mode
	;GPTMCFG: 	.equ 0x000 ;General Purpose Timer Configuration Register
	;load current status
	LDRB    r0, [r1]
	AND     r0, r0, #0x0	            ;set bit 0 to 1
	STRB    r0, [r1] 		            ;set configuration 32-bit for 16/32 bit timer

	;set periodic mode
	;load current status
	LDRB    r0, [r1, #GPTMTAMR]
	ORR     r0, r0, #0x2			    ;set 2 to r0
	STRB    r0, [r1, #GPTMTAMR]         ;set periodic mode for timer A

	;set interval period
	;load current status
	LDR     r0, [r1, #GPTMTAILR]
	MOV     r0, #0x1200				    ;set r2 to 8 million
	MOVT    r0, #0x007A			        ;for 2 timer interrupts a second
	STR     r0, [r1, #GPTMTAILR] 	    ;set interval period for timer A

	;set up to interrupt processor
	;load current status
	LDR     r0, [r1, #GPTMIMR]
	ORR     r0, r0, #0x1		        ;set bit 0 to 1
	STR     r0, [r1, #GPTMIMR] 	        ;enable interrupts for timer A

	;Allow Timer to Interrupt Processor
	;set r1 to EN0 base address
	MOV     r1, #0xE000
	MOVT    r1, #0xE000

	;load current status
	LDR     r0, [r1, #EN0]
	ORR     r0, r0, #0x80000		    ;set timer 0 to be able to interrupt processor
	STR     r0, [r1, #EN0]

	POP     {lr}
	MOV     pc, lr

;***************************************************************************************************
; Function name: timer1_init
; Function behavior: Initializes the timer to be continuous. Timer is used as a seed for random 
; number generator.
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0: value manipulation
; r1: holds base address of timer 0 
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
timer1_init:
	PUSH    {lr}

	;set r1 to clock settings base address
	MOV     r1, #0xE000
	MOVT    r1, #0x400F

	;load in current value of the timer clock settings
	LDRB    r0, [r1, #RCGCTIMER]
	ORR     r0, r0, #0x2
	STRB    r0, [r1, #RCGCTIMER]        ;enable clock for timer 1 (A)

	;TIMER SETUP

	;set r1 to timer 1 base address
	MOV     r1, #0x1000
	MOVT    r1, #0x4003

	;Disable the timer
	;load current status
	LDRB    r0, [r1, #GPTMCTL]
	AND     r0, r0, #0x0		        ;set bit 0 to 1
	STRB    r0, [r1, #GPTMCTL]          ;disable timer 1 (A) for setup

	;set 32-bit mode
	;GPTMCFG: 	.equ 0x000 ;General Purpose Timer Configuration Register
	;load current status
	LDRB    r0, [r1]
	AND     r0, r0, #0x0	            ;set bit 0 to 1
	STRB    r0, [r1] 		            ;set configuration 32-bit for 16/32 bit timer

	;set periodic mode
	;load current status
	LDRB    r0, [r1, #GPTMTAMR]
	ORR     r0, r0, #0x2			    ;set 2 to r0
	STRB    r0, [r1, #GPTMTAMR]         ;set periodic mode for timer A

	;set interval period
	;load current status
	LDR     r0, [r1, #GPTMTAILR]
	MOV     r0, #0x2400				    ;set r2 to 16 million
	MOVT    r0, #0x00F4			        ;for 1 timer interrupt a second
	STR     r0, [r1, #GPTMTAILR] 	    ;set interval period for timer A



	;set up to interrupt processor
	;load current status
	LDR     r0, [r1, #GPTMIMR]
	ORR     r0, r0, #0x1		        ;set bit 0 to 1
	STR     r0, [r1, #GPTMIMR] 	        ;enable interrupts for timer A

	;Allow Timer to Interrupt Processor
	;set r1 to EN0 base address
	MOV     r1, #0xE000
	MOVT    r1, #0xE000

	;load current status
	LDR     r0, [r1, #EN0]
	ORR     r0, r0, #0x200000		    ;set timer 1 to be able to interrupt processor
	STR     r0, [r1, #EN0]


	POP     {lr}
	MOV     pc, lr


;***************************************************************************************************
; Function name: Timer_Handler
; Function behavior: Main gameplay loop. Updates the board state based on the direction variable.
; Uses remaining board spaces and score to determine if game is ended and whether game was won/lost.
; 
; Function inputs: none
; 
; Function returns: none
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
Timer_Handler:
    push    {r4-r11, lr}

    ;CLEAR INTERRUPT
	;load timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;set 1 to clear the interrupt
	LDR     r0, [r1, #GPTMICR]
	ORR     r0, r0, #0x01
	STR     r0, [r1, #GPTMICR]

    ;bl      update_time                 ; Update timer

    ; Get address of local pointer and dereference to get value of direction byte
    ; r4 = **ptr_to_shift_direction
    ldr     r5, ptr_to_shift_direction
    ldr     r5, [r5]
    ldrb    r4, [r5]
    
    ; Compare train to determine if a shift is needed
    cmp     r4, #0                      ; If direction == 0, no shift needed, return from Handler      
    beq     Timer_Handler_return        
    cmp     r4, #1                      ; If value is 1, D -> shift right
    bne     Timer_Handler_check_two
    bl      shift_right
    b       Timer_Handler_post_shift

Timer_Handler_check_two:
    cmp     r4, #2
    bne     Timer_Handler_check_four    ; If value is 2, S -> shift down
    bl      shift_down
    b       Timer_Handler_post_shift

Timer_Handler_check_four:
    cmp     r4, #4                      ; If value is 4, A -> shift left
    bne     Timer_Handler_check_eight
    bl      shift_left    
    b       Timer_Handler_post_shift

Timer_Handler_check_eight:
    ; If we're then value must be 8, W -> shift up
    bl      shift_up

; All shifts return a value of 1 if a shift happened and 0 if no shift happened. If r0 == 0, then we want to
; clear the direction bit so it can be updated by the UART handler.     
Timer_Handler_post_shift:
	ldr 	r1, ptr_to_frames			; Load frames pointer
	ldr 	r2, [r1]					; load frames value
    cmp     r0, #0
    bne     Timer_Handler_print_updated_board
	; Determine if new piece is necessary to print
    ; Store 0 in direction controller so user can select new direction. Return from handler.
    strb    r0, [r5]
	cmp 	r2, #0						; If frames is at 0, no shift happened, anim frames
	beq 	Timer_Handler_return		; skip all that crap and return
	; Otherwise, reset frames to one
	movw 	r2, #0
	str 	r2, [r1]
	bl 		set_new_block
	bl 		reset_cascade
	bl 		draw_board_internal
	; Are there any more valid moves?
	bl 		check_game_status
	cmp 	r0, #0						; If status returned is 0, game is ongoing
    beq 	Timer_Handler_return
	; Otherwise game is over. Pause game with appropriate message (value returned by check_game_status)
	bl 		pause_game
	b 		Timer_Handler_return

Timer_Handler_print_updated_board:
	add 	r2, #1						; Increment animation frames
	str 	r2, [r1]					; Store new value
    bl      draw_board_internal
    ; Insert game status check here.
Timer_Handler_return:
    ; Regardless, need to update score and time on board    
    ;bl      print_time_score

    pop     {r4-r11, lr}
    bx      lr




;***************************************************************************************************
; Function name: GameClock_Handler
; Function behavior: Updates the game clock every second
;
; Function inputs: none
;
; Function returns: none
;
; Registers used:
; r0 : loads and stores interrupt clear register
; r1 : contains the address for timer 1
;
; Subroutines called:
; update_time
; print_time_score
;
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;***************************************************************************************************
GameClock_Handler:
	PUSH {lr}
	;CLEAR INTERRUPT
	;load timer 1 base address
	MOV     r1, #0x1000
	MOVT    r1, #0x4003

	;set 1 to clear the interrupt
	LDR     r0, [r1, #GPTMICR]
	ORR     r0, r0, #0x01
	STR     r0, [r1, #GPTMICR]

	;check if clock should be updated and displayed
	BL      return_game_state
	CMP 	r0, #0x7B
	BEQ 	GameClock_end

	bl      update_time                 ; Update timer
	bl      print_time_score

GameClock_end:
	POP {lr}
	BX lr

    .end
