; makes the program runnable from BASIC

                  	*=$0801
					.word nextline            ; pointer to the next BASIC line 
					.word 10					; BASIC line number
					.null $9e,^start			; sys <__start>
					.byte 0						; end of line marker
nextline			.word 0						; end of basic program marker
