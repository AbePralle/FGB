; l0111.asm
; Generated 10.20.2000 by mlevel
; Modified  10.20.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0111Section",ROMX
;---------------------------------------------------------------------

L0111_Contents::
  DW L0111_Load
  DW L0111_Init
  DW L0111_Check
  DW L0111_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0111_Load:
        DW ((L0111_LoadFinished - L0111_Load2))  ;size
L0111_Load2:
        call    ParseMap
        ret


L0111_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0111_Map:
INCBIN "Data/Levels/l0111_tower.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0111_Init:
        DW ((L0111_InitFinished - L0111_Init2))  ;size
L0111_Init2:
        ret

L0111_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0111_Check:
        DW ((L0111_CheckFinished - L0111_Check2))  ;size
L0111_Check2:
        ret

L0111_CheckFinished:
PRINTT "0111 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0111_LoadFinished - L0111_Load2)
PRINTT " / "
PRINTV (L0111_InitFinished - L0111_Init2)
PRINTT " / "
PRINTV (L0111_CheckFinished - L0111_Check2)
PRINTT "\n"

