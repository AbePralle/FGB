; L0608.asm
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0608Section",ROMX
;---------------------------------------------------------------------

L0608_Contents::
  DW L0608_Load
  DW L0608_Init
  DW L0608_Check
  DW L0608_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0608_Load:
        DW ((L0608_LoadFinished - L0608_Load2))  ;size
L0608_Load2:
        call    ParseMap
        ret

L0608_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0608_Map:
INCBIN "Data/Levels/L0608_moores.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0608_Init:
        DW ((L0608_InitFinished - L0608_Init2))  ;size
L0608_Init2:
        ret

L0608_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0608_Check:
        DW ((L0608_CheckFinished - L0608_Check2))  ;size
L0608_Check2:
        ret

L0608_CheckFinished:
PRINTT "0608 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0608_LoadFinished - L0608_Load2)
PRINTT " / "
PRINTV (L0608_InitFinished - L0608_Init2)
PRINTT " / "
PRINTV (L0608_CheckFinished - L0608_Check2)
PRINTT "\n"

