; l0607.asm swampy
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0607Section",ROMX
;---------------------------------------------------------------------

L0607_Contents::
  DW L0607_Load
  DW L0607_Init
  DW L0607_Check
  DW L0607_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0607_Load:
        DW ((L0607_LoadFinished - L0607_Load2))  ;size
L0607_Load2:
        call    ParseMap
        ret

L0607_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0607_Map:
INCBIN "..\\fgbeditor\\l0607_swampthang.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0607_Init:
        DW ((L0607_InitFinished - L0607_Init2))  ;size
L0607_Init2:
        ld      a,ENV_RAIN
        call    SetEnvEffect
        ret

L0607_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0607_Check:
        DW ((L0607_CheckFinished - L0607_Check2))  ;size
L0607_Check2:
        ret

L0607_CheckFinished:
PRINTT "0607 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0607_LoadFinished - L0607_Load2)
PRINTT " / "
PRINTV (L0607_InitFinished - L0607_Init2)
PRINTT " / "
PRINTV (L0607_CheckFinished - L0607_Check2)
PRINTT "\n"

