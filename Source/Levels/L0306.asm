; L0306.asm Two Guns
; Generated 11.07.2000 by mlevel
; Modified  11.07.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0306Section",ROMX
;---------------------------------------------------------------------

L0306_Contents::
  DW L0306_Load
  DW L0306_Init
  DW L0306_Check
  DW L0306_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0306_Load:
        DW ((L0306_LoadFinished - L0306_Load2))  ;size
L0306_Load2:
        call    ParseMap
        ret

L0306_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0306_Map:
INCBIN "Data/Levels/L0306_twoguns.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0306_Init:
        DW ((L0306_InitFinished - L0306_Init2))  ;size
L0306_Init2:
        ld      a,ENV_DIRT
        call    SetEnvEffect
        ret

L0306_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0306_Check:
        DW ((L0306_CheckFinished - L0306_Check2))  ;size
L0306_Check2:
        ret

L0306_CheckFinished:
PRINT "0306 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0306_LoadFinished - L0306_Load2)
PRINT " / "
PRINT (L0306_InitFinished - L0306_Init2)
PRINT " / "
PRINT (L0306_CheckFinished - L0306_Check2)
PRINT "\n"

