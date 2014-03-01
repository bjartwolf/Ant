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
                        lda #$a0            ; LSB of position for 160   
                        sta $f0             ; store lsb of x position   
                        lda #$00            ; MSB of x position for 160   
                        sta $f1             ; store msb of x position    
                        ; y position is 0-200 stored in f2   
                        lda #$64            ; y position 100    
                        sta $f2             ; store y position    
;                        lda #$a4            ; lsb of start position     
;                        sta $f3             ; store lsb of start position   
;                        lda #$2f            ; msb of 2fa4   
;                        sta $f4             ; store msb in f4   
;                        lda #$80            ; middle bit on  
;                        ldy #$00 
;                        sta ($f3),y         ; not sure how to do without index    

                        ; store char*8 = 8*int(x/8) in e0 and e1   
loop                    lda $f1             ;msb of x 
                        sta $e1             ;don't need to do anything with this  
                        lda $f0             ;lsb of x   
                        and #$f8            ;ignore three last bits - 8*int(x/8)   
                        sta $e0             ;save lsb's   

                        ; calculate y and 7 (line) and store in e2-e3  
                        lda $f2
                        and #$07
                        sta $e2             ;lsb  
                        lda #$00
                        sta $e3             ;msb    

                        ; calculate 320*int(y/8)  
                        ; which is 40*(y&f8) or 8*(y&f8)+32*(y&f8)   
                        ; and store in locations e4-e5 and e6-e7  
                        lda $f2
                        and #$f8            ; y&f8  
                        clc                 ; clear carry before rotate   
                        rol                 ; multiply by two  
                        sta $e4             ; store lsb  
                        lda #$00            ; clear lsb  
                        rol                 ; rotate in carry  
                        sta $e5             ; store msb  
                        clc                 ; clear carry  
                        lda $e4             ;  
                        rol                 ; multiply by four   
                        sta $e4             ; save lsb  
                        lda $e5             ; load msb  
                        rol                 ; rotate in carry  
                        clc                 ; clear carry   
                        lda $e4             ;  
                        rol                 ; multiply by eight 
                        sta $e4             ; save lsb   
                        sta $e6             ; save msb for 32 multiplication 
                        lda $e5             ; load msb  
                        rol                 ; rotate in carry   
                        sta $e5             ; save msb 
                        sta $e7             ; save msb for 32 multiplication 
                        clc                 ; clear carry  
                        rol $e6             ; multiply lsb by 2 to 16 
                        rol $e7             ; multiply msb by 2, rotate in carry 
                        clc                 ; clear carry 
                        rol $e6             ; multiply lsb by 2, 32 total now  
                        rol $e7             ; multiply msb by 2, 32 total now  

                        ; find bit - last 8 values of x and store flag in e8  
                        lda $f0             ; x lsb   
                        and #$07            ; only three last values   
                        tax                 ; x as iterator  
                        lda #$00            ; clear a  
                        cpx #$00            ; is iterator 0?   
                        beq storebitflag    ; if it is equal continue  
                        lda #$80            ; 100000000   
movebitflag1            dex 
                        beq storebitflag    ; if x is 0 continue  
                        clc                 ;clear carry   
                        ror                 ;rotate bitflag 1  
                        jmp movebitflag1
storebitflag            sta $e8

                        ; 16 bit summation   
                        ; must sum base+row*320+char*8+line  and store in eab  
                        ; which is 2000+e45+e67+e01+e23  
                        clc                 ;clear carry   
                        lda #$00            ;lsb of base   
                        adc $e0
                        sta $ea             ;store lsb  
                        lda #$20            ;msb of base   
                        adc $e1
                        sta $eb             ;store msb  
                        clc                 ; clear carry for next round   
                        lda $ea
                        adc $e2
                        sta $ea             ; save result back   
                        lda $eb
                        adc $e3
                        sta $eb
                        clc 
                        lda $ea
                        adc $e4
                        sta $ea
                        lda $eb
                        adc $e5
                        sta $eb
                        clc 
                        lda $ea
                        adc $e6
                        sta $ea
                        lda $eb
                        adc $e7
                        sta $eb
                        ; saved position   
                        ; flip color by xor with bit  
                        lda $e8             ; load bit flag for which bit to turn on   
                        ldy #$00            ; not sure how to do without index  
                        ora ($ea),y         ; use eor to flip...? 
                        sta ($ea),y 
                        inc $f0             ; inc x lsb  
                        beq finished
                        dec $f2             ; inx y  
                        beq finished
                        jmp loop

finished                jmp finished
                        rts 
                        .include "Launcher.asm"
