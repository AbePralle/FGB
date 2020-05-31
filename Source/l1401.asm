; l1401.asm Appomattox control panel / destination select
; Generated 02.27.2001 by mlevel
; Modified  02.27.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"

VAR_DESTZONE  EQU 0
VAR_DESTCOLOR EQU 1
VAR_DESTBG    EQU 3
VAR_DESTBANK  EQU 5

;this var used in user.asm
VAR_SELSTAGE  EQU 6
VAR_STAGE0    EQU 7
VAR_STAGE1    EQU 8
VAR_STAGE2    EQU 9
VAR_STAGE3    EQU 10

VAR_LASTDIR   EQU 11


;---------------------------------------------------------------------
SECTION "Level1401Gfx2",DATA
;---------------------------------------------------------------------
nokey_bg::
  INCBIN "..\\fgbpix\\appomattox\\nokey.bg"

;---------------------------------------------------------------------
SECTION "Level1401Gfx",DATA
;---------------------------------------------------------------------
lz_zorhaus_bg::
  INCBIN "..\\fgbpix\\appomattox\\lz_zorhaus.bg"

lz_palace_bg::
  INCBIN "..\\fgbpix\\appomattox\\lz_palace.bg"

lz_croutongate_bg::
  INCBIN "..\\fgbpix\\appomattox\\lz_croutongate.bg"

;---------------------------------------------------------------------
SECTION "Level1401SectionDataControlPanel",DATA
;---------------------------------------------------------------------
controlpanel_bg::
  INCBIN "..\\fgbpix\\appomattox\\controlpanel.bg"

panelsprites_sp::
  INCBIN "..\\fgbpix\\appomattox\\panelsprites.sp"

;---------------------------------------------------------------------
SECTION "Level1401Waves",DATA
;---------------------------------------------------------------------
appwaves0_dat::
  INCBIN "..\\fgbpix\\appomattox\\appwaves0.dat"

appwaves1_dat::
  INCBIN "..\\fgbpix\\appomattox\\appwaves1.dat"

appwaves2_dat::
  INCBIN "..\\fgbpix\\appomattox\\appwaves2.dat"

appwaves3_dat::
  INCBIN "..\\fgbpix\\appomattox\\appwaves3.dat"

appwaves4_dat::
  INCBIN "..\\fgbpix\\appomattox\\appwaves4.dat"


;---------------------------------------------------------------------
SECTION "Level1401Section",DATA
;---------------------------------------------------------------------

L1401_Contents::
  DW L1401_Load
  DW L1401_Init
  DW L1401_Check
  DW L1401_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1401_Load:
        DW ((L1401_LoadFinished - L1401_Load2))  ;size
L1401_Load2:
        jr      .afterDirectionTable

.directionTable
;lookup table to convert 4-bit input into 0-7 or 8 (no dir)
                       ; DULR
        DB 8           ;%0000      701
        DB 2           ;%0001      682
        DB 6           ;%0010      543
        DB 8           ;%0011
        DB 0           ;%0100
        DB 1           ;%0101
        DB 7           ;%0110
        DB 8           ;%0111
        DB 4           ;%1000
        DB 3           ;%1001
        DB 5           ;%1010
        DB 8           ;%1011
        DB 8           ;%1100
        DB 8           ;%1101
        DB 8           ;%1110
        DB 8           ;%1111

.afterDirectionTable
        ld      bc,ITEM_APPXKEY
        call    HasInventoryItem
        jp      z,((.noKey-L1401_Load2)+levelCheckRAM)

        ld      a,1
        ld      [musicRegisters+0],a

        ld      a,BANK(takeoff_gbm)
        ld      hl,takeoff_gbm
        call    InitMusic

        ;----set up control panel window------------------------------
        ld      a,BANK(controlpanel_bg)
        ld      hl,controlpanel_bg
        call    LoadCinemaBG

        ld      a,BANK(panelsprites_sp)
        ld      hl,panelsprites_sp
        call    LoadCinemaSprite

        ;set last three positional indicators to blank sprite
        ld      hl,spriteOAMBuffer+8+2
        ld      de,4
        ld      a,36
        ld      c,6
