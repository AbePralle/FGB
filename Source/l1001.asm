; l1001.asm
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1001Section",ROMX
;---------------------------------------------------------------------

L1001_Contents::
  DW L1001_Load
  DW L1001_Init
  DW L1001_Check
  DW L1001_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1001_Load:
        DW ((L1001_LoadFinished - L1001_Load2))  ;size
L1001_Load2:
        call    ParseMap
        ret

L1001_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1001_Map:
INCBIN "..\\fgbeditor\\l1001_iceplain.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1001_Init:
        DW ((L1001_InitFinished - L1001_Init2))  ;size
L1001_Init2:
        call    UseAlternatePalette
        ld      a,ENV_SNOW
        call    SetEnvEffect
        ld      a,BANK(frosty_gbm)
        ld      hl,frosty_gbm
        call    InitMusic
        ret

L1001_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1001_Check:
        DW ((L1001_CheckFinished - L1001_Check2))  ;size
L1001_Check2:
        ret

L1001_CheckFinished:
PRINTT "1001 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1001_LoadFinished - L1001_Load2)
PRINTT " / "
PRINTV (L1001_InitFinished - L1001_Init2)
PRINTT " / "
PRINTV (L1001_CheckFinished - L1001_Check2)
PRINTT "\n"

