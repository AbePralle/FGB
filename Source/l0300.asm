; l0300.asm
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0300Section",ROMX
;---------------------------------------------------------------------

L0300_Contents::
  DW L0300_Load
  DW L0300_Init
  DW L0300_Check
  DW L0300_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0300_Load:
        DW ((L0300_LoadFinished - L0300_Load2))  ;size
L0300_Load2:
        call    ParseMap
        ret

L0300_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0300_Map:
INCBIN "..\\fgbeditor\\l0300_mist.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0300_Init:
        DW ((L0300_InitFinished - L0300_Init2))  ;size
L0300_Init2:
        ret

L0300_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0300_Check:
        DW ((L0300_CheckFinished - L0300_Check2))  ;size
L0300_Check2:
        ret

L0300_CheckFinished:
PRINTT "0300 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0300_LoadFinished - L0300_Load2)
PRINTT " / "
PRINTV (L0300_InitFinished - L0300_Init2)
PRINTT " / "
PRINTV (L0300_CheckFinished - L0300_Check2)
PRINTT "\n"

