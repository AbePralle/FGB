; l1007.asm liars heads
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 1
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level1007Section",ROMX
;---------------------------------------------------------------------

L1007_Contents::
  DW L1007_Load
  DW L1007_Init
  DW L1007_Check
  DW L1007_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1007_Load:
        DW ((L1007_LoadFinished - L1007_Load2))  ;size
L1007_Load2:
        call    ParseMap
        ret

L1007_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1007_Map:
INCBIN "Data/Levels/l1007_stoneheads.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1007_Init:
        DW ((L1007_InitFinished - L1007_Init2))  ;size
L1007_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ld      a,ENV_RAIN
        call    SetEnvEffect

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L1007_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1007_Check:
        DW ((L1007_CheckFinished - L1007_Check2))  ;size
L1007_Check2:
        call    ((.animateWater-L1007_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L1007_CheckFinished:
PRINTT "1007 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1007_LoadFinished - L1007_Load2)
PRINTT " / "
PRINTV (L1007_InitFinished - L1007_Init2)
PRINTT " / "
PRINTV (L1007_CheckFinished - L1007_Check2)
PRINTT "\n"

