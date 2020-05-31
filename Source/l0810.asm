; l0810.asm graves landing
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX EQU 40
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0810Section",DATA
;---------------------------------------------------------------------

L0810_Contents::
  DW L0810_Load
  DW L0810_Init
  DW L0810_Check
  DW L0810_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0810_Load:
        DW ((L0810_LoadFinished - L0810_Load2))  ;size
L0810_Load2:
        call    ParseMap
        ret

L0810_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0810_Map:
INCBIN "..\\fgbeditor\\l0810_graveslanding.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0810_Init:
        DW ((L0810_InitFinished - L0810_Init2))  ;size
L0810_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic

        LONGCALLNOARGS AddAppomattoxIfPresent
        ret

L0810_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0810_Check:
        DW ((L0810_CheckFinished - L0810_Check2))  ;size
L0810_Check2:
        call    ((.animateLandingLights-L0810_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0810_Check2)+levelCheckRAM)
        call    ((.animateLight-L0810_Check2)+levelCheckRAM)
        call    ((.animateLight-L0810_Check2)+levelCheckRAM)
        call    ((.animateLight-L0810_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0810_CheckFinished:
PRINTT "0810 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0810_LoadFinished - L0810_Load2)
PRINTT " / "
PRINTV (L0810_InitFinished - L0810_Init2)
PRINTT " / "
PRINTV (L0810_CheckFinished - L0810_Check2)
PRINTT "\n"

