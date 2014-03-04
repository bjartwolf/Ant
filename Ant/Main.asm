                        * = $1000
baseMSB = #$20
baseLSB = #$00
videoadrLSB = $fa
videoadrMSB = $fb
regbase = $d000
whiteblack = #$f0
videocolorbase = $0400
xMSB = $f1
y = $f2                                     ; current y position      
dir = $f3                                   ; ant dir     
right = #0
up = #1
left = #2
down = #3
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
                        ; x-position is 0-320 stored in f0 and f1, 160 is a0            

                        ; store dir in f3         
                        lda #0              ; dir 0        
                        sta dir

						lda #%00010000
                        sta scrBitFlag
                        lda #$2f
                        sta scrMemMSB
                        lda #$a3
						sta scrMemLSB

                        ; flip color by xor with bit           
shortcut                lda scrBitFlag      ; load bit flag for which bit to turn on            
                        ldy #0              ; not sure how to do without index           
                        eor (scrMemLSB),y   ; use eor to flip value of black and white        
                        sta (scrMemLSB),y   ; store new color   
                        and scrBitFlag      ; only check current bit          
                        cmp #0              ; check if black now        
                        bne white           ; go to white if not equal(double check logic after three beers)         
                        ; is black   
                        inc dir
                        lda #4
                        cmp dir             ;check         
                        beq wrappos
                        jmp checkdir
white                   dec dir
                        lda #$ff
                        cmp dir
                        beq wrapneg         ; if less than zero           
                        jmp checkdir
wrappos                 lda right           ; if position is wrapped on positive, set to right   
                        sta dir
                        jmp checkdir
wrapneg                 lda down            ; if position is negative, wrap around to down   
                        sta dir
checkdir                lda right
                        cmp dir
                        beq goright
                        lda up
                        cmp dir
                        beq goup
                        lda left
                        cmp dir
                        beq goleft
                        lda down
                        cmp dir
                        beq godown
goright                 jmp checkrightshortcut
checkrightshortcut      lda scrBitflag
						cmp #%00000001
                        bne rightshortcut
                        ; Change bitflag to other side and increase memlocation by 8
                        lda #%10000000
                        sta scrBitflag
                        clc 
                        lda scrMemLSB
                        adc #8
                        sta scrMemLSB
                        lda scrMemMSB
                        adc #0
						sta scrMemMSB
						jmp shortcut
rightshortcut			clc
						ror scrBitflag
						jmp shortcut
godown                  dec y
                        lda scrMemLSB
                        and #$07
                        cmp #$00
                        bne decScrMem
                        sec                 ; set carry to borrow 
                        lda scrMemLSB
                        sbc #$39
                        sta scrMemLSB
                        lda scrMemMSB
                        sbc #1
						sta scrMemMSB
                        jmp shortcut
decScrMem               dec scrMemLSB       ; ca not overflow because it is nnot zer 
						jmp shortcut
goup					inc y
						lda scrMemLSB
						and #7
                        cmp #7
                        bne incScrMem       ; if 7&y != 7 then take shortcut 
                        ; 7 - should go 313 more, 139 in hex
						clc
                        lda #$39
                        adc scrMemLSB
                        sta scrMemLSB
                        lda scrMemMSB
                        adc #1
						sta scrMemMSB
						jmp shortcut
incScrMem				inc scrMemLSB ; can not overflow as not 7
						jmp shortcut
decmsb                  dec xMSB
goleft					lda scrBitflag
						cmp #%10000000
                        bne leftshortcut
						lda #%00000001
                        sta scrBitflag
                        sec 
                        lda scrMemLSB
                        sbc #8
                        sta scrMemLSB
                        lda scrMemMSB
                        sbc #0
						sta scrMemMSB
						jmp shortcut
leftshortcut			clc
						rol scrBitflag
						jmp shortcut
finito                  rts 
                        .include "Launcher.asm"