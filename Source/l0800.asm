; l0800.asm ice bridge
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX1 EQU 6
WATERINDEX2 EQU 16
VAR_WATER1  EQU 0
VAR_WATER2  EQU 1

;---------------------------------------------------------------------
SECTION "Level0800Section",ROMX
;---------------------------------------------------------------------

L0800_Contents::
  DW L0800_Load
  DW L0800_Init
  DW L0800_Check
  DW L0800_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0800_Load:
        DW ((L0800_LoadFinished - L0800_Load2))  ;size
L0800_Load2:
        call    ParseMap
        ret

L0800_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0800_Map:
INCBIN "Data/Levels/l0800_ice.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0800_Init:
        DW ((L0800_InitFinished - L0800_Init2))  ;size
L0800_Init2:
        call    UseAlternatePalette
        ld      a,[bgTileMap + WATERINDEX1]
        ld      [levelVars + VAR_WATER1],a
        ld      a,[bgTileMap + WATERINDEX2]
        ld      [levelVars + VAR_WATER2],a
        ld      a,ENV_SNOW
        call    SetEnvEffect

        ld      a,BANK(frosty_gbm)
        ld      hl,frosty_gbm
        call    InitMusic
        ret

L0800_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0800_Check:
        DW ((L0800_CheckFinished - L0800_Check2))  ;size
L0800_Check2:
        call    ((.animateWater1-L0800_Check2)+levelCheckRAM)
        call    ((.animateWater2-L0800_Check2)+levelCheckRAM)
        ret

.animateWater1
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER1
        add     [hl]
        ld      [bgTileMap + WATERINDEX1],a
        ret

.animateWater2
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER2
        add     [hl]
        ld      [bgTileMap + WATERINDEX2],a
        ret

L0800_CheckFinished:
PRINTT "0800 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0800_LoadFinished - L0800_Load2)
PRINTT " / "
PRINTV (L0800_InitFinished - L0800_Init2)
PRINTT " / "
PRINTV (L0800_CheckFinished - L0800_Check2)
PRINTT "\n"

