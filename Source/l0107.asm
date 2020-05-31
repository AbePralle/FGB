;level0107.asm first landing
;Abe Pralle 3.4.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/gfx.inc"

GATE_INDEX EQU 10
LIGHTINDEX EQU 48
PURPLE_INDEX EQU 55
BLUE_INDEX   EQU 56
YELLOW_INDEX EQU 57
BA_INDEX     EQU 58
BS_INDEX     EQU 59
LASER_INDEX  EQU 60

VAR_LIGHT         EQU 0
VAR_SPEAKING_HERO EQU 1

STATE_INITIALUPDATE    EQU 1
STATE_MISSION          EQU 2
STATE_WAITPANSIES      EQU 3
STATE_WAITGATE         EQU 4
STATE_WAITRETURN       EQU 5

;referenced in l1401 lz_brokenwall_bg
STATE_NORMAL           EQU 6

EXPORT bigLaserSound
EXPORT disappearSound
EXPORT closeGateSound


;---------------------------------------------------------------------
SECTION "LevelsSection1",DATA,BANK[MAP0ROM]
;---------------------------------------------------------------------

L0107_Contents::
  DW L0107_Load
  DW L0107_Init
  DW L0107_Check
  DW L0107_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0107_Load:
        DW ((L0107_LoadFinished - L0107_Load)-2)  ;size
L0107_Load2:
        call    ParseMap

        ;ld      a,BANK(arrows_bin)
        ;ld      hl,arrows_bin
        ;ld      c,5
        ;ld      de,$8300
        ;call    LoadSprites
        ret

L0107_LoadFinished:


L0107_Map:
INCBIN "..\\fgbeditor\\L0107_landing.lvl"

arrows_bin:   INCBIN "arrows0-4.bin"

dialog:
hero_checkgate_gtx:
  INCBIN "gtx\\landing\\hero_checkgate.gtx"

guard_dontcomecloser_gtx:
  INCBIN "gtx\\landing\\guard_dontcomecloser.gtx"

hero_whoareyou_gtx:
  INCBIN "gtx\\landing\\hero_whoareyou.gtx"

guard_pansies_gtx:
  INCBIN "gtx\\landing\\guard_pansies.gtx"

hero_move_gtx:
  INCBIN "gtx\\landing\\hero_move.gtx"

guard_notpossible_gtx:
  INCBIN "gtx\\landing\\guard_notpossible.gtx"

hero_whatever_gtx:
  INCBIN "gtx\\landing\\hero_whatever.gtx"

guard_really_gtx:
  INCBIN "gtx\\landing\\guard_really.gtx"

bs_absolutely_gtx:
  INCBIN "gtx\\landing\\bs_absolutely.gtx"

guard_yeah_gtx:
  INCBIN "gtx\\landing\\guard_yeah.gtx"

hero_closedgate_gtx:
  INCBIN "gtx\\landing\\hero_closedgate.gtx"

hero_report_gtx:
  INCBIN "gtx\\landing\\hero_report.gtx"

bs_tookkey_gtx:
  INCBIN "gtx\\landing\\bs_tookkey.gtx"

ba_whataboutspare_gtx:
  INCBIN "gtx\\landing\\ba_whataboutspare.gtx"

bs_wasspare_gtx:
  INCBIN "gtx\\landing\\bs_wasspare.gtx"

ba_guns_gtx:
  INCBIN "gtx\\landing\\ba_guns.gtx"

bs_finelotofgood_gtx:
  INCBIN "gtx\\landing\\bs_finelotofgood.gtx"

bs_cool_gtx:
  INCBIN "gtx\\landing\\bs_cool.gtx"

L0107_Init:
        DW ((L0107_InitFinished - L0107_Init)-2)  ;size
L0107_Init2:
;ld a,STATE_NORMAL
;ldio [mapState],a
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent

        ld      a,BANK(dialog)
        ld      [dialogBank],a

        call    SetPressBDialog

        ;ld      a,ENV_WINDYSNOW
        ;call    SetEnvEffect

.ready
        ;make pansies inactive?
        ldio    a,[mapState]
        cp      STATE_WAITGATE
        jr      nc,.afterInactiveCheck

        ld      bc,classPansy
        ld      de,classDoNothing
        call    ChangeClass

.afterInactiveCheck
        ldio    a,[mapState]
        cp      STATE_NORMAL
        jr      z,.removeTrees

.close
        call    (.closeGate +  (levelCheckRAM-L0107_Init2))
        jr      .afterClose

.removeTrees
        ;clear the bushes the appomattox shot out & the pansies
        ld      a,MAPBANK
        ld      [$ff70],a
        xor     a
        ld      hl,$d109
        ld      [hl],a
        ld      hl,$d149
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d189
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d209
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d249
        ld      [hl],a
        ld      hl,$d24a
        ld      [hl],a
        ld      hl,$d28a
        ld      [hl],a

.afterClose
        ldio    a,[mapState]
        cp      STATE_WAITRETURN
        jr      c,.afterDeletePansies

        ld      bc,classPansy
        call    DeleteObjectsOfClass

