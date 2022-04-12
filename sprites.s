    .data

zero:               .string 27, "[30;40m      ", 27, "[1B", 27, "[6D"  
                    .string 27, "[30;40m      ", 27, "[1B", 27, "[6D" 
                    .string 27, "[30;40m      ", 0
two:                .string 27, "[30;41m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;41m  2   ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;41m      ", 0
four:               .string 27, "[30;42m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;42m  4   ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;42m      ", 0
eight:              .string 27, "[30;43m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;43m  8   ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;43m      ", 0
sixteen:            .string 27, "[30;44m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;44m  16  ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;44m      ", 0
thirtytwo:          .string 27, "[30;45m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;45m  32  ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;45m      ", 0
sixtyfour:          .string 27, "[30;46m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;46m  64  ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;46m      ", 0
onetwentyeight:     .string 27, "[30;47m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;47m 128  ", 27, "[1B", 27, "[6D"
                    .string 27, "[30;47m      ", 0
twofiftysix:        .string 27, "[38;5;0m",27,"[48;5;9m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;9m 256  ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;9m      ", 0
fivetwelve:         .string 27, "[38;5;0m",27,"[48;5;10m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;10m 512  ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;10m      ", 0
tentwentyfour:      .string 27, "[38;5;0m",27,"[48;5;11m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;11m 1024 ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;11m      ", 0
twentyfortyeight:   .string 27, "[38;5;0m",27,"[48;5;12m      ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;12m 2048 ", 27, "[1B", 27, "[6D"
                    .string 27, "[38;5;0m",27,"[48;5;12m      ", 0



    .text
    
    .global get_sprite

ptr_to_zero:                .word zero
ptr_to_two:                 .word two
ptr_to_four:                .word four
ptr_to_eight:               .word eight
ptr_to_sixteen:             .word sixteen
ptr_to_thirtytwo:           .word thirtytwo
ptr_to_sixtyfour:           .word sixtyfour
ptr_to_onetwentyeight:      .word onetwentyeight
ptr_to_twofiftysix:         .word twofiftysix
ptr_to_fivetwelve:          .word fivetwelve
ptr_to_tentwentyfour:       .word tentwentyfour
ptr_to_twentyfortyeight:    .word twentyfortyeight


;***************************************************************************************************
; Function name: get_sprite
; Function behavior: Takes in a number from the shadow board and returns address to the top/bottom
; sprite string
; 
; Function inputs: 
; r0 : number value of sprite
;
; Function returns: 
; r0 : returns offset to sprite string
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
get_sprite:
    cmp     r0, #0
    bne     get_sprite_2
    ldr     r0, ptr_to_zero
    b       get_sprite_end

get_sprite_2:
    cmp     r0, #2
    bne     get_sprite_4
    ldr     r0, ptr_to_two
    b       get_sprite_end
    
get_sprite_4:
    cmp     r0, #4
    bne     get_sprite_8
    ldr     r0, ptr_to_four
    b       get_sprite_end

get_sprite_8:
    cmp     r0, #8
    bne     get_sprite_16
    ldr     r0, ptr_to_eight
    b       get_sprite_end

get_sprite_16:
    cmp     r0, #16
    bne     get_sprite_32
    ldr     r0, ptr_to_sixteen
    b       get_sprite_end
    
get_sprite_32:
    cmp     r0, #32
    bne     get_sprite_64
    ldr     r0, ptr_to_thirtytwo
    b       get_sprite_end
    
get_sprite_64:
    cmp     r0, #64
    bne     get_sprite_128
    ldr     r0, ptr_to_sixtyfour
    b       get_sprite_end
    
get_sprite_128:
    cmp     r0, #128
    bne     get_sprite_256
    ldr     r0, ptr_to_onetwentyeight
    b       get_sprite_end
    
get_sprite_256:
    cmp     r0, #256
    bne     get_sprite_512
    ldr     r0, ptr_to_twofiftysix
    b       get_sprite_end
    
get_sprite_512:
    cmp     r0, #512
    bne     get_sprite_1024
    ldr     r0, ptr_to_fivetwelve
    b       get_sprite_end
    
get_sprite_1024:
    cmp     r0, #1024
    bne     get_sprite_2048
    ldr     r0, ptr_to_tentwentyfour
    b       get_sprite_end
    
get_sprite_2048:
    ldr     r0, ptr_to_twentyfortyeight
    
; Template in case I need it later.   
;get_sprite_:
;    cmp     r0, #
;    bne     get_sprite_
;    ldr     r0, ptr_to
;    b       get_sprite_end
    
get_sprite_end:
    mov     pc, lr
    
    .end