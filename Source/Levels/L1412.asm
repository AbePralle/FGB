; L1412.asm Crouton Homeworld 3
; Generated 04.19.2001 by mlevel
; Modified  04.19.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level1412Section",ROMX
;---------------------------------------------------------------------

L1412_Contents::
  DW L1412_Load
  DW L1412_Init
  DW L1412_Check
  DW L1412_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1412_Load:
        DW ((L1412_LoadFinished - L1412_Load2))  ;size
L1412_Load2:
        call    ParseMap
        ret

L1412_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1412_Map:
INCBIN "Data/Levels/L1412_crouton_hw3.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1412_Init:
        DW ((L1412_InitFinished - L1412_Init2))  ;size
L1412_Init2:
        ret

L1412_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1412_Check:
        DW ((L1412_CheckFinished - L1412_Check2))  ;size
L1412_Check2:
        ret

L1412_CheckFinished:
PRINT "1412 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1412_LoadFinished - L1412_Load2)
PRINT " / "
PRINT (L1412_InitFinished - L1412_Init2)
PRINT " / "
PRINT (L1412_CheckFinished - L1412_Check2)
PRINT "\n"

