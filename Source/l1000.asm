; l1000.asm crouton base camp landing
; Generated 01.02.1998 by mlevel
; Modified  01.02.1998 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX   EQU  79
DICEINDEX    EQU  87
HFENCE_INDEX EQU  97
VFENCE_INDEX EQU 101
GYRO_INDEX   EQU 109

VAR_HFENCE       EQU 0
VAR_VFENCE       EQU 1
VAR_LIGHT        EQU 2
VAR_DICELIGHT    EQU 3
VAR_EXPLODEDGATE EQU 4  ;used in class.asm
VAR_TALKED       EQU 5
VAR_SPEAKER      EQU 6

STATE_GATECLOSED EQU 1
STATE_WAITGYRO   EQU 2
STATE_NORMAL     EQU 3


;---------------------------------------------------------------------
SECTION "Level1000Section",ROMX
;---------------------------------------------------------------------

dialog:
l1000_needbomb_gtx:
  INCBIN "gtx\\talk\\l1000_needbomb.gtx"

l1000_freeze_gtx:
  INCBIN "gtx\\talk\\l1000_freeze.gtx"

l1000_toolate_gtx:
  INCBIN "gtx\\talk\\l1000_toolate.gtx"

l1000_follow_gtx:
  INCBIN "gtx\\talk\\l1000_follow.gtx"

L1000_Contents::
  DW L1000_Load
  DW L1000_Init
  DW L1000_Check
  DW L1000_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1000_Load:
        DW ((L1000_LoadFinished - L1000_Load2))  ;size
L1000_Load2:
        call    ParseMap
        ret

L1000_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1000_Map:
INCBIN "..\\fgbeditor\\l1000_basecamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1000_Init:
        DW ((L1000_InitFinished - L1000_Init2))  ;size
