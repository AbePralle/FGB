; L0406.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0406Section",ROMX
;---------------------------------------------------------------------

L0406_Contents::
  DW L0406_Load
  DW L0406_Init
  DW L0406_Check
  DW L0406_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0406_Load:
        DW ((L0406_LoadFinished - L0406_Load2))  ;size
L0406_Load2:
        call    ParseMap
        ret

L0406_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0406_Map:
INCBIN "Data/Levels/L0406_bios.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0406_Init:
        DW ((L0406_InitFinished - L0406_Init2))  ;size
L0406_Init2:
        ret

L0406_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0406_Check:
        DW ((L0406_CheckFinished - L0406_Check2))  ;size
L0406_Check2:
        ret

L0406_CheckFinished:
PRINTT "0406 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0406_LoadFinished - L0406_Load2)
PRINTT " / "
PRINTV (L0406_InitFinished - L0406_Init2)
PRINTT " / "
PRINTV (L0406_CheckFinished - L0406_Check2)
PRINTT "\n"

