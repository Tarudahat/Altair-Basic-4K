INCLUDE "include/hardware.inc"

SECTION "KeyboardVars", WRAM0
wCurrentKeyPress::db; the currently pressed key in ascii. 0 means no press
wSelectedKeyPressId::db; the currently selected key
wKeyboardHidden::db

def wSelectorY equs "wShadowOAM"
def wSelectorX equs "wShadowOAM + 1" 
def wSelectorTile equs "wShadowOAM + 2"
def wSelectorAttr equs "wShadowOAM + 3"

SECTION "OnScreenKeyboard", ROM0
KeyboardMap:
    db "1234567890", 2, 2, 2, 8, 2, 0
.Row1:
    db "!@#$%^&*_=()-+", 2, 0
    db "QWERTYUIOP[]\\", 13, 2, 0
    db "ASDFGHJKL:;\"`", 13 , 2, 0
    db "ZXC VBNM<>,./?", 2, 0
.End:

def KeyboardMapRowSize equ KeyboardMap.Row1 - KeyboardMap
def KeyboardMapSize equ KeyboardMap.End - KeyboardMap
def KeyboardOffset equ 24

SECTION "OnScreenKeyboardHandler", ROM0

; init keyboard
InitKeyboard::
    xor a
    ld [wCurrentKeyPress], a
    ld [wSelectedKeyPressId], a
    ld [wKeyboardHidden], a
    ld [wSelectorAttr], a

    add a, WX_OFS + KeyboardOffset
    ld [rWX], a
    ld a, SCREEN_HEIGHT_PX - TILE_HEIGHT*5
    ld [rWY], a

    add a, 2*8
    ld [wSelectorY], a
    ld a, KeyboardOffset + 8
    ld [wSelectorX], a

    ld a, 1
    ld [wSelectorTile], a

    ret

; draws the keyboard on the window
DrawKeyboard::
    ld de, KeyboardMap
    ld hl, TILEMAP1
    call MemCpyTill0
    ld hl, TILEMAP1 + 32
    call MemCpyTill0
    ld hl, TILEMAP1 + 32*2
    call MemCpyTill0
    ld hl, TILEMAP1 + 32*3
    call MemCpyTill0
    ld hl, TILEMAP1 + 32*4
    call MemCpyTill0
    ret

; updates the keyboard state
; UpdateBtns should be called before use
UpdateKeyboard::
    ld a, [wChangedBtns]
    ld b, a
    ld a, [wCurrentBtns]
    or a, b 
    ld b, a 

    ; update hidden state

    bit B_PAD_START, b

    jr nz, .ToggleHidden
    ld a, [wKeyboardHidden]
    xor a, $FF
    ld [wKeyboardHidden], a

    or a
    jr z, .UnHide
    ld a, SCREEN_WIDTH_PX + WX_OFS
    ld [rWX], a

    ld a, [wSelectorY]
    add a, 100
    ld [wSelectorY], a
    ret
.UnHide
    ld a, WX_OFS + KeyboardOffset
    ld [rWX], a

    ld a, [wSelectorY]
    sub a, 100
    ld [wSelectorY], a
.ToggleHidden:

    xor a
    ld [wCurrentKeyPress], a

    bit B_PAD_A, b
    jr nz, .NoPress
    ld a, [wSelectedKeyPressId]
    ld hl, KeyboardMap
    add a, LOW(hl)
    ld LOW(hl), a
    ld a, 0
    adc a, HIGH(hl)
    ld HIGH(hl), a
    ld a, [hl]
    ld [wCurrentKeyPress], a
    ret
.NoPress

    ; update selector
    bit B_PAD_RIGHT, b
    jr nz, .NoMoveRight
    ld a, [wSelectedKeyPressId]

    add a, 3
    and a, $0F
    jr nz, .NoWrapRight
    ld a, [wSelectedKeyPressId]
    sub 13
    ld [wSelectedKeyPressId], a

    ld a, [wSelectorX]
    sub a, 13 * TILE_WIDTH    
    ld [wSelectorX], a
    jr .NoMoveRight
.NoWrapRight:
    ld a, [wSelectedKeyPressId]
    inc a
    ld [wSelectedKeyPressId], a
    
    ld a, [wSelectorX]
    add a, TILE_WIDTH
    ld [wSelectorX], a
.NoMoveRight

    bit B_PAD_LEFT, b
    jr nz, .NoMoveLeft
    ld a, [wSelectedKeyPressId]

    and a, $0F
    jr nz, .NoWrapLeft
    ld a, [wSelectedKeyPressId]
    add 13
    ld [wSelectedKeyPressId], a
    ld a, [wSelectorX]
    add a, 13 * TILE_WIDTH    
    ld [wSelectorX], a
    jr .NoMoveLeft
.NoWrapLeft:

    ld a, [wSelectedKeyPressId]
    dec a
    ld [wSelectedKeyPressId], a

    ld a, [wSelectorX]
    sub a, TILE_WIDTH
    ld [wSelectorX], a
.NoMoveLeft

    bit B_PAD_DOWN, b
    jr nz, .NoMoveDown
    ld a, [wSelectedKeyPressId]
    add a, KeyboardMapRowSize
    ld [wSelectedKeyPressId], a
    
    ld a, [wSelectorY]
    add a, TILE_HEIGHT
    ld [wSelectorY], a
.NoMoveDown

    bit B_PAD_UP, b
    jr nz, .NoMoveUp
    ld a, [wSelectedKeyPressId]
    sub a, KeyboardMapRowSize
    ld [wSelectedKeyPressId], a

    ld a, [wSelectorY]
    sub a, TILE_HEIGHT
    ld [wSelectorY], a
.NoMoveUp

    ; wrap selector values
    ld a, [wSelectedKeyPressId]
    cp a, KeyboardMapSize + KeyboardMapRowSize

    jr c, .NoWrapTop
    add a, KeyboardMapSize
    ld [wSelectedKeyPressId], a

    ld a,  [wSelectorY]
    add a, TILE_HEIGHT * 5
    ld [wSelectorY], a
.NoWrapTop

    ld a, [wSelectedKeyPressId]
    cp a, KeyboardMapSize

    jr c, .NoWrapBottom
    sub a, KeyboardMapSize
    ld [wSelectedKeyPressId], a

    ld a,  [wSelectorY]
    sub a, TILE_HEIGHT * 5
    ld [wSelectorY], a
.NoWrapBottom

    ; flip the selector for transparency effect
    ld a, [wSelectorAttr]
    xor a, 1 << 5
    ld [wSelectorAttr], a

    ret