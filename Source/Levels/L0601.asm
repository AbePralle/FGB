; L0601.asm
; Generated 09.05.2000 by mlevel
; Modified  09.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0601Section",ROMX
;---------------------------------------------------------------------

L0601_Contents::
  DW L0601_Load
  DW L0601_Init
  DW L0601_Check
  DW L0601_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0601_Load:
        DW ((L0601_LoadFinished - L0601_Load2))  ;size
L0601_Load2:
        call    ParseMap
        ret

L0601_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0601_Map:
INCBIN "Data/Levels/L0601_wolf.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0601_Init:
        DW ((L0601_InitFinished - L0601_Init2))  ;size
L0601_Init2:
        call    UseAlternatePalette
        ret

L0601_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0601_Check:
        DW ((L0601_CheckFinished - L0601_Check2))  ;size
L0601_Check2:
        ret

L0601_CheckFinished:
PRINTT "0601 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0601_LoadFinished - L0601_Load2)
PRINTT " / "
PRINTV (L0601_InitFinished - L0601_Init2)
PRINTT " / "
PRINTV (L0601_CheckFinished - L0601_Check2)
PRINTT "\n"

