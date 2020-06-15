; L1008.asm east graves
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 1
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level1008Section",ROMX
;---------------------------------------------------------------------

L1008_Contents::
  DW L1008_Load
  DW L1008_Init
  DW L1008_Check
  DW L1008_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1008_Load:
        DW ((L1008_LoadFinished - L1008_Load2))  ;size
L1008_Load2:
        call    ParseMap
        ret

L1008_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1008_Map:
INCBIN "Data/Levels/L1008_graves.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1008_Init:
        DW ((L1008_InitFinished - L1008_Init2))  ;size
L1008_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic
        ret

L1008_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1008_Check:
        DW ((L1008_CheckFinished - L1008_Check2))  ;size
L1008_Check2:
        call    ((.animateWater-L1008_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L1008_CheckFinished:
PRINTT "1008 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1008_LoadFinished - L1008_Load2)
PRINTT " / "
PRINTV (L1008_InitFinished - L1008_Init2)
PRINTT " / "
PRINTV (L1008_CheckFinished - L1008_Check2)
PRINTT "\n"

