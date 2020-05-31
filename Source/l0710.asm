; l0710.asm outback croc keeper
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 3
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0710Section",DATA
;---------------------------------------------------------------------

L0710_Contents::
  DW L0710_Load
  DW L0710_Init
  DW L0710_Check
  DW L0710_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0710_Load:
        DW ((L0710_LoadFinished - L0710_Load2))  ;size
L0710_Load2:
        call    ParseMap
        ret

L0710_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0710_Map:
INCBIN "..\\fgbeditor\\l0710_outback.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0710_Init:
        DW ((L0710_InitFinished - L0710_Init2))  ;size
L0710_Init2:
        ld      a,[bgTileMap + WATERINDEX]
				ld      [levelVars + VAR_WATER],a

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0710_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0710_Check:
        DW ((L0710_CheckFinished - L0710_Check2))  ;size
L0710_Check2:
        call    ((.animateWater-L0710_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
				swap    a
				and     %11
				ld      hl,levelVars + VAR_WATER
				add     [hl]
				ld      [bgTileMap + WATERINDEX],a
				ret

L0710_CheckFinished:
PRINTT "0710 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0710_LoadFinished - L0710_Load2)
PRINTT " / "
PRINTV (L0710_InitFinished - L0710_Init2)
PRINTT " / "
PRINTV (L0710_CheckFinished - L0710_Check2)
PRINTT "\n"

