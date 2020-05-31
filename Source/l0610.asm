; L0610.asm outback
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 2
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0610Section",ROMX
;---------------------------------------------------------------------

L0610_Contents::
  DW L0610_Load
  DW L0610_Init
  DW L0610_Check
  DW L0610_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0610_Load:
        DW ((L0610_LoadFinished - L0610_Load2))  ;size
L0610_Load2:
        call    ParseMap
        ret

L0610_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0610_Map:
INCBIN "Data/Levels/L0610_outback.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0610_Init:
        DW ((L0610_InitFinished - L0610_Init2))  ;size
L0610_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0610_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0610_Check:
        DW ((L0610_CheckFinished - L0610_Check2))  ;size
L0610_Check2:
        call    ((.animateWater-L0610_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0610_CheckFinished:
PRINTT "0610 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0610_LoadFinished - L0610_Load2)
PRINTT " / "
PRINTV (L0610_InitFinished - L0610_Init2)
PRINTT " / "
PRINTV (L0610_CheckFinished - L0610_Check2)
PRINTT "\n"

