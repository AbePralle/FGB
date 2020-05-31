;leveL1100 character select
;Abe Pralle 4.3.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/gfx.inc"
INCLUDE "Source/start.inc"

EXITAPPOMATTOX EQU $1300
;EXITAPPOMATTOX EQU $0812
;EXITAPPOMATTOX EQU $0107


;---------------------------------------------------------------------
SECTION "L1100Gfx1",ROMX
;---------------------------------------------------------------------
select_grenade_sp:
  INCBIN "../fgbpix/charselect/select_grenade.sp"

select_grenade_name_bg:
  INCBIN "../fgbpix/charselect/kgname.bg"

;---------------------------------------------------------------------
SECTION "L1100Section",ROMX
;---------------------------------------------------------------------

select_hero_bg:
  INCBIN "../fgbpix/charselect/charselecthills.bg"

select_ba_sp:
  INCBIN "charselect/select_ba.sp"

select_ba_name_bg:
  INCBIN "../fgbpix/charselect/select_ba_name.bg"

select_bs_sp:
  INCBIN "charselect/select_bs.sp"

select_bs_name_bg:
  INCBIN "../fgbpix/charselect/select_bs_name.bg"

select_haiku_sp:
  INCBIN "charselect/select_haiku.sp"

select_haiku_name_bg:
  INCBIN "../fgbpix/charselect/select_haiku_name.bg"

L1100_Contents::
  DW L1100_Load
  DW L1100_Init
  DW L1100_Check
  DW L1100_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1100_Load:
        DW ((L1100_LoadFinished - L1100_Load)-2)  ;size
L1100_Load2:
        ld      hl,$1100
        call    SetJoinMap
        ld      hl,EXITAPPOMATTOX
        call    SetRespawnMap

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

;ld a,[heroesAvailable]
;or HERO_GRENADE_FLAG
;ld [heroesAvailable],a
        xor     a
        ld      [scrollSprites],a

        ld      a,$44
        ldio    [scrollSpeed],a

        ld      a,BANK(select_hero_bg)
        ld      hl,select_hero_bg
        call    LoadCinemaBG

        xor     a
        ld      [gamePalette+2],a
        ld      [gamePalette+3],a

        ;if my hero type is the same as both hero types (e.g. the other 
        ;hero's types) then pick an alternate hero (probably just
        ;joined game)
        LDHL_CURHERODATA HERODATA_TYPE
        ld      b,[hl]
        ld      a,[hero0_type]
        cp      b 
        jr      nz,.myTypeOkay
        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.myTypeOkay   ;no link
        ld      a,[hero1_type]
        cp      b
        jr      nz,.myTypeOkay

        ;change my type
        cp      1
        jr      z,.changeTypeTo2
        ld      a,1
        jr      .pickedANewType
.changeTypeTo2
        ld      a,2
.pickedANewType
        ld      [hl],a
.myTypeOkay
        ;mark my hero as used
        ld      b,[hl]
        ld      a,[heroesUsed]
        or      b
        ld      [heroesUsed],a
        call    UpdateRemoteHeroesUsed

        call    ((.loadCurHeroSprite-L1100_Load2)+levelCheckRAM)
        ld      d,160
        call    ScrollSpritesRight

        ld      hl,((CharSelectOnHBlank-L1100_Load2)+levelCheckRAM)
        call    InstallHBlankHandler
        ld      a,1
        call    SetupFadeFromStandard
        ld      a,120
        ld      [camera_i],a

        ld      d,160
        call    ScrollSpritesLeft
        call    ((.scrollInFromRight-L1100_Load2)+levelCheckRAM)

.waitInputLoop
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,[myJoy]
        bit     JOY_RIGHT_BIT,a
        jr      z,.checkLeft

        call    ((.nextHeroRight-L1100_Load2)+levelCheckRAM)
        jp      ((.waitContinue-L1100_Load2)+levelCheckRAM)

.checkLeft
        bit     JOY_LEFT_BIT,a
        jr      z,.checkExit

        call    ((.nextHeroLeft-L1100_Load2)+levelCheckRAM)
        jr      .waitContinue

.checkExit
        bit     JOY_A_BIT,a
        jr      nz,.exit
        bit     JOY_START_BIT,a
        jr      z,.waitContinue

.exit
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        cp      HERO_BA_FLAG
        jr      nz,.exitCheckBS
        ld      de,BA_CINDEX
        jr      .exitGotHeroClass
