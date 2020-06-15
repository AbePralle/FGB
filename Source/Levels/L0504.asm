; L0504.asm north gardens
; Generated 10.16.2000 by mlevel
; Modified  10.16.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0504Section",ROMX
;---------------------------------------------------------------------

L0504_Contents::
  DW L0504_Load
  DW L0504_Init
  DW L0504_Check
  DW L0504_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0504_Load:
        DW ((L0504_LoadFinished - L0504_Load2))  ;size
L0504_Load2:
        call    ParseMap
        ret

L0504_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0504_Map:
INCBIN "Data/Levels/L0504_garden.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0504_Init:
        DW ((L0504_InitFinished - L0504_Init2))  ;size
L0504_Init2:
        ret

L0504_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0504_Check:
        DW ((L0504_CheckFinished - L0504_Check2))  ;size
L0504_Check2:
        ret

L0504_CheckFinished:
PRINTT "0504 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0504_LoadFinished - L0504_Load2)
PRINTT " / "
PRINTV (L0504_InitFinished - L0504_Init2)
PRINTT " / "
PRINTV (L0504_CheckFinished - L0504_Check2)
PRINTT "\n"

