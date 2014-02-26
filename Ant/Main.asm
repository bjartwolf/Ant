                        * = $1000
start
                        ; add your code here 

                        lda #$3b;lda #$20            ; Bit 5 on (some use 10x59 x3b)
                        sta $d011           ; Reg 17 Bit 5 enable high res  
                        lda #$18            ; Point to high res 
                        sta $d018           ; Reg 24   
                        lda #$00
                        ldx #$00			; Counter count down from 0 and loop
resetcolor              sta $0400,x 
                        sta $0500,x 
                        sta $0600,x 
						sta $0700,x
						dex 
						bne resetcolor
forever					jmp forever
                        rts 

                        .include "Launcher.asm"
