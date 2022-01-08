; L1009.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level1009Section",ROMX
;---------------------------------------------------------------------

L1009_Contents::
  DW L1009_Load
  DW L1009_Init
  DW L1009_Check
  DW L1009_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1009_Load:
        DW ((L1009_LoadFinished - L1009_Load2))  ;size
L1009_Load2:
        call    ParseMap
        ret

L1009_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1009_Map:
INCBIN "Data/Levels/L1009_warzone.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1009_Init:
        DW ((L1009_InitFinished - L1009_Init2))  ;size
L1009_Init2:
        ret

L1009_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1009_Check:
        DW ((L1009_CheckFinished - L1009_Check2))  ;size
L1009_Check2:
        ret

L1009_CheckFinished:
PRINT "1009 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1009_LoadFinished - L1009_Load2)
PRINT " / "
PRINT (L1009_InitFinished - L1009_Init2)
PRINT " / "
PRINT (L1009_CheckFinished - L1009_Check2)
PRINT "\n"

