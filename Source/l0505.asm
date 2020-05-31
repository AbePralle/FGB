; l0505.asm palace / wedding
; Generated 10.19.2000 by mlevel
; Modified  10.19.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX   EQU 71

VAR_LIGHT        EQU  0
VAR_WEDDINGSTAGE EQU 10
VAR_HERO         EQU 11

STATE_INIT          EQU 0
STATE_WEDDING       EQU 1
;STATE_AFTERWEDDING referenced in l0405 and l0505
STATE_AFTERWEDDING  EQU 2



;---------------------------------------------------------------------
SECTION "Level0505Section",DATA
;---------------------------------------------------------------------

L0505_Contents::
  DW L0505_Load
  DW L0505_Init
  DW L0505_Check
  DW L0505_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0505_Load:
        DW ((L0505_LoadFinished - L0505_Load2))  ;size
L0505_Load2:
        call    ParseMap
        ret

L0505_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0505_Map:
INCBIN "..\\fgbeditor\\l0505_palace.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0505_Init:
        DW ((L0505_InitFinished - L0505_Init2))  ;size
L0505_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        ldio    a,[mapState]
        cp      STATE_AFTERWEDDING
        jr      nc,.afterWedding

        xor     a
        ld      [levelVars+VAR_WEDDINGSTAGE],a
        ld      bc,classPansy
        ld      de,classActor
        call    ChangeClass
   
        ld      bc,classDandelionGuard
        call    ChangeClass

        ld      a,BANK(wedding_gbm)
        ld      hl,wedding_gbm
        call    InitMusic
        jr      .done

.afterWedding
        ld      bc,classPansy
        call    DeleteObjectsOfClass
        ld      bc,classCaptainFlour
        call    DeleteObjectsOfClass
        ld      bc,classLadyFlower
        call    DeleteObjectsOfClass
        ld      bc,classDandelionGuard
        call    DeleteObjectsOfClass

.done
        ret

L0505_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0505_Check:
        DW ((L0505_CheckFinished - L0505_Check2))  ;size
L0505_Check2:
        ldio    a,[mapState]
        cp      STATE_AFTERWEDDING
        jr      z,.afterWedding

        cp      STATE_INIT
        jr      nz,.wedding

        ;initial draw
        ld      a,STATE_WEDDING
        ldio    [mapState],a

        ld      a,1
        ld      [heroesIdle],a
        ;call    MakeIdle
        ret

.wedding
        ld      a,$11
        ldio    [scrollSpeed],a
        xor     a
        ld      [camera_i],a
        ld      [camera_j],a
        
        ld      de,((.endPan-L0505_Check2)+levelCheckRAM)
        call    SetDialogForward
        call    SetDialogSkip

        ld      a,220
        call    Delay

.endPan
        call    SetSpeakerToFirstHero
        ld      a,[dialogSpeakerIndex]
        ld      [levelVars+VAR_HERO],a

        ld      hl,levelVars+VAR_HERO
        xor     a
        call    LinkTransmitMemoryLocation

        ld      hl,$1103
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        call    MakeNonIdle
        ld      a,STATE_AFTERWEDDING
        ldio    [mapState],a
        ret

.afterWedding
        call    ((.animateLandingLights-L0505_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0505_Check2)+levelCheckRAM)
        call    ((.animateLight-L0505_Check2)+levelCheckRAM)
        call    ((.animateLight-L0505_Check2)+levelCheckRAM)
        call    ((.animateLight-L0505_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret


L0505_CheckFinished:
PRINTT "0505 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0505_LoadFinished - L0505_Load2)
PRINTT " / "
PRINTV (L0505_InitFinished - L0505_Init2)
PRINTT " / "
PRINTV (L0505_CheckFinished - L0505_Check2)
PRINTT "\n"

