; L0502.asm
; Generated 09.05.2000 by mlevel
; Modified  09.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0502Section",ROMX
;---------------------------------------------------------------------

L0502_Contents::
  DW L0502_Load
  DW L0502_Init
  DW L0502_Check
  DW L0502_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0502_Load:
        DW ((L0502_LoadFinished - L0502_Load2))  ;size
L0502_Load2:
        call    ParseMap
        ret

L0502_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0502_Map:
INCBIN "Data/Levels/L0502_chill.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0502_Init:
        DW ((L0502_InitFinished - L0502_Init2))  ;size
L0502_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0502_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0502_Check:
        DW ((L0502_CheckFinished - L0502_Check2))  ;size
L0502_Check2:
        ret

L0502_CheckFinished:
PRINT "0502 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0502_LoadFinished - L0502_Load2)
PRINT " / "
PRINT (L0502_InitFinished - L0502_Init2)
PRINT " / "
PRINT (L0502_CheckFinished - L0502_Check2)
PRINT "\n"

