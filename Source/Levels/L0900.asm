; L0900.asm Crouton Guard Post
; Generated 01.03.1980 by mlevel
; Modified  01.03.1980 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"


;---------------------------------------------------------------------
SECTION "Level0900Section",ROMX
;---------------------------------------------------------------------

L0900_Contents::
  DW L0900_Load
  DW L0900_Init
  DW L0900_Check
  DW L0900_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0900_Load:
        DW ((L0900_LoadFinished - L0900_Load2))  ;size
L0900_Load2:
        call    ParseMap
        ret

L0900_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0900_Map:
INCBIN "Data/Levels/L0900_guardpost.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0900_Init:
        DW ((L0900_InitFinished - L0900_Init2))  ;size
L0900_Init2:
        call    UseAlternatePalette
        ld      a,ENV_SNOW
        call    SetEnvEffect

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      bc,ITEM_CODE0900
        call    RemoveClearanceIfTaken
        ret

L0900_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0900_Check:
        DW ((L0900_CheckFinished - L0900_Check2))  ;size
L0900_Check2:
        ret

L0900_CheckFinished:
PRINT "0900 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0900_LoadFinished - L0900_Load2)
PRINT " / "
PRINT (L0900_InitFinished - L0900_Init2)
PRINT " / "
PRINT (L0900_CheckFinished - L0900_Check2)
PRINT "\n"

