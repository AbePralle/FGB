; L0612.asm crouton teleport chamber
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"

DICEINDEX     EQU 31
VAR_DICELIGHT EQU 0
VAR_TENS      EQU 1
VAR_ONES      EQU 2
VAR_COUNT     EQU 3
VAR_VBLANKS   EQU 4

STATE_NOP          EQU 1
STATE_TALKPLAN     EQU 2
STATE_TALKCONTROLS EQU 3
STATE_NOCLEARANCE  EQU 4
STATE_COUNTDOWN    EQU 5
STATE_DUKE         EQU 6
STATE_RETURNINIT   EQU 7
STATE_RETURNTALK   EQU 8
STATE_NORMAL       EQU 9


;---------------------------------------------------------------------
SECTION "Level0612Section",ROMX
;---------------------------------------------------------------------

dialog:
L0612_plan_gtx:
  INCBIN "Data/Dialog/Talk/L0612_plan.gtx"

L0612_clearance_gtx:
  INCBIN "Data/Dialog/Talk/L0612_clearance.gtx"

L0612_controls_gtx:
  INCBIN "Data/Dialog/Talk/L0612_controls.gtx"

L0612_go_gtx:
  INCBIN "Data/Dialog/Talk/L0612_go.gtx"

L0612_duke_gtx:
  INCBIN "Data/Dialog/Talk/L0612_duke.gtx"

L0612_return_gtx:
  INCBIN "Data/Dialog/Talk/L0612_return.gtx"

L0612_Contents::
  DW L0612_Load
  DW L0612_Init
  DW L0612_Check
  DW L0612_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0612_Load:
        DW ((L0612_LoadFinished - L0612_Load2))  ;size
L0612_Load2:
        call    ParseMap

        ;make sure $ff is a blank sprite tile
        PUSHROM
        ld      a,BANK(BGTiles1024)
        call    SetActiveROM
        ld      a,0
        ld      c,1
        ld      de,$8ff0
        ld      hl,BGTiles1024
        call    VMemCopy
        POPROM
        ret

L0612_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0612_Map:
INCBIN "Data/Levels/L0612_teleport.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0612_Init:
        DW ((L0612_InitFinished - L0612_Init2))  ;size
L0612_Init2:
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$cf]   ;been to generators?
        or      a
        jr      nz,.afterReset    ;blown up 

        ld      a,STATE_NOP
        ldio    [mapState],a

.afterReset
        STDSETUPDIALOG

        ld      hl,$1100
        call    SetJoinMap
        call    SetRespawnMap

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic

        ld      a,[bgTileMap+DICEINDEX]  ;tile index of first light
        ld      [levelVars+VAR_DICELIGHT],a

        ld      a,ENV_COUNTER
        ld      [envEffectType],a

        ld      a,$ff
        ld      [levelVars+VAR_COUNT],a
        xor     a
        ld      [levelVars+VAR_VBLANKS],a

        ;allocate and position two sprites for the timer countdown
        ;set them to $ff (blank sprite tile)
        call    ((.alloc-L0612_Init2)+levelCheckRAM)
        ld      [levelVars+VAR_TENS],a
        call    ((.alloc-L0612_Init2)+levelCheckRAM)
        ld      [levelVars+VAR_ONES],a
        inc     hl
        ld      [hl],88    ;different xpos for second

        ;delete hulk, grunt, goblin, and artillery
        ld      bc,classCroutonGrunt
        call    DeleteObjectsOfClass
        ld      bc,classCroutonHulk
        call    DeleteObjectsOfClass
        ld      bc,classCroutonArtillery
        call    DeleteObjectsOfClass
        ld      bc,classCroutonGoblin
        call    DeleteObjectsOfClass

        ret

.alloc
        call    AllocateSprite
        ld      l,a
        ld      h,((spriteOAMBuffer>>8)&$ff)
        push    hl
        ld      [hl],16
        inc     hl
        ld      [hl],80
        inc     hl
        ld      [hl],$ff
        inc     hl
        ld      [hl],0
        pop     hl
        ld      a,l
        ret

L0612_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0612_Check:
        DW ((L0612_CheckFinished - L0612_Check2))  ;size