.clearIndicators
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.clearIndicators

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

        ;copy panel to top half of map
        ld      bc,$1409
        ld      de,$0000
        ld      hl,$0009
        call    CinemaBlitRect
        ld      a,1
        call    Delay

        ;panel to dialog window
        ld      de,((.byte8-L1401_Load2)+levelCheckRAM)
        call    ShowDialogAtBottomCommon

        ld      a,[appomattoxMapIndex]
        call    ((.getLandingInfo-L1401_Load2)+levelCheckRAM)
        call    LoadCinemaBG

        ld      a,18
        ld      [camera_j],a
        ld      a,9
        ld      [mapTop],a

        ;someone already flying?
        ld      a,[appomattoxMapIndex]
        or      a
        call    z,((.backToAppx-L1401_Load2)+levelCheckRAM)

        ld      a,15
        call    SetupFadeFromStandard

        xor     a
        ld      hl,levelVars+VAR_SELSTAGE
        ld      [hl+],a
        ld      [hl+],a   ;stage 0
        ld      [hl+],a   ;stage 1
        ld      [hl+],a   ;stage 2
        ld      [hl+],a   ;stage 3
        ld      a,8
        ld      [hl+],a   ;last direction pushed

.setCoords
        ld      a,[myJoy]
        and     %1111      ;directions
        add     (((.directionTable-L1401_Load2)+levelCheckRAM) & $ff)
        ld      l,a
        ld      h,((((.directionTable-L1401_Load2)+levelCheckRAM)>>8)&$ff)
        ld      a,[hl]
        push    af
        call    ((.setHLCurStage-L1401_Load2)+levelCheckRAM)
        pop     af
        ld      [hl],a
        ld      a,[levelVars+VAR_LASTDIR]
        cp      [hl]
        jr      z,.afterPlayChangeSound

        ld      a,[hl]
        ld      [levelVars+VAR_LASTDIR],a
        ;ld      hl,((.changeSound-L1401_Load2)+levelCheckRAM)
        ;call    PlaySound

.afterPlayChangeSound
        call    ((.drawCurSymbol-L1401_Load2)+levelCheckRAM)

        ld      a,[myJoy]
        bit     JOY_A_BIT,a
        jr      z,.checkUp

        call    ((.changeStage-L1401_Load2)+levelCheckRAM)
        call    ((.drawCurSymbol-L1401_Load2)+levelCheckRAM)
        ;ld      hl,((.buttonSound-L1401_Load2)+levelCheckRAM)
        ;call    PlaySound
        ld      a,1
        call    Delay
        call    ((.waitInputZero-L1401_Load2)+levelCheckRAM)
        jr      .setCoordsContinue

.checkUp
IF 0
        bit     JOY_UP_BIT,a
        jr      z,.checkDown

        call    ((.previousSymbol-L1401_Load2)+levelCheckRAM)
        call    ((.drawCurSymbol-L1401_Load2)+levelCheckRAM)
        call    ((.waitInputZero-L1401_Load2)+levelCheckRAM)
        jr      .setCoordsContinue

.checkDown
        bit     JOY_DOWN_BIT,a
        jr      z,.setCoordsContinue

        call    ((.nextSymbol-L1401_Load2)+levelCheckRAM)
        call    ((.drawCurSymbol-L1401_Load2)+levelCheckRAM)
        call    ((.waitInputZero-L1401_Load2)+levelCheckRAM)
ENDC

.setCoordsContinue
        ld      a,1
        call    Delay

        ld      a,[levelVars+VAR_SELSTAGE]
        cp      $ff
        call    z,((.backToAppx-L1401_Load2)+levelCheckRAM)
        cp      4
        jr      nz,.setCoords

        call    ((.convertCoordsToMapIndex-L1401_Load2)+levelCheckRAM)
        ld      [levelVars+VAR_DESTZONE],a
        call    ((.getLandingInfo-L1401_Load2)+levelCheckRAM)
        ld      d,h
        ld      e,l
        ld      hl,levelVars+VAR_DESTCOLOR
        ld      [hl],c
        inc     hl
        ld      [hl],b
        inc     hl
        ld      [hl],e
        inc     hl
        ld      [hl],d
        inc     hl
        ld      [hl],a

        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.afterRemoteAppx 

.removeRemoteAppx
        ld      a,LCHANGEAPPXMAP
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.removeRemoteAppx      ;must repeat
        xor     a
        call    TransmitByte
