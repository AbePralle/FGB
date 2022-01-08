; L0305.asm
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0305Section",ROMX
;---------------------------------------------------------------------

L0305_Contents::
  DW L0305_Load
  DW L0305_Init
  DW L0305_Check
  DW L0305_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0305_Load:
        DW ((L0305_LoadFinished - L0305_Load2))  ;size
L0305_Load2:
        call    ParseMap
        ret

L0305_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0305_Map:
INCBIN "Data/Levels/L0305_path.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0305_Init:
        DW ((L0305_InitFinished - L0305_Init2))  ;size
L0305_Init2:
        ret

L0305_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0305_Check:
        DW ((L0305_CheckFinished - L0305_Check2))  ;size
L0305_Check2:
        ret

L0305_CheckFinished:
PRINT "0305 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0305_LoadFinished - L0305_Load2)
PRINT " / "
PRINT (L0305_InitFinished - L0305_Init2)
PRINT " / "
PRINT (L0305_CheckFinished - L0305_Check2)
PRINT "\n"

