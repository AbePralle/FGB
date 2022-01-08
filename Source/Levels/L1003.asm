; L1003.asm beach
; Generated 01.03.1980 by mlevel
; Modified  01.03.1980 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX EQU 42
VAR_WATER  EQU 0
LIGHTINDEX EQU 64
VAR_LIGHT EQU 1

;---------------------------------------------------------------------
SECTION "Level1003Section",ROMX
;---------------------------------------------------------------------

L1003_Contents::
  DW L1003_Load
  DW L1003_Init
  DW L1003_Check
  DW L1003_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1003_Load:
        DW ((L1003_LoadFinished - L1003_Load2))  ;size
L1003_Load2:
        call    ParseMap
        ret

L1003_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1003_Map:
INCBIN "Data/Levels/L1003_beach.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1003_Init:
        DW ((L1003_InitFinished - L1003_Init2))  ;size
L1003_Init2:
        call    UseAlternatePalette
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent
        ret

L1003_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1003_Check:
        DW ((L1003_CheckFinished - L1003_Check2))  ;size
L1003_Check2:
        call    ((.animateWater-L1003_Check2)+levelCheckRAM)
        call    ((.animateLandingLights-L1003_Check2)+levelCheckRAM)
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

.animateLandingLights
        ldio    a,[updateTimer]
        rrca
        rrca
        and     %11
        ld      b,a

        ld      a,[levelVars+VAR_LIGHT]
        ld      c,a
        ld      d,0

        ld      hl,bgTileMap+LIGHTINDEX
        call    ((.animateLight-L1003_Check2)+levelCheckRAM)
        call    ((.animateLight-L1003_Check2)+levelCheckRAM)
        call    ((.animateLight-L1003_Check2)+levelCheckRAM)
        call    ((.animateLight-L1003_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L1003_CheckFinished:
PRINT "1003 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1003_LoadFinished - L1003_Load2)
PRINT " / "
PRINT (L1003_InitFinished - L1003_Init2)
PRINT " / "
PRINT (L1003_CheckFinished - L1003_Check2)
PRINT "\n"