.afterRemoteAppx

        ld      hl,$1400
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,2
        ld      [timeToChangeLevel],a
        ret

.animateWave
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
        add     (((.waveFrameTable-L1401_Load2)+levelCheckRAM) & $ff)
        ld      l,a
        ld      a,0
        adc     ((((.waveFrameTable-L1401_Load2)+levelCheckRAM)>>8) & $ff)
        ld      h,a
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ld      de,$9420
        ld      c,40
        ld      a,1
        call    VMemCopy
        POPROM
        ret

.waveFrameTable
  DW appwaves0_dat,appwaves0_dat+640,appwaves0_dat+640*2,appwaves0_dat+640*3
  DW appwaves1_dat,appwaves1_dat+640,appwaves1_dat+640*2,appwaves1_dat+640*3
  DW appwaves2_dat,appwaves2_dat+640,appwaves2_dat+640*2,appwaves2_dat+640*3
  DW appwaves3_dat,appwaves3_dat+640,appwaves3_dat+640*2,appwaves3_dat+640*3
  DW appwaves4_dat,appwaves4_dat+640,appwaves4_dat+640*2,appwaves4_dat+640*3

.convertCoordsToMapIndex
        ;de = binary map coords
        ld      hl,levelVars+VAR_STAGE0
        ld      a,[hl+]
        swap    a
        ld      d,a
        ld      a,[hl+]
        or      d
        ld      d,a
        ld      a,[hl+]
        swap    a
        ld      e,a
        ld      a,[hl+]
        or      e
        ld      e,a

        ld      a,FLIGHTCODEBANK
        ld      [$ff70],a
        ld      hl,flightCode
        ld      c,[hl]    ;num flight codes
.findCode
        inc     hl
        ld      a,[hl+]
        cp      e
        jr      nz,.noMatch

        ld      a,[hl]
        cp      d
        jr      nz,.noMatch

        ;match!  Get map index
        inc     hl
        ld      a,[hl]
        ret

.noMatch
        inc     hl
        dec     c
        jr      nz,.findCode

        ;go to default map
        ld      a,$71
        ret

.waitInputZero
        ld      a,JOY_A      ;|JOY_UP|JOY_DOWN
        ld      hl,myJoy
        jp      WaitInputZero

.setHLCurStage
        ld      h,(((levelVars+VAR_STAGE0)>>8) & $ff)
        ld      a,[levelVars+VAR_SELSTAGE]
        ld      b,a
        add     ((levelVars+VAR_STAGE0) & $ff)
        ld      l,a
        ld      a,[hl]
        ret


.drawCurSymbol
        call    ((.animateWave-L1401_Load2)+levelCheckRAM)
        ;set power bar level
        ld      a,[levelVars+VAR_SELSTAGE]
        inc     a
        ld      [musicRegisters+0],a
        dec     a
        push    af
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
        pop     af

        ;turn on HUD sprites based on stage
        push    af
        or      a
        jr      nz,.checkHUD1

        ;HUD 0
        call    ((.diagramOff-L1401_Load2)+levelCheckRAM)
        jr      .afterCheckHUD

.checkHUD1
        cp      1
        jr      nz,.checkHUD2

        call    ((.diagramOn-L1401_Load2)+levelCheckRAM)
        call    ((.recticleOff-L1401_Load2)+levelCheckRAM)
        jr      .afterCheckHUD

.checkHUD2
        cp      2
        jr      nz,.checkHUD3

        call    ((.recticleOn-L1401_Load2)+levelCheckRAM)
        call    ((.horizonOff-L1401_Load2)+levelCheckRAM)
        jr      .afterCheckHUD

.checkHUD3
        cp      3
        jr      nz,.HUD4

        call    ((.horizonOn-L1401_Load2)+levelCheckRAM)
        jr      .afterCheckHUD

.HUD4

.afterCheckHUD
        pop     af
        cp      4
        ret     z     ;done

        call    ((.setHLCurStage-L1401_Load2)+levelCheckRAM)
        cp      8
        jr      nz,.drawYellow

        ;draw blue
        ld      d,1
        jr      .afterSetPalette

.drawYellow
        ld      d,0

