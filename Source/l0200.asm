; l0200.asm evil village
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;water=lava here
WATERINDEX EQU 29
FIREINDEX  EQU 38
VAR_FIRE   EQU 0
VAR_WATER  EQU 1

;---------------------------------------------------------------------
SECTION "Level0200Section",ROMX
;---------------------------------------------------------------------

L0200_Contents::
  DW L0200_Load
  DW L0200_Init
  DW L0200_Check
  DW L0200_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0200_Load:
        DW ((L0200_LoadFinished - L0200_Load2))  ;size
L0200_Load2:
        call    ParseMap
        ret

L0200_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0200_Map:
INCBIN "..\\fgbeditor\\l0200_evilvill.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0200_Init:
        DW ((L0200_InitFinished - L0200_Init2))  ;size
L0200_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ld      a,[bgTileMap + FIREINDEX]
        ld      [levelVars + VAR_FIRE],a
        ret

L0200_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0200_Check:
        DW ((L0200_CheckFinished - L0200_Check2))  ;size
L0200_Check2:
        call    ((.animateWater-L0200_Check2)+levelCheckRAM)
        call    ((.animateFire-L0200_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

.animateFire
        ldio    a,[updateTimer]
        rrca
        rrca
        and     %11
        ld      hl,levelVars + VAR_FIRE
        add     [hl]
        ld      [bgTileMap + FIREINDEX],a
        ret

L0200_CheckFinished:
PRINTT "0200 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0200_LoadFinished - L0200_Load2)
PRINTT " / "
PRINTV (L0200_InitFinished - L0200_Init2)
PRINTT " / "
PRINTV (L0200_CheckFinished - L0200_Check2)
PRINTT "\n"

