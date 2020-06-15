; L1102.asm main intro cinema
; Generated 07.26.2000 by mlevel
; Modified  07.26.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

MUSICTEST EQU 0

NEXTLEVEL EQU $0313
;NEXTLEVEL EQU $0013
NEXTLEVELDIR EQU EXIT_D

;---------------------------------------------------------------------
SECTION "Level1102Section2",ROMX
;---------------------------------------------------------------------
flour_bg::
  INCBIN "../fgbpix/MainCharDialog/flour_triumph.bg"
skippy_bg::
  INCBIN "../fgbpix/MainCharDialog/skippy_triumph.bg"

dialog:
flour1_gtx:
  INCBIN "Data/Dialog/Intro/flour1.gtx"

flour2_gtx:
  INCBIN "Data/Dialog/Intro/flour2.gtx"

flour3_gtx:
  INCBIN "Data/Dialog/Intro/flour3.gtx"

flour4_gtx:
  INCBIN "Data/Dialog/Intro/flour4.gtx"

flour5_gtx:
  INCBIN "Data/Dialog/Intro/flour5.gtx"

flour6_gtx:
  INCBIN "Data/Dialog/Intro/flour6.gtx"

flour7_gtx:
  INCBIN "Data/Dialog/Intro/flour7.gtx"

skippy1_gtx:
  INCBIN "Data/Dialog/Intro/skippy1.gtx"

skippy2_gtx:
  INCBIN "Data/Dialog/Intro/skippy2.gtx"

skippy3_gtx:
  INCBIN "Data/Dialog/Intro/skippy3.gtx"

triumph_small_sp:
  INCBIN "../fgbpix/Intro/triumph_small.sp"

bcs_vestigial_bg:
  INCBIN "../fgbpix/Intro/bcs_vestigial.bg"

narrator_warroom_bg:
  INCBIN "../fgbpix/Intro/narrator_warroom.bg"

nar_crewquarters_bg:
  INCBIN "../fgbpix/Intro/nar_crewquarters.bg"

;---------------------------------------------------------------------
SECTION "Level1102Section",ROMX
;---------------------------------------------------------------------

L1102_Contents::
  DW L1102_Load
  DW L1102_Init
  DW L1102_Check
  DW L1102_Map

moon_bg::
  INCBIN "../fgbpix/Intro/moon.bg"
group_in_triumph_bg:
  INCBIN "../fgbpix/Intro/group_in_triumph.bg"
space_bg1_bg:
  INCBIN "../fgbpix/Intro/space_bg1.bg"
moontact_bg::
  INCBIN "../fgbpix/Intro/moontact.bg"
tactmap_bg:
  INCBIN "../fgbpix/Intro/tactmap.bg"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1102_Load:
        DW ((L1102_LoadFinished - L1102_Load2))  ;size
L1102_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

IF MUSICTEST==0
        ld      a,BANK(intro_cinema_gbm)
        ld      hl,intro_cinema_gbm
        call    InitMusic
ENDC

        ld      a,BANK(moon_bg)
        ld      hl,moon_bg
        call    LoadCinemaBG


IF MUSICTEST
ld a,16
call SetupFadeFromStandard
call WaitFade
.repeat
        ld      a,BANK(jungle_gbm)
        ld      hl,jungle_gbm
        call    InitMusic

.getJoy0_5
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy0_5

.releaseJoy0_5
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy0_5

        ld      a,BANK(mysterious_gbm)
        ld      hl,mysterious_gbm
        call    InitMusic

.getJoy0_55
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy0_55

.releaseJoy0_55
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy0_55

        ld      a,BANK(spaceish_gbm)
        ld      hl,spaceish_gbm
        call    InitMusic

.getJoy0_6
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy0_6

.releaseJoy0_6
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy0_6

        ld      a,BANK(alarm_gbm)
        ld      hl,alarm_gbm
        call    InitMusic

.getJoy0_7
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy0_7

.releaseJoy0_7
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy0_7

        ld      a,BANK(frosty_gbm)
        ld      hl,frosty_gbm
        call    InitMusic

.getJoy0_8
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy0_8

.releaseJoy0_8
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy0_8

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic

