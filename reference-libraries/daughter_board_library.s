    .text

    .global illuminate_LEDs
    .global read_from_push_btns
    .global read_keypad
    .global initialize_daughter_board



;***************************************************************************************************
; Function name: illuminate_LEDs
; Function behavior: Takes validated input parameter r0 and loads into PORT B data segment to
; illuminate the proper lights.
; 
; Function inputs: 
; r0 : validated pin configuration for lights. Pins 0-3 control lights in PORT B so valid input 
; 	   is between 0x0 (off) and 0xF
; 
; Function returns: none
; 
; Registers used: 
; r4 : holds the address of PORT B data - 0x4000.53fc
; 
; Subroutines called: none
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
illuminate_LEDs: 
    PUSH	{lr}	
    
	; Push registers used by this routine
    push	{r4}
 
	; Set address in r4 to PORT B data address - 0x4000.53fc
	movw	r4, #0x53fc					; Load lower half of base address
	movt 	r4, #0x4000					; Load upper half of base address

	; Stores value parameter in r0 to memory
	strb 	r0, [r4]

	; Pop used registers
	pop 	{r4}

	POP 	{lr}
	MOV 	pc, lr 


;***************************************************************************************************
; Function name: read_from_push_btns 
; Function behavior: Reads from PORT D data switches at address 0x4000.73fc. Uses eor instruction to
; get value of pressed pins and returns value to main in r0. Pin value of 1 denotes pressed pin
; 
; Function inputs: none
; 
; Function returns: 
; r0 : Value of pressed switch(es)
; 
; Registers used: 
; r4 : holds PORT D data address
; 
; Subroutines called: none
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
read_from_push_btns: 
    PUSH	{lr}	
    
	; Push registers used by this routine
	push 	{r4}

    ; Load address of PORT D data into r4 - 0x4000.73fc
	movw 	r4, #0x73fc
	movt 	r4,	#0x4000

	ldrb	r0, [r4]					; Get current value of switches
    
    ; Pop used registers
	pop 	{r4}

	POP 	{lr}
	MOV 	pc, lr 

;***************************************************************************************************
; Function name: read_keypad
; Function behavior: Cyles the power to each pin on PORT D and reads data from PORT A. If pin 2-5
; is showing value of 1, will use cross chart to return character pressed
; SPECIAL NOTE: Documentation for the board directs that we should set the pin 2-5 to high individually 
; and check for port d pin values to determine which button was pressed
; 
; Function inputs: none
; 
; Function returns: 
; r0 : returns character value or 0 if no keypress detected
; 
; Registers used: 
; r4 : holds address of port D data, will be reading to check character return value
; r5 : holds byte value at address of PORT A data 0x4000.43fc / holds value to set to PUR
; r6 : holds address of port A data to set pins 2-5 for matrix
; 
; Subroutines called: none 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
read_keypad: 
    PUSH	{lr}	
    
	; Push registers used by this routine
    push 	{r4, r5, r6}

	; Load address of port a data segment
	movw 	r6, #0x43fc					; Load lower address of Port A GPIOPUR
	movt	r6, #0x4000					; Load upper address of Port A GPIOPUR

	; Load address of port d data segment
	movw 	r4, #0x73fc					; Load lower address of Port D data
	movt	r4, #0x4000					; Load upper address of Port D data
	
	; Set default return value into return register r0.
	movw 	r0, #0						; Start initial value in r0 at 0, default return
    
	; Activate pin 2, port A
	movw 	r5, #0x04					; Load 0b0000.0100
    strb 	r5, [r6]					; Set pin
	bl 		noop
	ldrb	r5, [r4]					; Load value of port D data 
	cmp 	r5, #0						; If value == 0, no port d pins have power
	beq		read_keypad_port_a_pin_3	; Check next pin
	cmp 	r5, #1						; Check if pin 0 set
	bne 	read_keypad_port_a_pin_2_d1 ; Check next character
	movw	r0, #'1'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_2_d1:
	cmp 	r5, #2						; Check if pin 1 set
	bne 	read_keypad_port_a_pin_2_d2 ; Check next character
	movw	r0, #'4'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_2_d2:
	cmp 	r5, #4						; Check if pin 2 set
	bne 	read_keypad_port_a_pin_2_d3 ; Check next character
	movw	r0, #'7'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_2_d3:
	movw	r0, #'*'					; Set return value character
	b 		read_keypad_reset_and_return

read_keypad_port_a_pin_3:
	; Activate pin 3, port A
	movw 	r5, #0x08					; Load 0b0000.1000
    strb 	r5, [r6]					; Set pin
	bl 		noop
	ldrb	r5, [r4]					; Load value of port D data 
	cmp 	r5, #0						; If value == 0, no port d pins have power
	beq		read_keypad_port_a_pin_4	; Check next pin
	cmp 	r5, #1						; Check if pin 0 set
	bne 	read_keypad_port_a_pin_3_d1 ; Check next character
	movw	r0, #'2'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_3_d1:
	cmp 	r5, #2						; Check if pin 1 set
	bne 	read_keypad_port_a_pin_3_d2 ; Check next character
	movw	r0, #'5'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_3_d2:
	cmp 	r5, #4						; Check if pin 2 set
	bne 	read_keypad_port_a_pin_3_d3 ; Check next character
	movw	r0, #'8'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_3_d3:
	movw	r0, #'0'					; Set return value character
	b 		read_keypad_reset_and_return

