INCLUDE "include/hardware.inc"

SECTION "ShadowOAM", WRAM0[$C000], ALIGN[8]
wShadowOAM:: ds 160

SECTION "DMATransferRoutine", ROM0
; adapted from https://gbdev.io/pandocs/OAM_DMA_Transfer.html
DMATransferRoutine::
LOAD "DMATransferRoutineHram", HRAM
DMATransfer::
    ld a, HIGH(wShadowOAM)
    ldh [rDMA], a; set src & start DMA
    ld a, 40        ; delay for a total of 4×40 = 160 M-cycles
.Wait
    dec a           ; 1 M-cycle
    jr nz, .Wait    ; 3 M-cycles
    ret
ENDL
.End::