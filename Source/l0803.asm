; L0803.asm genie
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 24
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0803Section",ROMX
;---------------------------------------------------------------------

L0803_Contents::
  DW L0803_Load
  DW L0803_Init
  DW L0803_Check
  DW L0803_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0803_Load:
        DW ((L0803_LoadFinished - L0803_Load2))  ;size
L0803_Load2:
        call    ParseMap
        ret

L0803_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0803_Map:
INCBIN "Data/Levels/L0803_djinn.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0803_Init:
        DW ((L0803_InitFinished - L0803_Init2))  ;size
L0803_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0803_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0803_Check:
        DW ((L0803_CheckFinished - L0803_Check2))  ;size
L0803_Check2:
        call    ((.animateWater-L0803_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0803_CheckFinished:
PRINTT "0803 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0803_LoadFinished - L0803_Load2)
PRINTT " / "
PRINTV (L0803_InitFinished - L0803_Init2)
PRINTT " / "
PRINTV (L0803_CheckFinished - L0803_Check2)
PRINTT "\n"

