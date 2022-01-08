; L0805.asm
; Generated 10.27.2000 by mlevel
; Modified  10.27.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0805Section",ROMX
;---------------------------------------------------------------------

L0805_Contents::
  DW L0805_Load
  DW L0805_Init
  DW L0805_Check
  DW L0805_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0805_Load:
        DW ((L0805_LoadFinished - L0805_Load2))  ;size
L0805_Load2:
        call    ParseMap
        ret

L0805_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0805_Map:
INCBIN "Data/Levels/L0805_jungle.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0805_Init:
        DW ((L0805_InitFinished - L0805_Init2))  ;size
L0805_Init2:
        ret

L0805_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0805_Check:
        DW ((L0805_CheckFinished - L0805_Check2))  ;size
L0805_Check2:
        ret

L0805_CheckFinished:
PRINT "0805 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0805_LoadFinished - L0805_Load2)
PRINT " / "
PRINT (L0805_InitFinished - L0805_Init2)
PRINT " / "
PRINT (L0805_CheckFinished - L0805_Check2)
PRINT "\n"

