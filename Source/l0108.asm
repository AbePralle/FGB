; l0108.asm forest landing
; Generated 09.04.2000 by mlevel
; Modified  09.04.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX EQU 61
VAR_LIGHT EQU 0
VAR_SIGN  EQU 1

;---------------------------------------------------------------------
SECTION "Level0108Section",ROMX
;---------------------------------------------------------------------

dialog:
l0108_sign_gtx:
  INCBIN "Data/Dialog/talk/l0108_sign.gtx"

L0108_Contents::
  DW L0108_Load
  DW L0108_Init
  DW L0108_Check
  DW L0108_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0108_Load:
        DW ((L0108_LoadFinished - L0108_Load2))  ;size
L0108_Load2:
        call    ParseMap
        ret

L0108_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0108_Map:
INCBIN "Data/Levels/l0108_forest_landing.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0108_Init:
        DW ((L0108_InitFinished - L0108_Init2))  ;size
L0108_Init2:
        STDSETUPDIALOG

        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        xor     a
        ld      [levelVars+VAR_SIGN],a
        ret

L0108_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0108_Check:
        DW ((L0108_CheckFinished - L0108_Check2))  ;size
L0108_Check2:
        call    ((.animateLandingLights-L0108_Check2)+levelCheckRAM)
        call    ((.checkSign-L0108_Check2)+levelCheckRAM)
        ret

.checkSign
        ld      a,1
        ld      hl,((.heroAtSign-L0108_Check2)+levelCheckRAM)
        call    CheckEachHero

        ld      hl,levelVars + VAR_SIGN
        cp      [hl]
        jp      z,((.afterResetSign-L0108_Check2)+levelCheckRAM)

        ld      [hl],a
        or      a
        jp      z,((.afterResetSign-L0108_Check2)+levelCheckRAM)

        ;read sign
        ld      de,((.afterSignDialog-L0108_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerFromHeroIndex
        ld      de,l0108_sign_gtx
        call    ShowDialogAtTop
.afterSignDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

.afterResetSign
        ret

.heroAtSign
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      3
        jr      z,.returnTrue

.returnFalse
        xor     a
        ret

.returnTrue
        ld      a,1
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
        call    ((.animateLight-L0108_Check2)+levelCheckRAM)
        call    ((.animateLight-L0108_Check2)+levelCheckRAM)
        call    ((.animateLight-L0108_Check2)+levelCheckRAM)
        call    ((.animateLight-L0108_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0108_CheckFinished:
PRINTT "0108 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0108_LoadFinished - L0108_Load2)
PRINTT " / "
PRINTV (L0108_InitFinished - L0108_Init2)
PRINTT " / "
PRINTV (L0108_CheckFinished - L0108_Check2)
PRINTT "\n"