.afterSetPalette
        ;alter palette based on time
        push    af
        ldio    a,[vblankTimer]
        and     %1000
        rrca
        rrca
        or      d
        ld      d,a
        pop     af
        rlca    ;selection times four is sprite pattern index
        rlca
        ld      c,a
        ld      a,b
        rlca    ;stage*8+2 is sprite index
        rlca
        rlca
        add     2
        add     (spriteOAMBuffer&$ff)
        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      [hl],c   ;tile pattern
        inc     hl
        ld      [hl],d   ;palette
        inc     hl
        inc     hl
        inc     hl
        inc     c
        inc     c
        ld      [hl],c
        inc     hl
        ld      [hl],d
        ret

.diagramOn
        ld      hl,spriteOAMBuffer+20*4
        ld      [hl],16
        ld      hl,spriteOAMBuffer+21*4
        ld      [hl],16
        ret

.diagramOff
        ld      hl,spriteOAMBuffer+20*4
        ld      [hl],160
        ld      hl,spriteOAMBuffer+21*4
        ld      [hl],160
        ret

.recticleOn
        ld      b,2
        ld      de,4
        ld      a,32
        ld      hl,spriteOAMBuffer+8*4
.recticleOnLoopOuter
        ld      c,4
.recticleOnLoopInner
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.recticleOnLoopInner
        add     16
        dec     b
        jr      nz,.recticleOnLoopOuter
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

.horizonOn
        ld      de,4
        ld      a,40
        ld      hl,spriteOAMBuffer+16*4
        ld      c,4
.horizonOnLoop
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.horizonOnLoop
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


;----changeStage------------------------------------------------------
.changeStage
        call    ((.setHLCurStage-L1401_Load2)+levelCheckRAM)
        cp      8       ;back arrow?
        jr      z,.backArrow

        ;forward
        inc     b
        ld      a,b
        ld      [levelVars+VAR_SELSTAGE],a
        cp      4
        ret     z    ;all done!
 
        ;set this sprite to palette 0 and reset sprite for next level
        ld      a,[hl]
        inc     hl
        ld      [hl],a
        ld      a,b
        rlca    ;times eight
        rlca
        rlca
        sub     5
        add     (spriteOAMBuffer&$ff)
        ld      l,a
        ld      h,((spriteOAMBuffer>>8)&$ff)
        ld      de,4
        ld      [hl],0
        add     hl,de
        ld      [hl],0
        add     hl,de
        dec     hl
        ld      [hl],0
        add     hl,de
        ld      [hl],2

        ret

.backArrow
        dec     b
        ld      a,b
        cp      $ff
        jr      nz,.notPos0

.backToAppx
        ;return to appomattox
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

        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade
        call    ClearDialog
        ld      a,1
        call    Delay
        pop     hl   ;pop return address, return from Load2
        ret

.notPos0
        dec     hl   ;set stage[n-1] to be back arrow too
        ld      [hl],8
        ld      [levelVars+VAR_SELSTAGE],a
 
        ;reset this sprite to blank before going back
        inc     a   
        rlca    ;times eight
        rlca
        rlca
        add     2
        add     (spriteOAMBuffer&$ff)
        ld      l,a
        ld      h,((spriteOAMBuffer>>8)&$ff)
        ld      [hl],36
        ld      de,4
        add     hl,de
        ld      [hl],36

        ;decrement rolloever sprite (8 & 9) xpos
        ;ld      hl,spriteOAMBuffer+8*4+1
        ;ld      b,24
        ;ld      a,[hl]
        ;sub     b
        ;ld      [hl],a
        ;ld      hl,spriteOAMBuffer+9*4+1
        ;ld      a,[hl]
        ;sub     b
        ;ld      [hl],a

        ret

;----getLandingInfo---------------------------------------------------
.getLandingInfo
.checkGate
        cp       $71
        jr       nz,.checkCroutonGate

        ld       a,LEVELSTATEBANK
        ldio     [$ff70],a
        ld       a,[levelState+$71]
        cp       6
        jr       nz,.gate

        ;broken wall (blasted)
        ld       a,BANK(lz_brokenwall_bg)
        ld       hl,lz_brokenwall_bg
        jp       ((.defaultSkyColor-L1401_Load2)+levelCheckRAM)

