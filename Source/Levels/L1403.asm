; L1403.asm approaching kiwi
; Generated 03.08.2001 by mlevel
; Modified  03.08.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

VAR_DESTZONE  EQU 0
VAR_DESTCOLOR EQU 1
VAR_DESTBG    EQU 3
VAR_DESTBANK  EQU 5

;this var used in user.asm
VAR_SELSTAGE  EQU 6
VAR_EXHAUST_FRAME EQU 7





;---------------------------------------------------------------------
SECTION "Level1403Section",ROMX
;---------------------------------------------------------------------

L1403_Contents::
  DW L1403_Load
  DW L1403_Init
  DW L1403_Check
  DW L1403_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1403_Load:
        DW ((L1403_LoadFinished - L1403_Load2))  ;size
L1403_Load2:
        ld      a,1
        ld      [displayType],a
        xor     a
        ld      [scrollSprites],a
        xor     a
        ld      [levelVars+VAR_EXHAUST_FRAME],a
        ld      a,4
        ld      [levelVars+VAR_SELSTAGE],a

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

;----"Thank you"------------------------------------------------------
.thankYou
        call    ((.loadLadyFlowerOnScreen-L1403_Load2)+levelCheckRAM)

        ld      de,((.seeYou-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      de,((.endCinema-L1403_Load2)+levelCheckRAM)
        call    SetDialogSkip

        ld      c,0
        DIALOGBOTTOM lady_saved_gtx

        ld      d,3
        LONGCALLNOARGS AnimateLadyFlowerDistress

;----"See you"--------------------------------------------------------
.seeYou 
        call    ((.loadFlour-L1403_Load2)+levelCheckRAM)

        ld      de,((.wait-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_seeyou_gtx

        call    ((.animateFlourDriving3-L1403_Load2)+levelCheckRAM)

;----"Wait..."--------------------------------------------------------
.wait
        call    ((.loadLadyFlowerOnScreen-L1403_Load2)+levelCheckRAM)

        ld      de,((.holdOut-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM lady_wait_gtx

        ld      d,3
        LONGCALLNOARGS AnimateLadyFlowerDistress
        
;----"Do you think you can hold out for a few days?"------------------
.holdOut
        call    ((.loadFlour-L1403_Load2)+levelCheckRAM)

        ld      de,((.whatNo-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_holdout_gtx

        call    ((.animateFlourDriving4-L1403_Load2)+levelCheckRAM)


;----"What?! No!"-----------------------------------------------------
.whatNo
        call    ((.loadLadyFlowerOnScreen-L1403_Load2)+levelCheckRAM)

        ld      de,((.sendShuttle-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM lady_no_gtx

        ld      d,3
        LONGCALLNOARGS AnimateLadyFlowerDistress

;----"BS, send over the shuttle"--------------------------------------
.sendShuttle
        call    ((.loadFlour-L1403_Load2)+levelCheckRAM)

        ld      de,((.toKiwi-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_shuttle_gtx

        call    ((.animateFlourDriving4-L1403_Load2)+levelCheckRAM)

        ld      a,60
        call    SetupFadeToBlack
        call    WaitFade

.toKiwi
        call    ((.quickToBlack-L1403_Load2)+levelCheckRAM)
        ld      de,((.approachKiwi-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(appomattox_tokiwi_bg)
        ld      hl,appomattox_tokiwi_bg
        call    ((.appxSideView-L1403_Load2)+levelCheckRAM)
        ld      a,16
        call    SetupFadeToBlack
        ld      c,20
        call    ((.appxScrollStarsWaitFade-L1403_Load2)+levelCheckRAM)

;----Approach Kiwi----------------------------------------------------
.approachKiwi
        call    ((.quickToBlack-L1403_Load2)+levelCheckRAM)
        ld      a,BANK(kiwi1_bg)
        ld      hl,kiwi1_bg
        call    LoadCinemaBG

        ld      a,BANK(starfield_sprite_sp)
        ld      hl,starfield_sprite_sp
        call    LoadCinemaSprite
        ld      a,1
        call    Delay

        ld      de,((.controlPanel-L1403_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,16
        call    SetupFadeFromBlack
        call    WaitFade

        ld      b,30
        call    (.animate_ship + (levelCheckRAM-L1403_Load2))

        ld       a,16
        call     SetupFadeToBlackBGOnly
        ld       b,16
        call     (.animate_ship + (levelCheckRAM-L1403_Load2))

        ;kiwi 2
        ld       a,BANK(kiwi2_bg)
        ld       hl,kiwi2_bg
        call     LoadCinemaBG

        ld       a,16
        call     SetupFadeFromBlackBGOnly
        ld       c,16
        call     ((.animate_ship-L1403_Load2)+levelCheckRAM)

        ld       b,30
        call     (.animate_ship + (levelCheckRAM-L1403_Load2))

        ld       a,16
        call     SetupFadeToBlackBGOnly
        ld       b,16
        call     (.animate_ship + (levelCheckRAM-L1403_Load2))

        ;kiwi 3
        ld       a,BANK(kiwi3_bg)
        ld       hl,kiwi3_bg
        call     LoadCinemaBG

        ld       a,16
        call     SetupFadeFromBlackBGOnly

        ld       b,30
        call     (.animate_ship + (levelCheckRAM-L1403_Load2))

        ld      a,16
        call    ((.setupFadeFromSky-L1403_Load2)+levelCheckRAM)
        ld      b,16
        call    (.animate_ship + (levelCheckRAM-L1403_Load2))

.endCinema
.controlPanel
        ld      a,2
        call    ((.setupFadeFromSky-L1403_Load2)+levelCheckRAM)
        call    WaitFade

        call    ResetSprites

        ;----set up control panel window------------------------------
        ld      a,BANK(controlpanel_bg)
        ld      hl,controlpanel_bg
        call    LoadCinemaBG

        ld      a,BANK(panelsprites_sp)
        ld      hl,panelsprites_sp
        call    LoadCinemaSprite

        ;set coords to be star flower wrench crouton
        ld      hl,spriteOAMBuffer+2
        ld      de,4
        ld      [hl],0
        add     hl,de
        ld      [hl],2
        add     hl,de
        ld      [hl],8
        add     hl,de
        ld      [hl],10
        add     hl,de
        ld      [hl],24
        add     hl,de
        ld      [hl],26
        add     hl,de
        ld      [hl],12
        add     hl,de
        ld      [hl],14

IF 0
        ;set four positional indicators to blank sprite
        ld      hl,spriteOAMBuffer+2
        ld      de,4
        ld      a,36
        ld      c,8
.clearIndicators
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.clearIndicators
ENDC

        ;set sprites 8-19 to be HUD instead of dest symbol
        ld      hl,spriteOAMBuffer+8*4+2
        ld      a,64
        ld      b,4    ;palette 4 for HUD
        ld      c,12
        ld      de,3
.spritesToHUD
        ld      [hl+],a
        ld      [hl],b
        add     hl,de
        add     2
        dec     c
        jr      nz,.spritesToHUD

IF 0
        ;hide all HUD sprites except power bars
        ld      hl,spriteOAMBuffer+8*4
        ld      b,144    ;offset to add to each sprite
        ld      c,14
        ld      de,4
.hideAllHUD
        ld      a,[hl]
        add     b
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.hideAllHUD
ENDC

        ;copy panel to top half of map
        ld      bc,$1409
        ld      de,$0000
        ld      hl,$0009
        call    CinemaBlitRect
        ld      a,1
        call    Delay

        ;panel to dialog window
        ld      de,((.byte8-L1403_Load2)+levelCheckRAM)
        call    ShowDialogAtBottomCommon
        ld      a,1
        call    Delay

        ld      a,BANK(lz_gate_bg)
        ld      hl,lz_gate_bg
        call    LoadCinemaBG

        ;set up DEST info
        ld      hl,levelVars+VAR_DESTZONE
        ld      a,$71
        ld      [hl+],a
        ld      a,$20
        ld      [hl+],a
        ld      a,$7e
        ld      [hl+],a
        ld      a,(lz_gate_bg & $ff)
        ld      [hl+],a
        ld      a,((lz_gate_bg>>8) & $ff)
        ld      [hl+],a
        ld      a,BANK(lz_gate_bg)
        ld      [hl+],a
        ld      a,4
        ld      [hl+],a

.setPowerBar
        ld      hl,spriteOAMBuffer+22*4+2
        ld      a,60
        ld      de,4
        ld      [hl],a
        add     hl,de
        add     2
        ld      [hl],a

        ;set horizon bar vertical
        ld      hl,spriteOAMBuffer+16*4
        ld      a,$3a
        ld      [hl],a
        add     hl,de
        ld      [hl],a
        add     hl,de
        ld      [hl],a
        add     hl,de
        ld      [hl],a

        ld      hl,$1503
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,2
        ld      [timeToChangeLevel],a

        ret

;---------------------------------------------------------------------
;Support Routines
;---------------------------------------------------------------------
.appxSideView
        call    LoadCinemaBG

        ld      a,BANK(appomattox_big_sprites_sp)
        ld      hl,appomattox_big_sprites_sp
        call    LoadCinemaSprite

        ;change 1st 32 sprites to be BG priority
        ld      c,32
        ld      hl,spriteOAMBuffer+8*4+3
        ld      de,4
.spritePriorityLoop
        set     7,[hl]
        add     hl,de
        dec     c
        jr      nz,.spritePriorityLoop

        ld      a,90
        call    SetupFadeFromBlack

        ld      c,160
.appxScrollStarsWaitFade
.waitFade
        ld      a,1
        call    Delay
        call    ((.scrollStars-L1403_Load2)+levelCheckRAM)
        dec     c
        jr      nz,.waitFade

        ret

.quickToBlack
        call    BlackoutPalette
        call    ClearDialog
        jp      ResetSprites

.quickFromBlack
        ld      a,1
        jp      SetupFadeFromBlack

.loadFlour
        call    ((.quickToBlack-L1403_Load2)+levelCheckRAM)

        ld      a,BANK(flourdriving_bg)
        ld      hl,flourdriving_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1403_Load2)+levelCheckRAM)
        ret

.animateFlourDriving3
        ld      d,3
        jr      .animateFlourDrivingN

.animateFlourDriving4
        ld      d,4
.animateFlourDrivingN
        LONGCALLNOARGS AnimateFlourDriving

.scrollStars
        push    bc
        push    de
        push    hl

        ;of 32 stars, scroll odd ones by one pixel and evens
        ;by two
        ld      c,16
        ld      de,4
        ld      hl,spriteOAMBuffer+8*4+1
.scrollStarsLoop
        dec     [hl]
        add     hl,de
        dec     [hl]
        dec     [hl]
        add     hl,de
        dec     c
        jr      nz,.scrollStarsLoop

        ;ping-pong exhaust
        ld      hl,levelVars+VAR_EXHAUST_FRAME
        ld      a,[updateTimer]
        bit     0,a
        jr      nz,.gotCurFrame

        ;increment frame
        ld      a,[hl]
        add     16
        cp      160
        jr      nz,.wrapFrame
        xor     a
.wrapFrame
        ld      [hl],a

.gotCurFrame
        ld      a,[hl]
        ;sprite = curframe + 80
        cp      96
        jr      c,.frameOkay
        cpl
        add     161
.frameOkay
        add     80
        ld      hl,spriteOAMBuffer+2
        ld      de,4
        ld      c,8
.setThrust
        ld      [hl],a
        add     2
        add     hl,de
        dec     c
        jr      nz,.setThrust

        pop     hl
        pop     de
        pop     bc
        ret

.loadLadyFlowerOnScreen
        call    ((.loadLadyFlowerInDistress-L1403_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1403_Load2)+levelCheckRAM)
        jp      ((.ladyFaceToViewscreen-L1403_Load2)+levelCheckRAM)

.loadLadyFlowerInDistress
        call    ((.quickToBlack-L1403_Load2)+levelCheckRAM)

        ld      a,BANK(flowerviewscreen_bg) 
        ld      hl,flowerviewscreen_bg
        call    LoadCinemaBG
        ret

.ladyFaceToViewscreen
        ;put lady flower's face on
        ld      bc,$1009
        ld      de,$0201
        ld      hl,$1a12
        call    CinemaBlitRect
        ret

.animate_ship
        push     bc
.animate_loop
        push     bc
        ld       a,1
        call     Delay
        pop      bc

        ld       a,b
        and      %10   ;thrust on or off?

        jr       nz,.animate_thruston
        call     (.routine_thrustoff + (levelCheckRAM-L1403_Load2))
        jr       .animate_check_done

.animate_thruston
        call     (.routine_thruston + (levelCheckRAM-L1403_Load2))

.animate_check_done
        dec      b
        jr       nz,.animate_loop

        pop      bc

        ret

.routine_thrustoff
        ;turn thrust off by setting sprites 0-5 to pattern 50
        ld       hl,spriteOAMBuffer+2
        ld       de,4
        ld       a,50
        ld       c,6
.thrustOffLoop
        ld       [hl],a
        add      hl,de
        dec      c
        jr       nz,.thrustOffLoop
        ret

.routine_thruston
        ;turn thrust on by setting sprites 0-5 to patterns 0,2,4,6,8,10
        ld       hl,spriteOAMBuffer+2
        ld       de,4
        xor      a
        ld       c,6
.thrustOnLoop
        ld       [hl],a
        inc      a
        inc      a
        add      hl,de
        dec      c
        jr       nz,.thrustOnLoop
        ret

.setupFadeFromSky
        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;ld      hl,gamePalette
        ;ld      de,fadeCurPalette
        ;call    FadeCommonCopyPalette

        ;set all colors to be $7d80
        ld      hl,fadeFinalPalette
        ld      c,64
.setAll7d80
        ld      [hl],$80
        inc     hl
        ld      [hl],$7d
        inc     hl
        dec     c
        jr      nz,.setAll7d80

        pop     af
        call    FadeInit
        ret

.byte8
  DB 8

L1403_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1403_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1403_Init:
        DW ((L1403_InitFinished - L1403_Init2))  ;size
L1403_Init2:
        ret

L1403_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1403_Check:
        DW ((L1403_CheckFinished - L1403_Check2))  ;size
L1403_Check2:
        ret

L1403_CheckFinished:
PRINT "1403 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1403_LoadFinished - L1403_Load2)
PRINT " / "
PRINT (L1403_InitFinished - L1403_Init2)
PRINT " / "
PRINT (L1403_CheckFinished - L1403_Check2)
PRINT "\n"

