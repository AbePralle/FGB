; L1503.asm
; Generated 03.08.2001 by mlevel
; Modified  03.08.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"






VAR_DESTZONE  EQU 0
VAR_DESTCOLOR EQU 1
VAR_DESTBG    EQU 3
VAR_DESTBANK  EQU 5

VAR_SELSTAGE  EQU 6

;---------------------------------------------------------------------
SECTION "Level1503Gfx1",ROMX
;---------------------------------------------------------------------
downramp_bg::
  INCBIN "Data/Cinema/Distress/downramp.bg"

downramp_sprites_sp:
  INCBIN "Data/Cinema/Distress/downramp_sprites.sp"

;---------------------------------------------------------------------
SECTION "Level1503Gfx2",ROMX
;---------------------------------------------------------------------
flower_and_flour_establishing_bg:
  INCBIN "Data/Cinema/Distress/flower_and_flour_establishing.bg"

flour_and_flower_bg:
  INCBIN "Data/Cinema/Distress/flour_and_flower.bg"

;---------------------------------------------------------------------
SECTION "Level1503Section",ROMX
;---------------------------------------------------------------------

L1503_Contents::
  DW L1503_Load
  DW L1503_Init
  DW L1503_Check
  DW L1503_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1503_Load:
        DW ((L1503_LoadFinished - L1503_Load2))  ;size
L1503_Load2:
        ld      a,1
        ld      [displayType],a
        xor     a
        ld      [scrollSprites],a
        ld      a,1
        call    Delay

        ld      de,((.landingOnKiwi-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      de,((.endCinema-L1503_Load2)+levelCheckRAM)
        call    SetDialogSkip

.flying
        ld      a,BANK(cloud0_bg)
        ld      hl,cloud0_bg
        call    LoadCinemaBG
        ld      a,1
        call    Delay

        ld      a,15
        call    ((.setupFadeToClouds-L1503_Load2)+levelCheckRAM)

        ld       b,50
        ld       c,1
.cloudAnim
        ;load next cloud frame
        ld       d,0    ;de = c*4
        ld       e,c
        sla      e
        rl       d
        sla      e
        rl       d
        ld       hl,((.cloudFrames-L1503_Load2)+levelCheckRAM)
        add      hl,de
        ld       a,[hl+]    ;mem bank of cloud frame
        inc      hl
        push     af
        ld       a,[hl+]
        ld       h,[hl]
        ld       l,a
        pop      af
        call     LoadCinemaBG
        ;ld       a,1
        ;call     Delay
        call    ((.animateWave-L1503_Load2)+levelCheckRAM)

        ld       a,c
        inc      a
        and      7
        ld       c,a

        ld       a,b
        cp       20
        jr       nz,.afterStartFadeOutInClouds

        ld       a,15
        call    ((.setupFadeToSky-L1503_Load2)+levelCheckRAM)

.afterStartFadeOutInClouds
        dec      b
        jr       nz,.cloudAnim

        ld      a,3
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1503_Load2)+levelCheckRAM)

;----Load picture of new landing zone---------------------------------
        ld      hl,levelVars+VAR_DESTBANK
        ld      a,[hl-]
        push    af
        ld      a,[hl-]
        ld      l,[hl]
        ld      h,a
        pop     af
        call    LoadCinemaBG
        ld      a,1
        call    Delay

        ld      a,FADEBANK
        ld      [$ff70],a
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette
        ld      a,1
        call    FadeInit
        call    WaitFade
        ld      a,2
        call    Delay

        ld      a,190
        ldio    [jiggleDuration],a

        ld      a,1
        ldio    [jiggleType],a    ;take-off jiggle

        ld      a,18
        ld      [camera_j],a

        ld      a,$11
        ldio    [scrollSpeed],a

        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.afterRemoteAppx 

.addRemoteAppx
        ld      a,LCHANGEAPPXMAP
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.addRemoteAppx      ;must repeat
        ld      a,[appomattoxMapIndex]
        call    TransmitByte