.exitCheckBS
        cp      HERO_BS_FLAG
        jr      nz,.exitCheckHaiku
        ld      de,BS_CINDEX
        jr      .exitGotHeroClass
.exitCheckHaiku
        cp      HERO_HAIKU_FLAG
        jr      nz,.exitCheckGrenade
        ld      de,HAIKU_CINDEX
        jr      .exitGotHeroClass
.exitCheckGrenade
        ld      de,KGRENADE_CINDEX
.exitGotHeroClass
        LDHL_CURHERODATA HERODATA_CLASS
        ld      a,e
        ld      [hl+],a
        ld      a,d
        ld      [hl+],a
        LDHL_CURHERODATA HERODATA_HEALTH
        xor     a
        ld      [hl],a
        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,EXIT_D
        ld      [hl],a
        ld      hl,EXITAPPOMATTOX
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        call    ClearDialog
        ld      hl,OnHBlank
        call    InstallHBlankHandler
        ld      a,1
        call    SetupFadeToStandard
        ld      a,1
        call    Delay
        call    ResetSprites
        ret

.waitContinue
        ld      a,1
        call    Delay
        jp      ((.waitInputLoop-L1100_Load2)+levelCheckRAM)
        ret

;----Support Routines-------------------------------------------------
.nextHeroRight
        ;wait until I can lock heroesUsed
        call    LockRemoteHeroesUsed
        jr      nz,.heroesLockedRight
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        jr      .nextHeroRight

.heroesLockedRight
        ;if no link set all to unused (fix used hero on broken link)
        ld      a,[amLinkMaster]
        bit     7,a
        jr      z,.unlockMyHeroRight   ;has link

        ;mark all as unused
        xor     a
        ld      [heroesUsed],a
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        jr      .pickNewRotateRight

.unlockMyHeroRight
        ;mark cur hero as unused
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        push    af
        xor     $ff
        ld      hl,heroesUsed
        and     [hl]
        ld      [hl],a
        pop     af

.pickNewRotateRight
        ;pick new by rotating right until matches available
        ld      b,a
        ld      a,[heroesUsed]
        xor     $ff
        ld      c,a
        ld      a,[heroesAvailable]
        and     c
        ld      c,a
.nextHeroLeftLoop
        rrc     b
        ld      a,c
        or      b
        cp      c
        jr      nz,.nextHeroLeftLoop

        LDHL_CURHERODATA HERODATA_TYPE
        ld      [hl],b     ;found new hero
        ld      a,[heroesUsed]
        or      b
        ld      [heroesUsed],a
        call    UpdateRemoteHeroesUsed
        call    ((.scrollOutToLeft-L1100_Load2)+levelCheckRAM)
        call    ((.loadCurHeroSprite-L1100_Load2)+levelCheckRAM)
        call    ((.scrollInFromRight-L1100_Load2)+levelCheckRAM)
        ret

.nextHeroLeft
        ;wait until I can lock heroesUsed
        call    LockRemoteHeroesUsed
        jr      nz,.heroesLockedLeft
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        jr      .nextHeroLeft

.heroesLockedLeft
        ;if no link set all to unused (fix used hero on broken link)
        ld      a,[amLinkMaster]
        bit     7,a
        jr      z,.unlockMyHeroLeft   ;has link

        ;mark all as unused
        xor     a
        ld      [heroesUsed],a
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        jr      .pickNewRotateLeft

.unlockMyHeroLeft
        ;mark cur hero as unused
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        push    af
        xor     $ff
        ld      hl,heroesUsed
        and     [hl]
        ld      [hl],a
        pop     af

.pickNewRotateLeft
        ;pick new by rotating left until matches available
        ld      b,a
        ld      a,[heroesUsed]
        xor     $ff
        ld      c,a
        ld      a,[heroesAvailable]
        and     c
        ld      c,a
.nextHeroRightLoop
        rlc     b
        ld      a,c
        or      b
        cp      c
        jr      nz,.nextHeroRightLoop

        LDHL_CURHERODATA HERODATA_TYPE
        ld      [hl],b     ;found new hero
        ld      a,[heroesUsed]
        or      b
        ld      [heroesUsed],a
        call    UpdateRemoteHeroesUsed
        call    ((.scrollOutToRight-L1100_Load2)+levelCheckRAM)
        call    ((.loadCurHeroSprite-L1100_Load2)+levelCheckRAM)
        call    ((.scrollInFromLeft-L1100_Load2)+levelCheckRAM)
        ret

