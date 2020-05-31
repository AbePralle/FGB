; l1502.asm approach to kiwi
; Generated 03.06.2001 by mlevel
; Modified  03.06.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

VAR_EXHAUST_FRAME EQU 0

TEMPKLUDGE EQU 0


;---------------------------------------------------------------------
SECTION "Level1502Gfx1",DATA
;---------------------------------------------------------------------
flour_gang_mono_bg:
  INCBIN "..\\fgbpix\\distress\\flour_gang_mono.bg"

appomattox_big_bg:
  INCBIN "..\\fgbpix\\distress\\appomattox_big.bg"

appomattox_big_sprites_sp::
  INCBIN "..\\fgbpix\\distress\\appomattox_big_sprites.sp"

nar_certaindanger_bg:
  INCBIN "..\\fgbpix\\distress\\nar_certaindanger.bg"


;---------------------------------------------------------------------
SECTION "Level1502Gfx2",DATA
;---------------------------------------------------------------------
flourdriving_bg::
  INCBIN "..\\fgbpix\\distress\\flourdriving.bg"

ba_bg::
  INCBIN "..\\fgbpix\\distress\\ba.bg"

bs_bg::
  INCBIN "..\\fgbpix\\distress\\bs.bg"

;---------------------------------------------------------------------
SECTION "Level1502Gfx3",DATA
;---------------------------------------------------------------------
remote_bg:
  INCBIN "..\\fgbpix\\distress\\remote.bg"

flowerviewscreen_bg::
  INCBIN "..\\fgbpix\\distress\\flowerviewscreen.bg"

;---------------------------------------------------------------------
SECTION "Level1502Gfx4",DATA
;---------------------------------------------------------------------
yacht_under_fire_bg:
  INCBIN "..\\fgbpix\\distress\\yacht_under_fire.bg"

pirate_sprites_sp:
  INCBIN "..\\fgbpix\\distress\\pirate_sprites.sp"

;---------------------------------------------------------------------
SECTION "Level1502Gfx5",DATA
;---------------------------------------------------------------------
starfield_bg:
  INCBIN "..\\fgbpix\\intro\\starfield.bg"

starfield_sprite_sp::
  INCBIN "..\\fgbpix\\intro\\starfield_sprite.sp"

;---------------------------------------------------------------------
SECTION "Level1502Gfx6",DATA
;---------------------------------------------------------------------
appomattox_tokiwi_bg::
  INCBIN "..\\fgbpix\\distress\\appomattox_tokiwi.bg"


;---------------------------------------------------------------------
SECTION "Level1502Dialog",DATA
;---------------------------------------------------------------------
dialog:
captain_cider_gtx:
  INCBIN "gtx\\distress\\captain_cider.gtx"

haiku_cider_gtx:
  INCBIN "gtx\\distress\\haiku_cider.gtx"

captain_whyglum_gtx:
  INCBIN "gtx\\distress\\captain_whyglum.gtx"

ba_surrendering_gtx:
  INCBIN "gtx\\distress\\ba_surrendering.gtx"

captain_winsome_gtx:
  INCBIN "gtx\\distress\\captain_winsome.gtx"

bs_nearKiwi_gtx:
  INCBIN "gtx\\distress\\bs_nearKiwi.gtx"

haiku_signal_gtx:
  INCBIN "gtx\\distress\\haiku_signal.gtx"

captain_showit_gtx:
  INCBIN "gtx\\distress\\captain_showit.gtx"

lady_help_gtx:
  INCBIN "gtx\\distress\\lady_help.gtx"

captain_goodness_gtx:
  INCBIN "gtx\\distress\\captain_goodness.gtx"

lady_saved_gtx::
  INCBIN "gtx\\distress\\lady_saved.gtx"

captain_seeyou_gtx::
  INCBIN "gtx\\distress\\captain_seeyou.gtx"

lady_wait_gtx::
  INCBIN "gtx\\distress\\lady_wait.gtx"

captain_holdout_gtx::
  INCBIN "gtx\\distress\\captain_holdout.gtx"

lady_no_gtx::
  INCBIN "gtx\\distress\\lady_no.gtx"

captain_shuttle_gtx::
  INCBIN "gtx\\distress\\captain_shuttle.gtx"

