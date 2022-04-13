    .data
mydata:         .byte   0


    .text
    
    .global uart_init
    .global output_string
	.global int2string

ptr_to_mydata:  .word   mydata

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


    .end