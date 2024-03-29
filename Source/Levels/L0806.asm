; L0806.asm
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0806Section",ROMX
;---------------------------------------------------------------------

L0806_Contents::
  DW L0806_Load
  DW L0806_Init
  DW L0806_Check
  DW L0806_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0806_Load:
        DW ((L0806_LoadFinished - L0806_Load2))  ;size
L0806_Load2:
        call    ParseMap
        ret

L0806_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0806_Map:
INCBIN "Data/Levels/L0806_moores.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0806_Init:
        DW ((L0806_InitFinished - L0806_Init2))  ;size
L0806_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0806_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0806_Check:
        DW ((L0806_CheckFinished - L0806_Check2))  ;size
L0806_Check2:
        ret

L0806_CheckFinished:
PRINT "0806 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0806_LoadFinished - L0806_Load2)
PRINT " / "
PRINT (L0806_InitFinished - L0806_Init2)
PRINT " / "
PRINT (L0806_CheckFinished - L0806_Check2)
PRINT "\n"

