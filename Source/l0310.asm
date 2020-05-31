; L0310.asm desert landing
; Generated 11.03.2000 by mlevel
; Modified  11.03.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX EQU 59
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0310Section",ROMX
;---------------------------------------------------------------------

L0310_Contents::
  DW L0310_Load
  DW L0310_Init
  DW L0310_Check
  DW L0310_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0310_Load:
        DW ((L0310_LoadFinished - L0310_Load2))  ;size
L0310_Load2:
        call    ParseMap
        ret

L0310_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0310_Map:
INCBIN "Data/Levels/L0310_desertland.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0310_Init:
        DW ((L0310_InitFinished - L0310_Init2))  ;size
L0310_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent
        ret

L0310_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0310_Check:
        DW ((L0310_CheckFinished - L0310_Check2))  ;size
L0310_Check2:
        call    ((.animateLandingLights-L0310_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0310_Check2)+levelCheckRAM)
        call    ((.animateLight-L0310_Check2)+levelCheckRAM)
        call    ((.animateLight-L0310_Check2)+levelCheckRAM)
        call    ((.animateLight-L0310_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0310_CheckFinished:
PRINTT "0310 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0310_LoadFinished - L0310_Load2)
PRINTT " / "
PRINTV (L0310_InitFinished - L0310_Init2)
PRINTT " / "
PRINTV (L0310_CheckFinished - L0310_Check2)
PRINTT "\n"

