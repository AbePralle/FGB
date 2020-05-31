; L1402.asm lady flower intervenes
; Generated 08.13.2000 by mlevel
; Modified  08.13.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level1402SectionData2",ROMX
;---------------------------------------------------------------------
spacepan_bg:
  INCBIN "../fgbpix/distress/spacepan.bg"

final_bg:
  INCBIN "../fgbpix/distress/final.bg"

;---------------------------------------------------------------------
SECTION "Level1402Section",ROMX
;---------------------------------------------------------------------

L1402_Contents::
  DW L1402_Load
  DW L1402_Init
  DW L1402_Check
  DW L1402_Map

moon_mini_bg:
  INCBIN "../fgbpix/distress/moon_mini.bg"

palace_bg:
  INCBIN "../fgbpix/distress/palace.bg"

flowernight_bg:
  INCBIN "../fgbpix/distress/flowernight.bg"
  
fgstars_sp:
  INCBIN "../fgbpix/distress/fgstars.sp"

yacht_mini_sp:
  INCBIN "../fgbpix/distress/yacht_mini.sp"

bee_sp:
  INCBIN "../fgbpix/distress/bee.sp"

dialog:
lady_badNews_gtx:
  INCBIN "Data/Dialog/distress/lady_badNews.gtx"

lady_dispatched_gtx:
  INCBIN "Data/Dialog/distress/lady_dispatched.gtx"

lady_surrender_gtx:
  INCBIN "Data/Dialog/distress/lady_surrender.gtx"

lady_bigBullies_gtx:
  INCBIN "Data/Dialog/distress/lady_bigBullies.gtx"

lady_poorCaptain_gtx:
  INCBIN "Data/Dialog/distress/lady_poorCaptain.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
VAR_BEEPOS EQU 0

L1402_Load:
        DW ((L1402_LoadFinished - L1402_Load2))  ;size
L1402_Load2:
        ld      hl,$1402
        call    SetJoinMap

        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,BANK(moon_bg)
        ld      hl,moon_bg
        call    LoadCinemaBG

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ;center moon in stars
        ;right top stars to bottom
        ld      bc,$1406
        ld      hl,$1406
        ld      de,$140c
        call    CinemaBlitRect
        ld      a,1
        call    Delay
        
        ;left moon centered in right
        ld      bc,$140c
        ld      hl,$0000
        ld      de,$1403
        call    CinemaBlitRect
        ld      a,1
        call    Delay

        ;right to left
        ld      bc,$1412
        ld      hl,$1400
        ld      de,$0000
        call    CinemaBlitRect
        ld      a,1
        call    Delay

        ld      a,48
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.endCinema-L1402_Load2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.showMoonMini-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,32
        call    Delay

.showMoonMini
        call    ((.fadeToBlack32-L1402_Load2)+levelCheckRAM)

        ld      a,BANK(moon_mini_bg)
        ld      hl,moon_mini_bg
        call    LoadCinemaBG

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.showSpacePan-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,32
        call    Delay

.showSpacePan
        call    ((.fadeToBlack32-L1402_Load2)+levelCheckRAM)

        ld      a,BANK(spacepan_bg)
        ld      hl,spacepan_bg
        call    LoadCinemaBG

        ld      a,BANK(fgstars_sp)
        ld      hl,fgstars_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.showKiwi-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,32
        call    Delay

        ld      a,$44
        ld      [scrollSpeed],a

        ld      a,117
        ld      [camera_i],a

        ld      c,4
.stars1
        ld      a,1
        call    Delay
        ld      d,2
        call    ScrollSpritesLeft
        dec     c
        jr      nz,.stars1


        ld      a,$82
        ld      [scrollSpeed],a

        ld      c,150
.stars2
        ld      a,1
        call    Delay
        ld      a,[mapLeft]
        cp      108
        jr      nc,.afterStarScroll
        ld      d,4
        call    ScrollSpritesLeft
.afterStarScroll
        dec     c
        jr      nz,.stars2

.showKiwi
        call    ((.fadeToBlack32-L1402_Load2)+levelCheckRAM)
        call    ResetSprites

        ld      a,BANK(kiwi1_bg)
        ld      hl,kiwi1_bg
        call    LoadCinemaBG

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.showPalace1-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,32
        call    Delay

