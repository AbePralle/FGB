; l1204.asm Escape from the space station
; Generated 05.02.2001 by mlevel
; Modified  05.02.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level1204Gfx1",ROMX
;---------------------------------------------------------------------
gyro_screen_bg:
  INCBIN "..\\fgbpix\\ending\\gyro_screen.bg"

button_bg:
  INCBIN "..\\fgbpix\\ending\\button.bg"

minuteslater_bg:
  INCBIN "..\\fgbpix\\ending\\minuteslater.bg"

;---------------------------------------------------------------------
SECTION "Level1204Gfx2",ROMX
;---------------------------------------------------------------------
appland3d2_bg:
  INCBIN "..\\fgbpix\\ending\\appland3d2.bg"

appland_sprites_sp:
  INCBIN "..\\fgbpix\\ending\\appland_sprites.sp"

;---------------------------------------------------------------------
SECTION "Level1204Gfx2",ROMX
;---------------------------------------------------------------------
willtheyland_bg:
  INCBIN "..\\fgbpix\\promo\\willtheyland.bg"

haveseenthelast_bg:
  INCBIN "..\\fgbpix\\promo\\haveseenthelast.bg"

publish_bg:
  INCBIN "..\\fgbpix\\promo\\publish.bg"

;---------------------------------------------------------------------
SECTION "Level1204Section",ROMX
;---------------------------------------------------------------------

dialog:
l1204_gyro_notthere_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gyro_notthere.gtx"

l1204_gyro_ofcourse_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gyro_ofcourse.gtx"

l1204_gyro_unfortunately_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gyro_unfortunately.gtx"

l1204_gyro_explode_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gyro_explode.gtx"

l1204_gyro_escape_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gyro_escape.gtx"

l1204_gyro_button_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gyro_button.gtx"

l1204_gotitall_gtx:
  INCBIN "gtx\\apocalypse\\l1204_gotitall.gtx"

l1204_datahere_gtx:
  INCBIN "gtx\\apocalypse\\l1204_datahere.gtx"

l1204_letsroll_gtx:
  INCBIN "gtx\\apocalypse\\l1204_letsroll.gtx"

blank_gtx:
  INCBIN "gtx\\main_intro\\blank.gtx"

L1204_Contents::
  DW L1204_Load
  DW L1204_Init
  DW L1204_Check
  DW L1204_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1204_Load:
        DW ((L1204_LoadFinished - L1204_Load2))  ;size
