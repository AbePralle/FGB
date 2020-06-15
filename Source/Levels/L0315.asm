; L0315.asm
; Generated 07.30.2000 by mlevel
; Modified  07.30.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0315Section",ROMX
;---------------------------------------------------------------------

L0315_Contents::
  DW L0315_Load
  DW L0315_Init
  DW L0315_Check
  DW L0315_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0315_Load:
        DW ((L0315_LoadFinished - L0315_Load2))  ;size
L0315_Load2:
        call    ParseMap
        ret

L0315_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0315_Map:
INCBIN "Data/Levels/L0315_intro_bs4.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0315_Init:
        DW ((L0315_InitFinished - L0315_Init2))  ;size
L0315_Init2:
        ret

L0315_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0315_Check:
        DW ((L0315_CheckFinished - L0315_Check2))  ;size
L0315_Check2:
        ret

L0315_CheckFinished:
PRINTT "0315 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0315_LoadFinished - L0315_Load2)
PRINTT " / "
PRINTV (L0315_InitFinished - L0315_Init2)
PRINTT " / "
PRINTV (L0315_CheckFinished - L0315_Check2)
PRINTT "\n"

