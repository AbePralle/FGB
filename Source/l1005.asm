; l1005.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1005Section",ROMX
;---------------------------------------------------------------------

L1005_Contents::
  DW L1005_Load
  DW L1005_Init
  DW L1005_Check
  DW L1005_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1005_Load:
        DW ((L1005_LoadFinished - L1005_Load2))  ;size
L1005_Load2:
        call    ParseMap
        ret

L1005_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1005_Map:
INCBIN "..\\fgbeditor\\L1005_autumn.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1005_Init:
        DW ((L1005_InitFinished - L1005_Init2))  ;size
L1005_Init2:
        ret

L1005_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1005_Check:
        DW ((L1005_CheckFinished - L1005_Check2))  ;size
L1005_Check2:
        ret

L1005_CheckFinished:
PRINTT "1005 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1005_LoadFinished - L1005_Load2)
PRINTT " / "
PRINTV (L1005_InitFinished - L1005_Init2)
PRINTT " / "
PRINTV (L1005_CheckFinished - L1005_Check2)
PRINTT "\n"

