; l0305.asm
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0305Section",DATA
;---------------------------------------------------------------------

L0305_Contents::
  DW L0305_Load
  DW L0305_Init
  DW L0305_Check
  DW L0305_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0305_Load:
        DW ((L0305_LoadFinished - L0305_Load2))  ;size
L0305_Load2:
        call    ParseMap
        ret

L0305_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0305_Map:
INCBIN "..\\fgbeditor\\L0305_path.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0305_Init:
        DW ((L0305_InitFinished - L0305_Init2))  ;size
L0305_Init2:
        ret

L0305_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0305_Check:
        DW ((L0305_CheckFinished - L0305_Check2))  ;size
L0305_Check2:
        ret

L0305_CheckFinished:
PRINTT "0305 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0305_LoadFinished - L0305_Load2)
PRINTT " / "
PRINTV (L0305_InitFinished - L0305_Init2)
PRINTT " / "
PRINTV (L0305_CheckFinished - L0305_Check2)
PRINTT "\n"

