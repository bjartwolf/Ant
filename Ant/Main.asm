			       *=$1000
start
				   ; add your code here

				   lda #$09
				   sta $d021
				   rts

				   .include "Launcher.asm"
