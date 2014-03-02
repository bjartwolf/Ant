                        * = $1000
baseMSB = #$20
baseLSB = #$00
videoadrLSB = $fa
videoadrMSB = $fb
regbase = $d000
whiteblack = #$f0
videocolorbase = $0400
xLSB = $f0                                  ; current x position  
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

                        ; Set color in 25*40 grid  
                        lda whiteblack      ; msb nybble is on color, lsb is off   
                        ldy #0              ; Counter count down from 0 and loop         
resetcolor              sta videocolorbase,y  ; Easier and faster than using 16 bit adressing         
                        sta videocolorbase + $0100,y 
                        sta videocolorbase + $0200,y 
                        sta videocolorbase + $0300,y 
                        dey                 ;starts with zero so wraps around first to ff  
                        bne resetcolor

                        lda baseLSB
                        sta videoadrLSB
                        lda baseMSB
                        sta videoadrMSB
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

                        ; set initial position for ant 
                        lda #160            ; LSB of position for 160        
                        sta xLSB            ; store lsb of x position        
                        lda #0              ; MSB of x position for 160        
                        sta xMSB            ; store msb of x position         
                        ; y position is 0-200 stored in f2        
                        lda #100            ; y position 100         
                        sta y               ; store y position          

                        ; store dir in f3     
                        lda #0              ; dir 0    
                        sta dir
                        ; store char*8 = 8*int(x/8) in e0 and e1        
loop                    lda xMSB            ;msb of x      
                        sta $e1             ;don't need to do anything with this       
                        lda xLSB            ;lsb of x        
                        and #$f8            ;ignore three last bits - 8*int(x/8)        
                        sta $e0             ;save lsb's        

                        ; calculate y and 7 (line) and store in e2-e3       
                        lda y
                        and #%111			;keep only last three bits
                        sta $e2             ;lsb       
                        lda #0
                        sta $e3             ;msb         

                        ; calculate 320*int(y/8)       
                        ; which is 40*(y&f8) or 8*(y&f8)+32*(y&f8)        
                        ; and store in locations e4-e5 and e6-e7       
                        lda y
                        and #$f8            ; y&f8       
                        clc                 ; clear carry before rotate        
                        rol                 ; multiply by two       
                        sta $e4             ; store lsb       
                        lda #0              ; clear lsb       
                        rol                 ; rotate in carry       
                        sta $e5             ; store msb       
                        clc                 ; clear carry       
                        lda $e4             ;       
                        rol                 ; multiply by four        
                        sta $e4             ; save lsb       
                        lda $e5             ; load msb       
                        rol                 ; rotate in carry       
                        sta $e5
                        clc                 ; clear carry        
                        lda $e4             ;       
                        rol                 ; multiply by eight      
                        sta $e4             ; save lsb        
                        sta $e6             ; save lsb for 32 multiplication      
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
                        lda xLSB            ; x lsb        
                        and #%111            ; keep only three last values        
                        tax                 ; x as iterator       
                        lda #0              ; set 00000000      
                        sec                 ; set carry     
movebitflag1            ror 
                        dex 
                        bmi storebitflag
                        jmp movebitflag1    ; if x is 0 continue       
storebitflag            sta scrBitFlag

                        ; 16 bit summation        
                        ; must sum base+row*320+char*8+line  and store in eab       
                        ; which is 2000+e45+e67+e01+e23       
                        clc                 ;clear carry        
                        lda baseLSB         ;lsb of base        
                        adc $e0
                        sta scrMemLSB             ;store lsb       
                        lda baseMSB         ;msb of base        
                        adc $e1
                        sta scrMemMSB             ;store msb       
                        clc                 ; clear carry for next round        
                        lda scrMemLSB
                        adc $e2
                        sta scrMemLSB             ; save result back        
                        lda scrMemMSB
                        adc $e3
                        sta scrMemMSB
                        clc 
                        lda scrMemLSB
                        adc $e4
                        sta scrMemLSB
                        lda scrMemMSB
                        adc $e5
                        sta scrMemMSB
                        clc 
                        lda scrMemLSB
                        adc $e6
                        sta scrMemLSB
                        lda scrMemMSB
                        adc $e7
                        sta scrMemMSB
                        ; flip color by xor with bit       
                        lda scrBitFlag             ; load bit flag for which bit to turn on        
                        ldy #0              ; not sure how to do without index       
                        eor (scrMemLSB),y         ; use eor to flip value    
                        ; check if current position is set or not, incx or y     
                        sta (scrMemLSB),y 
                        and scrBitFlag             ; only check current bit      
                        cmp #0              ; check if black now    
                        bne white           ; go to white if not equal(double check logic after three beers)     
                        ; assume black     
                        inc dir
                        lda #4
                        cmp dir             ;check     
                        beq wrappos
                        jmp checkdir
wrappos                 lda right
                        sta dir             ;is right    
                        jmp checkdir
white                   dec dir
                        lda #$ff
                        cmp dir
                        beq wrapneg         ; if less than zero       
                        jmp checkdir
wrapneg                 lda down
                        sta dir             ; set to 03 if negative    
                        jmp checkdir
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
goright                 inc xLSB
                        lda #0
                        cmp xLSB
                        beq incmsb          ; jmp back if not wrapped to zero     
                        jmp loop
incmsb                  inc xMSB
                        ; if carry add one to msb    
                        jmp loop
goup                    ldx y
                        inx 
                        stx y
                        jmp loop
godown                  ldx y
                        dex 
                        stx y
                        jmp loop
goleft                  dec xLSB
                        lda #$ff
                        cmp xLSB
                        beq decmsb
                        jmp loop
decmsb                  dec xMSB
                        jmp loop
finito                  rts 
                        .include "Launcher.asm"
