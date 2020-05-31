; L0807.asm
; Generated 11.03.2000 by mlevel
; Modified  11.03.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0807Section",ROMX
;---------------------------------------------------------------------

L0807_Contents::
  DW L0807_Load
  DW L0807_Init
  DW L0807_Check
  DW L0807_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0807_Load:
        DW ((L0807_LoadFinished - L0807_Load2))  ;size
L0807_Load2:
        call    ParseMap
        ret

L0807_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0807_Map:
INCBIN "Data/Levels/L0807_swamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0807_Init:
        DW ((L0807_InitFinished - L0807_Init2))  ;size
L0807_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0807_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0807_Check:
        DW ((L0807_CheckFinished - L0807_Check2))  ;size
L0807_Check2:
        ret

L0807_CheckFinished:
PRINTT "0807 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0807_LoadFinished - L0807_Load2)
PRINTT " / "
PRINTV (L0807_InitFinished - L0807_Init2)
PRINTT " / "
PRINTV (L0807_CheckFinished - L0807_Check2)
PRINTT "\n"

