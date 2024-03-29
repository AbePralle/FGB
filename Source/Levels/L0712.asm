; L0712.asm farm landing
; Generated 11.29.2000 by mlevel
; Modified  11.29.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

LIGHTINDEX EQU 46
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0712Section",ROMX
;---------------------------------------------------------------------

L0712_Contents::
  DW L0712_Load
  DW L0712_Init
  DW L0712_Check
  DW L0712_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0712_Load:
        DW ((L0712_LoadFinished - L0712_Load2))  ;size
L0712_Load2:
        call    ParseMap
        ret

L0712_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0712_Map:
INCBIN "Data/Levels/L0712_farmlanding.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0712_Init:
        DW ((L0712_InitFinished - L0712_Init2))  ;size
L0712_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        ld      a,BANK(cowboy_gbm)
        ld      hl,cowboy_gbm
        call    InitMusic
        ret

L0712_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0712_Check:
        DW ((L0712_CheckFinished - L0712_Check2))  ;size
L0712_Check2:
        call    ((.animateLandingLights-L0712_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0712_Check2)+levelCheckRAM)
        call    ((.animateLight-L0712_Check2)+levelCheckRAM)
        call    ((.animateLight-L0712_Check2)+levelCheckRAM)
        call    ((.animateLight-L0712_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0712_CheckFinished:
PRINT "0712 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0712_LoadFinished - L0712_Load2)
PRINT " / "
PRINT (L0712_InitFinished - L0712_Init2)
PRINT " / "
PRINT (L0712_CheckFinished - L0712_Check2)
PRINT "\n"

