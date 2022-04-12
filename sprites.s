    .data

0tb:        .string 27, "[30;40m      ",0
2tb:        .string 27, "[30;41m      ",0
2main:      .string 27, "[30;41m   2  ",0
4tb:        .string 27, "[30;42m      ",0
4main:      .string 27, "[30;42m   4  ",0
8tb:        .string 27, "[30;43m      ",0
8main:      .string 27, "[30;43m   8  ",0
16tb:       .string 27, "[30;44m      ",0
16main:     .string 27, "[30;44m  16  ",0
32tb:       .string 27, "[30;45m      ",0
32main:     .string 27, "[30;45m  32  ",0
64tb:       .string 27, "[30;46m      ",0
64main:     .string 27, "[30;46m  64  ",0
128tb:      .string 27, "[30;47m      ",0
128main:    .string 27, "[30;47m  128 ",0
256tb:      .string 27, "[38;5;0m",27,"[48;5;9m      ",0
256main:    .string 27, "[38;5;0m",27,"[48;5;9m  256 ",0
512tb:      .string 27, "[38;5;0m",27,"[48;5;10m      ",0
512main:    .string 27, "[38;5;0m",27,"[48;5;10m  512 ",0
1024tb:     .string 27, "[38;5;0m",27,"[48;5;11m      ",0
1024main:   .string 27, "[38;5;0m",27,"[48;5;11m 1024 ",0
2048tb:     .string 27, "[38;5;0m",27,"[48;5;12m      ",0
2048main:   .string 27, "[38;5;0m",27,"[48;5;12m 2048 ",0



    .text
    
    .global get_sprite


ptr_to_0tb:         .word  0tb  
ptr_to_2tb:         .word  2tb     
ptr_to_2main:       .word  2main       
ptr_to_4tb:         .word  4tb     
ptr_to_4main:       .word  4main       
ptr_to_8tb:         .word  8tb     
ptr_to_8main:       .word  8main       
ptr_to_16tb:        .word  16tb      
ptr_to_16main:      .word  16main        
ptr_to_32tb:        .word  32tb      
ptr_to_32main:      .word  32main        
ptr_to_64tb:        .word  64tb      
ptr_to_64main:      .word  64main        
ptr_to_128tb:       .word  128tb       
ptr_to_128main:     .word  128main         
ptr_to_256tb:       .word  256tb       
ptr_to_256main:     .word  256main         
ptr_to_512tb:       .word  512tb       
ptr_to_512main:     .word  512main         
ptr_to_1024tb:      .word  1024tb        
ptr_to_1024main:    .word  1024main          
ptr_to_2048tb:      .word  2048tb        
ptr_to_2048main:    .word  2048main          

;***************************************************************************************************
; Function name: get_sprite
; Function behavior: Takes in a number from the shadow board and returns address to the top/bottom
; sprite string
; 
; Function inputs: 
; r0 : number value of sprite
;
; Function returns: 
; r0 : top/bottom string
; r1 : main string
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
    ldr     r0, ptr_to_0tb
    ldr     r1, ptr_to_0tb
    b       get_sprite_end

get_sprite_2:
    cmp     r0, #2
    bne     get_sprite_4
    ldr     r0, ptr_to_2tb
    ldr     r1, ptr_to_2main
    b       get_sprite_end
    
get_sprite_4:
    cmp     r0, #4
    bne     get_sprite_8
    ldr     r0, ptr_to_4tb
    ldr     r1, ptr_to_4main
    b       get_sprite_end

get_sprite_8:
    cmp     r0, #8
    bne     get_sprite_16
    ldr     r0, ptr_to_8tb
    ldr     r1, ptr_to_8main
    b       get_sprite_end

get_sprite_16:
    cmp     r0, #16
    bne     get_sprite_32
    ldr     r0, ptr_to_16tb
    ldr     r1, ptr_to_16main
    b       get_sprite_end
    
get_sprite_32:
    cmp     r0, #32
    bne     get_sprite_64
    ldr     r0, ptr_to_32tb
    ldr     r1, ptr_to_32main
    b       get_sprite_end
    
get_sprite_64:
    cmp     r0, #64
    bne     get_sprite_128
    ldr     r0, ptr_to_64tb
    ldr     r1, ptr_to_64main
    b       get_sprite_end
    
get_sprite_128:
    cmp     r0, #128
    bne     get_sprite_256
    ldr     r0, ptr_to_128tb
    ldr     r1, ptr_to_128main
    b       get_sprite_end
    
get_sprite_256:
    cmp     r0, #256
    bne     get_sprite_512
    ldr     r0, ptr_to_256tb
    ldr     r1, ptr_to_256main
    b       get_sprite_end
    
get_sprite_512:
    cmp     r0, #512
    bne     get_sprite_1024
    ldr     r0, ptr_to_512tb
    ldr     r1, ptr_to_512main
    b       get_sprite_end
    
get_sprite_1024:
    cmp     r0, #1024
    bne     get_sprite_2048
    ldr     r0, ptr_to_1024tb
    ldr     r1, ptr_to_1024main
    b       get_sprite_end
    
get_sprite_2048:
    ldr     r0, ptr_to_2048tb
    ldr     r1, ptr_to_2048main
    

    
get_sprite_:
    cmp     r0, #
    bne     get_sprite_
    b       get_sprite_end
    
get_sprite_:
    cmp     r0, #
    bne     get_sprite_
    b       get_sprite_end
get_sprite_:
    cmp     r0, #
    bne     get_sprite_
    
get_sprite_end:

    .end