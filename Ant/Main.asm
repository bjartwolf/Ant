			       *=$1000
start
				   ; add your code here

				   lda #$20		; Bit 5 on
				   sta $d011	; Reg 17 Bit 5 enable high res
				   rts

				   .include "Launcher.asm"
