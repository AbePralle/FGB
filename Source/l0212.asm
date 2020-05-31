; L0212.asm
; Generated 08.31.2000 by mlevel
; Modified  08.31.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0212Section",ROMX
;---------------------------------------------------------------------

L0212_Contents::
  DW L0212_Load
  DW L0212_Init
  DW L0212_Check
  DW L0212_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0212_Load:
        DW ((L0212_LoadFinished - L0212_Load2))  ;size
L0212_Load2:
        call    ParseMap
        ret

L0212_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0212_Map:
INCBIN "Data/Levels/L0212_sunsethouseup.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0212_Init:
        DW ((L0212_InitFinished - L0212_Init2))  ;size
L0212_Init2:
        ret

L0212_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0212_Check:
        DW ((L0212_CheckFinished - L0212_Check2))  ;size
L0212_Check2:
        ret

L0212_CheckFinished:
PRINTT "0212 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0212_LoadFinished - L0212_Load2)
PRINTT " / "
PRINTV (L0212_InitFinished - L0212_Init2)
PRINTT " / "
PRINTV (L0212_CheckFinished - L0212_Check2)
PRINTT "\n"

