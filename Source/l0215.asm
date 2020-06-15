; L0215.asm BRAINIAC computer room
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"



;---------------------------------------------------------------------
SECTION "Level0215Section",ROMX
;---------------------------------------------------------------------

L0215_Contents::
  DW L0215_Load
  DW L0215_Init
  DW L0215_Check
  DW L0215_Map

brainiac_bg::
  INCBIN "Data/Cinema/Intro/brainiac.bg"

haiku_bg::
  INCBIN "Data/Cinema/MainCharDialog/haiku.bg"

dialog:
skippycapture_gyves1_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_gyves1.gtx"

skippycapture_gyves1_2_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_gyves1_2.gtx"

skippycapture_brainiac1_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_brainiac1.gtx"

skippycapture_skippy1_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_skippy1.gtx"

skippycapture_skippy1_2_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_skippy1_2.gtx"

skippycapture_brainiac2_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_brainiac2.gtx"

skippycapture_skippy2_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_skippy2.gtx"

skippycapture_brainiac3_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_brainiac3.gtx"

skippycapture_flour1_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_flour1.gtx"

skippycapture_haiku1_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_haiku1.gtx"

skippycapture_flour2_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_flour2.gtx"

skippycapture_haiku2_gtx:
  INCBIN "Data/Dialog/Intro/skippycapture_haiku2.gtx"

;----BS Dialog--------------------------------------

bs_justYouAnMe_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_justYouAnMe.gtx"

brainiac_sorry_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_sorry.gtx"

bs_answerSomeQuestions_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_answerSomeQuestions.gtx"

brainiac_lovzHelping_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_lovzHelping.gtx"

bs_showMe_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_showMe.gtx"

brainiac_notNeedBRAINIAC_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_notNeedBRAINIAC.gtx"

bs_gotAPoint_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_gotAPoint.gtx"

brainiac_sezAsk_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_sezAsk.gtx"

bs_reallyHard_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_reallyHard.gtx"

brainiac_canAnswerAny_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_canAnswerAny.gtx"

bs_hereGoes_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_hereGoes.gtx"

brainiac_computes1_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes1.gtx"

brainiac_computes2_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes2.gtx"

brainiac_computes3_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes3.gtx"

brainiac_computes4_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes4.gtx"

brainiac_computes5_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes5.gtx"

brainiac_computes6_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes6.gtx"

brainiac_computes7_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_computes7.gtx"

bs_well_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_well.gtx"

brainiac_surrender_gtx:
  INCBIN "Data/Dialog/IntroBS/brainiac_surrender.gtx"

bs_wellSee_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_wellSee.gtx"

STATE_MOVETOBRAINIAC  EQU 1
STATE_GYROTALKDELAY1  EQU 2
STATE_GYROTALKDELAY2  EQU 3
STATE_BRAINIACCINEMA  EQU 4
STATE_SKIPPY_CAPTURE  EQU 5
STATE_FLOUR_ORDERS_RESCUE EQU 6
STATE_NORMAL          EQU 7
STATE_WAIT_DIALOG     EQU 8
STATE_BS1             EQU 9
STATE_BS2             EQU 10
STATE_BS3             EQU 11
STATE_BS4             EQU 12
STATE_BS5             EQU 13
STATE_BS6             EQU 14
STATE_BS7             EQU 15
STATE_BS8             EQU 16
STATE_BS9             EQU 17
STATE_BS10            EQU 18
STATE_BS11            EQU 19
STATE_BS12            EQU 20
STATE_BS13            EQU 21
STATE_BS14            EQU 22
STATE_BS15            EQU 23
STATE_BS16            EQU 24
STATE_BS17            EQU 25
STATE_BS18            EQU 26
STATE_BS19            EQU 27
STATE_BS20            EQU 28
STATE_BS21            EQU 29

VAR_LIGHT     EQU 0
VAR_GYRO      EQU 1
VAR_SKIPPY    EQU 2
VAR_DELAY     EQU 3
GYRO_DEST     EQU $d0ce

