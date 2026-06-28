INCLUDE "include/hardware.inc"

SECTION "Header", ROM0[$0100]
	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

SECTION "Main", ROM0[$0150]
EntryPoint:
    ; turn off audio 
    xor a
    ld [rAUDENA], a

    ; copy DMA Transfer Routine into HRAM
    ld de, DMATransferRoutine
    ld hl, DMATransfer
    ld bc, DMATransferRoutine.End - DMATransferRoutine
    call MemCpy

    ; turn on VBlank interrupts
    ld a, IE_VBLANK
    ld [rIE], a
    ei 

    ; turn off screen
    call WaitVBlank
	xor a
	ld [rLCDC], a

    ; copy tile data into vram
    ld de, TileSet
    ld bc, TileSet.ASCII_08 - TileSet
    ld hl, $8000
    call MemCpy

    ld de, TileSet.ASCII_08
    ld bc, 16
    ld hl, $8000 + $08 * 16
    call MemCpy

    ld de, TileSet.ASCII_0D
    ld bc, 16
    ld hl, $8000 + $0D * 16
    call MemCpy

    ; load ASCII tiles
    ld de, TileSet.ASCII
    ld bc, TileSet.ASCIIEnd - TileSet.ASCII
    ld hl, $8000 + $20 * 16;offset ascii
    call MemCpy

    ; clear OAM & Shadow OAM
    ld hl, $FE00
    ld bc, 160
    call MemClr

    ld hl, wShadowOAM
    ld bc, 160
    call MemClr


    ; init Keyboard
    call InitKeyboard
    call DrawKeyboard

    ; turn on scrn
	ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON | LCDC_BLOCK01 | LCDC_WIN_9C00 | LCDC_OBJ_ON
	ld [rLCDC], a
	
	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
    cpl 
	ld [rOBP1], a

Main:
    call UpdateBtns
    call UpdateKeyboard
    jr Main


SECTION "TileSet", ROM0
INCLUDE "assets/TilesSet.z80"