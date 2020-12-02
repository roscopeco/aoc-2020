; *************************************************************
; Advent Of Code 2020 Day 02 - Part 1
; Copyright (c) 2020 Ross Bamford (roscopeco@gmail.com)
;
; Fairly simple line-by-line/character-by-character looping 
; solution. Could be more efficient (register sizing) but I
; quite like that it will support passwords up to 
; 1<<32 characters :D
; *************************************************************
;
    section .text                     ; This is normal code

; Register alloc in main loop:
;
;  * D0 - Scratch
;  * D1 - Minimum number of occurences for rule
;  * D2 - Maximum number of occurences for rule
;  * D3 - Character for rule
;  * D4 - Count of occurrences of rule character in password
;  * D7 - Current correct count
;
kmain::
    movem.l D0-D4/D7/A0,-(A7)         ; Save regs

    moveq.l #0,D7                     ; Start correct count at 0
    lea     INPUT,A0                  ; Start of input

.LINELOOP
    move.b  (A0),D0                   ; Peek next character
    cmp.b   #0,D0                     ; Is it the null terminator?
    beq.s   .DONE                     ; Done if so

    moveq.l #0,D4                     ; Start rule char count at 0

    bsr.s   STRTONUM                  ; Convert first number to integer
    move.l  D0,D1
    bsr.s   STRTONUM                  ; Convert second number to integer
    move.l  D0,D2
    move.b  (A0),D3                   ; Get target character for rule
    addq.l  #3,A0                     ; Skip character, colon and space

.CHARLOOP
    move.b  (A0)+,D0                  ; Get next character
    cmp.b   #13,D0                    ; Have we hit newline?
    beq.s   .CHECKLINE                ; Next line if so

    cmp.b   D3,D0                     ; Is this our rule character?
    bne.s   .CHARLOOP                 ; Nope - moving on...

    addq.l  #1,D4                     ; It's the rule character - increment count
    bra.s   .CHARLOOP                 ; And loop.

.CHECKLINE
    cmp.l   D1,D4                     ; Check minimum bound
    blo.s   .LINELOOP                 ; Too low - just go to next line

    cmp.l   D2,D4                     ; Check maximum bound
    bhi.s   .LINELOOP                 ; Too high - just go to next line

    addq.l  #1,D7                     ; Within range - increment correct count
    bra.s   .LINELOOP                 ; And go to next line

.DONE
    move.l  D7,D1                     ; Correct count is number to display
    move.l  #15,D0                    ; Function code 15 
    move.b  #10,D2                    ; Base 10
    trap    #15                       ; Call TRAP 15 to display num in D1

    movem.l (A7)+,D0-D4/D7/A0         ; Restore regs
    rts

; Convert a string (pointed to by A0) to an integer (in D0.L).
; Unsigned only. Base 10. Modifies A0 (leaves it pointing to first 
; character after the terminal non-digit character).
;
; Takes as many digits as possible. Uses a buffer at _end.
;
; This could be faster (it could use a table, trading space for time)
; but I like the readability of it this way...
;
; Note! This doesn't account for overflow! Doesn't matter for the
; purposes of AoC though (at least with my input).
STRTONUM:
    movem.l D1-D2/A1,-(A7)            ; Save regs

    lea     _end,A1                   ; Buffer starts at _end
    moveq.l #0,D0                     ; Initialize result to 0
    moveq.l #1,D2                     ; Initialize multiplier to 1

.LOOP
    move.b  (A0)+,D1                  ; Get next character
   
    cmp.b   #$30,D1                   ; Less than ASCII '0'?
    blo.s   .GOTCHRS                  ; Got all digits if so
 
    cmp.b   #$39,D1                   ; Greater than ASCII '9'?
    bhi.s   .GOTCHRS                  ; Got all digits if so

    subi.b  #$30,D1                   ; Subtract 0x30 from ASCII value
    move.b  D1,(A1)+                  ; Store in buffer

    bra.s   .LOOP                     ; Around we go!

.GOTCHRS
    cmp.l   #_end,A1                  ; Have we reached the start of the buffer?
    blt.s   .DONE                     ; Yes - leave

    moveq.l #0,D1                     ; Zero D1 for word-sized mulu...
    move.b  -(A1),D1                  ; Get previous char
    mulu.w  D2,D1                     ; Apply current multiplier
    add.l   D1,D0                     ; And add to result

    mulu.w  #10,D2                    ; Increase multiplier (input is base 10, sadly)
    bra.s   .GOTCHRS                  ; And loop

.DONE
    movem.l (A7)+,D1-D2/A1            ; Restore regs
    rts

    section .rodata
    include 'input.inc'