L1000_Init2:
        ld      a,[bgTileMap+HFENCE_INDEX]
        ld      [levelVars + VAR_HFENCE],a
        ld      a,[bgTileMap+VFENCE_INDEX]
        ld      [levelVars + VAR_VFENCE],a
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        ld      a,[bgTileMap+DICEINDEX]  ;tile index of first light
        ld      [levelVars+VAR_DICELIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        STDSETUPDIALOG

        xor     a
        ld      [levelVars+VAR_TALKED],a

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        xor     a
        ld      [levelVars+VAR_EXPLODEDGATE],a

        call    State0To1

        ldio    a,[mapState]
        cp      STATE_WAITGYRO
        call    nc,((.removeGate-L1000_Init2)+levelCheckRAM)
        ldio    a,[mapState]
        cp      STATE_NORMAL
        call    z,((.removeGyro-L1000_Init2)+levelCheckRAM)
        ret

.removeGate
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d24e
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d26e
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d28e
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ret

.removeGyro
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ;remove space ship
        ld      hl,$d04f
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d06f
        ld      [hl+],a
        ld      [hl+],a

        ;remove Gyro
        ld      bc,classGeneralGyro
        call    DeleteObjectsOfClass
        ret

L1000_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1000_Check:
        DW ((L1000_CheckFinished - L1000_Check2))  ;size
L1000_Check2:
        call    ((.animateFence-L1000_Check2)+levelCheckRAM)
        call    ((.animateLandingLights-L1000_Check2)+levelCheckRAM)
        call    ((.animateDiceLights-L1000_Check2)+levelCheckRAM)
        call    ((.checkDialog-L1000_Check2)+levelCheckRAM)
        call    ((.checkConfrontGyro-L1000_Check2)+levelCheckRAM)

        ldio    a,[mapState]
        cp      STATE_GATECLOSED
        jr      nz,.done

        call    ((.checkOpenGate-L1000_Check2)+levelCheckRAM)

.done
        ret

.checkConfrontGyro
        ldio    a,[mapState]
        cp      STATE_WAITGYRO ;exploded gate?
        ret     nz

        ld      hl,((.checkHeroConfront-L1000_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroConfront
        ld      c,a
        ld      [levelVars+VAR_SPEAKER],a
        call    GetFirst
        call    GetCurZone
        cp      5
        jr      z,.inConfrontZone

        xor     a
        ret

.inConfrontZone
        call    MakeIdle

        ld      de,((.afterConfrontDialog-L1000_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l1000_freeze_gtx
        call    ShowDialogAtBottom

        call    ClearDialog
        ld      de,l1000_toolate_gtx
        ld      c,GYRO_INDEX
        call    ShowDialogAtTop

        call    ClearDialog
        ld      a,15
        call    Delay

        ld      bc,classGeneralGyro
        call    DeleteObjectsOfClass

        ld      a,15
        call    Delay

        ld      a,30
        ldio    [jiggleDuration],a

        ld      a,15
        call    Delay

        ;clear ship
        ld      a,MAPBANK
        ldio    [$ff70],a

        xor     a
        ld      hl,$d04f
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d06f
        ld      [hl+],a
        ld      [hl+],a

        ld      a,15
        call    Delay

        ld      a,[levelVars+VAR_SPEAKER]
        ld      c,a
        ld      de,l1000_follow_gtx
        call    ShowDialogAtBottom

.afterConfrontDialog
        ld      bc,classGeneralGyro
        call    DeleteObjectsOfClass

        ;clear ship
        ld      a,MAPBANK
        ldio    [$ff70],a

        xor     a
        ld      hl,$d04f
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d06f
        ld      [hl+],a
        ld      [hl+],a

        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      hl,$1104
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ld      a,1
        ret

.checkDialog
        ld      a,[levelVars+VAR_TALKED]
        or      a
        ret     nz

        ldio    a,[mapState]
        cp      STATE_WAITGYRO ;exploded gate?
        ret     nc

        ld      hl,((.checkHeroInZone-L1000_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroInZone
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      4
        jr      z,.inZone

        xor     a
        ret

.inZone
        call    MakeIdle

        ld      de,((.afterDialog-L1000_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l1000_needbomb_gtx
        call    ShowDialogAtBottom

.afterDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,1
        ld      [levelVars+VAR_TALKED],a

        ld      a,1
        ret

.checkOpenGate
        ld      a,[levelVars+VAR_EXPLODEDGATE]
        or      a
        ret     z

        ld      bc,$0403
        ld      de,$1407
        ld      hl,$d24e
        call    CreateBigExplosion
        ld      hl,bigExplosionSound
        call    PlaySound

        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d24e
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d26e
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d28e
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a

        ld      a,STATE_WAITGYRO
        ldio    [mapState],a
        ret

.animateFence
        ldio    a,[updateTimer]
        rrca
        and     3
        ld      b,a
        ld      hl,bgTileMap+HFENCE_INDEX
        ld      a,[levelVars+VAR_HFENCE]
        ld      d,a
        call    ((.animateFourFrames-L1000_Check2)+levelCheckRAM)
        ld      a,[levelVars+VAR_VFENCE]
        ld      d,a
        jp      ((.animateFourFrames-L1000_Check2)+levelCheckRAM)

.animateFourFrames
        ld      c,4

.animateFourFrames_loop
        ld      a,b
        add     c
        and     3
        add     d
        ld      [hl+],a
        dec     c
        jr      nz,.animateFourFrames_loop
        ret

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
        call    ((.animateLight-L1000_Check2)+levelCheckRAM)
        call    ((.animateLight-L1000_Check2)+levelCheckRAM)
        call    ((.animateLight-L1000_Check2)+levelCheckRAM)
        call    ((.animateLight-L1000_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

.animateDiceLights
        ;animate dice lights
        ld      a,[levelVars+VAR_DICELIGHT]
        ld      b,a

        ;slow lights
        ldio    a,[updateTimer]
        swap    a
        and     %00000011
        add     b

        ld      hl,bgTileMap+DICEINDEX
        call    ((.updateTwoLights - L1000_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L1000_Check2) + levelCheckRAM)
        ret

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L1000_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret

L1000_CheckFinished:
PRINTT "1000 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1000_LoadFinished - L1000_Load2)
PRINTT " / "
PRINTV (L1000_InitFinished - L1000_Init2)
PRINTT " / "
PRINTV (L1000_CheckFinished - L1000_Check2)
PRINTT "\n"

