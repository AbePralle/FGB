; L1004.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level1004Section",ROMX
;---------------------------------------------------------------------

L1004_Contents::
  DW L1004_Load
  DW L1004_Init
  DW L1004_Check
  DW L1004_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1004_Load:
        DW ((L1004_LoadFinished - L1004_Load2))  ;size
L1004_Load2:
        call    ParseMap
        ret

L1004_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1004_Map:
INCBIN "Data/Levels/L1004_pumpkins.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1004_Init:
        DW ((L1004_InitFinished - L1004_Init2))  ;size
L1004_Init2:
        ret

L1004_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1004_Check:
        DW ((L1004_CheckFinished - L1004_Check2))  ;size
L1004_Check2:
        ret

L1004_CheckFinished:
PRINT "1004 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1004_LoadFinished - L1004_Load2)
PRINT " / "
PRINT (L1004_InitFinished - L1004_Init2)
PRINT " / "
PRINT (L1004_CheckFinished - L1004_Check2)
PRINT "\n"

