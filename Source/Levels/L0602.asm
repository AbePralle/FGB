; L0602.asm
; Generated 10.25.2000 by mlevel
; Modified  10.25.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

VAR_FIRE EQU 0
FIRE_INDEX EQU 24

;---------------------------------------------------------------------
SECTION "Level0602Section",ROMX
;---------------------------------------------------------------------

L0602_Contents::
  DW L0602_Load
  DW L0602_Init
  DW L0602_Check
  DW L0602_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0602_Load:
        DW ((L0602_LoadFinished - L0602_Load2))  ;size
L0602_Load2:
        call    ParseMap
        ret

L0602_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0602_Map:
INCBIN "Data/Levels/L0602_hillpeople.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0602_Init:
        DW ((L0602_InitFinished - L0602_Init2))  ;size
L0602_Init2:
        ;store index of first (of 4) fire frames
        ld      a,[bgTileMap + FIRE_INDEX]
        ld      [levelVars + VAR_FIRE],a
        ret

L0602_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0602_Check:
        DW ((L0602_CheckFinished - L0602_Check2))  ;size
L0602_Check2:
        call    ((.animateFire-L0602_Check2)+levelCheckRAM)
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

L0602_CheckFinished:
PRINT "0602 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0602_LoadFinished - L0602_Load2)
PRINT " / "
PRINT (L0602_InitFinished - L0602_Init2)
PRINT " / "
PRINT (L0602_CheckFinished - L0602_Check2)
PRINT "\n"

