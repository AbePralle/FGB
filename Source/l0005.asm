; l0005.asm trakktor clearing
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level0005Section",ROMX
;---------------------------------------------------------------------

L0005_Contents::
  DW L0005_Load
  DW L0005_Init
  DW L0005_Check
  DW L0005_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0005_Load:
        DW ((L0005_LoadFinished - L0005_Load2))  ;size
L0005_Load2:
        call    ParseMap
        ret

L0005_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0005_Map:
INCBIN "Data/Levels/L0005_path.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0005_Init:
        DW ((L0005_InitFinished - L0005_Init2))  ;size
L0005_Init2:
        ld      a,ENV_RAIN
        call    SetEnvEffect


        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ld      hl,$1300
        call    SetRespawnMap
        ret

L0005_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0005_Check:
        DW ((L0005_CheckFinished - L0005_Check2))  ;size
L0005_Check2:
        ret

L0005_CheckFinished:
PRINTT "0005 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0005_LoadFinished - L0005_Load2)
PRINTT " / "
PRINTV (L0005_InitFinished - L0005_Init2)
PRINTT " / "
PRINTV (L0005_CheckFinished - L0005_Check2)
PRINTT "\n"

