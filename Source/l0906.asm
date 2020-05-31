; l0906.asm
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0906Section",DATA
;---------------------------------------------------------------------

L0906_Contents::
  DW L0906_Load
  DW L0906_Init
  DW L0906_Check
  DW L0906_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0906_Load:
        DW ((L0906_LoadFinished - L0906_Load2))  ;size
L0906_Load2:
        call    ParseMap
        ret

L0906_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0906_Map:
INCBIN "..\\fgbeditor\\l0906_stone_wisp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0906_Init:
        DW ((L0906_InitFinished - L0906_Init2))  ;size
L0906_Init2:
        ld      a,BANK(mysterious_gbm)
        ld      hl,mysterious_gbm
        call    InitMusic
        ret

L0906_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0906_Check:
        DW ((L0906_CheckFinished - L0906_Check2))  ;size
L0906_Check2:
        ret

L0906_CheckFinished:
PRINTT "0906 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0906_LoadFinished - L0906_Load2)
PRINTT " / "
PRINTV (L0906_InitFinished - L0906_Init2)
PRINTT " / "
PRINTV (L0906_CheckFinished - L0906_Check2)
PRINTT "\n"

