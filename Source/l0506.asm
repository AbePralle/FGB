; l0506.asm
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0506Section",ROMX
;---------------------------------------------------------------------

L0506_Contents::
  DW L0506_Load
  DW L0506_Init
  DW L0506_Check
  DW L0506_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0506_Load:
        DW ((L0506_LoadFinished - L0506_Load2))  ;size
L0506_Load2:
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
        ld      hl,$d04f
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d06f
        ld      [hl+],a
        ld      [hl],a

.notRescued
        ret

L0506_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0506_Map:
INCBIN "Data/Levels/l0506_garden.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0506_Init:
        DW ((L0506_InitFinished - L0506_Init2))  ;size
L0506_Init2:
        ret

L0506_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0506_Check:
        DW ((L0506_CheckFinished - L0506_Check2))  ;size
L0506_Check2:
        ret

L0506_CheckFinished:
PRINTT "0506 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0506_LoadFinished - L0506_Load2)
PRINTT " / "
PRINTV (L0506_InitFinished - L0506_Init2)
PRINTT " / "
PRINTV (L0506_CheckFinished - L0506_Check2)
PRINTT "\n"

