                        * = $1000
start
                        ; add your code here 

                        lda #$3b            ; Bit 5 on (some use 10x59 x3b)
                        sta $d011           ; Reg 17 Bit 5 enable high res  
                        lda #$18            ; Point to high res 
						sta $d018           ; Reg 24   
                        lda #$f0
                        ldx #$00			; Counter count down from 0 and loop
resetcolor              sta $0400,x 
                        sta $0500,x 
                        sta $0600,x 
						sta $0700,x
						dex
                        bne resetcolor
                        ldx #$00
						lda #$da
resetscreenmem          sta $2000,x 
                        sta $2100,x 
                        sta $2200,x 
						sta $2300,x
						sta $2400,x
                        sta $2500,x 
                        sta $2600,x 
						sta $2700,x
                        sta $2800,x 
                        sta $2900,x 
                        sta $2a00,x 
                        sta $2b00,x 
                        sta $2c00,x 
                        sta $2d00,x 
                        sta $2e00,x 
						sta $2f00,x
						sta $3000,x 
                        sta $3100,x 
                        sta $3200,x 
                        sta $3300,x 
                        sta $3400,x 
                        sta $3500,x 
                        sta $3600,x 
                        sta $3700,x 
                        sta $3800,x 
                        sta $3900,x 
                        sta $3a00,x 
						sta $3a00,x
                        sta $3b00,x 
                        sta $3c00,x 
                        sta $3d00,x 
                        sta $3e00,x 
						sta $3f00,x
						dex
                        bne resetscreenmem	
						lda #$f0
						sta $d100
forever					jmp forever			; basic messes up memory space
                        rts 

                        .include "Launcher.asm"
