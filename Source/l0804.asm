; L0804.asm grand canyon
; Generated 09.18.2000 by mlevel
; Modified  09.18.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 1
VAR_WATER  EQU 0


;---------------------------------------------------------------------
SECTION "Level0804Section",ROMX
;---------------------------------------------------------------------

L0804_Contents::
  DW L0804_Load
  DW L0804_Init
  DW L0804_Check
  DW L0804_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0804_Load:
        DW ((L0804_LoadFinished - L0804_Load2))  ;size
L0804_Load2:
        call    ParseMap
        ret

L0804_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0804_Map:
INCBIN "Data/Levels/L0804_canyon.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0804_Init:
        DW ((L0804_InitFinished - L0804_Init2))  ;size
L0804_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0804_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0804_Check:
        DW ((L0804_CheckFinished - L0804_Check2))  ;size
L0804_Check2:
        call    ((.animateWater-L0804_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0804_CheckFinished:
PRINTT "0804 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0804_LoadFinished - L0804_Load2)
PRINTT " / "
PRINTV (L0804_InitFinished - L0804_Init2)
PRINTT " / "
PRINTV (L0804_CheckFinished - L0804_Check2)
PRINTT "\n"

