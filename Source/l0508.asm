; l0508.asm
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0508Section",ROMX
;---------------------------------------------------------------------

L0508_Contents::
  DW L0508_Load
  DW L0508_Init
  DW L0508_Check
  DW L0508_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0508_Load:
        DW ((L0508_LoadFinished - L0508_Load2))  ;size
L0508_Load2:
        call    ParseMap
        ret

L0508_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0508_Map:
INCBIN "..\\fgbeditor\\l0508_witch.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0508_Init:
        DW ((L0508_InitFinished - L0508_Init2))  ;size
L0508_Init2:
        ret

L0508_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0508_Check:
        DW ((L0508_CheckFinished - L0508_Check2))  ;size
L0508_Check2:
        ret

L0508_CheckFinished:
PRINTT "0508 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0508_LoadFinished - L0508_Load2)
PRINTT " / "
PRINTV (L0508_InitFinished - L0508_Init2)
PRINTT " / "
PRINTV (L0508_CheckFinished - L0508_Check2)
PRINTT "\n"

