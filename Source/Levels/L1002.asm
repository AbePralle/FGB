; L1002.asm
; Generated 01.02.1998 by mlevel
; Modified  01.02.1998 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"


;---------------------------------------------------------------------
SECTION "Level1002Section",ROMX
;---------------------------------------------------------------------

L1002_Contents::
  DW L1002_Load
  DW L1002_Init
  DW L1002_Check
  DW L1002_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1002_Load:
        DW ((L1002_LoadFinished - L1002_Load2))  ;size
L1002_Load2:
        call    ParseMap
        ret

L1002_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1002_Map:
INCBIN "Data/Levels/L1002_guardpost.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1002_Init:
        DW ((L1002_InitFinished - L1002_Init2))  ;size
L1002_Init2:
        call    UseAlternatePalette
        ld      a,ENV_SNOW
        call    SetEnvEffect
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      bc,ITEM_CODE1002
        call    RemoveClearanceIfTaken
        ret

L1002_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1002_Check:
        DW ((L1002_CheckFinished - L1002_Check2))  ;size
L1002_Check2:
        ret

L1002_CheckFinished:
PRINTT "1002 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1002_LoadFinished - L1002_Load2)
PRINTT " / "
PRINTV (L1002_InitFinished - L1002_Init2)
PRINTT " / "
PRINTV (L1002_CheckFinished - L1002_Check2)
PRINTT "\n"

