; l0408.asm death valley
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0408Section",DATA
;---------------------------------------------------------------------

L0408_Contents::
  DW L0408_Load
  DW L0408_Init
  DW L0408_Check
  DW L0408_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0408_Load:
        DW ((L0408_LoadFinished - L0408_Load2))  ;size
L0408_Load2:
        call    ParseMap
        ret

L0408_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0408_Map:
INCBIN "..\\fgbeditor\\l0408_deathvalley.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0408_Init:
        DW ((L0408_InitFinished - L0408_Init2))  ;size
L0408_Init2:
        ld      a,ENV_DIRT
        call    SetEnvEffect
        ret

L0408_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0408_Check:
        DW ((L0408_CheckFinished - L0408_Check2))  ;size
L0408_Check2:
        ret

L0408_CheckFinished:
PRINTT "0408 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0408_LoadFinished - L0408_Load2)
PRINTT " / "
PRINTV (L0408_InitFinished - L0408_Init2)
PRINTT " / "
PRINTV (L0408_CheckFinished - L0408_Check2)
PRINTT "\n"