read_keypad_port_a_pin_4:
	; Activate pin 4, port A
	movw 	r5, #0x10					; Load 0b0001.0000
    strb 	r5, [r6]					; Set pin
	bl 		noop
	ldrb	r5, [r4]					; Load value of port D data 
	cmp 	r5, #0						; If value == 0, no port d pins have power
	beq		read_keypad_port_a_pin_5	; Check next pin
	cmp 	r5, #1						; Check if pin 0 set
	bne 	read_keypad_port_a_pin_4_d1 ; Check next character
	movw	r0, #'3'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_4_d1:
	cmp 	r5, #2						; Check if pin 1 set
	bne 	read_keypad_port_a_pin_4_d2 ; Check next character
	movw	r0, #'6'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_4_d2:
	cmp 	r5, #4						; Check if pin 2 set
	bne 	read_keypad_port_a_pin_4_d3 ; Check next character
	movw	r0, #'9'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_4_d3:
	movw	r0, #0x23					; Set return value character, hash '#' character
	b 		read_keypad_reset_and_return

read_keypad_port_a_pin_5:
	; Activate pin 5, port A
	movw 	r5, #0x20					; Load 0b0010.0000
    strb 	r5, [r6]					; Set pin
	bl 		noop
	ldrb	r5, [r4]					; Load value of port D data 
	cmp 	r5, #0						; If value == 0, no port d pins have power
	beq		read_keypad_reset_and_return
	cmp 	r5, #1						; Check if pin 0 set
	bne 	read_keypad_port_a_pin_5_d1 ; Check next character
	movw	r0, #'A'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_5_d1:
	cmp 	r5, #2						; Check if pin 1 set
	bne 	read_keypad_port_a_pin_5_d2 ; Check next character
	movw	r0, #'B'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_5_d2:
	cmp 	r5, #4						; Check if pin 2 set
	bne 	read_keypad_port_a_pin_5_d3 ; Check next character
	movw	r0, #'C'					; Set return value character
	b 		read_keypad_reset_and_return
read_keypad_port_a_pin_5_d3:
	movw	r0, #'D'					; Set return value character
	b 		read_keypad_reset_and_return


read_keypad_reset_and_return:
	; Turn off all pins in PORT A
	movw 	r5, #0						; Load 0 to clear pins
	strb 	r5, [r6]					; Turn off all output pins (2-5)

	; Pop used registers
    pop 	{r4, r5, r6}

	POP 	{lr}
	MOV 	pc, lr 


;***************************************************************************************************
; Function name: initialize_daughter_board
; Function behavior: Initializes PORTA, PORTB, and PORTD. Sets the clock and initial values for input
; and output. Sets necessary pins to digital. Initializing keypad, leds and sw2-sw5
; 
; Function inputs: none
; 
; Function returns: none
; 
; Registers used: 
; r4 : Holds address offset
; r5 : Miscellaneous register
; 
; Subroutines called: 
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
initialize_daughter_board:
    PUSH	{lr}	
    
	; Push registers used by this routine
    push 	{r4, r5}

	; To share clock with PORTS A,B, and D we need to set bits at address 0x400fe608
	movw	r4, #0xe608					; Load lower half of address
	movt	r4, #0x400f					; Load upper half of address
	ldrb    r5, [r4]                    ; Load current port selections
    orr 	r5,	#0x0b					; Set bit 0,1,4 - 0b0000.1011 - 0x0B
	strb	r5, [r4]					; Load bit set into memory
	
	; The above instruction needs 3 clock cycles to complete clock share

	; Load base address of port A, pin pad, 0x4000.4000
	movw 	r4, #0x4000					; Load lower half of address (1 clock cycles)
    movt	r4, #0x4000					; Load upper half of address (2 clock cycles)
	
	; Set bits 3-6 for digital read in GPIODEN - offset 0x51c
	movw	r5, #0x3c					; Set bits 3-6 : 0b0011.1100 - 0x3C (3 clock cycles)
	; We can now write to ports we shared clock with
	strb	r5, [r4, #0x51c]			; Set pins

	; Set pin direction. Pins 0-3 are outputs. Set for keypad matrix check. GPIODIR is at offset: 0x400
	strb 	r5, [r4, #0x400]			; Load bit set into memory
	

	; Change offset address to Port B, LEDs, 0x4000.5000
	add 	r4, #0x1000					; Previous stored address was 0x4000.4000
	
	; We will be setting pins 0-3 for both digital read and output. Have to set pins to 1
	; Pins will be set in GPIODEN - offset 0x51c and GPIODIR - offset 0x400
	movw	r5, #0x0f					; Load pin value - 0b0000.1111 - 0x0f
	strb	r5, [r4, #0x51c]			; Set pins
	strb	r5, [r4, #0x400]			; Set pins

	; Change offset to PORT D, 0x4000.4000
	add 	r4, #0x2000					; Previous stored address was 0x4000.5000
	; We will be setting pins 0-3 for digital read in GPIODEN - offset 0x51c
	; Previous instruction already stored 0x0f - 0b0000.1111 - 0x0f
	strb	r5, [r4, #0x51c]			; Set pins

    ; Pop used registers
	pop		{r4, r5}

	POP 	{lr}
	MOV 	pc, lr 



noop:
	push 	{lr}
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2		
	and 	r2, r2
	pop		{lr}
	mov 	pc, lr		


	.end 