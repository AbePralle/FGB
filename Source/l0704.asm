; l0704.asm Canyon Landing
; Generated 09.18.2000 by mlevel
; Modified  09.18.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX EQU 65

VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0704Section",DATA
;---------------------------------------------------------------------

L0704_Contents::
  DW L0704_Load
  DW L0704_Init
  DW L0704_Check
  DW L0704_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0704_Load:
        DW ((L0704_LoadFinished - L0704_Load2))  ;size
L0704_Load2:
        call    ParseMap
        ret

L0704_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0704_Map:
INCBIN "..\\fgbeditor\\l0704_canyon.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0704_Init:
        DW ((L0704_InitFinished - L0704_Init2))  ;size
L0704_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        ;ld      a,BANK(main_in_game_gbm)
        ;ld      hl,main_in_game_gbm
        ;call    InitMusic
        ret

L0704_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0704_Check:
        DW ((L0704_CheckFinished - L0704_Check2))  ;size
L0704_Check2:
        call    ((.animateLandingLights-L0704_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0704_Check2)+levelCheckRAM)
        call    ((.animateLight-L0704_Check2)+levelCheckRAM)
        call    ((.animateLight-L0704_Check2)+levelCheckRAM)
        call    ((.animateLight-L0704_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0704_CheckFinished:
PRINTT "0704 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0704_LoadFinished - L0704_Load2)
PRINTT " / "
PRINTV (L0704_InitFinished - L0704_Init2)
PRINTT " / "
PRINTV (L0704_CheckFinished - L0704_Check2)
PRINTT "\n"

