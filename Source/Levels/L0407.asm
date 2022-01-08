; L0407.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

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
INCBIN "Data/Levels/L0407_bios.lvl"

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
PRINT "0407 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0407_LoadFinished - L0407_Load2)
PRINT " / "
PRINT (L0407_InitFinished - L0407_Init2)
PRINT " / "
PRINT (L0407_CheckFinished - L0407_Check2)
PRINT "\n"

