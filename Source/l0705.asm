; l0705.asm
; Generated 10.26.2000 by mlevel
; Modified  10.26.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0705Section",ROMX
;---------------------------------------------------------------------

L0705_Contents::
  DW L0705_Load
  DW L0705_Init
  DW L0705_Check
  DW L0705_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0705_Load:
        DW ((L0705_LoadFinished - L0705_Load2))  ;size
L0705_Load2:
        call    ParseMap
        ret

L0705_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0705_Map:
INCBIN "..\\fgbeditor\\l0705_jungle.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0705_Init:
        DW ((L0705_InitFinished - L0705_Init2))  ;size
L0705_Init2:
        ret

L0705_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0705_Check:
        DW ((L0705_CheckFinished - L0705_Check2))  ;size
L0705_Check2:
        ret

L0705_CheckFinished:
PRINTT "0705 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0705_LoadFinished - L0705_Load2)
PRINTT " / "
PRINTV (L0705_InitFinished - L0705_Init2)
PRINTT " / "
PRINTV (L0705_CheckFinished - L0705_Check2)
PRINTT "\n"

