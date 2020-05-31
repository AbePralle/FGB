; L0400.asm crouton ice post
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"


;---------------------------------------------------------------------
SECTION "Level0400Section",ROMX
;---------------------------------------------------------------------

L0400_Contents::
  DW L0400_Load
  DW L0400_Init
  DW L0400_Check
  DW L0400_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0400_Load:
        DW ((L0400_LoadFinished - L0400_Load2))  ;size
L0400_Load2:
        call    ParseMap
        ret

L0400_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0400_Map:
INCBIN "Data/Levels/L0400_ice_out.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0400_Init:
        DW ((L0400_InitFinished - L0400_Init2))  ;size
L0400_Init2:
        call    UseAlternatePalette

        ld      bc,ITEM_CODE0400
        call    RemoveClearanceIfTaken
        ret

L0400_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0400_Check:
        DW ((L0400_CheckFinished - L0400_Check2))  ;size
L0400_Check2:
        ret

L0400_CheckFinished:
PRINTT "0400 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0400_LoadFinished - L0400_Load2)
PRINTT " / "
PRINTV (L0400_InitFinished - L0400_Init2)
PRINTT " / "
PRINTV (L0400_CheckFinished - L0400_Check2)
PRINTT "\n"

