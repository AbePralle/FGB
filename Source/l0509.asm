; l0509.asm big desert
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0509Section",ROMX
;---------------------------------------------------------------------

L0509_Contents::
  DW L0509_Load
  DW L0509_Init
  DW L0509_Check
  DW L0509_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0509_Load:
        DW ((L0509_LoadFinished - L0509_Load2))  ;size
L0509_Load2:
        call    ParseMap
        ret

L0509_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0509_Map:
INCBIN "Data/Levels/l0509_bigdesert.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
WATERINDEX EQU 22

VAR_WATER EQU 0

L0509_Init:
        DW ((L0509_InitFinished - L0509_Init2))  ;size
L0509_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ld      a,ENV_DIRT
        call    SetEnvEffect
        ret

L0509_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0509_Check:
        DW ((L0509_CheckFinished - L0509_Check2))  ;size
L0509_Check2:
        call    ((.animateWater-L0509_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0509_CheckFinished:
PRINTT "0509 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0509_LoadFinished - L0509_Load2)
PRINTT " / "
PRINTV (L0509_InitFinished - L0509_Init2)
PRINTT " / "
PRINTV (L0509_CheckFinished - L0509_Check2)
PRINTT "\n"

