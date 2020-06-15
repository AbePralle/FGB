;L1200 logo cinema
;Abe Pralle 5.2.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/gfx.inc"

TEMPKLUDGE EQU 50

;---------------------------------------------------------------------
SECTION "L1200DataSection",ROMX
;---------------------------------------------------------------------
logo160_bg:
  INCBIN "../fgbpix/logo/logo160.bg"

presents_bg:
  INCBIN "../fgbpix/logo/presents.bg"

fgbtitle_bg:
  INCBIN "../fgbpix/logo/fgbtitle.bg"

;---------------------------------------------------------------------
SECTION "L1200DataSection2",ROMX
;---------------------------------------------------------------------
kiwi1_bg::
  INCBIN "../fgbpix/Appomattox/kiwi1.bg"

kiwi2_bg::
  INCBIN "../fgbpix/Appomattox/kiwi2.bg"

kiwi3_bg::
  INCBIN "../fgbpix/Appomattox/kiwi3.bg"

landing_bg_bg::
  INCBIN "../fgbpix/Appomattox/landing_bg.bg"

landing_sprites_sp::
  INCBIN "../fgbpix/Appomattox/landing_sprites.sp"

;---------------------------------------------------------------------
SECTION "L1200DataSection3",ROMX
;---------------------------------------------------------------------
titlesprite_sp:
  INCBIN "../fgbpix/logo/titlesprite.sp"

ocloud0_bg:
  INCBIN "../fgbpix/logo/ocloud0.bg"

ocloud1_bg:
  INCBIN "../fgbpix/logo/ocloud1.bg"

;---------------------------------------------------------------------
SECTION "L1200DataSection4",ROMX
;---------------------------------------------------------------------
ocloud2_bg:
  INCBIN "../fgbpix/logo/ocloud2.bg"

ocloud3_bg:
  INCBIN "../fgbpix/logo/ocloud3.bg"


;---------------------------------------------------------------------
SECTION "L1200DataSection5",ROMX
;---------------------------------------------------------------------
ocloud4_bg:
  INCBIN "../fgbpix/logo/ocloud4.bg"

ocloud5_bg:
  INCBIN "../fgbpix/logo/ocloud5.bg"


;---------------------------------------------------------------------
SECTION "L1200DataSection6",ROMX
;---------------------------------------------------------------------
ocloud6_bg:
  INCBIN "../fgbpix/logo/ocloud6.bg"

ocloud7_bg:
  INCBIN "../fgbpix/logo/ocloud7.bg"


;---------------------------------------------------------------------
SECTION "L1200DataSection7",ROMX
;---------------------------------------------------------------------
ocloud8_bg:
  INCBIN "../fgbpix/logo/ocloud8.bg"

ocloud9_bg:
  INCBIN "../fgbpix/logo/ocloud9.bg"


;---------------------------------------------------------------------
SECTION "L1200DataSection8",ROMX
;---------------------------------------------------------------------
oclouda_bg:
  INCBIN "../fgbpix/logo/oclouda.bg"

ocloudb_bg:
  INCBIN "../fgbpix/logo/ocloudb.bg"


;---------------------------------------------------------------------
SECTION "L1200DataSection9",ROMX
;---------------------------------------------------------------------
ocloudc_bg:
  INCBIN "../fgbpix/logo/ocloudc.bg"

ocloudd_bg:
  INCBIN "../fgbpix/logo/ocloudd.bg"


;---------------------------------------------------------------------
SECTION "L1200DataSection10",ROMX
;---------------------------------------------------------------------
ocloude_bg:
  INCBIN "../fgbpix/logo/ocloude.bg"

ocloudf_bg:
  INCBIN "../fgbpix/logo/ocloudf.bg"

;---------------------------------------------------------------------
SECTION "L1200CodeSection",ROMX
;---------------------------------------------------------------------
L1200_Contents::
  DW L1200_Load
  DW L1200_Init
  DW L1200_Check
  DW L1200_Map

;---------------------------------------------------------------------
;  demo intro
;---------------------------------------------------------------------
L1200_Load:
        DW ((L1200_LoadFinished - L1200_Load)-2)  ;size
L1200_Load2:
        ;----------------plasmaworks logo----------------------
        ld       a,BANK(logo160_bg)
        ld       hl,logo160_bg
        call     LoadCinemaBG

        ld       a,1
        call     Delay

        ld       a,BANK(haiku_gbm)
        ld       hl,haiku_gbm
        call     InitMusic

        ld       de,((.endLogoCinema-L1200_Load2)+levelCheckRAM)
        call     SetDialogSkip
        ld       de,((.showPresents-L1200_Load2)+levelCheckRAM)
        call     SetDialogForward

        ld       a,16
        call     SetupFadeFromWhite
        call     WaitFade

        ld       a,30
        call     Delay

        ;----------------presents------------------------------
