; l0115.asm BS sneaks in the crouton base
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0115Section",ROMX
;---------------------------------------------------------------------

L0115_Contents::
  DW L0115_Load
  DW L0115_Init
  DW L0115_Check
  DW L0115_Map

dialog:
brainiac_detectIntruder_gtx:
  INCBIN "gtx\\intro_bs\\brainiac_detectIntruder.gtx"

bs_segashuating_gtx:
  INCBIN "gtx\\intro_bs\\bs_segashuating.gtx"

brainiac_bringIt_gtx:
  INCBIN "gtx\\intro_bs\\brainiac_bringIt.gtx"

monitor_onlyCroutons_gtx:
  INCBIN "gtx\\intro_bs\\monitor_onlyCroutons.gtx"

bs_idea_gtx:
  INCBIN "gtx\\intro_bs\\bs_idea.gtx"

bs_presto_gtx:
  INCBIN "gtx\\intro_bs\\bs_presto.gtx"

bs_hangin1_gtx:
  INCBIN "gtx\\intro_bs\\bs_hangin1.gtx"

grunt_hangin2_gtx:
  INCBIN "gtx\\intro_bs\\grunt_hangin2.gtx"

bs_hangin3_gtx:
  INCBIN "gtx\\intro_bs\\bs_hangin3.gtx"

grunt_hangin4_gtx:
  INCBIN "gtx\\intro_bs\\grunt_hangin4.gtx"

bs_hangin5_gtx:
  INCBIN "gtx\\intro_bs\\bs_hangin5.gtx"

monitor_openDoor_gtx:
  INCBIN "gtx\\intro_bs\\monitor_openDoor.gtx"

brainiac_wait_gtx:
  INCBIN "gtx\\intro_bs\\brainiac_wait.gtx"

monitor_sorry_gtx:
  INCBIN "gtx\\intro_bs\\monitor_sorry.gtx"

brainiac_justClose_gtx:
  INCBIN "gtx\\intro_bs\\brainiac_justClose.gtx"

monitor_oneSecond_gtx:
  INCBIN "gtx\\intro_bs\\monitor_oneSecond.gtx"

brainiac_idiotz_gtx:
  INCBIN "gtx\\intro_bs\\brainiac_idiotz.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0115_Load:
        DW ((L0115_LoadFinished - L0115_Load2))  ;size
L0115_Load2:
        call    ParseMap
        ret

L0115_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0115_Map:
INCBIN "..\\fgbeditor\\l0115_intro_bs2.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
STATE_DETECT1             EQU  0
STATE_DETECT2             EQU  1
STATE_DETECT3             EQU  2
STATE_PRESTO              EQU  3
STATE_HANGIN2             EQU  4
STATE_HANGIN3             EQU  5
STATE_HANGIN4             EQU  6
STATE_HANGIN5             EQU  7
STATE_MONITOR1            EQU  8
STATE_WAIT_ALLBRAINIAC    EQU  9
STATE_MONITOR2            EQU 10
STATE_MONITOR3            EQU 11
STATE_MONITOR4            EQU 12
STATE_MONITOR5            EQU 13
STATE_NORMAL              EQU 14
STATE_WAIT_DIALOG         EQU 15

VAR_MONITOR_WARNING EQU 0
VAR_STATIC          EQU 1
VAR_SPEAKINGHERO    EQU 2
VAR_GRUNT_TILE      EQU 3
VAR_COSTUME_DIALOG  EQU 4
VAR_BS_TILE         EQU 5
VAR_NUMMONITORS     EQU 6
VAR_MONITORS        EQU 7   ;7-26, 20 monitors
VAR_HANGIN_DIALOG   EQU 27
VAR_COSTUME_HERO    EQU 28

STATICINDEX     EQU 34
BGBRAINIACINDEX EQU 31
GOBLININDEX     EQU 46
GRUNTINDEX      EQU 44
GUARDINDEX      EQU 45
BRAINIACINDEX   EQU 49

DETECTZONE      EQU 11
PAINTZONE       EQU 10  ;8
HANGINZONE1     EQU  5
HANGINZONE2     EQU  8  ;5
MONITORZONE     EQU  9

