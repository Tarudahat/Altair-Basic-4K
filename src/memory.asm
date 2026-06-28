SECTION "Memory", ROM0

;de hl bc = src dst size
MemCpy::
    ld a, [de]
    inc de
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jr nz, MemCpy
    ret

;de hl = src dst
MemCpyTill0::
    ld a, [de]
    inc de
    ld [hl+], a
    or a
    jr nz, MemCpyTill0
    ret

;hl bc = dst count
MemClr::
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or a, c
    jr nz, MemClr
    ret