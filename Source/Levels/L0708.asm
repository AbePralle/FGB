; L0708.asm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0708Section",ROMX
;---------------------------------------------------------------------

L0708_Contents::
  DW L0708_Load
  DW L0708_Init
  DW L0708_Check
  DW L0708_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0708_Load:
        DW ((L0708_LoadFinished - L0708_Load2))  ;size
L0708_Load2:
        call    ParseMap
        ret

L0708_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0708_Map:
INCBIN "Data/Levels/L0708_swamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0708_Init:
        DW ((L0708_InitFinished - L0708_Init2))  ;size
L0708_Init2:
        ret

L0708_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0708_Check:
        DW ((L0708_CheckFinished - L0708_Check2))  ;size
L0708_Check2:
        ret

L0708_CheckFinished:
PRINT "0708 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0708_LoadFinished - L0708_Load2)
PRINT " / "
PRINT (L0708_InitFinished - L0708_Init2)
PRINT " / "
PRINT (L0708_CheckFinished - L0708_Check2)
PRINT "\n"

