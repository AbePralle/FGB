; l1302.asm gyves cornered cinema
; Generated 07.31.2000 by mlevel
; Modified  07.31.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1302Section",ROMX
;---------------------------------------------------------------------

L1302_Contents::
  DW L1302_Load
  DW L1302_Init
  DW L1302_Check
  DW L1302_Map

gyro_cornered_bg:
  INCBIN "..\\fgbpix\\main_intro\\gyrocornered.bg"

gyro_cornered_gun_sp:
  INCBIN "..\\fgbpix\\main_intro\\gyro_cornered_gun.sp"

dialog:
gyro_cornered1_gtx:
  INCBIN "gtx\\main_intro\\gyro_cornered1.gtx"

gyro_cornered2_gtx:
  INCBIN "gtx\\main_intro\\gyro_cornered2.gtx"

gyro_cornered3_gtx:
  INCBIN "gtx\\main_intro\\gyro_cornered3.gtx"

gyro_cornered4_gtx:
  INCBIN "gtx\\main_intro\\gyro_cornered4.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1302_Load:
        DW ((L1302_LoadFinished - L1302_Load2))  ;size
L1302_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      a,BANK(gyro_cornered_bg)
        ld      hl,gyro_cornered_bg
        call    LoadCinemaBG

        ld      a,BANK(gyro_cornered_gun_sp)
        ld      hl,gyro_cornered_gun_sp
        call    LoadCinemaSprite

        ld      d,162
        call    ScrollSpritesRight

        ld      d,40
        call    ScrollSpritesDown

        ;cur palette to game palette + gun quarter-bright
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ;fade from black to gun quarter-bright
        ;cur palette to all white
        ld      hl,fadeCurPalette
        call    FadeCommonSetPaletteToBlack

        ld      hl,fadeFinalPalette + 64
        ld      d,8
        call    ((.paletteToQuarterBright - L1302_Load2) + levelCheckRAM)

        ld      a,16
        call    FadeInit
        call    WaitFade

        ld      de,((.endCinema - L1302_Load2) + levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.dialog1 - L1302_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,16
        call    Delay

        ;----focus on gun---------------------------------------------
        call    ((.setupFadeToFocusOnGun-L1302_Load2) + levelCheckRAM)
        ld      a,60
        call    FadeInit

        ;slide gun out as fade is happening
        ld      c,60
.slideGunOutLoop
        ld      d,1
        call    ScrollSpritesLeft
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.slideGunOutLoop

        ld      a,30
        call    Delay

        ld      a,BANK(gyro_cornered1_gtx)
        ld      c,0
        ld      de,gyro_cornered1_gtx
        call    ShowDialogAtBottomNoWait

.dialog1
        call    ((.showGunForSure - L1302_Load2) + levelCheckRAM)
        ;----gyro says wait-------------------------------------------
        ld      de,((.dialog2 - L1302_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      b,3
        call    ((.animateGyro-L1302_Load2)+levelCheckRAM)

        ;----focus on gyro--------------------------------------------
        call    ((.setupFadeToFocusOnGyro-L1302_Load2) + levelCheckRAM)
        ld      a,60
        call    FadeInit

        ld      c,120
        ld      b,0
.hideGunLoop
        ld      a,b
        srl     a
        and     1
        ld      d,a
        call    ScrollSpritesRight
        ld      a,1
        call    Delay
        inc     b
        dec     c
        jr      nz,.hideGunLoop

.dialog2
        call    ((.hideGunForSure - L1302_Load2) + levelCheckRAM)
        ;----gyro makes the deal--------------------------------------
        ld      de,((.dialog3 - L1302_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(gyro_cornered2_gtx)
        ld      c,0
        ld      de,gyro_cornered2_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,4
        call    ((.animateGyro-L1302_Load2)+levelCheckRAM)

.dialog3
        ld      de,((.dialog4 - L1302_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(gyro_cornered3_gtx)
        ld      c,0
        ld      de,gyro_cornered3_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,5
        call    ((.animateGyro-L1302_Load2)+levelCheckRAM)

.dialog4
        ld      de,((.endCinema - L1302_Load2) + levelCheckRAM)
        call    SetDialogForward

        ld      a,BANK(gyro_cornered4_gtx)
        ld      c,0
        ld      de,gyro_cornered4_gtx
        call    ShowDialogAtBottomNoWait

        ld      b,5
        call    ((.animateGyro-L1302_Load2)+levelCheckRAM)

.endCinema
        call    ClearDialog
        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ld      hl,$1202
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.animateGyro
        ;b already set up with # of loops
        sla     b       ;b*=4
        sla     b
.gyroEyes
        ld      c,4

.gyroTalk
        push    bc
        ld      a,3
        call    Delay

        ld      a,b
        cp      8
        ld      a,2
        jr      nc,.animate
        ld      a,1

.animate
        ;animate mouth
        ld      bc,$0604
        ld      de,$0806
        ld      hl,$1402
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.gyroTalk

        ;animate eye
        push    bc
        ld      a,4
        ld      bc,$0202
        ld      de,$0704
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     b
        jr      nz,.gyroEyes

        ;open eye at end
        ld      a,1
        ld      bc,$0202
        ld      de,$0704
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        ld      a,10
        call    Delay
        ret

.paletteToQuarterBright
        push    bc
        push    de
        push    hl
        ld      a,FADEBANK
        ldio    [$ff70],a

.quarterBrightLoop
        ld      a,[hl+]
        ld      c,a
        ld      a,[hl-]
        ld      b,a
        call    GetRedComponent
        srl     a
        srl     a
        call    SetRedComponent
        call    GetGreenComponent
        srl     a
        srl     a
        call    SetGreenComponent
        call    GetBlueComponent
        srl     a
        srl     a
        call    SetBlueComponent
        ld      a,c
        ld      [hl+],a
        ld      a,b
        ld      [hl+],a
        dec     d
        jr      nz,.quarterBrightLoop
        pop     hl
        pop     de
        pop     bc
        ret

.setupFadeToFocusOnGun
        ld      a,FADEBANK
        ldio    [$ff70],a
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeFinalPalette + 8
        ld      d,28
        call    ((.paletteToQuarterBright - L1302_Load2) + levelCheckRAM)
        ld      hl,fadeCurPalette + 64
        ld      d,8
        call    ((.paletteToQuarterBright - L1302_Load2) + levelCheckRAM)
        ret

.setupFadeToFocusOnGyro
        ld      a,FADEBANK
        ldio    [$ff70],a
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeFinalPalette + 64
        ld      d,8
        call    ((.paletteToQuarterBright-L1302_Load2)+levelCheckRAM)
        ld      hl,fadeCurPalette + 8
        ld      d,28
        call    ((.paletteToQuarterBright-L1302_Load2)+levelCheckRAM)
        ret

.showGunForSure
        ld      hl,spriteOAMBuffer + 1
        ld      a,[hl]    ;first sprite x pos
        sub     102+8     ;minus desired x pos
        ld      d,a
        call    ScrollSpritesLeft   ;is amount to scroll sprites

        call    ((.setupFadeToFocusOnGun-L1302_Load2) + levelCheckRAM)
        ld      a,1
        call    FadeInit
        ret

.hideGunForSure
        ld      hl,spriteOAMBuffer + 1
        ld      a,162+8   ;desired x pos
        sub     [hl]      ;minus first sprite x pos
        ld      d,a
        call    ScrollSpritesRight   ;is amount to scroll sprites

        call    ((.setupFadeToFocusOnGyro-L1302_Load2)+levelCheckRAM)
        ld      a,1
        call    FadeInit
        ret

L1302_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1302_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1302_Init:
        DW ((L1302_InitFinished - L1302_Init2))  ;size
L1302_Init2:
        ret

L1302_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1302_Check:
        DW ((L1302_CheckFinished - L1302_Check2))  ;size
L1302_Check2:
        ret

L1302_CheckFinished:
PRINTT "1302 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1302_LoadFinished - L1302_Load2)
PRINTT " / "
PRINTV (L1302_InitFinished - L1302_Init2)
PRINTT " / "
PRINTV (L1302_CheckFinished - L1302_Check2)
PRINTT "\n"

