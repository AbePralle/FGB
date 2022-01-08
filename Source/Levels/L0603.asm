; L0603.asm
; Generated 10.23.2000 by mlevel
; Modified  10.23.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

VAR_FIRE EQU 0
FIRE_INDEX EQU 19

;---------------------------------------------------------------------
SECTION "Level0603Section",ROMX
;---------------------------------------------------------------------

L0603_Contents::
  DW L0603_Load
  DW L0603_Init
  DW L0603_Check
  DW L0603_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0603_Load:
        DW ((L0603_LoadFinished - L0603_Load2))  ;size
L0603_Load2:
        call    ParseMap
        ret

L0603_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0603_Map:
INCBIN "Data/Levels/L0603_hillpeople.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0603_Init:
        DW ((L0603_InitFinished - L0603_Init2))  ;size
L0603_Init2:
        ;store index of first (of 4) fire frames
        ld      a,[bgTileMap + FIRE_INDEX]
        ld      [levelVars + VAR_FIRE],a
        ret

L0603_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0603_Check:
        DW ((L0603_CheckFinished - L0603_Check2))  ;size
L0603_Check2:
        call    ((.animateFire-L0603_Check2)+levelCheckRAM)
        ret

.animateFire
        ldio    a,[updateTimer]
        rrca
        rrca
        and     %11
        ld      hl,levelVars + VAR_FIRE
        add     [hl]
        ld      [bgTileMap + FIRE_INDEX],a
        ret

L0603_CheckFinished:
PRINT "0603 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0603_LoadFinished - L0603_Load2)
PRINT " / "
PRINT (L0603_InitFinished - L0603_Init2)
PRINT " / "
PRINT (L0603_CheckFinished - L0603_Check2)
PRINT "\n"

