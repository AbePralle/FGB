; L0009.asm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0009Section",ROMX
;---------------------------------------------------------------------

L0009_Contents::
  DW L0009_Load
  DW L0009_Init
  DW L0009_Check
  DW L0009_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0009_Load:
        DW ((L0009_LoadFinished - L0009_Load2))  ;size
L0009_Load2:
        call    ParseMap
        ret

L0009_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0009_Map:
INCBIN "Data/Levels/L0009_mouse.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0009_Init:
        DW ((L0009_InitFinished - L0009_Init2))  ;size
L0009_Init2:
        ret

L0009_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0009_Check:
        DW ((L0009_CheckFinished - L0009_Check2))  ;size
L0009_Check2:
        ret

L0009_CheckFinished:
PRINT "0009 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0009_LoadFinished - L0009_Load2)
PRINT " / "
PRINT (L0009_InitFinished - L0009_Init2)
PRINT " / "
PRINT (L0009_CheckFinished - L0009_Check2)
PRINT "\n"