.getJoy0_9
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy0_9

.releaseJoy0_9
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy0_9

        ld      a,BANK(wedding_gbm)
        ld      hl,wedding_gbm
        call    InitMusic

.getJoy1
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy1

.releaseJoy1
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy1

        ld      a,BANK(intro_cinema_gbm)
        ld      hl,intro_cinema_gbm
        call    InitMusic

.getJoy2
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy2

.releaseJoy2
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy2

        ld      a,BANK(bs_gbm)
        ld      hl,bs_gbm
        call    InitMusic

.getJoy3
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy3

.releaseJoy3
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy3

        ld      a,BANK(lady_flower_gbm)
        ld      hl,lady_flower_gbm
        call    InitMusic

.getJoy4
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy4

.releaseJoy4
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy4

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

.getJoy5
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy5

.releaseJoy5
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy5

        ld      a,BANK(haiku_gbm)
        ld      hl,haiku_gbm
        call    InitMusic

.getJoy6
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy6

.releaseJoy6
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy6

        ld      a,BANK(moon_base_ba_gbm)
        ld      hl,moon_base_ba_gbm
        call    InitMusic

.getJoy7
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy7

.releaseJoy7
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy7

        ld      a,BANK(moon_base_haiku_gbm)
        ld      hl,moon_base_haiku_gbm
        call    InitMusic

;.getJoy8
        ;ld      a,1
        ;call    Delay
        ;ld      a,[myJoy]
        ;and     %10000
        ;jr      z,.getJoy8

;.releaseJoy8
        ;ld      a,1
        ;call    Delay
        ;ld      a,[myJoy]
        ;or      a
        ;jr      nz,.releaseJoy8

        ;ld      a,BANK(shroom_gbm)
        ;ld      hl,shroom_gbm
        ;call    InitMusic

.getJoy9
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy9

.releaseJoy9
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy9

        ld      a,BANK(cowboy_gbm)
        ld      hl,cowboy_gbm
        call    InitMusic

.getJoy10
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %10000
        jr      z,.getJoy10

.releaseJoy10
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        or      a
        jr      nz,.releaseJoy10

        jp      ((.repeat-L1102_Load2)+levelCheckRAM)

ENDC

        ld      a,BANK(triumph_small_sp)
        ld      hl,triumph_small_sp
        call    LoadCinemaSprite

        ld      d,52
        call    ScrollSpritesLeft

        ld      d,144
        call    ScrollSpritesDown

        ld      a,BANK(bcs_vestigial_bg)
        ld      hl,bcs_vestigial_bg
        call    LoadCinemaTextBox

        ld      a,16
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.endCinema - L1102_Load2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.showGroup - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,30
        call    Delay

        ;scroll the view, waiting until left edge is at tile 6 before
        ;raising the ship sprites to make it visible
        ld      a,$41
        ldio    [scrollSpeed],a
        ld      a,30
        ld      [camera_i],a

        ld      c,120
        ld      b,1     ;flag that we need to show ship
.waitScroll
        ld      a,1
        call    Delay

        ld      a,[mapLeft]
        cp      6
        jr      nz,.afterShowShip
        ld      a,b
        or      a
        jr      z,.afterShowShip

        ld      b,0
        ld      d,104
        call    ScrollSpritesUp
        call    GfxShowStandardTextBox

.afterShowShip
        dec     c
        jr      nz,.waitScroll

