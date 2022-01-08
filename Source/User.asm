;Class.asm
;Gfx.asm
;Map.asm
;Object.asm
;Music.asm
;---------------------------------------------------------------------
; user.asm
; 12.18.99 by Abe Pralle
;---------------------------------------------------------------------

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Start.inc"
INCLUDE "Source/Items.inc"

MIN_VBLANKS  EQU  2

INTCLK EQU $83
EXTCLK EQU $82




        SECTION        "User",ROM0

;---------------------------------------------------------------------
; Subroutine:   UserMain
; Description:  Sets up game then goes into main loop
;---------------------------------------------------------------------
UserMain::
        call    InitGfx

        ;set up initial location + hero
        ;initial L0009 (demo intro)
        ld      a,LEVELSTATEBANK
        ld      [$ff70],a
        xor     a
        ld      [curLevelStateIndex],a

        xor     a
        ldio    [mapState],a
        ldio    [mapState+1],a

        ;initial level index
        ld      a,((INITIALMAP>>8) & $ff)
        ld      [curLevelIndex+1],a
        ld      a,(INITIALMAP & $ff)
        ld      [curLevelIndex],a

        ld      hl,$1102
        call    SetJoinMap
        call    SetRespawnMap

        ld      a,[heroesUsed]
        or      INITTYPE0
        ld      [heroesUsed],a

        ;hero 0 initial setup
        ld      a,(INITHERO0 & $ff)
        ld      [hero0_class],a
        ld      a,((INITHERO0>>8)&$ff)
        ld      [hero0_class+1],a
        ld      a,(INITLOC0 & $ff)
        ld      [hero0_enterLevelLocation],a
        ld      a,((INITLOC0>>8) & $ff)
        ld      [hero0_enterLevelLocation+1],a
        ld      a,INITEXIT0
        ld      [hero0_enterLevelFacing],a
        ld      a,INITTYPE0
        ld      [hero0_type],a
        xor     a
        ld      [hero0_health],a

        ;hero 1 initial setup
        ld      a,(INITHERO1 & $ff)
        ld      [hero1_class],a
        ld      a,((INITHERO1>>8)&$ff)
        ld      [hero1_class+1],a
        ld      a,(INITLOC1 & $ff)
        ld      [hero1_enterLevelLocation],a
        ld      a,((INITLOC1>>8) & $ff)
        ld      [hero1_enterLevelLocation+1],a
        ld      a,INITEXIT1
        ld      [hero1_enterLevelFacing],a
        ld      a,INITTYPE1
        ld      [hero1_type],a
        xor     a
        ld      [hero1_health],a

        ld      a,1
        ld      [timeToChangeLevel],a

        jr      .loadNextLevel

.game   ld      a,[timeToChangeLevel]
        or      a
        jr      z,.continue

        ;switch levels
        ld      b,METHOD_DIE
        call    IterateAllLists
        ld      a,15
        call    SetupFadeToBlack
        call    WaitFade

.loadNextLevel
        call    LoadNextLevel
        call    UpdateObjects
        call    GentleCameraAdjust
        call    levelCheckRAM
        call    RedrawMap
        ld      a,15
        call    SetupFadeFromBlack
        call    WaitFade
        ;call    LighteningIn

.continue
        call    MainLoopUpdateObjects
        call    GentleCameraAdjust

        call    levelCheckRAM
.afterLevelCheck
        call    RedrawMap
        jr      .game

;---------------------------------------------------------------------
; Routine:      SetActiveROM
; Argument:     a - desired ROM bank
; Returns:      Nothing.
; Alters:       af
; Description:  Switches to a new ROM bank by writing the new bank
;               number to [$2100].  Also saves the bank in
;               [curROMBank].
;---------------------------------------------------------------------
SetActiveROM::
        ldio    [curROMBank],a
        ld      [$2100],a
        ret

;---------------------------------------------------------------------
; Routine:      LongCall
; Arguments:    stack:
;                 +0:  parameter de
;                 +2:  parameter af
;                 +4:  empty (for addr of routine)
;                 +6:  empty (return addr from routine)
;                 +8:  af - old ROM bank
;                +10:  return addr from LongCall
;               a  - bank of routine
;               de - address of routine
; Returns:      Whatever routine normally returns (excluding F).
; Alters:       af, hl
; Description:
;---------------------------------------------------------------------
LongCall::
        ldio    [curROMBank],a   ;switch to ROM containing routine
        ld      [$2100],a

        push    hl
        ld      hl,sp+6          ;point hl to empty spot in stack
        ld      [hl],e
        inc     hl
        ld      [hl],d           ;save addr of method
        inc     hl
        ld      de,.returnAddress
        ld      [hl],e           ;save return addr of method
        inc     hl
        ld      [hl],d
        pop     hl
        pop     de
        pop     af
        ret                      ;call method

.returnAddress
        ld      [longCallTempA],a
        pop     af               ;get old ROM bank
        ldio    [curROMBank],a
        ld      [$2100],a
        ld      a,[longCallTempA]

        ret                      ;return from this routine

;---------------------------------------------------------------------
; Routine:      LongCallNoArgs
; Arguments:    a  - RAM bank of routine
;               hl - address of routine
; Returns:      Nothing.
; Alters:       af
; Description:  Quick & dirty long call (handles bank swapping)
;               for routines that don't require arguments or return
;               values.
;---------------------------------------------------------------------
LongCallNoArgs::
        push    bc

        ld      b,a
        ld      a,[curROMBank]
        push    af                   ;save old bank

        ld      a,b
        ld      [curROMBank],a       ;swap in new bank
        ld      [$2100],a

        ld      bc,.returnAddress
        push    bc

        jp      hl
.returnAddress

        pop     af                   ;retrieve old bank & swap it in
        ld      [curROMBank],a
        ld      [$2100],a

        pop     bc
        ret

WaitFade::
        call    FadeStep

        ;took out distorts synchronization
        ;send a null control byte
        ;ld      a,LNULL
        ;call    ExchangeByte
        ;call    HandleRemoteInput

        call    CheckSkip
        ld      a,[specialFX]
        and     FX_FADE
        jr      nz,WaitFade

        ;allow last palette to install
.waitInstall
        ldio    a,[paletteBufferReady]  ;wait for vblank
        or      a
        jr      nz,.waitInstall

        ret

;---------------------------------------------------------------------
; Routine:      CheckSpecialFX
; Alters:       af
; Description:  Performs any special effects upkeep
;---------------------------------------------------------------------
CheckSpecialFX:
        ld      a,[specialFX]
        and     FX_FADE
        jr      z,.done

        call    FadeStep
        ret

.done
        ret

;---------------------------------------------------------------------
; Subroutine:   UpdateObjTimers
; Alters:       af
; Description:  Updates timers used for object movement
;---------------------------------------------------------------------
UpdateObjTimers::
        ld      a,[objTimerBase]
        inc     a
        ld      [objTimerBase],a

        ;put 2 LSB bits in 4:3
        rlca
        rlca
        rlca
        and     %00011000
        ld      [objTimer60ths],a

        ret

;---------------------------------------------------------------------
; Subroutine:   UpdateHeroTimers
; Alters:       af
; Description:  Updates timers used for hero/hero bullet movement
;---------------------------------------------------------------------
UpdateHeroTimers:
        ld      a,[heroTimerBase]
        inc     a
        ld      [heroTimerBase],a

        ;put 2 LSB bits in 4:3
        rlca
        rlca
        rlca
        and     %00011000
        ld      [heroTimer60ths],a

        ret


;---------------------------------------------------------------------
; Subroutine:   VWait
; Description:  Waits until a vertical blank occurs and then returns
;---------------------------------------------------------------------
VWait::
.vwait  halt                      ;stop processor until interrupt
        nop                       ;pad to prevent weird stuff after halt

        ;interrupt happened, let's look at our flag
        ldio    a,[vblankFlag]
        or      a                 ;a=a|a; tells us if vblankFlag is 1 or 0
        jr      z,.vwait          ;not the vblank flag after all

        ;If we're here then a vblank has occurred.  Get on with our lives.
        xor     a                 ;clear vblank flag
        ldio    [vblankFlag],a
        ret

;---------------------------------------------------------------------
; Subroutine:   OnVBlank
; Description:  Called every vertical blank.  Sets "vblankFlag" to
;               1 to indicate a vertical blank has occurred
;---------------------------------------------------------------------
OnVBlank::
        push    af   ;save all registers on stack
        push    bc
        push    de
        push    hl

        ld      a,1  ;set "vblankFlag" to 1
        ldio    [vblankFlag],a

        ;store current VRAM bank in use
        ld      a,[$ff00+$4f]
        push    af

        ;update timers
        ld      hl,vblankTimer
        inc     [hl]

        ;is the backBuffer ready for DMA blit to screen?
        ldio    a,[backBufferReady]
        or      a
        jr      z,.checkDMALoad      ;wasn't ready

        ld      a,[displayType]
        or      a
        jr      nz,.afterVblankCheck  ;cinema type

        ldio    a,[vblankTimer]
        ld      hl,vblankTemp
        sub     [hl]
        ldio    [vblanksPerUpdate],a

        ;update no faster than 1-frame-every-so-many-blanks clocks
        cp      MIN_VBLANKS
        jr      c,.checkDMALoad   ;too soon to update

;MUST SYNCHRONIZE WITH REMOTE TO DYNAMICALLY CHANGE THIS
        ;jr      z,.rightOn        ;exactly right
        ;updating too many objects; decrease iterateNumObjects
        ;ld      hl,iterateNumObjects
        ;ld      a,[hl]
        ;cp      17
        ;jr      c,.rightOn    ;don't risk going below 16 per update

        ;dec     [hl]

.rightOn
        ldio a,[vblankTimer]  ;save time of this screen update
        ldio [vblankTemp],a

.afterVblankCheck
        ld      hl,updateTimer
        inc     [hl]

        xor     a
        ldio    [backBufferReady],a  ;signal we've blitted backbuffer

        ;set VRAM bank to 0
        xor     a
        ld      [$ff00+$4f],a

        ;use DMA to transfer sprite OAM buffer to VRAM
        call    SpriteDMAHandler

        ;Initiate DMA transfer of backbuffer to VRAM

        ld      hl,backBuffer
        ld      a,h
        ld      [$ff00+$51],a     ;high byte of source
        ld      a,l
        ld      [$ff00+$52],a     ;low byte of source
        ldio    a,[backBufferDestHighByte]
        ld      [$ff00+$53],a     ;high byte of dest
        xor     a
        ld      [$ff00+$54],a     ;low byte of dest
        ld      a,37              ;copy (37+1)*16 = 608 bytes
        ld      [$ff00+$55],a     ;store length to start DMA

        ;set VRAM bank to 1 (tile attributes)
        ld      a,1
        ld      [$ff00+$4f],a

        ;Initiate DMA transfer of tile attributes to VRAM
        ld      hl,attributeBuffer
        ld      a,h
        ld      [$ff00+$51],a     ;high byte of source
        ld      a,l
        ld      [$ff00+$52],a     ;low byte of source
        ldio    a,[backBufferDestHighByte]
        ld      [$ff00+$53],a     ;high byte of dest
        xor     a
        ld      [$ff00+$54],a     ;low byte of dest
        ld      a,37              ;copy (37+1)*16 = 608 bytes
        ld      [$ff00+$55],a     ;store length to start DMA

        ld      a,[desiredPixelOffset_x]
        ld      [curPixelOffset_x],a
        ld      a,[desiredPixelOffset_y]
        ld      [curPixelOffset_y],a
        jr      .scroll

.checkDMALoad
        ldio    a,[dmaLoad]
        or      a
        jr      z,.scroll

.checkLoadBank0
        bit     0,a
        jr      z,.checkLoadBank1

.loadBank0
        res     0,a
        ldio    [dmaLoad],a       ;indicate we've loaded it
        xor     a
        ld      [$ff4f],a

        ;Initiate DMA transfer to bank 0 VRAM
        ld      a,[dmaLoadSrc0+1]
        ld      [$ff00+$51],a     ;high byte of source
        ld      a,[dmaLoadSrc0]
        ld      [$ff00+$52],a     ;low byte of source
        ld      a,[dmaLoadDest0+1]
        ld      [$ff00+$53],a     ;high byte of dest
        ld      a,[dmaLoadDest0]
        ld      [$ff00+$54],a     ;low byte of dest
        ld      a,[dmaLoadLen0]   ;copy (N+1)*16 bytes
        ld      [$ff00+$55],a     ;store length to start DMA

.checkLoadBank1
        ldio    a,[dmaLoad]
        bit     1,a
        jr      z,.scroll

.loadBank1
        res     1,a
        ldio    [dmaLoad],a       ;indicate we've loaded it
        ld      a,1
        ld      [$ff4f],a

        ;Initiate DMA transfer to bank 1 VRAM
        ld      a,[dmaLoadSrc1+1]
        ld      [$ff00+$51],a     ;high byte of source
        ld      a,[dmaLoadSrc1]
        ld      [$ff00+$52],a     ;low byte of source
        ld      a,[dmaLoadDest1+1]
        ld      [$ff00+$53],a     ;high byte of dest
        ld      a,[dmaLoadDest1]
        ld      [$ff00+$54],a     ;low byte of dest
        ld      a,[dmaLoadLen1]   ;copy (N+1)*16 bytes
        ld      [$ff00+$55],a     ;store length to start DMA

.scroll          ;Adjust scroll coordinates
        ld      hl,lineZeroHorizontalOffset
        ldio    a,[jiggleDuration]
        or      a
        jr      z,.useNormalScreenOffsets

        ;jiggle the screen!
        dec     a
        ldio    [jiggleDuration],a

        ;determine jiggle type
        ld      a,[jiggleType]
        or      a
        jr      nz,.takeoffJiggle

.normalJiggle
        ;pick a "random value"
        ld      a,[jiggleLoc]
        add     17
        ld      [jiggleLoc],a
        ld      b,a             ;store random value in b
        and     %00000111       ;random x offset
        ldio    [baseHorizontalOffset],a
        add     [hl]            ;add lineZeroHorizontalOffset
        ldio    [$ff43],a
        swap    b
        ld      a,%00000111     ;random y offset
        and     b
        ldio    [$ff42],a
        jr      .done

.takeoffJiggle
        ld      a,[jiggleLoc]
        add     17
        ld      [jiggleLoc],a
        ld      b,a             ;store random value in b
        and     %11             ;x offset
        ldio    [$ff43],a
        swap    b
        ld      a,%11
        and     b
        ld      b,a
        ld      a,[curPixelOffset_y]
        add     b
        cp      8
        jr      c,.takeoffVOkay

        ld      a,7

.takeoffVOkay
        ldio    [$ff42],a
        jr      .done

