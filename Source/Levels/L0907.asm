; L0907.asm bullseye village
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0907Section",ROMX
;---------------------------------------------------------------------

L0907_Contents::
  DW L0907_Load
  DW L0907_Init
  DW L0907_Check
  DW L0907_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0907_Load:
        DW ((L0907_LoadFinished - L0907_Load2))  ;size
L0907_Load2:
        call    ParseMap
        ret

L0907_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0907_Map:
INCBIN "Data/Levels/L0907_bullseye.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0907_Init:
        DW ((L0907_InitFinished - L0907_Init2))  ;size
L0907_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0907_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0907_Check:
        DW ((L0907_CheckFinished - L0907_Check2))  ;size
L0907_Check2:
        ret

L0907_CheckFinished:
PRINT "0907 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0907_LoadFinished - L0907_Load2)
PRINT " / "
PRINT (L0907_InitFinished - L0907_Init2)
PRINT " / "
PRINT (L0907_CheckFinished - L0907_Check2)
PRINT "\n"

