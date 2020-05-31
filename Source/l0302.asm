; L0302.asm mist landing
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 1
LIGHTINDEX EQU 61
VAR_WATER  EQU 0
VAR_LIGHT  EQU 1

;---------------------------------------------------------------------
SECTION "Level0302Section",ROMX
;---------------------------------------------------------------------

L0302_Contents::
  DW L0302_Load
  DW L0302_Init
  DW L0302_Check
  DW L0302_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0302_Load:
        DW ((L0302_LoadFinished - L0302_Load2))  ;size
L0302_Load2:
        call    ParseMap
        ret

L0302_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0302_Map:
INCBIN "Data/Levels/L0302_mistland.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0302_Init:
        DW ((L0302_InitFinished - L0302_Init2))  ;size
L0302_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        ld      a,BANK(mysterious_gbm)
        ld      hl,mysterious_gbm
        call    InitMusic
        ret

L0302_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0302_Check:
        DW ((L0302_CheckFinished - L0302_Check2))  ;size
L0302_Check2:
        call    ((.animateWater-L0302_Check2)+levelCheckRAM)
        call    ((.animateLandingLights-L0302_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0302_Check2)+levelCheckRAM)
        call    ((.animateLight-L0302_Check2)+levelCheckRAM)
        call    ((.animateLight-L0302_Check2)+levelCheckRAM)
        call    ((.animateLight-L0302_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0302_CheckFinished:
PRINTT "0302 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0302_LoadFinished - L0302_Load2)
PRINTT " / "
PRINTV (L0302_InitFinished - L0302_Init2)
PRINTT " / "
PRINTV (L0302_CheckFinished - L0302_Check2)
PRINTT "\n"

