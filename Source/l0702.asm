; l0702.asm
; Generated 10.30.2000 by mlevel
; Modified  10.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0702Section",ROMX
;---------------------------------------------------------------------

L0702_Contents::
  DW L0702_Load
  DW L0702_Init
  DW L0702_Check
  DW L0702_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0702_Load:
        DW ((L0702_LoadFinished - L0702_Load2))  ;size
L0702_Load2:
        call    ParseMap
        ret

L0702_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0702_Map:
INCBIN "..\\fgbeditor\\l0702_caverns.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0702_Init:
        DW ((L0702_InitFinished - L0702_Init2))  ;size
L0702_Init2:
        ret

L0702_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0702_Check:
        DW ((L0702_CheckFinished - L0702_Check2))  ;size
L0702_Check2:
        ret

L0702_CheckFinished:
PRINTT "0702 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0702_LoadFinished - L0702_Load2)
PRINTT " / "
PRINTV (L0702_InitFinished - L0702_Init2)
PRINTT " / "
PRINTV (L0702_CheckFinished - L0702_Check2)
PRINTT "\n"

