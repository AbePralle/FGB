; l1400.asm Appomattox flying 
; Generated 02.21.2001 by mlevel
; Modified  02.21.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

VAR_DESTZONE  EQU 0
VAR_DESTCOLOR EQU 1
VAR_DESTBG    EQU 3
VAR_DESTBANK  EQU 5

VAR_SELSTAGE  EQU 6


;---------------------------------------------------------------------
SECTION "Level1402SectionLZ1",ROMX
;---------------------------------------------------------------------
lz_mist_bg::
  INCBIN "../fgbpix/appomattox/lz_mist.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ2",ROMX
;---------------------------------------------------------------------
lz_ice1_bg::
  INCBIN "../fgbpix/appomattox/lz_ice1.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ3",ROMX
;---------------------------------------------------------------------
lz_gate_bg::
  INCBIN "../fgbpix/appomattox/lz_gate.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ4",ROMX
;---------------------------------------------------------------------
lz_brokenwall_bg::
  INCBIN "../fgbpix/appomattox/lz_brokenwall.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ5",ROMX
;---------------------------------------------------------------------
lz_canyon_bg::
  INCBIN "../fgbpix/appomattox/lz_canyon.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ6",ROMX
;---------------------------------------------------------------------
lz_desert_bg::
  INCBIN "../fgbpix/appomattox/lz_desert.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ7",ROMX
;---------------------------------------------------------------------
lz_graves_bg::
  INCBIN "../fgbpix/appomattox/lz_graves.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ8",ROMX
;---------------------------------------------------------------------
lz_icecubes_bg::
  INCBIN "../fgbpix/appomattox/lz_icecubes.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ9",ROMX
;---------------------------------------------------------------------
lz_jungle_bg::
  INCBIN "../fgbpix/appomattox/lz_jungle.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ10",ROMX
;---------------------------------------------------------------------
lz_mountains_bg::
  INCBIN "../fgbpix/appomattox/lz_mountains.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ11",ROMX
;---------------------------------------------------------------------
lz_ocean_bg::
  INCBIN "../fgbpix/appomattox/lz_ocean.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ12",ROMX
;---------------------------------------------------------------------
lz_pencil_bg::
  INCBIN "../fgbpix/appomattox/lz_pencil.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionLZ13",ROMX
;---------------------------------------------------------------------
lz_treepath_bg::
  INCBIN "../fgbpix/appomattox/lz_treepath.bg"


;---------------------------------------------------------------------
SECTION "Level1402SectionData3",ROMX
;---------------------------------------------------------------------
lz_trees1_bg::
  INCBIN "../fgbpix/appomattox/lz_trees1.bg"

;---------------------------------------------------------------------
SECTION "Level1402SectionData2",ROMX
;---------------------------------------------------------------------
cloud0_bg::
  INCBIN "../fgbpix/appomattox/cloud0.bg"
cloud1_bg::
  INCBIN "../fgbpix/appomattox/cloud1.bg"
cloud2_bg::
  INCBIN "../fgbpix/appomattox/cloud2.bg"
cloud3_bg::
  INCBIN "../fgbpix/appomattox/cloud3.bg"
cloud4_bg::
  INCBIN "../fgbpix/appomattox/cloud4.bg"

;---------------------------------------------------------------------
SECTION "Level1400Section",ROMX
;---------------------------------------------------------------------

cloud5_bg::
  INCBIN "../fgbpix/appomattox/cloud5.bg"
cloud6_bg::
  INCBIN "../fgbpix/appomattox/cloud6.bg"
cloud7_bg::
  INCBIN "../fgbpix/appomattox/cloud7.bg"

L1400_Contents::
  DW L1400_Load
  DW L1400_Init
  DW L1400_Check
  DW L1400_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1400_Load:
        DW ((L1400_LoadFinished - L1400_Load2))  ;size
L1400_Load2:
        ld      a,1
        ld      [displayType],a
        xor     a
        ld      [scrollSprites],a

        ld      a,200
        ldio    [jiggleDuration],a

        ld      a,1
        ldio    [jiggleType],a    ;take-off jiggle

        ld      hl,musicEnabled  ;disable track 4
        res     3,[hl]

        ld      hl,((.engineSound1-L1400_Load2)+levelCheckRAM)
        call    PlaySound

        ld      a,$11
        ldio    [scrollSpeed],a


        ld      de,((.tookOff-L1400_Load2)+levelCheckRAM)
        call    SetDialogSkip
        call    SetDialogForward

        ld      a,60
        call    ((.delayAnimateWave-L1400_Load2)+levelCheckRAM)

        xor     a
        ld      [camera_j],a

        ld      hl,((.engineSound2-L1400_Load2)+levelCheckRAM)
        call    PlaySound

        ld      a,69
        call    ((.delayAdjustHorizon-L1400_Load2)+levelCheckRAM)