L0115_Init:
        DW ((L0115_InitFinished - L0115_Init2))  ;size
L0115_Init2:
        call    SetPressBDialog
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,BANK(bs_gbm)
        ld      hl,bs_gbm
        call    InitMusic

        xor     a
        ld      [levelVars + VAR_MONITOR_WARNING],a
        ld      [levelVars + VAR_COSTUME_DIALOG],a
        ld      [levelVars + VAR_HANGIN_DIALOG],a

        ;save BS's current tile for later
        call    SetSpeakerToFirstHero
        call    GetFGMapping
        ld      [levelVars+VAR_BS_TILE],a

        ld      a,20
        ld      [levelVars + VAR_NUMMONITORS],a

        xor     a
        ld      c,20
        ld      hl,levelVars + VAR_MONITORS
.clearMonitors
        ld      [hl+],a
        dec     c
        jr      nz,.clearMonitors
        

        ;ld      a,$ff
        ;ld      [levelVars + VAR_BS_TILE],a

        ld      a,[bgTileMap+STATICINDEX]
        ld      [levelVars+VAR_STATIC],a

        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      a,[fgTileMap+GRUNTINDEX]
        ld      [levelVars+VAR_GRUNT_TILE],a

        ldio    a,[mapState]
        cp      STATE_NORMAL
        ret     nz

        ;open doors
        ;open the security door
        ;ld      a,MAPBANK
        ;ldio    [$ff70],a
        ;xor     a
        ;ld      hl,$d189
        ;ld      [hl+],a
        ;ld      [hl],a

        ;open the outer door
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d049
        ld      [hl+],a
        ld      [hl],a

        ;mark certain dialogs as having happened
        ld      a,1
        ld      [levelVars + VAR_COSTUME_DIALOG],a
        ld      [levelVars + VAR_HANGIN_DIALOG],a

        ret

L0115_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0115_Check:
        DW ((L0115_CheckFinished - L0115_Check2))  ;size
L0115_Check2:
        call    SetSkipStackPos
        call    CheckSkip
        call    ((.animateStatic-L0115_Check2)+levelCheckRAM)
        call    ((.checkBSAttack-L0115_Check2)+levelCheckRAM)
        call    ((.checkPaintRoom-L0115_Check2)+levelCheckRAM)
        call    ((.checkHangin-L0115_Check2)+levelCheckRAM)
        call    ((.adjustCameraInMonitorRoom-L0115_Check2)+levelCheckRAM)
        call    ((.checkMonitorWarn-L0115_Check2)+levelCheckRAM)
        VECTORTOSTATE ((.stateTable-L0115_Check2)+levelCheckRAM)

.stateTable
        DW      ((.checkDetect1-L0115_Check2)+levelCheckRAM)
        DW      ((.checkDetect2-L0115_Check2)+levelCheckRAM)
        DW      ((.checkDetect3-L0115_Check2)+levelCheckRAM)
        DW      ((.checkPresto-L0115_Check2)+levelCheckRAM)
        DW      ((.checkHangin2-L0115_Check2)+levelCheckRAM)
        DW      ((.checkHangin3-L0115_Check2)+levelCheckRAM)
        DW      ((.checkHangin4-L0115_Check2)+levelCheckRAM)
        DW      ((.checkHangin5-L0115_Check2)+levelCheckRAM)
        DW      ((.checkMonitor1-L0115_Check2)+levelCheckRAM)
        DW      ((.checkWaitAllBRAINIAC-L0115_Check2)+levelCheckRAM)
        DW      ((.checkMonitor2-L0115_Check2)+levelCheckRAM)
        DW      ((.checkMonitor3-L0115_Check2)+levelCheckRAM)
        DW      ((.checkMonitor4-L0115_Check2)+levelCheckRAM)
        DW      ((.checkMonitor5-L0115_Check2)+levelCheckRAM)
        DW      ((.checkNormal-L0115_Check2)+levelCheckRAM)
        DW      ((.checkWaitDialog-L0115_Check2)+levelCheckRAM)

