; l0708.asm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0708Section",DATA
;---------------------------------------------------------------------

L0708_Contents::
  DW L0708_Load
  DW L0708_Init
  DW L0708_Check
  DW L0708_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0708_Load:
        DW ((L0708_LoadFinished - L0708_Load2))  ;size
L0708_Load2:
        call    ParseMap
        ret

L0708_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0708_Map:
INCBIN "..\\fgbeditor\\l0708_swamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0708_Init:
        DW ((L0708_InitFinished - L0708_Init2))  ;size
L0708_Init2:
        ret

L0708_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0708_Check:
        DW ((L0708_CheckFinished - L0708_Check2))  ;size
L0708_Check2:
        ret

L0708_CheckFinished:
PRINTT "0708 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0708_LoadFinished - L0708_Load2)
PRINTT " / "
PRINTV (L0708_InitFinished - L0708_Init2)
PRINTT " / "
PRINTV (L0708_CheckFinished - L0708_Check2)
PRINTT "\n"