.showGroup
        call    ClearDialog
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        call    ResetSprites

        ld      de,((.flourDialog1 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(narrator_warroom_bg)
        ld      hl,narrator_warroom_bg
        call    LoadCinemaTextBox
        call    GfxShowStandardTextBox
        call    ((.showGroupInTriumph - L1102_Load2) + levelCheckRAM)

.flourDialog1
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade

        call    ClearDialog
        call    ((.loadFlour - L1102_Load2) + levelCheckRAM)
        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      de,((.flourDialog2 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(flour1_gtx)
        ld      c,0
        ld      de,flour1_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,5   ;5*50 delay
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.flourDialog2
        call    ClearDialog
        ld      a,BANK(flour2_gtx)
        ld      c,0
        ld      de,flour2_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.tactMap1 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      b,2   ;3*50 delay
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.tactMap1
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)

        call    ClearDialog

        ;----tactical map of our position-----------------------------
        call    ((.loadTactMap - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)

        ld      de,((.flour3 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,40
        call    ((.animateMap - L1102_Load2) + levelCheckRAM)

.flour3
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        call    ((.loadFlour - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)

        ld      de,((.tactMap2 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(flour3_gtx)
        ld      c,0
        ld      de,flour3_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,5   ;5*50 delay
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.tactMap2
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        call    ClearDialog
        call    ((.loadTactMap - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)

        ld      de,((.showGroup2 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward
        ld      a,60
        call    ((.animateMap - L1102_Load2) + levelCheckRAM)

.showGroup2
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        ld      de,((.flour4 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        call    ((.showGroupInTriumph - L1102_Load2) + levelCheckRAM)

.flour4
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        call    ((.loadFlour - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)
        ld      de,((.moontact - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(flour4_gtx)
        ld      c,0
        ld      de,flour4_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,6   ;6*50 delay
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.moontact
        call    ClearDialog
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        ld      a,BANK(moontact_bg)
        ld      hl,moontact_bg
        call    LoadCinemaBG
        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)
        ld      de,((.skippy1 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward
        ld      a,40
        call    ((.animateMap - L1102_Load2) + levelCheckRAM)
.skippy1
        call    ((.fadeToBlack - L1102_Load2) + levelCheckRAM)
        call    ((.loadSkippy - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)

        ld      a,BANK(skippy1_gtx)
        ld      c,0
        ld      de,skippy1_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour5 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      b,4
        call    ((.animateSkippy - L1102_Load2) + levelCheckRAM)

.flour5
        call    ClearDialog
        call    ((.fadeToBlack1 - L1102_Load2) + levelCheckRAM)
        call    ((.loadFlour - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L1102_Load2) + levelCheckRAM)
        ld      de,((.skippy2 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(flour5_gtx)
        ld      c,0
        ld      de,flour5_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,3   ;6*50 delay
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.skippy2
        call    ClearDialog
        call    ((.fadeToBlack1 - L1102_Load2) + levelCheckRAM)
        call    ((.loadSkippy - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L1102_Load2) + levelCheckRAM)

        ld      a,BANK(skippy2_gtx)
        ld      c,0
        ld      de,skippy2_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour6 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      b,3
        call    ((.animateSkippy - L1102_Load2) + levelCheckRAM)

.flour6
        call    ClearDialog
        call    ((.fadeToBlack1 - L1102_Load2) + levelCheckRAM)
        call    ((.loadFlour - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L1102_Load2) + levelCheckRAM)
        ld      de,((.skippy3 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(flour6_gtx)
        ld      c,0
        ld      de,flour6_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,5   ;5*50 delay
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.skippy3
        call    ClearDialog
        call    ((.fadeToBlack1 - L1102_Load2) + levelCheckRAM)
        call    ((.loadSkippy - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L1102_Load2) + levelCheckRAM)

        ld      a,BANK(skippy3_gtx)
        ld      c,0
        ld      de,skippy3_gtx
        call    ShowDialogAtBottomNoWait

        ld      de,((.flour7 - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      b,5
        call    ((.animateSkippy - L1102_Load2) + levelCheckRAM)

.flour7
        call    ClearDialog
        call    ((.fadeToBlack1 - L1102_Load2) + levelCheckRAM)
        call    ((.loadFlour - L1102_Load2) + levelCheckRAM)
        call    ((.fadeFromBlack1 - L1102_Load2) + levelCheckRAM)
        ld      de,((.endCinema - L1102_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(flour7_gtx)
        ld      c,0
        ld      de,flour7_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,2 
        call    ((.animateFlour - L1102_Load2) + levelCheckRAM)

.endCinema
        call    ClearDialog
        ld      a,BANK(nar_crewquarters_bg)
        ld      hl,nar_crewquarters_bg
        call    LoadCinemaTextBox

        ld      hl,2054  ;BA
        ld      a,l
        ld      [hero0_class],a
        ld      a,h
        ld      [hero0_class+1],a
        ld      a,HERO_BA_FLAG
        ld      [hero0_type],a
        ld      hl,$0409
        ld      a,l
        ld      [hero0_enterLevelLocation],a
        ld      a,h
        ld      [hero0_enterLevelLocation+1],a

        ld      hl,RA_CINDEX
        ld      a,l
        ld      [hero1_class],a
        ld      a,h
        ld      [hero1_class+1],a
        ld      a,HERO_BS_FLAG
        ld      [hero1_type],a

        ld      hl,NEXTLEVEL
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,NEXTLEVELDIR
        ld      [hero0_enterLevelFacing],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ret

.loadFlour
        ld      a,BANK(flour_bg)
        ld      hl,flour_bg
        call    LoadCinemaBG
        ret

.loadSkippy
        ld      a,BANK(skippy_bg)
        ld      hl,skippy_bg
        call    LoadCinemaBG
        ret

.loadTactMap
        ld      a,BANK(tactmap_bg)
        ld      hl,tactmap_bg
        call    LoadCinemaBG
        ret

.fadeToBlack
        ld      a,16
        call    SetupFadeToBlack
        call    WaitFade
        ret

.fadeFromBlack
        ld      a,16
        call    SetupFadeFromBlack
        call    WaitFade
        ret

.fadeToBlack1
        ld      a,16
        call    SetupFadeToBlack
        call    WaitFade
        ret

.fadeFromBlack1
        ld      a,16
        call    SetupFadeFromBlack
        call    WaitFade
        ret

.showGroupInTriumph
        ld      a,BANK(group_in_triumph_bg)
        ld      hl,group_in_triumph_bg
        call    LoadCinemaBG

        call    ((.fadeFromBlack - L1102_Load2) + levelCheckRAM)

        ld      a,90
        call    Delay

        ret

.animateFlour
        ;b already set up with # of loops
.flourEyes
        ld      c,10

.flourTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      1
        ld      a,4
        jr      nz,.animate
        ld      a,1

.animate
        ;animate mouth
        ld      bc,$0502
        ld      de,$0906
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.flourTalk

        ;animate eyes
        push    bc
        ld      a,3
        ld      bc,$0603
        ld      de,$0903
        ld      hl,$1900
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.flourEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0603
        ld      de,$0903
        ld      hl,$1900
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

.animateSkippy
.skippyEyes
        ld      c,10

.skippyTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      3
        ld      a,3
        jr      nc,.animateSkippyMouth
        ld      a,1

.animateSkippyMouth
        ;animate mouth
        ld      bc,$0402
        ld      de,$0609
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     c
        jr      nz,.skippyTalk

        ;animate eyes
        push    bc
        ld      a,5
        ld      bc,$0403
        ld      de,$0606
        ld      hl,$1402
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.skippyEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0403
        ld      de,$0606
        ld      hl,$1402
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

.animateMap
        ld      h,a
        ld      l,0
        ld      de,0

        ld      c,6

.animateMapLoop
        push    bc
        ld      a,10
        call    Delay
        ld      bc,$1412
        call    CinemaBlitRect
        push    hl
        ld      hl,((.mapSound - L1102_Load2) + levelCheckRAM)
        call    PlaySound
        pop     hl
        ld      a,10
        call    Delay
        push    hl
        ld      hl,$1400
        call    CinemaBlitRect
        pop     hl
        pop     bc
        dec     c
        jr      nz,.animateMapLoop
        ret

.mapSound
        DB      1,$00,$b8,$f0,$80,$c6


L1102_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1102_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1102_Init:
        DW ((L1102_InitFinished - L1102_Init2))  ;size
L1102_Init2:
        ret

L1102_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1102_Check:
        DW ((L1102_CheckFinished - L1102_Check2))  ;size
L1102_Check2:
        ret

L1102_CheckFinished:
PRINTT "1102 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1102_LoadFinished - L1102_Load2)
PRINTT " / "
PRINTV (L1102_InitFinished - L1102_Init2)
PRINTT " / "
PRINTV (L1102_CheckFinished - L1102_Check2)
PRINTT "\n"

