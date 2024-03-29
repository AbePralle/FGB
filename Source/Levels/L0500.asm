; L0500.asm
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0500Section",ROMX
;---------------------------------------------------------------------

L0500_Contents::
  DW L0500_Load
  DW L0500_Init
  DW L0500_Check
  DW L0500_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0500_Load:
        DW ((L0500_LoadFinished - L0500_Load2))  ;size
L0500_Load2:
        call    ParseMap
        ret

L0500_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0500_Map:
INCBIN "Data/Levels/L0500_ice.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0500_Init:
        DW ((L0500_InitFinished - L0500_Init2))  ;size
L0500_Init2:
        call    UseAlternatePalette
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0500_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0500_Check:
        DW ((L0500_CheckFinished - L0500_Check2))  ;size
L0500_Check2:
        ret

L0500_CheckFinished:
PRINT "0500 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0500_LoadFinished - L0500_Load2)
PRINT " / "
PRINT (L0500_InitFinished - L0500_Init2)
PRINT " / "
PRINT (L0500_CheckFinished - L0500_Check2)
PRINT "\n"

