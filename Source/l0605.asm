; L0605.asm
; Generated 09.14.2000 by mlevel
; Modified  09.14.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0605Section",ROMX
;---------------------------------------------------------------------

L0605_Contents::
  DW L0605_Load
  DW L0605_Init
  DW L0605_Check
  DW L0605_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0605_Load:
        DW ((L0605_LoadFinished - L0605_Load2))  ;size
L0605_Load2:
        call    ParseMap

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$3c]    ;rescue from tower
        or      a
        jr      z,.notRescued

        ;rescued, open gates
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d057
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d097
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d3c1
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d401
        ld      [hl+],a
        ld      [hl],a

.notRescued
        ret

L0605_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0605_Map:
INCBIN "Data/Levels/L0605_garden.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0605_Init:
        DW ((L0605_InitFinished - L0605_Init2))  ;size
L0605_Init2:
        ret

L0605_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0605_Check:
        DW ((L0605_CheckFinished - L0605_Check2))  ;size
L0605_Check2:
        ret

L0605_CheckFinished:
PRINTT "0605 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0605_LoadFinished - L0605_Load2)
PRINTT " / "
PRINTV (L0605_InitFinished - L0605_Init2)
PRINTT " / "
PRINTV (L0605_CheckFinished - L0605_Check2)
PRINTT "\n"

