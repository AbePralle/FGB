; L1005.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level1005Section",ROMX
;---------------------------------------------------------------------

L1005_Contents::
  DW L1005_Load
  DW L1005_Init
  DW L1005_Check
  DW L1005_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1005_Load:
        DW ((L1005_LoadFinished - L1005_Load2))  ;size
L1005_Load2:
        call    ParseMap
        ret

L1005_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1005_Map:
INCBIN "Data/Levels/L1005_autumn.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1005_Init:
        DW ((L1005_InitFinished - L1005_Init2))  ;size
L1005_Init2:
        ret

L1005_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1005_Check:
        DW ((L1005_CheckFinished - L1005_Check2))  ;size
L1005_Check2:
        ret

L1005_CheckFinished:
PRINT "1005 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1005_LoadFinished - L1005_Load2)
PRINT " / "
PRINT (L1005_InitFinished - L1005_Init2)
PRINT " / "
PRINT (L1005_CheckFinished - L1005_Check2)
PRINT "\n"

