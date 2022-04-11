    .data

mydata:		    .byte   0
player_control: .byte   0x01 ; MSNibble is axis, LSNibble is direction
end_game:       .byte   0
player_pos:     .word   226
board_start:    .string 0xC, "Press enter to change axis, SW1 to change direction", 0xA, 0xD
                .string " -------------------- ", 0xA, 0xD
play_area:      .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string "|                    |", 0xA, 0xD
                .string " -------------------- ", 0

ptr_to_end_game_flag:           .word end_game

    .text

;************************************** UART0 FUNCTIONS ********************************************
    .global uart_init
    .global uart_interrupt_init
    .global UART0_Handler
    .global output_string
    .global read_string

;************************************** PORTF FUNCTIONS ********************************************
    .global gpio_interrupt_init
    .global Switch_Handler

;************************************* TIMER0 FUNCTIONS ********************************************
    .global timer_interrupt_init
    .global Timer_Handler

;************************************* "GAME" FUNCTIONS ********************************************
    .global reset_game
    .global get_state

    


;****************************************** POINTERS ***********************************************
ptr_to_mydata:              .word mydata
ptr_to_player_control:      .word player_control
ptr_to_board_start:         .word board_start
ptr_to_play_area:           .word play_area
ptr_to_player_pos:          .word player_pos
ptr_to_end_game:            .word end_game


