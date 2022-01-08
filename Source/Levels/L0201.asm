; L0201.asm mist south of evil village
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 1
VAR_WATER  EQU 0

;---------------------------------------------------------------------
SECTION "Level0201Section",ROMX
;---------------------------------------------------------------------

L0201_Contents::
  DW L0201_Load
  DW L0201_Init
  DW L0201_Check
  DW L0201_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0201_Load:
        DW ((L0201_LoadFinished - L0201_Load2))  ;size
L0201_Load2:
        call    ParseMap
        ret

L0201_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0201_Map:
INCBIN "Data/Levels/L0201_mist.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0201_Init:
        DW ((L0201_InitFinished - L0201_Init2))  ;size
L0201_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ret

L0201_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0201_Check:
        DW ((L0201_CheckFinished - L0201_Check2))  ;size
L0201_Check2:
        call    ((.animateWater-L0201_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0201_CheckFinished:
PRINT "0201 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0201_LoadFinished - L0201_Load2)
PRINT " / "
PRINT (L0201_InitFinished - L0201_Init2)
PRINT " / "
PRINT (L0201_CheckFinished - L0201_Check2)
PRINT "\n"

