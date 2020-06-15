; L0303.asm mist stone henge
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 3
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0303Section",ROMX
;---------------------------------------------------------------------

L0303_Contents::
  DW L0303_Load
  DW L0303_Init
  DW L0303_Check
  DW L0303_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0303_Load:
        DW ((L0303_LoadFinished - L0303_Load2))  ;size
L0303_Load2:
        call    ParseMap
        ret

L0303_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0303_Map:
INCBIN "Data/Levels/L0303_stone_mist.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0303_Init:
        DW ((L0303_InitFinished - L0303_Init2))  ;size
L0303_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a

        ld      a,BANK(mysterious_gbm)
        ld      hl,mysterious_gbm
        call    InitMusic
        ret

L0303_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0303_Check:
        DW ((L0303_CheckFinished - L0303_Check2))  ;size
L0303_Check2:
        call    ((.animateWater-L0303_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0303_CheckFinished:
PRINTT "0303 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0303_LoadFinished - L0303_Load2)
PRINTT " / "
PRINTV (L0303_InitFinished - L0303_Init2)
PRINTT " / "
PRINTV (L0303_CheckFinished - L0303_Check2)
PRINTT "\n"

