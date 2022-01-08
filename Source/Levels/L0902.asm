; L0902.asm Ice Plain Landing
; Generated 11.13.2000 by mlevel
; Modified  11.13.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

LIGHTINDEX EQU 70
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0902Section",ROMX
;---------------------------------------------------------------------

L0902_Contents::
  DW L0902_Load
  DW L0902_Init
  DW L0902_Check
  DW L0902_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0902_Load:
        DW ((L0902_LoadFinished - L0902_Load2))  ;size
L0902_Load2:
        call    ParseMap
        ret

L0902_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0902_Map:
INCBIN "Data/Levels/L0902_iceplainland.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0902_Init:
        DW ((L0902_InitFinished - L0902_Init2))  ;size
L0902_Init2:
        call    UseAlternatePalette
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent
        ld      a,ENV_SNOW
        call    SetEnvEffect
        ld      a,BANK(frosty_gbm)
        ld      hl,frosty_gbm
        call    InitMusic
        ret

L0902_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0902_Check:
        DW ((L0902_CheckFinished - L0902_Check2))  ;size
L0902_Check2:
        call    ((.animateLandingLights-L0902_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0902_Check2)+levelCheckRAM)
        call    ((.animateLight-L0902_Check2)+levelCheckRAM)
        call    ((.animateLight-L0902_Check2)+levelCheckRAM)
        call    ((.animateLight-L0902_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0902_CheckFinished:
PRINT "0902 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0902_LoadFinished - L0902_Load2)
PRINT " / "
PRINT (L0902_InitFinished - L0902_Init2)
PRINT " / "
PRINT (L0902_CheckFinished - L0902_Check2)
PRINT "\n"