.useNormalScreenOffsets
        ld      a,[curPixelOffset_x]
        ldio    [baseHorizontalOffset],a
        add     [hl]            ;add lineZeroHorizontalOffset
        ldio    [$ff43],a
        ld      a,[curPixelOffset_y]
        ldio    [$ff42],a

        ;new palette to copy?
        ldio    a,[paletteBufferReady]
        or      a
        jr      z,.afterPaletteCopy

        ld      c,16    ;c is count
        ld      hl,fadeCurPalette
        ld      a,%10000000
        ld      [$ff68],a
        ld      [$ff6a],a
.paletteCopyBG
        ld      a,[hl+]     ;copy sets of 4 bytes to avoid minute but
        ld      [$ff69],a   ;killer delays decrementing the counter
        ld      a,[hl+]
        ld      [$ff69],a
        ld      a,[hl+]
        ld      [$ff69],a
        ld      a,[hl+]
        ld      [$ff69],a
        dec     c
        jr      nz,.paletteCopyBG

        ld      c,16    ;c is count
.paletteCopyFG
        ld      a,[hl+]
        ld      [$ff6b],a
        ld      a,[hl+]
        ld      [$ff6b],a
        ld      a,[hl+]
        ld      [$ff6b],a
        ld      a,[hl+]
        ld      [$ff6b],a
        dec     c
        jr      nz,.paletteCopyFG

        xor     a
        ldio    [paletteBufferReady],a

.afterPaletteCopy

.done
        ;update music
        ldio    a,[musicEnabled]
        and     %10000
        jr      z,.doneMusic

        ld      hl,musicNoteCountdown
        dec     [hl]
        call    z,PlayMusic

.doneMusic
        ;restore VRAM bank that was in use
        pop     af
        ld      [$ff00+$4f],a

        pop     hl   ;restore all regs from stack
        pop     de
        pop     bc
        pop     af
        reti         ;return from interrupt


;---------------------------------------------------------------------
; Subroutine:   OnHBlank
; Description:  Called after every line is drawn.
;---------------------------------------------------------------------
OnHBlank::
        push    af
        push    bc
        push    hl

OnHBlank_afterPush:
        ldio    a,[$ff41]           ;get stat register
        bit     2,a                 ;equal to lyc?
        jp      z,FinishHBlankPlayingSample

.continue
        ld      hl,hblankFlag
        bit     0,[hl]              ;turning window on or off?
        jr      nz,OnHBlank_turnOffWindow

        ;turn on window
        bit     1,[hl]              ;allowed to?
        jr      nz,.turnOn
        jp      z,FinishHBlankPlayingSample
.turnOn
        set     0,[hl]
        ldio    a,[hblankWinOff]
        ld      [$ff45],a           ;reset lyc to win off pos
        ld      hl,$ff40            ;turn window on
        set     5,[hl]

OnHBlank_SetBGColorBlack:
        ;set background palette 0, color zero to black
        ld      b,0
        ld      c,$68
        ld      hl,$ff69
        ld      a,%10000000         ;specification 0
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ;ld      a,%10000110         ;white
        ;ld      [c],a
        ;ld      [hl],h
        ;ld      [hl],h

        ld      a,%10001000         ;palette 1
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ld      a,%10010000         ;palette 2
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ld      a,%10011000         ;palette 3
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ld      a,%10100000         ;palette 4
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ld      a,%10101000         ;palette 5
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ld      a,%10110000         ;palette 6
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        ld      a,%10111000         ;palette 7
        ld      [c],a
        ld      [hl],b
        ld      [hl],b

        jp      FinishHBlankPlayingSample

OnHBlank_turnOffWindow:
        res     0,[hl]
        ldio    a,[hblankWinOn]
        ld      [$ff45],a           ;reset lyc to win on pos
        ld      hl,$ff40            ;turn window off
        res     5,[hl]

        ;restore background palette 0, color zero
        push    de
        ld      c,$68
        ld      hl,mapColor
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a
        ld      hl,$ff69

HBlankSetBGColorCDEHL_DEPushed:
        ld      a,%10000000         ;specification 0
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10001000         ;specification 1
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10010000         ;specification 2
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10011000         ;specification 3
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10100000         ;specification 4
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10101000         ;specification 5
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10110000         ;specification 6
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ld      a,%10111000         ;specification 7
        ld      [c],a
        ld      [hl],e
        ld      [hl],d

        ;ld      a,%10000110         ;white
        ;ld      [c],a
        ;ld      a,[fadeCurPalette+6]
        ;ld      [hl],a
        ;ld      a,[fadeCurPalette+7]
        ;ld      [hl],a

        pop     de

.done
        jp      FinishHBlankPlayingSample

;---------------------------------------------------------------------
; Subroutine:   CinemaOnHBlank
; Description:  Called after every line is drawn.
;---------------------------------------------------------------------
CinemaOnHBlank::
        push    af
        push    bc
        push    hl

        ldio    a,[$ff41]           ;get stat register
        bit     2,a                 ;equal to lyc?
        jp      z,FinishHBlankPlayingSample

.continue
        ld      hl,hblankFlag
        bit     0,[hl]              ;turning window on or off?
        jr      nz,.turnOff

        ;turn on window
        bit     1,[hl]              ;allowed to?
        jr      nz,.turnOn
        jp      z,FinishHBlankPlayingSample
.turnOn
        set     0,[hl]
        ldio    a,[hblankWinOff]
        ld      [$ff45],a           ;reset lyc to win off pos
        ld      hl,$ff40            ;turn window on
        set     5,[hl]
        jp      FinishHBlankPlayingSample

.turnOff
        res     0,[hl]
        ldio    a,[hblankWinOn]
        ld      [$ff45],a           ;reset lyc to win on pos
        ld      hl,$ff40            ;turn window off
        res     5,[hl]

.done
        jp      FinishHBlankPlayingSample

;---------------------------------------------------------------------
; Subroutine:   HOffsetOnHBlank
; Description:  Called after every line is drawn.  Sets each line's
;               horizontal offset from horizontalOffset[144]
;---------------------------------------------------------------------
HOffsetOnHBlank::
        push    af
        push    bc
        push    hl

        ;save current RAM bank
        ldio    a,[$ff70]
        push    af

        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ;add to the horizontal offset for next line
        ld      c,$44        ;get $ff44
        ld      a,[c]        ;ypos of refresh (index to array)
        dec     c            ;c=$43 ($ff43)
        inc     a
        ld      l,a
        ld      h,((horizontalOffset>>8)&$ff)
        ldio    a,[baseHorizontalOffset]
        add     [hl]
        ld      [c],a        ;xpos of screen

.afterAdjustOffsets
        pop     af
        ldio    [$ff70],a
        jp      OnHBlank_afterPush

;---------------------------------------------------------------------
; Subroutine:   SeasonsOnHBlank
; Description:  Called after every line is drawn.  Sets color 0 (all
;               bg palettes) to white on line 143 and to brown ($888)
;               on line 39.
;---------------------------------------------------------------------
SeasonsOnHBlank::
        push    af
        push    bc
        push    hl

        ld      a,[amShowingDialog]
        or      a
        jr      nz,.seasonsWindow

        ;jr      z,.normal
        ;ld      a,[hblankFlag]
        ;and     %11
        ;jr      nz,.seasonsWindow

.normal
        ldio    a,[$ff44]        ;ypos
        cp      143
        jr      z,.toWhite
        cp      39
        jp      nz,.seasonsWindow

.toBrown
        push    de
        ld      c,$68
        ld      hl,fadeCurPalette+62
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a
        ld      hl,$ff69
        jp      HBlankSetBGColorCDEHL_DEPushed

.toWhite
        push    de
        ld      c,$68
        ld      hl,mapColor
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a
        ld      hl,$ff69
        jp      HBlankSetBGColorCDEHL_DEPushed

.seasonsWindow
        ldio    a,[$ff41]           ;get stat register
        bit     2,a                 ;equal to lyc?
        jp      z,FinishHBlankPlayingSample

.continue
        ld      hl,hblankFlag
        bit     0,[hl]              ;turning window on or off?
        jr      nz,.turnOff

        ;turn on window
        bit     1,[hl]              ;allowed to?
        jr      z,.toBrown
        ;jr      nz,.turnOn
        ;jp      FinishHBlankPlayingSample
.turnOn
        set     0,[hl]
        ldio    a,[hblankWinOff]
        ld      [$ff45],a           ;reset lyc to win off pos
        ld      hl,$ff40            ;turn window on
        set     5,[hl]
        jp      OnHBlank_SetBGColorBlack

.turnOff
        res     0,[hl]
        ldio    a,[hblankWinOn]
        ld      [$ff45],a           ;reset lyc to win on pos
        ld      hl,$ff40            ;turn window off
        res     5,[hl]

        jr      .toBrown

;---------------------------------------------------------------------
; Routine:      GetInput
; Description:  Swaps in the link code bank, passes the work along to
;               HandleInput, and swaps in the object bank before
;               ending.
;---------------------------------------------------------------------
GetInput::
        LONGCALLNOARGS HandleInput

        ;if the heroes are idle then set both inputs to zero
        ld      a,[heroesIdle]
        or      a
        ret     z

        xor     a
        ld      [curJoy0],a
        ld      [curJoy1],a

        ret

;---------------------------------------------------------------------
; Routine:      CheckPause
; Description:  Checks for pause button being pressed
;---------------------------------------------------------------------
CheckPause:
        ld      hl,dialogJoyIndex
        ld      a,[hl]
        push    af

        ld      a,[heroesPresent]
        cp      %11
        jr      z,.checkBoth

        dec     a
        ld      [hl],a
        ld      a,[myJoy]
        bit     JOY_START_BIT,a
        jr      z,.done
        jr      .checkModes

.checkBoth
        ld      [hl],0
        ld      a,[curInput0]
        bit     JOY_START_BIT,a
        jr      nz,.checkModes

        ld      [hl],1
        ld      a,[curInput1]
        bit     JOY_START_BIT,a
        jr      z,.done

.checkModes
        ld      a,[amShowingDialog]
        or      a
        jr      nz,.done

        ld      a,[displayType]
        or      a
        jr      nz,.done

        ld      a,[amChangingMap]
        or      a
        jr      nz,.done

        ld      a,[heroesIdle]
        or      a
        jr      nz,.done

        ;(show as dialog)
        ld      a,[dialogSettings]
        push    af
        call    SetPressBDialog
        call    SaveIdle

        ld      de,.afterPause
        call    SetDialogSkip

        ld      a,BANK(GeneratePauseMessage)
        ld      hl,GeneratePauseMessage
        call    LongCallNoArgs

        ld      a,1
        ld      [amShowingDialog],a
        ld      de,backBuffer+63

        call    ShowDialogAtTopCommon
        call    DialogWaitInputZero

.wait
        call    UpdateObjects
        call    RedrawMap
        call    SetDialogJoy
        bit     JOY_SELECT_BIT,[hl]
        jr      nz,.selectPressed
        call    CheckDialogContinue
        or      a
        jr      z,.wait

.afterPause
        call    ClearDialog

        call    RestoreIdle
        pop     af
        ld      [dialogSettings],a
.done
        pop     af
        ld      [dialogJoyIndex],a
        ret

.selectPressed
        call    ClearDialog
        call    RestoreIdle
        pop     af
        ld      [dialogSettings],a
        pop     af
        ld      [dialogJoyIndex],a

        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,respawnMap
        ld      a,[hl+]
        ld      [curLevelIndex],a
        ld      a,[hl+]
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret


;---------------------------------------------------------------------
; Routine:      UpdateObjects
; Description:  Waits for a vertical blank and then updates the
;               objects
;---------------------------------------------------------------------
MainLoopUpdateObjects:
        call    VWait             ;wait for a vertical blank
        ld      a,1
        ld      [checkInputInMainLoop],a
        call    GetInput
        call    CheckPause
        xor     a
        ld      [checkInputInMainLoop],a
        jr      .doneWithInput

.vwait  call    VWait             ;wait for a vertical blank

.doneWithInput
        call    CheckSpecialFX

        ;wait for previous frame to be drawn
        ldio    a,[backBufferReady]
        or      a
        jp      nz,.vwait
        jr      UpdateObjectsCommon

UpdateObjects::
        call    VWait             ;wait for a vertical blank
        call    GetInput

.vwait  call    VWait             ;wait for a vertical blank

.doneWithInput
        call    CheckSpecialFX

        ;wait for previous frame to be drawn
        ldio    a,[backBufferReady]
        or      a
        jp      nz,.vwait

UpdateObjectsCommon:
        ld      a,[displayType]
        or      a
        ret     nz              ;done if cinema type

        ;check each object
        ld      b,METHOD_CHECK
        ld      a,[iterateNumObjects]
        ld      c,a
        call    IterateMaxObjects

        ;update the timers that hero/hero bullets base moves off of
        call    UpdateHeroTimers

        ;make sure we check the hero & hero's bullets each time
        ld      hl,hero0_index
        call    .checkHeroObjects
        ld      hl,hero1_index
        call    .checkHeroObjects

        ret

.checkHeroObjects
        ld      a,[hl+]                ;heroX_index
        or      a
        ret     z                      ;this hero doesn't exist

        ld      c,a
        call    GetFirst
        ld      b,METHOD_CHECK
        ;ld      e,[hl]                 ;heroX_objectL
        ;inc     hl
        ;ld      d,[hl]                 ;heroX_objectH
        ;inc     hl
        call    CallMethod

        inc     hl
        inc     hl

        ld      a,[hl]                 ;heroX_bulletIndex
        ld      c,a
        call    GetFirst
        call    IterateList
        ret

;---------------------------------------------------------------------
; Routine:      RedrawMap
; Description:  Redraws the map for the next vblank
;---------------------------------------------------------------------
RedrawMap::
        call    RestrictCameraToBounds
        call    ScrollToCamera

        call    DrawMapToBackBuffer
        call    UpdateEnvEffect

        ld      a,1
        ldio    [backBufferReady],a  ;signal we're ready for DMA

        ret



;---------------------------------------------------------------------
; Routine:      HandleRemoteInput
; Arguments:    a - remoteInput
; Returns:      a - remoteInput
;               zflag - set if must repeat
; Alters:       af
;---------------------------------------------------------------------
HandleRemoteInput::
        bit     7,a            ;test bit 7
        ret     z              ;got the BCB

        ;handle the link command code we received.
        call    HandleLCC

        ;indicate we need to try exchanging our control bytes again
        ld      a,1
        or      a              ;don't set zero flag
        ret

;---------------------------------------------------------------------
; Routine:      HandleLCC
; Arguments:    a - value of the Link Command Code.
; Returns:      nothing.
; Alters:       af
;---------------------------------------------------------------------
HandleLCC:
.checkLGETGAMESTATE
        cp      LGETGAMESTATE
        jr      nz,.checkLGETMAPINDEX

        ;LGETGAMESTATE
        LONGCALLNOARGS TransmitGameState
        ret

.checkLGETMAPINDEX
        cp      LGETMAPINDEX
        jr      nz,.checkLUPDATESTATE

        ;LGETMAPINDEX
        ld      a,[displayType]
        or      a
        jr      nz,.returnDifferentMapCode  ;cinema type
        ld      a,[amChangingMap]
        or      a
        jr      nz,.returnWaitCode
        ld      a,[canJoinMap]
        ;or      a
        ;jr      z,.returnWaitCode
        cp      2
        jr      z,.returnDifferentMapCode   ;do this map independently

        ld      a,[curLevelStateIndex]
        jr      .returnMapIndex
