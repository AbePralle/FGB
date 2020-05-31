; l0314.asm skippy runs for it
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"



;---------------------------------------------------------------------
SECTION "Level0314Section",DATA
;---------------------------------------------------------------------

L0314_Contents::
  DW L0314_Load
  DW L0314_Init
  DW L0314_Check
  DW L0314_Map

dialog:
skippy_woowee_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_woowee.gtx"

flour_anySign_gtx:
  INCBIN "gtx\\intro_haiku\\flour_anySign.gtx"

haiku_theyNever_gtx:
  INCBIN "gtx\\intro_haiku\\haiku_theyNever.gtx"

flour_poorIambic_gtx:
  INCBIN "gtx\\intro_haiku\\flour_poorIambic.gtx"

flour_poorQuatrain_gtx:
  INCBIN "gtx\\intro_haiku\\flour_poorQuatrain.gtx"

flour_headHome_gtx:
  INCBIN "gtx\\intro_haiku\\flour_headHome.gtx"

skippy_notJustYet_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_notJustYet.gtx"

skippy_smartestThing_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_smartestThing.gtx"

skippy_loseForSure_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_loseForSure.gtx"

flour_sendBS_gtx:
  INCBIN "gtx\\intro_haiku\\flour_sendBS.gtx"

flour_sabotage_gtx:
  INCBIN "gtx\\intro_haiku\\flour_sabotage.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
STATE_WAITSKIPPY  EQU 0
STATE_WAITFADE    EQU 1
STATE_CINEMA      EQU 2

L0314_Load:
        DW ((L0314_LoadFinished - L0314_Load2))  ;size
L0314_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ldio    a,[mapState]
        cp      STATE_WAITSKIPPY
        jr      nz,.doCinema
        call    ParseMap
        ret

