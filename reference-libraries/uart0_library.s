    .data

    .global mydata
    
    .text

    .global uart_init
    .global uart_interrupt_init
    .global UART0_Handler
    .global simple_read_character
    .global output_character
    .global read_string
    .global output_string
    .global int2string
    .global string2int

    .global mydata 
    
mydata:         .byte   0               ; Holds keypad interrupt value

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
; the value of the keystroke that initiated the interrupt
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
	ldr 	r0, ptr_to_mydata			; Load address to pass to simple read char func
	bl 		simple_read_character		; Call simple read character function

	; Increment counter for times interrupted
	ldr 	r0, ptr_to_read_count		; Load address of counter
	ldr		r1, [r0]					; Load value of counter
	add 	r1, #1						; Increment counter
	str		r1, [r0]					; Store counter

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
; Function returns: none
; 
; Registers used: 
; r1 : Address of UART0 data
; r2 : Data manipulation
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

	ldrb	r2, [r1]
	strb 	r2, [r0]

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
; r1 : Address that read character stores characters in
; 
; Function returns: none
; 
; Registers used: 
; r0 : Holds currently read character
; r4 : Used to access most recently stored character
; r5 : Stores byte offset of string to write to
; r6 : Preserves address of character storage across calls
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
	mov 	r6, r1						; Move character storage address into r6
	movw	r5, #0						; Start byte offset at 0

	; Store null character in chracter storage to start string read
	strb	r5, [r6]					; r5 has value null

	; Main loop, loops until enter key is detected to signify end of transmission
read_string_main_loop:
	ldrb 	r0, [r6]					; Get value from storage
	cmp 	r0, #0						; Compare to null value
	beq 	read_string_main_loop		; Reloop if NULL

	cmp		r0, #127					; Check if backspace ASCII 127 entered
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
; Function name: int2string
; Function behavior: Converts an integer to a string. First counts number of digits in the string by
; dividing by 10. Then reverse iterates string to correctly place digits. Uses formula for remainder
; to iterate get decimal place value at each junction n mod 10 = n - (10*floor (n/10)). Stores in 
; string index, divides number by 10 and loops again.
; SPECIAL CASE: Passed integer is 0, store '0' and \0
; 
; Function inputs: 
; r0 : integer for conversion 
; r1 : Address of string storage
;
; Function returns: none
; 
; Registers used: 
; r4 : Holds copy of integer for digit count/remainder to store in string
; r5 : digit counter/loop counter/string offset
; r6 : holds 10 for division and multiplication
; 
; Subroutines called: 
; none
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
int2string:  
	PUSH	{lr}   						; Store register lr on stack

	; Push used registers
	push 	{r4-r6}

	movw 	r6, #10						; Load decimal 10 into r6 for div/mul

	; Use division do determine number of places in digit. 
	mov		r4, r0						; Load integer into r4
	movw	r5, #0						; Load 0 for use as counter/offset

digit_count_begin:
	cmp		r4, #0						; If r4 == 0
	beq		digit_count_end				; Stop counting digits
	; Otherwise, divide integer by 10 and increment counter
	sdiv 	r4, r4, r6					; r4/10
	add		r5, #1						; Increment counter
	b 		digit_count_begin			; Restart loop

digit_count_end:
	; Special case, number entered is 0
	cmp 	r5, #0						; r5 != 0?
	bne		int2string_null_char		; skip next step
	movw	r4, #'0'					; Load ASCII '0'
	strb	r4, [r1]					; Store ASCII '0'
	strb	r5,	[r1, #1]				; Store null character
	b 		int2string_finish_and_return; Finish and return

	; Store the null character at size string index.
int2string_null_char:
	movw	r4, #0						; Load \0 character
	strb	r4, [r1, r5]				; Store null terminator
	add 	r5, #-1						; Decrement counter

	; For each string index, get the value of int mod 10 and store at index, then reduce 
	; integer by power of 10 with division until all digits have been stringified
int2string_main_loop:
	
	; Begin modulus formula
	sdiv 	r4, r0, r6  				; floor (n/10)
	mul		r4, r4, r6					; 10 * floor(n/10)
	sub		r4, r0, r4					; n - 10*floor(n/10)

	; Convert to ascii character and store
	add 	r4, #'0'					; Int + ASCII '0' to get ASCII value
	strb	r4, [r1, r5]				; Store character at address + offset
	
	; Decrease int by power of 10
	sdiv 	r0, r0, r6					; int / 10

	; Decrement and compare
	add 	r5, #-1						; Decrement
	cmp		r5, #-1						; If r5 != -1
	bne		int2string_main_loop		; Loop again


int2string_finish_and_return:

	; Pop used registers
	pop 	{r4-r6}

	POP 	{lr}  						; Restore lr from stack
	mov 	pc, lr

;***************************************************************************************************
; Function name: string2int
; Function behavior: Takes in an integer string. For each string, multiplies current value of
; r0 by 10 and adds the new index value to create decimal integer.
; SPECIAL CASE: Empty string, returns invalid
; 
; Function inputs: 
; r0 : address offset of string
; 
; Function returns: 
; r0 : holds integer value of string or -1 on failure (string character x > 9 or x < 0)
; 
; Registers used: 
; r4 : address we'll store string in
; r5 : current string index character
; r6 : holds the value ten for multiplication
;
; Subroutines called: 
; none 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
string2int:  
	PUSH	{lr}   						; Store register lr on stack

	; Push used registers to stack so return in same condition received
	push 	{r4-r6}

	mov		r4, r0						; Store string address offset in r4
	movw	r0, #0						; Set starting value of integer to 0
	movw	r6, #10						; Set 10 to register for multiplication
	ldrb	r5, [r4]					; Check if empty string
	cmp 	r5, #0						; If string is empty, return failed
	beq 	entry_was_invalid			; Return invalid	

	; Main loop. Will create decimal integer
string2int_main_loop:
	ldrb	r5, [r4]					; Get byte from string	
	cmp		r5, #0						; If null terminator, end loop successfully
	beq		string2int_main_loop_end	; End loop
	cmp 	r5, #'0'					; x < '0'?
	blt		entry_was_invalid			; End in failure
	cmp		r5, #'9'					; x > '9'?
	bgt		entry_was_invalid			; End in failure
	sub 	r5, #'0'					; Subtract ASCII value of 0 from character to get int value
	
	; If valid input, then we will use the formula (r0 * 10) + r5 to get value
	mul		r0, r6						; r0*10
	add		r0, r5						; (r0*10) + r5
	
	; Increment address by one byte and reloop
	add		r4, #1						; inc address 1 byte
	b 		string2int_main_loop		; Loop again

	; Called when the string character is less than '0' or greater than '9' indicating user error.
	; Moves -1 into r0 for return to be parsed by calling routine
entry_was_invalid:
	movw	r0, #0						; Zero out r0						
	add		r0, #-1						; Move -1 into r0 to indicate failure

string2int_main_loop_end:

	; Pop used register from stack
	pop 	{r4-r6}

	POP 	{lr}  						; Restore lr from stack
	mov 	pc, lr

    .end