; l0812.asm demo warp zone
; Generated 12.01.2000 by mlevel
; Modified  12.01.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

FIREINDEX EQU 88
VAR_FIRE EQU 0

;---------------------------------------------------------------------
SECTION "Level0812Section",DATA
;---------------------------------------------------------------------

L0812_Contents::
  DW L0812_Load
  DW L0812_Init
  DW L0812_Check
  DW L0812_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0812_Load:
        DW ((L0812_LoadFinished - L0812_Load2))  ;size
L0812_Load2:
        call    ParseMap
        ret

L0812_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0812_Map:
INCBIN "..\\fgbeditor\\l0812_warp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0812_Init:
        DW ((L0812_InitFinished - L0812_Init2))  ;size
L0812_Init2:
        ld      a,[bgTileMap + FIREINDEX]
				ld      [levelVars + VAR_FIRE],a
        ret

L0812_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0812_Check:
        DW ((L0812_CheckFinished - L0812_Check2))  ;size
L0812_Check2:
        call    ((.animateFire-L0812_Check2)+levelCheckRAM)
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

L0812_CheckFinished:
PRINTT "0812 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0812_LoadFinished - L0812_Load2)
PRINTT " / "
PRINTV (L0812_InitFinished - L0812_Init2)
PRINTT " / "
PRINTV (L0812_CheckFinished - L0812_Check2)
PRINTT "\n"

