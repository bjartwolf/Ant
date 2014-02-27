                        * = $1000
start
                        lda #$3b            ; Bit 5 on (some use 10x59 x3b) 
                        sta $d011           ; Reg 17 Bit 5 enable high res   
                        lda #$18            ; Point to high res memory map  
                        sta $d018           ; Reg 24    
                        lda #$f0            ; msb nybble is on color, lsb is off 
                        ldy #$00            ; Counter count down from 0 and loop 
resetcolor              sta $0400,y         ; Easier and faster than using 16 bit adressing 
                        sta $0500,y 
                        sta $0600,y 
                        sta $0700,y 
                        dey 
                        bne resetcolor

                        lda #$00            ; LSB of 2000  
                        sta $fa             ; store LSB in zero page location fa 
                        lda #$20            ; MSB of 2000  
                        sta $fb             ; store MSB in zero page location fb 
                        lda #$00            ; turn all bits in bitmap off 
                        ldy #$00            ; clear y (iterator)		 
resetscreenmem          sta ($fa),y         ; Store in fb,fa location+y 
                        iny 
                        bne resetscreenmem
                        ldx $fb             ; load msb of loop range 
                        inx                 ; inx  
                        stx $fb             ; save stored value back 
                        cpx #$40            ; we count to 3fff (I think, if we count to far it is only sprite memory I think)   
                        bne resetscreenmem
                        ; TODO 
                        ; x and y positions  
                        ; multiplication 16 bit  
                        ; move  
                        ; x-position is 0-320 stored in f0 and f1, 160 is a0
                        lda #$a0			; LSB of position for 160
                        sta $f0				; store lsb of x position
                        lda #$00            ; MSB of x position for 160
                        sta $f1             ; store msb of x position 
						; y position is 0-200 stored in f2
                        lda #$64             ; y position 100 
                        sta $f2             ; store y position 
                        lda #$a4             ;lsb of start position  
                        sta $f3				; store lsb of start position
                        lda #$2f			; msb of 2fa4
                        sta $f4				; store msb in f4
                        lda #$80            ; middle bit on 
						ldy #$00
						sta ($f3),y         ; not sure how to do without index
                        ;draw initial position 
						;must calculate location and bit flags for x and y positions						
forever                 jmp forever         ; basic messes up memory space 
                        rts 
.include "Launcher.asm"
