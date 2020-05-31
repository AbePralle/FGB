; l0413.asm
; Generated 04.22.2001 by mlevel
; Modified  04.22.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0413Section",ROMX
;---------------------------------------------------------------------

L0413_Contents::
  DW L0413_Load
  DW L0413_Init
  DW L0413_Check
  DW L0413_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0413_Load:
        DW ((L0413_LoadFinished - L0413_Load2))  ;size
L0413_Load2:
        ret

L0413_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0413_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0413_Init:
        DW ((L0413_InitFinished - L0413_Init2))  ;size
L0413_Init2:
        ret

L0413_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0413_Check:
        DW ((L0413_CheckFinished - L0413_Check2))  ;size
L0413_Check2:
        ret

L0413_CheckFinished:
PRINTT "0413 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0413_LoadFinished - L0413_Load2)
PRINTT " / "
PRINTV (L0413_InitFinished - L0413_Init2)
PRINTT " / "
PRINTV (L0413_CheckFinished - L0413_Check2)
PRINTT "\n"

