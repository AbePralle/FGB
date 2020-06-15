; L0802.asm windy passage
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0802Section",ROMX
;---------------------------------------------------------------------

L0802_Contents::
  DW L0802_Load
  DW L0802_Init
  DW L0802_Check
  DW L0802_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0802_Load:
        DW ((L0802_LoadFinished - L0802_Load2))  ;size
L0802_Load2:
        call    ParseMap
        ret

L0802_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0802_Map:
INCBIN "Data/Levels/L0802_windypass.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0802_Init:
        DW ((L0802_InitFinished - L0802_Init2))  ;size
L0802_Init2:
        call    UseAlternatePalette
        ld      a,ENV_WINDYSNOW
        call    SetEnvEffect
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0802_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0802_Check:
        DW ((L0802_CheckFinished - L0802_Check2))  ;size
L0802_Check2:
        ret

L0802_CheckFinished:
PRINTT "0802 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0802_LoadFinished - L0802_Load2)
PRINTT " / "
PRINTV (L0802_InitFinished - L0802_Init2)
PRINTT " / "
PRINTV (L0802_CheckFinished - L0802_Check2)
PRINTT "\n"

