; L0409.asm
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0409Section",ROMX
;---------------------------------------------------------------------

L0409_Contents::
  DW L0409_Load
  DW L0409_Init
  DW L0409_Check
  DW L0409_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0409_Load:
        DW ((L0409_LoadFinished - L0409_Load2))  ;size
L0409_Load2:
        call    ParseMap
        ret

L0409_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0409_Map:
INCBIN "Data/Levels/L0409_desert.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0409_Init:
        DW ((L0409_InitFinished - L0409_Init2))  ;size
L0409_Init2:
        ret

L0409_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0409_Check:
        DW ((L0409_CheckFinished - L0409_Check2))  ;size
L0409_Check2:
        ret

L0409_CheckFinished:
PRINT "0409 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0409_LoadFinished - L0409_Load2)
PRINT " / "
PRINT (L0409_InitFinished - L0409_Init2)
PRINT " / "
PRINT (L0409_CheckFinished - L0409_Check2)
PRINT "\n"

