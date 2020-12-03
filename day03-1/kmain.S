; *************************************************************
; Advent Of Code 2020 Day 03 - Part 1
; Copyright (c) 2020 Ross Bamford (roscopeco@gmail.com)
; *************************************************************
;

CHARS_RIGHT equ   3                   ; Right 3 on each move

    section .text                     ; This is normal code

kmain::
    movem.l D0-D4/A0,-(A7)            ; Save regs

    ; First, determine line length in input (store in D2)
    lea     INPUT,A0
    move.l  #0,D2

.CHARLOOP
    move.b  (A0)+,D0                  ; Get next character
    tst.b   D0                        ; Is it the null-terminator (no newlines)?
    beq.s   .CHARDONE                 ; Break if so

    cmp.b   #13,D0                    ; Is it CR?
    beq.s   .CHARDONE                 ; Break if so (Don't want CR in the length)

    addq.l  #1,D2                     ; Else, increment length...
    bra.s   .CHARLOOP                 ; ... and loop

.CHARDONE
    lea     INPUT,A0                  ; Reset A0
    move.l  #0,D1                     ; Start tree count at 0

.MAINLOOP
    cmp.l   #INPUTEND,A0              ; Check position wrt end of input
    bhs.s   .MAINDONE                 ; Break loop if beyond

    move.b  (A0)+,D0                  ; Get char from current position
    cmp.b   #$23,D0                   ; Is it a #?
    bne.s   .MAINNEXT                 ; Next iteration if not

    addq.l  #1,D1                     ; Encountered a tree - record it

.MAINNEXT
    move.b  #0,D3                     ; Zero 'seen CR' flag
    move.w  #CHARS_RIGHT,D4           ; Number of steps right into D4
    bra.s   .STEPSTART

.STEPLOOP
    move.b  (A0)+,D0                  ; Check current character
    cmp.b   #13,D0                    ; Is is a CR?
    bne.s   .STEPSTART                ; Branch if so

    move.b  #1,D3                     ; Set 'seen CR' flag

.STEPSTART
    dbra.w  D4,.STEPLOOP

.STEPDONE
    tst.b   D3                        ; Did we see a CR during the stepping?
    bne.s   .MAINLOOP                 ; Yes - Next iteration of main loop

    add.l   D2,A0                     ; No - Add an extra line to A0
    bra.s   .MAINLOOP
    
.MAINDONE
    move.l  #15,D0                    ; Function code 15 
    move.b  #10,D2                    ; Base 10
    trap    #15                       ; Call TRAP 15 to display num in D1
    
    movem.l (A7)+,D0-D4/A0            ; Restore regs
    rts

    section .rodata
    include 'input.inc'