.scrollInFromRight
        ;scroll sprites out of view to the right
        ld      d,160
        call    ScrollSpritesRight
        ld      a,[specialFX]
        and     FX_FADE
        jr      nz,.afterInstallPaletteRight
        call    InstallGamePalette
.afterInstallPaletteRight
        call    GfxShowStandardTextBox

        ;scroll sprites into view
        ld      c,24
.scrollInFromRightLoop
        ld      d,5
        call    ScrollSpritesLeft
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.scrollInFromRightLoop
        ret

.scrollInFromLeft
        ;scroll sprites out of view to the left
        ld      d,80
        call    ScrollSpritesLeft
        ld      a,[specialFX]
        and     FX_FADE
        jr      nz,.afterInstallPaletteLeft
        call    InstallGamePalette
.afterInstallPaletteLeft
        call    GfxShowStandardTextBox

        ;scroll sprites into view from left
        ld      c,24
.scrollInFromLeftLoop
        ld      d,5
        call    ScrollSpritesRight
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.scrollInFromLeftLoop
        ret

.scrollOutToRight
        call    ClearDialog
        ld      c,20
.scrollOutToRightLoop
        ld      d,6
        call    ScrollSpritesRight
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.scrollOutToRightLoop
        call    ResetSprites
        ret

.scrollOutToLeft
        call    ClearDialog
        ld      c,20
.scrollOutToLeftLoop
        ld      d,6
        call    ScrollSpritesLeft
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.scrollOutToLeftLoop
        call    ResetSprites
        ret

.scrollBG
        ld      a,[mapLeft]
        cp      44
        ret     nz
        xor     a
        ld      [mapLeft],a
        ret
        
.loadCurHeroSprite
        xor     a
        ldio    [backBufferReady],a 

        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        cp      HERO_BA_FLAG
        jr      nz,.loadBS
        ld      a,BANK(select_ba_name_bg)
        ld      hl,select_ba_name_bg
        call    LoadCinemaTextBox
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        ld      a,BANK(select_ba_sp)
        ld      hl,select_ba_sp
        call    LoadCinemaSprite
        ret

.loadBS
        cp      HERO_BS_FLAG
        jr      nz,.loadHaiku

        ld      a,BANK(select_bs_name_bg)
        ld      hl,select_bs_name_bg
        call    LoadCinemaTextBox
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        ld      a,BANK(select_bs_sp)
        ld      hl,select_bs_sp
        call    LoadCinemaSprite
        ret

.loadHaiku
        cp      HERO_HAIKU_FLAG
        jr      nz,.loadGrenade

        ld      a,BANK(select_haiku_name_bg)
        ld      hl,select_haiku_name_bg
        call    LoadCinemaTextBox
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        ld      a,BANK(select_haiku_sp)
        ld      hl,select_haiku_sp
        call    LoadCinemaSprite
        ret

.loadGrenade
        ld      a,BANK(select_grenade_name_bg)
        ld      hl,select_grenade_name_bg
        call    LoadCinemaTextBox
        call    ((.scrollBG-L1100_Load2)+levelCheckRAM)
        ld      a,1
        call    Delay
        ld      a,BANK(select_grenade_sp)
        ld      hl,select_grenade_sp
        call    LoadCinemaSprite
        ret

CharSelectOnHBlank:
        push    af
        push    bc
        push    hl

        ;rainbow sky
        ld      c,$69
        ldio    a,[$ff44]
.checkRainbowSky
        cp      70
        jr      nc,.resetSkyTop

        inc     a
        rlca    ;times two (index to word array)
        add     (((.rainbowSky-L1100_Load2)+levelCheckRAM)&$ff)
        ld      l,a
        ld      a,((((.rainbowSky-L1100_Load2)+levelCheckRAM)>>8)&$ff)
        adc     0
        ld      h,a
        ld      a,%10000010
        ldio    [$ff68],a
        ld      a,[hl+]
        ld      [c],a
        ld      a,[hl+]
        ld      [c],a
        jr      .checkDialogOnOff

.resetSkyTop
        ld      a,%10000010
        ld      [$ff68],a
        xor     a
        ld      [c],a
        ld      [c],a

.checkDialogOnOff
        ldio    a,[$ff41]           ;get stat register
        bit     2,a                 ;equal to lyc?
        jr      z,.done

