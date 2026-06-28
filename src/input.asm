INCLUDE "include/hardware.inc"

SECTION "InputVars", WRAM0

; Down Up Left Right Start Select B A
wCurrentBtns::db; pressed
wChangedBtns::db; delta pressed

SECTION "Input", ROM0
UpdateBtns::
    ld  a, JOYP_GET_CTRL_PAD
    call .GetBtns

    ; mask off top half
    and $0F
    swap a
    ld b, a

    ld  a, JOYP_GET_BUTTONS
    call .GetBtns

    and $0F
    or a, b
    ld b, a

    ld a, JOYP_GET_NONE
    ldh [rJOYP], a

    ; compare to previous btns state to determine newly pressed
    ld a, [wCurrentBtns]
    xor a, b
    cpl
    ld [wChangedBtns], a

    ; store currenct btns state
    ld a, b
    ld [wCurrentBtns], a

    ret

.GetBtns
    ; tell it to poll for ABSS or UDLR
    ldh [rJOYP], a

    ; read btns
    ldh a, [rJOYP]
    call .CycleWaster

    ; read again after stabelisation
    ldh a, [rJOYP]

.CycleWaster
    ret