lady_stay_gtx::
  INCBIN "gtx\\distress\\lady_stay.gtx"

captain_nostuff_gtx::
  INCBIN "gtx\\distress\\captain_nostuff.gtx"

lady_please_gtx::
  INCBIN "gtx\\distress\\lady_please.gtx"

captain_nothanks_gtx::
  INCBIN "gtx\\distress\\captain_nothanks.gtx"

lady_must_gtx::
  INCBIN "gtx\\distress\\lady_must.gtx"

captain_no_gtx::
  INCBIN "gtx\\distress\\captain_no.gtx"

lady_insist_gtx::
  INCBIN "gtx\\distress\\lady_insist.gtx"

captain_okay_gtx::
  INCBIN "gtx\\distress\\captain_okay.gtx"

ba_goneawhile_gtx::
  INCBIN "gtx\\distress\\ba_goneawhile.gtx"


;---------------------------------------------------------------------
SECTION "Level1502Section",DATA
;---------------------------------------------------------------------

L1502_Contents::
  DW L1502_Load
  DW L1502_Init
  DW L1502_Check
  DW L1502_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1502_Load:
        DW ((L1502_LoadFinished - L1502_Load2))  ;size
L1502_Load2:
        ;restore health of heroes on next game engine level
        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a

        ld      a,BANK(dialog)
				ld      [dialogBank],a

				ld      a,BANK(intro_cinema_gbm)
				ld      hl,intro_cinema_gbm
				call    InitMusic

        xor     a
        ld      [levelVars+VAR_EXHAUST_FRAME],a

        ld      de,((.endCinema-L1502_Load2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.flourGang-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(appomattox_big_bg)
        ld      hl,appomattox_big_bg
        call    ((.appxSideView-L1502_Load2)+levelCheckRAM)

.flourGang
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(flour_gang_mono_bg)
        ld      hl,flour_gang_mono_bg
        call    LoadCinemaBG

        ld      a,BANK(nar_certaindanger_bg)
        ld      hl,nar_certaindanger_bg
        call    LoadCinemaTextBox

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)
        call    GfxShowStandardTextBox

        ld      de,((.appleCider-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,120
        call    Delay

;----"Haiku, did you bring the apple cider?"--------------------------
.appleCider
        call    ((.loadFlour-L1502_Load2)+levelCheckRAM)
        call    LoadFont

        ld      de,((.iBroughtTheCider-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM captain_cider_gtx

        call    ((.animateFlourDriving4-L1502_Load2)+levelCheckRAM)

;----"I brought the cider..."-----------------------------------------
.iBroughtTheCider
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(haiku_bg)
        ld      hl,haiku_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.whySoGlum-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM haiku_cider_gtx

        LONGCALLNOARGS AnimateHaiku

;----Why so glum?-----------------------------------------------------
.whySoGlum
        call    ((.loadFlour-L1502_Load2)+levelCheckRAM)

        ld      de,((.itSucks-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM captain_whyglum_gtx

        call    ((.animateFlourDriving3-L1502_Load2)+levelCheckRAM)

;----It sucks that we're surrendering after only two weeks!-----------
.itSucks
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(ba_bg)
        ld      hl,ba_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.winSomeLoseSome-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM ba_surrendering_gtx

        ld      d,4
        LONGCALLNOARGS AnimateBA

;----"Well you win some you lose some"--------------------------------
.winSomeLoseSome
        call    ((.loadFlour-L1502_Load2)+levelCheckRAM)

        ld      de,((.nearPlanetKiwi-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM captain_winsome_gtx

        call    ((.animateFlourDriving4-L1502_Load2)+levelCheckRAM)

;----"Near planet Kiwi and you-know-who"------------------------------
.nearPlanetKiwi
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(bs_bg) 
        ld      hl,bs_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.distressCallFromLadyFlower-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM bs_nearKiwi_gtx

        ld      d,4
        LONGCALLNOARGS AnimateBS

;----"Distress call from Lady Flower"---------------------------------
.distressCallFromLadyFlower
        call    ((.loadHaiku-L1502_Load2)+levelCheckRAM)

        ld      de,((.showIt-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM haiku_signal_gtx

        LONGCALLNOARGS AnimateHaiku

;----"Show it on the big screen"--------------------------------------
.showIt
        call    ((.loadFlour-L1502_Load2)+levelCheckRAM)

        ld      de,((.remoteControl-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM captain_showit_gtx

        call    ((.animateFlourDriving4-L1502_Load2)+levelCheckRAM)

;----Remote control turns on screen-----------------------------------
.remoteControl
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(remote_bg)
        ld      hl,remote_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.help-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        call    ((.delay15-L1502_Load2)+levelCheckRAM)

        ld      bc,$0809
        ld      de,$0800
        ld      hl,$1400
        call    CinemaBlitRect

        call    ((.delay15-L1502_Load2)+levelCheckRAM)

        ld      bc,$0809
        ld      de,$0800
        ld      hl,$1409
        call    CinemaBlitRect

        call    ((.delay15-L1502_Load2)+levelCheckRAM)

;----"Help, our ship is being attacked by a space gang!"---------------
.help
				ld      a,BANK(alarm_gbm)
				ld      hl,alarm_gbm
        call    InitMusic
        call    ((.loadLadyFlowerInDistress-L1502_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.myGoodness-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ;flash "distress"
        ld      a,60
.flashDistress
        push    af
        ld      hl,$1a00
        ld      a,[updateTimer]
        and     %1000
        jr      z,.flashFrame0
        ld      l,$09
.flashFrame0
        ld      bc,$1009
        ld      de,$0201
        call    CinemaBlitRect
        ld      a,1
        call    Delay
        pop     af
        dec     a
        jr      nz,.flashDistress

        call    ((.ladyFaceToViewscreen-L1502_Load2)+levelCheckRAM)

        ld      c,0
				DIALOGBOTTOM lady_help_gtx

        ld      d,(3|$80)
        LONGCALLNOARGS AnimateLadyFlowerDistress

;----"Oh my goodness!"------------------------------------------------
.myGoodness
        call    ((.loadFlour-L1502_Load2)+levelCheckRAM)

        ld      de,((.yachtUnderFire-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
				DIALOGBOTTOM captain_goodness_gtx

        call    ((.animateFlourDriving3-L1502_Load2)+levelCheckRAM)

        ld      a,120
        call    SetupFadeToBlack
        call    WaitFade

;----Yacht under fire-------------------------------------------------
.yachtUnderFire
        call    ((.loadYachtScene-L1502_Load2)+levelCheckRAM)

        ld      a,60
        call    SetupFadeFromBlack

        ld      de,((.appxWarp-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,110/3
.laserLoop
        push    af

        ld      bc,$0303   ;laser 1
        ld      de,$0802
        ld      hl,$1400
        ld      a,6*4      ;pirate sprite number
        call    ((.pirateFire-L1502_Load2)+levelCheckRAM)

        ld      bc,$0702   ;laser 2
        ld      de,$0a05
        ld      hl,$1700
        ld      a,9*4      ;pirate sprite number
        call    ((.pirateFire-L1502_Load2)+levelCheckRAM)

        ld      a,3
        call    Delay

        pop     af
        dec     a
        jr      nz,.laserLoop

        ;----------------star field-----------------------------
.appxWarp
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)
				ld      a,BANK(main_in_game_gbm)
				ld      hl,main_in_game_gbm
        call    InitMusic

				ld       a,BANK(starfield_bg)
				ld       hl,starfield_bg
				call     LoadCinemaBG

				ld       a,BANK(starfield_sprite_sp)
				ld       hl,starfield_sprite_sp
				call     LoadCinemaSprite

				ld       d,48 + (TEMPKLUDGE/2) + 40
				call     ScrollSpritesLeft

				ld       d,48 + (TEMPKLUDGE/2) + 40
				call     ScrollSpritesDown

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.piratesFlee-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ;number of cycles total 
        ld       b,180 + TEMPKLUDGE + 20

.loop
        push     bc

				call     (.clearPaletteToBlack + (levelCheckRAM-L1502_Load2))
				call     (.cycleColors + (levelCheckRAM-L1502_Load2))
				ld       a,1
				ld       [paletteBufferReady],a

        ld       a,1
				call     Delay
				pop      bc

				ld       a,b
				and      %00000001
				jr       nz,.afterScrollSprites

				ld       d,1
				call     ScrollSpritesUp

				ld       d,1
				call     ScrollSpritesRight

.afterScrollSprites
        ld       a,b
				and      %00000010
				jr       nz,.turnThrustOn

        call     (.routine_thrustoff + (levelCheckRAM-L1502_Load2))
				jr       .afterThrust

.turnThrustOn
        call     (.routine_thruston + (levelCheckRAM-L1502_Load2))

.afterThrust
				dec      b
				jr       nz,.loop

        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

;----Pirates Flee-----------------------------------------------------
.piratesFlee
        call    ((.loadYachtScene-L1502_Load2)+levelCheckRAM)

        ;replace yacht with damaged yacht
        ld      bc,$0906
        ld      de,$0303
        ld      hl,$1f06
        call    CinemaBlitRect

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)

        ld      de,((.endCinema-L1502_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,30
        call    Delay

        ld      c,15
.fleeLoopSlow
        ld      d,1
        call    ScrollSpritesLeft
        ld      b,24
        call    ((.setPirateSpriteDuringFlee-L1502_Load2)+levelCheckRAM)
        ld      d,1
        call    ScrollSpritesLeft
        ld      b,12
        call    ((.setPirateSpriteDuringFlee-L1502_Load2)+levelCheckRAM)
        dec     c
        jr      nz,.fleeLoopSlow

        ld      c,35
.fleeLoopFast
        ld      d,2
        call    ScrollSpritesLeft
        ld      b,24
        call    ((.setPirateSpriteDuringFlee-L1502_Load2)+levelCheckRAM)
        ld      d,2
        call    ScrollSpritesLeft
        ld      b,12
        call    ((.setPirateSpriteDuringFlee-L1502_Load2)+levelCheckRAM)
        dec     c
        jr      nz,.fleeLoopFast

.endCinema
        call    LoadFont

        ld      hl,$1403
				ld      a,l
        ld      [curLevelIndex],a
				ld      a,h
        ld      [curLevelIndex+1],a
				ld      a,2
				ld      [timeToChangeLevel],a
        ret

.loadYachtScene
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

				ld      a,BANK(yacht_under_fire_bg)
				ld      hl,yacht_under_fire_bg
				call    LoadCinemaBG

				ld      a,BANK(pirate_sprites_sp)
				ld      hl,pirate_sprites_sp
				call    LoadCinemaSprite

        ret

.pirateFire
        push    af
        ld      a,1
        call    GetRandomNumMask
        or      a
        jr      nz,.firing

.notFiring
        ld      a,l
        add     c
        ld      l,a
        call    CinemaBlitRect
        ld      b,12
        jr      .setPirateSprite

.firing
        call    CinemaBlitRect
        ld      b,30

.setPirateSprite
        pop     af
.setPirateSpriteAfterPop
        add     2
        ld      h,((spriteOAMBuffer>>8)&$ff)
        ld      l,a
        ld      de,4
        ld      a,b
        cp      30
        jr      nz,.afterSound
        cp      [hl]
        jr      z,.afterSound   ;same sound

        push    hl
        ld      hl,((.pirateLaserSound-L1502_Load2)+levelCheckRAM)
        call    PlaySound
        pop     hl
        ld      a,b

.afterSound
        ld      [hl],a
        add     hl,de
        add     2
        ld      [hl],a
        add     hl,de
        add     2
        ld      [hl],a
        add     hl,de
        ret

.setPirateSpriteDuringFlee
        ld      a,6*4
        call    ((.setPirateSpriteAfterPop-L1502_Load2)+levelCheckRAM)
        ld      a,9*4
        call    ((.setPirateSpriteAfterPop-L1502_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        ret


.quickToBlack
        call    BlackoutPalette
        call    ClearDialog
        jp      ResetSprites

.quickFromBlack
        ld      a,1
        jp      SetupFadeFromBlack

.delay15
        ld      a,15
        jp      Delay

.loadLadyFlowerOnScreen
        call    ((.loadLadyFlowerInDistress-L1502_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)
        jp      ((.ladyFaceToViewscreen-L1502_Load2)+levelCheckRAM)

.loadLadyFlowerInDistress
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

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

.loadHaiku
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(haiku_bg)
        ld      hl,haiku_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)
        ret

.loadFlour
        call    ((.quickToBlack-L1502_Load2)+levelCheckRAM)

        ld      a,BANK(flourdriving_bg)
        ld      hl,flourdriving_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1502_Load2)+levelCheckRAM)
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

.clearPaletteToBlack
        push     bc
        ld       c,64
				ld       hl,fadeCurPalette
				xor      a
.clearPaletteLoop
				ld       [hl+],a
				dec      c
				jr       nz,.clearPaletteLoop
				pop      bc
				ret

.cycleColors
        ;b is current cycle
				;set palettes 1,5, & 7 to cycle half-speed (1/8 speed of b)
				;rest to cycle full speed (1/4 speed of b)
				push     bc

        ;----------set full-speed palettes (0,2,3,4,6)------------
				;color = (clock % 6) / 2
				ld       c,6
				ld       a,b
.getMod6
				cp       c
				jr       c,.gotMod6
				sub      c
				jr       .getMod6
.gotMod6
				srl      a      ;divided by 2 yields 0-2
				ld       c,a
				inc      c      ;c is now 1-3

        push     bc
				ld       b,0
				xor      a
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;0
				inc      a
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;2
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;3
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;4
				inc      a
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;6
				pop      bc

        ;----------set half-speed palettes (1,5,7)---------------
				;color = (clock % 12) / 4
				ld       c,12
				ld       a,b
.getMod12
				cp       c
				jr       c,.gotMod12
				sub      c
				jr       .getMod12
.gotMod12
				srl      a      ;divided by 4 yields 0-2
				srl      a
				ld       c,a
				inc      c      ;c is now 1-3

        push     bc
				ld       b,1
        ld       a,1
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;1
				ld       a,5
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;5
				inc      a
				call     (.setCycle + (levelCheckRAM-L1502_Load2))  ;7
				pop      bc

				pop      bc
				ret

.setCycle
        ;a is palette # to set (0-7)
				;b is color flag (0=white, 1=grey)
				;c is color number to set (1-3)
				push     af
				push     hl

				;(palette# * 4 + color) * 2 + 128 is first byte to set
				rlca
				rlca
				add      c
				rlca
				add      128
				ld       l,a
				ld       h,((fadeCurPalette>>8) & $ff)

        ld       a,b
				cp       1
				jr       z,.setToGrey

        ;set to white
        ld       a,$ff
				ld       [hl+],a
				ld       a,$7f
				ld       [hl],a
				jr       .done

.setToGrey
        ld       a,$08
				ld       [hl+],a
				ld       a,$21
				ld       [hl],a

.done
				pop      hl
				pop      af
				inc      a
				ret

.animate_ship
        push     bc
				ld       b,90
.animate_loop
        push     bc
				ld       a,1
				call     Delay
				pop      bc

				ld       a,b
				and      %10   ;thrust on or off?

				jr       nz,.animate_thruston
        call     (.routine_thrustoff + (levelCheckRAM-L1502_Load2))
				jr       .animate_check_done

.animate_thruston
        call     (.routine_thruston + (levelCheckRAM-L1502_Load2))

.animate_check_done
				dec      b
				jr       nz,.animate_loop

				pop      bc

				ret

.pirateLaserSound
   DB 1,$3c,00,$f6,00,$87

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

.appxScrollStarsWaitFade
        ld      c,160
.waitFade
        ld      a,1
        call    Delay
        call    ((.scrollStars-L1502_Load2)+levelCheckRAM)
        dec     c
        jr      nz,.waitFade

        ret


L1502_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1502_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1502_Init:
        DW ((L1502_InitFinished - L1502_Init2))  ;size
L1502_Init2:
        ret

L1502_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1502_Check:
        DW ((L1502_CheckFinished - L1502_Check2))  ;size
L1502_Check2:
        ret

L1502_CheckFinished:
PRINTT "1502 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1502_LoadFinished - L1502_Load2)
PRINTT " / "
PRINTV (L1502_InitFinished - L1502_Init2)
PRINTT " / "
PRINTV (L1502_CheckFinished - L1502_Check2)
PRINTT "\n"