.gate
        ld       a,BANK(lz_gate_bg)
        ld       hl,lz_gate_bg
        jp       ((.defaultSkyColor-L1401_Load2)+levelCheckRAM)

.checkCroutonGate
        cp       $0a
        jr       nz,.checkZorhaus

        ld       a,BANK(lz_croutongate_bg)
        ld       hl,lz_croutongate_bg
        ld       bc,0       ;sky color
        ret

.checkZorhaus
        cp       $3d
        jr       nz,.checkPalace

        ld       a,BANK(lz_zorhaus_bg)
        ld       hl,lz_zorhaus_bg
        ld       bc,$33f  ;sky color
        ret

.checkPalace
        cp       $55
        jr       nz,.checkTrees1

        ld       a,BANK(lz_palace_bg)
        ld       hl,lz_palace_bg
        ld       bc,$7eee  ;sky color
        ret

.checkTrees1
        cp       $81
        jr       nz,.checkMist
        ld       a,BANK(lz_trees1_bg)
        ld       hl,lz_trees1_bg
        jp       ((.defaultSkyColor-L1401_Load2)+levelCheckRAM)

.checkMist
        cp       $23
        jr       nz,.checkIce1
        ld       a,BANK(lz_mist_bg)
        ld       hl,lz_mist_bg
        ld       bc,$592e
        ret

.checkIce1
        cp       $06
        jr       nz,.checkCanyon

        ld       a,BANK(lz_ice1_bg)
        ld       hl,lz_ice1_bg
        ld       bc,$7eed
        ret

.checkCanyon
        cp       $47
        jr       nz,.checkDesert

        ld       a,BANK(lz_canyon_bg)
        ld       hl,lz_canyon_bg
        ld       bc,$2fff
        ret

.checkDesert
        cp       $a3
        jr       nz,.checkGraves

        ld       a,BANK(lz_desert_bg)
        ld       hl,lz_desert_bg
        ld       bc,$2fff
        ret

.checkGraves
        cp       $a8
        jr       nz,.checkIceCubes

        ld       a,BANK(lz_graves_bg)
        ld       hl,lz_graves_bg
        ld       bc,0
        ret

.checkIceCubes
        cp       $29
        jr       nz,.checkJungle

        ld       a,BANK(lz_icecubes_bg)
        ld       hl,lz_icecubes_bg
        ld       bc,$7e2b
        ret

.checkJungle
        cp       $59
        jr       nz,.checkMountains
        
        ld       a,BANK(lz_jungle_bg)
        ld       hl,lz_jungle_bg
        ld       bc,$a0
        ret

.checkMountains
        cp       $66
        jr       nz,.checkOcean

        ld       a,BANK(lz_mountains_bg)
        ld       hl,lz_mountains_bg
        ld       bc,$487f
        ret

.checkOcean
        cp       $3a
        jr       nz,.checkTreePath

        ld       a,BANK(lz_ocean_bg)
        ld       hl,lz_ocean_bg
        ld       bc,$121f
        ret

.checkTreePath
        ;cp       $c7
        ld       a,BANK(lz_treepath_bg)
        ld       hl,lz_treepath_bg

.defaultSkyColor
        ld      bc,$7e20
        ret

.changeSound
  DB 1,$31,$80,$c1,$00,$83

.buttonSound
  DB 1,$79,$80,$f1,$00,$87

.byte8
  DB 8

.noKey
        ld      a,BANK(nokey_bg)
        ld      hl,nokey_bg
        call    LoadCinemaBG

        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.returnToShip-L1401_Load2)+levelCheckRAM)
        call    SetDialogForward
        call    SetDialogSkip

        ld      a,150
        call    Delay

.returnToShip
        call    ClearDialogSkipForward

        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,EXIT_N
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$1300
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

L1401_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1401_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1401_Init:
        DW ((L1401_InitFinished - L1401_Init2))  ;size
L1401_Init2:
        ret

L1401_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1401_Check:
        DW ((L1401_CheckFinished - L1401_Check2))  ;size
L1401_Check2:
        ret

L1401_CheckFinished:
PRINTT "1401 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1401_LoadFinished - L1401_Load2)
PRINTT " / "
PRINTV (L1401_InitFinished - L1401_Init2)
PRINTT " / "
PRINTV (L1401_CheckFinished - L1401_Check2)
PRINTT "\n"

