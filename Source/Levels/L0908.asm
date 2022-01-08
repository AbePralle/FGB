; L0908.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0908Section",ROMX
;---------------------------------------------------------------------

L0908_Contents::
  DW L0908_Load
  DW L0908_Init
  DW L0908_Check
  DW L0908_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0908_Load:
        DW ((L0908_LoadFinished - L0908_Load2))  ;size
L0908_Load2:
        call    ParseMap
        ret

L0908_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0908_Map:
INCBIN "Data/Levels/L0908_warzone.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0908_Init:
        DW ((L0908_InitFinished - L0908_Init2))  ;size
L0908_Init2:
        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic
        ret

L0908_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0908_Check:
        DW ((L0908_CheckFinished - L0908_Check2))  ;size
L0908_Check2:
        ret

L0908_CheckFinished:
PRINT "0908 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0908_LoadFinished - L0908_Load2)
PRINT " / "
PRINT (L0908_InitFinished - L0908_Init2)
PRINT " / "
PRINT (L0908_CheckFinished - L0908_Check2)
PRINT "\n"

