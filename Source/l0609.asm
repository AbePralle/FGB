; l0609.asm outback farm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 4
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0609Section",DATA
;---------------------------------------------------------------------

L0609_Contents::
  DW L0609_Load
  DW L0609_Init
  DW L0609_Check
  DW L0609_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0609_Load:
        DW ((L0609_LoadFinished - L0609_Load2))  ;size
L0609_Load2:
        call    ParseMap
        ret

L0609_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0609_Map:
INCBIN "..\\fgbeditor\\l0609_outback.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0609_Init:
        DW ((L0609_InitFinished - L0609_Init2))  ;size
L0609_Init2:
        ld      a,[bgTileMap + WATERINDEX]
				ld      [levelVars + VAR_WATER],a
        ret

L0609_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0609_Check:
        DW ((L0609_CheckFinished - L0609_Check2))  ;size
L0609_Check2:
        call    ((.animateWater-L0609_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
				swap    a
				and     %11
				ld      hl,levelVars + VAR_WATER
				add     [hl]
				ld      [bgTileMap + WATERINDEX],a
				ret

L0609_CheckFinished:
PRINTT "0609 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0609_LoadFinished - L0609_Load2)
PRINTT " / "
PRINTV (L0609_InitFinished - L0609_Init2)
PRINTT " / "
PRINTV (L0609_CheckFinished - L0609_Check2)
PRINTT "\n"

