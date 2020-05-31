; l1004.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1004Section",ROMX
;---------------------------------------------------------------------

L1004_Contents::
  DW L1004_Load
  DW L1004_Init
  DW L1004_Check
  DW L1004_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1004_Load:
        DW ((L1004_LoadFinished - L1004_Load2))  ;size
L1004_Load2:
        call    ParseMap
        ret

L1004_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1004_Map:
INCBIN "..\\fgbeditor\\L1004_pumpkins.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1004_Init:
        DW ((L1004_InitFinished - L1004_Init2))  ;size
L1004_Init2:
        ret

L1004_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1004_Check:
        DW ((L1004_CheckFinished - L1004_Check2))  ;size
L1004_Check2:
        ret

L1004_CheckFinished:
PRINTT "1004 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1004_LoadFinished - L1004_Load2)
PRINTT " / "
PRINTV (L1004_InitFinished - L1004_Init2)
PRINTT " / "
PRINTV (L1004_CheckFinished - L1004_Check2)
PRINTT "\n"