LIGHTINDEX       EQU 45
HULKINDEX        EQU 134
GRUNTINDEX       EQU 135
GYROINDEX        EQU 137
SKIPPYINDEX      EQU 138
PURPLEINDEX      EQU 139
YELLOWINDEX      EQU 140
BRAINIACINDEX    EQU 141

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0215_Load:
        DW ((L0215_LoadFinished - L0215_Load2))  ;size
L0215_Load2:
;ld a,STATE_NORMAL
;ldio [mapState],a
        ldio    a,[mapState]
        or      a
        jr      nz,.notZero

        ld      a,1
        ld      [mapState],a

.notZero
        cp      STATE_BRAINIACCINEMA
        jr      z,.brainiacCinema

        cp      STATE_MOVETOBRAINIAC
        jr      z,.zeroHealth

        cp      STATE_SKIPPY_CAPTURE
        jr      nz,.parseMap

        ld      a,BANK(alarm_gbm)
        ld      hl,alarm_gbm
        call    InitMusic

.zeroHealth
        ;zero health so sparklies don't show up on screen
        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a

        ld      a,2
        ld      [canJoinMap],a


.parseMap
        call    ParseMap
        ret

.brainiacCinema
        ;----display cinema scenes------------------------------------
        ;----"BRAINIAC givez it to you straight :)"-------------------
        ld      a,BANK(dialog)
        ld      [dialogBank],a

.brain1
        ld      hl,dialogSettings
        res     DLG_BORDER_BIT,[hl]
        ld      a,BANK(brainiac_bg)
        ld      hl,brainiac_bg
        call    LoadCinemaBG
        call    ((.fadeFromBlack16-L0215_Load2)+levelCheckRAM)

        ld      de,((.skippy1 - L0215_Load2) + levelCheckRAM)
        call    SetDialogForward
        ld      de,((.endCinemaPart1 - L0215_Load2) + levelCheckRAM)
        call    SetDialogSkip

        ld      c,0
        ld      de,skippycapture_brainiac1_gtx
        call    ShowDialogAtBottomNoWait

        ld      d,4
        LONGCALLNOARGS AnimateBRAINIAC

        ;----"Well hot dang!!!"---------------------------------------