.showPalace1
        call    ((.fadeToBlack32-L1402_Load2)+levelCheckRAM)

        ld      a,BANK(palace_bg)
        ld      hl,palace_bg
        call    LoadCinemaBG

        ld      a,BANK(yacht_mini_sp)
        ld      hl,yacht_mini_sp
        call    LoadCinemaSprite
        ;set bg priority
        ld      hl,spriteOAMBuffer+3
        set     7,[hl]
        ld      hl,spriteOAMBuffer+7
        set     7,[hl]

        ld      a,28
        ld      [camera_j],a
        ld      a,18
        ld      [mapTop],a

        ld      a,1
        call    Delay

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.showLadyFlower-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,32
        call    Delay

.showLadyFlower
        call    ((.fadeToBlack32-L1402_Load2)+levelCheckRAM)
        call    ResetSprites

        ld      a,BANK(lady_flower_gbm)
        ld      hl,lady_flower_gbm
        call    InitMusic

        xor     a
        ld      [levelVars + VAR_BEEPOS],a

        ld      a,BANK(flowernight_bg)
        ld      hl,flowernight_bg
        call    LoadCinemaBG

        ld      a,BANK(bee_sp)
        ld      hl,bee_sp
        call    LoadCinemaSprite

        ;clear the sprites of bee's other two frames
        ld      hl,spriteOAMBuffer+8
        xor     a
        ld      [hl+],a  ;ypos to zero
        inc     hl
        inc     hl
        inc     hl
        ld      [hl+],a  ;ypos to zero

        ld      d,16
        call    ScrollSpritesRight
        ld      d,16 
        call    ScrollSpritesDown

        ld      a,1
        call    Delay

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.dialog1-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,1  ;get her to open her eyes
        LONGCALLNOARGS AnimateLadyFlower

