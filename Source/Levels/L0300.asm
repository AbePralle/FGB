; L0300.asm
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0300Section",ROMX
;---------------------------------------------------------------------

L0300_Contents::
  DW L0300_Load
  DW L0300_Init
  DW L0300_Check
  DW L0300_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0300_Load:
        DW ((L0300_LoadFinished - L0300_Load2))  ;size
L0300_Load2:
        call    ParseMap
        ret

L0300_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0300_Map:
INCBIN "Data/Levels/L0300_mist.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0300_Init:
        DW ((L0300_InitFinished - L0300_Init2))  ;size
L0300_Init2:
        ret

L0300_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0300_Check:
        DW ((L0300_CheckFinished - L0300_Check2))  ;size
L0300_Check2:
        ret

L0300_CheckFinished:
PRINT "0300 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0300_LoadFinished - L0300_Load2)
PRINT " / "
PRINT (L0300_InitFinished - L0300_Init2)
PRINT " / "
PRINT (L0300_CheckFinished - L0300_Check2)
PRINT "\n"

