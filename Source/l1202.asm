; l1202.asm dropship leaving triumph
; Generated 07.30.2000 by mlevel
; Modified  07.30.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

STATE_BASHUTTLE     EQU 1
STATE_SKIPPYSHUTTLE EQU 2

;---------------------------------------------------------------------
SECTION "Level1202Section",DATA
;---------------------------------------------------------------------

L1202_Contents::
  DW L1202_Load
  DW L1202_Init
  DW L1202_Check
  DW L1202_Map

triumphBIG_bg::
  INCBIN "..\\fgbpix\\main_intro\\triumphBIG.bg"

dropship_tiny_sp:
  INCBIN "..\\fgbpix\\main_intro\\dropship_tiny.sp"

nar_skippyshuttle_bg:
  INCBIN "..\\fgbpix\\main_intro\\nar_skippyshuttle.bg"

dialog:
blank_gtx:
  INCBIN "gtx\\main_intro\\blank.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1202_Load:
        DW ((L1202_LoadFinished - L1202_Load2))  ;size

L1202_Load2:
        ld      a,STATE_BASHUTTLE
        ldio    [mapState],a

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$2d]    ;gyro catches BA
        or      a
        jr      z,.afterSkippyShuttle
        ld      a,STATE_SKIPPYSHUTTLE
        ldio    [mapState],a
.afterSkippyShuttle

        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ;ldio    a,[mapState]
        ;or      a
        ;jr      nz,.afterState0

        ;ld      a,BANK(moon_base_ba_gbm)
        ;ld      hl,moon_base_ba_gbm
        ;call    InitMusic

.afterState0
        ld      a,BANK(triumphBIG_bg)
        ld      hl,triumphBIG_bg
        call    LoadCinemaBG

        ld      a,BANK(dropship_tiny_sp)
        ld      hl,dropship_tiny_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        ld      a,BANK(nar_skippyshuttle_bg)
        ld      hl,nar_skippyshuttle_bg
        call    LoadCinemaTextBox

        ld      a,1
        call    Delay

        ld      d,72
        call    ScrollSpritesRight
        ld      d,74
        call    ScrollSpritesDown

        ld      b,%10000000
        call    ((.setSpritePriority-L1202_Load2)+levelCheckRAM)

        ld      a,1
        call    Delay

        ld      a,16
        call    SetupFadeFromStandard
        call    WaitFade

        ldio    a,[mapState]
        cp      STATE_SKIPPYSHUTTLE
        jr      nc,.describe_skippy

        ld      a,BANK(blank_gtx)
        ld      c,0
        ld      de,blank_gtx
        call    ShowDialogAtBottomNoWait
        jr      .afterSetupTextBox

.describe_skippy
        call    GfxShowStandardTextBox

.afterSetupTextBox
        ld      a,1
        call    Delay

        ;blit the full image from the offscreen buffer now that the
        ;bottom is obscured by the text box
        ld      bc,$1424
        ld      de,$0000
        ld      hl,$1400
        call    CinemaBlitRect

        ld      a,$22
        ldio    [scrollSpeed],a

        ;start the screen scrolling down
        ld      a,28
        ld      [camera_j],a

.afterShowSkippyShuttle

        ld      de,((.endCinema - L1202_Load2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.endCinema - L1202_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      c,80 + 144
.scrollDropshipLoop
        ld      d,1
        call    ScrollSpritesDown
        ld      a,1
        call    Delay
        ld      a,c

        cp      80
        jr      nz,.stillScrolling
        ldio    a,[mapState]
        cp      STATE_SKIPPYSHUTTLE
        jr      nc,.stillScrolling
        call    ClearDialog
.stillScrolling

        dec     c
        jr      nz,.scrollDropshipLoop

.endCinema
        ld      hl,$0013
        ld      de,$0013   ;respawn map
        ldio    a,[mapState]
        cp      STATE_SKIPPYSHUTTLE
        jr      nz,.afterChooseNextLevel

        ld      hl,$0215
        ld      de,$0014   ;respawn map
.afterChooseNextLevel

        call    ClearDialog

        ld      a,e
        ld      [respawnMap],a
        ld      a,d
        ld      [respawnMap+1],a

        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a
        cp      STATE_SKIPPYSHUTTLE
        ldio    [mapState],a

        ld      a,1
        ld      [timeToChangeLevel],a

        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ret

.setSpritePriority
        ;set the priority flag for the first 8 sprites
        ld      hl,spriteOAMBuffer+3
        ld      de,4
        ld      c,8
.setPriorityLoop
        ld      a,[hl]
        and     %01111111
        or      b
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.setPriorityLoop
        ret

L1202_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1202_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1202_Init:
        DW ((L1202_InitFinished - L1202_Init2))  ;size
L1202_Init2:
        ret

L1202_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1202_Check:
        DW ((L1202_CheckFinished - L1202_Check2))  ;size
L1202_Check2:
        ret

L1202_CheckFinished:
PRINTT "1202 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1202_LoadFinished - L1202_Load2)
PRINTT " / "
PRINTV (L1202_InitFinished - L1202_Init2)
PRINTT " / "
PRINTV (L1202_CheckFinished - L1202_Check2)
PRINTT "\n"

