                        * = $1000
baseMSB = #$20
baseLSB = #$00
videoadrLSB = $fa
videoadrMSB = $fb
regbase = $d000
whiteblack = #$f0
videocolorbase = $0400
dir = $f3                                   ; ant dir        
right = #0
up = #64
left = #128
down = #192
scrMemLSB = $ea
scrMemMSB = $eb
scrBitFlag = $e8

start                   ; Configure HI RES display         
                        lda #$3b            ; Bit 5 on                
                        sta regbase + 17    ; Reg 17 Bit 5 enable high res                  
                        lda #$18            ; Point to high res memory map                 
                        sta regbase + 24    ; Reg 24                   

                        lda baseLSB
                        sta videoadrLSB
                        lda baseMSB
                        sta videoadrMSB

                        ; Set color in 25*40 grid to black and white       
                        lda whiteblack      ; msb nybble is on color, lsb is off          
                        ldy #0              ; Counter count down from 0 and loop                
resetcolor              sta videocolorbase,y  ; Easier and faster than using 16 bit adressing                
                        sta videocolorbase + $0100,y 
                        sta videocolorbase + $0200,y 
                        sta videocolorbase + $0300,y 
                        dey                 ;starts with zero so wraps around first to ff         
                        bne resetcolor

                        lda #0              ; turn all bits in bitmap off                
                        ldy #0              ; clear y (iterator)		                
resetscreenmem          sta (videoadrLSB),y  ; Store in fb,fa location+y                
                        iny 
                        bne resetscreenmem
                        ldx videoadrMSB     ; load msb of loop range                
                        inx                 ; inx                 
                        stx videoadrMSB     ; save stored value back                
                        cpx #$40            ; we count to 3fff (I think, if we count to far it is only sprite memory I think)                  
                        bne resetscreenmem
                        ; store dir in f3            
                        lda #0              ; dir 0           
                        sta dir
                        ; Set bitflag and xy position  
                        lda #%00010000
                        sta scrBitFlag
                        lda #$2f            ;position middle   
                        sta scrMemMSB
                        lda #$a3            ;position middle   
                        sta scrMemLSB
                        ; flip color by xor with bit              
loop                    lda scrBitFlag      ; load bit flag for which bit to turn on               
                        ldy #0              ; not sure how to do without index              
                        eor (scrMemLSB),y   ; use eor to flip value of black and white           
                        sta (scrMemLSB),y   ; store new color      
                        and scrBitFlag      ; only check current bit             
                        cmp #0              ; check if black now           
                        bne white           ; go to white if not equal(double check logic after three beers)            
                        ; did not branch on white, so we are on black  
                        lda dir             ; load directions into accumulator      
                        clc 
                        adc #64             ; Turn right is adding 64  
                        sta dir
                        jmp checkdir
white                   lda dir             ; load directions into accumulator  
                        sec 
                        sbc #64             ; turn left is subtracing 64  
                        sta dir
checkdir                cmp #192            ; acc already holds direction, comparing <= 192 
                        bcs godown          ;  
                        cmp #128            ; <= 128 
                        bcs goleft
                        cmp #64
                        bcs goup            ; fall through to right   
goright                 lda scrBitflag
                        cmp #%00000001
                        bne rightloop       ; Change bitflag to other side and increase memlocation by 8   
                        lda #%10000000
                        sta scrBitflag
                        clc 
                        lda scrMemLSB
                        adc #8
                        sta scrMemLSB
                        lda scrMemMSB
                        adc #0
                        sta scrMemMSB
                        jmp loop
rightloop               lsr scrBitflag
                        jmp loop
godown                  lda scrMemLSB
                        and #$07            ; and sets flag if result is zero  
                        bne decScrMem       ; branch if three last bits is not zero  
                        sec                 ; result is zero, set carry to borrow    
                        lda scrMemLSB       ; must go down 320-7=313=0x139  
                        sbc #$39
                        sta scrMemLSB
                        lda scrMemMSB
                        sbc #1
                        sta scrMemMSB
                        jmp loop
decScrMem               dec scrMemLSB       ; ca not overflow because it is nnot zer    
                        jmp loop
goup                    lda scrMemLSB
                        and #7
                        cmp #7
                        bne incScrMem       ; if 7&y != 7 then take loop    
                        ; 7 - should go 313 more, 139 in hex   
                        clc 
                        lda #$39
                        adc scrMemLSB
                        sta scrMemLSB
                        lda scrMemMSB
                        adc #1
                        sta scrMemMSB
                        jmp loop
incScrMem               inc scrMemLSB       ; can not overflow as not 7   
                        jmp loop
goleft                  lda scrBitflag
                        cmp #%10000000
                        bne leftloop
                        lda #%00000001      ; maybe do in place rotate of flag without carry?  
                        sta scrBitflag
                        sec 
                        lda scrMemLSB
                        sbc #8
                        sta scrMemLSB
                        lda scrMemMSB
                        sbc #0
                        sta scrMemMSB
                        jmp loop
leftloop                asl scrBitflag
                        jmp loop
finito                  rts 
                        .include "Launcher.asm"