; L0507.asm swamp
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 1
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0507Section",ROMX
;---------------------------------------------------------------------

L0507_Contents::
  DW L0507_Load
  DW L0507_Init
  DW L0507_Check
  DW L0507_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0507_Load:
        DW ((L0507_LoadFinished - L0507_Load2))  ;size
L0507_Load2:
        call    ParseMap
        ret

L0507_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0507_Map:
INCBIN "Data/Levels/L0507_swamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0507_Init:
        DW ((L0507_InitFinished - L0507_Init2))  ;size
L0507_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0507_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0507_Check:
        DW ((L0507_CheckFinished - L0507_Check2))  ;size
L0507_Check2:
        call    ((.animateWater-L0507_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0507_CheckFinished:
PRINT "0507 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0507_LoadFinished - L0507_Load2)
PRINT " / "
PRINT (L0507_InitFinished - L0507_Init2)
PRINT " / "
PRINT (L0507_CheckFinished - L0507_Check2)
PRINT "\n"