L0612_Check2:
        call    ((.animateDiceLights-L0612_Check2)+levelCheckRAM)
        call    ((.generateCube-L0612_Check2)+levelCheckRAM)
        call    ((.displayCount-L0612_Check2)+levelCheckRAM)
        ld      hl,((.vectorToStateTable-L0612_Check2)+levelCheckRAM)
        VECTORTOSTATE ((.vectorToStateTable-L0612_Check2)+levelCheckRAM)
        ret

.vectorToStateTable
  DW ((.stateNOP-L0612_Check2)+levelCheckRAM)
  DW ((.stateNOP-L0612_Check2)+levelCheckRAM)
  DW ((.stateTalkPlan-L0612_Check2)+levelCheckRAM)
  DW ((.stateTalkControls-L0612_Check2)+levelCheckRAM)
  DW ((.stateNoClearance-L0612_Check2)+levelCheckRAM)
  DW ((.stateCountdown-L0612_Check2)+levelCheckRAM)
  DW ((.stateDuke-L0612_Check2)+levelCheckRAM)
  DW ((.stateReturnInit-L0612_Check2)+levelCheckRAM)
  DW ((.stateReturnTalk-L0612_Check2)+levelCheckRAM)
  DW ((.stateNormal-L0612_Check2)+levelCheckRAM)

.stateNOP
        ld      a,STATE_TALKPLAN
        ldio    [mapState],a
        ret

