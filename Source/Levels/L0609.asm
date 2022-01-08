; L0609.asm outback farm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 4
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0609Section",ROMX
;---------------------------------------------------------------------

L0609_Contents::
  DW L0609_Load
  DW L0609_Init
  DW L0609_Check
  DW L0609_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0609_Load:
        DW ((L0609_LoadFinished - L0609_Load2))  ;size
L0609_Load2:
        call    ParseMap
        ret

L0609_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0609_Map:
INCBIN "Data/Levels/L0609_outback.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0609_Init:
        DW ((L0609_InitFinished - L0609_Init2))  ;size
L0609_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0609_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0609_Check:
        DW ((L0609_CheckFinished - L0609_Check2))  ;size
L0609_Check2:
        call    ((.animateWater-L0609_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0609_CheckFinished:
PRINT "0609 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0609_LoadFinished - L0609_Load2)
PRINT " / "
PRINT (L0609_InitFinished - L0609_Init2)
PRINT " / "
PRINT (L0609_CheckFinished - L0609_Check2)
PRINT "\n"