.returnWaitCode
        ld      a,$ff
        jr      .returnMapIndex
.returnDifferentMapCode
        ld      a,$fe
.returnMapIndex
        call    TransmitByte
        ret

.checkLUPDATESTATE
        cp      LUPDATESTATE
        jr      nz,.checkLUPDATEHERO

        ;LUPDATESTATE
        push    hl
        ld      a,LEVELSTATEBANK
        ld      [$ff70],a
        call    ReceiveByte
        ld      h,((levelState>>8) & $ff)
        ld      l,a
        call    ReceiveByte
        ld      [hl],a
        pop     hl

        ret

.checkLUPDATEHERO
        cp      LUPDATEHERO
        jr      nz,.checkLYANKPLAYER

        ;LUPDATEHERO
        call    ReceiveByte
        ld      [heroesUsed],a
        ret

.checkLYANKPLAYER
        cp      LYANKPLAYER
        jr      nz,.checkLRESYNCHRONIZE

        ;LYANKPLAYER
        ;get exit direction
        call    ReceiveByte
        ld      [hero0_enterLevelFacing],a

        ;get new map coordinates
        push    bc
        push    af
        call    ReceiveByte
        ld      c,a
        call    ReceiveByte
        ld      b,a
        ld      a,[hero0_enterLevelFacing]
        and     7
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a
        pop     af
        cp      8
        jr      nc,.changeMap

        ld      a,[curLevelIndex]
        cp      c
        jr      nz,.changeMap
        ld      a,[curLevelIndex+1]
        cp      b
        jr      z,.noChangeMap

.changeMap
        ld      a,c
        ld      [curLevelIndex],a    ;map index lobyte
        ld      a,b
        ld      [curLevelIndex+1],a    ;map index lobyte
        ld      a,1
        ld      [timeToChangeLevel],a

.noChangeMap ;already on this map
        pop     bc
        ret

.checkLRESYNCHRONIZE
        cp      LRESYNCHRONIZE
        jr      nz,.checkLGETRANDOMSEED

        LONGCALLNOARGS GuestContinueSynchronization
        ret

.checkLGETRANDOMSEED
        cp      LGETRANDOMSEED
        jr      nz,.checkLTERMINATE

        ldio    a,[randomLoc]
        call    TransmitByte
        ret

.checkLTERMINATE
        cp      LTERMINATE
        jr      nz,.checkLSYNCHRONIZE

        ld      a,[amLinkMaster]
        cp      1
        jr      z,.terminateMaster

        ;terminate slave
        rst     $00
.terminateMaster
        ld      a,$fe
        ld      [amLinkMaster],a
        ret

.checkLSYNCHRONIZE
        cp      LSYNCHRONIZE
        jr      nz,.checkLLOCKHEROES

        ;LSYNCHRONIZE
        ;am I ready to synchronize?
        ld      a,[checkInputInMainLoop]
        or      a
        jr      z,.notReadyToSync
        ld      a,[amShowingDialog]
        or      a
        jr      nz,.readyIfCinema
        ld      a,[canJoinMap]
        or      a
        jr      z,.notReadyToSync
        jr      .readyToSynchronize

.readyIfCinema
        ld      a,[displayType]
        or      a
        jr      nz,.readyToSynchronize

        ;not ready
.notReadyToSync
        ld      a,LSYNCHWAIT
        call    TransmitByte
        ret

.readyToSynchronize
        ld      a,LSYNCHREADY
        call    TransmitByte
        LONGCALLNOARGS HostSynchronize
        ret

.checkLLOCKHEROES
        cp      LLOCKHEROES
        jr      nz,.checkLNOLINK

        call    ReceiveByte      ;receive lock or unlock from remote
        ld      [heroesLocked],a
        ret

.checkLNOLINK
        cp      LNOLINK
        jr      nz,.checkLLINKTEST
        ret

.checkLLINKTEST
        cp      LLINKTEST
        jr      nz,.checkLCHANGEAPPXMAP

        LONGCALLNOARGS LinkTest
        ret

.checkLCHANGEAPPXMAP
        cp      LCHANGEAPPXMAP
        jr      nz,.checkLADDINVITEM

        LONGCALLNOARGS NewAppxLocation
        ret

.checkLADDINVITEM
        cp      LADDINVITEM
        jr      nz,.checkLREMINVITEM

        push    bc
        call    ReceiveByte      ;get bc (inventory item)
        ld      c,a
        call    ReceiveByte
        ld      b,a

        ;duplicate code also in Map.asm
        push    hl
        call    PointHLToInventory
        or      c
        ld      [hl],a
        pop     hl
        pop     bc
        ret

.checkLREMINVITEM
        cp      LREMINVITEM
        jr      nz,.checkLUPDATEMEMORY

        ;duplicate code also in Map.asm
        push    bc
        call    ReceiveByte      ;get bc (inventory item)
        ld      c,a
        call    ReceiveByte
        ld      b,a

        ;duplicate code also in Map.asm
        push    hl
        call    PointHLToInventory
        xor     $ff
        or      c
        xor     $ff
        ld      [hl],a
        pop     hl
        pop     bc
        ret

.checkLUPDATEMEMORY
        cp      LUPDATEMEMORY
        jr      nz,.unknown

        push    hl
        call    ReceiveByte   ;memory bank of data
        ldio    [$ff70],a
        call    ReceiveByte   ;address
        ld      l,a
        call    ReceiveByte
        ld      h,a
        call    ReceiveByte   ;new value
        ld      [hl],a
        pop     hl
        ret

.unknown
        ret

;---------------------------------------------------------------------
; Routines:     LLTransmitByte
; Arguments:    a              - byte to send
;               [amLinkMaster] - should be set to 1 or 0
; Returns:      Nothing.
; Alters:       af
; Note:         DON'T CALL THIS DIRECTLY.  It should only be called
;               via TransmitByte and ReceiveByte.
; Description:  Low-level routine to transmit a byte via the link
;               cable.
;---------------------------------------------------------------------
LLTransmitByte:
        di      ;be sure we're not interrupted
        ldio    [$ff01],a   ;store the data to transfer
        ld      a,INTCLK
        ldio    [$ff02],a   ;let's do it
.waitForCompletion
        ldio    a,[$ff02]                       ;12
        and     $80                             ; 8
        jr      nz,.waitForCompletion           ; 8

        ;go into slave mode to await next byte
        ld      a,EXTCLK                        ; 8
        ldio    [$ff02],a                       ;12  TOTAL = 48

        ;clear pending interrupts
        xor     a
        ei
        ld      [$ff0f],a

        ret

;---------------------------------------------------------------------
; Routines:     LLReceiveByte
; Arguments:    [amLinkMaster] - should be set to 1 or 0
; Returns:      a - byte received from linked GameBoy.
; Alters:       af
; Note:         DON'T CALL THIS DIRECTLY.  It should only be called
;               via TransmitByte and ReceiveByte.
; Description:  Low-level routine to receive a byte via the link
;               cable.  If no signal within nine seconds aborts link
;               connection and:
;                 Master - continues game as slaveless master ($fe).
;                 Slave  - restarts game.
;---------------------------------------------------------------------
LLReceiveByte:
        push    bc
        push    de

        ld      de,$0C00   ;abort timer counts down $C00 * 256 times
        ld      c,0        ;(about 1.25 sec per $100)
.waitForCompletion
        ldio    a,[$ff02]
        and     $80
        jr      z,.gotValue

        ;update our abort timer
        dec     c
        jr      nz,.waitForCompletion

        dec     de
        xor     a
        cp      d
        jr      nz,.waitForCompletion
        cp      e
        jr      nz,.waitForCompletion
        jr      .linkLost

.gotValue
        ldio    a,[$ff01]   ;return the value we received

        ;kill some time before we let ourselves change to master
        ;to give the current master time to change to slave
        push    af
.killOuter
        ld      a,6
.killTime
        dec     a               ; 4
        jr      nz,.killTime    ; 4/8  TOTAL = 8, *6=48
        pop     af
        jr      .done

.linkLost
        ld      a,[amLinkMaster]
        or      a
        jr      z,.amSlave

        cp      1
        jr      z,.amMaster

        ;link already lost, restore stack & jump to bail-out address
        ;if not 0
        ld      a,[linkBailOut]     ;get bail-out address
        ld      e,a
        ld      a,[linkBailOut+1]
        ld      d,a
        xor     a
        cp      d
        jr      nz,.bail
        cp      e
        jr      nz,.bail

        ;null bail address; just quit
        jr      .done

.bail
        ;restore the stack before jumping to the bail address
        ld      a,[linkBailOut+2]
        ld      l,a
        ld      a,[linkBailOut+3]
        ld      h,a
        ld      sp,hl
        push    de
        ret

.amMaster
        ld      a,$fe
        ld      [amLinkMaster],a

        call    RemoveRemoteHero
        jr      .done

.amSlave
        rst     $00             ;restart the game

.done
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      TransmitByte
; Argument:     a - byte to send
; Returns:      Nothing.
; Alters:       af
; Description:  Transmits a byte via the link cable to a remote GBC.
;---------------------------------------------------------------------
TransmitByte::
        push    bc
        ld      b,a

        ;If I was the last one to transmit, receive a byte as an
        ;acknowledgement.
        ld      a,[lastLinkAction]
        or      a
        jr      z,.afterOrientStream

        call    LLReceiveByte

.afterOrientStream
        ld      a,1          ;our action this time is to transmit
        ld      [lastLinkAction],a

        ld      a,b
        call    LLTransmitByte

.done
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      ReceiveByte
; Arguments:    None.
; Returns:      a - byte received.
; Alters:       af
; Description:  Receives a byte from a remote machine.
;---------------------------------------------------------------------
ReceiveByte::
        ;If necessary we'll transmit a value to avoid receiving twice
        ;in a row.
        ld      a,[lastLinkAction]
        or      a
        jr      nz,.afterOrientStream

        ld      a,1
        call    LLTransmitByte

.afterOrientStream
        xor     a   ;our action this time is to receive
        ld      [lastLinkAction],a

        call    LLReceiveByte
        ret


;---------------------------------------------------------------------
; Routine:      ExchangeByte
; Argument:     a - byte to send
; Returns:      a - byte received in return
; Alters:       af
; Description:  Uses value of [amLinkMaster] (Master should be $01 and
;               Slave should be $00) to determine sequencing of
;               TransmitByte and ReceiveByte.
;---------------------------------------------------------------------
ExchangeByte::
        push    bc
        ld      b,a

        ld      a,[amLinkMaster]
        or      a
        jr      z,.slaveExchange

        ;masterExchange
        ld      a,b
        call    TransmitByte
        call    ReceiveByte
        jr      .done

.slaveExchange
        call    ReceiveByte
        ld      c,a
        ld      a,b
        call    TransmitByte
        ld      a,c

.done
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      TransmitData
; Arguments:    a  - RAM bank to switch to (may/may not make a diff)
;               bc - number of bytes to transmit
;               hl - starting address of data to transmit
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
TransmitData::
        push    bc
        push    hl

        ldio    [$ff70],a

.loop   ld      a,[hl+]
        call    TransmitByte
        dec     bc
        xor     a
        cp      b
        jr      nz,.loop
        cp      c
        jr      nz,.loop

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ReceiveData
; Arguments:    a  - RAM bank to switch to (may/may not make a diff)
;               bc - number of bytes to receive
;               hl - starting address to store data
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
ReceiveData::
        push    bc
        push    hl

        ldio    [$ff70],a     ;change RAM bank

.loop   call    ReceiveByte
        ld      [hl+],a
        dec     bc
        xor     a
        cp      b
        jr      nz,.loop
        cp      c
        jr      nz,.loop

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      TransmitCompressedData
; Arguments:    a  - RAM bank to switch to (may/may not make a diff)
;               bc - number of bytes to transmit
;               hl - starting address of data to transmit
; Returns:      Nothing.
; Alters:       af
; Description:  Packs bytes 8:1 into the backBuffer by combining
;               bit[0] from every eight bytes into one byte.  The
;               left-most bit will be from byte[0] and the right-most
;               from byte[7].
;---------------------------------------------------------------------
TransmitCompressedData::
        push    bc
        push    de
        push    hl

        ldio    [$ff70],a

        ;divide len by 8  (>>3)
        srl     b
        rr      c
        srl     b
        rr      c
        srl     b
        rr      c

        push    bc            ;save length

        ;----Compress the data into backBuffer------------------------
        ld      de,backBuffer ;compression buffer
.nextByte
        push    de            ;push destination
        ld      de,8          ;d is compressed (0), e is times to loop

.nextBit
        ld      a,[hl+]       ;get the next byte
        rrca                  ;shift out bit[0] into the carry flag
        rl      d             ;rotate onto right side of result
        dec     e
        jr      nz,.nextBit

        ld      a,d           ;a has compressed byte
        pop     de            ;pop destination
        ld      [de],a        ;store the compressed byte
        inc     de

        dec     bc
        xor     a
        cp      b
        jr      nz,.nextByte
        cp      c
        jr      nz,.nextByte

        pop     bc   ;done with compression, retrieve len

        ld      hl,backBuffer  ;transmit the compressed data
        xor     a
        call    TransmitData

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ReceiveCompressedData
; Arguments:    a  - RAM bank to switch to (may/may not make a diff)
;               bc - number of bytes to receive
;               hl - starting address of data to receive
; Returns:      Nothing.
; Alters:       af
; Description:  Receives numBytes/8 into the backBuffer, then unpacks
;               each byte 1:8 to the data address.
;---------------------------------------------------------------------
ReceiveCompressedData::
        push    bc
        push    de
        push    hl

        push    af            ;save original RAM bank
        push    hl            ;save original dest

        ;----Calculate numBytes/8 (>>3)-------------------------------
        srl     b
        rr      c
        srl     b
        rr      c
        srl     b
        rr      c

        ld      hl,backBuffer  ;receive the compressed data
        xor     a
        call    ReceiveData

        pop     hl             ;retrieve original dest
        pop     af             ;retrieve original RAM bank
        ldio    [$ff70],a

        ;----Decompress the data into the destination buffer----------
        ld      de,backBuffer ;decompression buffer
.nextByte
        ld      a,[de]        ;get a byte from the buffer
        inc     de
        push    de            ;push source
        ld      d,a           ;store compressed byte in d
        ld      e,8           ;e is times to loop

