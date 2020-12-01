; *************************************************************
; Copyright (c) 2020 You (you@youremail.com)
; *************************************************************
;
    section .text                     ; This is normal code

kmain::
    movem.l D0-D2/A0-A1,-(A7)         ; Save regs

    eor.l   D0,D0
    move.l  D0,D1
    move.l  D0,D2

    move.l  #INPUT,A0                 ; Start of input into A0

.OUTER                                ; Outer loop...
    cmp.l   #INPUTEND,A0              ; Have we reached the end in the outer loop?
    beq.s   .NOMATCH                  ; No match if so
    
    move.l  #INPUT,A1                 ; Restart input

    move.w  (A0)+,D0                  ; Else, get the next word

.INNER                                ; Inner loop
    cmp.l   #INPUTEND,A1              ; Have we reached the end in the inner loop?
    beq.s   .OUTER                    ; Next iteration of outer if so

    cmp.l   A0,A1                     ; Skip the same element as current outer
    bne.s   .CHECK                    ; or go to the check.

    addq.l  #2,A1                     ; We're skipping
    bra.s   .INNER

.CHECK                                ; Not the same element - check them
    move.w  (A1)+,D1                  ; Get element
    move.w  D1,D2                     ; Dup to D2 so we can keep original in D1
    add.w   D0,D2                     ; Add them

    cmp.w   #456,D0                   ; Is D0 456
    bne.s   .NOSHOW                   ; Skip display if so
    bsr.s   DISPLAY_D0
    bsr.s   DISPLAY_D1
    bsr.s   DISPLAY_D2

.NOSHOW
    cmp.w   #2020,D2                  ; Is it 2020?
    beq.s   .FOUND                    ; Found it!

    bra.s   .INNER                    ; Else, next iter of inner loop...

.FOUND
    mulu.w  D0,D1                     ; Multiply them

    move.l  #15,D0                    ; Function code 15 
    move.b  #10,D2                    ; Base 10
    trap    #15                       ; Call TRAP 15 to display num in D1
    
    bra.s   .DONE                     ; And we're done

.NOMATCH
    move.l  #14,D0                    ; Function code 14
    lea     SZNOMATCH,A1              ; Load string address
    trap    #15                       ; Call TRAP 15 to print sz str

.DONE
    movem.l (A7)+,D0-D2/A0-A1         ; Restore regs
    rts                               ; Warm reboot

DISPLAY_D0:
    movem.l D0-D2/A0-A1,-(A7)
    move.l  D0,D1
    move.l  #15,D0
    move.l  #10,D2
    trap    #15
    move.l  #14,D0
    lea     SZCRLF,A1
    trap    #15
    movem.l (A7)+,D0-D2/A0-A1
    rts

DISPLAY_D1:
    movem.l D0-D2/A0-A1,-(A7)
    move.l  #15,D0
    move.l  #10,D2
    trap    #15
    move.l  #14,D0
    lea     SZCRLF,A1
    trap    #15
    movem.l (A7)+,D0-D2/A0-A1
    rts

DISPLAY_D2:
    movem.l D0-D2/A0-A1,-(A7)
    move.l  D2,D1
    move.l  #15,D0
    move.l  #10,D2
    trap    #15
    move.l  #14,D0
    lea     SZCRLF,A1
    trap    #15
    move.l  #14,D0
    lea     SZCRLF,A1
    trap    #15
    movem.l (A7)+,D0-D2/A0-A1
    rts

    section .rodata
    align 2
SZNOMATCH dc.b  "No match found", 13,10,0
    align 2
SZCRLF    dc.b  13,10,0 
    align 2
    include 'input.inc'