.afterDeletePansies
        ;ldio    a,[mapState]
        ;cp      3
        ;jr      nz,.afterSetupArrow

        ;ld      a,128
        ;ld      [metaSprite_x],a
        ;ld      a,120
        ;ld      [metaSprite_y],a
        ;ld      bc,$0202            ;2x2
        ;ld      de,$3105
        ;ld      hl,(arrowInfo + (levelCheckRAM-L0107_Check2))
        ;call    CreateMetaSprite
        ;ld      a,45  
        ;ldio    [mapState+1],a

;.afterSetupArrow
        ret

.closeGate
        ld      a,MAPBANK
        ld      [$ff70],a
        ld      hl,$d049
        ld      a,GATE_INDEX
        ld      [hl+],a
        inc     a
        ld      [hl],a
        ld      hl,$d089
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl],a
        ret
L0107_InitFinished:


L0107_Check:
        DW ((L0107_CheckFinished - L0107_Check) - 2)  ;size
L0107_Check2:
L0107_CheckOffset EQU (levelCheckADDR - L0107_Check2)
        call    ((.animateLandingLights-L0107_Check2)+levelCheckRAM)
        VECTORTOSTATE ((.stateTable-L0107_Check2)+levelCheckRAM)

.stateTable
        DW ((.state_initialUpdate-L0107_Check2)+levelCheckRAM)
        DW ((.state_initialUpdate-L0107_Check2)+levelCheckRAM)
        DW ((.state_mission-L0107_Check2)+levelCheckRAM)
        DW ((.state_waitPansies-L0107_Check2)+levelCheckRAM)
        DW ((.state_waitGate-L0107_Check2)+levelCheckRAM)
        DW ((.state_waitReturn-L0107_Check2)+levelCheckRAM)
        DW ((.state_normal-L0107_Check2)+levelCheckRAM)

.state_initialUpdate
        ld      a,STATE_MISSION
        ldio    [mapState],a
        ret

