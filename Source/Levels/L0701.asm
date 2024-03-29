; L0701.asm kiwi keep
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0701Section",ROMX
;---------------------------------------------------------------------

L0701_Contents::
  DW L0701_Load
  DW L0701_Init
  DW L0701_Check
  DW L0701_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0701_Load:
        DW ((L0701_LoadFinished - L0701_Load2))  ;size
L0701_Load2:
        call    ParseMap
        ret

L0701_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0701_Map:
INCBIN "Data/Levels/L0701_kiwikeep.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0701_Init:
        DW ((L0701_InitFinished - L0701_Init2))  ;size
L0701_Init2:
        ld      a,ENV_CLOUDS
        call    SetEnvEffect
        ret

L0701_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0701_Check:
        DW ((L0701_CheckFinished - L0701_Check2))  ;size
L0701_Check2:
        ret

L0701_CheckFinished:
PRINT "0701 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0701_LoadFinished - L0701_Load2)
PRINT " / "
PRINT (L0701_InitFinished - L0701_Init2)
PRINT " / "
PRINT (L0701_CheckFinished - L0701_Check2)
PRINT "\n"