.dialog1
        ld      c,0
        DIALOGBOTTOM lady_badNews_gtx
        ld      de,((.dialog2-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,2
        LONGCALLNOARGS AnimateLadyFlower

.dialog2
        ld      c,0
        DIALOGBOTTOM lady_dispatched_gtx
        ld      de,((.dialog3-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateLadyFlower

.dialog3
        ld      c,0
        DIALOGBOTTOM lady_surrender_gtx
        ld      de,((.dialog4-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,6
        LONGCALLNOARGS AnimateLadyFlower

.dialog4
        ld      c,0
        DIALOGBOTTOM lady_bigBullies_gtx
        ld      de,((.dialog5-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateLadyFlower

.dialog5
        ld      c,0
        DIALOGBOTTOM lady_poorCaptain_gtx
        ld      de,((.showPalace2-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,6
        LONGCALLNOARGS AnimateLadyFlower

.showPalace2
        call    ClearDialog
        ld      a,32
        call    SetupFadeToBlack
.waitFadeBee
        call    ((.animateBee-L1402_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        ld      a,[specialFX]
        and     FX_FADE
        jr      nz,.waitFadeBee
        
        call    ResetSprites
        ld      a,BANK(palace_bg)
        ld      hl,palace_bg
        call    LoadCinemaBG

        ld      a,BANK(yacht_mini_sp)
        ld      hl,yacht_mini_sp
        call    LoadCinemaSprite

        ld      a,28
        ld      [camera_j],a
        ld      a,18
        ld      [mapTop],a
        ld      a,1
        call    Delay

        ;set bg priority
        ld      hl,spriteOAMBuffer+3
        set     7,[hl]
        ld      hl,spriteOAMBuffer+7
        set     7,[hl]

        ;sprites don't scroll with the bg
        xor     a
        ld      [scrollSprites],a
        ld      a,$11
        ld      [scrollSpeed],a   ;bg scroll speed

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.endCinema-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ;----take off-------------------------------------------------
        ;setup a fade
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    CopyPalette32
        ld      de,fadeFinalPalette
        call    CopyPalette32

        ;set the final  palette's first 6 BG colors to dark purple
        ld      c,6
        ld      de,6 
        ld      hl,fadeFinalPalette
.setPurpleLoop
        ld      [hl],$04
        inc     hl
        ld      [hl],$10
        inc     hl
        add     hl,de
        dec     c
        jr      nz,.setPurpleLoop
        ld      a,14*8
        call    FadeInit

        ;set the camera to pan up
        xor     a
        ld      [camera_j],a

        ld      c,14*8
.takeoffLoop
        push    bc
        ld      a,1
        call    Delay

        ;scroll the ship sprites up 1 pixel
        ;ld      hl,spriteOAMBuffer
        ;dec     [hl]
        ;ld      hl,spriteOAMBuffer+4
        ;dec     [hl]

        call    ((.scrollMoons-L1402_Load2)+levelCheckRAM)

        pop     bc
        dec     c
        jr      nz,.takeoffLoop

        ;accellerate offscreen
        ld      hl,fadeFinalPalette
        ld      de,fadeCurPalette
        call    CopyPalette32
        ld      hl,fadeFinalPalette
        call    FadeCommonSetPaletteToBlack
        ld      hl,fadeFinalPalette
        ld      de,gamePalette
        call    CopyPalette32
        ld      a,14*8
        call    FadeInit

        ld      c,14*8
.accelerateLoop
        push    bc
        ld      a,1
        call    Delay

        ;scroll the ship sprites up 1 pixel
        ld      hl,spriteOAMBuffer
        dec     [hl]
        ld      hl,spriteOAMBuffer+4
        dec     [hl]

        call    ((.scrollMoons-L1402_Load2)+levelCheckRAM)
        call    ((.scrollMoons-L1402_Load2)+levelCheckRAM)

        pop     bc
        dec     c
        jr      nz,.accelerateLoop

.endCinema
        call    ClearDialog
        ld      a,16
        call    SetupFadeToBlack
        call    WaitFade
        call    ResetSprites

IF 0
        ld      a,BANK(final_bg)
        ld      hl,final_bg
        call    LoadCinemaBG

        call    ((.fadeFromBlack32-L1402_Load2)+levelCheckRAM)

        ld      de,((.backToMenu-L1402_Load2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.backToMenu-L1402_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,150
        call    Delay

.backToMenu
;.infi 
        ;ld      a,1
        ;call    Delay  ;upkeep so remote game won't freak
;jr .infi
ENDC
        ;ld      de,0
        ;call    SetDialogSkip
        ;call    SetDialogForward

        ;ld      a,16
        ;call    SetupFadeToStandard
        ;call    WaitFade

        ;ld      hl,fadeFinalPalette
        ;ld      de,gamePalette
        ;call    CopyPalette64
        ;ld      de,fadeCurPalette
        ;call    CopyPalette64

        ld      hl,$1502
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,2
        ld      [timeToChangeLevel],a

        ret

;----support routines-------------------------------------------------
.fadeToBlack32
        ld      a,32
        call    SetupFadeToBlack
        call    WaitFade
        ret

.fadeFromBlack32
        ld      a,32
        call    SetupFadeFromBlack
        call    WaitFade
        ret

.animateBee
        ;bee y position
        ld      a,[levelVars + VAR_BEEPOS]
        add     2
        ld      [levelVars + VAR_BEEPOS],a
        cp      128
        jr      c,.beeDirectionChosen
        ld      b,a     ;a = 255 - a
        ld      a,255
        sub     b
.beeDirectionChosen
        sub     64
        rlca          ;get sign bit in bit 7
        sra     a
        sra     a
        sra     a
        sra     a

        ;adjust y coord
        ld      hl,spriteOAMBuffer
        add     40
        ld      [hl],a
        ld      hl,spriteOAMBuffer+4
        ld      [hl],a

        ;adjust animation frame
        ldio    a,[updateTimer]
        rlca
        rlca
        and     %100
        ld      hl,spriteOAMBuffer + 2
        ld      [hl],a
        inc     a
        inc     a
        ld      hl,spriteOAMBuffer + 6
        ld      [hl],a

        ret

.scrollMoons
        ;scroll the 13 moon sprites down 1 pixel every other time
        ld      a,[updateTimer]
        and     1
        ret     z
        ld      c,13
        ld      hl,spriteOAMBuffer+8
.scrollMoonsLoop
        inc     [hl]
        ld      a,l
        add     4
        ld      l,a
        dec     c
        jr      nz,.scrollMoonsLoop
        ret

L1402_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1402_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1402_Init:
        DW ((L1402_InitFinished - L1402_Init2))  ;size
L1402_Init2:
        ret

L1402_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1402_Check:
        DW ((L1402_CheckFinished - L1402_Check2))  ;size
L1402_Check2:
        ret

L1402_CheckFinished:
PRINTT "1402 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1402_LoadFinished - L1402_Load2)
PRINTT " / "
PRINTV (L1402_InitFinished - L1402_Init2)
PRINTT " / "
PRINTV (L1402_CheckFinished - L1402_Check2)
PRINTT "\n"

