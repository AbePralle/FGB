; L0510.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0510Section",ROMX
;---------------------------------------------------------------------

L0510_Contents::
  DW L0510_Load
  DW L0510_Init
  DW L0510_Check
  DW L0510_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0510_Load:
        DW ((L0510_LoadFinished - L0510_Load2))  ;size
L0510_Load2:
        call    ParseMap
        ret

L0510_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0510_Map:
INCBIN "Data/Levels/L0510_summer.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0510_Init:
        DW ((L0510_InitFinished - L0510_Init2))  ;size
L0510_Init2:
        ret

L0510_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0510_Check:
        DW ((L0510_CheckFinished - L0510_Check2))  ;size
L0510_Check2:
        ret

L0510_CheckFinished:
PRINT "0510 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0510_LoadFinished - L0510_Load2)
PRINT " / "
PRINT (L0510_InitFinished - L0510_Init2)
PRINT " / "
PRINT (L0510_CheckFinished - L0510_Check2)
PRINT "\n"