.stateTalkPlan
        call    MakeIdle
        ld      de,((.afterTalkPlanDialog-L0612_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        ld      de,L0612_plan_gtx
        call    ShowDialogAtBottom

.afterTalkPlanDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle
        ld      a,STATE_TALKCONTROLS
        ldio    [mapState],a
        ret

.stateTalkControls
        ld      a,1
        ld      hl,((.checkAtControls-L0612_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkAtControls
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      3
        jr      z,.atControls

        xor     a
        ret

.atControls
        push    bc
        ld      bc,ITEM_ZETACLEAR
        call    HasInventoryItem
        pop     bc
        jr      z,.needClearance

        call    SetSpeakerFromHeroIndex
        call    MakeIdle
        ld      de,((.afterControlsDialog-L0612_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      de,L0612_controls_gtx
        call    ShowDialogAtBottom

.afterControlsDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,90
        ld      [levelVars+VAR_COUNT],a
        ld      a,STATE_COUNTDOWN
        ldio    [mapState],a
        ld      a,1
        ret

.needClearance
        call    MakeIdle
        ld      de,((.afterClearanceDialog-L0612_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        ld      de,L0612_clearance_gtx
        call    ShowDialogAtBottom

.afterClearanceDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,STATE_NOCLEARANCE
        ldio    [mapState],a
        ld      a,1
        ret

.stateNoClearance
        ret

.stateCountdown
        ld      hl,levelVars+VAR_VBLANKS
        inc     [hl]
        ld      a,[hl]
        cp      30
        ret     c

        ld      [hl],0
        ld      hl,levelVars+VAR_COUNT
        dec     [hl]
        ret     nz

        ld      a,STATE_DUKE
        ldio    [mapState],a
        ret
        
.stateDuke
        ld      a,1
        ld      hl,((.checkAtStation-L0612_Check2)+levelCheckRAM)
        jp      CheckEachHero

.checkAtStation
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.atStation

        xor     a
        ret

.atStation
        call    MakeIdle

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      de,((.afterGoDialog-L0612_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,L0612_go_gtx
        call    ShowDialogAtBottom

.afterGoDialog

        ld      c,7
.flicker
        ld      a,c
        rlca
        ld      b,15
        call    SetupFadeFromSaturated
        call    WaitFade

        ld      a,c
        rlca
        call    Delay

        dec     c
        jr      nz,.flicker

        ld      a,BANK(jungle_gbm)
        ld      hl,jungle_gbm
        call    InitMusic

        xor     a
        ld      [camera_i],a
        ld      [camera_j],a

        ld      de,L0612_duke_gtx
        call    ShowDialogAtBottom

        ld      c,7
.flicker2
        ld      a,c
        rlca
        ld      b,15
        call    SetupFadeFromSaturated
        call    WaitFade

        ld      a,c
        rlca
        call    Delay

        dec     c
        jr      nz,.flicker2

.afterDukeDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$0912
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a

        ld      a,STATE_RETURNINIT
        ldio    [mapState],a

        ld      a,EXIT_D
        call    YankRemotePlayer

        ld      a,1
        ld      [timeToChangeLevel],a

        ld      a,1
        ret

.stateReturnInit
        ld      a,STATE_RETURNTALK
        ldio    [mapState],a
        ret

.stateReturnTalk
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$cf]    ;homeworld 4
        or      a
        jr      nz,.talk

        ld      a,STATE_RETURNINIT
        ldio    [mapState],a
        ret

.talk
        call    MakeIdle
        ld      de,((.afterReturnDialog-L0612_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        ld      de,L0612_return_gtx
        call    ShowDialogAtBottom

.afterReturnDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle
        ld      a,STATE_NORMAL
        ldio    [mapState],a
        ret

.stateNormal
        ret

.displayCount
        ld      a,[levelVars+VAR_COUNT]
        cp      100
        ret     nc      ;don't display values >= 100

        ;tens = count / 10
        ld      b,a
        ld      c,0
.getDiv
        cp      10
        jr      c,.gotDiv
        sub     10
        inc     c
        jr      .getDiv

.gotDiv
        add     200
        ld      hl,spriteOAMBuffer+4+2
        ld      [hl],a   ;ones digit
        ld      a,c
        add     200
        ld      hl,spriteOAMBuffer+2
        ld      [hl],a   ;tens digit
        ret

.generateCube
        ldio    a,[mapState]
        cp      STATE_RETURNINIT
        ret     nc

        ;make a cube every so often
        ldio    a,[updateTimer]
        and     63
        ret     nz

        ;pick one of 12 positions from the table
        ;ld      a,3
        ;call    GetRandomNumMask
        ;ld      b,a
        ;rlca
        ;add     b
        ld      a,11
        call    GetRandomNumZeroToN
        ld      hl,((.cubeAppearTable-L0612_Check2)+levelCheckRAM)
        ld      b,a
        call    Lookup16

        ;make sure it's clear
        push    hl
        call    ((.isOccupied2x2-L0612_Check2)+levelCheckRAM)
        pop     hl
        jr      z,.go

        ld      a,b
        inc     a
        cp      12
        jr      c,.aokay
        xor     a
.aokay
        ld      b,a
        ld      hl,((.cubeAppearTable-L0612_Check2)+levelCheckRAM)
        call    Lookup16

        push    hl
        call    ((.isOccupied2x2-L0612_Check2)+levelCheckRAM)
        pop     hl
        jr      z,.go

        ld      a,b
        inc     a
        cp      12
        jr      c,.aokay2
        xor     a
.aokay2
        ld      b,a
        ld      hl,((.cubeAppearTable-L0612_Check2)+levelCheckRAM)
        call    Lookup16

        push    hl
        call    ((.isOccupied2x2-L0612_Check2)+levelCheckRAM)
        pop     hl
        ret     nz

.go
        ld      bc,classTeleportCube
        call    FindClassIndex
        ret     z
        ld      c,a
        call    CreateInitAndDrawObject
        ret

.isOccupied2x2
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl+]
        or      a
        ret     nz

        ld      a,[hl-]
        or      a
        ret     nz

        ld      a,[mapPitch]
        ld      e,a
        ld      d,0
        push    de
        add     hl,de
        pop     de
        ld      a,[hl+]
        or      a
        ret     nz

        ld      a,[hl]
        or      a
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
        call    ((.updateTwoLights - L0612_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L0612_Check2) + levelCheckRAM)
        ret

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L0612_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret

.cubeAppearTable
  DW $d1a3, $d223, $d2a3, $d323, $d3a3, $d423
  DW $d1b1, $d231, $d2b1, $d331, $d3b1, $d431
;$d1a3
  ;$d223
  ;$d2a3
;$d323
  ;$d3a3
  ;$d423
;$d1b1
  ;$d231
  ;$d2b1
;$d331
  ;$d3b1
  ;$d431


L0612_CheckFinished:
PRINT "0612 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0612_LoadFinished - L0612_Load2)
PRINT " / "
PRINT (L0612_InitFinished - L0612_Init2)
PRINT " / "
PRINT (L0612_CheckFinished - L0612_Check2)
PRINT "\n"

