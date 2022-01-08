; L0015.asm
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"


;---------------------------------------------------------------------
SECTION "Level0015Section",ROMX
;---------------------------------------------------------------------

L0015_Contents::
  DW L0015_Load
  DW L0015_Init
  DW L0015_Check
  DW L0015_Map


dialog:
soldier_how_gtx:
  INCBIN "Data/Dialog/IntroBS/soldier_how.gtx"

bs_likeButter_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_likeButter.gtx"

soldier_yellow_gtx:
  INCBIN "Data/Dialog/IntroBS/soldier_yellow.gtx"

bs_slippery_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_slippery.gtx"

guard_freeze_gtx:
  INCBIN "Data/Dialog/IntroBS/guard_freeze.gtx"

bs_actually_gtx:
  INCBIN "Data/Dialog/IntroBS/bs_actually.gtx"

guard_moveAlong_gtx:
  INCBIN "Data/Dialog/IntroBS/guard_moveAlong.gtx"


;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0015_Load:
        DW ((L0015_LoadFinished - L0015_Load2))  ;size
L0015_Load2:
        call    ParseMap
        ret

L0015_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0015_Map:
INCBIN "Data/Levels/L0015_intro_bs1.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
VAR_RADAR        EQU  0
VAR_SPEAKINGHERO EQU  1

RADARINDEX      EQU 52
GRUNTINDEX      EQU 87
B12SOLDIERINDEX EQU 88

STATE_INITIALDRAW  EQU 0
STATE_TALKSOLDIER1 EQU 1
STATE_TALKSOLDIER2 EQU 2
STATE_TALKSOLDIER3 EQU 3
STATE_TALKSOLDIER4 EQU 4
STATE_TALKGUARD1   EQU 5
STATE_TALKGUARD2   EQU 6
STATE_TALKGUARD3   EQU 7
STATE_NORMAL       EQU 8
STATE_WAIT_DIALOG  EQU 9

L0015_Init:
        DW ((L0015_InitFinished - L0015_Init2))  ;size
L0015_Init2:
        ld      hl,$0015
        call    SetJoinMap

        ld      hl,$0015
        call    SetRespawnMap

        ld      a,BANK(bs_gbm)
        ld      hl,bs_gbm
        call    InitMusic

        call    SetPressBDialog
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,[bgTileMap+RADARINDEX]
        ld      [levelVars+VAR_RADAR],a

        ld      bc,classB12Soldier
        ld      de,classDoNothing
        call    ChangeClass

        ld      bc,classCroutonGrunt
        ld      de,classDoNothing
        call    ChangeClass
        ret

L0015_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0015_Check:
        DW ((L0015_CheckFinished - L0015_Check2))  ;size
L0015_Check2:
        call    ((.animateRadar-L0015_Check2)+levelCheckRAM)

        ldio    a,[mapState]
        cp      STATE_NORMAL
        jr      nz,.checkInitialDraw

        ret

.checkInitialDraw
        cp      STATE_INITIALDRAW
        jr      nz,.checkTalkSoldier1

        ld      a,STATE_TALKSOLDIER1
        ldio    [mapState],a
        ret