.afterRemoteAppx

        ld      hl,musicEnabled  ;disable track 4
        res     3,[hl]
       
        ld      hl,((.engineSound1-L1503_Load2)+levelCheckRAM)
        call    PlaySound

        ld      a,40
        call    ((.delayAdjustHorizon-L1503_Load2)+levelCheckRAM)

        ld      a,2
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1503_Load2)+levelCheckRAM)

        ld      a,15
        call    ((.delayAdjustHorizon-L1503_Load2)+levelCheckRAM)

        ld      a,1
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1503_Load2)+levelCheckRAM)

        ;ld      hl,((.engineSound2-L1503_Load2)+levelCheckRAM)
        ;call    PlaySound

        ;ld      a,30
        ;call    ((.delayAdjustHorizon-L1503_Load2)+levelCheckRAM)

        ;xor     a
        ;ld      [levelVars+VAR_SELSTAGE],a
        ;call    ((.setPowerBar-L1503_Load2)+levelCheckRAM)

        ;ld      a,30
        ;call    ((.delayAdjustHorizon-L1503_Load2)+levelCheckRAM)

        ;ld      hl,musicEnabled  ;enable track 4
        ;set     3,[hl]

        ;call    ((.powerDown-L1503_Load2)+levelCheckRAM)

        ;----------------landing on kiwi-----------------------
.landingOnKiwi
        xor     a
        ldio    [jiggleDuration],a
        call    ((.delay2-L1503_Load2)+levelCheckRAM)
        call    BlackoutPalette
        call    ClearDialog
        call    ResetSprites
        call    ((.delay2-L1503_Load2)+levelCheckRAM)

        ld      a,BANK(landing_bg_bg)
        ld      hl,landing_bg_bg
        call    LoadCinemaBG
        ld      a,BANK(landing_sprites_sp)
        ld      hl,landing_sprites_sp
        call    LoadCinemaSprite

        ld      d,16
        call    ScrollSpritesRight
        ld      d,48
        call    ScrollSpritesUp

        ;set landing gear sprites and flame to off
        ld      hl,spriteOAMBuffer+6
        ld      c,8
        xor     a
