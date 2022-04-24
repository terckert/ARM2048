    .data

    .global pause_game

    .text

    .global illuminate_RGB_LED 
    .global gpio_interrupt_init
    .global Switch_Handler
    .global read_from_push_btns
    .global initialize_daughter_board


;GPIO Register OFFSETS
DIR: .equ 0x400		;port direction register
DEN: .equ 0x51C		;port digital enable
DATA: .equ 0x3FC	;gpio data offset
PUR: .equ 0x510		;pull-up resistor offset


;***************************************************************************************************
; Function name: illuminate_RGB_LED
; Function behavior: Takes in an even value between 0x00 and 0x0e. Uses parameter value to set pins
; for red, green, or blue. Pin 1 (bit 2) controls red, pin 2 (bit 3) controls green, pin 3 (bit 4)
; controls blue light.
; 
; Function inputs: 
; r0 : value to set pins to 
;
; Function returns: none
; 
; Registers used: 
; r4 : Holds 0x4002.5000, address of PORTF data
; 
; Subroutines called: none
; 
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
illuminate_RGB_LED:
	PUSH	{lr}	
    
	; Push registers used by this routine
    push	{r4}
 
	; Set address in r4 to PORT F data address - 0x4002.53fc
	movw	r4, #0x53fc					; Load lower half of base address
	movt 	r4, #0x4002					; Load upper half of base address

	; Stores value parameter in r0 to memory
	strb 	r0, [r4]

	; Pop used registers
	pop 	{r4}

	POP 	{lr}
	MOV 	pc, lr 

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
	strb 	r5, [r4, #DEN]			; Load bit set into memory

	; Set pin direction. Pin 4 is input, pins 1-3 are outputs.  If flagged with 1 will be output, 
	; flagged at 0 will be input. GPIODIR is at offset: 0x400
	movw	r5, #0x0e					; Set bit mask: 0b0000.0000 - 0x10
	strb 	r5, [r4, #DIR]			; Load bit set into memory
				
	; Set pull up resistor on switch. GPIOPUR is at offset: 0x510
	movw	r5, #0x10					; Set bit mask: 0b0001.0000 - 0x10
	strb 	r5, [r4, #PUR]			; Load bit set into memory

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
; Function behavior: Clears the switch interrupt, increments the SW1 counter, and for testing purposes
; toggles the RGB LED (cold blue)
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
; pause_game
; 
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;*************************************************************************************************** 
Switch_Handler:
	; Function calls other subroutines, push value of lr
	push 	{lr}
	; Store unpreserved registers
	push 	{r4-r11}

	; Move 0 into r0 as parameter for pause_game (standard menu print)
    movw    r0, #0
    bl      pause_game

	; Load address of PORTF #0x4002.5000 for interrupt clear (GIPIOICR)
	; Offset: 0x41c Pin : 4 (0x10)
	movw 	r0, #0x541c
	movt	r0, #0x4002
	
	; Use EOR to reset interrupt signal on pin 4
	ldrb	r1, [r0]
	eor		r1, r1, #0x10
	strb	r1, [r0]


	; Pop it like it's haaaaaawt
	pop 	{r4-r11}
	pop 	{lr}
	
	BX 		lr       					; Return

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
	;movw	r5, #0x3c					; Set bits 3-6 : 0b0011.1100 - 0x3C (3 clock cycles)

	LDR		r5, [r4, #DEN]			; load the current value (in case UART0 is set,
										; this won't overwrite previous values)]

	ORR		r5, r5, #0x3C				; ORR with 0x3C to set bits 3-6

	; We can now write to ports we shared clock with
	strb	r5, [r4, #DEN]			; Set pins

	; Set pin direction. Pins 0-3 are outputs. Set for keypad matrix check. GPIODIR is at offset: 0x400
	strb 	r5, [r4, #DIR]			; Load bit set into memory
	

	; Change offset address to Port B, LEDs, 0x4000.5000
	add 	r4, #0x1000					; Previous stored address was 0x4000.4000
	
	; We will be setting pins 0-3 for both digital read and output. Have to set pins to 1
	; Pins will be set in GPIODEN - offset 0x51c and GPIODIR - offset 0x400
	movw	r5, #0x0f					; Load pin value - 0b0000.1111 - 0x0f
	strb	r5, [r4, #DEN]			; Set pins
	strb	r5, [r4, #DIR]			; Set pins

	; Change offset to PORT D, 0x4000.4000
	add 	r4, #0x2000					; Previous stored address was 0x4000.5000
	; We will be setting pins 0-3 for digital read in GPIODEN - offset 0x51c
	; Previous instruction already stored 0x0f - 0b0000.1111 - 0x0f
	strb	r5, [r4, #DEN]			; Set pins

    ; Pop used registers
	pop		{r4, r5}

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


    .end
