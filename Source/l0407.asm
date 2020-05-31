; l0407.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0407Section",ROMX
;---------------------------------------------------------------------

L0407_Contents::
  DW L0407_Load
  DW L0407_Init
  DW L0407_Check
  DW L0407_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0407_Load:
        DW ((L0407_LoadFinished - L0407_Load2))  ;size
L0407_Load2:
        call    ParseMap
        ret

L0407_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0407_Map:
INCBIN "Data/Levels/l0407_bios.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0407_Init:
        DW ((L0407_InitFinished - L0407_Init2))  ;size
L0407_Init2:
        ret

L0407_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0407_Check:
        DW ((L0407_CheckFinished - L0407_Check2))  ;size
L0407_Check2:
        ret

L0407_CheckFinished:
PRINTT "0407 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0407_LoadFinished - L0407_Load2)
PRINTT " / "
PRINTV (L0407_InitFinished - L0407_Init2)
PRINTT " / "
PRINTV (L0407_CheckFinished - L0407_Check2)
PRINTT "\n"