.nextBit
        xor     a
        rl      d             ;get a bit off left side of compressed
        rla                   ;shift onto right side of uncompressed
        ld      [hl+],a       ;store in final destination
        dec     e
        jr      nz,.nextBit

        pop     de            ;pop source

        dec     bc
        xor     a
        cp      b
        jr      nz,.nextByte
        cp      c
        jr      nz,.nextByte

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CheckSimultaneousLCC
; Argument:     a - byte received from link exchange
; Returns:      not z flag - this machine must repeat its command
;               z flag set - everything is okay
; Alters:       af
; Description:  Called after one machine has sent the first byte of
;               a Link Command Code.  If the remote machine
;               coincidentally sent its own LCC at the same time then
;               the Slave must delay its own LCC until the Master's
;               LCC has been handled.
;---------------------------------------------------------------------
CheckSimultaneousLCC::
        bit     7,a           ;see if we got a LCC or a BCB.
        ret     z             ;Got a BCB, everything's cool.

        ;Got a LCC.  If I'm the Master then the other machine must
        ;yield to me so everything's still cool.
        push    af
        ld      a,[amLinkMaster]
        or      a
        jr      z,.amSlave
        pop     af
        xor     a
        ret

.amSlave
        ;I must yield to the Master.  Handle his request and then
        ;return a value indicating I must repeat my own request.
        pop     af
        call    HandleLCC
        ld      a,1
        or      a
        ret

