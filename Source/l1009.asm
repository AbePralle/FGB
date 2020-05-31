; l1009.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1009Section",DATA
;---------------------------------------------------------------------

L1009_Contents::
  DW L1009_Load
  DW L1009_Init
  DW L1009_Check
  DW L1009_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1009_Load:
        DW ((L1009_LoadFinished - L1009_Load2))  ;size
L1009_Load2:
        call    ParseMap
        ret

L1009_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1009_Map:
INCBIN "..\\fgbeditor\\l1009_warzone.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1009_Init:
        DW ((L1009_InitFinished - L1009_Init2))  ;size
L1009_Init2:
        ret

L1009_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1009_Check:
        DW ((L1009_CheckFinished - L1009_Check2))  ;size
L1009_Check2:
        ret

L1009_CheckFinished:
PRINTT "1009 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1009_LoadFinished - L1009_Load2)
PRINTT " / "
PRINTV (L1009_InitFinished - L1009_Init2)
PRINTT " / "
PRINTV (L1009_CheckFinished - L1009_Check2)
PRINTT "\n"

