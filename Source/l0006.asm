; L0006.asm Sunset Village
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0006Section",ROMX
;---------------------------------------------------------------------

L0006_Contents::
  DW L0006_Load
  DW L0006_Init
  DW L0006_Check
  DW L0006_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0006_Load:
        DW ((L0006_LoadFinished - L0006_Load2))  ;size
L0006_Load2:
        call    ParseMap
        ret

L0006_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0006_Map:
INCBIN "Data/Levels/L0006_sunset.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0006_Init:
        DW ((L0006_InitFinished - L0006_Init2))  ;size
L0006_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ret

L0006_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0006_Check:
        DW ((L0006_CheckFinished - L0006_Check2))  ;size
L0006_Check2:
        ret

L0006_CheckFinished:
PRINTT "0006 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0006_LoadFinished - L0006_Load2)
PRINTT " / "
PRINTV (L0006_InitFinished - L0006_Init2)
PRINTT " / "
PRINTV (L0006_CheckFinished - L0006_Check2)
PRINTT "\n"

