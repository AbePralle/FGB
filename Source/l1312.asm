; l1312.asm Crouton Homeworld 2
; Generated 04.19.2001 by mlevel
; Modified  04.19.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1312Section",DATA
;---------------------------------------------------------------------

L1312_Contents::
  DW L1312_Load
  DW L1312_Init
  DW L1312_Check
  DW L1312_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1312_Load:
        DW ((L1312_LoadFinished - L1312_Load2))  ;size
L1312_Load2:
        call    ParseMap
        ret

L1312_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1312_Map:
INCBIN "..\\fgbeditor\\L1312_crouton_hw2.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1312_Init:
        DW ((L1312_InitFinished - L1312_Init2))  ;size
L1312_Init2:
        ret

L1312_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1312_Check:
        DW ((L1312_CheckFinished - L1312_Check2))  ;size
L1312_Check2:
        ret

L1312_CheckFinished:
PRINTT "1312 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1312_LoadFinished - L1312_Load2)
PRINTT " / "
PRINTV (L1312_InitFinished - L1312_Init2)
PRINTT " / "
PRINTV (L1312_CheckFinished - L1312_Check2)
PRINTT "\n"