.checkTalkSoldier1
        cp      STATE_TALKSOLDIER1
        jr      nz,.checkTalkSoldier2

        call    SetSpeakerToFirstHero

        ld      de,soldier_how_gtx
        ld      c,B12SOLDIERINDEX
        call    ShowDialogAtTopNoWait

        ld      de,((.endTalkSoldier-L0015_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_TALKSOLDIER2
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a
        ret

.checkTalkSoldier2
        cp      STATE_TALKSOLDIER2
        jr      nz,.checkTalkSoldier3

        call    SetSpeakerToFirstHero
        ld      de,bs_likeButter_gtx
        call    ShowDialogAtBottomNoWait

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_TALKSOLDIER3
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a
        ret

.checkTalkSoldier3
        cp      STATE_TALKSOLDIER3
        jr      nz,.checkTalkSoldier4

        ld      de,soldier_yellow_gtx
        ld      c,B12SOLDIERINDEX
        call    ShowDialogAtTopNoWait

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_TALKSOLDIER4
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a
        ret

.checkTalkSoldier4
        cp      STATE_TALKSOLDIER4
        jr      nz,.checkTalkGuard1

        call    SetSpeakerToFirstHero
        ld      de,bs_slippery_gtx
        call    ShowDialogAtBottomNoWait

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_TALKGUARD1
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a
        ret

.endTalkSoldier
        xor     a
        ld      [heroesIdle],a
        ld      [allIdle],a
        ld      de,0
        call    SetDialogSkip
        call    ClearDialog
        ld      a,STATE_TALKGUARD1
        ldio    [mapState],a
        ret

.checkTalkGuard1
        cp      STATE_TALKGUARD1
        jr      nz,.checkTalkGuard2

        ld      a,[hero0_index]
        call    ((.checkHeroTalkToGuard-L0015_Check2)+levelCheckRAM)
        ld      a,[hero1_index]
        call    ((.checkHeroTalkToGuard-L0015_Check2)+levelCheckRAM)
        ret

.checkTalkGuard2
        cp      STATE_TALKGUARD2
        jr      nz,.checkTalkGuard3

        ld      a,[levelVars + VAR_SPEAKINGHERO]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        ld      de,bs_actually_gtx
        call    ShowDialogAtBottomNoWait

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_TALKGUARD3
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a

        ret

.checkTalkGuard3
        cp      STATE_TALKGUARD3
        jr      nz,.checkWaitDialog

        ld      c,GRUNTINDEX
        ld      de,guard_moveAlong_gtx
        call    ShowDialogAtTopNoWait

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_NORMAL
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a

        ret

.endTalkGuard
        ld      de,0
        call    SetDialogSkip
        xor     a
        ld      [heroesIdle],a
        ld      [allIdle],a
        call    ClearDialog
        ld      a,STATE_NORMAL
        ldio    [mapState],a
        ret

.checkWaitDialog
        call    CheckDialogContinue
        or      a
        ret     z

        xor     a
        ld      [heroesIdle],a

        ldio    a,[mapState+1]
        ldio    [mapState],a
        ret

        ret

.animateRadar
        ;animate the radar tower (index 47-52) based on timer/8
        ldio    a,[updateTimer]
        rrca                    ;(t/8)*6 == t/4*3
        and     %00000110
        ld      b,a
        add     b
        add     b
        ld      b,a
        ld      a,[levelVars+VAR_RADAR]
        add     b

        ld      hl,bgTileMap + RADARINDEX
        ld      c,6
.animateTower
        ld      [hl+],a
        inc     a
        dec     c
        jr      nz,.animateTower
        ret

.checkHeroTalkToGuard
        or      a
        ret     z
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        ret     nz

        ld      a,c
        ld      [levelVars + VAR_SPEAKINGHERO],a
        call    SetSpeakerFromHeroIndex

        ld      de,guard_freeze_gtx
        ld      c,GRUNTINDEX
        call    ShowDialogAtTopNoWait

        pop     bc   ;adjust stack pos for dialog skip
        ld      de,((.endTalkGuard-L0015_Check2)+levelCheckRAM)
        call    SetDialogSkip
        push    bc

        ld      a,1
        ld      [heroesIdle],a
        ld      a,STATE_TALKGUARD2
        ldio    [mapState+1],a
        ld      a,STATE_WAIT_DIALOG
        ldio    [mapState],a
        ret

L0015_CheckFinished:
PRINT "0015 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0015_LoadFinished - L0015_Load2)
PRINT " / "
PRINT (L0015_InitFinished - L0015_Init2)
PRINT " / "
PRINT (L0015_CheckFinished - L0015_Check2)
PRINT "\n"

