                        * = $1000
start
                        lda #$3b            ; Bit 5 on (some use 10x59 x3b)
                        sta $d011           ; Reg 17 Bit 5 enable high res  
                        lda #$18            ; Point to high res 
						sta $d018           ; Reg 24   
                        lda #$f0
                        ldx #$00			; Counter count down from 0 and loop
resetcolor              sta $0400,x			; Easier and faster than using 16 bit adressing
                        sta $0500,x  
                        sta $0600,x 
						sta $0700,x
						dex
                        bne resetcolor
                        ldx #$00
						lda #$00 ; LSB of 2000 
						sta $fa  ; store LSB in zero page location fa
                        lda #$20 ; MSB of 2000 
						sta $fb  ; store MSB in zero page location fb
                        lda #$00 ; turn all off
                        ldy #$00 ; clear y 
						ldx #$ff ; value to turn everything white (on)
resetscreenmem			sta ($fa),y ; Store in fb,fa location+y
						iny
						bne resetscreenmem
                        ldx $fb             ; load msb of loop range
                        inx                 ; inx 
						stx $fb			    ; save stored value back
                        cpx #$40             ; we count to 3fff (I think)  
						bne resetscreenmem 
                        ; 0 is black, 1 is white 
                        ; need indirect memory from  
                        ; x and y positions 
						; multiplication 16 bit
						lda #$ff
                        ldx #$00
loop					dex
						sta $3100,x
						jmp loop
forever					jmp forever			; basic messes up memory space
                        rts 
                        .include "Launcher.asm"
