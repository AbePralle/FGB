; L0909.asm
; Generated 11.01.2000 by mlevel
; Modified  11.01.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0909Section",ROMX
;---------------------------------------------------------------------

L0909_Contents::
  DW L0909_Load
  DW L0909_Init
  DW L0909_Check
  DW L0909_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0909_Load:
        DW ((L0909_LoadFinished - L0909_Load2))  ;size
L0909_Load2:
        call    ParseMap
        ret

L0909_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0909_Map:
INCBIN "Data/Levels/L0909_warzone.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0909_Init:
        DW ((L0909_InitFinished - L0909_Init2))  ;size
L0909_Init2:
        ret

L0909_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0909_Check:
        DW ((L0909_CheckFinished - L0909_Check2))  ;size
L0909_Check2:
        ret

L0909_CheckFinished:
PRINT "0909 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0909_LoadFinished - L0909_Load2)
PRINT " / "
PRINT (L0909_InitFinished - L0909_Init2)
PRINT " / "
PRINT (L0909_CheckFinished - L0909_Check2)
PRINT "\n"

