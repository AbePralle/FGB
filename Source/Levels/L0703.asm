; L0703.asm
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0703Section",ROMX
;---------------------------------------------------------------------

L0703_Contents::
  DW L0703_Load
  DW L0703_Init
  DW L0703_Check
  DW L0703_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0703_Load:
        DW ((L0703_LoadFinished - L0703_Load2))  ;size
L0703_Load2:
        call    ParseMap
        ret

L0703_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0703_Map:
INCBIN "Data/Levels/L0703_caverns.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0703_Init:
        DW ((L0703_InitFinished - L0703_Init2))  ;size
L0703_Init2:
        ret

L0703_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0703_Check:
        DW ((L0703_CheckFinished - L0703_Check2))  ;size
L0703_Check2:
        ret

L0703_CheckFinished:
PRINT "0703 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0703_LoadFinished - L0703_Load2)
PRINT " / "
PRINT (L0703_InitFinished - L0703_Init2)
PRINT " / "
PRINT (L0703_CheckFinished - L0703_Check2)
PRINT "\n"

