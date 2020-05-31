; L0109.asm
; Generated 09.04.2000 by mlevel
; Modified  09.04.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0109Section",ROMX
;---------------------------------------------------------------------

L0109_Contents::
  DW L0109_Load
  DW L0109_Init
  DW L0109_Check
  DW L0109_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0109_Load:
        DW ((L0109_LoadFinished - L0109_Load2))  ;size
L0109_Load2:
        call    ParseMap
        ret

L0109_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0109_Map:
INCBIN "Data/Levels/L0109_mouse.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0109_Init:
        DW ((L0109_InitFinished - L0109_Init2))  ;size
L0109_Init2:
        ret

L0109_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0109_Check:
        DW ((L0109_CheckFinished - L0109_Check2))  ;size
L0109_Check2:
        ret

L0109_CheckFinished:
PRINTT "0109 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0109_LoadFinished - L0109_Load2)
PRINTT " / "
PRINTV (L0109_InitFinished - L0109_Init2)
PRINTT " / "
PRINTV (L0109_CheckFinished - L0109_Check2)
PRINTT "\n"