.skippy1
        call    ((.fadeToBlack1 - L0215_Load2) + levelCheckRAM)
        call    ((.loadSkippy - L0215_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L0215_Load2) + levelCheckRAM)

        ld      de,((.skippy2 - L0215_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        ld      de,skippycapture_skippy1_gtx
        call    ShowDialogAtBottomNoWait

        ld      d,3
        LONGCALLNOARGS AnimateSkippy

        ;----"just what were you fellers plannin to do"---------------
.skippy2
        ld      c,0
        ld      de,skippycapture_skippy1_2_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.brain2 - L0215_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,5
        LONGCALLNOARGS AnimateSkippy

        ;----"we gonna capture big B12 officer"-----------------------
.brain2
        call    ((.loadBRAINIAC - L0215_Load2) + levelCheckRAM)

        ld      de,((.skippy3 - L0215_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        ld      de,skippycapture_brainiac2_gtx
        call    ShowDialogAtBottomNoWait

        ld      d,6
        LONGCALLNOARGS AnimateBRAINIAC

        ;----"And just how were you thinkin you'd do that?"-----------
.skippy3
        call    ((.fadeToBlack1 - L0215_Load2) + levelCheckRAM)
        call    ((.loadSkippy - L0215_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L0215_Load2) + levelCheckRAM)

        ld      de,((.brain3 - L0215_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        ld      de,skippycapture_skippy2_gtx
        call    ShowDialogAtBottomNoWait

        ld      d,4
        LONGCALLNOARGS AnimateSkippy

        ;----"BRAINIAC sez gonna make him think he capture the base"--
.brain3
        call    ((.loadBRAINIAC - L0215_Load2) + levelCheckRAM)

        ld      de,((.endCinemaPart1 - L0215_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        ld      de,skippycapture_brainiac3_gtx
        call    ShowDialogAtBottomNoWait

        ld      d,6
        LONGCALLNOARGS AnimateBRAINIAC

.endCinemaPart1
        call    ClearDialog

        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,STATE_SKIPPY_CAPTURE
        ldio    [mapState],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.fadeToBlack1
        call    ClearDialog
        ld      a,1
        call    SetupFadeToBlack
        jr      .fadeCommon

.fadeFromBlack1
        ld      a,1
        call    SetupFadeFromBlack
        jr      .fadeCommon

.fadeToBlack16
        ld      a,16
        call    SetupFadeToBlack
        jr      .fadeCommon

.fadeFromBlack16
        ld      a,16
        call    SetupFadeFromBlack
        jr      .fadeCommon

.fadeCommon
        call    WaitFade
        ret

.loadSkippy
        ld      a,BANK(skippy_bg)
        ld      hl,skippy_bg
        call    LoadCinemaBG
        ret

.loadBRAINIAC
        call    ((.fadeToBlack1-L0215_Load2)+levelCheckRAM)
        call    ClearDialog
        ld      a,BANK(brainiac_bg)
        ld      hl,brainiac_bg
        jr      .loadCommon
        ret

.loadFlour
        ld      a,BANK(flour_bg)
        ld      hl,flour_bg
        call    LoadCinemaBG
        ret

.loadCommon
        call    LoadCinemaBG
        call    ((.fadeFromBlack1-L0215_Load2)+levelCheckRAM)
        ret

L0215_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0215_Map:
INCBIN "Data/Levels/L0215_intro_bs3.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0215_Init:
        DW ((L0215_InitFinished - L0215_Init2))  ;size
L0215_Init2:
;ld a,STATE_NORMAL
;ldio [mapState],a
        call    SetPressBDialog
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,10
        ld      [camera_i],a
        ld      [camera_j],a
        ld      a,1
        ld      [mapLeft],a

        ld      a,[bgTileMap+LIGHTINDEX]  ;tile index of first light
        ld      [levelVars+VAR_LIGHT],a

        ldio    a,[mapState]
        cp      STATE_MOVETOBRAINIAC
        jr      nz,.checkSkippyCapture

        ;----skippy and gyro moving to brainiac-----------------------
        ;create Gyro, Skippy, and some B12 guards
        call    ((.removeHulks - L0215_Init2) + levelCheckRAM)
        ld      c,GYROINDEX    ;gyro
        ld      hl,$d22a
        call    CreateInitAndDrawObject
        ld      hl,$d18e
        call    SetActorDestLoc
        call    PointerDEToIndex
        ld      [levelVars + VAR_GYRO],a

        ld      c,SKIPPYINDEX    ;skippy
        ld      hl,$d1ea
        call    CreateInitAndDrawObject
        ld      hl,$d14e
        call    SetActorDestLoc
        call    PointerDEToIndex
        ld      [levelVars + VAR_SKIPPY],a

        call    ((.createGuards - L0215_Init2) + levelCheckRAM)
        call    ((.removeHeroes - L0215_Init2) + levelCheckRAM)

        ld      bc,classB12Soldier
        ld      de,classDoNothing
        call    ChangeClass

        ld      bc,classMajorSkippy
        ld      de,classActor2x2
        call    ChangeClass

        ld      bc,classGeneralGyro
        ld      de,classActor2x2
        call    ChangeClass
        ret

.checkSkippyCapture
        cp      STATE_SKIPPY_CAPTURE
        jr      nz,.checkNormal

        ;----crouton grunts moving to kill guards---------------------
        call    ((.removeHulks - L0215_Init2) + levelCheckRAM)
        ld      c,GYROINDEX   
        ld      hl,$d0ce
        call    CreateInitAndDrawObject
        ld      b,DIR_EAST
        call    ((.faceDirection - L0215_Init2) + levelCheckRAM)
        ld      a,GROUP_MONSTERN
        call    SetGroup

        ld      c,SKIPPYINDEX    ;skippy
        ld      hl,$d0cb
        call    CreateInitAndDrawObject
        ld      b,DIR_EAST
        call    ((.faceDirection - L0215_Init2) + levelCheckRAM)
        ld      a,GROUP_MONSTERN
        call    SetGroup

        call    ((.createGuards - L0215_Init2) + levelCheckRAM)
        call    ((.removeHeroes - L0215_Init2) + levelCheckRAM)

        ;create croutons
        ld      b,6
        ld      hl,$d1e9
        call    ((.createCroutons - L0215_Init2) + levelCheckRAM)
        ld      b,6
        ld      hl,$d209
        call    ((.createCroutons - L0215_Init2) + levelCheckRAM)
        ld      b,2
        ld      hl,$d22a
        call    ((.createCroutons - L0215_Init2) + levelCheckRAM)
        ld      b,2
        ld      hl,$d24a
        call    ((.createCroutons - L0215_Init2) + levelCheckRAM)

        ld      bc,classMajorSkippy
        ld      de,classDoNothing
        call    ChangeClass

        ld      bc,classGeneralGyro
        ld      de,classDoNothing
        call    ChangeClass

        ret

.checkNormal
        ;----BS Enters room, must kill hulks--------------------------
        ld      a,30  ;delay after killing last hulk before text box
        ld      [levelVars + VAR_DELAY],a

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

.createGuards
        ld      c,PURPLEINDEX    ;purple guard
        ld      hl,$d144
        call    CreateInitAndDrawObject
        ld      b,DIR_EAST
        call    ((.faceDirection - L0215_Init2) + levelCheckRAM)
        ld      hl,$d184
        call    CreateInitAndDrawObject
        ld      b,DIR_EAST
        call    ((.faceDirection - L0215_Init2) + levelCheckRAM)

        ld      c,YELLOWINDEX    ;yellow guard
        ld      hl,$d152
        call    CreateInitAndDrawObject
        ld      b,DIR_WEST
        call    ((.faceDirection - L0215_Init2) + levelCheckRAM)
        ld      hl,$d192
        call    CreateInitAndDrawObject
        ld      b,DIR_WEST
        call    ((.faceDirection - L0215_Init2) + levelCheckRAM)
        ret

.createCroutons
        ld      c,GRUNTINDEX    ;crouton class index
        call    CreateInitAndDrawObject
        inc     hl
        dec     b
        jr      nz,.createCroutons
        ret

.faceDirection
        ld      a,b
        call    SetFacing
        ld      b,METHOD_DRAW
        call    CallMethod
        ret

.removeHeroes
        ld      a,[hero0_index]
        call    ((.removeHero - L0215_Init2) + levelCheckRAM)

        ld      a,[hero1_index]
        call    ((.removeHero - L0215_Init2) + levelCheckRAM)

        ld      a,1
        ld      [heroesIdle],a
        ret

.removeHero
        or      a
        ret     z
        ld      c,a
        call    GetFirst
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        ret

.removeHulks
        ld      a,HULKINDEX
        call    DeleteObjectsOfClassIndex
        ret

L0215_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
;STATE_MOVETOBRAINIAC EQU 0
;STATE_SKIPPY_CAPTURE EQU 1
;STATE_NORMAL         EQU 2
L0215_Check:
        DW ((L0215_CheckFinished - L0215_Check2))  ;size
L0215_Check2:
        call    SetSkipStackPos
        call    CheckSkip

        ;animate dice lights
        ld      a,[levelVars+VAR_LIGHT]
        ld      b,a

        ;slow lights
        ldio    a,[updateTimer]
        swap    a
        and     %00000011
        add     b

        ld      hl,bgTileMap+LIGHTINDEX
        call    ((.updateTwoLights - L0215_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L0215_Check2) + levelCheckRAM)

        VECTORTOSTATE ((.stateTable - L0215_Check2) + levelCheckRAM)

.stateTable
        DW ((.checkMoveToBRAINIAC-L0215_Check2)+levelCheckRAM)
        DW ((.checkMoveToBRAINIAC-L0215_Check2)+levelCheckRAM)
        DW ((.checkGyroTalkDelay1-L0215_Check2)+levelCheckRAM)
        DW ((.checkGyroTalkDelay2-L0215_Check2)+levelCheckRAM)
        DW ((.checkBRAINIACCinema-L0215_Check2)+levelCheckRAM)
        DW ((.checkSkippyCapture-L0215_Check2)+levelCheckRAM)
        DW ((.checkFlourOrdersRescue-L0215_Check2)+levelCheckRAM)
        DW ((.checkNormal-L0215_Check2)+levelCheckRAM)
        DW ((.checkWaitDialog-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS1-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS2-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS3-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS4-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS5-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS6-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS7-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS8-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS9-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS10-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS11-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS12-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS13-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS14-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS15-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS16-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS17-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS18-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS19-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS20-L0215_Check2)+levelCheckRAM)
        DW ((.checkBS21-L0215_Check2)+levelCheckRAM)

.checkNormal
        ;normal state
        ;wait 'till all hulks are dead
        ld      c,HULKINDEX
        call    GetFirst
        or      a
        ret     nz

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_BS1
        ldio    [mapState],a
        ret

.checkWaitDialog
        STDWAITDIALOG
        ret

.setupBRAINIAC
        call    SetSpeakerToFirstHero
        ld      c,BRAINIACINDEX
        ld      hl,dialogSettings
        set     DLG_BRAINIAC_BIT,[hl]
        ret

.checkBS1
        ld      hl,levelVars + VAR_DELAY  ;allow bullets to explode etc
        dec     [hl]
        ret     nz

        ld      de,((.endBSBRAINIAC - L0215_Check2) + levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_justYouAnMe_gtx
        WAITDIALOG STATE_BS2
        ret
.checkBS2
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_sorry_gtx
        WAITDIALOG STATE_BS3
        ret
.checkBS3
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_answerSomeQuestions_gtx
        WAITDIALOG STATE_BS4
        ret
.checkBS4
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_lovzHelping_gtx
        WAITDIALOG STATE_BS5
        ret
.checkBS5
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_showMe_gtx
        WAITDIALOG STATE_BS6
        ret
.checkBS6
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_notNeedBRAINIAC_gtx
        WAITDIALOG STATE_BS7
        ret
.checkBS7
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_gotAPoint_gtx
        WAITDIALOG STATE_BS8
        ret
.checkBS8
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_sezAsk_gtx
        WAITDIALOG STATE_BS9
        ret
.checkBS9
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_reallyHard_gtx
        WAITDIALOG STATE_BS10
        ret
.checkBS10
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_canAnswerAny_gtx
        WAITDIALOG STATE_BS11
        ret
.checkBS11
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_hereGoes_gtx
        WAITDIALOG STATE_BS12
        ret
.checkBS12
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes1_gtx
        WAITDIALOGNOCLEAR STATE_BS13
        ret
.checkBS13
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes2_gtx
        WAITDIALOGNOCLEAR STATE_BS14
        ret
.checkBS14
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes3_gtx
        WAITDIALOGNOCLEAR STATE_BS15
        ret
.brainiacPrint
        ld      h,29
        ld      de,$1205
        ld      bc,$0203
        call    BlitMap
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        ret
.checkBS15
        ld      l,1
        call    ((.brainiacPrint-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes4_gtx
        WAITDIALOGNOCLEAR STATE_BS16
        ret
.checkBS16
        ld      l,4
        call    ((.brainiacPrint-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes5_gtx
        WAITDIALOGNOCLEAR STATE_BS17
        ret
.checkBS17
        ld      l,7
        call    ((.brainiacPrint-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes6_gtx
        WAITDIALOGNOCLEAR STATE_BS18
        ret
.checkBS18
        ld      l,10
        call    ((.brainiacPrint-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_computes7_gtx
        WAITDIALOG STATE_BS19
        ret
.checkBS19
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM bs_well_gtx
        WAITDIALOG STATE_BS20
        ret
.checkBS20
        call    ((.setupBRAINIAC-L0215_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_surrender_gtx
        WAITDIALOG STATE_BS21
        ret
.checkBS21
        ;call    SetSpeakerToFirstHero
        ;DIALOGBOTTOM bs_wellSee_gtx
.endBSBRAINIAC
        call    ClearDialog
        ld      a,96 
        call    SetupFadeToStandard
        call    WaitFade
        ld      hl,fadeFinalPalette
        ld      de,gamePalette
        call    CopyPalette64

        ld      hl,$1402
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        call    YankRemotePlayer
        ld      a,1
        ld      [timeToChangeLevel],a
        ret


.checkMoveToBRAINIAC
        ld      de,((.checkBRAINIACCinema - L0215_Check2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.bothAtFinalDest - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        ;skippy there yet?
        ld      c,SKIPPYINDEX  ;skippy class index
        ld      a,[levelVars + VAR_SKIPPY]
        call    ((.checkActorAtDest - L0215_Check2) + levelCheckRAM)
        jr      z,.afterResetSkippy

        ;reset skippy once he gets to his waypoint
        call    GetCurZone
        cp      4
        jr      nz,.afterResetSkippy

        ld      hl,$d0cb
        call    SetActorDestLoc
        ret

.checkActorAtDest
        call    IndexToPointerDE
        call    IsActorAtDest
        or      a
        ret

.afterResetSkippy
        ;do the same for gyro
        ld      c,GYROINDEX                 
        ld      a,[levelVars + VAR_GYRO]
        call    ((.checkActorAtDest - L0215_Check2) + levelCheckRAM)
        ret     z

        call    GetCurZone
        cp      4
        jr      nz,.bothAtFinalDest

        ld      hl,GYRO_DEST
        call    SetActorDestLoc
        ret

.bothAtFinalDest
        call    SetSpeakerToFirstHero
        ld      c,GYROINDEX
        ld      de,skippycapture_gyves1_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.checkBRAINIACCinema - L0215_Check2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.gyvesIntroduce2 - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,100
        ld      [levelVars + VAR_DELAY],a
        ld      a,STATE_GYROTALKDELAY1
        ldio    [mapState],a
        ret

.checkGyroTalkDelay1
        ld      hl,levelVars + VAR_DELAY
        dec     [hl]
        ret     nz

.gyvesIntroduce2
        ld      a,140     ;reset delay for next dialog
        ld      [levelVars + VAR_DELAY],a

        ;display second half of dialog
        ld      c,GYROINDEX    ;gyro class index
        ld      de,skippycapture_gyves1_2_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.checkBRAINIACCinema - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,STATE_GYROTALKDELAY2
        ldio    [mapState],a
        ld      a,1
        ;ld      [timeToChangeLevel],a
        ret

.checkGyroTalkDelay2
        ld      hl,levelVars + VAR_DELAY
        dec     [hl]
        ret     nz

.checkBRAINIACCinema
        call    ClearDialog
        ld      a,STATE_BRAINIACCINEMA
        ldio    [mapState],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.checkSkippyCapture
        ld      de,((.fadeOut - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward
        call    SetDialogSkip

        ;wait until all the guards (PURPLEINDEX & YELLOWINDEX are dead
        ;OR all the croutons (GRUNTINDEX) are dead (god forbid)
        ld      c,PURPLEINDEX
        call    GetFirst
        or      a
        jr      nz,.checkCroutonsRemaining

        ld      c,YELLOWINDEX
        call    GetFirst
        or      a
        jr      z,.fadeOut

.checkCroutonsRemaining
        ld      c,GRUNTINDEX
        call    GetFirst
        or      a
        ret     nz

.fadeOut
        ld      a,96
        call    SetupFadeToBlack

        ld      de,0
        call    SetDialogForward
        call    SetDialogSkip

        ld      a,STATE_FLOUR_ORDERS_RESCUE
        ldio    [mapState],a

        ret

.checkFlourOrdersRescue
.isFlourOrdersRescue
        ld      a,[specialFX]
        and     FX_FADE
        ret     nz

        ld      hl,dialogSettings
        res     DLG_BORDER_BIT,[hl]
        call    ResetSprites
        ld      a,BANK(moon_bg)
        ld      hl,moon_bg
        call    LoadCinemaBG

        ld      de,((.endCinemaPart2 - L0215_Check2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.flour1 - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,60
        call    SetupFadeFromBlack
        call    WaitFade

        ld      a,60
        call    Delay

        call    ((.fadeToBlack16-L0215_Check2)+levelCheckRAM)

        ld      a,BANK(triumphBIG_bg)
        ld      hl,triumphBIG_bg
        call    LoadCinemaBG

        ld      bc,$140c
        ld      hl,$1402
        ld      de,$0000
        call    CinemaBlitRect
        ld      a,1
        call    Delay

        call    ((.fadeFromBlack16-L0215_Check2)+levelCheckRAM)

        ld      a,30
        call    Delay

.flour1
        ;----"Oh my gosh Major Skippy's been kidnapped!"--------------
        call    ((.fadeToBlack16-L0215_Check2)+levelCheckRAM)
        call    ((.loadFlour - L0215_Check2) + levelCheckRAM)
        call    ((.fadeFromBlack16-L0215_Check2)+levelCheckRAM)

        ld      c,0
        ld      de,skippycapture_flour1_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.haiku1 - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,6
        LONGCALLNOARGS    AnimateFlour

.haiku1
        ;----"Yes what is it?"----------------------------------------
        call    ((.loadHaiku - L0215_Check2) + levelCheckRAM)

        ld      a,BANK(haiku_gbm)
        ld      hl,haiku_gbm
        call    InitMusic

        ld      c,0
        ld      de,skippycapture_haiku1_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour2 - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        LONGCALLNOARGS    AnimateHaiku

.flour2
        ;----"Take your merry band of Ninjas..."----------------------
        call    ((.fadeToBlack1-L0215_Check2)+levelCheckRAM)
        call    ((.loadFlour - L0215_Check2) + levelCheckRAM)
        call    ((.fadeFromBlack1-L0215_Check2)+levelCheckRAM)

        ld      c,0
        ld      de,skippycapture_flour2_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.haiku2 - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        ld      d,6
        LONGCALLNOARGS    AnimateFlour

.haiku2
        ;----"I will take Quatrain..."--------------------------------
        call    ((.loadHaiku - L0215_Check2) + levelCheckRAM)

        ld      c,0
        ld      de,skippycapture_haiku2_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.endCinemaPart2 - L0215_Check2) + levelCheckRAM)
        call    SetDialogForward

        LONGCALLNOARGS    AnimateHaiku

.endCinemaPart2
        call    ClearDialog

        ;ld      a,16
        ;call    SetupFadeToWhite
        ;call    WaitFade

        ld      hl,2058  ;haiku
        ld      a,l
        ld      [hero0_class],a
        ld      a,h
        ld      [hero0_class+1],a
        ld      a,HERO_HAIKU_FLAG
        ld      [hero0_type],a

        ld      hl,FREEVERSE_CINDEX
        ld      a,l
        ld      [hero1_class],a
        ld      a,h
        ld      [hero1_class+1],a
        ld      a,HERO_BS_FLAG
        ld      [hero1_type],a

        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a

        ld      hl,$0014
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ret

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L0215_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.fadeToBlack1
        ld      a,1
        call    SetupFadeToBlack
        jr      .fadeCommon

.fadeFromBlack1
        ld      a,1
        call    SetupFadeFromBlack
        jr      .fadeCommon

.fadeToBlack16
        ld      a,16
        call    SetupFadeToBlack
        jr      .fadeCommon

.fadeFromBlack16
        ld      a,16
        call    SetupFadeFromBlack
        jr      .fadeCommon

.fadeCommon
        call    WaitFade
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret

.loadSkippy
        ld      a,BANK(skippy_bg)
        ld      hl,skippy_bg
        jr      .loadCommon
        ret

.loadFlour
        ld      a,BANK(flour_bg)
        ld      hl,flour_bg
        call    LoadCinemaBG
        ret

.loadHaiku
        call    ((.fadeToBlack1-L0215_Check2)+levelCheckRAM)
        ld      a,BANK(haiku_bg)
        ld      hl,haiku_bg
        jr      .loadCommon
        ret

.loadCommon
        call    LoadCinemaBG
        call    ((.fadeFromBlack1-L0215_Check2)+levelCheckRAM)
        ret

L0215_CheckFinished:
PRINTT "0215 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0215_LoadFinished - L0215_Load2)
PRINTT " / "
PRINTV (L0215_InitFinished - L0215_Init2)
PRINTT " / "
PRINTV (L0215_CheckFinished - L0215_Check2)
PRINTT "\n"

