; l0301.asm mist se of evil village
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 1
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0301Section",DATA
;---------------------------------------------------------------------

L0301_Contents::
  DW L0301_Load
  DW L0301_Init
  DW L0301_Check
  DW L0301_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0301_Load:
        DW ((L0301_LoadFinished - L0301_Load2))  ;size
L0301_Load2:
        call    ParseMap
        ret

L0301_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0301_Map:
INCBIN "..\\fgbeditor\\l0301_mist.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0301_Init:
        DW ((L0301_InitFinished - L0301_Init2))  ;size
L0301_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0301_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0301_Check:
        DW ((L0301_CheckFinished - L0301_Check2))  ;size
L0301_Check2:
        call    ((.animateWater-L0301_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0301_CheckFinished:
PRINTT "0301 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0301_LoadFinished - L0301_Load2)
PRINTT " / "
PRINTV (L0301_InitFinished - L0301_Init2)
PRINTT " / "
PRINTV (L0301_CheckFinished - L0301_Check2)
PRINTT "\n"

