; L0801.asm
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0801Section",ROMX
;---------------------------------------------------------------------

L0801_Contents::
  DW L0801_Load
  DW L0801_Init
  DW L0801_Check
  DW L0801_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0801_Load:
        DW ((L0801_LoadFinished - L0801_Load2))  ;size
L0801_Load2:
        call    ParseMap
        ret

L0801_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0801_Map:
INCBIN "Data/Levels/L0801_escape.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0801_Init:
        DW ((L0801_InitFinished - L0801_Init2))  ;size
L0801_Init2:
        ret

L0801_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0801_Check:
        DW ((L0801_CheckFinished - L0801_Check2))  ;size
L0801_Check2:
        ret

L0801_CheckFinished:
PRINTT "0801 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0801_LoadFinished - L0801_Load2)
PRINTT " / "
PRINTV (L0801_InitFinished - L0801_Init2)
PRINTT " / "
PRINTV (L0801_CheckFinished - L0801_Check2)
PRINTT "\n"

