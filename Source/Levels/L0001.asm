; L0001.asm outside the hive
; Generated 08.27.2000 by mlevel
; Modified  08.27.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 35
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0001Section",ROMX
;---------------------------------------------------------------------

L0001_Contents::
  DW L0001_Load
  DW L0001_Init
  DW L0001_Check
  DW L0001_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0001_Load:
        DW ((L0001_LoadFinished - L0001_Load2))  ;size
L0001_Load2:
        call    ParseMap
        ret

L0001_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0001_Map:
INCBIN "Data/Levels/L0001_bees.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0001_Init:
        DW ((L0001_InitFinished - L0001_Init2))  ;size
L0001_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ret

L0001_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0001_Check:
        DW ((L0001_CheckFinished - L0001_Check2))  ;size
L0001_Check2:
        call    ((.animateWater-L0001_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0001_CheckFinished:
PRINT "0001 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0001_LoadFinished - L0001_Load2)
PRINT " / "
PRINT (L0001_InitFinished - L0001_Init2)
PRINT " / "
PRINT (L0001_CheckFinished - L0001_Check2)
PRINT "\n"

