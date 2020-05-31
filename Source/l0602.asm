; l0602.asm
; Generated 10.25.2000 by mlevel
; Modified  10.25.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

VAR_FIRE EQU 0
FIRE_INDEX EQU 24

;---------------------------------------------------------------------
SECTION "Level0602Section",DATA
;---------------------------------------------------------------------

L0602_Contents::
  DW L0602_Load
  DW L0602_Init
  DW L0602_Check
  DW L0602_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0602_Load:
        DW ((L0602_LoadFinished - L0602_Load2))  ;size
L0602_Load2:
        call    ParseMap
        ret

L0602_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0602_Map:
INCBIN "..\\fgbeditor\\l0602_hillpeople.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0602_Init:
        DW ((L0602_InitFinished - L0602_Init2))  ;size
L0602_Init2:
        ;store index of first (of 4) fire frames
        ld      a,[bgTileMap + FIRE_INDEX]
				ld      [levelVars + VAR_FIRE],a
        ret

L0602_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0602_Check:
        DW ((L0602_CheckFinished - L0602_Check2))  ;size
L0602_Check2:
        call    ((.animateFire-L0602_Check2)+levelCheckRAM)
				ret

.animateFire
				ldio    a,[updateTimer]
				rrca
				rrca
				and     %11
				ld      hl,levelVars + VAR_FIRE
				add     [hl]
				ld      [bgTileMap + FIRE_INDEX],a
        ret

L0602_CheckFinished:
PRINTT "0602 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0602_LoadFinished - L0602_Load2)
PRINTT " / "
PRINTV (L0602_InitFinished - L0602_Init2)
PRINTT " / "
PRINTV (L0602_CheckFinished - L0602_Check2)
PRINTT "\n"

