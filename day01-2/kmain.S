; *************************************************************
; Advent Of Code 2020 Day 01 - Part 2
; Naive (brute-force) solution
; Copyright (c) 2020 Ross Bamford (roscopeco@gmail.com)
; *************************************************************
;
; Note - There's some optional MC68020 code in here that uses native 32-bit
; unsigned multiply on that CPU - Make with:
;
; ```
; MC68020=true make clean all
; ```
;
; To have that used, otherwise there's some (nasty unoptimized) code that
; emulates 32-bit multiply instead :) 
;

    section .text                     ; This is normal code

kmain::
    movem.l D0-D3/A0-A2,-(A7)         ; Save regs

    moveq.l #0,D0                     ; Zero longwords, since we'll need
    move.l  D0,D1                     ; them for the mulu later...
    move.l  D1,D2
    move.l  D2,D3

    move.l  #INPUT,A0                 ; Start of input into A0

    
.ONE                                  ; Outer loop...
    cmp.l   #INPUTEND,A0              ; Have we reached the end in the outer loop?
    beq.s   .NOMATCH                  ; No match if so
    
    move.l  #INPUT,A1                 ; Restart input

    move.w  (A0)+,D0                  ; Else, get the next word

.TWO                                  ; Middle loop
    cmp.l   #INPUTEND,A1              ; Have we reached the end in the middle loop?
    beq.s   .ONE                      ; Next iteration of outer if so

    cmp.l   A0,A1                     ; Skip the same element as current outer
    bne.s   .CONT2                    ; or go to the check.

    addq.l  #2,A1                     ; We're skipping
    bra.s   .TWO

.CONT2
    move.l  #INPUT,A2                 ; Restart middle input
    move.w  (A1)+,D1                  ; Get middle element

.THREE                                ; Inner loop
    cmp.l   #INPUTEND,A2              ; Have we reached the end in the inner loop?
    beq.s   .TWO                      ; Next iteration of middle if so

    cmp.l   A0,A2                     ; Skip the same element as current outer
    bne.s   .MIDCHECK                 ; Or continue

    addq.l  #2,A2                     ; We're skipping
    bra.s   .THREE

.MIDCHECK
    cmp.l   A1,A2                     ; Skip same element as current middle
    bne.s   .CHECK                    ; Or go to check

    addq.l  #2,A2                     ; We're skipping
    bra.s   .THREE

.CHECK
    move.w  (A2)+,D2                  ; Get inner element
    move.w  D2,D3                     ; Dup to D2 so we can keep original in D1
    add.w   D0,D2                     ; Add them
    add.w   D1,D2
    cmp.w   #2020,D2                  ; Is it 2020?
    beq.s   .FOUND                    ; Found it!

    bra.s   .THREE                    ; Else, next iter of inner loop...

.FOUND
    move.l  D3,D2

    ifd MC68020                       ; Conditional assembly - use native 32-bit mulu on 68020
    mulu.l  D0,D1                     ; ...
    mulu.l  D1,D2
    move.l  D2,D1

    else                              ; 68000/68010 - We'll have to emulate 32-bit mulu...

    bsr.s   UMULL                     ; ...
    move.l  D2,D1                     ; Set up for second multiply (discard high 32-bits)
                                      ; This works for my input as result doesn't overflow...
                                      ; YMMV may vary depending on your input!
    bsr.s   UMULL                     ; Pseudo-32-bit multiply again...
    move.l  D0,D1                     ; Discard high bits again and prepare to print.
    endif

    move.l  #15,D0                    ; Function code 15 
    move.b  #10,D2                    ; Base 10
    trap    #15                       ; Call TRAP 15 to display num in D1
    
    bra.s   .DONE                     ; And we're done

.NOMATCH
    move.l  #14,D0                    ; Function code 14
    lea     SZNOMATCH,A1              ; Load string address
    trap    #15                       ; Call TRAP 15 to print sz str

.DONE
    movem.l (A7)+,D0-D3/A0-A2         ; Restore regs
    rts                               ; Warm reboot

    ifnd MC68020
UMULL:
    ; Probably needs a bit of explanation. On pre-68020, we only
    ; have 16-bit multiply available. This is conditionally assembled
    ; in on 68000/68010.
    ;
    ; It uses four 16-bit multiplies and some register swapping to 
    ; do a 32-bit multiply (supporting 64-bit results) according to the 
    ; following:
    ;
    ; A * B = Ah * Bh<<32 + Al * Bh<<16 + Ah * Bl<<16 + Al * Bl
    ;
    ; Multiplies D0.l * D1.l
    ; Result is D0.l:D1.l (D0.l holds high 32-bits)
    ;
    movem.l D2-D5,-(A7)               ; Save regs

    move.w  D0,D3
    mulu.w  D1,D3                     ; D3.l is Al*Bl

    swap    D0
    swap    D1
    move.w  D0,D2
    mulu.w  D1,D2                     ; D2.l is Ah*Bh

    swap    D0
    move.w  D0,D4
    mulu.w  D1,D4                     ; D4 is Al*Bh

    swap    D4
    moveq.l #0,D5
    move.w  D4,D5
    clr.w   D4                        ; D5:D4 is 0x0000:Nh:Nl:0x0000, where N is Al*Bh

    add.l   D4,D3
    addx.l  D5,D2                     ; add Al*Bh*0x10000 to the partial result in D2:D3
                                      ; Note this also uses the extend bit!

    swap    D0
    swap    D1

    move.w  D0,D4
    mulu.w  D1,D4                     ; D4 is Ah*Bl

    swap    D4
    moveq.l #0,D5
    move.w  D4,D5
    clr.w   D4                        ; D5:D4 is 0x0000:Nh:Nl:0x0000, where N is Ah*Bl

    add.l   D4,D3
    addx.l  D5,D2                     ; add Ah*Bl*0x10000 to the partial result

    move.l  D2,D1                     ; Put result back in original regs
    move.l  D3,D0   

    movem.l (A7)+,D2-D5               ; Restore regs
    rts                               ; And done...
    endif


    section .rodata
    align 2
SZNOMATCH dc.b  "No match found", 13,10,0
    align 2
SZCRLF    dc.b  13,10,0 
    align 2
    include 'input.inc'
