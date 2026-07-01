INCLUDE "include/hardware.inc"

SECTION "TerminalVars", WRAM0, ALIGN[8]
wLineBuffer:: ds 73
wLineBufferPtr:: db
wTerminalWidth:: db  
wTerminalCharX:: db
wTerminalCharY:: db

SECTION "Terminal", ROM0

InitTerminal::
    xor a
    ld [wTerminalCharX], a
    ld [wTerminalCharY], a
    ld [wLineBufferPtr], a

    ld hl, wLineBufferPtr
    ld bc, 73
    call MemClr

    ld a, 72
    ld [wTerminalWidth], a

    ret

; b = char
PutChar::
    ld de, TILEMAP0
    ld HIGH(hl) , 0
    
    ; calculate y offset's adress
    ld a, [wTerminalCharY]
    ld LOW(hl), a

    ; *32
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl

    ; add tile map offset
    add hl, de

    ; add x offset
    ld a, [wTerminalCharX]

    add a, LOW(hl)
    ld LOW(hl), a
    xor a 
    adc a, HIGH(hl)
    ld HIGH(hl), a

    ; wait for vblank
    call WaitVBlank
    
    ; put the char
    ld [hl], b

    ; ignore updating visual ptr if empty char
    ld a, b
    or a, a
    ret z

    ld a, [wTerminalCharX]
    inc a
    ld [wTerminalCharX], a

    cp a, 20
    call  nc, PrintNewLine

    ret

; doesn't actually print anything...
PrintNewLine::
    xor a
    ld [wTerminalCharX], a 

    ld a, [wTerminalCharY]
    inc a
    ld [wTerminalCharY], a 
    ret

;takes input
LineBuffer:: 
    ; poll for key press
    call UpdateBtns
    call UpdateKeyboard
    ld a, [wCurrentKeyPress]
    or a
    jr z, LineBuffer

    ; enter? new line and return
    cp a, 13
    jr nz, .NoNewLine
    xor a
    ld [wLineBufferPtr], a
    call PrintNewLine
    ret
.NoNewLine

    ; backspace?
    cp a, 8
    jr z, .YesBS
    cp a, 95
    jr z, .YesBS
    
    jr .NoBS
.YesBS

    ; place buffer ptr back
    ld a, [wLineBufferPtr]
    dec a
    ld [wLineBufferPtr], a

    ; clear cell
    ld hl, wLineBuffer
    add a, LOW(hl)
    ld LOW(hl), a
    ld [hl], 0


    ; place tile ptr back
    ld a, [wTerminalCharX]
    ld b, a
    or a

    jr nz, .NoLineBack
    ld b, 1
    ld a, [wTerminalCharY]
    or a

    jr z, .NoLineBack
    dec a
    ld [wTerminalCharY], a
    ld b, 20
 .NoLineBack

    dec b
    ld a, b
    ld [wTerminalCharX], a

    ; place empty tile
    ld b, 0
    call PutChar

    jr LineBuffer
.NoBS

    ; @ to cancel
    cp a, 64
    jr nz, .NoCancel
    call PrintNewLine

    ld hl, wLineBuffer
    ld bc, 73
    call MemClr
    jr LineBuffer
.NoCancel

    ; ignore add to buffer if buffer to full
    ld b, a
    ld a, [wTerminalWidth]
    ld c, a
    ld a, [wLineBufferPtr]
    cp a, c
    ret z

    ; add char to buffer
    ld hl, wLineBuffer
    add a, LOW(hl)
    ld LOW(hl), a
    ld [hl], b
    ld a, [wLineBufferPtr]
    inc a
    ld [wLineBufferPtr], a

    ; show the character on screen
    jp PutChar
