; L0312.asm sunset bee house
; Generated 08.31.2000 by mlevel
; Modified  08.31.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

HIVE_INDEX EQU 15

STATE_HIVE_DESTROYED EQU 2

;---------------------------------------------------------------------
SECTION "Level0312Section",ROMX
;---------------------------------------------------------------------

L0312_Contents::
  DW L0312_Load
  DW L0312_Init
  DW L0312_Check
  DW L0312_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0312_Load:
        DW ((L0312_LoadFinished - L0312_Load2))  ;size
L0312_Load2:
        call    ParseMap
        ret

L0312_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0312_Map:
INCBIN "Data/Levels/L0312_sunsethousedown.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0312_Init:
        DW ((L0312_InitFinished - L0312_Init2))  ;size
L0312_Init2:
        ret

L0312_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0312_Check:
        DW ((L0312_CheckFinished - L0312_Check2))  ;size
L0312_Check2:
        ld      c,15
        call    GetFirst
        or      a
        ret     nz

        ld      a,STATE_HIVE_DESTROYED
        ldio    [mapState],a
        ret

L0312_CheckFinished:
PRINT "0312 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0312_LoadFinished - L0312_Load2)
PRINT " / "
PRINT (L0312_InitFinished - L0312_Init2)
PRINT " / "
PRINT (L0312_CheckFinished - L0312_Check2)
PRINT "\n"

