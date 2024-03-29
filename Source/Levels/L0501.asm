; L0501.asm
; Generated 09.05.2000 by mlevel
; Modified  09.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0501Section",ROMX
;---------------------------------------------------------------------

L0501_Contents::
  DW L0501_Load
  DW L0501_Init
  DW L0501_Check
  DW L0501_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0501_Load:
        DW ((L0501_LoadFinished - L0501_Load2))  ;size
L0501_Load2:
        call    ParseMap
        ret

L0501_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0501_Map:
INCBIN "Data/Levels/L0501_winter.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0501_Init:
        DW ((L0501_InitFinished - L0501_Init2))  ;size
L0501_Init2:
        call    UseAlternatePalette
        ld      a,ENV_SNOW
        call    SetEnvEffect

        ld      a,BANK(frosty_gbm)
        ld      hl,frosty_gbm
        call    InitMusic
        ret

L0501_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0501_Check:
        DW ((L0501_CheckFinished - L0501_Check2))  ;size
L0501_Check2:
        ret

L0501_CheckFinished:
PRINT "0501 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0501_LoadFinished - L0501_Load2)
PRINT " / "
PRINT (L0501_InitFinished - L0501_Init2)
PRINT " / "
PRINT (L0501_CheckFinished - L0501_Check2)
PRINT "\n"

