; L0512.asm
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0512Section",ROMX
;---------------------------------------------------------------------

L0512_Contents::
  DW L0512_Load
  DW L0512_Init
  DW L0512_Check
  DW L0512_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0512_Load:
        DW ((L0512_LoadFinished - L0512_Load2))  ;size
L0512_Load2:
        call    ParseMap
        ret

L0512_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0512_Map:
INCBIN "Data/Levels/L0512_witch_house.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0512_Init:
        DW ((L0512_InitFinished - L0512_Init2))  ;size
L0512_Init2:
        ret

L0512_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0512_Check:
        DW ((L0512_CheckFinished - L0512_Check2))  ;size
L0512_Check2:
        ret

L0512_CheckFinished:
PRINTT "0512 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0512_LoadFinished - L0512_Load2)
PRINTT " / "
PRINTV (L0512_InitFinished - L0512_Init2)
PRINTT " / "
PRINTV (L0512_CheckFinished - L0512_Check2)
PRINTT "\n"