L1204_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,BANK(gyro_screen_bg)
        ld      hl,gyro_screen_bg
        call    LoadCinemaBG

        ld      a,15
        call    SetupFadeFromBlack
        call    WaitFade

        ld      de,((.afterDialog-L1204_Load2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.notThere-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,30
        call    Delay

.notThere
        ld      c,0
        DIALOGBOTTOM l1204_gyro_notthere_gtx
        ld      de,((.ofCourse-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateGyroOnScreen


.ofCourse
        ld      c,0
        DIALOGBOTTOM   l1204_gyro_ofcourse_gtx
        ld      de,((.unfortunately-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateGyroOnScreen

.unfortunately
        ld      c,0
        DIALOGBOTTOM l1204_gyro_unfortunately_gtx
        ld      de,((.explode-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateGyroOnScreen

.explode
        ld      c,0
        DIALOGBOTTOM l1204_gyro_explode_gtx
        ld      de,((.escape-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateGyroOnScreen

.escape
        ld      c,0
        DIALOGBOTTOM l1204_gyro_escape_gtx
        ld      de,((.button-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateGyroOnScreen

.button
        call    ((.quickToBlack-L1204_Load2)+levelCheckRAM)
        ld      a,BANK(button_bg)
        ld      hl,button_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1204_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM l1204_gyro_button_gtx
        ld      de,((.minuteslater-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,15
.blinkLoop
        push    af
        ld      a,5
        call    Delay
        ld      bc,$1412
        ld      de,$0000
        ld      hl,$1400
        call    CinemaBlitRect

        ld      a,5
        call    Delay
        ld      bc,$1412
        ld      de,$0000
        ld      hl,$2800
        call    CinemaBlitRect
        pop     af
        dec     a
        jr      nz,.blinkLoop

.minuteslater
        call    ((.quickToBlack-L1204_Load2)+levelCheckRAM)
        ld      a,BANK(minuteslater_bg)
        ld      hl,minuteslater_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1204_Load2)+levelCheckRAM)
        ld      de,((.gotitall-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      a,120
        call    Delay

.gotitall
        call    ((.quickToBlack-L1204_Load2)+levelCheckRAM)
        ld      a,BANK(bs_bg)
        ld      hl,bs_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1204_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM l1204_gotitall_gtx
        ld      de,((.datahere-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS    AnimateBS

.datahere
        call    ((.quickToBlack-L1204_Load2)+levelCheckRAM)
        ld      a,BANK(haiku_bg)
        ld      hl,haiku_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1204_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM l1204_datahere_gtx
        ld      de,((.letsroll-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS    AnimateHaiku

.letsroll
        call    ((.quickToBlack-L1204_Load2)+levelCheckRAM)
        ld      a,BANK(bs_bg)
        ld      hl,bs_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1204_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM l1204_letsroll_gtx
        ld      de,((.descending-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,2
        LONGCALLNOARGS    AnimateBS

.afterDialog
.descending
        ld      de,0
        call    SetDialogForward

        ld      a,15
        call    SetupFadeToBlack
        call    WaitFade
        call    ResetSprites
        call    ClearDialog

        ld      a,BANK(appland3d2_bg)
        ld      hl,appland3d2_bg
        call    LoadCinemaBG

        ld      a,BANK(appland_sprites_sp)
        ld      hl,appland_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      c,0
        DIALOGBOTTOM blank_gtx

        ld      a,15
        call    SetupFadeFromBlack

        ;ld      de,((.willtheyland-L1204_Load2)+levelCheckRAM)
        ;call    SetDialogForward

        ld      c,24
.shipScroll1
        ld      d,1
        call    ScrollSpritesDown
        call    ((.shakeShip-L1204_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.shipScroll1

        ld      a,$11
        ldio    [scrollSpeed],a
        ld      a,30
        ld      [camera_j],a


        ld      a,48
.shipScrollLoop
        push    af
        ld      d,1
        call    ScrollSpritesDown
        call    ((.scrollTerrain-L1204_Load2)+levelCheckRAM)
        call    ((.shakeShip-L1204_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        pop     af
        dec     a
        jr      nz,.shipScrollLoop

.willtheyland
        call    ClearDialog
        ld      a,BANK(willtheyland_bg)
        ld      hl,willtheyland_bg
        call    LoadCinemaTextBox
        call    InstallGamePalette
        call    GfxShowStandardTextBox

        ld      de,((.haveseenthelast-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,120
        call    ((.scrollShakeDelay-L1204_Load2)+levelCheckRAM)

.haveseenthelast
        call    ClearDialog
        ld      a,BANK(haveseenthelast_bg)
        ld      hl,haveseenthelast_bg
        call    LoadCinemaTextBox
        call    InstallGamePalette
        call    GfxShowStandardTextBox

        ld      de,((.publish-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,120
        call    ((.scrollShakeDelay-L1204_Load2)+levelCheckRAM)

.publish
        call    ClearDialog
        ld      a,BANK(publish_bg)
        ld      hl,publish_bg
        call    LoadCinemaTextBox
        call    InstallGamePalette
        call    GfxShowStandardTextBox

        ld      de,((.tempEnd-L1204_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,120
        call    ((.scrollShakeDelay-L1204_Load2)+levelCheckRAM)

.tempEnd

.infi
        call    ((.scrollTerrain-L1204_Load2)+levelCheckRAM)
        call    ((.shakeShip-L1204_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        jr      .infi

        ret

.scrollShakeDelay
        push    af
        call    ((.scrollTerrain-L1204_Load2)+levelCheckRAM)
        call    ((.shakeShip-L1204_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        pop     af
        dec     a
        jr      nz,.scrollShakeDelay

.scrollTerrain
        ldio    a,[updateTimer]   ;frame * 6
        rrca
        and     %11
        ld      b,a
        ld      a,3
        sub     b
        rlca
        ld      b,a
        rlca
        add     b
        ld      l,a
        ld      h,$14
        ld      bc,$1406
        ld      de,$000c
        call    CinemaBlitRect
        ret

.shakeShip
        ;scroll ship vertical by value in shipSineTable
        ldio    a,[updateTimer]
        and     63
        add     (((.shipSineTable-L1204_Load2)+levelCheckRAM) & $ff)
        ld      l,a
        ld      a,0
        adc     ((((.shipSineTable-L1204_Load2)+levelCheckRAM)>>8) & $ff)
        ld      h,a
        ld      d,[hl]
        call    ScrollSpritesDown
        ret

.quickToBlack
        call    ClearDialog
        call    ResetSprites
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade
        ret

.quickFromBlack
        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade
        ret

.shipSineTable
  DB   1,  0,  0,255,  0,  1,  0,  0,254,  0,  0,  1,  0,  0,  0,  0
  DB   0,  2,  0,  0,255,  0,  0,  0,254,  0,  0,  0,  1,  0,  0,  0
  DB   0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
  DB   0,  0,  0,  0,  0,255,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0

L1204_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1204_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1204_Init:
        DW ((L1204_InitFinished - L1204_Init2))  ;size
L1204_Init2:
        ret

L1204_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1204_Check:
        DW ((L1204_CheckFinished - L1204_Check2))  ;size
L1204_Check2:
        ret

L1204_CheckFinished:
PRINTT "1204 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1204_LoadFinished - L1204_Load2)
PRINTT " / "
PRINTV (L1204_InitFinished - L1204_Init2)
PRINTT " / "
PRINTV (L1204_CheckFinished - L1204_Check2)
PRINTT "\n"