.init_landing_loop
        ld      [hl+],a
        inc     hl
        inc     hl
        inc     hl
        dec     c
        jr      nz,.init_landing_loop

        ld      de,((.ramp-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward

        ;----------------animate descent of appomattox

        ;landing gear stowed
        ld       a,1
        call     SetupFadeFromBlack
        ld       b,60
.descent1
        push     bc
        ld       a,1
        call     Delay
        ld       d,1
        call     ((.scrollAllSpritesDown-L1503_Load2)+levelCheckRAM)
        pop      bc

        dec      b
        jr       nz,.descent1

        ;landing gear half-out
        ld       hl,spriteOAMBuffer+(9*4)+2
        ld       c,4
        ld       a,2
.gear_half_loop
        ld       [hl+],a   ;change tile index
        inc      hl
        inc      hl
        inc      hl
        add      2
        dec      c
        jr       nz,.gear_half_loop

        ld       b,5
.descent2
        push     bc
        call     ((.delay2-L1503_Load2)+levelCheckRAM)
        ld       d,1
        call     ((.scrollAllSpritesDown-L1503_Load2)+levelCheckRAM)
        pop      bc

        dec      b
        jr       nz,.descent2

        ;landing gear full out
        ld       hl,spriteOAMBuffer+(9*4)+2
        ld       c,4
        ld       a,10
.gear_full_loop
        ld       [hl+],a   ;change tile index
        inc      hl
        inc      hl
        inc      hl
        add      2
        dec      c
        jr       nz,.gear_full_loop

        ld       b,20
.descent3
        push     bc
        call     ((.delay2-L1503_Load2)+levelCheckRAM)
        ld       d,1
        call     ((.scrollAllSpritesDown-L1503_Load2)+levelCheckRAM)
        pop      bc

        dec      b
        jr       nz,.descent3

        ;engine noise fade to off
        ld      hl,((.engineSound2-L1503_Load2)+levelCheckRAM)
        call    PlaySound

        ld      b,10
.descent4
        push     bc
        ld       a,3
        call     Delay
        ld       d,1
        call     ((.scrollAllSpritesDown-L1503_Load2)+levelCheckRAM)
        pop      bc

        dec      b
        jr       nz,.descent4

        ld      a,30
        call    Delay

;----Walking down the landing ramp------------------------------------
.ramp
        call    BlackoutPalette
        call    ResetSprites

        ld      a,BANK(downramp_bg)
        ld      hl,downramp_bg
        call    LoadCinemaBG

        ld      a,BANK(downramp_sprites_sp)
        ld      hl,downramp_sprites_sp
        call    LoadCinemaSprite

        call    ((.quickFromBlack-L1503_Load2)+levelCheckRAM)

        ld      de,((.establishing-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(lady_flower_gbm)
        ld      hl,lady_flower_gbm
        call    InitMusic

        ld      a,30
        call    Delay

        ld      c,9
.walkDownRamp
        ;second frame
        ld      a,8
        call    ((.animateRampSprites-L1503_Load2)+levelCheckRAM)
        ld      d,2
        call    ScrollSpritesRight
        ld      d,1
        call    ScrollSpritesDown
        ld      a,5
        call    Delay

        ;first frame
        xor     a
        call    ((.animateRampSprites-L1503_Load2)+levelCheckRAM)
        ld      d,2
        call    ScrollSpritesRight
        ld      d,1
        call    ScrollSpritesDown
        ld      a,5
        call    Delay
        dec     c
        jr      nz,.walkDownRamp

        ld      a,30
        call    Delay

.establishing
        call    BlackoutPalette
        call    ResetSprites
        call    LoadFont

        ld      a,BANK(flower_and_flour_establishing_bg)
        ld      hl,flower_and_flour_establishing_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1503_Load2)+levelCheckRAM)

        ld      de,((.talking-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,60
        call    Delay

.talking
        ld      a,$21
        ldio    [scrollSpeed],a
        call    BlackoutPalette

        ld      a,BANK(flour_and_flower_bg)
        ld      hl,flour_and_flower_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1503_Load2)+levelCheckRAM)

        ld      de,((.nostuff-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(lady_stay_gtx)
        ld      [dialogBank],a

        ld      c,0
        DIALOGBOTTOM lady_stay_gtx
        ld      d,3
        LONGCALLNOARGS AnimateLadyFlowerRamp

.nostuff
        call    ((.panToCaptain-L1503_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM captain_nostuff_gtx
        ld      de,((.please-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,3
        LONGCALLNOARGS AnimateCaptainRamp

.please
        call    ((.panToLady-L1503_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM lady_please_gtx
        ld      de,((.nothanks-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,3
        LONGCALLNOARGS AnimateLadyFlowerRamp

.nothanks
        call    ((.panToCaptain-L1503_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM captain_nothanks_gtx
        ld      de,((.must-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,2
        LONGCALLNOARGS AnimateCaptainRamp

.must
        ;call    StopMusic
        ;ld      hl,((.buzzerSound-L1503_Load2)+levelCheckRAM)
        ;call    PlaySound
        ld      a,$41
        ldio    [scrollSpeed],a
        call    ((.panToLady-L1503_Load2)+levelCheckRAM)
        ;ld      a,30
        ;call    Delay
        ;ld      a,15
        ;ldio    [jiggleDuration],a
        ld      c,0
        DIALOGBOTTOM lady_must_gtx
        ld      de,((.no-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,2
        LONGCALLNOARGS AnimateLadyFlowerRamp

.no
        call    ((.panToCaptain-L1503_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM captain_no_gtx
        ld      de,((.insist-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,2
        LONGCALLNOARGS AnimateCaptainRamp

.insist
        ld      a,$82
        ldio    [scrollSpeed],a
        call    ((.panToLady-L1503_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM lady_insist_gtx
        ld      de,((.okay-L1503_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,2
        LONGCALLNOARGS AnimateLadyFlowerRamp

.okay

.endCinema
        call    BlackoutPalette
        call    ClearDialog
        call    ResetSprites

        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,EXIT_N
        ld      [hl],a
        ld      hl,$1504
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,2
        ld      [timeToChangeLevel],a
        ret

.panToCaptain
        ld      a,21
        ld      [camera_i],a
        ld      a,23
        ld      [camera_j],a
        ret

.panToLady
        xor     a
        ld      [camera_i],a
        ld      [camera_j],a
        ret

.animateRampSprites
        push    bc
        ld      hl,spriteOAMBuffer+2
        ld      de,4
        ld      c,4
.animateRampSpritesLoop
        ld      [hl],a
        add     hl,de
        add     2
        dec     c
        jr      nz,.animateRampSpritesLoop
        pop     bc
        ret

.powerDown
        ;xor     a
        ;ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1503_Load2)+levelCheckRAM)
        call    ((.recticleOff-L1503_Load2)+levelCheckRAM)
        call    ((.horizonOff-L1503_Load2)+levelCheckRAM)
        call    ((.diagramOff-L1503_Load2)+levelCheckRAM)
        ld      a,30
        call    ((.delayAnimateWave-L1503_Load2)+levelCheckRAM)
        ret

.setPowerBar
        ld      a,[levelVars+VAR_SELSTAGE]
        inc     a
        ld      [musicRegisters+0],a
        dec     a
        rlca    ;sprite = stage*4 + 44
        rlca
        add     44
        ld      hl,spriteOAMBuffer+22*4+2
        ld      [hl+],a
        inc     hl
        inc     hl
        inc     hl
        add     2
        ld      [hl],a

        ret

.horizonOff
        ld      de,4
        xor     a
        ld      hl,spriteOAMBuffer+16*4
        ld      c,4
.horizonOffLoop
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.horizonOffLoop
        ret

.recticleOff
        ld      de,4
        xor     a
        ld      hl,spriteOAMBuffer+8*4
        ld      c,8
.recticleOffLoop
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.recticleOffLoop
        ret

.diagramOff
        ld      hl,spriteOAMBuffer+20*4
        ld      [hl],160
        ld      hl,spriteOAMBuffer+21*4
        ld      [hl],160
        ret


.delayAdjustHorizon
        ld      c,a
        ld      hl,spriteOAMBuffer+16*4
        ld      de,4
.delayLoop
        call    ((.animateWave-L1503_Load2)+levelCheckRAM)

        ld      a,1
        call    Delay

        ;horizon = 58 - ((mapTop*8+desiredPixelOffset_y)/4)
        ld      a,[mapTop]
        rlca
        rlca
        rlca
        ld      b,a
        ld      a,[desiredPixelOffset_y]
        add     b
        srl     a
        srl     a
        cpl
        add     59

        push    hl
        ld      b,4
.alterHorizonSpriteLoop
        ld      [hl],a
        add     hl,de
        dec     b
        jr      nz,.alterHorizonSpriteLoop
        pop     hl
        dec     c
        jr      nz,.delayLoop
        ret


.setupFadeFromSky
        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set final palette bg7 to be bg7 color 0
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeFinalPalette+8*7
        ld      a,$80
        ld      c,a
        ld      b,$7d
        ld      hl,fadeFinalPalette+8*7
        call    ((.setBG7-L1503_Load2)+levelCheckRAM)

        pop     af
        call    FadeInit
        ret

.setBG7
        ;copy bc to 4 entries at palette hl
        ld      hl,fadeFinalPalette+8*7
        ld      a,4
.setBG7Loop
        ld      [hl],c
        inc     hl
        ld      [hl],b
        inc     hl
        dec     a
        jr      nz,.setBG7Loop
        ret

.setupFadeToSky
        push    bc
        push    de
        push    hl

        push    af

        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ld      hl,levelVars+VAR_DESTZONE
        ld      a,[hl+]
        ld      [appomattoxMapIndex],a
        ld      a,[hl+]
        ld      b,[hl]
        ld      c,a
        ld      hl,fadeCurPalette+8*7
        call    ((.setBG7-L1503_Load2)+levelCheckRAM)
        pop     af
        call    FadeInit
        pop     hl
        pop     de
        pop     bc
        ret

.defaultSkyColor
        ld      bc,$7e20
        ret

.setupFadeToClouds
        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ;set all colors to be $7d80
        ld      hl,fadeCurPalette
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

.cloudFrames
  DW BANK(cloud0_bg), cloud0_bg, BANK(cloud1_bg), cloud1_bg
  DW BANK(cloud2_bg), cloud2_bg, BANK(cloud3_bg), cloud3_bg
  DW BANK(cloud4_bg), cloud4_bg, BANK(cloud5_bg), cloud5_bg
  DW BANK(cloud6_bg), cloud6_bg, BANK(cloud7_bg), cloud7_bg

.engineSound1
  DB      4,$00,$df,$a9,$80   ;looping/infinite

.engineSound2
  DB      4,$00,$d7,$a9,$80   ;fades

.byte8
  DB 8

.delayAnimateWave
        push    af
        call    ((.animateWave-L1503_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        pop     af
        dec     a
        jr      nz,.delayAnimateWave
        ret

.animateWave
        push    bc
        push    de
        push    hl
        PUSHROM
        ld      a,BANK(appwaves0_dat)
        call    SetActiveROM
        ld      a,[levelVars+VAR_SELSTAGE]   ;a=stage*8 + frame*2
        rlca
        rlca
        rlca
        ld      b,a
        ldio    a,[vblankTimer]
        and     %11000
        rrca
        rrca
        or      b
        add     (((.waveFrameTable-L1503_Load2)+levelCheckRAM) & $ff)
        ld      l,a
        ld      a,0
        adc     ((((.waveFrameTable-L1503_Load2)+levelCheckRAM)>>8) & $ff)
        ld      h,a
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ld      de,$9420
        ld      c,40
        ld      a,1
        call    VMemCopy
        POPROM
        pop     hl
        pop     de
        pop     bc
        ret

.waveFrameTable
  DW appwaves0_dat,appwaves0_dat+640,appwaves0_dat+640*2,appwaves0_dat+640*3
  DW appwaves1_dat,appwaves1_dat+640,appwaves1_dat+640*2,appwaves1_dat+640*3
  DW appwaves2_dat,appwaves2_dat+640,appwaves2_dat+640*2,appwaves2_dat+640*3
  DW appwaves3_dat,appwaves3_dat+640,appwaves3_dat+640*2,appwaves3_dat+640*3
  DW appwaves4_dat,appwaves4_dat+640,appwaves4_dat+640*2,appwaves4_dat+640*3

.scrollAllSpritesDown
        push     bc
        push     de
        push     hl

        ld       hl,spriteOAMBuffer
        ld       c,35
.scrollDownLoop
        ld       a,[hl]
        add      d
        ld       [hl+],a
        inc      hl
        inc      hl
        inc      hl
        dec      c
        jr       nz,.scrollDownLoop

        pop      hl
        pop      de
        pop      bc
        ret

.quickFromBlack
        ld      a,1
        jp      SetupFadeFromBlack

.delay2
        ld      a,2
        jp      Delay

L1503_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1503_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1503_Init:
        DW ((L1503_InitFinished - L1503_Init2))  ;size
L1503_Init2:
        ret

L1503_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1503_Check:
        DW ((L1503_CheckFinished - L1503_Check2))  ;size
L1503_Check2:
        ret

L1503_CheckFinished:
PRINTT "1503 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1503_LoadFinished - L1503_Load2)
PRINTT " / "
PRINTV (L1503_InitFinished - L1503_Init2)
PRINTT " / "
PRINTV (L1503_CheckFinished - L1503_Check2)
PRINTT "\n"

