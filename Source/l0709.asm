; l0709.asm scardie
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 2
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0709Section",DATA
;---------------------------------------------------------------------

L0709_Contents::
  DW L0709_Load
  DW L0709_Init
  DW L0709_Check
  DW L0709_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0709_Load:
        DW ((L0709_LoadFinished - L0709_Load2))  ;size
L0709_Load2:
        call    ParseMap
        ret

L0709_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0709_Map:
INCBIN "..\\fgbeditor\\l0709_outback.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0709_Init:
        DW ((L0709_InitFinished - L0709_Init2))  ;size
L0709_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a

        ld      a,ENV_DIRT
        call    SetEnvEffect

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0709_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0709_Check:
        DW ((L0709_CheckFinished - L0709_Check2))  ;size
L0709_Check2:
        call    ((.animateWater-L0709_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0709_CheckFinished:
PRINTT "0709 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0709_LoadFinished - L0709_Load2)
PRINTT " / "
PRINTV (L0709_InitFinished - L0709_Init2)
PRINTT " / "
PRINTV (L0709_CheckFinished - L0709_Check2)
PRINTT "\n"

