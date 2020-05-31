; L0402.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0402Section",ROMX
;---------------------------------------------------------------------

L0402_Contents::
  DW L0402_Load
  DW L0402_Init
  DW L0402_Check
  DW L0402_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0402_Load:
        DW ((L0402_LoadFinished - L0402_Load2))  ;size
L0402_Load2:
        call    ParseMap
        ret

L0402_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0402_Map:
INCBIN "Data/Levels/L0402_dusk.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0402_Init:
        DW ((L0402_InitFinished - L0402_Init2))  ;size
L0402_Init2:
        ret

L0402_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0402_Check:
        DW ((L0402_CheckFinished - L0402_Check2))  ;size
L0402_Check2:
        ret

L0402_CheckFinished:
PRINTT "0402 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0402_LoadFinished - L0402_Load2)
PRINTT " / "
PRINTV (L0402_InitFinished - L0402_Init2)
PRINTT " / "
PRINTV (L0402_CheckFinished - L0402_Check2)
PRINTT "\n"