.checkDetect1
        ld      a,1
        ld      hl,((.checkDetect1_hero-L0115_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkDetect1_hero
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      DETECTZONE
        ld      a,0
        ret     nz

        ld      a,c
        ld      [levelVars + VAR_SPEAKINGHERO],a
        call    SetSpeakerFromHeroIndex

        call    MakeIdle

        ld      hl,$d85d
        call    ((.monitorToStatic-L0115_Check2)+levelCheckRAM)

        ld      c,8
.waitStatic
        ld      de,((.skipDetect - L0115_Check2) + levelCheckRAM)
        call    SetDialogSkip

        ld      a,1
        call    Delay
        call    ((.animateStatic-L0115_Check2)+levelCheckRAM)
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.waitStatic

        ld      hl,$d85d
        call    ((.monitorToBRAINIAC-L0115_Check2)+levelCheckRAM)
        call    ((.setupBRAINIAC-L0115_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_detectIntruder_gtx
        WAITDIALOG STATE_DETECT2
        ld      a,1
        ret

.checkDetect2
        ld      a,[levelVars + VAR_SPEAKINGHERO]
        ld      c,a
        DIALOGBOTTOM bs_segashuating_gtx
        WAITDIALOG STATE_DETECT3
        ret

.checkDetect3
        call    ((.setupBRAINIAC-L0115_Check2)+levelCheckRAM)
        DIALOGTOP brainiac_bringIt_gtx
        call    MakeNonIdle
        WAITDIALOG STATE_MONITOR1
        ret

.checkPaintRoom
        ldio    a,[mapState]
        cp      STATE_PRESTO
        ret     z

        xor     a
        ld      hl,((.checkPaintRoom_hero-L0115_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkPaintRoom_hero
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      PAINTZONE
        ld      a,0
        ret     nz

        ;only if hero's attack delay is zero
        call    GetAttackDelay
        or      a
        ld      a,0
        ret     nz

        ;possible for costume?
        ld      a,[levelVars + VAR_GRUNT_TILE]
        inc     a
        ret     z    ;returns if $ff (no tile)

        ;already talked about costume?
        ld      a,c
        ld      [levelVars + VAR_COSTUME_HERO],a
        ld      a,[levelVars + VAR_COSTUME_DIALOG]
        or      a
        jr      nz,.checkPresto

        call    SetSpeakerFromHeroIndex

        ld      de,((.skipCostume-L0115_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle
        DIALOGBOTTOM bs_idea_gtx
        WAITDIALOGNOCLEAR STATE_PRESTO

        ld      a,1
        ret

.checkPresto
        call    ((.useCostume-L0115_Check2)+levelCheckRAM)

        ld      a,[levelVars + VAR_COSTUME_DIALOG]
        or      a
        ret     nz

        ld      a,[levelVars + VAR_COSTUME_HERO]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        call    ((.clearSkipAfterDialog-L0115_Check2)+levelCheckRAM)
        DIALOGBOTTOM bs_presto_gtx
        call    MakeNonIdle
        WAITDIALOG STATE_MONITOR1
        ld      a,1
        ld      [levelVars + VAR_COSTUME_DIALOG],a
        ret

.checkHangin
        ld      a,[levelVars + VAR_HANGIN_DIALOG]
        or      a
        ret     nz

        ;jr      z,.okayToHang
        ;ld      a,STATE_MONITOR1
        ;ldio    [mapState],a
        ;ret
;.okayToHang
        ld      a,1
        ld      hl,((.checkHangin_hero-L0115_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkHangin_hero
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      HANGINZONE1
        jr      z,.checkCostume
        cp      HANGINZONE2
        ld      a,0
        ret     nz

.checkCostume
        call    SetSpeakerFromHeroIndex
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      h,((fgTileMap>>8) & $ff)
        ld      l,c
        ld      a,[levelVars + VAR_GRUNT_TILE]
        cp      [hl]
        ld      a,0
        ret     nz   ;not in costume!

        ;make sure there's some grunts to talk to
        push    bc
        push    de
        ld      c,GRUNTINDEX
        call    GetFirst
        pop     de
        pop     bc
        or      a
        ret     z     ;no grunts

        ld      a,1
        ld      [levelVars + VAR_HANGIN_DIALOG],a
        ld      de,((.skipHangin-L0115_Check2)+levelCheckRAM)
        call    SetDialogSkip
        call    MakeIdle
        ld      a,c
        ld      [levelVars + VAR_SPEAKINGHERO],a
        call    SetSpeakerFromHeroIndex
        DIALOGBOTTOM bs_hangin1_gtx
        WAITDIALOG STATE_HANGIN2
        ld      a,1
        ret

.checkHangin2
        ld      c,GRUNTINDEX
        DIALOGTOP  grunt_hangin2_gtx
        WAITDIALOG STATE_HANGIN3
        ret

.checkHangin3
        ld      a,[levelVars + VAR_SPEAKINGHERO]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        DIALOGBOTTOM bs_hangin3_gtx
        WAITDIALOG STATE_HANGIN4
        ret

.checkHangin4
        ld      c,GRUNTINDEX
        DIALOGTOP  grunt_hangin4_gtx
        WAITDIALOG STATE_HANGIN5
        ret

.checkHangin5
        call    ((.clearSkipAfterDialog-L0115_Check2)+levelCheckRAM)
        call    MakeNonIdle
        ld      a,[levelVars + VAR_SPEAKINGHERO]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        DIALOGBOTTOM bs_hangin5_gtx
        WAITDIALOG STATE_MONITOR1
        ret

.checkMonitor1
        ld      a,1
        ld      hl,((.checkMonitor1_hero-L0115_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkMonitor1_hero
        or      a
        ret     z

        ld      c,a
        ;hero in costume?
        call    GetFGMapping
        ld      hl,levelVars + VAR_GRUNT_TILE
        cp      [hl]
        ld      a,0
        ret     nz            ;not yet!

        call    GetFirst
        call    GetCurZone
        cp      MONITORZONE
        ld      a,0
        ret     nz

        call    SetSpeakerFromHeroIndex
        call    MakeIdle
        ld      a,1   ;make sure the warning won't happen
        ld      [levelVars + VAR_MONITOR_WARNING],a
        ld      c,GUARDINDEX
        DIALOGTOP  monitor_openDoor_gtx
        WAITDIALOG STATE_WAIT_ALLBRAINIAC
        ld      a,MAPBANK
        ldio    [$ff70],a

        ;open the outer door
        xor     a
        ld      hl,$d049
        ld      [hl+],a
        ld      [hl],a

        ld      de,((.skipMonitor-L0115_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,1
        ret

.checkWaitAllBRAINIAC
        ld      a,[levelVars + VAR_NUMMONITORS]
        or      a
        jr      z,.brainiacTalks

        ;animate monitors from normal to static to BRAINIAC
        dec     a                     ;pick a monitor at random
        call    GetRandomNumZeroToN
        inc     a
        ld      c,a
        ld      de,0
        ld      hl,levelVars + VAR_MONITORS

        ;find monitor state data
.findActiveMonitor
        ld      a,[hl+]
        inc     e
        cp      5
        jr      nc,.findActiveMonitor  ;skip if this one finished
        dec     c
        jr      nz,.findActiveMonitor
        dec     hl
        dec     e
        inc     [hl]
        inc     a
        ld      c,a          ;save monitor state
        sla     e            ;de *= 2   (offset)
        rl      d
        ld      hl,((.monitorLocations-L0115_Check2)+levelCheckRAM)
        add     hl,de        ;hl = monitor location table
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a          ;hl is monitor location
        ld      a,c
        cp      5
        jr      nc,.changeToFace

        ;change to static
        call    ((.monitorToStatic-L0115_Check2)+levelCheckRAM)
        ret

.changeToFace
        call    ((.monitorToBRAINIAC-L0115_Check2)+levelCheckRAM)
        ld      hl,levelVars + VAR_NUMMONITORS
        dec     [hl]
        ret

.brainiacTalks
        call    ((.setupBRAINIAC-L0115_Check2)+levelCheckRAM)
        DIALOGTOP  brainiac_wait_gtx
        WAITDIALOG STATE_MONITOR2
        ret

.resetHero
        or      a
        ret     z
        ld      c,a
        call    GetFirst
        ld      a,10
        call    SetAttackDelay
        ld      b,METHOD_DRAW
        call    CallMethod
        ret

.checkMonitor2
        call    ((.openSecurityDoor-L0115_Check2)+levelCheckRAM)

        ld         c,GUARDINDEX
        DIALOGTOP  monitor_sorry_gtx
        WAITDIALOGNOCLEAR STATE_MONITOR3
        ret

.checkMonitor3
        call    ((.setupBRAINIAC-L0115_Check2)+levelCheckRAM)
        DIALOGTOP  brainiac_justClose_gtx
        WAITDIALOGNOCLEAR STATE_MONITOR4
        ret

.checkMonitor4
        ld         c,GUARDINDEX
        DIALOGTOP  monitor_oneSecond_gtx
        WAITDIALOGNOCLEAR STATE_MONITOR5
        ret

.checkMonitor5
        call    ((.setupBRAINIAC-L0115_Check2)+levelCheckRAM)
        set     DLG_CLEARSKIP_BIT,[hl]
        DIALOGTOP  brainiac_idiotz_gtx
        call       MakeNonIdle
        WAITDIALOG STATE_NORMAL
        ret

.checkNormal
        ret

.checkWaitDialog
        STDWAITDIALOG
        ret

;----support routines-------------------------------------------------
.clearSkipAfterDialog
        ld      hl,dialogSettings
        set     DLG_CLEARSKIP_BIT,[hl]
        ret

.skipDetect
        call    ClearDialog
        call    MakeNonIdle
        ld      hl,$d85d
        call    ((.monitorToBRAINIAC-L0115_Check2)+levelCheckRAM)
        ld      a,STATE_MONITOR1
        ldio    [mapState],a
        ld      a,1
        ret

.useCostume
        ld      a,[levelVars + VAR_COSTUME_HERO]
        ld      c,a
        ld      a,[levelVars + VAR_GRUNT_TILE] ;use the grunt's tile
        call    SetFGMapping

        call    GetFirst
        ld      a,0
        call    SetAttackDelay
        ld      b,METHOD_DRAW
        call    CallMethod
        ld      a,GROUP_MONSTERA    ;hero is one of the boys now
        call    SetGroup
        ret

.skipCostume
        call    ClearDialog
        call    MakeNonIdle
        call    ((.useCostume-L0115_Check2)+levelCheckRAM)
        ld      a,1
        ld      [levelVars + VAR_COSTUME_DIALOG],a
        ld      a,STATE_MONITOR1
        ldio    [mapState],a
        ret

.skipHangin
        call    ClearDialog
        call    MakeNonIdle
        ld      a,STATE_MONITOR1
        ldio    [mapState],a
        ret

.skipMonitor
        call    ClearDialog
        call    MakeNonIdle
        ld      a,STATE_NORMAL
        ldio    [mapState],a

        call    ((.openSecurityDoor-L0115_Check2)+levelCheckRAM)
        
        ;set all monitors to brainiac
        ld      c,20
        ld      hl,((.monitorLocations-L0115_Check2)+levelCheckRAM)
.setAllMonitorsLoop
        ld      a,[hl+]
        push    hl
        ld      h,[hl]
        ld      l,a
        call    ((.monitorToBRAINIAC-L0115_Check2)+levelCheckRAM)
        pop     hl
        inc     hl
        dec     c
        jr      nz,.setAllMonitorsLoop
        ret

.openSecurityDoor
        ld      a,[hero0_index]
        call    ((.resetHero-L0115_Check2)+levelCheckRAM)
        ld      a,[hero1_index]
        call    ((.resetHero-L0115_Check2)+levelCheckRAM)
        call    ((.checkBSAttack-L0115_Check2)+levelCheckRAM)

        ;open the security door
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d189
        ld      [hl+],a
        ld      [hl],a

        ;ld      a,$ff
        ;ld      [levelVars + VAR_GRUNT_TILE],a  ;no more changing

        ret

.setupBRAINIAC
        ld      hl,dialogSettings
        set     DLG_BRAINIAC_BIT,[hl]
        ld      c,BRAINIACINDEX
        ret

.checkMonitorWarn
        ld      a,[levelVars + VAR_MONITOR_WARNING]
        or      a
        ret     nz

        ld      a,1
        ld      hl,((.checkMonitorWarn_hero-L0115_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkMonitorWarn_hero
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      MONITORZONE
        ld      a,0
        ret     nz

        ;no warning if I'm in crouton disguise
        call    GetFGMapping
        ld      hl,levelVars + VAR_GRUNT_TILE
        cp      [hl]
        ld      a,0
        ret     z 

        ld      a,1
        ld      [levelVars + VAR_MONITOR_WARNING],a

        ld      de,((.skipMonitorWarn-L0115_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    ((.clearSkipAfterDialog-L0115_Check2)+levelCheckRAM)
        ld      c,GUARDINDEX
        DIALOGTOP monitor_onlyCroutons_gtx
        WAITDIALOG STATE_MONITOR1
        ld      a,1
        ret

.skipMonitorWarn
        call    ClearDialog
        call    MakeNonIdle
        ld      a,STATE_MONITOR1
        ldio    [mapState],a
        ret

.monitorLocations
        DW      $d082
        DW      $d084
        DW      $d086
        DW      $d08c
        DW      $d08e
        DW      $d090
        DW      $d102
        DW      $d182
        DW      $d202
        DW      $d282
        DW      $d110
        DW      $d190
        DW      $d210
        DW      $d290
        DW      $d302
        DW      $d304
        DW      $d306
        DW      $d30c
        DW      $d30e
        DW      $d310    ;20 total (does not include entrance)

.adjustCameraInMonitorRoom
        call    GetMyHero
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      7
        jr      z,.adjustCamera
        cp      9
        ret     nz
.adjustCamera
        ld      a,1
        ld      [camera_i],a
        ld      [camera_j],a
        ret

.monitorToStatic
        push    bc
        push    de
        push    hl

        ;push    hl
        ;ld      hl,((.staticSound-L0115_Check2)+levelCheckRAM)
        ;call    PlaySound
        ;pop     hl

        ld      de,$2901
        jr      .monitorCommon

.monitorToBRAINIAC
        push    bc
        push    de
        push    hl

        ld      de,$2903

.monitorCommon
        call    ConvertLocHLToXY
        push    de
        push    hl
        pop     de
        pop     hl
        ld      bc,$0202
        call    BlitMap

        pop     hl
        pop     de
        pop     bc
        ret

.animateStatic
        ld      a,[levelVars+VAR_STATIC]
        ld      b,a
        ldio    a,[updateTimer]
        rrca
        and     %00000010
        add     b
        ld      hl,bgTileMap+STATICINDEX
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ret

.checkBSAttack
        ;sets BS's group back to hero and get rid of his disguise 
        ;if he attacks
        ld      a,[hero0_index]
        call    ((.groupToHero-L0115_Check2)+levelCheckRAM)
        ld      a,[hero1_index]
        call    ((.groupToHero-L0115_Check2)+levelCheckRAM)
        ret

.groupToHero
        or      a
        ret     z

        ld      c,a
        call    GetFirst
        call    GetAttackDelay
        or      a
        ret     z

        ;have a copy of BS's original tile?
        ld      a,[levelVars + VAR_BS_TILE]
        cp      $ff
        ret     z

       
        ld      a,[levelVars + VAR_BS_TILE]
        call    SetFGMapping

        ld      b,METHOD_DRAW
        call    CallMethod

        ld      a,GROUP_HERO
        call    SetGroup
        ld      a,TILEINDEXBANK
        ret

;.staticSound
        ;DB      4,$00,$f0,$20,$c0

L0115_CheckFinished:
PRINTT "0115 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0115_LoadFinished - L0115_Load2)
PRINTT " / "
PRINTV (L0115_InitFinished - L0115_Init2)
PRINTT " / "
PRINTV (L0115_CheckFinished - L0115_Check2)
PRINTT "\n"

