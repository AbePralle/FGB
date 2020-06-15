; L0112.asm hive entrance
; Generated 08.31.2000 by mlevel
; Modified  08.31.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0112Section",ROMX
;---------------------------------------------------------------------

L0112_Contents::
  DW L0112_Load
  DW L0112_Init
  DW L0112_Check
  DW L0112_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0112_Load:
        DW ((L0112_LoadFinished - L0112_Load2))  ;size
L0112_Load2:
        call    ParseMap
        ret

L0112_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0112_Map:
INCBIN "Data/Levels/L0112_hive_entrance.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0112_Init:
        DW ((L0112_InitFinished - L0112_Init2))  ;size
L0112_Init2:
        ld      a,BANK(beehive_gbm)
        ld      hl,beehive_gbm
        call    InitMusic
        ret

L0112_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0112_Check:
        DW ((L0112_CheckFinished - L0112_Check2))  ;size
L0112_Check2:
        ret

L0112_CheckFinished:
PRINTT "0112 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0112_LoadFinished - L0112_Load2)
PRINTT " / "
PRINTV (L0112_InitFinished - L0112_Init2)
PRINTT " / "
PRINTV (L0112_CheckFinished - L0112_Check2)
PRINTT "\n"

