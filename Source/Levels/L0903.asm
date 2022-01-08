; L0903.asm
; Generated 01.03.1980 by mlevel
; Modified  01.03.1980 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0903Section",ROMX
;---------------------------------------------------------------------

L0903_Contents::
  DW L0903_Load
  DW L0903_Init
  DW L0903_Check
  DW L0903_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0903_Load:
        DW ((L0903_LoadFinished - L0903_Load2))  ;size
L0903_Load2:
        call    ParseMap
        ret

L0903_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0903_Map:
INCBIN "Data/Levels/L0903_cornville.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0903_Init:
        DW ((L0903_InitFinished - L0903_Init2))  ;size
L0903_Init2:
        ret

L0903_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0903_Check:
        DW ((L0903_CheckFinished - L0903_Check2))  ;size
L0903_Check2:
        ret

L0903_CheckFinished:
PRINT "0903 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0903_LoadFinished - L0903_Load2)
PRINT " / "
PRINT (L0903_InitFinished - L0903_Init2)
PRINT " / "
PRINT (L0903_CheckFinished - L0903_Check2)
PRINT "\n"