;---------------------------------------------------------------------
; Routine:      YankRemotePlayer
; Arguments:    a  - exit to set to  (>7 means &7 and don't check
;                    to see if you're on the map)
;
;               hl - map to set to in BCD (e.g. $0205)
; Returns:      Nothing.
; Alters:       af
; Description:  Interrupts whatever the other player is doing and
;               sets him to come to the specified map.  Also sets
;               the join/respawn map to the map to set to.
;---------------------------------------------------------------------
YankRemotePlayer::
        push    af
        call    UpdateState
        call    SetJoinMap
        call    SetRespawnMap
        pop     af

        ;verify link established
        push    hl
        ld      hl,amLinkMaster
        bit     7,[hl]
        pop     hl
        ret     nz

        push    af
        push    hl
        ld      a,2    ;two additional things on stack
        ld      hl,.linkBailAddress
        call    SetLinkBailOutAddress

        pop     hl

.sendYank
        ld      a,LYANKPLAYER
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.sendYank
        pop     af

        ;remote machine is listening; send map coords
        call    TransmitByte   ;exit dir
        ld      a,l
        call    TransmitByte
        ld      a,h
        call    TransmitByte
.linkBailAddress
        push    hl
        ld      hl,0
        xor     a
        call    SetLinkBailOutAddress
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      RemoveRemoteHero
; Arguments:    None.
; Returns:      Nothing.
; Alters:       af
; Description:  Deletes the remote hero and removes traces of its
;               presence.
;---------------------------------------------------------------------
RemoveRemoteHero::
        push    bc
        push    de
        push    hl

        ;determine which is the remote hero
        ld      a,[amLinkMaster]
        or      a
        jr      z,.amSlave

.amMaster
        ld      hl,hero1_index
        jr      .determinedRemoteHero

.amSlave
        ld      hl,hero0_index

.determinedRemoteHero
        ;remove remote hero from map if present
        ld      a,[hl]          ;heroX_index
        or      a
        jr      z,.done         ;not here

        ;save the current ROM & switch in the object ROM
        ldio    a,[curROMBank]
        push    af
        ld      a,CLASSROM
        call    SetActiveROM

        ;----remove this one's heroesPresent flag----
        ld      a,[hl]          ;heroX_index
        push    af

        ld       a,l
        and      16
IF HERODATASIZE!=16
fix this
ENDC
        swap     a              ;a is now 1 or 0
        add      1              ;now 2 or 1
        xor      $ff            ;now ~2 or ~1
        ld       b,a
        ld       a,[heroesPresent]
        and      b
        ld       [heroesPresent],a

        ;push    hl
        ;ld      de,(HERODATA_TYPE - HERODATA_INDEX)
        ;add     hl,de
        ;ld      a,[hl]          ;heroX_type
        ;xor     $ff
        ;ld      b,a
        ;ld      a,[heroesPresent]
        ;and     b
        ;ld      [heroesPresent],a
        ;pop     hl
        xor     a
        ld      [hl],a          ;heroX_index
        pop     af

        ld      c,a
        call    GetFirst
        ld      b,METHOD_DIE
        call    CallMethod

        ;restore the old ROM
        pop     af
        call    SetActiveROM

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      DebugMesg
; Argument:     hl - pointer to a gtx structure
; Returns:      Nothing.
; Alters:       af
; Description:  Displays the given gtx string in a window for a
;               brief period.
;---------------------------------------------------------------------
DebugMesg::
        push    bc
        push    de
        push    hl

        ldio    a,[$ff40]
        and     %10000000
        jr      z,.done

        ld      d,h
        ld      e,l
        xor     a

        ;-------Show Dialog At Top-------------------
        push    af
        push    bc
        push    de
        push    hl

        ld      b,0            ;lines to skip at top
        ld      a,[curROMBank]
        call    ShowDialogCommon

        xor     a
        ldh     [$ff4a], a     ;set window y position

        ld      a,[de]         ;number of lines
        rlca                   ;times 8 = pixels for window
        rlca
        rlca
        add     7
        ld      [hblankWinOff],a

        ld      a,143
        ld      [hblankWinOn],a

        ld      a,[hblankFlag]
        bit     1,a
        jr      nz,.afterSetLYC

        ld      a,143
        ld      [$ff45],a            ;lyc
        ld      a,[hblankFlag]

.afterSetLYC
        or      %10               ;allow window to show
        ld      [hblankFlag],a

        pop     hl
        pop     de
        pop     bc
        pop     af
        ;-------Show Dialog At Top-------------------

        ld      bc,16384
        call    TimerDelay
        call    ClearDialog

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      DebugVal
; Argument:     a - byte to show as a hex value
; Returns:      Nothing.
; Alters:       Nothing.
; Description:  Displays the given value in hex using a Dialog
;               window for a brief period.  Game must be on.
;---------------------------------------------------------------------
DebugVal::
        push    af
        push    bc
        push    de
        push    hl

        ld      b,a    ;save byte

        ldio    a,[$ff40]
        and     %10000000
        jr      z,.done

        ld      hl,$c200
        ld      [hl],1
        inc     hl
        ld      [hl],1
        inc     hl
        ld      [hl],2
        inc     hl
        ld      a,b
        ld      c,0
        swap    a
        and     $0f
        add     200
        ld      [hl+],a
        ld      a,b
        and     $0f
        add     200
        ld      [hl+],a
        ld      de,$c200
        xor     a

        ;-------Show Dialog At Top-------------------
        push    af
        push    bc
        push    de
        push    hl

        ld      b,0            ;lines to skip at top
        ld      a,[curROMBank]
        call    ShowDialogCommon

        xor     a
        ldh     [$ff4a], a     ;set window y position

        ld      a,[de]         ;number of lines
        rlca                   ;times 8 = pixels for window
        rlca
        rlca
        add     7
        ld      [hblankWinOff],a

        ld      a,143
        ld      [hblankWinOn],a

        ld      a,[hblankFlag]
        bit     1,a
        jr      nz,.afterSetLYC

        ld      a,143
        ld      [$ff45],a            ;lyc
        ld      a,[hblankFlag]

.afterSetLYC
        or      %10               ;allow window to show
        ld      [hblankFlag],a

        pop     hl
        pop     de
        pop     bc
        pop     af
        ;-------Show Dialog At Top-------------------

        ld      bc,8192    ;16384
        call    TimerDelay
        call    ClearDialog

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      TimerDelay
; Argument:     bc - number of 16384's of a second to delay
; Alters:       af
;---------------------------------------------------------------------
TimerDelay::
        push    bc
        push    de
        push    hl

        ld      hl,$ff04
        ld      d,0          ;prev value of time
        ld      [hl],0
.wait
        ld      a,[hl]
        ld      e,a
        xor     d            ;equal to prev value?
        jr      z,.wait

        ld      d,e
        dec     bc
        xor     a
        cp      b
        jr      nz,.wait
        cp      c
        jr      nz,.wait

        pop     hl
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      SetDialogSkip
;               SetDialogForward
; Arguments:    de - position to skip or fast forward to
; Alters:       af
; Description:  Saves the stack pointer (minus the space that this
;               function call is taking up) and sets the go-to
;               address for fast forwarding (any button pressed)
;               or skipping (start button pressed).
;---------------------------------------------------------------------
SetDialogSkip::
        push    hl
        ld      hl,sp+4     ;stack ptr pos once returned from this fn
        ld      a,e
        ld      [levelCheckSkip+2],a     ;set skip forward addr
        ld      a,d
        ld      [levelCheckSkip+3],a
        jr      SetDialogCommon

SetDialogForward::
        push    hl
        ld      hl,sp+4     ;stack ptr pos once returned from this fn
        ld      a,e                      ;set fast forward addr
        ld      [levelCheckSkip],a
        ld      a,d
        ld      [levelCheckSkip+1],a
        jr      SetDialogCommon

SetSkipStackPos::
        push    hl
        ld      hl,sp+4     ;stack ptr pos once returned from this fn

SetDialogCommon:
        ld      a,l
        ld      [levelCheckStackPos],a
        ld      a,h
        ld      [levelCheckStackPos+1],a
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      ClearDialogSkipForward
; Arguments:    None.
; Alters:       af,hl
;---------------------------------------------------------------------
ClearDialogSkipForward::
        call    ClearDialog
        call    ClearSkipForward
        ret

;---------------------------------------------------------------------
; Routine:      ClearSkipForward
; Arguments:    None.
; Alters:       af,hl
;---------------------------------------------------------------------
ClearSkipForward::
        ld      de,0
        call    SetDialogSkip
        call    SetDialogForward
        ret

;---------------------------------------------------------------------
; Routine:      SetRespawnMap
; Arguments:    hl - map to go to after hero dies
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
SetRespawnMap::
        ld      a,l
        ld      [respawnMap],a
        ld      a,h
        ld      [respawnMap+1],a
        ret

;---------------------------------------------------------------------
; Routine:      SetJoinMap
; Arguments:    hl - map to join from 2nd player title screen
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
SetJoinMap::
        ld      a,l
        ld      [joinMap],a
        ld      a,h
        ld      [joinMap+1],a
        ret

;---------------------------------------------------------------------
; Routine:      SetLinkBailOutAddress
; Arguments:    a  - number of additional words to add to stack
;                    pointer
;               hl - saves stack pointer and bailout address into
;                    [linkBailOut0...3].
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
SetLinkBailOutAddress::
        push    hl
        push    af
        ;save bail out address
        ld      a,l
        ld      [linkBailOut],a
        ld      a,h
        ld      [linkBailOut+1],a

        ;save stack pointer (plus a*2 + 6 for things pushed on stack)
        ld      hl,sp+6
        pop     af
        or      a
        jr      z,.afterAdjustStackPointer

.adjustStackPointer
        inc     hl
        inc     hl
        dec     a
        jr      nz,.adjustStackPointer

.afterAdjustStackPointer
        ld      a,l
        ld      [linkBailOut+2],a
        ld      a,h
        ld      [linkBailOut+3],a

        pop     hl
        ret


;---------------------------------------------------------------------
; Routine:      RemoveSpriteObjectsFromMap
;---------------------------------------------------------------------
RemoveSpriteObjectsFromMap:
        ;----remove all objects from the map--------------------------
        ld      a,OBJLISTBANK
        ldio    [$ff70],a
        ld      hl,objExists+1
.removeObjectsLoop
        push    hl
        ld      a,[hl]
        or      a
        jr      z,.removeObjects_continue
        ld      a,l
        call    IndexToPointerDE
        ld      a,[numClasses]
        ld      b,a
        inc     b
        ld      h,((objClassLookup>>8) & $ff)
        ld      a,[hl]
        cp      b             ;this obj a regular creature?
        jr      nc,.removeObjects_continue

        call    GetFacing
        bit     7,a           ;sprite?
        jr      z,.restoreObjListBank   ;no
        ld      c,a
        call    RemoveFromMap
.restoreObjListBank
        ld      a,OBJLISTBANK
        ldio    [$ff70],a
.removeObjects_continue
        pop     hl
        inc     hl
        ld      a,h
        cp      ((objExists>>8) & $ff) + 1
        jr      nz,.removeObjectsLoop
        ret

;---------------------------------------------------------------------
; Routine:      GetMethodAddrFromPointer
; Arguments:    hl - pointer to method address
; Returns:      hl - pointer to method
; Alters:       af
;---------------------------------------------------------------------
GetMethodAddrFromPointer::
        PUSHROM
        ld      a,BANK(classTable)
        call    SetActiveROM

        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        POPROM
        ret

;---------------------------------------------------------------------
; Routine:      InstallHBlankHandler
; Arguments:    hl - pointer to hblank handler
; Returns:      Nothing.
; Alters:       af
;---------------------------------------------------------------------
InstallHBlankHandler::
        di
        ld      a,l
        ld      [hblankVector+1],a   ;+0 is opcode "jp"
        ld      a,h
        ld      [hblankVector+2],a
        ei
        ret

;---------------------------------------------------------------------
; Routine:      LockRemoteHeroesUsed
; Arguments:    None.
; Returns:      z  - lock attempt unsuccessful
;               nz - success
; Alters:       af
; Description:  Informs the remote machine that this machine is
;               messing with the heroes to prevent collisions
;---------------------------------------------------------------------
LockRemoteHeroesUsed::
        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.lockOkay

.sendLock
        ld      a,[heroesLocked]
        or      a
        jr      nz,.returnFailure
        ld      a,LLOCKHEROES
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.sendLock

        ld      a,1  ;send "locked" to remote
        call    TransmitByte

.lockOkay
        ld      a,1
        ld      [heroesLocked],a
        or      a
        ret

.returnFailure
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      UpdateRemoteHeroesUsed
; Arguments:    None.
; Returns:      Nothing.
; Alters:       af
; Description:  Sends current [heroesUsed] to the remote machine
;               if present.  Also unlocks heroesUsed if locked.
;---------------------------------------------------------------------
UpdateRemoteHeroesUsed::
        ld      a,[amLinkMaster]
        bit     7,a
        jr      z,.updateHeroesUsed

        ;no link, free lock
        xor     a
        ld      [heroesLocked],a
        ret

.updateHeroesUsed
        ld      a,LUPDATEHERO
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.updateHeroesUsed      ;must repeat

        ld      a,[heroesUsed]
        call    TransmitByte

        ld      a,[heroesLocked]
        or      a
        ret     z  ;not locked don't bother

.sendLock
        ld      a,LLOCKHEROES
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.sendLock

        xor     a              ;send "unlocked" to remote
        ld      [heroesLocked],a
        call    TransmitByte

        ret

;---------------------------------------------------------------------
; Routine:      PlaySample
; Arguments:    a  - bank of sample
;               hl - start address of sample
; Alters:       af,hl
; Description:
;---------------------------------------------------------------------
PlaySample::
        ;start sample playing
        di
        ldio    [sampleBank],a
        xor     a
        ldio    [samplePlaying],a
        ei

        ld      a,l
        ldio    [sampleAddress],a
        ld      a,h
        ldio    [sampleAddress+1],a
        ld      a,$0f
        ldio    [sampleMask],a
        ld      a,$86
        ldio    [$ff1a],a    ;sound 3 enable
        ld      hl,$ff26
        set     2,[hl]
        ld      a,1
        ldio    [samplePlaying],a
        ret

;---------------------------------------------------------------------
;  FinishHBlankPlayingSample
;---------------------------------------------------------------------
FinishHBlankPlayingSample::
        ldio    a,[samplePlaying]
        or      a
        jr      z,.done

.nextSample
        ld      hl,sampleAddress
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
.loadNextSample
        ldio    a,[sampleBank]
        ld      [$2100],a
        ldio    a,[sampleMask]
        xor     $ff
        ldio    [sampleMask],a
        cp      $0f
        jr      nz,.getLeftNibble

.getRightNibble
        and     a,[hl]
        inc     hl
        jr      .normalData ;will never be special code

.getLeftNibble
        and     a,[hl]      ;next sample byte

.checkForSpecialCodes
        cp      $80
        jr      nz,.normalData

        ;code indicating termination or link follows
        inc     hl
        ld      a,[hl+]
        or      a
        jr      nz,.link

        ld      [samplePlaying],a
        ld      a,$ff
        ld      [$ff24],a         ;full volume both channels
        jr      .restoreBank

.link   ld      a,[hl+]
        ld      [sampleBank],a
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        jr      .loadNextSample

.normalData
        ld      b,a
        swap    a
        or      b
        or      $88
        ldio    [$ff24],a        ;sound enabled/volume

.saveNewAddress
        ld      a,l
        ldio    [sampleAddress],a
        ld      a,h
        ldio    [sampleAddress+1],a

.restoreBank
        ldio    a,[curROMBank]
        ld      [$2100],a

.done
        pop     hl
        pop     bc
        pop     af
        reti

;---------------------------------------------------------------------
; Routine:      Lookup8
; Arguments:    a  - index
;               hl - start lookup table
; Alters:       af,hl
; Returns:      a - table[a]
;---------------------------------------------------------------------
Lookup8::
        add     l
        ld      l,a
        ld      a,h
        adc     0
        ld      h,a
        ld      a,[hl]
        ret

;---------------------------------------------------------------------
; Routine:      Lookup16
; Arguments:    a  - index
;               hl - start lookup table
; Alters:       af,hl
; Returns:      hl - table[a*2]
;---------------------------------------------------------------------
Lookup16::
        push    de
        ld      e,a
        ld      d,0
        sla     e
        rl      d
        add     hl,de
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      LookupIndexOfData8
; Arguments:    a  - data
;               hl - start of lookup table
; Alters:       af,hl
; Returns:      a - where table[a] is original data a.
;               Data must exist!
;---------------------------------------------------------------------
LookupIndexOfData8::
        push    bc

        ld      c,0
.findLoop
        cp      [hl]
        jr      z,.done

        inc     c
        inc     hl
        jr      .findLoop

.done
        ld      a,c
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FindFirstBGLoc
; Arguments:    hl - bg class to find (e.g. classClearanceBG)
; Returns:      hl - first location of class
;               a  - 0 on failure
;               zflag - or a
; Alters:       af
;---------------------------------------------------------------------
FindFirstBGLoc::
        push    bc
        push    de

        push    hl
        pop     bc
        call    FindClassIndex
        ld      b,a

        ld      a,MAPBANK
        ld      [$ff70],a

        ;setup de with first out-of-bounds index
        ld      a,[mapTotalSize]
        ld      e,a
        ld      a,[mapTotalSize+1]
        ld      d,a

        ld      hl,map
.lookForFirst
        ld      a,[hl+]
        cp      b
        jr      z,.foundIt

        ;hl < de?
        ld      a,h
        cp      d
        jr      c,.lookForFirst

        ld      a,l
        cp      e
        jr      c,.lookForFirst

        ;not found
        xor     a
        jr      .done

.foundIt
        dec     hl
        ld      a,1
        or      a

.done
        pop     de
        pop     bc

        ret

;---------------------------------------------------------------------
; Routine:      LinkTransmitMemoryLocation
; Arguments:    a  - RAM bank
;               hl - memory location to transmit to the remote
;                    GameBoy
; Alters:       af
;---------------------------------------------------------------------
LinkTransmitMemoryLocation::
        push    bc
        ld      b,a

        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.done    ;not linked

.requestTransmit
        ld      a,LUPDATEMEMORY
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.requestTransmit

        ld      a,b
        ldio    [$ff70],a
        call    TransmitByte
        ld      a,l
        call    TransmitByte
        ld      a,h
        call    TransmitByte
        ld      a,[hl]
        call    TransmitByte

.done
        pop     bc
        ret


;---------------------------------------------------------------------
; Link Code
;---------------------------------------------------------------------
SECTION        "LinkCodeSection",ROMX
linkCode:


;---------------------------------------------------------------------
; Routine:      HandleInput
; Description:  Polls the buttons and stores the input in [curInput0].
;               Then performs some network code and sets up [curJoy0],
;               [curJoy1], [curInput0], and [curInput1].  curJoyX may
;               be set to zero elsewhere to prevent the heroes from
;               moving but curInput0 and curInput1 will always be the
;               original values.
;
;               $80 - 7:Start
;               $40 - 6:Select
;               $20 - 5:B
;               $10 - 4:A
;               $08 - 3:Down
;               $04 - 2:Up
;               $02 - 1:Left
;               $01 - 0:Right
;
;               A linked Master should read its input from [curJoy0].
;               A linked Slave should read its input from [curJoy1].
;               To make this easier [myJoy] is set up to be the
;               appropriate one.
;
;               If no link connection established, attempt a link
;               connection.
;
;               If no link:
;                 Convert curInput0->Joy1 (result will be same as
;                 encoding then decoding curInput).
;
;               If link connection established:
;                 Exchange Control Byte with linked machine.  If
;                 Command Code gotten in return, perform requested
;                 action and then repeat attempt to exchange control
;                 byte.
;
;                 If Master:  curInput0->Joy1, remoteInput->Joy2
;                 If Slave:   curInput0->Joy2, remoteInput->Joy1
;---------------------------------------------------------------------
HandleInput:
        ld      a,$20
        ldio    [$ff00],a     ;select P14
        ldio    a,[$ff00]
        ldio    a,[$ff00]     ;wait a few cycles
        cpl
        and     $0f
        ld      b,a           ;b has direction info
        ld      a,$10         ;select P15
        ld      [$ff00],a
        ldio    a,[$ff00]     ;wait mo
        ldio    a,[$ff00]     ;wait mo
        ldio    a,[$ff00]     ;wait mo
        ldio    a,[$ff00]     ;wait mo
        ldio    a,[$ff00]     ;wait mo
        ldio    a,[$ff00]     ;wait mo
        cpl
        and     $0f
        swap    a
        or      b             ;a has all buttons
        ld      [curInput0],a
        ld      a,$30         ;deselect P14 and P15
        ldio    [$ff00],a

        ;--if no link, attempt link connection ----------------------
        ld      a,[amLinkMaster]
        cp      $ff
        jr      z,.afterLinkAttempt    ;L1101 attempts link as slave
        cp      $fe                    ;attempt link as master?
        jr      nz,.afterLinkAttempt

.attemptLinkAsMaster
        ld      a,$55
        ldio    [$ff01],a     ;exchange data = $55
        ld      a,INTCLK      ;ready to xchg, use my clock
        ldio    [$ff02],a

.waitMasterLinkAttempt
        ldio    a,[$ff02]
        and     $80
        jr      nz,.waitMasterLinkAttempt

        ;see what we got
        ldio    a,[$ff01]
        cp      $aa
        jr      nz,.afterLinkAttempt

        ;found a Slave!  That means I'm the Master!
        ld      a,EXTCLK    ;switch to receive mode
        ldio    [$ff02],a
        ld      a,1
        ld      [amLinkMaster],a
        ld      [lastLinkAction],a

.afterLinkAttempt
        ld      a,[amLinkMaster]
        bit     7,a
        jr      z,.amLinked

        ;no link, convert curInput->curJoy0.
        ld      a,[curInput0]
        call    ConvertInput
        ld      [curInput0],a
        ld      [curJoy0],a
        ld      [myJoy],a
        xor     a
        ld      [curJoy1],a
        ld      [curInput1],a
        ret

.amLinked

IF 0
        ;----every second or so, get the remote machine's
        ;----random seed and make sure it matches ours.
        ;----Resynchronize the machines if not
        ld      a,[amLinkMaster]
        cp      1
        jr      nz,.exchangeBCB    ;only master can initiate

        ld      a,[updateTimer]    ;not time yet
        and     31
        cp      31
        jr      nz,.exchangeBCB

        ;don't do it if can't join map
        ld      a,[canJoinMap]
        or      a
        jr      z,.exchangeBCB

.getRandomSeed
        ld      a,LGETRANDOMSEED       ;send the request
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.getRandomSeed      ;must repeat

        ;get the actual seed
        call    ReceiveByte
        ld      b,a
        ld      a,[randomLoc]
        cp      b                           ;got same in return?
        jr      z,.exchangeBCB              ;continue if yes

        ;on same map?
        ld      a,[heroesPresent]
        cp      %11
        jr      nz,.exchangeBCB             ;not on same map

.resynchronize
        ;resynchronize machines
        ld      a,LRESYNCHRONIZE
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.resynchronize
        LONGCALLNOARGS HostResynchronize
ENDC

.exchangeBCB
        ;----exchange Button Control Bytes with remote machine--------
        ld      a,[curInput0]
        call    EncodeInput
        call    ExchangeByte
        call    HandleRemoteInput
        jr      nz,.exchangeBCB    ;must repeat

        ;--Decode Button Control Bytes--------------------------------
        push    af            ;save remoteInput
        ld      a,[amLinkMaster]
        or      a
        jr      z,.amLinkSlave

        ;I am the master.  curInput0->curJoy0, remoteInput->curJoy1
        pop     af            ;retrieve remoteInput
        call    DecodeInput
        ld      [curInput1],a
        ld      [curJoy1],a
        ld      a,[curInput0]
        call    ConvertInput
        ld      [curInput0],a
        ld      [curJoy0],a
        ld      [myJoy],a
        ret

.amLinkSlave
        ld      a,[curInput0]
        call    ConvertInput
        ld      [curInput1],a
        ld      [curJoy1],a
        ld      [myJoy],a

        pop     af            ;retrieve remoteInput
        call    DecodeInput
        ld      [curInput0],a
        ld      [curJoy0],a
        ret

;---------------------------------------------------------------------
; Routine:      ConvertInput
; Argument:     a - uncoded button control byte
; Returns:      a - converted BCB, same as calling Encode then
;                   Decode but quicker
; Description:  To simulate uncoded->encoded->decoded, forces buttons
;               7:4 to have A/B or Start/Select info but not both
;               (A/B has priority).
; Alters:       af
;---------------------------------------------------------------------
ConvertInput:
        push    bc

        ld      b,a                ;save original
        and     %00110000          ;has A/B info?
        ld      a,b                ;restore original
        jr      z,.done            ;if no AB info then conv. complete
        and     %00111111          ;has AB info; clear out start/sel

.done
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      EncodeInput
; Argument:     a - uncoded button control byte
;                   7:st 6:se 5:b 4:a 3:0=DULR
; Returns:      a - coded button control byte
;                   7=0
;                   6=0 - 5:4 = ba
;                    =1 - 5:4 = te  (start, select)
;                   3:0 = DULR
; Alters:       af
;---------------------------------------------------------------------
EncodeInput:
        push    bc
        push    hl

        ld      b,a         ;save original
        and     %00001111
        ld      c,a         ;save D-PAD

        ld      h,((encodeControlByteTable>>8) & $ff)
        ld      a,b
        swap    a
        and     %00001111
        add     (encodeControlByteTable & $ff)
        ld      l,a

        ld      a,[hl]      ;get encoded buttons
        or      c           ;combine with D-PAD

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      DecodeInput
; Argument:     a - coded Control Byte
; Returns:      a - uncoded button Control Byte
; Alters:       af
;---------------------------------------------------------------------
DecodeInput:
        push    bc
        push    hl

        ld      b,a         ;save original
        and     %00001111
        ld      c,a         ;save D-PAD

        ld      h,((decodeControlByteTable>>8) & $ff)
        ld      a,b
        swap    a
        and     %00000111
        add     (decodeControlByteTable & $ff)
        ld      l,a

        ld      a,[hl]      ;get decoded buttons
        or      c           ;combine with D-PAD

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      TransmitGameState
; Arguments:    none
; Returns:      none
; Alters:       af
; Description:  Transmits relevant game state data to Slave
;               Includes hero data so slave's classes will be set
;               appropriately
;---------------------------------------------------------------------
TransmitGameState:
        push    bc
        push    hl

        ld      hl,.linkBailAddress
        xor     a
        call    SetLinkBailOutAddress

        ld      hl,gameState
        ld      bc,5
        xor     a            ;RAM bank doesn't matter
        call    TransmitData

        ld      hl,levelState
        ld      bc,256
        ld      a,LEVELSTATEBANK
        call    TransmitData

        ld      hl,inventory
        ld      bc,16
        xor     a
        call    TransmitData

        ld      hl,flightCode
        ld      bc,256
        ld      a,FLIGHTCODEBANK
        call    TransmitData

        ld      hl,hero0_data
        ld      bc,HERODATASIZE * 2
        xor     a
        call    TransmitData

        ld      a,[appomattoxMapIndex]
        call    TransmitByte

        ;send the joinMap
        ld      a,[joinMap]
        call    TransmitByte
        ld      a,[joinMap+1]
        call    TransmitByte

.linkBailAddress
        ld      hl,0
        xor     a
        call    SetLinkBailOutAddress

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      HostSynchronize
; Arguments:    none
; Returns:      none
; Alters:       af
; Description:  Transmits relevant map data to Guest
;---------------------------------------------------------------------
HostResynchronize:
        push    bc
        push    hl
        jr      HostSynchronizeCommon

HostSynchronize:
        push    bc
        push    hl

        ld      hl,.nogo
        xor     a
        call    SetLinkBailOutAddress

        ld      a,1                ;make sure it's looking at 1x1
        ldio    [curObjWidthHeight],a
        call    ReceiveByte        ;guest's requested exit direction
        ld      hl,$0101           ;start looking at (1,1)
        call    FindExitLocation
        xor     a                  ;didn't find it if $0000
        cp      h
        jr      nz,.goAhead
        cp      l
        jr      nz,.goAhead

        ;nogo
        xor     a
        call    TransmitByte
.nogo
        ld      hl,0
        xor     a
        call    SetLinkBailOutAddress

        pop     hl
        pop     bc
        ret

.goAhead
        call    ConvertLocHLToXY
        ld      a,1
        call    TransmitByte

        ldio    a,[mapState]       ;level state
        call    TransmitByte
        ldio    a,[mapState+1]
        call    TransmitByte

        ;make sure backbuffer doesn't redraw during hero loading
        xor     a
        ldio    [backBufferReady],a

        ;activate heroes 0 and 1
        ld      a,[hero0_index]
        or      a
        jr      nz,.hero0_active

        ld      a,1
        ld      [hero0_index],a

.hero0_active
        ld      a,[hero1_index]
        or      a
        jr      nz,.hero1_active

        ld      a,1
        ld      [hero1_index],a
.hero1_active
        call    HostExchangeHeroData

        ;set hero 1 to joystick 1
        push    hl
        ld      a,[hero1_type]
        ld      hl,heroJoyIndex
        or      [hl]
        ld      [hl],a
        pop     hl

        inc     hl
        ld      b,h
        ld      c,l
        PREPLONGCALL .afterSetupHero
        LONGCALL PrepSetupHeroBC   ;bc is correct hero data
.afterSetupHero

HostSynchronizeCommon:
        xor     a
        ld      [backBufferReady],a

        ;wait on ready signal from guest
.waitReady
        call    ReceiveByte
        cp      LSYNCHREADY
        jr      nz,.waitReady

        ;send all my hero data     ;re-send all my hero data
        ld      hl,hero0_data
        ld      bc,HERODATASIZE*2
        xor     a
        call    TransmitData

        ld      a,[randomLoc]      ;current random value/seed
        call    TransmitByte

        ld      a,[heroesIdle]
        call    TransmitByte

        LONGCALLNOARGS RemoveSpriteObjectsFromMap

        ;----transmit map---------------------------------------------
        ld      hl,map
        ld      bc,4096
        ld      a,MAPBANK
        call    TransmitData

        ;fadeCurPalette
        ld      hl,fadeCurPalette
        ld      bc,128
        xor     a
        call    TransmitData

        ;gamePalette
        ld      hl,gamePalette
        ld      bc,128
        ld      a,FADEBANK
        call    TransmitData

        ;first 16 bytes of level check RAM
        ld      hl,levelCheckRAM
        ld      bc,16
        xor     a
        call    TransmitData

        ;spriteOAMdata
        ld      hl,spriteOAMBuffer
        ld      bc,160
        xor     a
        call    TransmitData

        ld      hl,headTable    ;headTable - linked list head
        ld      bc,256
        ld      a,OBJLISTBANK
        call    TransmitData

        ld      hl,objExists     ;objExists, FOF table
        ld      bc,512
        ld      a,OBJLISTBANK
        call    TransmitCompressedData

        ld      a,[numClasses]
        call    TransmitByte

        ;bc = numClasses times two + 2
        ld      a,[numClasses]
        ld      b,0
        ld      c,a
        sla     c
        rl      b
        inc     bc
        inc     bc

        ld      hl,classLookup   ;objExists, FOF table
        ;ld      bc,512  numClasses * 2
        ld      a,OBJLISTBANK
        call    TransmitData

        ld      hl,fgTileMap
        ld      a,[numClasses]
        ld      b,0
        ld      c,a
        ld      a,OBJLISTBANK
        call    TransmitData

        ld      hl,objClassLookup   ;class indices for each obj
        ld      bc,256
        ld      a,OBJLISTBANK
        call    TransmitData

        ld      hl,associatedIndex
        ld      bc,256
        ld      a,OBJLISTBANK
        call    TransmitData

        ld      hl,spritesUsed
        ld      bc,40
        ld      a,OBJLISTBANK
        call    TransmitCompressedData

        ;---------------transmit used objects-------------------------
        ld      a,OBJLISTBANK
        ld      [$ff70],a
        ld      de,objExists+1
.transmitUsedObject
        ld      a,[de]            ;is this object used?
        or      a
        jr      z,.afterTransmitUsedObject  ;not used

        PREPLONGCALL .afterCvtToPtr
        ld      a,e               ;get object index
        LONGCALL IndexToPointerHL ;cvt to ptr
.afterCvtToPtr
        ld      bc,16
        ld      a,OBJBANK
        call    TransmitData
        ld      a,OBJLISTBANK
        ld      [$ff70],a

.afterTransmitUsedObject
        inc     de
        ld      a,e
        or      a
        jr      nz,.transmitUsedObject

        ld      a,[numFreeSprites]
        call    TransmitByte

        ld      a,[firstFreeObj]
        call    TransmitByte

        ld      a,[randomLoc]
        call    TransmitByte

        ld      a,[guardAlarm]
        call    TransmitByte

        ;ld      a,[dialogBank]
        ;call    TransmitByte

        ld      a,[respawnMap]
        call    TransmitByte
        ld      a,[respawnMap+1]
        call    TransmitByte

        ldio    a,[mapState]       ;level state
        call    TransmitByte
        ldio    a,[mapState+1]
        call    TransmitByte

        ld      hl,levelVars
        ld      bc,64
        xor     a            ;RAM bank doesn't matter
        call    TransmitData

        ld      hl,musicBank
        ld      bc,64
        xor     a            ;RAM bank doesn't matter
        call    TransmitData

        ld      hl,musicStack
        ld      bc,128
        ld      a,MUSICBANK
        call    TransmitData

        ldio    a,[musicEnabled]
        call    TransmitByte

        LONGCALLNOARGS LinkRemakeLists

.done
        pop     hl
        pop     bc
        ret

HostExchangeHeroData:
        ;send out my hero data
        ld      a,[amLinkMaster]
        or      a
        jr      z,.slave_sendHero1_recvHero0

.master_sendHero0_recvHero1
        ld      hl,hero1_data
        push    hl
        ld      hl,hero0_data
        jr      .setHeroSequence

.slave_sendHero1_recvHero0
        ld      hl,hero0_data
        push    hl
        ld      hl,hero1_data

.setHeroSequence
        ;send my hero data
        ld      bc,HERODATASIZE
        xor     a
        call    TransmitData

        ;get remote hero data
        pop     hl
        xor     a
        call    ReceiveData

        ret


;---------------------------------------------------------------------
; Routine:      LinkTest
; Arguments:    none
; Returns:      none
; Alters:       af
; Description:  Fills 4k of memory with repeating pattern $00-$ff,
;               transmits that data to Slave, receives that data
;               back, compares it to the original pattern, and
;               finally prints out a Debug message of 1 for equal
;               or 0 for not equal.
;---------------------------------------------------------------------
LinkTest:
        push    bc
        push    de
        push    hl

        di
        ;fill $d000-$cfff with repeating pattern $00-$ff
        ld      a,1
        ld      [$ff70],a

        ld      hl,$d000
        xor     a
.fill
        ld      [hl+],a
        inc     a
        jr      nz,.fill
        ld      a,h
        cp      $e0
        ld      a,0       ;avoid setting z flag here
        jr      nz,.fill

        ld      a,4
.transfer32k
        push    af
        ld      a,1
        ld      bc,$1000
        ld      hl,$d000
        call    TransmitData

        ld      a,1
        call    ReceiveData
        pop     af
        dec     a
        jr      nz,.transfer32k

        ;compare received data to original pattern
        ld      b,0          ;comparing to $00
        ld      hl,$d000
.compare
        ld      a,[hl+]
        cp      b
        jr      nz,.notEqual
        inc     b
        ld      a,h
        cp      $e0
        jr      nz,.compare

.equal
        xor     a
        ldio    [$ff0f],a
        ei
        ld      a,1
        call    DebugVal
        jr      .infi

.notEqual
        xor     a
        ldio    [$ff0f],a
        ei
        xor     a
        call    DebugVal

        dec     hl
        ld      a,h
        call    DebugVal
        ld      a,l
        call    DebugVal
di
.infi   jr      .infi

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GeneratePauseMessage
; Arguments:    none
; Returns:      none
; Alters:       all
; Description:  Creates appropriate Pause Message
;---------------------------------------------------------------------
GeneratePauseMessage:
        ld      a,[dialogBank]
        push    af

        ;wait until the backbuffer is blitted
.waitBackBuffer
        ldio    a,[backBufferReady]
        or      a
        jr      z,.canMessWithBackBuffer

        call    VWait
        jr      .waitBackBuffer

.canMessWithBackBuffer
        ;generate gtx at backbuffer+$800

        ;de = level name index
        ld      a,[curLevelStateIndex]
        ld      d,0
        ld      e,a   ;level index * 2
        sla     e
        rl      d
        ld      hl,levelNames
        add     hl,de
        ld      a,[hl+]
        ld      e,a
        ld      a,[hl+]
        ld      d,a
        ld      hl,backBuffer
        ld      a,BANK(levelNames)
        ld      [dialogBank],a
        call    ClearGTXLine
        call    WriteGTXLine

        ;write char name
        push    hl
        push    hl
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        ld      c,$ff
.findCharIndex
        inc     c
        rrca
        bit     7,a
        jr      z,.findCharIndex
        ld      a,c
        ld      hl,heroNames
        call    .lookupIndexAToHLToDE
        pop     hl
        call    ClearGTXLine
        call    WriteGTXLine
        pop     hl

        ;write map coordinates
        add     sp,-24  ;create temporary buffer on stack
        push    hl
        ld      hl,sp+2
        ld      d,h
        ld      e,l
        ld      [hl],16  ;spaces to center
        inc     hl
        ld      [hl],4  ;number of chars
        inc     hl
        ld      a,[curLevelStateIndex]
        push    af
        and     $f
        add     210       ;'A' character
        ld      [hl+],a
        pop     af
        ld      [hl],$f9  ;hyphen
        inc     hl
        swap    a
        and     $f
        cp      10
        jr      c,.oneDigit
        ld      [hl],201  ;'1'
        inc     hl
        sub     10
.oneDigit
        add     200       ;get digit '0'-'9'
        ld      [hl+],a
        ld      [hl],0    ;blank space may or may not be used
        pop     hl
        push    de
        call    WriteGTXLine   ;de is line to write
        pop     de

        ;write map coordinates if landing zone------------------------
        ld      c,2   ;# of items in inventory screen

        push    bc  ;see if we're at an LZ
        ld      a,[curLevelStateIndex]
        call    .getFlightCodeBCFromMapA
        pop     bc
        jr      z,.afterWriteCoords

        push    hl
        ld      h,d
        ld      l,e
        ld      [hl],8  ;spaces to center
        inc     hl
        ld      [hl],4  ;number of chars
        inc     hl
        push    bc
        ld      a,[curLevelStateIndex]
        call    .getFlightCodeBCFromMapA
        call    .writeCoordsBC
        pop     bc
        pop     hl
        call    ClearGTXLine
        call    WriteGTXLine   ;de is line to write
        inc     c
.afterWriteCoords
        add     sp,24     ;free up temporary stack space

        ;write inventory
        call    GetFirstInventoryIndex
        cp      $ff
        jr      z,.afterWriteInventory

        ;blank line
        push    af
        ld      de,blankLine
        call    ClearGTXLine
        call    WriteGTXLine
        inc     c
        pop     af

        ;remaining inventory
.nextInventoryItem
        ld      b,a     ;obj index in b
        push    af
        push    hl
        ld      hl,itemNames
        call    .lookupIndexAToHLToDE
        pop     hl

        inc     de
        ld      a,[de]
        dec     de
        or      a
        jr      z,.skipItem  ;an upgrade or something

        call    ClearGTXLine
        push    hl
        call    WriteGTXLine

        ;write object color
        ld      a,b
        add     (itemColors&$ff)
        ld      e,a
        ld      a,((itemColors>>8)&$ff)
        adc     0
        ld      d,a
        ld      a,[de]
        or      8
        pop     de
        push    hl
        ld      hl,$300
        add     hl,de
        ld      [hl],a
        pop     hl
        inc     c
.skipItem
        pop     af
        call    GetNextInventoryIndex
        cp      $ff
        jr      nz,.nextInventoryItem

.afterWriteInventory
        inc     c
        ld      de,restart_message
        call    ClearGTXLine
        call    WriteGTXLine

        ld      a,c
        ld      [backBuffer+63],a   ;#lines

        pop     af
        ld      [dialogBank],a
        ret

.getFlightCodeBCFromMapA
        ;returns flight code in bc, zflag
        push    de
        push    hl
        ld      de,3

        ld      b,a
        ld      a,FLIGHTCODEBANK
        ldio    [$ff70],a
        ld      hl,flightCode
        ld      c,[hl]    ;number of flight codes
        add     hl,de     ;start at byte 2/3 (map index)
.findFlightCode
        ld      a,[hl]
        cp      b
        jr      z,.getFlightCodeMatch
        add     hl,de
        dec     c
        jr      nz,.findFlightCode

        xor     a      ;not found
        pop     hl
        pop     de
        ret

.getFlightCodeMatch
        dec     hl
        ld      b,[hl]
        dec     hl
        ld      c,[hl]
        pop     hl
        pop     de
        ld      a,1
        or      a
        ret

.lookupIndexAToHLToDE
        rlca
        add     l
        ld      l,a
        ld      a,h
        adc     0
        ld      h,a
        ld      a,[hl+]
        ld      d,[hl]
        ld      e,a
        ret

.writeCoordsBC
        ld      a,b
        swap    a
        call    .writeCoordA
        ld      a,b
        call    .writeCoordA
        ld      a,c
        swap    a
        call    .writeCoordA
        ld      a,c
        call    .writeCoordA
        ret

.writeCoordA
        and     $f
        add     $c0    ;first of 8 coordinate symbols
        ld      [hl+],a
        ret

restart_message:
  GTXSTRINGC "SELECTgoRESTART"
blankLine:
  DB 0,0

;---------------------------------------------------------------------
; Routine:      CopyMessageDEToHL
; Arguments:    de - pointer to message
;               hl - pointer to dest
; Returns:      none
; Alters:       all
; Description:  First byte at [de] is number of bytes to copy from
;               [de] to [hl].  Must be >= 1!
;---------------------------------------------------------------------
CopyMessageDEToHL:
        ld      a,[de]
        inc     de
        ld      c,a
.loop   ld      a,[de]
        inc     de
        ld      [hl+],a
        dec     c
        jr      nz,.loop
        ret

levelNames:
  DW L0000_Name,L0100_Name,L0200_Name,L0300_Name
  DW L0400_Name,L0500_Name,L0600_Name,L0700_Name
  DW L0800_Name,L0900_Name,L1000_Name,L1100_Name
  DW L1200_Name,L1300_Name,L1400_Name,L1500_Name

  DW L0001_Name,L0101_Name,L0201_Name,L0301_Name
  DW L0401_Name,L0501_Name,L0601_Name,L0701_Name
  DW L0801_Name,L0901_Name,L1001_Name,L1101_Name
  DW L1201_Name,L1301_Name,L1401_Name,L1501_Name

  DW L0002_Name,L0102_Name,L0202_Name,L0302_Name
  DW L0402_Name,L0502_Name,L0602_Name,L0702_Name
  DW L0802_Name,L0902_Name,L1002_Name,L1102_Name
  DW L1202_Name,L1302_Name,L1402_Name,L1502_Name

  DW L0003_Name,L0103_Name,L0203_Name,L0303_Name
  DW L0403_Name,L0503_Name,L0603_Name,L0703_Name
  DW L0803_Name,L0903_Name,L1003_Name,L1103_Name
  DW L1203_Name,L1303_Name,L1403_Name,L1503_Name

  DW L0004_Name,L0104_Name,L0204_Name,L0304_Name
  DW L0404_Name,L0504_Name,L0604_Name,L0704_Name
  DW L0804_Name,L0904_Name,L1004_Name,L1104_Name
  DW L1204_Name,L1304_Name,L1404_Name,L1504_Name

  DW L0005_Name,L0105_Name,L0205_Name,L0305_Name
  DW L0405_Name,L0505_Name,L0605_Name,L0705_Name
  DW L0805_Name,L0905_Name,L1005_Name,L1105_Name
  DW L1205_Name,L1305_Name,L1405_Name,L1505_Name

  DW L0006_Name,L0106_Name,L0206_Name,L0306_Name
  DW L0406_Name,L0506_Name,L0606_Name,L0706_Name
  DW L0806_Name,L0906_Name,L1006_Name,L1106_Name
  DW L1206_Name,L1306_Name,L1406_Name,L1506_Name

  DW L0007_Name,L0107_Name,L0207_Name,L0307_Name
  DW L0407_Name,L0507_Name,L0607_Name,L0707_Name
  DW L0807_Name,L0907_Name,L1007_Name,L1107_Name
  DW L1207_Name,L1307_Name,L1407_Name,L1507_Name

  DW L0008_Name,L0108_Name,L0208_Name,L0308_Name
  DW L0408_Name,L0508_Name,L0608_Name,L0708_Name
  DW L0808_Name,L0908_Name,L1008_Name,L1108_Name
  DW L1208_Name,L1308_Name,L1408_Name,L1508_Name

  DW L0009_Name,L0109_Name,L0209_Name,L0309_Name
  DW L0409_Name,L0509_Name,L0609_Name,L0709_Name
  DW L0809_Name,L0909_Name,L1009_Name,L1109_Name
  DW L1209_Name,L1309_Name,L1409_Name,L1509_Name

  DW L0010_Name,L0110_Name,L0210_Name,L0310_Name
  DW L0410_Name,L0510_Name,L0610_Name,L0710_Name
  DW L0810_Name,L0910_Name,L1010_Name,L1110_Name
  DW L1210_Name,L1310_Name,L1410_Name,L1510_Name

  DW L0011_Name,L0111_Name,L0211_Name,L0311_Name
  DW L0411_Name,L0511_Name,L0611_Name,L0711_Name
  DW L0811_Name,L0911_Name,L1011_Name,L1111_Name
  DW L1211_Name,L1311_Name,L1411_Name,L1511_Name

  DW L0012_Name,L0112_Name,L0212_Name,L0312_Name
  DW L0412_Name,L0512_Name,L0612_Name,L0712_Name
  DW L0812_Name,L0912_Name,L1012_Name,L1112_Name
  DW L1212_Name,L1312_Name,L1412_Name,L1512_Name

  DW L0013_Name,L0113_Name,L0213_Name,L0313_Name
  DW L0413_Name,L0513_Name,L0613_Name,L0713_Name
  DW L0813_Name,L0913_Name,L1013_Name,L1113_Name
  DW L1213_Name,L1313_Name,L1413_Name,L1513_Name

  DW L0014_Name,L0114_Name,L0214_Name,L0314_Name
  DW L0414_Name,L0514_Name,L0614_Name,L0714_Name
  DW L0814_Name,L0914_Name,L1014_Name,L1114_Name
  DW L1214_Name,L1314_Name,L1414_Name,L1514_Name

  DW L0015_Name,L0115_Name,L0215_Name,L0315_Name
  DW L0415_Name,L0515_Name,L0615_Name,L0715_Name
  DW L0815_Name,L0915_Name,L1015_Name,L1115_Name
  DW L1215_Name,L1315_Name,L1415_Name,L1515_Name

L0000_Name:
  GTXSTRINGC "THEoHIVE"
L0001_Name:
  GTXSTRINGC "MADoBEEoPASS"
L0002_Name:
  GTXSTRINGC "BEEoCOUNTRY"
L0003_Name:
  GTXSTRINGC "BIGoEDaSoSHEEPoFARM"
L0004_Name:
  GTXSTRINGC "HILLoBROTHERSoRANCH"
L0005_Name:
  GTXSTRINGC "TRAKKTORoCOUNTRY"
L0006_Name:
  GTXSTRINGC "SUNSEToVILLAGE"
L0007_Name:
  GTXSTRINGC "CRAZYoCROWoGULCH"
L0008_Name:
  GTXSTRINGC "SNEAKYoTREEoVALLEY"
L0009_Name:
  GTXSTRINGC "PROVOLONE"
L0010_Name:
  GTXSTRINGC "MUENSTER"
L0011_Name:
  GTXSTRINGC "HOUSEoOFoSEASONS"
L0012_Name:
  GTXSTRINGC "COMMANDoCORE"
L0013_Name:
  GTXSTRINGC "ITCHYoTRIGGER"
L0014_Name:
  GTXSTRINGC "THEoFAULT"
L0015_Name:
  GTXSTRINGC "LOOSEoJARGON"

L0100_Name:
L0101_Name:
L0102_Name:
  GTXSTRINGC "RIVER"
L0103_Name:
  GTXSTRINGC "LILoEDaSoSHEEPoFARM"
L0104_Name:
  GTXSTRINGC "SPRING"
L0105_Name:
  GTXSTRINGC "DARKERoFOREST"
L0106_Name:
  GTXSTRINGC "DARKISHoFOREST"
L0107_Name:
  GTXSTRINGC "KIDNAPoCORNERoeLZf"
L0108_Name:
  GTXSTRINGC "SNAKEoPIToeLZf"
L0109_Name:
  GTXSTRINGC "CHEDDAR"
L0110_Name:
  GTXSTRINGC "HAVARTI"
L0111_Name:
  GTXSTRINGC "GOBLINoPIT"
L0112_Name:
  GTXSTRINGC "HIVEoENTRANCE"
L0113_Name:
  GTXSTRINGC "FRIENDLYoFIRE"
L0114_Name:
  GTXSTRINGC "PATHoOFoSHADOWS"
L0115_Name:
  GTXSTRINGC "DOUBLEoENTENDRE"

L0200_Name:
  GTXSTRINGC "FORBIDDENoVILLAGE"
L0201_Name:
  GTXSTRINGC "STRANGEoMIST"
L0202_Name:
L0203_Name:
L0204_Name:
  GTXSTRINGC "RIVER"
L0205_Name:
  GTXSTRINGC "JACOBaSoBRIDGE"
L0206_Name:
L0207_Name:
L0208_Name:
L0209_Name:
L0210_Name:
  GTXSTRINGC "RIVER"
L0211_Name:
  GTXSTRINGC "THEoBLOWERS"
L0212_Name:
  GTXSTRINGC "THEoBELFRY"
L0213_Name:
  GTXSTRINGC "CLOSEoQUARTERS"
L0214_Name:
  GTXSTRINGC "JAILoBREAK"
L0215_Name:
  GTXSTRINGC "BRAINIAC"

L0300_Name:
  GTXSTRINGC "WEIRDoMIST"
L0301_Name:
  GTXSTRINGC "ODDoMIST"
L0302_Name:
  GTXSTRINGC "BIZARREoMISToeLZf"
L0303_Name:
  GTXSTRINGC "MISToGATE"
L0304_Name:
  GTXSTRINGC "MUNGAoFUNGA"
L0305_Name:
  GTXSTRINGC "TRILINGoBURROW"
L0306_Name:
  GTXSTRINGC "TWOoGUNS"
L0307_Name:
  GTXSTRINGC "OUTPOSTgoDESOLATION"
L0308_Name:
  GTXSTRINGC "DRYoGULCH"
L0309_Name:
  GTXSTRINGC "SHOOToOUT"
L0310_Name:
  GTXSTRINGC "REDoBENDoeLZf"
L0311_Name:
  GTXSTRINGC "HIGHoGROUND"
L0312_Name:
  GTXSTRINGC "THEoSTING"
L0313_Name:
  GTXSTRINGC "INSOMNIAC"
L0314_Name:
  GTXSTRINGC "RUNAWAY"
L0315_Name:
  GTXSTRINGC "INSOMNIAC"

L0400_Name:
  GTXSTRINGC "OUTPOSTgoDARKFROST"
L0401_Name:
  GTXSTRINGC "PITCHoBLACK"
L0402_Name:
  GTXSTRINGC "WYRMoDUSK"
L0403_Name:
  GTXSTRINGC "GROMMOLD"
L0404_Name:
  GTXSTRINGC "MILDEWoSTIRRING"
L0405_Name:
  GTXSTRINGC "WESTGATE"
L0406_Name:
  GTXSTRINGC "PIGSoINoAoBLANKET"
L0407_Name:
  GTXSTRINGC "BIOS"
L0408_Name:
  GTXSTRINGC "HOToVALLEYoOFoDEATH"
L0409_Name:
  GTXSTRINGC "TUMBLEWEED"
L0410_Name:
  GTXSTRINGC "OUTPOSTgoDRAGON"
L0411_Name:
  GTXSTRINGC "THEoCELL"
L0412_Name:
  GTXSTRINGC "STONEHEADoHOUSE"
L0413_Name:
L0414_Name:
L0415_Name:
  GTXSTRINGC "FGB"

L0500_Name:
  GTXSTRINGC "PENGUINoSMACKDOWN"
L0501_Name:
  GTXSTRINGC "WINTER"
L0502_Name:
  GTXSTRINGC "CHILLVILLE"
L0503_Name:
  GTXSTRINGC "OLDoHOSS"
L0504_Name:
  GTXSTRINGC "NORTHGATE"
L0505_Name:
  GTXSTRINGC "FLOWERoTOWER"
L0506_Name:
  GTXSTRINGC "SOUTHGATE"
L0507_Name:
  GTXSTRINGC "WETLANDS"
L0508_Name:
  GTXSTRINGC "LAaSHANDAaS"
L0509_Name:
  GTXSTRINGC "OUTBACK"
L0510_Name:
  GTXSTRINGC "SUMMER"
L0511_Name:
L0512_Name:
  GTXSTRINGC "LAaSHANDA"
L0513_Name:
L0514_Name:
L0515_Name:
  GTXSTRINGC "FGB"

L0600_Name:
  GTXSTRINGC "ICEoPLAINSoeLZf"
L0601_Name:
  GTXSTRINGC "ICEWOLFoRUN"
L0602_Name:
  GTXSTRINGC "KINGoCHUBBAaSoHALL"
L0603_Name:
  GTXSTRINGC "IGNORANToHILLoPEOPLE"
L0604_Name:
  GTXSTRINGC "TOWERoOFoPAIN"
L0605_Name:
  GTXSTRINGC "EASTGATE"
L0606_Name:
  GTXSTRINGC "ROCKoBOTTOMoBENDeLZf"
L0607_Name:
  GTXSTRINGC "SWAMPYaSoLAIR"
L0608_Name:
  GTXSTRINGC "GOONoHILL"
L0609_Name:
  GTXSTRINGC "LASToRESORT"
L0610_Name:
  GTXSTRINGC "BITTERoROCKoPARK"
L0611_Name:
L0612_Name:
  GTXSTRINGC "TELEPORToCHAMBER"
L0613_Name:
L0614_Name:
L0615_Name:
  GTXSTRINGC "FGB"

L0700_Name:
  GTXSTRINGC "THEoPLANEoOFoNOTHING"
L0701_Name:
  GTXSTRINGC "KIWIoKEEP"
L0702_Name:
  GTXSTRINGC "BAToCAVE"
L0703_Name:
  GTXSTRINGC "UNDERLAKEoCAVERNS"
L0704_Name:
  GTXSTRINGC "STONEHEADoCANYONeLZf"
L0705_Name:
  GTXSTRINGC "MONKEYoHOLLER"
L0706_Name:
  GTXSTRINGC "SWAMPLACE"
L0707_Name:
  GTXSTRINGC "THEoBARROWS"
L0708_Name:
  GTXSTRINGC "BLACKoSWAMPoPASSAGE"
L0709_Name:
  GTXSTRINGC "HERDoLANDS"
L0710_Name:
  GTXSTRINGC "DONaToSHOOToTHEoCROC"
L0711_Name:
  GTXSTRINGC "SPACEoSTNoAPOCALYPSE"
L0712_Name:
  GTXSTRINGC "HICKoLANDINGoeLZf"
L0713_Name:
L0714_Name:
L0715_Name:
  GTXSTRINGC "FGB"

L0800_Name:
  GTXSTRINGC "JACOBaSoOTHERoBRIDGE"
L0801_Name:
  GTXSTRINGC "KIWIoROAD"
L0802_Name:
  GTXSTRINGC "WINDYoPASS"
L0803_Name:
  GTXSTRINGC "DJINNoLAKE"
L0804_Name:
  GTXSTRINGC "ELDERoROCKoCANYON"
L0805_Name:
  GTXSTRINGC "MONKEYoSURPRISE"
L0806_Name:
  GTXSTRINGC "SCAREDIEoRUN"
L0807_Name:
  GTXSTRINGC "SPIDERoMOORE"
L0808_Name:
  GTXSTRINGC "CROUTONoWARoCAMP"
L0809_Name:
  GTXSTRINGC "GRAPESHOT"
L0810_Name:
  GTXSTRINGC "CROUTONoGRAVESoeLZf"
L0811_Name:
  GTXSTRINGC "GOBLINoMODULE"
L0812_Name:
  GTXSTRINGC "WARPoZONE"
L0813_Name:
L0814_Name:
L0815_Name:
  GTXSTRINGC "FGB"

L0900_Name:
  GTXSTRINGC "OUTPOSTgoDELTA"
L0901_Name:
  GTXSTRINGC "CROUTONoSLAVEoCAMP"
L0902_Name:
  GTXSTRINGC "WIZARDaSoPASSoeLZf"
L0903_Name:
  GTXSTRINGC "CORNVILLE"
L0904_Name:
  GTXSTRINGC "SPIDERWEEDoCANYON"
L0905_Name:
  GTXSTRINGC "MONKEYoLANDINGoeLZf"
L0906_Name:
  GTXSTRINGC "MOOREoGATE"
L0907_Name:
  GTXSTRINGC "ARROWHEADoCITY"
L0908_Name:
  GTXSTRINGC "CANNONBALL"
L0909_Name:
  GTXSTRINGC "CROSSROADS"
L0910_Name:
  GTXSTRINGC "WARZONE"
L0911_Name:
  GTXSTRINGC "ARTILLERYoMODULE"
L0912_Name:
  GTXSTRINGC "MONKEYoHOMEWORLD"
L0913_Name:
L0914_Name:
L0915_Name:
  GTXSTRINGC "FGB"

L1000_Name:
  GTXSTRINGC "GYROaSoBASEoCAMPeLZf"
L1001_Name:
  GTXSTRINGC "CACTUSoPETE"
L1002_Name:
  GTXSTRINGC "OUTPOSTgoDINGLE"
L1003_Name:
  GTXSTRINGC "THEoBEACHoeLZf"
L1004_Name:
  GTXSTRINGC "PUMPKINoPATCH"
L1005_Name:
  GTXSTRINGC "AUTUMN"
L1006_Name:
  GTXSTRINGC "OUTPOSTgoDESPAIR"
L1007_Name:
  GTXSTRINGC "BUBoANDoJEB"
L1008_Name:
  GTXSTRINGC "GRENADIERoGRAVEYARD"
L1009_Name:
  GTXSTRINGC "BLACKoMAGIC"
L1010_Name:
  GTXSTRINGC "GRENADIERoCASTLE"
L1011_Name:
  GTXSTRINGC "DOCKINGoBAY"
L1012_Name:
  GTXSTRINGC "MONKEYoLIBRARY"
L1013_Name:
L1014_Name:
L1015_Name:
  GTXSTRINGC "FGB"

L1100_Name:
L1101_Name:
L1102_Name:
L1103_Name:
L1104_Name:
L1105_Name:
L1106_Name:
L1107_Name:
L1108_Name:
L1109_Name:
L1110_Name:
  GTXSTRINGC "FGB"
L1111_Name:
  GTXSTRINGC "HULKoMODULE"
L1112_Name:
  GTXSTRINGC "DUKEaSoDISCO"
L1113_Name:
L1114_Name:
L1115_Name:

L1200_Name:
L1201_Name:
L1202_Name:
L1203_Name:
L1204_Name:
L1205_Name:
L1206_Name:
L1207_Name:
L1208_Name:
L1209_Name:
L1210_Name:
L1211_Name:
  GTXSTRINGC "FGB"
L1212_Name:
  GTXSTRINGC "THEoBESToLAIDoPLANS`"
L1213_Name:
L1214_Name:
L1215_Name:

L1300_Name:
  GTXSTRINGC "BCSoAPPOMATTOX"
L1301_Name:
  GTXSTRINGC "FGB"
L1302_Name:
L1303_Name:
L1304_Name:
L1305_Name:
L1306_Name:
L1307_Name:
L1308_Name:
L1309_Name:
L1310_Name:
L1311_Name:
  GTXSTRINGC "FGB"
L1312_Name:
  GTXSTRINGC "GOBLINoCOUNTRY"
L1313_Name:
L1314_Name:
L1315_Name:

L1400_Name:
L1401_Name:
L1402_Name:
L1403_Name:
L1404_Name:
L1405_Name:
L1406_Name:
L1407_Name:
L1408_Name:
L1409_Name:
L1410_Name:
L1411_Name:
  GTXSTRINGC "FGB"
L1412_Name:
  GTXSTRINGC "HIGHoNOON"
L1413_Name:
L1414_Name:
L1415_Name:

L1500_Name:
L1501_Name:
L1502_Name:
L1503_Name:
L1504_Name:
  ;THE KIDNAPPING!
  DB ((20-STRLEN("THEoKIDNAPPING "))/2),STRLEN("THEoKIDNAPPING ")
COUNTER = 1
REPT STRLEN("THEoKIDNAPPING")
  DB ((STRSUB("THEoKIDNAPPING",COUNTER,1)+145) & $ff)
COUNTER = COUNTER+1
ENDR
  DB 237    ;!
L1505_Name:
  GTXSTRINGC "FGB"
L1506_Name:
L1507_Name:
L1508_Name:
L1509_Name:
L1510_Name:
L1511_Name:
  GTXSTRINGC "FGB"
L1512_Name:
  GTXSTRINGC "GENERATORoCORE"
L1513_Name:
L1514_Name:
L1515_Name:
  GTXSTRINGC "FGB"

heroNames:
  DW ba_name,bs_name,haiku_name,flour_name,flower_name,grenade_name

ba_name:
  GTXSTRING "BA"
bs_name:
  GTXSTRING "BS"
haiku_name:
  GTXSTRING "HAIKU"
flour_name:
  GTXSTRING "CAPTAINoFLOUR"
flower_name:
  GTXSTRING "LADYoFLOWER"
grenade_name:
  GTXSTRING "KINGoGRENADE"

itemNames:
  DW item000_Name,item001_Name,item002_Name,item003_Name,item004_Name
  DW item005_Name,item006_Name,item007_Name,item008_Name,item009_Name
  DW item010_Name,item011_Name,item012_Name,item013_Name,item014_Name
  DW item015_Name,item016_Name,item017_Name,item018_Name,item019_Name
  DW item020_Name,item021_Name,item022_Name

itemColors:
  DB 1,1,0,0,0,0,0,1,3,1   ; 0- 9
  DB 5,0,0,5,0,0,1,6,5,3   ;10-19
  DB 2,4,5,0,0,0,0,0,0,0   ;20-29
;0=Grey, 1=Red, 2=Blue, 3=Green, 4=Purple, 5=Yellow, 6=Brown/Orange, 7=Fuscia

item000_Name:
  ITEMSTRING 246,"SNAKEoBITEoKIT"
item001_Name:
  ITEMSTRING 254,"SPOREoMASK"
item002_Name:
  ;ITEMSTRING 250,"CODE0400"
  DB 0,0
item003_Name:
  ;ITEMSTRING 250,"CODE0900"
  DB 0,0
item004_Name:
  ;ITEMSTRING 250,"CODE1002"
  DB 0,0
item005_Name:
  ;ITEMSTRING 250,"CODE1006"
  DB 0,0
item006_Name:
  ;ITEMSTRING 250,"CODE0410"
  DB 0,0
item007_Name:
  ITEMSTRING 249,"BAToJUICE"
item008_Name:
  ITEMSTRING 248,"SPACEoMONEY"
item009_Name:
  ITEMSTRING 247,"SPACEoSODA"
item010_Name:
  ITEMSTRING 247,"HONEY"
item011_Name:
  ITEMSTRING 254,"WRANGLINGoIRON"
item012_Name:
  DB 0,0    ;BS Shoot Fast
item013_Name:
  ITEMSTRING 253,"BUGoSPRAY"
item014_Name:
  DB 0,0    ;BA High Impact Bullets
item015_Name:
  ;ITEMSTRING 250,"CODE0307"
  DB 0,0
item016_Name:
  ITEMSTRING 250,"ALPHAoCLEARANCE"
item017_Name:
  ITEMSTRING 250,"BETAoCLEARANCE"
item018_Name:
  ITEMSTRING 250,"GAMMAoCLEARANCE"
item019_Name:
  ITEMSTRING 250,"DELTAoCLEARANCE"
item020_Name:
  ITEMSTRING 250,"EPSILONoCLEARANCE"
item021_Name:
  ITEMSTRING 250,"ZETAoCLEARANCE"
item022_Name:
  ITEMSTRING 251,"APPOMATTOXoKEY"


SECTION        "MiscSection",ROMX
;---------------------------------------------------------------------
; Routine:      NewAppxLocation
; Arguments:    None.
; Returns:      none
; Alters:       af
; Description:
;---------------------------------------------------------------------
NewAppxLocation:
        push    bc
        push    de
        push    hl

        ld      a,[curLevelStateIndex]
        ld      b,a
        ld      a,[appomattoxMapIndex]
        cp      b
        jr      nz,.checkAppear

        ;remove appomattox from current map
        call    ReceiveByte      ;new map location
        ld      [appomattoxMapIndex],a
        ld      a,190
        ldio    [jiggleDuration],a

        call    FindFirstLight       ;remove appx
        ld      c,a  ;invisible wall index
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        ld      a,b    ;light index
        call    .drawLightRowTop
        call    .drawLightRowMiddle
        call    .drawLightRowMiddle
        call    .drawLightRowMiddle
        call    .drawLightRowMiddle
        call    .drawLightRowBottom

        ld      hl,EngineSound
        call    PlaySound

        ;link up exit to $4040 (+0 +0)
        ld      hl,mapExitLinks+EXIT_U*2
        ld      a,$40
        ld      [hl+],a
        ld      [hl],a

        jr      .done

.checkAppear
        call    ReceiveByte             ;new map location
        ld      [appomattoxMapIndex],a
        cp      b                       ;appearing on my map
        jr      nz,.checkInAppx

        ;place appomattox on current map
        ld      a,190
        ldio    [jiggleDuration],a

        call    AddAppomattox
        ld      hl,EngineSound
        call    PlaySound

        jr      .done

.checkInAppx
        ld      a,b
        cp      $0d
        jr      nz,.checkAtAppxControls

        ;I'm inside the Appomattox!
        ld      a,190
        ldio    [jiggleDuration],a

        ld      hl,EngineSound
        call    PlaySound

        ld      a,[appomattoxMapIndex]
        or      a
        jr      nz,.landing

.takingOff
        ;link down exit to $4040 (+0 +0)
        ld      hl,mapExitLinks+EXIT_D*2
        ld      a,$40
        ld      [hl+],a
        ld      [hl],a
        jr      .done

.landing
        ;convert map index to 16-bit BCD index
        ld      b,a
        and     %1111
        call    NumberToBCD
        ld      d,a
        ld      a,b
        swap    a
        and     %1111
        call    NumberToBCD
        ld      e,a

        ld      hl,mapExitLinks+EXIT_D*2
        ld      [hl],e
        inc     hl
        ld      [hl],d
        jr      .done

.checkAtAppxControls
        ;if I was at the controls when my buddy took off, kick me off
        cp      $1e
        jr      nz,.done

        ld      hl,EngineSound
        call    PlaySound

        ld      a,$ff
        ld      [levelVars+6],a    ;VAR_SELSTAGE in $1401

.done
        pop     hl
        pop     de
        pop     bc
        ret

.drawLightRowTop
        push    hl
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        sub     3
        pop     hl
        add     hl,de
        ret

.drawLightRowMiddle
        push    hl
        push    af
        sub     b
        add     3
        and     3
        add     b
        ld      [hl+],a
        ;xor     a
        ld      a,c
        ld      [hl+],a
        ld      [hl+],a
        pop     af
        ld      [hl+],a
        sub     b
        add     3
        and     3
        add     b
        pop     hl
        add     hl,de
        ret

.drawLightRowBottom
        push    hl
        add     3
        ld      [hl+],a
        dec     a
        ld      [hl+],a
        dec     a
        ld      [hl+],a
        dec     a
        ld      [hl+],a
        dec     a
        pop     hl
        add     hl,de
        ret

FindFirstLight:
        ;leaves hl at mem location of first landing light
        ;b = first light index, c=first appx index
        ;a = invisible wall index
        ;must exist or infinite loop!
        ld      bc,classInvisibleWallBG
        call    FindClassIndex

        push    af
        ld      bc,classLandingLightsBG
        call    FindClassIndex
        ld      b,a     ;index to look for

        push    bc
        ld      bc,classAppomattoxBG
        call    FindClassIndex
        pop     bc
        ld      c,a

        ld      a,MAPBANK
        ld      [$ff70],a

        ;setup de with first out-of-bounds index
        ;ld      a,[mapTotalSize]
        ;ld      e,a
        ;ld      a,[mapTotalSize+1]
        ;ld      d,a

        ld      hl,map
.lookForFirstLight
        ld      a,[hl+]
        cp      b
        jr      nz,.lookForFirstLight

        dec     hl
        pop     af

        ret

AddAppomattoxIfPresent::
        push    bc
        ld      a,[curLevelStateIndex]
        ld      b,a
        ld      a,[appomattoxMapIndex]
        cp      b
        jr      nz,.done

        call    AddAppomattox

.done
        pop     bc
        ret

EngineSound:
        DB      4,$00,$d7,$a9,$80

AddAppomattox:
        push    bc
        push    de
        push    hl

        call    FindFirstLight       ;draw appx
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        ld      a,c    ;appx index
        call    .drawAppxMiddle
        call    .drawAppxMiddle
        call    .drawAppxMiddle
        call    .drawAppxRow
        call    .drawAppxRow
        call    .drawAppxRow

        ;link exit up to $1300 (appomattox interior)
        ld      hl,mapExitLinks+EXIT_U*2
        xor     a
        ld      [hl+],a
        ld      [hl],$13

        pop     hl
        pop     de
        pop     bc
        ret

.drawAppxMiddle
        push    hl
        inc     hl
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl],a
        add     2
        pop     hl
        add     hl,de
        ret

