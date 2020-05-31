; l0503.asm
; Generated 09.05.2000 by mlevel
; Modified  09.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0503Section",DATA
;---------------------------------------------------------------------

L0503_Contents::
  DW L0503_Load
  DW L0503_Init
  DW L0503_Check
  DW L0503_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0503_Load:
        DW ((L0503_LoadFinished - L0503_Load2))  ;size
L0503_Load2:
        call    ParseMap
        ret

L0503_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0503_Map:
INCBIN "..\\fgbeditor\\l0503_hermit.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0503_Init:
        DW ((L0503_InitFinished - L0503_Init2))  ;size
L0503_Init2:
        ret

L0503_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0503_Check:
        DW ((L0503_CheckFinished - L0503_Check2))  ;size
L0503_Check2:
        ret

L0503_CheckFinished:
PRINTT "0503 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0503_LoadFinished - L0503_Load2)
PRINTT " / "
PRINTV (L0503_InitFinished - L0503_Init2)
PRINTT " / "
PRINTV (L0503_CheckFinished - L0503_Check2)
PRINTT "\n"

