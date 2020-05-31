; l0308.asm desert bridge
; Generated 11.07.2000 by mlevel
; Modified  11.07.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0308Section",ROMX
;---------------------------------------------------------------------

L0308_Contents::
  DW L0308_Load
  DW L0308_Init
  DW L0308_Check
  DW L0308_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0308_Load:
        DW ((L0308_LoadFinished - L0308_Load2))  ;size
L0308_Load2:
        call    ParseMap
        ret

L0308_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0308_Map:
INCBIN "Data/Levels/l0308_drylake.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0308_Init:
        DW ((L0308_InitFinished - L0308_Init2))  ;size
L0308_Init2:
        ld      a,ENV_DIRT
        call    SetEnvEffect
        ret

L0308_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0308_Check:
        DW ((L0308_CheckFinished - L0308_Check2))  ;size
L0308_Check2:
        ret

L0308_CheckFinished:
PRINTT "0308 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0308_LoadFinished - L0308_Load2)
PRINTT " / "
PRINTV (L0308_InitFinished - L0308_Init2)
PRINTT " / "
PRINTV (L0308_CheckFinished - L0308_Check2)
PRINTT "\n"

