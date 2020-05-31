; l0904.asm
; Generated 09.18.2000 by mlevel
; Modified  09.18.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0904Section",ROMX
;---------------------------------------------------------------------

L0904_Contents::
  DW L0904_Load
  DW L0904_Init
  DW L0904_Check
  DW L0904_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0904_Load:
        DW ((L0904_LoadFinished - L0904_Load2))  ;size
L0904_Load2:
        call    ParseMap
        ret

L0904_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0904_Map:
INCBIN "Data/Levels/l0904_canyon.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0904_Init:
        DW ((L0904_InitFinished - L0904_Init2))  ;size
L0904_Init2:
        ret

L0904_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0904_Check:
        DW ((L0904_CheckFinished - L0904_Check2))  ;size
L0904_Check2:
        ret

L0904_CheckFinished:
PRINTT "0904 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0904_LoadFinished - L0904_Load2)
PRINTT " / "
PRINTV (L0904_InitFinished - L0904_Init2)
PRINTT " / "
PRINTV (L0904_CheckFinished - L0904_Check2)
PRINTT "\n"

