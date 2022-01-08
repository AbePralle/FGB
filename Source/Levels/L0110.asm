; L0110.asm
; Generated 11.06.2000 by mlevel
; Modified  11.06.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0110Section",ROMX
;---------------------------------------------------------------------

L0110_Contents::
  DW L0110_Load
  DW L0110_Init
  DW L0110_Check
  DW L0110_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0110_Load:
        DW ((L0110_LoadFinished - L0110_Load2))  ;size
L0110_Load2:
        call    ParseMap
        ret

L0110_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0110_Map:
INCBIN "Data/Levels/L0110_mouse.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0110_Init:
        DW ((L0110_InitFinished - L0110_Init2))  ;size
L0110_Init2:
        ret

L0110_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0110_Check:
        DW ((L0110_CheckFinished - L0110_Check2))  ;size
L0110_Check2:
        ret

L0110_CheckFinished:
PRINT "0110 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0110_LoadFinished - L0110_Load2)
PRINT " / "
PRINT (L0110_InitFinished - L0110_Init2)
PRINT " / "
PRINT (L0110_CheckFinished - L0110_Check2)
PRINT "\n"

