                        * = $1000
baseMSB = #$20
baseLSB = #$00
videoadrLSB = $fa
videoadrMSB = $fb
regbase = $d000                             ; base adress for registermainpulation     
whiteblack = #$F0                           ; The colors the fields should have for on/off     
videocolorbase = $0400
dir = $f3                                   ; ant dir             
right = #0              ; using 0 for right and adding 64 when turning left     
up = #64                ; This allows for wrapping around automatically     
left = #128
down = #192
antPosByteLSB = $ea                         ; which byte is ant in    
antPosByteMSB = $eb
antPosInByte = $e8                          ; position of ant within byte    

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
                        ; For each character we can set the color we should have for on and off     
                        lda whiteblack      ; msb nybble is on color, lsb is off, 4 bit colors               
                        ; Easier and faster than using 16 bit adressing - split into four.     
                        ldy #250            ; Count from 250                     
resetcolorscheme        dey 
                        sta videocolorbase,y  ; 0-249     
                        sta videocolorbase + $FA,y  ; 250-499      
                        sta videocolorbase + $01F4,y  ; 500-749     
                        sta videocolorbase + $02EE,y  ; 750-999     
                        bne resetcolorscheme

                        ; must clear all bits from $20 to $40     
                        ; We have 320*200/8 = 8000 bytes to clear     
                        ; in loops of 256 bytes = 31     
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
                        ; Set xy position       
                        lda #%00010000
                        sta antPosInByte
                        lda #$2f            ;position middle        
                        sta antPosByteMSB
                        lda #$a3            ;position middle        
                        sta antPosByteLSB

                        ; This is the main program  

loop                    lda antPosInByte    ; load bit flag for which bit to turn on                    
                        ldy #0              ; not sure how to do eor to 16 bit address without index                   
                        ; Change color of new position  
                        eor (antPosByteLSB),y  ; use eor to flip value of black and white for current position   
                        sta (antPosByteLSB),y  ; store new color           
                        and antPosInByte    ; only check current bit                  
                        cmp #0              ; check if black now                
                        bne isOnWhiteSpot   ; go to white if not equal(double check logic after three beers)                 
                        ; did not branch on white, so we are on black       
                        lda dir             ; load directions into accumulator           
                        clc                 ; Must clear carry so we overflow correctly when "turning"  
                        adc #64             ; Turn right is adding 64       
                        sta dir
                        jmp checkdir
isOnWhiteSpot           lda dir             ; load directions into accumulator       
                        sec                 ; Must set overflow before "turning"  
                        sbc #64             ; turn left is subtracing 64       
                        sta dir
checkdir                cmp down            ; acc already holds direction, comparing <= 192      
                        bcs godown          ;       
                        cmp left            ; <= 128      
                        bcs goleft
                        cmp up
                        bcs goup            ; fall through to right        
                        lda antPosInByte    ; go right      
                        cmp #%00000001      ; check if we are moving to the character to the right  
                        beq goToRightChar
                        lsr antPosInByte    ; Just shift bit to the right  
                        jmp loop
goToRightChar           lda #%10000000      ; Change bitflag to other side  
                        sta antPosInByte
                        clc 
                        lda antPosByteLSB
                        adc #8              ; increase the position by 8 to move to char to right  
                        sta antPosByteLSB
                        lda antPosByteMSB   ; make sure we get the carry to MSB  
                        adc #0
                        sta antPosByteMSB
                        jmp loop
goup                    lda antPosByteLSB
                        and #$07
                        beq gouptonextchar  ; branch if three last bits is zero       
                        dec antPosByteLSB   ; ca not overflow because it is nnot zer         
                        jmp loop
gouptonextchar          sec                 ; result is zero, set carry to borrow         
                        lda antPosByteLSB   ; must go down 320-7=313=0x139       
                        sbc #$39
                        sta antPosByteLSB
                        lda antPosByteMSB
                        sbc #1
                        sta antPosByteMSB
                        jmp loop
godown                  lda antPosByteLSB
                        and #7
                        cmp #7              ; Check if at bottom of character  
                        beq godowntonextchar
                        inc antPosByteLSB   ; move down one, can not overflow as not 7        
                        jmp loop
godowntonextchar        clc 
                        lda #$39            ; should go 313 more, 139 in hex (320-7)  
                        adc antPosByteLSB
                        sta antPosByteLSB
                        lda antPosByteMSB
                        adc #1
                        sta antPosByteMSB
                        jmp loop
goleft                  lda antPosInByte
                        cmp #%10000000
                        beq goToLeftChar
                        asl antPosInByte
                        jmp loop
goToLeftChar            lda #%00000001
                        sta antPosInByte
                        sec 
                        lda antPosByteLSB
                        sbc #8
                        sta antPosByteLSB
                        lda antPosByteMSB
                        sbc #0
                        sta antPosByteMSB
                        jmp loop
                        .include "Launcher.asm"