.drawAppxRow
        push    hl
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl],a
        inc     a
        pop     hl
        add     hl,de

        ret

;WARNING not in HOME section

;---------------------------------------------------------------------
; Variables
;---------------------------------------------------------------------
SECTION        "UserVarsHRAM",HRAM
vblankFlag:              DS 1    ;0=no interrupt, 1=vblank
vblankTemp:              DS 1
vblankTimer::            DS 1
vblanksPerUpdate:        DS 1
backBufferReady::        DS 1
backBufferDestHighByte:: DS 1
paletteBufferReady::     DS 1
dmaLoad::                DS 1   ;1=load bank 0, 2=load bank 1
randomLoc::              DS 1   ;ff92
jiggleDuration::         DS 1   ;ff93
temp::                   DS 1   ;ff94
drawMapTemp::            DS 2   ;ff95
hblankFlag::             DS 1   ;ff97  :0 top/bottom, :1 show, :2 wave
hblankWinOn::            DS 1   ;ff98
hblankWinOff::           DS 1   ;ff99
firstMonster::           DS 1   ;ff9a
curROMBank::             DS 1   ;ff9b
updateTimer::            DS 1   ;ff9c
curObjWidthHeight::      DS 1   ;7:4 width, 3:0 height
scrollSpeed::            DS 1   ;7:4 fast speed (0,2,4,8) 3:0 slow speed
mapState::               DS 2   ;ff9f
transmitACK::            DS 1   ;ffa1
musicEnabled::           DS 1   ;ffa2
baseHorizontalOffset:    DS 1   ;ffa3

samplePlaying:           DS 1   ;ffa4
sampleBank:              DS 1   ;ffa5
sampleAddress:           DS 2   ;ffa6
sampleMask:              DS 1   ;ffa8
jiggleType::             DS 1   ;ffa9
asyncRandLoc::           DS 1   ;ffaa


IF 0
;clear memory to ff
ld hl,$c000
ld bc,$0f00
;ld d,$ff
ld d,0
xor a
call MemSet

ld hl,$d000
ld bc,$1000
ld a,1
call MemSet

ld hl,$d000
ld bc,$1000
ld a,2
call MemSet

ld hl,$d000
ld bc,$1000
ld a,3
call MemSet

ld hl,$d000
ld bc,$1000
ld a,4
call MemSet

ld hl,$d000
ld bc,$1000
ld a,5
call MemSet

ld hl,$d000
ld bc,$1000
ld a,6
call MemSet

ld hl,$d000
ld bc,$0020
ld a,7
call MemSet

ld d,0
ld hl,$d020
ld bc,$0fe0
ld a,7
call MemSet
ENDC