.continue
        ld      hl,hblankFlag
        bit     0,[hl]              ;turning window on or off?
        jr      nz,.turnOffWindow

        ;turn on window
        bit     1,[hl]              ;allowed to?
        jr      nz,.turnOn
        jr      .done
.turnOn
        set     0,[hl]
        ldio    a,[hblankWinOff]
        ld      [$ff45],a           ;reset lyc to win off pos
        ld      hl,$ff40            ;turn window on
        set     5,[hl]

        ;set background palette 0, color zero to black
        ld      c,$68
        ld      a,%10000000         ;specification
        ld      [c],a
        xor     a
        inc     c
        ld      [c],a
        ld      [c],a
        jr      .done

.turnOffWindow
        res     0,[hl]
        ldio    a,[hblankWinOn]
        ld      [$ff45],a           ;reset lyc to win on pos
        ld      hl,$ff40            ;turn window off
        res     5,[hl]

        ;restore background palette 0, color zero
        ld      a,%10000000         ;specification
        ld      c,$68 
        ld      hl,mapColor
        ld      [c],a               ;ff68
        ld      a,[hl+]             ;[mapColor]
        inc     c
        ld      [c],a               ;ff69
        ld      a,[hl]              ;[mapColor+1]
        ld      [c],a               ;ff69

.done
        pop     hl
        pop     bc
        pop     af
        reti

.rainbowSky
        COLOR 0,0,0
        COLOR 0,0,8
        COLOR 0,0,17
        COLOR 0,0,25
        COLOR 0,0,34
        COLOR 0,0,42
        COLOR 0,0,51
        COLOR 0,0,59
        COLOR 0,0,68
        COLOR 0,0,76
        COLOR 0,0,85
        COLOR 0,0,93
        COLOR 0,0,102
        COLOR 0,0,110
        COLOR 0,0,119
        COLOR 0,0,127
        COLOR 0,0,136
        COLOR 0,0,144
        COLOR 0,0,153
        COLOR 0,0,161
        COLOR 0,0,170
        COLOR 0,0,178
        COLOR 0,0,187
        COLOR 0,0,195
        COLOR 0,0,204
        COLOR 0,0,212
        COLOR 0,0,221
        COLOR 0,0,229
        COLOR 0,0,238
        COLOR 0,0,246
        COLOR 0,0,255

        COLOR 0,0,255
        COLOR 4,6,255
        COLOR 8,12,255
        COLOR 12,19,255
        COLOR 17,25,255
        COLOR 21,32,255
        COLOR 25,38,255
        COLOR 29,44,255
        COLOR 34,51,255
        COLOR 38,57,255
        COLOR 42,64,255
        COLOR 46,70,255
        COLOR 51,76,255
        COLOR 55,83,255
        COLOR 59,89,255
        COLOR 64,96,255
        COLOR 68,102,255
        COLOR 72,108,255
        COLOR 76,115,255
        COLOR 81,121,255
        COLOR 85,128,255
        COLOR 89,134,255
        COLOR 93,140,255
        COLOR 98,147,255
        COLOR 102,153,255
        COLOR 106,160,255
        COLOR 110,166,255
        COLOR 115,172,255
        COLOR 119,179,255
        COLOR 123,185,255
        COLOR 128,192,255

        COLOR 128,192,255
        COLOR 139,197,255
        COLOR 151,203,255
        COLOR 162,209,255
        COLOR 174,214,255
        COLOR 185,220,255
        COLOR 197,226,255
        COLOR 208,232,255
        COLOR 220,237,255
        COLOR 231,243,255
        COLOR 243,249,255
        COLOR 255,255,255

L1100_LoadFinished:

PRINTT "  1100 Level Load Size: "
PRINTV (L1100_LoadFinished - L1100_Load2)
PRINTT "/$500 bytes\n"


L1100_Map:

;gtx_app_closed_gate_bs5:  INCBIN  "Data/Dialog/Landing/app_closed_gate_bs5.gtx"

L1100_Init:
        DW ((L1100_InitFinished - L1100_Init)-2)  ;size
L1100_Init2:
        ret

L1100_InitFinished:


L1100_Check:
        DW ((L1100_CheckFinished - L1100_Check) - 2)  ;size
L1100_Check2:
L1100_CheckOffset EQU (levelCheckADDR - L1100_Check2)
        ret

L1100_CheckFinished:

PRINTT "  1100 Level Load Size: "
PRINTV (L1100_LoadFinished - L1100_Load2)
PRINTT "/$500 bytes\n"

