; L0307.asm crouton outpost: desolation
; Generated 11.07.2000 by mlevel
; Modified  11.07.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"


;---------------------------------------------------------------------
SECTION "Level0307Section",ROMX
;---------------------------------------------------------------------

L0307_Contents::
  DW L0307_Load
  DW L0307_Init
  DW L0307_Check
  DW L0307_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0307_Load:
        DW ((L0307_LoadFinished - L0307_Load2))  ;size
L0307_Load2:
        call    ParseMap
        ret

L0307_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0307_Map:
INCBIN "Data/Levels/L0307_outpost.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0307_Init:
        DW ((L0307_InitFinished - L0307_Init2))  ;size
L0307_Init2:
        ld      a,ENV_DIRT
        call    SetEnvEffect

        ld      bc,ITEM_CODE0307
        call    RemoveClearanceIfTaken
        ret

L0307_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0307_Check:
        DW ((L0307_CheckFinished - L0307_Check2))  ;size
L0307_Check2:
        ret

L0307_CheckFinished:
PRINTT "0307 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0307_LoadFinished - L0307_Load2)
PRINTT " / "
PRINTV (L0307_InitFinished - L0307_Init2)
PRINTT " / "
PRINTV (L0307_CheckFinished - L0307_Check2)
PRINTT "\n"