.tookOff
        ld      hl,((.silentSound4-L1400_Load2)+levelCheckRAM)
        call    PlaySound
        call    ClearSkipForward
        xor     a
        ldio    [jiggleDuration],a
        ld      [mapTop],a
        ld      a,1
        call    ((.delayAdjustHorizon-L1400_Load2)+levelCheckRAM)

        ld      hl,musicEnabled  ;enable track 4
        set     3,[hl]

        ld      a,1
        call    ((.setupFadeFromSky-L1400_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay

        ld      de,((.skipToLanding-L1400_Load2)+levelCheckRAM)
        call    SetDialogSkip
        call    SetDialogForward

.flying
        ld      a,BANK(cloud0_bg)
        ld      hl,cloud0_bg
        call    LoadCinemaBG

        ld      a,15
        call    ((.setupFadeToClouds-L1400_Load2)+levelCheckRAM)

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
        ld       hl,((.cloudFrames-L1400_Load2)+levelCheckRAM)
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
        call     ((.animateWave-L1400_Load2)+levelCheckRAM)

        ld       a,c
        inc      a
        and      7
        ld       c,a

        ld       a,b
        cp       20
        jr       nz,.afterStartFadeOutInClouds

        ld       a,15
        call    ((.setupFadeToSky-L1400_Load2)+levelCheckRAM)

.afterStartFadeOutInClouds
        dec      b
        jr       nz,.cloudAnim
        jr       .naturalLanding

.skipToLanding
        call    ClearSkipForward
        ld      a,15
        call    ((.setupFadeToSky-L1400_Load2)+levelCheckRAM)
        call    WaitFade

.naturalLanding
        ld      a,3
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1400_Load2)+levelCheckRAM)

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

        ld      de,((.landed-L1400_Load2)+levelCheckRAM)
        call    SetDialogSkip
        call    SetDialogForward

        ld      hl,musicEnabled  ;disable track 4
        res     3,[hl]
       
        ld      hl,((.engineSound1-L1400_Load2)+levelCheckRAM)
        call    PlaySound

        ld      a,40
        call    ((.delayAdjustHorizon-L1400_Load2)+levelCheckRAM)

        ld      a,2
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1400_Load2)+levelCheckRAM)

        ld      a,40
        call    ((.delayAdjustHorizon-L1400_Load2)+levelCheckRAM)

        ld      a,1
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1400_Load2)+levelCheckRAM)

        ld      hl,((.engineSound2-L1400_Load2)+levelCheckRAM)
        call    PlaySound

        ld      a,30
        call    ((.delayAdjustHorizon-L1400_Load2)+levelCheckRAM)

        xor     a
        ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1400_Load2)+levelCheckRAM)

        ld      a,30
        call    ((.delayAdjustHorizon-L1400_Load2)+levelCheckRAM)

        ld      hl,musicEnabled  ;enable track 4
        set     3,[hl]

        call    ((.powerDown-L1400_Load2)+levelCheckRAM)

.landed
        ld      hl,((.silentSound4-L1400_Load2)+levelCheckRAM)
        call    PlaySound
        xor     a
        ldio    [jiggleDuration],a
        call    ClearSkipForward
        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade
        call    ClearDialog
        ld      a,2
        call    Delay

        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,EXIT_N
        ld      [hl],a
        ld      hl,$1300
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.powerDown
        ;xor     a
        ;ld      [levelVars+VAR_SELSTAGE],a
        call    ((.setPowerBar-L1400_Load2)+levelCheckRAM)
        call    ((.recticleOff-L1400_Load2)+levelCheckRAM)
        call    ((.horizonOff-L1400_Load2)+levelCheckRAM)
        call    ((.diagramOff-L1400_Load2)+levelCheckRAM)
        ld      a,30
        call    ((.delayAnimateWave-L1400_Load2)+levelCheckRAM)
        ret

.silentSound4
  DB 4,0,0,0,$c0

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

        ;ld      hl,((.buttonSound-L1400_Load2)+levelCheckRAM)
        ;call    PlaySound
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
        call    ((.animateWave-L1400_Load2)+levelCheckRAM)

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
        ld      a,[hl+]
        ld      c,a
        ld      b,[hl]
        ;call    ((.getLandingInfo-L1400_Load2)+levelCheckRAM)
        ld      hl,fadeFinalPalette+8*7
        call    ((.setBG7-L1400_Load2)+levelCheckRAM)

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
        call    ((.setBG7-L1400_Load2)+levelCheckRAM)
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

        ;set final palette bg7 to be bg7 color 0
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

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

.buttonSound
  DB 1,$79,$80,$f1,$00,$87

.byte8
  DB 8

.delayAnimateWave
        push    af
        call    ((.animateWave-L1400_Load2)+levelCheckRAM)
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
        add     (((.waveFrameTable-L1400_Load2)+levelCheckRAM) & $ff)
        ld      l,a
        ld      a,0
        adc     ((((.waveFrameTable-L1400_Load2)+levelCheckRAM)>>8) & $ff)
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

L1400_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1400_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1400_Init:
        DW ((L1400_InitFinished - L1400_Init2))  ;size
L1400_Init2:
        ret

L1400_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1400_Check:
        DW ((L1400_CheckFinished - L1400_Check2))  ;size
L1400_Check2:
        ret

L1400_CheckFinished:
PRINTT "1400 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1400_LoadFinished - L1400_Load2)
PRINTT " / "
PRINTV (L1400_InitFinished - L1400_Init2)
PRINTT " / "
PRINTV (L1400_CheckFinished - L1400_Check2)
PRINTT "\n"