.state_mission
        ld      a,5
        call    Delay

        call    SetSpeakerToFirstHero
        ld      de,((.afterStateMissionDialog-L0107_Check2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,hero_checkgate_gtx
        call    ShowDialogAtBottom
.afterStateMissionDialog
        call    ClearDialogSkipForward
        call    ClearDialog
        call    MakeNonIdle
        ld      a,STATE_WAITPANSIES
        ldio    [mapState],a
        ret

.state_waitPansies
        ld      a,1   ;skip second if first true
        ld      hl,((.checkSeePansies-L0107_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkSeePansies
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      5
        jr      z,.seesPansies

        xor     a    ;return false
        ret

.seesPansies
        ld      a,c
        ld      [levelVars+VAR_SPEAKING_HERO],a

        ld      a,STATE_WAITGATE
        ldio    [mapState],a

        ;to get joystick right
        ld      de,((.afterChallengeDialog-L0107_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,[levelVars+VAR_SPEAKING_HERO]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ld      c,YELLOW_INDEX
        ld      de,guard_dontcomecloser_gtx
        call    ShowDialogAtTop

        ld      a,[levelVars+VAR_SPEAKING_HERO]
        ld      c,a
        ld      de,hero_whoareyou_gtx
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom

        ld      c,YELLOW_INDEX
        ld      de,guard_pansies_gtx
        call    ShowDialogAtTop

        ld      a,[levelVars+VAR_SPEAKING_HERO]
        ld      c,a
        ld      de,hero_move_gtx
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom

        ld      c,YELLOW_INDEX
        ld      de,guard_notpossible_gtx
        call    ShowDialogAtTop

        ld      a,[levelVars+VAR_SPEAKING_HERO]
        ld      c,a
        ld      de,hero_whatever_gtx
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom
.afterChallengeDialog
        call    ClearDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,[levelVars+VAR_SPEAKING_HERO]
        ld      c,a
        ld      a,HERO_BS_FLAG
        call    ClassIndexIsHeroType
        or      a
        jr      z,.afterBS

        ld      de,((.afterChallengeBSDialog-L0107_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      c,PURPLE_INDEX
        ld      de,guard_really_gtx
        call    ShowDialogAtTop

        ld      a,[levelVars+VAR_SPEAKING_HERO]
        ld      c,a
        ld      de,bs_absolutely_gtx
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom

        ld      c,PURPLE_INDEX
        ld      de,guard_yeah_gtx
        call    ShowDialogAtTop

.afterChallengeBSDialog
        ;set the pansies against each other
        ld      a,FOF_ENEMY
        ld      b,GROUP_MONSTERC
        ld      c,GROUP_MONSTERC
        call    SetFOF

        ;randomize their fire delays so they won't all shoot at once
        ld      a,YELLOW_INDEX
        call    (.randomizeAttackDelay - L0107_Check2) + levelCheckRAM
        ld      a,BLUE_INDEX
        call    (.randomizeAttackDelay - L0107_Check2) + levelCheckRAM
        ld      a,PURPLE_INDEX
        call    (.randomizeAttackDelay - L0107_Check2) + levelCheckRAM

.afterBS
        call    ClearDialog
        call    ClearDialogSkipForward
        ld      bc,classDoNothing ;pansies become active
        ld      de,classPansy
        call    ChangeClass
        call    MakeNonIdle

        ld      a,1    ;return true
        ret

.state_waitGate
        ld      a,1   ;skip second if first true
        ld      hl,((.checkSeeGate-L0107_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkSeeGate
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      8
        jr      z,.seesGate

        xor     a    ;return false
        ret

.seesGate
        call    MakeIdle

        ld      de,((.afterGateDialog-L0107_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      de,hero_closedgate_gtx
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom
.afterGateDialog
        call    ClearDialog
        call    ClearDialogSkipForward

        call    MakeNonIdle

        ld      a,STATE_WAITRETURN
        ldio    [mapState],a
        ret

.state_waitReturn
        ld      a,1   ;skip second if first true
        ld      hl,((.checkZone8Occupied-L0107_Check2)+levelCheckRAM)
        call    CheckEachHero
        or      a
        ret     nz     ;not clear of zone 8

        ld      a,1   ;skip second if first true
        ld      hl,((.checkAtAppomattox-L0107_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkZone8Occupied
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      8
        jr      nz,.notInZone8

        ld      a,1
        ret

.notInZone8
        cp      2
        jr      nz,.notInZone8or2

        ld      a,1
        ret

.notInZone8or2
        xor     a
        ret

.checkAtAppomattox
        ;at appomattox if on EXIT_U
        ld      c,a
        call    GetFirst
        call    GetCurZone
        ld      a,[hl]
        and     $f0
        cp      (EXIT_U << 4)
        jr      z,.atAppx

        xor     a
        ret

.atAppx
        ;dialog
        ld      a,10           ;move camera over appomattox
        ld      [camera_i],a
        ld      a,12
        ld      [camera_j],a

        ld      a,1
        ld      [heroesIdle],a

        push    bc
        ld      bc,classPansy   ;pansies inactive
        ld      de,classDoNothing
        call    ChangeClass
        pop     bc

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ld      de,((.afterReport-L0107_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      de,hero_report_gtx
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom

        ld      c,BS_INDEX
        ld      de,bs_tookkey_gtx
        call    ShowDialogAtTop

        ld      c,BA_INDEX
        ld      de,ba_whataboutspare_gtx
        call    ShowDialogAtBottom

        ld      c,BS_INDEX
        ld      de,bs_wasspare_gtx
        call    ShowDialogAtTop

        ld      c,BA_INDEX
        ld      de,ba_guns_gtx
        call    ShowDialogAtBottom

        ld      c,BS_INDEX
        ld      de,bs_finelotofgood_gtx
        call    ShowDialogAtTop
.afterReport
        call    ClearDialog
        call    ClearDialogSkipForward

        call    ((.blowOpenGate-L0107_Check2)+levelCheckRAM)

        ld      de,((.afterCool-L0107_Check2)+levelCheckRAM)
        call    SetDialogSkip
        ld      c,BS_INDEX
        ld      de,bs_cool_gtx
        call    ShowDialogAtTop
.afterCool
        call    ClearDialog
        call    ClearDialogSkipForward

        ld      bc,classDoNothing ;pansies become active
        ld      de,classPansy
        call    ChangeClass

        call    MakeNonIdle

        ld      a,1
        ret

.state_normal
        ret

.blowOpenGate
        ld      c,LASER_INDEX

        ld      b,7
.laserLoop
        ld      a,%00001000          ;blue palette, heading north
        ld      [methodParamL],a
        ld      hl,$d2ca             ;location
        call    CreateInitAndDrawObject     ;make a laser
        ld      hl,bigLaserSound
        call    PlaySound

        push    bc
        ld      b,2
        ld      a,16
        call    SetupFadeFromSaturated
        pop     bc

        ld      a,5  ;15
        call    Delay
        ld      a,%00001000          ;blue palette, heading north
        ld      [methodParamL],a
        ld      hl,$d2c9             ;location
        call    CreateInitAndDrawObject     ;make a laser
        ld      hl,bigLaserSound
        call    PlaySound

        push    bc
        ld      b,2
        ld      a,16
        call    SetupFadeFromSaturated
        pop     bc

        ld      a,6
        call    Delay
        dec     b
        jr      nz,.laserLoop

        ;ld      a,5   ;15
        ;call    Delay

        ld      b,16
        ld      a,28
        call    SetupFadeFromSaturated

        ld      a,30
        call    Delay
        ret

.randomizeAttackDelay
        ld      c,a
        call    GetFirst
.randomizeLoop
        or      a
        ret     z
        ld      a,5
        call    GetRandomNumZeroToN
        call    SetAttackDelay
        call    GetNextObject
        jr      .randomizeLoop

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
        call    ((.animateLight-L0107_Check2)+levelCheckRAM)
        call    ((.animateLight-L0107_Check2)+levelCheckRAM)
        call    ((.animateLight-L0107_Check2)+levelCheckRAM)
        call    ((.animateLight-L0107_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0107_CheckFinished:

arrowInfo:    DS      5
bsExists:     DS      1

PRINTT "  0107 Level Check Size: "
PRINTV (L0107_CheckFinished - L0107_Check2) + 5
PRINTT "/$500 bytes"