.showPresents
        ld       a,16
        call     SetupFadeToStandard
        call     WaitFade

        ld       a,BANK(presents_bg)
        ld       hl,presents_bg
        call     LoadCinemaBG

        ld       de,((.showTitle-L1200_Load2)+levelCheckRAM)
        call     SetDialogForward

        ld       a,16
        call     SetupFadeFromStandard
        call     WaitFade

        ld       a,27
        call     Delay

        ;----------------fgb title-----------------------------
.showTitle
        ld       a,16
        call     SetupFadeToStandard
        call     WaitFade

        ;ld       a,BANK(fgbtitle_bg)
        ;ld       hl,fgbtitle_bg
        ;call     LoadCinemaBG

        ld       a,BANK(ocloud0_bg)
        ld       hl,ocloud0_bg
        call     LoadCinemaBG

        ld       a,BANK(titlesprite_sp)
        ld       hl,titlesprite_sp
        call     LoadCinemaSprite
        ld       a,1
        call     Delay

        ld       de,((.endLogoCinema-L1200_Load2)+levelCheckRAM)
        call     SetDialogForward

        ld       a,16
        call     SetupFadeFromStandard
        call     WaitFade

        ld       b,32
        ld       c,1
.cloudAnim
        ;load next cloud frame
        ld       d,0    ;de = c*4
        ld       e,c
        sla      e
        rl       d
        sla      e
        rl       d
        ld       hl,((.cloudFrames-L1200_Load2)+levelCheckRAM)
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

        ld       a,c
        inc      a
        and      15
        ld       c,a

        dec      b
        jr       nz,.cloudAnim

.endLogoCinema
        ld       a,16
        call     SetupFadeToStandard
        call     WaitFade

        ld      hl,$1101
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

IF 0
.starfield
        ;----------------star field-----------------------------
        ld       a,BANK(starfield_bg)
        ld       hl,starfield_bg
        call     LoadCinemaBG

        ld       a,BANK(starfield_sprite_sp)
        ld       hl,starfield_sprite_sp
        call     LoadCinemaSprite

        ld      a,FADEBANK
        ld      [$ff70],a
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        ld       d,48 + (TEMPKLUDGE/2)
        call     ScrollSpritesLeft

        ld       d,48 + (TEMPKLUDGE/2)
        call     ScrollSpritesDown

        SETDIALOGSKIP(.afterIntro + (levelCheckRAM-L1200_Load2))

        ;number of cycles total 
        ld       b,180 + TEMPKLUDGE + 20

.loop
        push     bc

        call     (.clearPaletteToBlack + (levelCheckRAM-L1200_Load2))
        call     (.cycleColors + (levelCheckRAM-L1200_Load2))
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

        call     (.routine_thrustoff + (levelCheckRAM-L1200_Load2))
        jr       .afterThrust

.turnThrustOn
        call     (.routine_thruston + (levelCheckRAM-L1200_Load2))

.afterThrust
        dec      b
        jr       nz,.loop

        ld       a,16
        call     SetupFadeToStandard
        call     WaitFade
        ld       a,1
        call     Delay

        ;----------------approach kiwi-------------------------------
        ld       a,BANK(kiwi1_bg)
        ld       hl,kiwi1_bg
        call     LoadCinemaBG

        ld       a,16
        call     SetupFadeFromStandard
        call     WaitFade

        call     (.animate_ship + (levelCheckRAM-L1200_Load2))

        ld       a,16
        call     SetupFadeToBlackBGOnly
        call     WaitFade

        ;kiwi 2
        ld       a,BANK(kiwi2_bg)
        ld       hl,kiwi2_bg
        call     LoadCinemaBG

        ld       a,16
        call     SetupFadeFromBlackBGOnly
        call     WaitFade

        call     (.animate_ship + (levelCheckRAM-L1200_Load2))

        ld       a,16
        call     SetupFadeToBlackBGOnly
        call     WaitFade

        ;kiwi 3
        ld       a,BANK(kiwi3_bg)
        ld       hl,kiwi3_bg
        call     LoadCinemaBG

        ld       a,16
        call     SetupFadeFromBlackBGOnly
        call     WaitFade

        call     (.animate_ship + (levelCheckRAM-L1200_Load2))

        ld       a,16
        call     SetupFadeToBlack
        call     WaitFade

        ;----------------landing on kiwi-----------------------
        call     ResetSprites
        ld       a,BANK(landing_bg_bg)
        ld       hl,landing_bg_bg
        call     LoadCinemaBG
        ld       a,BANK(landing_sprites_sp)
        ld       hl,landing_sprites_sp
        call     LoadCinemaSprite

        ld       d,16
        call     ScrollSpritesRight
        ld       d,48
        call     ScrollSpritesUp

        ;set landing gear sprites and flame to off
        ld       hl,spriteOAMBuffer+6
        ld       c,8
        xor      a
