; L0600.asm
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

LIGHTINDEX EQU 57
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0600Section",ROMX
;---------------------------------------------------------------------

L0600_Contents::
  DW L0600_Load
  DW L0600_Init
  DW L0600_Check
  DW L0600_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0600_Load:
        DW ((L0600_LoadFinished - L0600_Load2))  ;size
L0600_Load2:
        call    ParseMap
        ret

L0600_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0600_Map:
INCBIN "Data/Levels/L0600_ice.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0600_Init:
        DW ((L0600_InitFinished - L0600_Init2))  ;size
L0600_Init2:
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

L0600_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0600_Check:
        DW ((L0600_CheckFinished - L0600_Check2))  ;size
L0600_Check2:
        call    ((.animateLandingLights-L0600_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0600_Check2)+levelCheckRAM)
        call    ((.animateLight-L0600_Check2)+levelCheckRAM)
        call    ((.animateLight-L0600_Check2)+levelCheckRAM)
        call    ((.animateLight-L0600_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0600_CheckFinished:
PRINTT "0600 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0600_LoadFinished - L0600_Load2)
PRINTT " / "
PRINTV (L0600_InitFinished - L0600_Init2)
PRINTT " / "
PRINTV (L0600_CheckFinished - L0600_Check2)
PRINTT "\n"

