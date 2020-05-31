; l0707.asm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0707Section",ROMX
;---------------------------------------------------------------------

L0707_Contents::
  DW L0707_Load
  DW L0707_Init
  DW L0707_Check
  DW L0707_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0707_Load:
        DW ((L0707_LoadFinished - L0707_Load2))  ;size
L0707_Load2:
        call    ParseMap
        ret

L0707_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0707_Map:
INCBIN "..\\fgbeditor\\l0707_barrows.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0707_Init:
        DW ((L0707_InitFinished - L0707_Init2))  ;size
L0707_Init2:
        ld      a,ENV_RAIN
        call    SetEnvEffect
        ret

L0707_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0707_Check:
        DW ((L0707_CheckFinished - L0707_Check2))  ;size
L0707_Check2:
        ret

L0707_CheckFinished:
PRINTT "0707 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0707_LoadFinished - L0707_Load2)
PRINTT " / "
PRINTV (L0707_InitFinished - L0707_Init2)
PRINTT " / "
PRINTV (L0707_CheckFinished - L0707_Check2)
PRINTT "\n"