.doCinema
        ld      a,BANK(intro_cinema_gbm)
        ld      hl,intro_cinema_gbm
        call    InitMusic

        ld      a,BANK(moon_bg)
        ld      hl,moon_bg
        call    LoadCinemaBG

        ld      de,((.endCinema - L0314_Load2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.skippy1 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,60
        call    SetupFadeFromStandard
        call    WaitFade

        ld      a,30
        call    Delay

        ld      a,16
        call    SetupFadeToBlack
        call    WaitFade

        ld      a,BANK(triumphBIG_bg)
        ld      hl,triumphBIG_bg
        call    LoadCinemaBG

        ld      bc,$140c
        ld      hl,$1402
        ld      de,$0000
        call    CinemaBlitRect
        ld      a,1
        call    Delay

        ld      a,16
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,30
        call    Delay

.skippy1
        ;----"Woowee that was a close one!"---------------------------
        ld      a,16
        call    SetupFadeToBlack
        call    WaitFade

        call    ((.loadSkippy - L0314_Load2) + levelCheckRAM)

        ld      a,16
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,BANK(skippy_woowee_gtx)
        ld      c,0
        ld      de,skippy_woowee_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour1 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,3
        LONGCALLNOARGS AnimateSkippy

.flour1
        ;----"Any sign of Quatrain and Iambic Pentameter?"------------
        call    ClearDialog
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade

        call    ((.loadFlour - L0314_Load2) + levelCheckRAM)

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,BANK(flour_anySign_gtx)
        ld      c,0
        ld      de,flour_anySign_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.haiku1 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.haiku1
        call    ClearDialog
        ;----"They never returned..."---------------------------------
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade

        call    ((.loadHaiku - L0314_Load2) + levelCheckRAM)

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,BANK(haiku_theyNever_gtx)
        ld      c,0
        ld      de,haiku_theyNever_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour2 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        LONGCALLNOARGS AnimateHaiku

.flour2
        call    ClearDialog
        ;----"Oh poor Iambic Pentamter!..."---------------------------
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade

        call    ((.loadFlour - L0314_Load2) + levelCheckRAM)

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,BANK(flour_poorIambic_gtx)
        ld      c,0
        ld      de,flour_poorIambic_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour3 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,6
        LONGCALLNOARGS AnimateFlour

.flour3
        ;----"And poor Quatrain!..."----------------------------------
        ld      a,BANK(flour_poorQuatrain_gtx)
        ld      c,0
        ld      de,flour_poorQuatrain_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour4 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,6
        LONGCALLNOARGS AnimateFlour

.flour4
        ;----"Well I guess it's time to head back home."--------------
        ld      a,BANK(flour_headHome_gtx)
        ld      c,0
        ld      de,flour_headHome_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.skippy2 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.skippy2
        call    ClearDialog
        ;----"Not just yet!  We have to get rid..."-------------------
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade

        call    ((.loadSkippy - L0314_Load2) + levelCheckRAM)

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,BANK(skippy_notJustYet_gtx)
        ld      c,0
        ld      de,skippy_notJustYet_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.skippy3 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateSkippy

.skippy3
        ;----"I reckon it's just about the smartest thing..."---------
        ld      a,BANK(skippy_smartestThing_gtx)
        ld      c,0
        ld      de,skippy_smartestThing_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.skippy4 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,5
        LONGCALLNOARGS AnimateSkippy

.skippy4
        ;----""We'll lose for sure..."--------------------------------
        ld      a,BANK(skippy_loseForSure_gtx)
        ld      c,0
        ld      de,skippy_loseForSure_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour5 - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,5
        LONGCALLNOARGS AnimateSkippy

.flour5
        call    ClearDialog
        ;----"Okay let's send BS!"------------------------------------
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade

        call    ((.loadFlour - L0314_Load2) + levelCheckRAM)

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,BANK(flour_sendBS_gtx)
        ld      c,0
        ld      de,flour_sendBS_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.transitionToMoon - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,6
        LONGCALLNOARGS AnimateFlour

.transitionToMoon
        call    ClearDialog
        ld      a,16
        call    SetupFadeToBlack
        call    WaitFade

        ld      a,BANK(moon_bg)
        ld      hl,moon_bg
        call    LoadCinemaBG

        ld      a,16
        call    SetupFadeFromBlack
        call    WaitFade

        ld      de,((.endCinema - L0314_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,30
        call    Delay

.endCinema
        call    ClearDialog
        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ld      hl,$0015
        ld      a,l
        ld      [respawnMap],a
        ld      a,h
        ld      [respawnMap+1],a

        ld      hl,2056  ;bs
        ld      a,l
        ld      [hero0_class],a
        ld      a,h
        ld      [hero0_class+1],a
        ld      a,HERO_BS_FLAG
        ld      [hero0_type],a

        ld      hl,CS_CINDEX
        ld      a,l
        ld      [hero1_class],a
        ld      a,h
        ld      [hero1_class+1],a
        ld      a,HERO_BA_FLAG
        ld      [hero1_type],a

        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a

        ld      hl,$0015
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.loadSkippy
        ld      a,BANK(skippy_bg)
        ld      hl,skippy_bg
        call    LoadCinemaBG
        ret

.loadFlour
        ld      a,BANK(flour_bg)
        ld      hl,flour_bg
        call    LoadCinemaBG
        ret

.loadHaiku
        ld      a,BANK(haiku_bg)
        ld      hl,haiku_bg
        call    LoadCinemaBG
        ret

L0314_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0314_Map:
INCBIN "..\\fgbeditor\\l0314_intro_haiku4.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
CROUTONINDEX EQU 21
SKIPPYINDEX  EQU 22

L0314_Init:
        DW ((L0314_InitFinished - L0314_Init2))  ;size
L0314_Init2:
        ld      a,2
        ld      [canJoinMap],a

        ;ld      a,BANK(alarm_gbm)
        ;ld      hl,alarm_gbm
        ;call    InitMusic

        ;all friends here
        ld      bc,((GROUP_MONSTERB<<8) | GROUP_MONSTERA)
        ld      a,1
        call    SetFOF

        ;set everybody to run to the right
        ld      c,CROUTONINDEX
        call    GetFirst
.setCroutonLoop
        call    ((.runRight-L0314_Init2)+levelCheckRAM)
        call    GetNextObject
        or      a
        jr      nz,.setCroutonLoop

        ld      c,SKIPPYINDEX
        call    GetFirst
        call    ((.runRight-L0314_Init2)+levelCheckRAM)

        ld      a,[hero0_index]
        or      a
        jr      z,.afterSetHero0
        ld      c,a
        call    GetFirst
        call    ((.runRight-L0314_Init2)+levelCheckRAM)

.afterSetHero0
        ld      a,[hero1_index]
        or      a
        jr      z,.afterSetHero1
        ld      c,a
        call    GetFirst
        call    ((.runRight-L0314_Init2)+levelCheckRAM)
.afterSetHero1

        ;everybody's an actor
        ld      bc,classCroutonDoctor
        ld      de,classActor
        call    ChangeClass

        ld      bc,classHaikuPlayer
        ld      de,classActor
        call    ChangeClass

        ld      bc,classMajorSkippy
        ld      de,classActorSpeed1
        call    ChangeClass

        ld      hl,((.greenDark-L0314_Init2)+levelCheckRAM)
        ld      de,gamePalette
        call    CopyPalette32

IF 0
        ld      c,9
.updateLoop
        call    UpdateObjTimers
        ld      b,METHOD_CHECK
        call    IterateAllLists
        dec     c
        jr      nz,.updateLoop
ENDC

        ret

.runRight
        call    GetCurLocation
        call    ConvertLocHLToXY
        ld      h,61
        call    ConvertXYToLocHL
        call    SetActorDestLoc
        call    GetFacing
        and     %11111100
        or      %00000001
        call    SetFacing
        ld      b,METHOD_DRAW
        call    CallMethod
        ret

.greenDark
DW      $0000, $0882, $1104, $1de7
DW      $0000, $0005, $000f, $1de7  ;red stays
DW      $0000, $1400, $1d00, $1de7
DW      $0000, $00a0, $01e0, $1de7
DW      $0000, $1002, $14c4, $1de7
DW      $0000, $00e3, $01e7, $1de7
DW      $0000, $0064, $00e7, $1de7
DW      $0000, $1004, $1cc7, $1de7

L0314_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0314_Check:
        DW ((L0314_CheckFinished - L0314_Check2))  ;size
L0314_Check2:
        ldio    a,[mapState]
        cp      STATE_WAITSKIPPY
        jr      nz,.checkWaitFade
        
        ;skippy far enough?
        ld      c,SKIPPYINDEX
        call    GetFirst
        call    GetCurLocation
        ld      a,h
        cp      $d2
        ret     nz
        ld      a,l
        cp      $e9
        ret     nz

        ;end level
        ld      a,48
        call    SetupFadeToStandard
        ld      a,STATE_WAITFADE
        ldio    [mapState],a
        ret

.checkWaitFade
        ld      a,[specialFX]
        and     FX_FADE
        ret     nz

        ld      hl,fadeFinalPalette
        ld      de,gamePalette
        call    CopyPalette64

        ld      hl,$0314
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a

        ld      a,STATE_CINEMA
        ldio    [mapState],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

L0314_CheckFinished:
PRINTT "0314 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0314_LoadFinished - L0314_Load2)
PRINTT " / "
PRINTV (L0314_InitFinished - L0314_Init2)
PRINTT " / "
PRINTV (L0314_CheckFinished - L0314_Check2)
PRINTT "\n"

