; L0007.asm
; Generated 09.04.2000 by mlevel
; Modified  09.04.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0007Section",ROMX
;---------------------------------------------------------------------

L0007_Contents::
  DW L0007_Load
  DW L0007_Init
  DW L0007_Check
  DW L0007_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0007_Load:
        DW ((L0007_LoadFinished - L0007_Load2))  ;size
L0007_Load2:
        call    ParseMap
        ret

L0007_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0007_Map:
INCBIN "Data/Levels/L0007_forest.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
CROWINDEX EQU 31
EATRANGE EQU ((29<<8) | 21)

L0007_Init:
        DW ((L0007_InitFinished - L0007_Init2))  ;size
L0007_Init2:
        ;set crows to eat the trees and bushes
        ld      c,CROWINDEX
        call    GetFirst
.setCrowsFood
        ld      hl,EATRANGE
        call    SetFoodIndexRange
        call    GetNextObject
        or      a
        jr      nz,.setCrowsFood

        ret

L0007_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0007_Check:
        DW ((L0007_CheckFinished - L0007_Check2))  ;size
L0007_Check2:
        ret

L0007_CheckFinished:
PRINTT "0007 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0007_LoadFinished - L0007_Load2)
PRINTT " / "
PRINTV (L0007_InitFinished - L0007_Init2)
PRINTT " / "
PRINTV (L0007_CheckFinished - L0007_Check2)
PRINTT "\n"

