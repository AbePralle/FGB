; L0700.asm
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0700Section",ROMX
;---------------------------------------------------------------------

L0700_Contents::
  DW L0700_Load
  DW L0700_Init
  DW L0700_Check
  DW L0700_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0700_Load:
        DW ((L0700_LoadFinished - L0700_Load2))  ;size
L0700_Load2:
        call    ParseMap
        ret

L0700_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0700_Map:
INCBIN "Data/Levels/L0700_ice.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0700_Init:
        DW ((L0700_InitFinished - L0700_Init2))  ;size
L0700_Init2:
        call    UseAlternatePalette
        ld      a,ENV_SNOW
        call    SetEnvEffect
        ret

L0700_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0700_Check:
        DW ((L0700_CheckFinished - L0700_Check2))  ;size
L0700_Check2:
        ret

L0700_CheckFinished:
PRINTT "0700 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0700_LoadFinished - L0700_Load2)
PRINTT " / "
PRINTV (L0700_InitFinished - L0700_Init2)
PRINTT " / "
PRINTV (L0700_CheckFinished - L0700_Check2)
PRINTT "\n"

