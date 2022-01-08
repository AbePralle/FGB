; L0309.asm
; Generated 11.14.2000 by mlevel
; Modified  11.14.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0309Section",ROMX
;---------------------------------------------------------------------

L0309_Contents::
  DW L0309_Load
  DW L0309_Init
  DW L0309_Check
  DW L0309_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0309_Load:
        DW ((L0309_LoadFinished - L0309_Load2))  ;size
L0309_Load2:
        call    ParseMap
        ret

L0309_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0309_Map:
INCBIN "Data/Levels/L0309_desert.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0309_Init:
        DW ((L0309_InitFinished - L0309_Init2))  ;size
L0309_Init2:
        ret

L0309_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0309_Check:
        DW ((L0309_CheckFinished - L0309_Check2))  ;size
L0309_Check2:
        ret

L0309_CheckFinished:
PRINT "0309 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0309_LoadFinished - L0309_Load2)
PRINT " / "
PRINT (L0309_InitFinished - L0309_Init2)
PRINT " / "
PRINT (L0309_CheckFinished - L0309_Check2)
PRINT "\n"

