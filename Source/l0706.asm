; l0706.asm
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0706Section",ROMX
;---------------------------------------------------------------------

L0706_Contents::
  DW L0706_Load
  DW L0706_Init
  DW L0706_Check
  DW L0706_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0706_Load:
        DW ((L0706_LoadFinished - L0706_Load2))  ;size
L0706_Load2:
        call    ParseMap
        ret

L0706_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0706_Map:
INCBIN "..\\fgbeditor\\l0706_swamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0706_Init:
        DW ((L0706_InitFinished - L0706_Init2))  ;size
L0706_Init2:
        ret

L0706_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0706_Check:
        DW ((L0706_CheckFinished - L0706_Check2))  ;size
L0706_Check2:
        ret

L0706_CheckFinished:
PRINTT "0706 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0706_LoadFinished - L0706_Load2)
PRINTT " / "
PRINTV (L0706_InitFinished - L0706_Init2)
PRINTT " / "
PRINTV (L0706_CheckFinished - L0706_Check2)
PRINTT "\n"