;***************************************************************************************************
; Function name: uart_init
; Function behavior: Initializes UART for read/write
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used 
; r4 : Holds address to read from/write to
; r5 : Holds values read from/stored to memory
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
uart_init:  
	PUSH	{lr}   						; Store register lr on stack
	
	; Push used registers to stack
	push 	{r4, r5}

	; The following sets flags manually with integer values	
	; Initialize clock to UART0 to 1, address 0x400FE618
	mov 	r4, #0xe618
	movt	r4,	#0x400f
	ldrb	r5, [r4]
	orr		r5, #1 
	strb	r5, [r4]

	; Initialize clock to PortA to 1, address 0x400FE608
	mov		r4, #0xe608
	movt	r4,	#0x400f
	ldrb	r5, [r4]
	orr		r5, #1 
	strb 	r5, [r4]

	; The above clock set needs 3 cycles to complete
	; Set base address of UART 0, 0x4000.c000
	movw 	r4, #0xc000 				; Instruction 1
	movt	r4, #0x4000					; Instruction 2


	; Set UART0 Control to 0, address 0x4000C030
	movw	r5, #0						; Instruction 3, can now write to register
	str 	r5, [r4, #0x30]

	; Set UART0_IBRD_R for 115,200 baud, address 0x4000C024
	movw	r5, #8
	str 	r5, [r4, #0x24]

	; Set UART0_FBRD_R for 115,200 baud, address 0x4000C028
	movw	r5,	#44
	str 	r5, [r4, #0x28]

	; Use system clock, address	0x4000CFC8
	movw	r5,	#0
	str 	r5, [r4, #0xfc8]

	; Use 8-bit word length, 1 stop bit, no parity, address 0x4000C02C
	movw	r5,	#0x60
	str 	r5, [r4, #0x2c]

	; Enable UART0 Control, address 0x4000C030
	movw	r5,	#0x301
	str 	r5, [r4, #0x30]


	; The following uses bit masking 'or' to set the desired bits while retaining any initial
	; values
	
	; Mark PA0 and PA1 as Digital Ports, address 0x4000451C
	mov		r4, #0x451c
	movt	r4, #0x4000
	ldrb	r5, [r4]
	orr		r5, r5, #0x03
	strb	r5, [r4]

	; Change PA0,PA1 to Use an Alternate Function, address 0x40004420
	mov 	r4, #0x4420
	movt	r4, #0x4000
	ldrb	r5, [r4]
	orr		r5, r5, #0x03
	strb	r5, [r4]

	; Configure PA0 and PA1 for UART, address 0x4000452C
	mov 	r4, #0x452c
	movt	r4, #0x4000
	ldrb	r5, [r4]
	orr		r5, r5, #0x11
	strb	r5, [r4]

	; Pop used registers from stack
	pop 	{r4, r5}

	pop 	{lr}  						; Restore lr from stack
	mov 	pc, lr 

;***************************************************************************************************
; Function name: uart_interrupt_init
; Function behavior: Initializes interrupt method to detect when key has been entered into putty
; terminal. Function assumes that uart_init has already been called. 
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used 
; r4 : Holds address to read from/write to
; r5 : Holds values read from/stored to memory
; r6 : Holds 32 bit value to be written to EOOO.E100
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
uart_interrupt_init:
	push 	{lr}
	; Push registers used in function
	push 	{r4, r5}
	

	; Set the Receive Interrupt bit (RXIM - bit 5) in UART Interrupt mask register. Other
	; bits in register may have already been set, so we load value and use or to set mask bit.
	; 1 unmasks bit to allow bit to be used as an interrupt.
	
	; Load UART0 base address
	movw 	r4, #0xC000
	movt 	r4, #0x4000
	
	; Offset - #0x38  Mask - 0x10
	ldrb 	r5, [r4, #0x38]
	orr 	r5, r5, #0x10
	strb	r5, [r4, #0x38]
	
	; Configure processor to allow UART0 to interrupt operation. Bit 5 needs to be set in 
	; enable register at base register - #0xE000.E000 offset - #0x100, bit 6 - #0x20
	movw 	r4, #0xE100
	movt	r4, #0xE000
	
	; Load current values so we don't overwrite anything previously set and orr with 0x40,
	; then store again.
	ldr 	r5, [r4]
	orr		r5, r5, #0x20
	str		r5, [r4]

	; Pop used registers
	pop 	{r4, r5}

	pop		{lr}
	mov 	pc, lr

;***************************************************************************************************
; Function name: UART0_Handler
; Function behavior: Clears RXIC interrupt pin and calls the simple_read_character function to store
; the value of the keystroke that initiated the interrupt. Toggles the character controller for the 
; vertical byte using xor 0x10;
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : Stores addresses
; r1 : Used for value store and manipulate
; 
; Subroutines called: 
; simple_read_character
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
UART0_Handler: 
	push 	{lr}
	; Push registers 4 - 11 to preserve values
	push 	{r4-r11}
	
	; Load address of UART interrupt clear register (UARTICR): #0x4000.C044
	; Load value from register and clear bit 5, RXIC, using exclusive or
	movw 	r0, #0xc044
	movt	r0, #0x4000
	ldrb	r1, [r0]
	eor 	r1, r1, #0x10
	strb	r1, [r0]
	
	; Call simple_read_chracter. Need to load address where we'll be storing value read in
	bl 		simple_read_character		; Call simple read character function

	; Check if read character was enter
    cmp     r0, #0xD                     
    bne     UART0_Handler_end           ; If value isn't enter key, end handler  
    ; Otherwise toggle vertical controller
    ldr     r0, ptr_to_player_control
    ldrb    r1, [r0]                    ; Load controller value
    eor     r1, r1, #0x10               ; Toggle axis nibble
    strb    r1, [r0]                    ; Store new value

UART0_Handler_end:

	; Restore registers
	pop 	{r4-r11}
	pop 	{lr}

	BX 		lr       					; Return

;***************************************************************************************************
; Function name: simple_read_character
; Function behavior: Reads the character from putty terminal and stores it in address passed in r0.
; 
; Function inputs: 
; r0 : Address to store character at
; 
; Function returns: 
; r0 : keystroke value
; 
; Registers used: 
; r1 : Address of UART0 data
; r2 : Address of mydata
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
simple_read_character: 
	; Load address of UART0 data segment, 0x4000.c000
	movw 	r1, #0xc000
	movt 	r1, #0x4000

    ldr     r2, ptr_to_mydata

	ldrb	r0, [r1]
	strb 	r0, [r2]

	MOV 	PC,LR      	; Return

;************************************************************************************************** 
; Function name: output_character
; Function behavior: Transmits a character along UART0 for display in console
; 
; Function inputs: 
; r0 - holds the character to be transmitted
; 
; Function returns: 
; nothing
; 
; Registers used 
; r4 : Holds address of data for UART - 0x4000c000
; r5 : Holds address of UART Flags - 0x4000c018
; r6 : Reads in flags, uses AND comparison to check transmission flag (TxFF - bit 5 (16))
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP lr. To return from function MOV pc, lr 
;************************************************************************************************** 
output_character:  
	PUSH {lr}   ; Store register lr on stack
	; Your code to output a character to be displayed in PuTTy
	; is placed here.  The character to be displayed is passed
	; into the routine in r0.
	
	;**********PUSH YOUR REGISTERS*******************
	push {r4-r6}

	; Store address of data in r4
	mov		r4, #0xc000
	movt	r4, #0x4000
	; Store address of flags in r5
	add		r5,	r4, #0x18

	; Load flag register for comparison. Bit flag is 16 decimal for TxFF (Bit 5). Loop continues until
	; flag for transmit is 0.
WAITONTRANSMIT:
		ldrb	r6, [r5]				; Load Flag register, only need first 8bits
		and 	r6, r6, #32				; Flag mask, checking bit 6, TxFF, if 1, repeat loop
		cmp		r6, #0
		bne		WAITONTRANSMIT			; If flag is not zero, continue waiting

	; Store character to be transmitted from r0 into UART data byte
	strb	r0, [r4]
	
	;**********POP YOUR REGISTERS********************
	pop {r4-r6}

	POP {lr}
	mov pc, lr

;***************************************************************************************************
; Function name: read_string
; Function behavior: Reads in a string byte-by-byte until the enter key ASCII value 13 is read. Checks
; my_data register to see if there has been any keyboard strikes detected in PuTTY terminal. Sets value
; of my_data to 0 and loops through. When keypress is detected reflects to screen and rewrites my_data
; to 0. Once enter key is detected, will push '\n' to screen and move location indicator to beginning
; of line and insert \0. 
;
; SPECIAL CASE: If backspace is read in, will decrement pointer by one and return to beginning of loop
; SPECIAL CASE: If enter is read in, jump to end of loop, print newline, insert \0
; 
; Function inputs: 
; r0 : Address offset of string to write to
; 
; Function returns: none
; 
; Registers used: 
; r0 : Holds currently read character
; r4 : Used to access most recently stored character
; r5 : Stores byte offset of string to write to
; r6 : Address that characters are stored to by interrupt
; Subroutines called: 
; output_character
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
read_string:  
	PUSH	{lr}   						; Store register lr on stack
	
	; Push used registers r4, r5 so on return registers will be same
	push 	{r4, r5}
	
	mov		r4, r0						; Move address of string into r4 to preserve
	ldr 	r6, ptr_to_mydata			; Move character storage address into r6
	movw	r5, #0						; Start byte offset at 0

	; Store null character in chracter storage to start string read
	strb	r5, [r6]					; r5 has value null

	; Main loop, loops until enter key is detected to signify end of transmission
read_string_main_loop:
	ldrb 	r0, [r6]					; Get value from storage
	cmp 	r0, #0						; Compare to null value
	beq 	read_string_main_loop		; Reloop if NULL

	cmp		r0, #0x7F					; Check if backspace ASCII 0x7F entered
	beq		backspace_detected			; Jump to backspace case
	bl		output_character			; Reflect character to screen
	cmp		r0, #13						; Check if enter was received
	beq 	read_string_main_loop_end	; End loop
	strb	r0, [r4, r5]				; Store current character
	add 	r5, #1						; Increment index counter
	
	; Reset stored character value to null
	movw 	r0, #0						; Set null character
	strb	r0, [r6]					; Store null character
	b		read_string_main_loop		; Return to start of loop

; If current offset is 0, do nothing and return, otherwise print backspace and decrement offset
backspace_detected:
	cmp		r5, #0						; Check that offset not 0 to prevent memory overun
	beq		no_decrement_needed			; Return to main loop, case nothing to overwrite
	bl 		output_character			; Otherwise print backspace to screen
	add		r5, #-1						; Decrement index
no_decrement_needed:
	; Reset stored character value to null
	movw 	r0, #0						; Set null character
	strb	r0, [r6]					; Store null character	
	b		read_string_main_loop		; Return to start of loop

; After read in loop, since enter key detected, print new lineand store \0 to signify end of
; string
read_string_main_loop_end:
	movw	r0, #10						; ASCII \n
	bl 		output_character			; Print newline
	movw 	r0, #0						; ASCII \0
	strb	r0, [r4, r5]				; Store string terminator

	; Pop pushed registers	
	pop 	{r4, r5}
	
	POP 	{lr}  						; Restore lr from stack
	mov 	pc, lr

;***************************************************************************************************
; Function name: output_string
; Function behavior: Transmits string via UART0 to be written to screen. On new line will reset
; to first column of new write row
; 
; Function inputs: 
; r0 : contains the address of the first byte of the string to be written 
;
; Function returns: None
; 
; Registers used: 
; r4 : Holds the offset address of the string
; r5 : Holds the write loop counter, used as offset when loading byte to be written 
; 
; Subroutines called:  
; output_character | escape_sequences
;
; REMINDER: 13 is the number for 'enter' and the number for carriage return
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
output_string:  
	PUSH	{lr}   						; Store register lr on stack

	; Pushing registers used in function to stack
	push	{r4-r5}

	mov		r4, r0						; Moving address of string into register
	movw	r5, #0						; Setting loop counter to 0
	
	movw	r0, #0						; Zero out the r0 register for use in output character
										; subroutine

	; Following loops through the string until NULL character is detected. For each character
	; calls the output_character function to display character on screen. If '\n'(10 dec) is detected, 
	; transmits carriage return character (13 decimal) to place pointer at proper spot on screen.
output_string_main_loop:
	ldrb	r0, [r4, r5]				; Get character at string address + offset
	cmp		r0, #0						; Check if character is null character
	beq		output_string_main_loop_end ; If null character, end loop
	; Checks if character is '\', if so, pulls next digit from string and calls escape sequence check
	cmp 	r0, #0x5c					; Check against ascii code for '\'
	bne		end_escape_sequence_check
	add		r5, #1						; Increments counter to get next character
	ldrb	r0, [r4, r5]				; Get character at string address + offset
	; Check for null character escape sequence '\0'
	cmp		r0, #0						; Check if character is null character
	beq		output_string_main_loop_end ; If null character, end loop
	bl 		escape_sequences			; Call subroutine to get ASCII code for sequence

end_escape_sequence_check:				
	bl		output_character			; Print character
	cmp		r0, #10						; Check if new line character
	bne 	output_string_inc_and_loop	; If not \n,  increment in loop
	movw	r0, #13						; Otherwise, load character return
	bl		output_character			; Print carriage return
output_string_inc_and_loop:				
	add		r5, #1						; Increment offset by 1 byte
	b 		output_string_main_loop
output_string_main_loop_end:

	; Restoring used registers via pop
	pop 	{r4-r5}

	POP 	{lr}  						; Restore lr from stack
	mov		pc, lr 

;***************************************************************************************************
; Function name: escape_sequences
; Function behavior: Switch statement to determine the ascii value of the escape sequence used. 
; Isolated into own subfuntion for readibility and to prevent confusion in main string output routine.
; Escapes sequences: \a, \b, \f, \n, \r, \t, \v, \\, \', \", \? 
; SPECIAL NOTE: This is unneccesary if .cstring direct is used {?}
;
; Function inputs: 
; r0 : second escape sequence character
; Function returns: 
; r0 : ascii character to be printed next
; Registers used: 
; 
; 
; Subroutines called: 
; output_character
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
escape_sequences:
	PUSH	{lr}   						; Store register lr on stack

	; Switch to determine escape sequence used. It will load r0 with ascii value to be printed, except
	; in default case. Default is indicated by escape sequence not listed above. In default it will 
	; print '\' and return the character passed in by the subroutine call. 
	; Case '\a' 97 -> 7
	cmp		r0, #97
	bne		switch_case_b
	movw	r0, #7
	b	end_and_return_escape_sequences ; end switch
switch_case_b:							; Case '\b' 98-> 8
	cmp 	r0, #98
	bne		switch_case_f
	movw	r0, #8
	b	end_and_return_escape_sequences ; end switch
switch_case_f:							; Case '\f' 102-> 12
	cmp		r0, #102
	bne 	switch_case_n
	movw	r0, #12
	b	end_and_return_escape_sequences ; end switch
switch_case_n:							; Case '\n' 110-> 10
	cmp		r0, #110
	bne 	switch_case_r
	movw	r0, #10
	b	end_and_return_escape_sequences ; end switch
switch_case_r:							; Case '\r' 114-> 13
	cmp 	r0, #114
	bne		switch_case_t
	movw	r0, #13
	b	end_and_return_escape_sequences ; end switch
switch_case_t:							; Case '\t' 116-> 9
	cmp 	r0, #116
	bne		switch_case_v
	movw	r0, #9
	b	end_and_return_escape_sequences ; end switch
switch_case_v:							; Case '\v' 118-> 11
	cmp 	r0, #118
	bne switch_case_slash
	movw	r0, #11
	b	end_and_return_escape_sequences ; end switch
switch_case_slash:						; Case '\\' 92-> 92
	cmp 	r0, #92
	beq	end_and_return_escape_sequences ; end switch
switch_case_quote:						; Case '\'' 39-> 39
	cmp		r0, #39
	beq	end_and_return_escape_sequences ; end switch
switch_case_quotes:						; Case '\"' 34-> 34
	cmp 	r0, #34
	beq	end_and_return_escape_sequences ; end switch
switch_case_quest:						; Case '\?' 63-> 63
	cmp 	r0, #63
	beq	end_and_return_escape_sequences ; end switch
	; Default case. If not one of the recognized escape sequences, will print a '\' and return with
	; passed in value.
switch_case_default:
	push 	{r0}						; Store current character to print
	movw	r0, #0x5c					; Ascii code for '\'
	bl		output_character			; Print '\n'
	pop		{r0}						; Restore r0
end_and_return_escape_sequences:

	POP 	{lr}  						; Restore lr from stack
	mov		pc, lr

;***************************************************************************************************
; Function name: gpio_interrupt_init
; Function behavior: Initializes SW1 and the RGB LED on the main TIVA board. This version also 
; initializes sw1 as an interrupt. 
; 
; Function inputs: None
; 
; Function returns: None
; 
; Registers used: 
; r4 : Address that we'll be writing too 
; r5 : Value to be stored in registers
; r6 : 32 value to be written to CPU interrupt register
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
gpio_interrupt_init:
	PUSH 	{lr}	
    
	; Push registers used in function to stack
    push 	{r4, r5, r6}

	; To share clock with PORT F we need to set bit 6 at address 0x400fe608
	movw	r4, #0xe608					; Load lower half of address
	movt	r4, #0x400f					; Load upper half of address
	ldrb    r5, [r4]                    ; Load current port selections
    orr 	r5,	#0x20					; Set bit 6 - 0b0010.0000 - 0x20
	strb	r5, [r4]					; Load bit set into memory
	
	; The above instruction needs 3 clock cycles to complete clock share

	; Set address in r4 to PORT F base address - 0x4002.5000
	movw	r4, #0x5000					; Load lower half of base address (clock cycle 1)
	movt 	r4, #0x4002					; Load upper half of base address (clock cycle 2)

	; All of the below will use offset immediates to access register.
	
	; Set control of PORTF pins 1-4 (bits 2-5) to digital. Pin 0 (bit 1) is the lower right button
	; Pin 1-3 control RGB and Pin 4 controls the lower left button. GPIODEN is at offset: 0x51c
	movw	r5, #0x1e					; Set bits 1-3 - 0b0000.1110 - 0x1E (clock cycle 3)
	; Clock share has been completed with above instruction
	strb 	r5, [r4, #0x51c]			; Load bit set into memory

	; Set pin direction. Pin 4 is input, pins 1-3 are outputs.  If flagged with 1 will be output, 
	; flagged at 0 will be input. GPIODIR is at offset: 0x400
	movw	r5, #0x0e					; Set bit mask: 0b0000.0000 - 0x10
	strb 	r5, [r4, #0x400]			; Load bit set into memory
				
	; Set pull up resistor on switch. GPIOPUR is at offset: 0x510
	movw	r5, #0x10					; Set bit mask: 0b0001.0000 - 0x10
	strb 	r5, [r4, #0x510]			; Load bit set into memory

	;************************* LAB 5 CHANGE START ******************************;
	; Set pins to detect a falling edge and send an interrupt signal using GIIOIEV
	; Setting a pin high sets it to detect on a rising edge.
	; Note for myself, we want falling edge since it starts at high it will detect
	; initial change. Leave unchanged, removing instruction
	; Register offset: 0x40c   Set to detect push button: 0x10
	; strb 	r5, [r4, #0x40c]			; Instruction removed, want to detect falling edge

	; Unmask pin 4 (SW1) to allow board to detect interrupt on press.
	; Register offset: 0x410  Set to detect push button: 0x10 - 
	strb r5, [r4, #0x410]
	
	; Set bit 31 in processor config. Bit 31 (0x4000.0000) in EOOOE100 to recognize
	; that switch has been pressed.
	movw 	r4, #0xe100
	movt 	r4, #0xe000
	; Using orr and str method to make sure we don't overwrite any other pins that
	; have already been set.
	ldr 	r5, [r4]
	movw 	r6, #0x0000					; Set lower value of bit mask
	movt	r6, #0x4000					; Set upper value
	orr		r5, r5, r6					; Update bitmask
	str		r5, [r4]					; Push updated bit mask
	;************************** LAB 5 CHANGE END *******************************;


	; Pop registers for return
	pop 	{r4, r5, r6}

	POP 	{lr}
	MOV 	pc, lr

;***************************************************************************************************
; Function name: Switch_Handler
; Function behavior: Clears the switch interrupt, toggles player controller positive/negative nibble
; 
; Function inputs: None
; 
; Function returns: None
; 
; Registers used: 
; r0 : Houses addresses to be written 
; r1 : Values to be written to registers/memory
; 
; Subroutines called: 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
Switch_Handler:
	; Function calls other subroutines, push value of lr
	push 	{lr}
	; Store unpreserved registers
	push 	{r4-r11}

	; Load address of PORTF #0x4002.5000 for interrupt clear (GIPIOICR)
	; Offset: 0x41c Pin : 4 (0x10)
	movw 	r0, #0x541c
	movt	r0, #0x4002
	
	; Use EOR to reset interrupt signal on pin 4
	ldrb	r1, [r0]
	eor		r1, r1, #0x10
	strb	r1, [r0]

    ; Toggle direction controller
	ldr		r1, ptr_to_player_control   
	ldr		r0, [r1]					; Load current value
	eor     r0, r0, #0x01               ; Toggle direction nibble
	str		r0, [r1]					; Store new value

	; Pop it like it's haaaaaawt
	pop 	{r4-r11}
	pop 	{lr}
	
	BX 		lr       					; Return



;***************************************************************************************************
; Function name: timer_interrupt_init
; Function behavior: Initializes timer 0 for 32-bit mode, half second intervals.
; 
; Function inputs: none
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
;TIMER OFFSETS
RCGCTIMER: 	    .equ 0x604 	            ;Timer Run Mode Clock Gating Control
GPTMCTL:	    .equ 0x00C 	            ;Timer Control Register
GPTMTAMR: 	    .equ 0x004	            ;Timer A Mode Register
GPTMTAILR:	    .equ 0x028	            ;Timer Interval Load Register
GPTMIMR:	    .equ 0x018	            ;Timer Interrupt Mask Register
GPTMICR:	    .equ 0x024      	    ;Timer Interrupt Clear Register
EN0: 		    .equ 0x100	            ;NVIC Interrupt Enable Register

timer_interrupt_init:
	PUSH    {lr}

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
; Function name: Timer_Handler
; Function behavior: Handles printing the boardstate at each frame. 2 frames per second. Uses the
; player_control byte to determine player facing. 0x1x - Vertical, 0x0x - Horizontal, 0xx1 poisitive,
; 0xx0, negative. Then determines if move would place player outside of valid range. If so, turns off
; timer and sets game flag to true. Otherwise, updates player position and prints new board state.
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : Holds value of player controller
; r1 : Holds player position
; r2 : Ptr addresses
; r3 : Play area address, data manipulation
; r4 : Data manipulation
; r5 : Value 24 for division/multiplication/modulus
; r6 : Holds division/modulus/multiplication values
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
Timer_Handler:
    ; Push register states to preserve values
    push    {lr}
    push    {r4-r11}
    ;CLEAR INTERRUPT
	;load timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;set 1 to clear the interrupt
	LDR     r0, [r1, #GPTMICR]
	ORR     r0, r0, #0x01
	STR     r0, [r1, #GPTMICR]

    ; Load player controller
    ldr     r2, ptr_to_player_control
    ldrb    r0, [r2]
    ; Load player position
    ldr     r2, ptr_to_player_pos
    ldr     r1, [r2]    
    ; Load value 24 for division, modulus, multiplication.
    movw    r5, #24

    ; Check axis value
    and     r4, r0, #0x10
    cmp     r4, #8                      ; If value is greater than 8, follow vertical logic
    bgt     Timer_Handler_vertical

    ; For horizontal movement, we need to use the formula for modulus to determine column value
    ; Valid range is between 1 and 20
    
    ; r1 mod 24
    sdiv    r6, r1, r5                  ; floor(r1/24)
    mul     r6, r6, r5                  ; 24*floor(r1/24)
    sub     r6, r1, r6                  ; r1 - 24*floor(r1/24)

    ; Check for positive or negative direction of movement
    and     r4, r0, #0x01
    cmp     r4, #0                      ; If value is 0, moving in negative direction
    bne     Timer_Handler_horizontal_positive ; otherwise, positive
    cmp     r6, #1                      ; If mod value is 1, then game over man, game over!
    beq     Timer_Handler_game_over
    sub     r0, r1, #1                  ; New player position is current position - 1
    b       Timer_Handler_draw_new_board ; Draw new board.

Timer_Handler_horizontal_positive:
    cmp     r6, #20                     ; If mod value is 20, Game over man, game over!
    beq     Timer_Handler_game_over     
    add     r0, r1, #1                  ; New player position is current position + 1
    b       Timer_Handler_draw_new_board ; Draw new board

Timer_Handler_vertical:
    ; For vertical movment, we use division to determine row value. Valid range is between
    ; 0 and 19
    sdiv    r6, r1, r5                  ; Floor(r1, 24) gives us row value

    ; Check for positive or negative direction of movement
    and     r4, r0, #0x01
    cmp     r4, #0                      ; If value is 0, moving in negative direction
    bne     Timer_Handler_vertical_positive ; otherwise, positive
    cmp     r6, #0                      ; If current row is 0, game over man, game over!
    beq     Timer_Handler_game_over
    sub     r0, r1, r5                  ; New space is current position - 24
    b       Timer_Handler_draw_new_board ; Draw new board


Timer_Handler_vertical_positive:
    cmp     r6, #19                     ; Check if row is currently at max
    beq     Timer_Handler_game_over     ; If so, game over man! game over!
    add     r0, r1, r5                  ; New position is current position + 24
    b       Timer_Handler_draw_new_board ; Draw new board

    ; When getting to this label, r0 should hold new value player position, r1 should hold current
    ; player position
Timer_Handler_draw_new_board:
    str     r0, [r2]                    ; Store new position 
    ldr     r3, ptr_to_play_area        ; Get play area offset
    movw    r2, #' '                    ; Clear current position
    strb    r2, [r3, r1]                ; Remove current marker
    movw    r2, #'X'                    ; Set new player position
    strb    r2, [r3, r0]                ; Write new position
    ldr     r0, ptr_to_board_start      ; Print new board
    bl      output_string               
    b       Timer_Handler_end           ; End and return from interrupt
    
    ; If game over, set flag to true and deactivate timer.
Timer_Handler_game_over:
    ldr     r1, ptr_to_end_game         ; Load endgame flag address
    movw    r0, #1                      ; Load true
    STRB    r0, [r1]                    ; Change value


    ;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;load current status
	LDRB    r0, [r1, #GPTMCTL]
	EOR     r0, r0, #0x3		        ;set bit 0 to 0, set bit 1 to 0
	STRB    r0, [r1, #GPTMCTL]          ;disable timer 0 (A)

Timer_Handler_end:
    ; Push and pop to restore registers
    pop     {r4-r11}
    pop     {lr}
    BX      lr

;***************************************************************************************************
; Function name: reset_game
; Function behavior: Sets the initial board state of the game.
; Initial states:
; Player Position - 226
; Player Controller - 0x01 - Horizontal, positive direction
; End game boolean - 0 (false)
;
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r0 : value manipulation
; r1 : data addresses
; r2 : play area address
; r3 : character value
; 
; Subroutines called: none
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
reset_game:
    ; Set player control byte
    ldr     r1, ptr_to_player_control       ; Load address
    mov     r0, #0x00                       ; Load initial value
    strb    r0, [r1]                        ; Set initial value

    ; Set game control flag
    ldr     r1, ptr_to_end_game             ; Load address
    mov     r0, #0                          ; Load initial value
    strb    r0, [r1]                        ; Set initial value

    ; Reset player marker
    ldr     r1, ptr_to_player_pos           ; Load player position address
    ldr     r0, [r1]                        ; Get value at address
    ldr     r2, ptr_to_play_area            ; Load address to play area
    movw    r3, #' '                        ; Load space character
    strb    r3, [r2, r0]                    ; Clear previous marker
    movw    r0, #226                        ; Load initial value
    movw    r3, #'X'                        ; Load player marker
    strb    r3, [r2, r0]                    ; Store player marker
    str     r0, [r1]                        ; Store starting position

    ;Start frame timer
	;set r1 to timer 0 base address
	MOV     r1, #0x0000
	MOVT    r1, #0x4003

	;load current status
	LDRB    r0, [r1, #GPTMCTL]
	ORR     r0, r0, #0x3		        ;set bit 0 to 1, set bit 1 to 1 to allow debugger to stop timer
	STRB    r0, [r1, #GPTMCTL]          ;enable timer 0 (A) for use

    mov     pc, lr

;***************************************************************************************************
; Function name: get_state
; Function behavior: Helper function for main output. Returns game state flag.
; 
; Function inputs: none
; 
; Function returns: 
; r0 : game state value
; 
; Registers used: 
; r1 : address of flag
; 
; Subroutines called: none
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
get_state:

    ldr     r1, ptr_to_end_game
    ldrb    r0, [r1]

    mov     pc, lr 

    .end