.init_landing_loop
        ld       [hl+],a
        inc      hl
        inc      hl
        inc      hl
        dec      c
        jr       nz,.init_landing_loop


        SETDIALOGSKIP(.afterIntro + (levelCheckRAM-L1200_Load2))

        ;----------------animate descent of appomattox

        ;landing gear stowed
        ld       a,16
        call     SetupFadeFromBlack
        ld       b,45
.descent1
        push     bc
        ld       a,1
        call     Delay
        ld       d,1
        call     (.scrollDownAllSprites + (levelCheckRAM-L1200_Load2))
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
        ld       a,1
        call     Delay
        ld       a,1
        call     Delay
        ld       d,1
        call     (.scrollDownAllSprites + (levelCheckRAM-L1200_Load2))
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

        ld       b,28
.descent3
        push     bc
        ld       a,1
        call     Delay
        ld       a,1
        call     Delay
        ld       d,1
        call     (.scrollDownAllSprites + (levelCheckRAM-L1200_Load2))
        pop      bc

        dec      b
        jr       nz,.descent3


        ld       a,16
        call     SetupFadeToStandard
        ld       b,8
.descent4
        push     bc
        ld       a,1
        call     Delay
        ld       a,1
        call     Delay
        ld       a,1
        call     Delay
        ld       d,1
        call     (.scrollDownAllSprites + (levelCheckRAM-L1200_Load2))
        pop      bc

        dec      b
        jr       nz,.descent4

        ;ld       a,16
        ;call     SetupFadeToWhite
        call     WaitFade

.afterIntro
        ld       a,$05
        ld       [curLevelIndex],a
        ld       a,$02
        ld       [curLevelIndex+1],a

        ld       a,1
        ld       [timeToChangeLevel],a

        ret
ENDC

.show_pic
        ld       a,16
        call     SetupFadeFromStandard
        call     WaitFade

        ld       a,48
        call     Delay

        ret

IF 0
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
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;0
        inc      a
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;2
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;3
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;4
        inc      a
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;6
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
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;1
        ld       a,5
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;5
        inc      a
        call     (.setCycle + (levelCheckRAM-L1200_Load2))  ;7
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
        SETDIALOGSKIP(.afterIntro + (levelCheckRAM-L1200_Load2))
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
        call     (.routine_thrustoff + (levelCheckRAM-L1200_Load2))
        jr       .animate_check_done

.animate_thruston
        call     (.routine_thruston + (levelCheckRAM-L1200_Load2))

.animate_check_done
        dec      b
        jr       nz,.animate_loop

        pop      bc

        ret

.scrollDownAllSprites
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

ENDC

.cloudFrames
  DW BANK(ocloud0_bg), ocloud0_bg, BANK(ocloud1_bg), ocloud1_bg
  DW BANK(ocloud2_bg), ocloud2_bg, BANK(ocloud3_bg), ocloud3_bg
  DW BANK(ocloud4_bg), ocloud4_bg, BANK(ocloud5_bg), ocloud5_bg
  DW BANK(ocloud6_bg), ocloud6_bg, BANK(ocloud7_bg), ocloud7_bg
  DW BANK(ocloud8_bg), ocloud8_bg, BANK(ocloud9_bg), ocloud9_bg
  DW BANK(oclouda_bg), oclouda_bg, BANK(ocloudb_bg), ocloudb_bg
  DW BANK(ocloudc_bg), ocloudc_bg, BANK(ocloudd_bg), ocloudd_bg
  DW BANK(ocloude_bg), ocloude_bg, BANK(ocloudf_bg), ocloudf_bg

L1200_LoadFinished:

PRINTT "  1200 Level Load Size: "
PRINTV (L1200_LoadFinished - L1200_Load2)
PRINTT "/$500 bytes\n"


L1200_Map:

;gtx_app_closed_gate_bs5:  INCBIN  "Data/Dialog/Landing/app_closed_gate_bs5.gtx"

L1200_Init:
        DW ((L1200_InitFinished - L1200_Init)-2)  ;size
L1200_Init2:
        ret

L1200_InitFinished:


L1200_Check:
        DW ((L1200_CheckFinished - L1200_Check) - 2)  ;size
L1200_Check2:
L1200_CheckOffset EQU (levelCheckADDR - L1200_Check2)
        ret

L1200_CheckFinished:

PRINTT "  1200 Level Check Size: "
PRINTV (L1200_CheckFinished - L1200_Check2)
PRINTT "/$500 bytes\n"

