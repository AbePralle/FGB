; l1006.asm crouton outpost
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"


;---------------------------------------------------------------------
SECTION "Level1006Section",DATA
;---------------------------------------------------------------------

L1006_Contents::
  DW L1006_Load
  DW L1006_Init
  DW L1006_Check
  DW L1006_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1006_Load:
        DW ((L1006_LoadFinished - L1006_Load2))  ;size
L1006_Load2:
        call    ParseMap
        ret

L1006_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1006_Map:
INCBIN "..\\fgbeditor\\l1006_outpost.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1006_Init:
        DW ((L1006_InitFinished - L1006_Init2))  ;size
L1006_Init2:
        ld      bc,ITEM_CODE1006
        call    RemoveClearanceIfTaken

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L1006_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1006_Check:
        DW ((L1006_CheckFinished - L1006_Check2))  ;size
L1006_Check2:
        ret

L1006_CheckFinished:
PRINTT "1006 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1006_LoadFinished - L1006_Load2)
PRINTT " / "
PRINTV (L1006_InitFinished - L1006_Init2)
PRINTT " / "
PRINTV (L1006_CheckFinished - L1006_Check2)
PRINTT "\n"

