INCLUDE "include/hardware.inc"

SECTION "VBlankInterruptHandlerPart01", ROM0[INT_HANDLER_VBLANK]
VBlankInterruptHandler01:
    push af
    ldh a, [wFrameCounter]
    inc a 
    jp VBlankInterruptHandler02

SECTION "VBlankInterruptHandlerPart02", ROM0
VBlankInterruptHandler02:
    ldh [wFrameCounter], a
    call DMATransfer
    pop af 
    reti 

SECTION "VBlankVars", HRAM
wFrameCounter::db

SECTION "VBlank", ROM0
WaitVBlank::
    ld a, [rLY]
    cp a, 144
    jr nz, WaitVBlank
    ret

