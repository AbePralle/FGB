; l0104.asm Spring
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0104Section",ROMX
;---------------------------------------------------------------------

L0104_Contents::
  DW L0104_Load
  DW L0104_Init
  DW L0104_Check
  DW L0104_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0104_Load:
        DW ((L0104_LoadFinished - L0104_Load2))  ;size
L0104_Load2:
        call    ParseMap
        ret

L0104_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0104_Map:
INCBIN "Data/Levels/L0104_spring.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0104_Init:
        DW ((L0104_InitFinished - L0104_Init2))  ;size
L0104_Init2:
        call    UseAlternatePalette
        ld      a,ENV_RAIN
        call    SetEnvEffect
        ret

L0104_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0104_Check:
        DW ((L0104_CheckFinished - L0104_Check2))  ;size
L0104_Check2:
        ret

L0104_CheckFinished:
PRINTT "0104 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0104_LoadFinished - L0104_Load2)
PRINTT " / "
PRINTV (L0104_InitFinished - L0104_Init2)
PRINTT " / "
PRINTV (L0104_CheckFinished - L0104_Check2)
PRINTT "\n"

