;***************************************************************************
;*  gfx.asm - graphics support routines
;*  12.17.99 by Abe Pralle
;*
;***************************************************************************

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/start.inc"

MAX_PER_TURN EQU 32



FAST_SCROLL_THRESHOLD EQU 2


SECTION        "Graphics",ROM0
;---------------------------------------------------------------------
; Routine:      InitGfx
; Description:  Sets up some basic graphics stuff - One time
;---------------------------------------------------------------------
InitGfx::
        push bc
        push de
        push hl

        ;set up game state
        ld      a,$ff
        ld      [amLinkMaster],a
        xor     a
        ld      [lastLinkAction],a
        ld      [amChangingMap],a
        ld      [heroesPresent],a

        ld      a,(hero0_data & $ff)
        ld      [curHeroAddressL],a

        ld      a,(HERO_BA_FLAG | HERO_BS_FLAG | HERO_HAIKU_FLAG)
        ld      [heroesAvailable],a

        xor     a
        ld      [heroesUsed],a
        ld      [randomLoc],a
        ldio    [musicEnabled],a
        ld      [musicBank],a
        ld      [musicAddress],a
        ld      [musicAddress+1],a
        ld      [heroesLocked],a
        ld      [hero0_puffCount],a
        ld      [hero1_puffCount],a
        ld      [inLoadMethod],a

        ld      c,16
        ld      hl,inventory
.clearInventory
        ld      [hl+],a
        dec     c
        jr      nz,.clearInventory

;ld a,%10100001
;ld [inventory],a
;ld a,%00000011
;ld [inventory+1],a

        xor     a
        ld      [musicOverride1],a
        ld      [musicOverride4],a

        ld      a,64
        ld      [fadeRange],a

        ld      a,APPOMATTOXMAPINDEX
        ld      [appomattoxMapIndex],a

        ld      a,BANK(init_flightCodes)
        call    SetActiveROM
        ld      a,FLIGHTCODEBANK
        ld      bc,256
        ld      de,flightCode
        ld      hl,init_flightCodes
        call    MemCopy

        xor     a
        ldio    [dmaLoad],a
        ld      [displayType],a

        ld      a,1
        ldio    [curROMBank],a

        call    DisplayOff
        call    SetupSpriteHandler

        ;sound off
        xor     a
        ldio    [$ff26],a

        ;envelopes to zero
        xor     a
        ldio    [$ff12],a    ;zero envelope all instruments
        ldio    [$ff17],a
        ldio    [$ff1c],a
        ldio    [$ff21],a

        ;turn on sound master control
        ld      a,$80
        ldio    [$ff26],a
        ld      a,$ff
        ldio    [$ff24],a         ;full volume both channels
        ldio    [$ff25],a         ;all sounds to both channels

        ;setup vector to hblank
        ld      a,$c3
        ld      [hblankVector],a     ;opcode of jp
        ld      hl,OnHBlank
        ld      a,l
        ld      [hblankVector+1],a
        ld      a,h
        ld      [hblankVector+2],a

        ;enable VBlank interrupts
        ld      a,[$ffff]
        or      1
        ld      [$ffff],a

        ;turn LCD on
        ld      a,%11000011
        ld      [$ff40], a       ;lcdc control

        ;clear all level states to zero
        ld      a,LEVELSTATEBANK
        ld      [$ff70],a
        ld      c,0       ;loop 256 times
        ld      hl,levelState
        xor     a
.clearStateLoop
        ld      [hl+],a
        dec     c
        jr      nz,.clearStateLoop

        ld      a,1  ;fade from white the first time
        ld      [standardFadeColor],a

        ;enable interrupts
        ei


.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      VMemCopy
; Arguments:    a  - VRAM bank of destination
;               c  - length in multiples of 16 bytes
;               de - dest
;               hl - source
; Alters:       af
;               [$ff4f] VRAM bank
; Description:  Copies bytes from source to destination in VRAM.
;               If screen is active it utilizes DMA loading, otherwise
;               a normal copy is performed.  DMA copies exceeding
;               2048 bytes may produce weird results.
;---------------------------------------------------------------------
VMemCopy::
        push    bc
        push    de
        push    hl
        push    af

        ;test if screen is on
        ldio    a,[$ff40]
        and     %10000000
        jr      nz,.screenIsOn

.screenIsOff
        pop     af
        ldio    [$ff4f],a    ;switch VRAM bank

.setLoop
        ld      b,16
.bytesLoop
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     b
        jr      nz,.bytesLoop

        dec     c
        jr      nz,.setLoop
        jr      .done

.screenIsOn     ;copy using DMA
        pop     af
        call    InitDMALoad
        call    WaitDMALoad

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      MemSet
; Arguments:    a  - RAM bank of destination
;               bc - length in bytes
;               d  - byte to set to
;               hl - dest
; Alters:       af
;               [$ff70] RAM bank
; Description:  Sets each byte in the range to be the specified value.
;---------------------------------------------------------------------
MemSet::
        push    bc
        push    de
        push    hl

        ldio    [$ff70],a

.loop   ld      a,d
        ld      [hl+],a
        dec     bc
        xor     a
        cp      b
        jr      nz,.loop
        cp      c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      MemCopy
; Arguments:    a  - RAM bank
;               bc - non-zero length in bytes
;               de - destination starting address
;               hl - source start address
; Alters:       af
;               [$ff70] RAM bank
; Description:  Copies each of "bc" # of bytes from source to dest.
;               Alters the RAM bank to specified but does not revert
;               to original during or after copying.
;---------------------------------------------------------------------
MemCopy::
        push    bc
        push    de
        push    hl

        ldio    [$ff70],a    ;set RAM

.copy   ld      a,[hl+]
        ld      [de],a
        inc     de
        xor     a
        dec     bc
        cp      b
        jr      nz,.copy
        cp      c
        jr      nz,.copy

        pop     hl
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      InitDMALoad
; Arguments:    a  - VRAM bank of destination
;               c  - length in multiples of 16 bytes
;               de - dest
;               hl - source
; Alters:       af
; Description:  Preps appropriate variables for DMA transfer to take
;               place on VBlank.  Note may be called multiple times
;               (er, twice) to set up values for bank 0 and bank 1
;               transfer.  Note that transfers for bank 0 and bank 1
;               combined should not exceed 2048 bytes (and perhaps
;               a bit less)
;---------------------------------------------------------------------
InitDMALoad::
        or      a
        jr      nz,.prepBank1

.prepBank0
        ld      a,l
        ld      [dmaLoadSrc0],a
        ld      a,h
        ld      [dmaLoadSrc0+1],a

        ld      a,e
        ld      [dmaLoadDest0],a
        ld      a,d
        ld      [dmaLoadDest0+1],a

        ld      a,c
        dec     a
        ld      [dmaLoadLen0],a

        ldio    a,[dmaLoad]
        or      1
        ldio    [dmaLoad],a
        ret

.prepBank1
        ld      a,l
        ld      [dmaLoadSrc1],a
        ld      a,h
        ld      [dmaLoadSrc1+1],a

        ld      a,e
        ld      [dmaLoadDest1],a
        ld      a,d
        ld      [dmaLoadDest1+1],a

        ld      a,c
        dec     a
        ld      [dmaLoadLen1],a

        ldio    a,[dmaLoad]
        or      2
        ldio    [dmaLoad],a
        ret

;---------------------------------------------------------------------
; Routine:      WaitDMALoad
; Alters:       af
;---------------------------------------------------------------------
WaitDMALoad::
        push    bc
        push    de
        push    hl
.wait
        ldio    a,[dmaLoad]
        and     %11
        jr      nz,.wait

        call    GetInput
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      DMALoad
; Arguments:    a  - VRAM bank of destination
;               c  - byte length / 16
;               hl - source
;               de - dest
; Alters:       af
; Description:  Combines InitDMALoad and WaitDMALoad.
;---------------------------------------------------------------------
DMALoad::
        call    InitDMALoad
        call    WaitDMALoad
        ret

;---------------------------------------------------------------------
; Routine:      DisplayOff
; Arguments:
; Alters:       af
; Description:  Waits for VBlank then turns of the display
;---------------------------------------------------------------------
DisplayOff::
        ;skip if the display is off already
        ld      a,[$ff40]
        and     %10000000
        ret     z

        ;turn display off
        ld      a,[$ffff]            ;get interrupts enabled
        push    af                   ;save original value
        and     %11111110            ;turn off vblank interrupt
        ld      [$ffff],a            ;"interrupt THIS!"
.wait   ld      a,[$ff44]            ;get line being drawn
        cp      144                  ;wait until line is >= 144
        jr      c,.wait
        ld      a,[$ff40]            ;LCDC register
        and     %01111111            ;turn off screen
        ld      [$ff40],a
        pop     af                   ;retrieve original interrupt settings
        ld      [$ffff],a

.waitVRAM
        ld      a,[$ff41]            ;STAT register
        and     %00000010            ;bit 1 needs to be zero to access VRAM
        jr      nz,.waitVRAM
        ret

;---------------------------------------------------------------------
; Subroutine:   LoadNextLevel
; Arguments:
; Alters:       af
; Description:  Does all the prep work of setting up the next level
;               based on arguments stored in memory
;---------------------------------------------------------------------
LoadNextLevel::
        push    bc
        push    de
        push    hl

.reload
        ld      a,1
        ld      [amChangingMap],a

        ;xor     a
        ;ld      [timeToChangeLevel],a

        ;save old level's level state
        ld      a,LEVELSTATEBANK
        ld      [$ff70],a
        ld      a,[curLevelStateIndex]
        ld      l,a
        ld      h,((levelState>>8) & $ff)
        ldio    a,[mapState]
        or      a
        jr      nz,.stateNotZero
        ld      a,1
.stateNotZero
        ld      [hl],a

        ;clear joystick input
        xor     a
        ld      [curJoy0],a
        ld      [curJoy1],a
        ldio    [jiggleDuration],a
        ld      [jiggleType],a       ;normal jiggle

        call    PrepLevel
        ld      a,[timeToChangeLevel]
        or      a
        jr      nz,.reload

        ;set interrupt controller flag so the interrupt will happen
        ld      a,[$ffff]         ;interrupt enable control register
        or      %00000011         ;enable vblank and hblank interrupts
        ld      [$ffff],a         ;store that back in the IEC

        call    DrawMapToBackBuffer

        ;ld      b,METHOD_CHECK
        ;call    IterateAllLists

        ;initialize some values
        xor     a
        ldio    [backBufferReady],a

        xor     a
        ld      [amChangingMap],a

        ei                        ;enable interrupts

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      PrepLevel
; Description:  Sets up some basic graphics stuff
;---------------------------------------------------------------------
PrepLevel::
        push bc
        push de
        push hl

        ;reset some stuff
        xor     a
        ld      [levelCheckSkip],a
        ld      [levelCheckSkip+1],a
        ld      [levelCheckSkip+2],a
        ld      [levelCheckSkip+3],a
        ld      a,MAX_PER_TURN
        ld      [iterateNumObjects],a

        ld      hl,timeToChangeLevel
        ld      a,[hl]
        ld      [hl],0
        cp      2           ;2=skip init & load in next
        jp      z,.loadMap

        ;restore default vector to hblank
        ld      hl,OnHBlank
        call    InstallHBlankHandler

        xor     a
        ldh     [$ff43], a        ;set screen offsets to 0
        ldh     [$ff42], a

        xor     a
        ldh     [$ff4a], a        ;set window offsets to 7,0
        ld      a,7
        ldh     [$ff4b], a

        xor     a
        ld      [specialFX],a
        ld      [paletteBufferReady],a
        ld      [mapColor],a
        ld      [mapColor+1],a
        ld      [bgAttributes],a
        ld      [bgTileMap],a
        ld      [checkInputInMainLoop],a
        ld      [dialogJoyIndex],a
        ld      [heroJoyIndex],a
        ld      [hero0_index],a
        ld      [hero1_index],a
        ld      [heroesIdle],a
        ld      [allIdle],a
        ld      [mapDialogClassIndex],a
        ld      [dialogSettings],a    ;no border, no press B
        ld      [amShowingDialog],a
        ld      [objTimerBase],a
        ld      [objTimer60ths],a
        ld      [heroTimerBase],a
        ld      [heroTimerBase],a
        ld      [lineZeroHorizontalOffset],a
        ld      [samplePlaying],a
        ld      [guardAlarm],a
        ld      [dialogNPC_speakerIndex],a
        ld      [dialogNPC_heroIndex],a
        ld      [dialogBalloonClassIndex],a
        ld      [envEffectType],a

        ;clear the horizontal offsets
        ld      bc,144
        ld      d,0
        ld      hl,horizontalOffset
        ld      a,TILEINDEXBANK
        call    MemSet

        ld      a,1
        ld      [canJoinMap],a

        ld      de,0
        call    SetDialogSkip
        call    SetDialogForward

        ;---------------------------
        xor     a
        ;turn all sounds off
        ldio    [$ff12],a   ;sound 1 envelope
        ldio    [$ff17],a   ;sound 2 envelope
        ldio    [$ff1a],a   ;sound 3 output
        ldio    [$ff21],a   ;sound 4 envelope

        ld      a,$ff
        ld      [$ff24],a         ;full volume both channels
        ;---------------------------

        ld      a,$ff
        ld      [dialogSpeakerIndex],a

        ;ld      a,$21   ;fast=2, slow=1
        ;ld      a,$22   ;fast=2, slow=2
        ld      a,$42
        ldio    [scrollSpeed],a

        ;set up each entry of bgTileMap to be its own index for a
        ;speed trick in the map redraw
        ld      c,0
        ld      hl,bgTileMap
        xor     a
.initBGTileMap
        ld      [hl+],a
        inc     a
        dec     c
        jr      nz,.initBGTileMap

        ld      a,%00100111      ;background palette colors
        ld      [$ff47],a

        ld      a,1
        ld      [scrollSprites],a

        call    LoadGraphics

        ;go back to VRAM bank zero
        xor     a                      ;Switch to tile map
        ld      [$ff00+$4f],a          ;(VRAM bank 0)

        call    SetupGamePalettes

        ;load in inventory items tiles 246-254
        ld      a,BANK(BGTiles1024)
        call    SetActiveROM
        ld      a,1
        ;xor     a
        ld      c,9            ;#characters
        ld      de,$8f60
        ld      hl,BGTiles1024+$3f70
        call    VMemCopy

        call    LoadFont

        ld      a,1
        ld      c,1              ;1 character
        ld      de,$8ff0
        ld      hl,blankTileData
        call    VMemCopy

        ;set up hblank interrupt
        ld      a,143
        ld      [$ff45],a         ;set lyc
        xor     a
        ld      [hblankFlag],a    ;don't show dialog window
        ld      a,[$ff0f]         ;clear LCDC interrupt flag
        and     %11111101
        ld      [$ff0f],a

        ld      a,119
        ldio    [hblankWinOn],a
        ld      a,143
        ldio    [hblankWinOff],a

        ld      a,%00001100       ;setup stat for lyc = ly
        ld      [$ff41],a

        ld      a,[$ffff]         ;enable hblank interrupt
        or      %00000010
        ld      [$ffff],a

        ld      a,$98
        ld      [backBufferDestHighByte],a

        call    ResetSprites

.loadMap
        ; load in a map
        ld      a,BANK(ResetList)
        call    SetActiveROM
        call    ResetList
        call    ClearFGBGFlags

        ld      hl,curLevelIndex
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        call    LoadMap

.done
        pop     hl
        pop     de
        pop     bc
        ret

LoadFont::
        ;load in font into $8c80 (tiles 200-253)
        ld      a,BANK(fontData)
        call    SetActiveROM
        xor     a
        ld      c,62             ;# characters
        ld      de,$8c00
        ld      hl,fontData
        jp      VMemCopy

;---------------------------------------------------------------------
; Routine:      SetupSpriteHandler
; Description:  Copies the routine required for sprite DMA to high
;               RAM and initializes the sprites to off
;---------------------------------------------------------------------
SetupSpriteHandler::
        ld      hl,oamHandlerStart                     ;src addr
        ld      de,SpriteDMAHandler                    ;dest addr
        ld      c,(oamHandlerFinish - oamHandlerStart) ;# of bytes

.loop   ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      nz,.loop

        call    ResetSprites

        ret

oamHandlerStart:
  ld      a,((spriteOAMBuffer>>8) & $ff)    ;addr of start (in $100's)
        ld      [$ff00+$46],a            ;start sprite dma
        ld      a,$28                    ;start a delay loop
.wait        dec     a
        jr      nz,.wait
        ret
oamHandlerFinish:


;---------------------------------------------------------------------
; Routine:      SetupCommonColor
; Arguments:    b  - Color Spec for entry to set up
;               de - color for entry
; Description:  Sets all 8 palettes (bg AND sprite) to have the same
;               colors for the specified entry.
; Note:         The format specification should have bit 7 set so it
;               auto-selects the next palette
;---------------------------------------------------------------------
SetupCommonColor::
        push    af
        push    bc
        push    hl

        ld      a,FADEBANK
        ld      [$ff70],a
        ld      a,b

        ld      h,((gamePalette>>8) & $ff)
        and     %00000110                       ;color # * 2
        add     (gamePalette & $ff)
        ld      l,a

        ld      a,b

        ld      c,16

.loop
        ld      a,e              ;Get low byte of color
        ld      [hl+],a          ;store it in game palette

        ld      a,d              ;Get high byte of color
        ld      [hl+],a          ;store in game palette

        ld      a,l              ;skip next 3 colors in game palette
        add     6
        ld      l,a

        dec     c
        jr      nz,.loop

        pop     hl
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      SetupGamePalettes
; Description:  Sets up [gamePalette] the in-game colors but sets
;               the actual hardware to be all standard
;---------------------------------------------------------------------
SetupGamePalettes:
        push    bc
        push    de
        push    hl

        ld      a,FADEBANK
        ld      [$ff70],a

        ld      a,%10000000  ;color specs
        ld      [$ff68],a
        ld      [$ff6a],a

        ld      bc,$0000     ;standard fade color
        ld      hl,standardFadeColor
        ld      a,[hl]
        ld      [hl],0
        or      a
        jr      z,.fadeColorSet

        ld      bc,$7fff     ;color 1 = white

.fadeColorSet
        ld      hl,.stdPaletteData
        ld      de,gamePalette
        ld      a,32     ;set up 64 bytes (32 colors)


.loop   push    af
        ld      a,[hl+]
        ld      [de],a       ;copy of palette
        inc     de
        ld      a,[hl+]
        ld      [de],a
        inc     de

        ld      a,c
        ld      [$ff69],a    ;bg palette
        ld      [$ff6b],a    ;fg palette

        ld      a,b
        ld      [$ff69],a    ;bg palette
        ld      [$ff6b],a    ;fg palette

        pop     af
        dec     a
        jr      nz,.loop

;repeat for FG colors
        ld      hl,.stdPaletteData
        ld      c,32     ;set up 64 bytes (32 colors)

.loopFG ld      a,[hl+]
        ld      [de],a       ;copy of palette
        inc     de
        ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      nz,.loopFG

        pop     hl
        pop     de
        pop     bc

        ret

.stdPaletteData
        DW      $0000, $2108, $4210, $7fff     ;Palette 0 (Grey)
        DW      $0000, $000A, $001f, $7fff     ;Palette 1 (Red)
        DW      $0000, $5000, $7e00, $7fff     ;Palette 2 (Blue)
        DW      $0000, $0140, $03e0, $7fff     ;Palette 3 (Green)
        DW      $0000, $4008, $5192, $7fff     ;Palette 4 (Purple)
        DW      $0000, $01cd, $03fe, $7fff     ;Palette 5 (Yellow)
        DW      $0000, $00d1, $09ff, $7fff     ;Palette 6 (Brown)
        DW      $0000, $4412, $799c, $7fff     ;Palette 7 (Fuscia)

;---------------------------------------------------------------------
; Routines:     IndexToPointerDE
;               IndexToPointerHL
; Arguments:    a   - index 1-255 of object
; Returns:      de/hl  - pointer $d010-$dff0 to object
;---------------------------------------------------------------------
IndexToPointerDE::
        swap    a
        jr      z,.null
        ld      e,a
        and     %00001111
        add     $d0
        ld      d,a
        ld      a,e
        and     %11110000
        ld      e,a
        ret
.null
        ld      de,0
        ret

IndexToPointerHL::
        swap    a
        jr      z,.null
        ld      l,a
        and     %00001111
        add     $d0
        ld      h,a
        ld      a,l
        and     %11110000
        ld      l,a
        ret
.null
        ld      hl,0
        ret


SECTION "TileCopyRoutines",ROM0
;---------------------------------------------------------------------
; Routines:     AddHL16
;               AddDE16
; Alters:       af, (hl or de)
;---------------------------------------------------------------------
AddHL16::
        ld      a,l
        add     16
        ld      l,a
        ret     nc
        inc     h
        ret
AddDE16::
        ld      a,e
        add     16
        ld      e,a
        ret     nc
        inc     d
        ret

;---------------------------------------------------------------------
; Routines:     TileIndexLToAddressHL
;               TileIndexEToAddressDE
; Arguments:    l/e   - tile index (0-255)
; Returns:      hl/de - address of tile index ($9000 +/- index*16)
;---------------------------------------------------------------------
TileIndexLToAddressHL:
        push    af

        ;shift "l" 4 left and into a
        xor     a                ;clear a to zero (new high byte)
        sla     l                ;shift into carry
        rla                      ;carry into a
        sla     l                ;repeat total of 4 times
        rla                      ;carry into a
        sla     l
        rla
        sla     l
        rla
        or      $90              ;add base addr of $9000
        cp      $98              ;>=$9800?
        jr      c,.allSet

        sub     $10              ;signed #'s means >$9800 should be $8800+

.allSet
        ld      h,a              ;a into h; hl is now $9000+/-offset

        pop     af
        ret

TileIndexEToAddressDE:
        push    af

        ;shift "e" 4 left and into a
        xor     a                ;clear a to zero (new high byte)
        sla     e                ;shift into carry
        rla                      ;carry into a
        sla     e                ;repeat total of 4 times
        rla                      ;carry into a
        sla     e
        rla
        sla     e
        rla
        or      $90              ;add base addr of $9000
        cp      $98
        jr      c,.allSet

        sub     $10

.allSet
        ld      d,a              ;a into d; de is now $9000+/-offset

        pop     af
        ret


;---------------------------------------------------------------------
; Routine:      TileCopyRotateCCW
; Arguments:    l - Source tile index (0-255)
;               e - Dest tile index
; Description:  Copies pixels from source tile to dest tile, rotating
;               90 degrees counter clock-wise in the process
; Note:         Assumes VRAM to be already accessible
;---------------------------------------------------------------------
TileCopyRotateCCW:
        push    af
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ;Set up outer loop
        ld      a,8               ;outer loop 8 times

        ;Beginning of outer loop / Set up inner loop
.outer1 push    de           ;save source start
        push    af           ;save outer loop counter
        ld      a,8          ;inner loop 8 times

.inner1 push    af           ;save loop counter on stack
        ld      a,[de]       ;get next even byte
        rrca
        rl      b
        ld      [de],a
        inc     de
        ld      a,[de]       ;get next odd byte
        rrca
        rl      c
        ld      [de],a
        inc     de

        pop     af           ;retrieve loop counter
        dec     a
        jr      nz,.inner1


        ld      a,b          ;save next two bytes of result
        ld      [hl+],a
        ld      a,c
        ld      [hl+],a

        pop     af           ;retrieve outer loop counter
        pop     de           ;reset srcptr to start of tile
        dec     a
        jr      nz,.outer1

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routines:     TileCopy
;               TileCopyShiftLeft
;               TileCopyShiftRight
;               TileCopyShiftLeftOverlay
;               TileCopyShiftRightOverlay
;               TileCopyShiftUp
;               TileCopyShiftDown
; Arguments:    e - Source tile index (0-15)
;               l - Dest tile index (0-15)
; Description:  Copies tiles while shifting 4 pixels in the specified
;               direction (except for plain TileCopy).  Tile patterns
;               should be stored in $c000-$c0ff.  "Overlay" routines
;               OR the source with the destination.
;---------------------------------------------------------------------
TileCopy:
        push    af
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ld      c,16            ;loop 16 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        ld      [hl+],a         ;put it in dest
        dec     c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

TileCopyShiftLeft:
        push    af
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ld      c,16            ;loop 16 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        swap    a               ;flip nibbles
        and     $f0             ;clear out lower four bits
        ld      [hl+],a         ;put it in dest
        dec     c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

TileCopyShiftRight:
        push    af
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ld      c,16            ;loop 16 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        swap    a               ;flip nibbles
        and     $0f             ;clear out upper four bits
        ld      [hl+],a         ;put it in dest
        dec     c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

TileCopyShiftLeftOverlay:
        push    af
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ld      c,16            ;loop 16 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        swap    a               ;flip nibbles
        and     $f0             ;clear out lower four bits
        or      [hl]            ;combine with dest
        ld      [hl+],a
        dec     c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

TileCopyShiftRightOverlay:
        push    af
        push    bc
        push    de
        push    hl

        ;Get tile addresses
        call    TileCopyIndicesToAddresses

        ld      c,16            ;loop 16 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        swap    a               ;flip nibbles
        and     $0f             ;clear out upper four bits
        or      [hl]            ;combine with dest
        ld      [hl+],a
        dec     c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

TileCopyIndicesToAddresses:
        push    bc
        ld      c,4
        ld      h,0
        ld      d,0
.loop
        sla     l
        rl      h
        sla     e
        rl      d
        dec     c
        jr      nz,.loop
        pop     bc
        ld      a,((backBuffer>>8) & $ff)
        add     a,h
        ld      h,a
        ld      a,((backBuffer>>8) & $ff)
        add     a,d
        ld      d,a
        ret

TileCopyShiftUp:
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ld      a,e     ;source += 8
        add     8
        ld      e,a

        ld      c,8             ;loop 8 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        ld      [hl+],a         ;put it in dest
        dec     c
        jr      nz,.loop

        ;clear 4 rows (8 bytes)
        ld      c,8
        xor     a
.clear
        ld      [hl+],a
        dec     c
        jr      nz,.clear

        pop     hl
        pop     de
        pop     bc
        ret

TileCopyShiftDown:
        push    bc
        push    de
        push    hl

        call    TileCopyIndicesToAddresses

        ;clear 4 rows (8 bytes)
        ld      c,8
        xor     a
.clear
        ld      [hl+],a
        dec     c
        jr      nz,.clear

        ld      c,8             ;loop 8 times
.loop   ld      a,[de]          ;get a byte
        inc     de
        ld      [hl+],a         ;put it in dest
        dec     c
        jr      nz,.loop

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      DuplicateTilesToSpriteMem
; Arguments:    a - number of tiles to duplicate (1+)
;               c - index of first tile in tile mem
; Alters:       af
; Description:  Copies {a} number of tiles (a*16 bytes) from $c000
;               (backBuffer) to $8000 + c*16.
; Note:         Uses current VRAM bank
;---------------------------------------------------------------------
DuplicateTilesToSpriteMem:
        push    bc
        push    de
        push    hl

        ld      b,a          ;tiles remaining

        ;de = $8000 + c*16
        ld      a,c
        swap    a
        and     %00001111
        add     $80
        ld      d,a

        ld      a,c
        swap    a
        and     %11110000
        ld      e,a

        ;hl = $c000
        ld      hl,backBuffer

.next_tile
        ;tiles 128-255 are in VRAM shared between sprites and tiles
        ;and do not need to be copied.
        ld      a,c
        cp      128
        jr      nc,.after_copy

        push    bc
        ld      c,1        ;1*16 bytes
        ld      a,1        ;VRAM bank 1
        call    VMemCopy
        pop     bc

.after_copy
        ;de+=16, hl+=16
        call    AddHL16
        call    AddDE16

        ;tileNum++, tilesRemaining--
        inc     c
        dec     b
        jr      nz,.next_tile

        pop     hl
        pop     de
        pop     bc
        ret

IF 0
        push    bc
        push    de
        push    hl

        ld      b,a
        ld      l,c
        call    TileIndexLToAddressHL

.next_tile
        ld      a,h
        cp      $90
        jr      c,.no_copy_necessary

        ;dest addr = source addr - $1000
        ld      a,h
        sub     $10
        ld      d,a
        ld      e,l

        ;source addr
        ld      hl,$c000
        ld      c,16

.copy   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.copy
        jr      .after_copy

.no_copy_necessary
        ld      de,16
        add     hl,de

.after_copy
        dec     b
        jr      nz,.next_tile

        pop     hl
        pop     de
        pop     bc
        ret
ENDC

;---------------------------------------------------------------------
; Routine:      GenerateFacings
; Arguments:    a - index (0-255) of the first of two consecutive
;                   tiles (frame1 and frame2) which should be facing
;                   east.  Tiles should be located at $c000
;                   (backBuffer).
;               [curObjWidthHeight] - copy of FG attribute flags
; Description:  Creates the following tiles at $9000-$97ff (indices
;               0-127) and $8800-$8fff (128-255):
;               a   - North facing, frame 1
;               a+1 - Top half of North facing, frame 2
;               a+2 - Bottom half of North facing, frame 2
;               a+3...a+5  - East facing (frame1, left frame2, right
;                            frame2)
;
;               Duplicates any tiles in area $9000-$9800 into
;               $8000-$8800 for tile<->sprite purposes
;---------------------------------------------------------------------
GenerateFacings::
        push    af
        push    bc
        push    de
        push    hl

        ld      c,a           ;starting index

        ldio    a,[curObjWidthHeight]   ;retrieve flags
        bit     BIT_2X2,a
        jr      z,.generate1x1
        jp      .generate2x2

.generate1x1
        ld      a,[curObjWidthHeight] ;attribute flags
        bit     BIT_NOROTATE,a
        jr      nz,.createNonRotatedSprites

.createRotatedSprites
        ;create non-split frames for sprites
        ld      e,0           ;source index
        ld      l,2           ;dest index
        call    TileCopyRotateCCW
        inc     e
        inc     l
        call    TileCopyRotateCCW
        jr      .copyTilesToSpriteMem

.createNonRotatedSprites
        ;create non-split frames for sprites
        ld      e,0           ;source index
        ld      l,2           ;dest index
        call    TileCopy
        inc     e
        inc     l
        call    TileCopy

.copyTilesToSpriteMem
        ld      a,4
        call    DuplicateTilesToSpriteMem

        ;East-facing frames
        ld      e,0           ;source index in e
        ld      l,3           ;dest index in l
        call    TileCopy
        inc     e             ;source to next frame
        inc     l             ;set dest index to next frame
        call    TileCopyShiftRight
        inc     l
        call    TileCopyShiftLeft

        ld      a,[curObjWidthHeight] ;attribute flags
        bit     BIT_NOROTATE,a
        jr      nz,.copyNorthNoRotate

        ;North facings
        ld      l,0           ;dest is +0 (North)
        ld      e,3           ;Set source ptr to +3 (East)
        call    TileCopyRotateCCW
        inc     e
        inc     l
        inc     l
        call    TileCopyRotateCCW
        inc     e
        dec     l
        call    TileCopyRotateCCW
        jr      .copyBufferToVMem

.copyNorthNoRotate
        ld      e,1
        ld      l,6
        call    TileCopy
        ld      e,6
        ld      l,1
        call    TileCopyShiftDown
        inc     l
        call    TileCopyShiftUp

.copyBufferToVMem
        ;Copy 6 tiles beginning at $c000+ to $9000+(c*16).
        ;Next location after $97f0 is $8800.
        ld      a,c
        cp      122         ;122+6 < 128
        jr      c,.copySet  ;to $9000+

        cp      128
        jr      nc,.copySet ;to $8800+

.copyOneByOne   ;split across different banks
        ld      e,c
        call    TileIndexEToAddressDE   ;destination
        ld      hl,$c000                ;source

        ld      b,6           ;tiles to copy
        ld      c,1           ;copy 16 bytes at a time

.nextTile
        ld      a,1           ;VRAM Bank 1
        call    VMemCopy
        call    AddDE16
        call    AddHL16
        ld      a,d
        cp      $98
        jr      nz,.destPtrOkay
        ld      d,$88
.destPtrOkay
        dec     b
        jr      nz,.nextTile
        jp      .done

.copySet
        ld      e,a
        call    TileIndexEToAddressDE
        ld      hl,$c000
        ld      c,6                ;6*16
        ld      a,1
        call    VMemCopy
        jp      .done

.generate2x2
        ;East-facing 2x2
        ld      e,0           ;source index in e
        ld      l,10          ;dest index in l
        call    TileCopy
        inc     e
        inc     l
        call    TileCopy
        inc     e
        inc     l
        call    TileCopy
        inc     e
        inc     l
        call    TileCopy

        inc     e
        inc     l
        call    TileCopyShiftRight
        inc     l
        call    TileCopyShiftLeft
        inc     e
        call    TileCopyShiftRightOverlay
        inc     l
        call    TileCopyShiftLeft

        inc     e
        inc     l
        call    TileCopyShiftRight
        inc     l
        call    TileCopyShiftLeft
        inc     e
        call    TileCopyShiftRightOverlay
        inc     l
        call    TileCopyShiftLeft

        ld      e,10
        ld      l,2
        call    TileCopyRotateCCW
        inc     e
        ld      l,0
        call    TileCopyRotateCCW
        inc     e
        ld      l,3
        call    TileCopyRotateCCW
        inc     e
        ld      l,1
        call    TileCopyRotateCCW
        inc     e
        ld      l,8
        call    TileCopyRotateCCW
        inc     e
        ld      l,6
        call    TileCopyRotateCCW
        inc     e
        ld      l,4
        call    TileCopyRotateCCW
        inc     e
        ld      l,9
        call    TileCopyRotateCCW
        inc     e
        ld      l,7
        call    TileCopyRotateCCW
        inc     e
        ld      l,5
        call    TileCopyRotateCCW

        ;Copy 20 tiles beginning at $c000+ to $9000+(c*16).
        ;Next location after $97f0 is $8800.
        ld      a,c
        cp      108         ;108+20 < 128
        jr      c,.copySet20  ;to $9000+

        cp      128
        jr      nc,.copySet20 ;to $8800+

.copyOneByOne20   ;split across different banks
        ld      e,c
        call    TileIndexEToAddressDE   ;destination
        ld      hl,$c000                ;source

        ld      b,20          ;tiles to copy
        ld      c,1           ;copy 16 bytes at a time

.nextTile20
        ld      a,1           ;VRAM Bank 1
        call    VMemCopy
        call    AddDE16
        call    AddHL16
        ld      a,d
        cp      $98
        jr      nz,.destPtrOkay20
        ld      d,$88
.destPtrOkay20
        dec     b
        jr      nz,.nextTile20
        jr      .done

.copySet20
        ld      e,a
        call    TileIndexEToAddressDE
        ld      hl,$c000
        ld      c,20               ;20*16
        ld      a,1
        call    VMemCopy
        jp      .done

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

SECTION "Graphics",ROM0
;---------------------------------------------------------------------
; Routine:      LoadGraphics
; Arguments:
;---------------------------------------------------------------------
LoadGraphics:
        ld      a,BANK(BGTiles)
        call    SetActiveROM

        ;switch to vram bank 1
        ld      a,1
        ;ld      [$ff4f],a
        call    .loadBlank

        ;switch to vram bank 0
        xor     a
        ;ld      [$ff4f],a
        call    .loadBlank

        ;load 86 explosion sprites
        ld      a,MAP0ROM
        call    SetActiveROM
        xor     a
        ld      c,86    ;#sprites
        ld      de,$8000
        ld      hl,explosionSprites
        call    VMemCopy

IF 0
        ;load 80 explosion sprites
        ld      a,MAP0ROM
        call    SetActiveROM
        ld      hl,explosionSprites
        ld      de,$8000
        ld      b,80                ;# sprites
.outer  ld      c,16                ;16 bytes each
.inner  ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.inner
        dec     b
        jr      nz,.outer
ENDC

        ret

.loadBlank
        ;load a blank tile to tile 0 of VRAM bank "a"
        ;xor     a
        ld      c,1   ;1 tile
        ld      de,$9000
        ld      hl,BGTiles     ;1st tile is blank
        call    VMemCopy
        ret

IF 0
        ld      hl,blankTile       ;address to get graphics from
        ld      de, $9000          ;destination address (Tile VRAM)
        ld      c,  1 * 16         ;copy 1 tile of 16 bytes
.loop   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop
        ret
ENDC

;---------------------------------------------------------------------
; Routine:      LoadSprites
; Arguments:    a  - ROM bank containing sprites
;               c  - number of sprites to load
;               hl - starting addr of sprites to load
;               de - dest addr of sprites to load
; Alters:       af
; Description:  Loads specified number of sprites to VRAM bank 0
;               specified location.  Switches back to CLASSROM when
;               done.  Must be done on VBLANK or when display is off
;---------------------------------------------------------------------
LoadSprites::
        push    bc
        push    de
        push    hl

        call    SetActiveROM
        xor     a            ;VRAM bank 0
        ld      [$ff4f],a

.outer  ld      b,16         ;copy 16 bytes
.inner  ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     b
        jr      nz,.inner
        dec     c
        jr      nz,.outer

        ld      a,CLASSROM
        call    SetActiveROM

        pop     hl
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      PrepareForInitialMapDraw
; Description:  Sets relevant variables so the map can be drawn
;---------------------------------------------------------------------
PrepareForInitialMapDraw::
        call    AdjustCameraToHero
        call    RestrictCameraToBounds

        ld      hl,mapLeft
        ld      a,[desiredMapLeft]
        ld      [hl+],a                ;mapLeft
        add     20
        ld      [hl+],a                ;mapRight
        inc     a
        ld      [hl+],a                ;mapRightPlusOne

        ld      a,[desiredMapTop]
        ld      [hl+],a                ;mapTop
        add     18
        ld      [hl+],a                ;mapBottom
        inc     a
        ld      [hl+],a                ;mapBottomPlusOne

        xor     a
        ld      [curPixelOffset_x],a
        ld      [curPixelOffset_y],a
        ld      [desiredPixelOffset_x],a
        ld      [desiredPixelOffset_y],a
        ld      [scrollAccelState_x],a
        ld      [scrollAccelState_y],a

        ;set up a table for speedy AI
        ;east offset is +1
        ld      a,1
        ld      [mapOffsetEast],a      ;low byte
        xor     a
        ld      [mapOffsetEast+1],a    ;high byte

        ;west offset is -1
        ld      a,$ff
        ld      [mapOffsetWest],a
        ld      [mapOffsetWest+1],a

        ;south offset is +pitch
        xor     a
        ld      [mapOffsetSouth+1],a
        ld      a,[mapPitch]
        ld      [mapOffsetSouth],a

        ;north offset is -pitch
        cpl
        inc     a
        ld      [mapOffsetNorth],a
        ld      a,$ff
        ld      [mapOffsetNorth+1],a

        ret

;---------------------------------------------------------------------
; Routine:      AdjustCameraToHero
; Arguments:    None.
; Description:  Centers camera on hero, then adjusts so that maximum
;               amount of space on in all 4 directions is visible
;
;---------------------------------------------------------------------
AdjustCameraToHero::
        ld      a,[displayType]
        or      a
        jr      z,.mapType

        ;cinema type
        xor     a
        ld      [camera_i],a
        ld      [camera_j],a
        ret

.mapType
        push    bc
        push    de
        push    hl

        ld      a,OBJBANK           ;Get Location of hero
        ld      [$ff70],a

        ;hl = &heroX_object
        LDHL_CURHERODATA HERODATA_OBJ

        ld      a,[hl+]
        ld      e,a
        ld      a,[hl]
        ld      d,a

        ld      a,[de]
        ld      l,a
        ld      [tempL],a
        inc     de
        ld      a,[de]
        ld      h,a
        ld      [tempH],a

        call    ConvertLocHLToXY    ;convert to x,y indices
        ld      a,h
        ld      [camera_i],a
        ld      a,l
        ld      [camera_j],a
        ld      a,MAPBANK
        ld      [$ff70],a
        ldio    a,[firstMonster]
        ld      c,a                 ;c class of first monster

        ;find nearest wall to the north of location
        ld      a,[tempL]           ;hl will track location
        ld      l,a
        ld      a,[tempH]
        ld      h,a
        ld      b,0                 ;b will track north offset
        ld      d,$ff               ;de = -pitch
        ld      a,[mapPitch]
        cpl
        add     1
        ld      e,a
        push    hl

.nloop  add     hl,de
        inc     b
        ld      a,[hl]
        or      a
        jr      z,.nloop            ;nothing at all here
        cp      c                   ;found something, check if monster
        jr      nc,.nloop           ;don't count monsters
        call    GetBGAttributes
        and     (BG_FLAG_WALKOVER|BG_FLAG_SHOOTOVER)
        ld      a,MAPBANK
        ldio    [$ff70],a
        jr      nz,.nloop

        ;b is tile distance of closest wall to the north
        pop     hl                  ;retrieve original location
        push    bc                  ;save north count b
        ld      b,0                 ;b counts clear tiles to south
        ld      d,0                 ;de is offset to go south
        ld      a,[mapPitch]
        ld      e,a
        push    hl                  ;push original location again

.sloop  add     hl,de
        inc     b
        ld      a,[hl]
        or      a
        jr      z,.sloop
        cp      c
        jr      nc,.sloop
        call    GetBGAttributes
        and     (BG_FLAG_WALKOVER|BG_FLAG_SHOOTOVER)
        ld      a,MAPBANK
        ldio    [$ff70],a
        jr      nz,.sloop

        ;now b is distance of closest wall to south
        pop     hl                  ;retrieve original location
        ld      a,b
        pop     bc                  ;retrieve north distance
        ld      c,a                 ;b=north, c=south dist

        ;---------------Scroll Camera South---------------------------
        ;while(s_dist >= 10 && n_dist<8){
        ;  move camera to south;
        ;   south dist--;
        ;  north dist++;
        ;}
.cam_south_loop
        ld      a,c                 ;s_dist >= 10?
        cp      10
        jr      c,.cam_south_loopDone

        ld      a,b
        cp      7
        jr      nc,.cam_south_loopDone     ;n_dist < 8?

        call    .moveCameraSouth
        jr      .cam_south_loop

.cam_south_loopDone

        ;---------------Scroll Camera North---------------------------
        ;while(n_dist >= 9 && s_dist<9){
        ;  move camera to north;
        ;   south dist++;
        ;  north dist--;
        ;}
.cam_north_loop
        ld      a,b                 ;n_dist >= 9?
        cp      9
        jr      c,.cam_north_loopDone

        ld      a,c
        cp      9
        jr      nc,.cam_north_loopDone     ;s_dist < 9?

        call    .moveCameraNorth
        jr      .cam_north_loop

.cam_north_loopDone
        ld      a,c                 ;save distances for later use
        ld      [distToWall_S],a
        ld      a,b
        ld      [distToWall_N],a

        ;----------------------------
        ; Handle east/west scrolling
        ;----------------------------
        ld      b,0                 ;b counts clear tiles to west
        ld      d,h                 ;save hl in de
        ld      e,l
        ldio    a,[firstMonster]
        ld      c,a
        dec     hl

.wloop  inc     b
        ld      a,[hl-]             ;get location
        or      a
        jr      z,.wloop            ;loop if empty
        cp      c
        jr      nc,.wloop           ;loop if monster
        call    GetBGAttributes
        and     (BG_FLAG_WALKOVER|BG_FLAG_SHOOTOVER)
        ld      a,MAPBANK
        ldio    [$ff70],a
        jr      nz,.wloop

        ;now b is distance of closest wall to west
        ld      h,d                 ;set hl back to original location
        ld      l,e
        ld      d,b                 ;store west distance in d
        ld      b,0
        inc     hl

.eloop  inc     b
        ld      a,[hl+]             ;get location
        or      a
        jr      z,.eloop            ;loop if empty
        cp      c
        jr      nc,.eloop           ;loop if monster
        call    GetBGAttributes
        and     (BG_FLAG_WALKOVER|BG_FLAG_SHOOTOVER)
        ld      a,MAPBANK
        ldio    [$ff70],a
        jr      nz,.eloop

        ;now b is distance of closest wall to east
        ld      c,b                 ;b=west, c=east dist
        ld      b,d

        ;---------------Scroll Camera East----------------------------
        ;while(e_dist >= 11 && w_dist<9){
        ;  move camera to east;
        ;   east dist--;
        ;  west dist++;
        ;}
.cam_east_loop
        ld      a,c                 ;e_dist >= 11?
        cp      11
        jr      c,.cam_east_loopDone

        ld      a,b
        cp      9
        jr      nc,.cam_east_loopDone     ;w_dist < 10?

        ld      a,[camera_i]
        inc     a
        ld      [camera_i],a
        dec     c
        inc     b
        jr      .cam_east_loop

.cam_east_loopDone

        ;---------------Scroll Camera West----------------------------
        ;while(w_dist >= 10 && e_dist<10){
        ;  move camera to west;
        ;   east dist++;
        ;  west dist--;
        ;}
.cam_west_loop
        ld      a,b                 ;w_dist >= 10?
        cp      10
        jr      c,.cam_west_loopDone

        ld      a,c
        cp      9
        jr      nc,.cam_west_loopDone     ;e_dist < 10?

        ld      a,[camera_i]
        dec     a
        ld      [camera_i],a
        inc     c
        dec     b
        jr      .cam_west_loop

.cam_west_loopDone
        ld      a,c                 ;save distances for later use
        ld      [distToWall_E],a
        ld      a,b
        ld      [distToWall_W],a

.done
        pop     hl
        pop     de
        pop     bc
        ret

.moveCameraSouth
        ld      a,[camera_j]
        inc     a
        ld      [camera_j],a
        dec     c
        inc     b
        ret

.moveCameraNorth
        ld      a,[camera_j]
        dec     a
        ld      [camera_j],a
        inc     c
        dec     b
        ret

;---------------------------------------------------------------------
; Routine:      GentleCameraAdjust
; Arguments:    None.
; Description:  Adjusts the camera to the hero but then goes with the
;               old camera position if it doesn't make much difference
;---------------------------------------------------------------------
GentleCameraAdjust::
        ld      a,[displayType]
        or      a
        ret     nz    ;done if cinema display type

        push    bc
        push    de
        push    hl

        ;save previous camera i,j
        ld      a,[camera_i]
        ld      b,a
        ld      a,[camera_j]
        ld      c,a
        push    bc

        call    AdjustCameraToHero

        pop     bc            ;retrieve old camera coords
        ld      a,[camera_i]
        cp      b
        jr      z,.checkCamera_j   ;new_i==old_i, don't bother
        jr      c,.new_i_lt_old_i

        ;new i > old i
        sub     b                   ;d = new_i - old_i
        ld      d,a
        ld      a,[distToWall_E]    ;a = dist_E + offset
        add     d
        cp      11
        jr      c,.useOldCamera_i   ;only good if east dist < 11
        jr      .checkCamera_j

.new_i_lt_old_i
        ;new i < old i
        sub     b                   ;d = old_i - new_i
        cpl
        inc     a
        ld      d,a

        ld      a,[distToWall_W]
        add     d
        cp      9
        jr      c,.useOldCamera_i   ;only good if west dist < 10
        jr      .checkCamera_j

.useOldCamera_i
        ;we can use the old camera pos and be less jerky
        ld      a,b
        ld      [camera_i],a

.checkCamera_j
        ld      a,[camera_j]
        cp      c
        jr      z,.done             ;new_j==old_j, don't bother
        jr      c,.new_j_lt_old_j

        ;new j > old j
        sub     c                   ;d = new_j - old_j
        ld      d,a
        ld      a,[distToWall_S]    ;a = dist_S + offset
        add     d
        cp      10
        jr      c,.useOldCamera_j   ;only good if south dist < 10
        jr      .done

.new_j_lt_old_j
        ;new j < old j
        sub     c                   ;d = old_j - new_j
        cpl
        inc     a
        ld      d,a

        ld      a,[distToWall_N]
        add     d
        cp      9
        jr      c,.useOldCamera_j   ;only good if north dist < 9
        jr      .done

.useOldCamera_j
        ;we can use the old camera pos and be less jerky
        ld      a,c
        ld      [camera_j],a

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      RestrictCameraToBounds
; Arguments:    None.
;---------------------------------------------------------------------
RestrictCameraToBounds::
        ld      a,[displayType]
        or      a
        jr      nz,.cinemaType

        push    hl

        ;set map left/right based on camera_i
        ld      a,[camera_i]
        sub     9
        jr      z,.left_le_0
        jr      nc,.left_gt_0

.left_le_0
        ld      a,1                ;set to 1 if < 1

.left_gt_0
        ld      hl,mapMaxLeft
        cp      [hl]
        jr      z,.left_le_max
        jr      c,.left_le_max

        ld      a,[hl]             ;left = maxLeft

.left_le_max
        ld      [desiredMapLeft],a

        ;now see about top/bottom boundaries using camera_j
        ld      a,[camera_j]
        sub     8
        jr      z,.top_le_0
        jr      nc,.top_gt_0

.top_le_0
        ld      a,1                ;set to one if less than one

.top_gt_0
        ld      hl,mapMaxTop
        cp      [hl]
        jr      z,.top_le_max
        jr      c,.top_le_max

        ld      a,[hl]             ;top = maxTop

.top_le_max
        ld      [desiredMapTop],a

        pop     hl
        ret

.cinemaType
        push    hl

        ;set map left/right based on camera_i
        ld      a,[camera_i]
        sub     9
        jr      z,.left_ge_0
        jr      nc,.left_ge_0

.left_lt_0
        xor     a                  ;set to 0 if < 0

.left_ge_0
        ld      hl,mapMaxLeft
        cp      [hl]
        jr      z,.left_le_max2
        jr      c,.left_le_max2

        ld      a,[hl]             ;left = maxLeft

.left_le_max2
        ld      [desiredMapLeft],a

        ;now see about top/bottom boundaries using camera_j
        ld      a,[camera_j]
        sub     8
        jr      z,.top_ge_0
        jr      nc,.top_ge_0

.top_lt_0
        xor     a                  ;set to zero if less than zero

.top_ge_0
        ld      hl,mapMaxTop
        cp      [hl]
        jr      z,.top_le_max2
        jr      c,.top_le_max2

        ld      a,[hl]             ;top = maxTop

.top_le_max2
        ld      [desiredMapTop],a

        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      ScrollToCamera
; Description:  Scrolls from old camera view to new camera position.
;               Increments of 2 pixels if difference < 4 tiles,
;               increments of 4 pixels if >= 4 tiles
;               Update:  Uses [scrollSpeed][7:4] for fast, [3:0] slow
;                        instead of 4 and 2.
;---------------------------------------------------------------------
ScrollToCamera::
        push    bc
        push    de
        push    hl

        ;calculate tiles different in x & store in d
        ld      a,[mapLeft]
        ld      b,a
        ld      a,[desiredMapLeft]
        sub     b
        jr      nc,.gotPositiveXDiff
        cpl
        inc     a
.gotPositiveXDiff
        ld      d,a

        ;calculate tiles different in y & store in e
        ld      a,[mapTop]
        ld      b,a
        ld      a,[desiredMapTop]
        sub     b
        jr      nc,.gotPositiveYDiff
        cpl
        inc     a
.gotPositiveYDiff
        ld      e,a

        ;setup d,e with x-pixel step-size and max value
        push    de
        ld      a,d
        cp      FAST_SCROLL_THRESHOLD
        jr      c,.setupXForSlow
        ld      a,[scrollAccelState_x]
        or      a
        jr      z,.setupXForSlow

        ;get fast scroll speed in 9
        ldio    a,[scrollSpeed]
        swap    a
        and     $0f
        ld      d,a
        ;ld      a,8
        ;sub     d
        ;ld      e,a
        ;ld      d,4
        ;ld      e,4

        ;ld      a,[desiredPixelOffset_x]  ;make sure its a multiple of 4
        ;and     %00000100
        ;ld      [desiredPixelOffset_x],a

        jr      .checkLeft
.setupXForSlow
        ;get slow scroll speed in d
        ldio    a,[scrollSpeed]
        and     $0f
        ld      d,a

.checkLeft
        ;make sure current pixel offset is an even multiple of the speed
        ;offset &= ~(speed - 1)
        ;off     mask   off  dec  cpl
        ;1 - and %111  0001 0000 1111
        ;2 - and %110  0010 0001 1110
        ;4 - and %100  0100 0011 1100
        ;8 - and %000  1000 0111 1000
        ld      a,d
        dec     a

        ;first scroll sprites right by value to be masked off
        ld      e,a
        ld      hl,desiredPixelOffset_x
        ld      a,[hl]
        and     e
        push    de
        ld      d,a
        call    ScrollSpritesRight
        pop     de
        ld      a,e
        cpl
        and     %00000111
        ld      e,a
        ld      a,[hl]
        and     e
        ld      [hl],a
        ld      a,8
        sub     d
        ld      e,a


        ;ld      a,[desiredPixelOffset_x]  ;make sure its a multiple of 4
        ;and     %00000100
        ;ld      [desiredPixelOffset_x],a

        ld      a,[mapLeft]
        ld      b,a
        ld      a,[desiredMapLeft]
        cp      b
        jr      z,.checkPixelOffset

        jr      c,.desired_lt_current
        jr      .desired_gt_current

.checkPixelOffset
        ld      a,[desiredPixelOffset_x]
        or      a
        jr      z,.x_offsetOkay

        push    af
        ld      a,[scrollSprites]
        or      a
        jr      z,.afterScrollRight1
        call    ScrollSpritesRight
.afterScrollRight1
        pop     af
        jr      .scrollPixelsLeft

.x_offsetOkay
        ;reset accelleration if no scroll
        xor     a
        ld      [scrollAccelState_x],a

        jr      .leftRightAdjustDone

.desired_gt_current
        ;desired is > current
        ld      a,[scrollSprites]
        or      a
        jr      z,.afterScrollSpritesLeft1
        call    ScrollSpritesLeft
.afterScrollSpritesLeft1
        ld      a,[desiredPixelOffset_x]
        cp      e
        jr      nc,.atMaxLeftPixelOffset

        add     d
        ld      [desiredPixelOffset_x],a
        jr      .leftRightAdjustDone

.atMaxLeftPixelOffset
        ld      hl,scrollAccelState_x
        inc     [hl]
        xor     a
        ld      [desiredPixelOffset_x],a
        ld      a,b
        inc     a
        jr      .recalcMapLeftRight

.desired_lt_current
        ld      a,[scrollSprites]
        or      a
        jr      z,.afterScrollSpritesRight2
        call    ScrollSpritesRight
.afterScrollSpritesRight2
        ld      a,[desiredPixelOffset_x]
        or      a
        jr      z,.atMinLeftPixelOffset

.scrollPixelsLeft
        sub     d
        ld      [desiredPixelOffset_x],a

        or      a
        jr      nz,.leftRightAdjustDone
        ld      hl,scrollAccelState_x
        inc     [hl]

        jr      .leftRightAdjustDone

.atMinLeftPixelOffset
        ld      a,e
        ld      [desiredPixelOffset_x],a
        ld      a,b
        dec     a

.recalcMapLeftRight
        ld      hl,mapLeft
        ld      [hl+],a     ;mapLeft, mapRight, mapRight+1
        add     20
        ld      [hl+],a
        inc     a
        ld      [hl+],a

.leftRightAdjustDone
        ;setup d,e with y-pixel step-size and max value
        pop     de
        ld      a,e
        cp      FAST_SCROLL_THRESHOLD
        jr      c,.setupYForSlow
        or      a
        jr      z,.setupYForSlow

        ldio    a,[scrollSpeed]
        swap    a
        and     $0f
        ld      d,a
        ld      a,8
        sub     d
        ld      e,a
        ;ld      d,4
        ;ld      e,4
        ;ld      a,[desiredPixelOffset_y]  ;make sure its a multiple of 4
        ;and     %00000100
        ;ld      [desiredPixelOffset_y],a
        jr      .checkTop
.setupYForSlow
        ldio    a,[scrollSpeed]
        and     $0f
        ld      d,a
        ld      a,8
        sub     d
        ld      e,a
        ;ld      d,2
        ;ld      e,6

.checkTop
        ;make sure current pixel offset is an even multiple of the speed
        ;offset &= ~(speed - 1)
        ;1 - and %111  0001 0000 1111
        ;2 - and %110  0010 0001 1110
        ;4 - and %100  0100 0011 1100
        ;8 - and %000  1000 0111 1000

        ld      a,d
        dec     a

        ;first scroll sprites down by value to be masked off to snap
        ;them to the new grid
        ld      e,a
        ld      hl,desiredPixelOffset_y
        ld      a,[hl]
        and     e
        push    de
        ld      d,a
        call    ScrollSpritesDown
        pop     de
        ld      a,e

        cpl
        and     %00000111
        ld      e,a
        ld      a,[hl]
        and     e
        ld      [hl],a
        ld      a,8
        sub     d
        ld      e,a

        ld      a,[mapTop]
        ld      b,a
        ld      a,[desiredMapTop]
        cp      b
        jr      z,.checkPixelOffsetTB
        jr      c,.desired_tb_lt_current
        jr      .desired_tb_gt_current

.checkPixelOffsetTB
        ld      a,[desiredPixelOffset_y]
        or      a
        jr      z,.y_offsetOkay

        push    af
        ld      a,[scrollSprites]
        or      a
        jr      z,.afterScrollSpritesDown1
        call    ScrollSpritesDown
.afterScrollSpritesDown1
        pop     af
        jr      .scrollPixelsUp

.y_offsetOkay
        ;reset accelleration if no scroll
        xor     a
        ld      [scrollAccelState_y],a

        jr      .topBottomAdjustDone

.desired_tb_gt_current
        ;desired is > current
        ld      a,[scrollSprites]
        or      a
        jr      z,.afterScrollSpritesUp1
        call    ScrollSpritesUp
.afterScrollSpritesUp1
        ld      a,[desiredPixelOffset_y]
        cp      e
        jr      nc,.atMaxTopPixelOffset

        add     d
        ld      [desiredPixelOffset_y],a
        jr      .topBottomAdjustDone

.atMaxTopPixelOffset
        ld      hl,scrollAccelState_y
        inc     [hl]

        xor     a
        ld      [desiredPixelOffset_y],a
        ld      a,b
        inc     a
        jr      .recalcMapTopBottom

.desired_tb_lt_current
        ld      a,[scrollSprites]
        or      a
        jr      z,.afterScrollSpritesDown2
        call    ScrollSpritesDown
.afterScrollSpritesDown2
        ld      a,[desiredPixelOffset_y]
        or      a
        jr      z,.atMinTopPixelOffset

.scrollPixelsUp
        sub     d
        ld      [desiredPixelOffset_y],a

        or      a
        jr      nz,.topBottomAdjustDone
        ld      hl,scrollAccelState_y
        inc     [hl]

        jr      .topBottomAdjustDone

.atMinTopPixelOffset
        ld      a,e
        ld      [desiredPixelOffset_y],a
        ld      a,b
        dec     a

.recalcMapTopBottom
        ld      hl,mapTop
        ld      [hl+],a     ;mapTop, mapBottom, mapBottom+1
        add     18
        ld      [hl+],a
        inc     a
        ld      [hl+],a

.topBottomAdjustDone
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routines:     ScrollSpritesLeft
;               ScrollSpritesRight
;               ScrollSpritesUp
;               ScrollSpritesDown
; Arguments:    d - pixels to scroll
; Alters:       af
; Description:  Scrolls each of the 40 sprites (if their y-pos!=0)
;               "d" # of pixels in the desired direction.
;---------------------------------------------------------------------
ScrollSpritesLeft::
        push    af
        push    bc
        push    de
        push    hl

        xor     a
        sub     d
        ld      d,a
        jr      ScrollSpritesLRCommon

ScrollSpritesRight::
        push    af
        push    bc
        push    de
        push    hl

ScrollSpritesLRCommon:
        ld      hl,spriteOAMBuffer
        ld      bc,3
        ld      e,40

.loop   ld      a,[hl+]
        or      a
        jr      z,.afterChange         ;sprite inactive

        ld      a,[hl]
        add     d
        ld      [hl],a

.afterChange
        add     hl,bc
        dec     e
        jr      nz,.loop

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

ScrollSpritesUp::
        push    af
        push    bc
        push    de
        push    hl

        xor     a
        sub     d
        ld      d,a
        jr      ScrollSpritesUDCommon

ScrollSpritesDown::
        push    af
        push    bc
        push    de
        push    hl

ScrollSpritesUDCommon:
        ld      hl,spriteOAMBuffer
        ld      bc,4
        ld      e,40

.loop   ld      a,[hl]
        or      a
        jr      z,.afterChange         ;sprite inactive

        add     d
        ld      [hl],a

.afterChange
        add     hl,bc
        dec     e
        jr      nz,.loop

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      DrawMapToBackBuffer
; Description:  Sets relevant variables so the map can be drawn
; Note:         Uses [temp] to store tile attributes
;---------------------------------------------------------------------
DrawMapToBackBuffer::
        ld      a,[displayType]
        or      a
        jr      z,.mapType

        jp      DrawCinemaToBackBuffer

.mapType
        push    bc
        push    de
        push    hl

        call    SetupDrawCommon

.outer  push    bc             ;save vertical count "b" on stack
        push    de             ;save starting ptr to dest (hl) and source (de)
        push    hl

;----copy 21 bg tiles into backBuffer/attributeBuffer
        ;save starting point, copy tile pattern numbers
        push    de
        push    hl

        ld      a,MAPBANK
        ld      [$ff70],a
        ld      b,((bgTileMap>>8) & $ff)

        call    .copy7BGTiles
        call    .copy7BGTiles
        call    .copy7BGTiles

        ;start over copying attributes
        pop     hl
        pop     de
        push    de
        push    hl

        ld      a,h       ;backBuffer -> attributeBuffer
        add     3
        ld      h,a
        ld      b,((bgAttributes>>8) & $ff)
        call    .copy7BGAttributes
        call    .copy7BGAttributes
        call    .copy7BGAttributes

        ;back to start again
        pop     hl
        pop     de
        push    de
        push    hl

        ;recopy FG tiles from shadow buffers
        ld      a,TILESHADOWBANK
        ld      [$ff70],a

        ldio    a,[firstMonster]
        ld      b,a

        call    .copy7FGTiles
        call    .copy7FGTiles
        call    .copy7FGTiles

        pop     hl
        pop     de

        ld      a,MAPBANK
        ld      [$ff70],a
        ld      a,h
        add     3
        ld      h,a

        call    .copy7FGAttributes
        call    .copy7FGAttributes
        call    .copy7FGAttributes

        ;row done

;---begin old code 3--------------------------------------------------
IF 0

        ;copy tile patterns & attributes for any BG tiles to ---------
        ;tile & attribute shadow buffers

        ;save starting point
        push    de
        push    hl

        ;use hl for map source / shadow buffer dest
        ld      h,d
        ld      l,e

        ;setup loop
        ld      a,MAPBANK
        ld      [$ff70],a
        ldio    a,[firstMonster]
        ld      b,a
        ld      c,21

.copyBGTiles
        ld      a,[hl]
        cp      b
        jr      c,.isBGTile
        inc     hl
        dec     c
        jr      nz,.copyBGTiles
        jr      .copyBGTilesDone

.isBGTile
        ld      d,((bgTileMap>>8) & $ff)
        ld      e,a
        ld      a,TILESHADOWBANK
        ld      [$ff70],a
        ld      a,[de]
        ld      [hl],a
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      d,((bgAttributes>>8) & $ff)
        ld      a,[de]
        and     %00000111
        ld      [hl+],a
        ld      a,MAPBANK
        ld      [$ff70],a
        dec     c
        jr      nz,.copyBGTiles

.copyBGTilesDone
        ;retrieve starting point & save again
        pop     hl
        pop     de
        push    de
        push    hl

        ;copy set of 21 bytes from TILESHADOWBANK to backBuffer
        ld      a,TILESHADOWBANK
        ld      [$ff70],a
        call    .copy21

        ;retrieve starting point
        pop     hl
        pop     de

        ;copy set of 21 bytes from ATTRSHADOWBANK to backBuffer
        ld      a,h
        add     3
        ld      h,a
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        call    .copy21

ENDC
        ;row done
;----end old code 3---------------------------------------------------


;------begin old code 2-----------------------------------------------
IF 0
        ;copy tile pattern numbers from map/buffer to backBuffer
        ld      a,MAPBANK
        ld      [$ff70],a
        ldio    a,[firstMonster]  ;get index of first fg class
        ld      b,a
        ld      c,21
        push    de
        push    hl

.copyTileNumbers
        ld      a,[de]         ;next class number from map
        cp      b
        jr      nc,.isFGTile

        ;lookup tile used for background
        push    bc
        ld      b,((bgTileMap>>8) & $ff)
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        inc     de
        pop     bc

        dec     c
        jr      nz,.copyTileNumbers
        jr      .setupCopyAttributes

.isFGTile
        ;lookup class number in tile shadow buffer
        ;push    bc
        ld      a,TILESHADOWBANK
        ld      [$ff70],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,MAPBANK
        ld      [$ff70],a
        dec     c
        jr      nz,.copyTileNumbers

.setupCopyAttributes
        pop     hl     ;go back to start of line
        pop     de
        ld      a,h    ;copy to attributeBuffer
        add     3
        ld      h,a
        ld      c,21   ;loop 21 times

.copyAttributes
        ld      a,[de]         ;next class number from map
        cp      b
        jr      nc,.isFGAttribute

        ;BG Attribute
        push    bc
        ld      b,((bgAttributes>>8) & $ff)
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        inc     de
        pop     bc
        dec     c
        jr      nz,.copyAttributes
        jr      .rowDone

.isFGAttribute
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]
        ld      [hl+],a
        inc     de
        ld      a,MAPBANK
        ld      [$ff70],a
        dec     c
        jr      nz,.copyAttributes

.rowDone
ENDC
;------end   old code 2-----------------------------------------------


;old loop code
;-------old code begin------------------------------------------------
IF 0
        ld      a,MAPBANK       ;set RAM bank to the map bank
        ld      [$ff70],a
        ld      c,21           ;times to loop horizontally

.inner  push    bc
        ld      a,[de]         ;load a tile index from level map
        cp      b              ;index of first monster
        jr      c,.isBGTile    ;< first monster

.isFGTile
        ;retrieve FG tile info from shadow buffers parallel to main map
        ld      a,ATTRSHADOWBANK   ;set RAM bank to the attribute shadow bank
        ld      [$ff70],a
        ld      a,[de]             ;attributes
        ldio    [temp],a
        ld      a,TILESHADOWBANK   ;set RAM bank to the tile shadow bank
        ld      [$ff70],a
        ld      a,[de]             ;tile to draw
        inc     de
        ld      [hl],a         ;store tile in backBuffer
        ld      a,MAPBANK       ;set RAM bank to the map bank
        ld      [$ff70],a
        jr      .gotTile

.isBGTile
        inc     de
        or      a
        jr      z,.isNullTile
        ld      c,a
        ;ld      a,TILEINDEXBANK  ;select RAM bank of tile index maps
        ;ld      [$ff70],a
        ld      b,((bgAttributes>>8)&$ff)
        ld      a,[bc]         ;attributes for this tile
        and     %00000111      ;get palette only
        ldio    [temp],a       ;store for later
        ld      b,((bgTileMap>>8)&$ff)  ;get ptr to tile to draw in bc
        ld      a,[bc]         ;get tile to draw
        ld      [hl],a         ;store tile in backBuffer
        jr      .gotTile

.isNullTile
        ld      [temp],a       ;attributes zero
        ld      [hl],a         ;store tile in backBuffer

.gotTile
        push    hl
        ld      a,h
        add     3              ;768 bytes to get from backbuffer to attr buffer
        ld      h,a

        ld      a,[temp]       ;get attributes for this tile
        ld      [hl],a         ;store attribute in buffer

        pop     hl             ;back to map buffer

.afterDrawTile
        inc     hl

        ;inner loop termination test
        pop     bc
        dec     c
        jr      nz,.inner
ENDC
;-------old code end--------------------------------------------------

        pop     hl             ;retrieve initial pointers
        pop     de

        ld      a,[mapPitch]   ;mapPtr += mapPitch
        add     e
        ld      e,a
        jr      nc,.hlNoCarry
        inc     d
.hlNoCarry

        ld      a,32           ;bgTileMapPtr += 32
        add     l
        ld      l,a
        jr      nc,.deNoCarry
        inc     h
.deNoCarry

        ;loop the outer loop again?
        pop     bc
        dec     b
        jr      nz,.outer

        call    PostDrawCommon

.done   ;map is drawn, bitch
        ld      a,MAPBANK       ;set RAM bank to the map bank
        ld      [$ff00+$70],a

        pop     hl
        pop     de
        pop     bc
        ret

.copy7BGTiles
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        ld      [hl+],a
        ret

.copy7BGAttributes
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[bc]
        and     %00000111
        ld      [hl+],a
        ret

.copy7FGTiles
        ld      a,[hl]
        cp      b
        jr      c,.notMonster0
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster0
        inc     hl
        inc     de
        ld      a,[hl]
        cp      b
        jr      c,.notMonster1
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster1
        inc     hl
        inc     de
        ld      a,[hl]
        cp      b
        jr      c,.notMonster2
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster2
        inc     hl
        inc     de
        ld      a,[hl]
        cp      b
        jr      c,.notMonster3
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster3
        inc     hl
        inc     de
        ld      a,[hl]
        cp      b
        jr      c,.notMonster4
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster4
        inc     hl
        inc     de
        ld      a,[hl]
        cp      b
        jr      c,.notMonster5
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster5
        inc     hl
        inc     de
        ld      a,[hl]
        cp      b
        jr      c,.notMonster6
        ld      a,[de]             ;get monster tile
        ld      [hl],a
.notMonster6
        inc     hl
        inc     de
        ret

.copy7FGAttributes
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster0
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster0
        inc     hl
        inc     de
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster1
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster1
        inc     hl
        inc     de
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster2
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster2
        inc     hl
        inc     de
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster3
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster3
        inc     hl
        inc     de
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster4
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster4
        inc     hl
        inc     de
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster5
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster5
        inc     hl
        inc     de
        ld      a,[de]
        cp      b
        jr      c,.fgNotMonster6
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        ld      a,[de]             ;get monster tile
        ld      [hl],a
        ld      a,MAPBANK
        ld      [$ff70],a
.fgNotMonster6
        inc     hl
        inc     de
        ret

IF 0
;loop unrolled for max speed
.copy21
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ret
ENDC

SetupDrawCommon:
        ;set VRAM bank to zero
        ld      a,MAPBANK
        ld      [$ff00+$4f],a

        ;find address to start getting tile indices from
        ld      a,[mapPitchMinusOne]
        ld      c,a
        ld      a,[mapTop]
        ld      e,a
        xor     a

.jTimesPitch
        sla     e       ;times two
        rla             ;carry from low bit into high bit
        srl     c       ;c is pitch-1, counter of how many times to shift
        jr      nz,.jTimesPitch
        ld      d,a     ;high byte into d;  de is now == j * pitch

        ld      a,[mapLeft]
        add     e
        ld      e,a            ;de is now (j*pitch) + i
        ld      hl,map         ;add in base address of map
        add     hl,de
        ld      d,h
        ld      e,l

        ;get memory address of backBuffer in hl
        ld      hl,backBuffer

        ;start looping
        ld      b,19           ;times to loop vertically
        ret

PostDrawCommon:
        ;if the map is scrolled as far as possible right and/or down we
        ;need to clear the right and/or bottom border so the jiggle effect
        ;won't look goofy
        ld      a,[mapMaxLeft]
        ld      b,a
        ld      a,[mapLeft]
        cp      b
        jr      c,.rightBorderOkay

        ;set up vertical loop clearing tiles to zero
        ld      hl,(backBuffer + 20)
        ld      de,32
        ld      c,19
        xor     a

.vloop  ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.vloop

.rightBorderOkay
        ;does bottom border need clearing?
        ld      a,[mapMaxTop]
        ld      b,a
        ld      a,[mapTop]
        cp      b
        jr      c,.done

        ;set up horizontal loop clearing tiles to zero
        ld      hl,(backBuffer + (32*18))
        ld      c,21
        xor     a

.hloop  ld      [hl+],a
        dec     c
        jr      nz,.hloop

.done
        ret


;---------------------------------------------------------------------
; Routine:      DrawCinemaToBackBuffer
; Alters:       af
; Description:  Sets relevant variables so the map can be drawn
; Note:         Uses [temp] to store tile attributes
;---------------------------------------------------------------------
DrawCinemaToBackBuffer::
        push    bc
        push    de
        push    hl

        call    SetupDrawCommon

.outer  push    de             ;save starting ptr to dest (hl) and source (de)
        push    hl
        ld      c,21           ;times to loop horizontally

.inner  push    bc
        ;retrieve tile info from shadow buffers parallel to main map
        ld      a,ATTRSHADOWBANK   ;set RAM bank to the attribute shadow bank
        ld      [$ff70],a
        ld      a,[de]             ;attributes
        ldio    [temp],a
        ld      a,TILESHADOWBANK   ;set RAM bank to the tile shadow bank
        ld      [$ff70],a
        ld      a,[de]             ;tile to draw
        inc     de

        ld      [hl],a         ;store tile in backBuffer
        push    hl
        ld      a,h
        add     3              ;768 bytes to get from backbuffer to attr buffer
        ld      h,a
        ld      a,[temp]       ;get attributes for this tile
        ld      [hl],a         ;store attribute in buffer
        pop     hl             ;back to map buffer
.afterDrawTile
        inc     hl

        ;inner loop termination test
        pop     bc
        dec     c
        jr      nz,.inner

        pop     hl             ;retrieve initial pointers
        pop     de

        ld      a,[mapPitch]   ;mapPtr += mapPitch
        add     e
        ld      e,a
        jr      nc,.hlNoCarry
        inc     d
.hlNoCarry

        ld      a,32           ;bgTileMapPtr += 32
        add     l
        ld      l,a
        jr      nc,.deNoCarry
        inc     h
.deNoCarry

        ;loop the outer loop again?
        dec     b
        jr      nz,.outer

        call    PostDrawCommon

.done   ;map is drawn, bitch
        ld      a,MAPBANK       ;set RAM bank to the map bank
        ld      [$ff00+$70],a

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ShowTitle
; Arguments:    de - pointer to text
; Description:  Shows the text centered on-screen and waits until
;               the user presses a button to continue.
; Alters:       a,hl
;---------------------------------------------------------------------
ShowTitle::
        push    bc

        ld      a,[de]               ;length of text
        inc     de
        ld      c,a
        ld      hl,spriteOAMBuffer+3

.loop
        xor     a                    ;sprite attributes
        ld      [hl-],a
        ld      a,[de]               ;letter
        inc     de
        ld      [hl-],a
        ld      a,16                 ;calculate x coordinate
        sub     c
        sla     a                    ;times 8 for pixels
        sla     a
        sla     a
        ld      [hl-],a              ;y coordinate
        ld      a,80
        ld      [hl],a
        ld      a,l                  ;add 7 to hl
        add     7
        ld      l,a
        ld      a,h
        adc     0
        ld      h,a

        dec     c
        jr      nz,.loop

        pop     bc
        ret

;---------------------------------------------------------------------
; Routines:     SetSpeakerToFirstHero
; Arguments:    None.
; Returns:      c - index of first hero present
;               [dialogSpeakerIndex]
;               [dialogJoyIndex]
; Alters:       af, c
; Description:  Finds the first hero on the map and sets up
;               some dialog parameters based on who it is.
;---------------------------------------------------------------------
SetSpeakerToFirstHero::
        push    de
        push    hl
        xor     a
        ld      hl,hero0_index
        call    .setParameters
        or      a
        jr      nz,.done

        ld      a,1
        ld      hl,hero1_index
        call    .setParameters

.done
        pop     hl
        pop     de
        ret

.setParameters
        ld      [dialogJoyIndex],a
        ld      a,[hl-]        ;get hero index
        or      a              ;non-zero?
        ret     z              ;not present

        ld      c,a            ;class index
        ld      de,HERODATA_TYPE
        add     hl,de
        ld      a,[hl]
        ld      [dialogSpeakerIndex],a   ;flag indicating speaker
        ld      a,1            ;operation successful
        ret

;---------------------------------------------------------------------
; Routines:     SetSpeakerFromHeroIndex
; Arguments:    c - index of speaking hero
; Returns:      [dialogSpeakerIndex]
;               [dialogJoyIndex]
; Alters:       af
; Description:
;---------------------------------------------------------------------
SetSpeakerFromHeroIndex::
        push    de
        push    hl

        ld      hl,hero0_index
        ld      a,[hl-]
        cp      c
        ld      a,0
        jr      nz,.setHero1

        call    .setParameters
        jr      .done

.setHero1
        ld      a,1
        ld      hl,hero1_data
        call    .setParameters

.done
        pop     hl
        pop     de
        ret

.setParameters
        ld      [dialogJoyIndex],a
        ld      de,HERODATA_TYPE
        add     hl,de
        ld      a,[hl]
        ld      [dialogSpeakerIndex],a   ;flag indicating speaker
        ret


;---------------------------------------------------------------------
; Routine:      SetPressBDialog
;---------------------------------------------------------------------
SetPressBDialog:
        ld      a,DLG_BORDER | DLG_PRESSB
        ld      [dialogSettings],a
        ret

;---------------------------------------------------------------------
; Routine:      SetDialogJoy::
; Arguments:    None.
; Returns:      hl - pointer to appropriate joy inputs
; Alters:       af,hl
;---------------------------------------------------------------------
SetDialogJoy::
        ld      a,[displayType]
        cp      1
        jr      z,.cinemaType
        ld      a,[canJoinMap]
        cp      2                  ;asynchronous join?
        jr      z,.cinemaType

        ld      hl,curInput0
        ld      a,[dialogJoyIndex]
        or      a
        ret     z
        inc     hl
        ret

.cinemaType
        ld      hl,myJoy
        ret

;---------------------------------------------------------------------
; Routine:      CheckDialogContinue
; Arguments:    None.
; Returns:      a  - 1 if done (B is pressed), 0 if not done
; Alters:       af
; Description:  Calls CheckDialogSkip and then sees if button B of
;               the speaker's joystick is pressed.
;---------------------------------------------------------------------
CheckDialogContinue::
        push    hl
        call    CheckSkip

        call    SetDialogJoy

        ld      a,[dialogSettings]
        and     DLG_WAITRELEASE
        jr      nz,.waitRelease

        ld      a,[hl]
        and     JOY_B
        jr      z,.returnFalse

        ld      hl,dialogSettings
        set     DLG_WAITRELEASE_BIT,[hl]
        jr      .returnFalse

.waitRelease
        ld      a,[hl]
        and     JOY_B
        jr      nz,.returnFalse

        ld      hl,dialogSettings
        res     DLG_WAITRELEASE_BIT,[hl]

        bit     DLG_CLEARSKIP_BIT,[hl]
        jr      z,.afterClearSkip

        res     DLG_CLEARSKIP_BIT,[hl]
        push    hl
        ld      de,0
        call    SetDialogSkip
        pop     hl

.afterClearSkip
        bit     DLG_NOCLEAR_BIT,[hl]
        res     DLG_NOCLEAR_BIT,[hl]
        jr      nz,.returnTrue

        call    ClearDialog

.returnTrue
        ld      a,1
        jr      .done


.returnFalse
        xor     a
.done
        pop     hl
        ret

;---------------------------------------------------------------------
; Routines:     ShowDialogAtTop
;               ShowDialogAtTopNoWait
;               ShowDialogAtBottom
;               ShowDialogAtBottomNoWait
;               ClearDialog
; Arguments:    [dialogBank] - bank containing text
;               c  - class index of speaking character
;               de - pointer to gtx text
; Description:  Shows the text centered at the top or bottom dialog
;               bar & waits until the user presses a button to
;               continue.
; Alters:       none
; Note:         Format of gtx:
;               BYTE  number of lines
;               REPT[nLines]:
;                 BYTE  spaces to center
;                 BYTE  num chars in line
;                 BYTE[nChars] characters
;---------------------------------------------------------------------
ShowDialogNPC::
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        call    ShowDialogAtTop
        call    ClearDialog
        ret

ShowDialogHero::
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom
        call    ClearDialog
        ret

ShowDialogAtTop::
        ld      a,[dialogBank]
        push    af
        push    bc
        push    de
        push    hl

        call    ChooseFromDialogAlternates

        ld      b,0            ;lines to skip at top
        call    ShowDialogCommon
        call    ShowDialogAtTopCommon
        call    ShowDialogWait

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

ShowDialogAtTopNoWait::
        ld      a,[dialogBank]
        push    af
        push    bc
        push    de
        push    hl

        call    ChooseFromDialogAlternates

        ld      b,0            ;lines to skip at top
        call    ShowDialogCommon
        call    ShowDialogAtTopCommon

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

ShowDialogAtTopCommon::
        call    DrawDialogBorderAtBottom
        call    GfxBlitBackBufferToWindow

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

        ld      a,OBJROM
        call    SetActiveROM
        ret

ShowDialogAtBottom::
        ld      a,[dialogBank]
        push    af
        push    bc
        push    de
        push    hl

        call    ChooseFromDialogAlternates

        ld      b,1            ;lines to skip at top
        call    ShowDialogCommon
        call    ShowDialogAtBottomCommon
        call    ShowDialogWait

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

ShowDialogAtBottomNoWait::
        ld      a,[dialogBank]
        push    af
        push    bc
        push    de
        push    hl

        call    ChooseFromDialogAlternates

        ld      b,1            ;lines to skip at top
        call    ShowDialogCommon
        call    ShowDialogAtBottomCommon

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

ShowDialogAtBottomCommon::
        call    DrawDialogBorderAtTop
        call    GfxBlitBackBufferToWindow

        ld      a,143
        ld      [hblankWinOff],a

        ;set window y pos.  Req'd for actual GBC, not emulator
        ld      a,[de]         ;# lines
        cpl
        add     1+17           ;(max lines) - (text lines+1)
        rlca
        rlca
        rlca                   ;times 8
        ldh     [$ff4a], a     ;set window y position

        ld      a,[de]         ;number of lines
        rlca                   ;times 8 = pixels for window
        rlca
        rlca
        add     8
        cpl                    ;make negative (+1), subtract from 143
         add     144            ;+1 2's compl, +143
        ld      [hblankWinOn],a

        ld      a,[hblankFlag]
        bit     1,a
        jr      nz,.afterSetLYC

        ld      a,[hblankWinOn]
        ld      [$ff45],a            ;lyc
        ld      a,[hblankFlag]

.afterSetLYC
        or      %10               ;allow window to show
        ld      [hblankFlag],a

        ld      a,OBJROM
        call    SetActiveROM
        ret

ClearDialog::
        push    af
        xor     a
        ld      [amShowingDialog],a

        ld      a,[hblankFlag]   ;turn off dialog box and window
        and     %11111101
        ld      [hblankFlag],a
        call    VWait
        ;call    InstallGamePalette
        ld      a,1
        ldio    [paletteBufferReady],a
        call    VWait
        pop     af
        ret

ShowDialogWait::
        ;change both heroes to idle
        ld      a,[heroesIdle]
        push    af
        ld      a,1
        ld      [heroesIdle],a

        call    .waitInputZero

.wait
        call    UpdateObjects
        call    RedrawMap
        call    CheckDialogContinue
        or      a
        jr      z,.wait

        ;call    .waitInput
        ;call    .waitInputZero

        pop     af
        ld      [heroesIdle],a

        ret

.waitInputZero
DialogWaitInputZero::
        call    UpdateObjects
        call    RedrawMap
        ld      h,((curInput0>>8) & $ff)
        ld      a,[dialogJoyIndex]
        add     (curInput0 & $ff)
        ld      l,a
        ld      a,[hl]
        and     %11110000
        jr      nz,DialogWaitInputZero
        ret


;---------------------------------------------------------------------
; Routines:     ShowDialogCommon
; Arguments:    a  - bank message is in
;               b  - lines to skip at top
;               c  - class index of speaking character
;               de - pointer to gtx text beginning with #lines
; Description:
; Alters:       af
; Note:         Format of gtx:
;               BYTE  number of lines
;               REPT[nLines]:
;                 BYTE  spaces to center
;                 BYTE  num chars in line
;                 BYTE[nChars] characters
;---------------------------------------------------------------------
ShowDialogCommon::
        push    de
        push    bc            ;save class index of speaking character

        call    SetActiveROM

        ld      a,1
        ld      [amShowingDialog],a

        ;wait until the backbuffer is blitted
.waitBackBuffer
        ldio    a,[backBufferReady]
        or      a
        jr      z,.canMessWithBackBuffer

        call    VWait
        jr      .waitBackBuffer

.canMessWithBackBuffer
        ;clear the backbuffer and attribute buffer for given #lines
        ld      a,[de]        ;b = number of lines + 1
        add     1
        ld      b,a
        ld      hl,backBuffer

.clearLines
        call    ClearGTXLine
        push    bc
        ld      bc,32
        add     hl,bc
        pop     bc
        dec     b
        jr      nz,.clearLines
        ;xor     a
;.outer1 ld      c,32
;.inner1 ld      [hl+],a
        ;dec     c
        ;jr      nz,.inner1
        ;dec     b
        ;jr      nz,.outer1

        ;ld      a,[de]        ;b = number of lines + 1
        ;add     1
        ;ld      b,a
        ;ld      hl,attributeBuffer
        ;xor     a
;.outer2 ld      c,32
;.inner2 ld      [hl+],a
        ;dec     c
        ;jr      nz,.inner2
        ;dec     b
        ;jr      nz,.outer2

        ;adjust hl down a line?
        pop     bc
        push    bc
        ld      hl,backBuffer
        bit     0,b
        jr      z,.hlOkay
        ld      bc,32
        add     hl,bc
.hlOkay

        ;for each line of text...
        ld      a,[de]        ;b = number of lines
        inc     de
        ld      b,a

.line
        call    WriteGTXLine

        ;go to next line
        dec     b
        jr      nz,.line

        ;retrieve class index of speaking character and
        ;blit that tile to the top-left corner of the buffer
        pop     bc
        call    DrawTileToTLCorner
        ;call    GfxBlitBackBufferToWindow
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      ClearGTXLine
; Arguments:
;               hl - backbuffer location to draw at
; Alters:       af
;---------------------------------------------------------------------
ClearGTXLine::
        push    bc
        push    hl

        push    hl

        ;clear backbuffer
        xor     a
        ld      c,32
.loop   ld      [hl+],a
        dec     c
        jr      nz,.loop

        ;clear attr buffer
        xor     a
        pop     hl
        ld      bc,$300
        add     hl,bc
        ld      c,32
.loop2  ld      [hl+],a
        dec     c
        jr      nz,.loop2

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      WriteGTXLine
; Arguments:    de - pointer to gtx text beginning with centerSpaces
;               hl - location to draw at
; Alters:       hl,de
;---------------------------------------------------------------------
WriteGTXLine::
        ;advance hl spaces required to center text
        push    bc
        ld      b,0
        ld      a,[de]
        inc     de
        ld      c,a
        add     hl,bc

        ;get the char count for this line
        ld      a,[de]
        inc     de
        ld      c,a
        or      a
        jr      z,.afterLoop

        ;copy the characters to the buffer
.loop   ld      a,[de]
        inc     de
        ld      [hl+],a
        dec     c
        jr      nz,.loop

.afterLoop
        ;advance hl to next line
        ld      a,l
        and     ~31
        add     32
        ld      l,a
        ld      a,0
        adc     h
        ld      h,a

        pop     bc
        ret


GfxBlitBackBufferToWindow::
        ;xor     a
        ;ld      c,38     ;38*16 = 608
        ;ld      de,$9c00  ;dest = window map memory
        ;ld      hl,$c000  ;source
        ;call    VMemCopy
        ;ret

        ld      a,$9c            ;copy to window map memory
        ldio    [backBufferDestHighByte],a
        ld      a,1
        ldio    [backBufferReady],a
.vwait  call    VWait
        ldio    a,[backBufferReady]  ;wait until buffer is copied
        or      a
        jr      nz,.vwait
        ld      a,$98            ;go back to copying to bg map memory
        ldio    [backBufferDestHighByte],a
        ret

GfxShowStandardTextBox::
        ;set interrupt to turn window off at bottom of screen
        ld      a,143
        ld      [hblankWinOff],a

        ;set window y pos.  Req'd for actual GBC, not emulator
        ld      a,96
        ldh     [$ff4a], a     ;set window y position
        ld      [hblankWinOn],a

        ld      a,[hblankFlag]
        bit     1,a
        jr      nz,.afterSetLYC

        ld      a,[hblankWinOn]
        ld      [$ff45],a            ;lyc
        ld      a,[hblankFlag]

.afterSetLYC
        or      %10               ;allow window to show
        ld      [hblankFlag],a
        ret

DrawDialogBorderAtTop:
        push    hl
        ld      hl,$c000   ;9c00
        call    DrawDialogBorder
        pop     hl
        ret

DrawDialogBorderAtBottom:
        push    de
        push    hl
        ld      hl,$c000   ;9c00
        ld      a,[de]     ;num lines
        ld      d,a
        xor     a
        srl     d
        rra
        srl     d
        rra
        srl     d
        rra
        ld      e,a
        add     hl,de
        call    DrawDialogBorder
        pop     hl
        pop     de
        ret

DrawDialogBorder:
        push    bc
        push    hl

        ld      a,[dialogSettings]
        and     DLG_BORDER
        jr      z,.done

        ;draw border at edge
        push    hl

        ;xor     a
        ;ldio    [$ff4f],a   ;VRAM bank

        ld      c,20
        ld      a,252
.drawBorder
        ld      [hl+],a
        dec     c
        jr      nz,.drawBorder

        dec     hl
        ld      a,[dialogSettings]
        and     DLG_PRESSB
        jr      z,.clearBG

        ld      [hl],253

.clearBG
        pop     hl

        ;clear bg attributes
        ld      bc,$300
        add     hl,bc

        ;ld      a,1
        ;ldio    [$ff4f],a   ;VRAM bank

        ld      c,20
        xor     a
.clearBGLoop
        ld      [hl+],a
        dec     c
        jr      nz,.clearBGLoop

.done
        pop     hl
        pop     bc
        ret

DrawTileToTLCorner:    ;class index in c, 1 line down in b
.drawTile
        ld      hl,backBuffer
        bit     0,b
        jr      z,.hlOkay
        ld      l,32
.hlOkay
        ld      a,c
        or      a
        jr      z,.useNullTile  ;use null tile

        ld      a,TILEINDEXBANK
        ld      [$ff70],a

        ld      b,((fgAttributes>>8) & $ff)
        ld      a,[bc]
        bit     5,a    ;2x2 monster?
        jr      nz,.speaker2x2

        and     %00000111
        or      %00001000        ;coming from bank 1
        ld      h,((attributeBuffer>>8) & $ff)
        ld      [hl],a

        ld      h,((backBuffer>>8) & $ff)
        ld      b,((fgTileMap>>8) & $ff)
        ld      a,[bc]           ;a is tile to draw
        add     3                ;get right-facing
        ld      [hl],a

        ret

.speaker2x2
        and     %00000111        ;color
        or      %00001000        ;coming from bank 1
        push    hl
        push    hl
        ld      h,((attributeBuffer>>8) & $ff)
        ld      [hl+],a
        ld      [hl+],a
        push    de
        ld      de,30
        add     hl,de
        pop     de
        ld      [hl+],a
        ld      [hl-],a

        ld      h,((backBuffer>>8) & $ff)
        ld      b,((fgTileMap>>8) & $ff)
        ld      a,[bc]           ;a is tile to draw
        add     12               ;get right-facing
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        pop     hl
        sub     3
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        pop     hl

        ;kludge for two-color BRAINIAC
        ld      a,[dialogSettings]
        bit     DLG_BRAINIAC_BIT,a
        ret     z

        res     DLG_BRAINIAC_BIT,a
        ld      [dialogSettings],a
        ld      h,((attributeBuffer>>8) & $ff)
        inc     hl
        ld      a,8+3   ;green color from bank 1
        ld      [hl],a
        push    de
        ld      de,32
        add     hl,de
        pop     de
        ld      [hl+],a

        ret


.useNullTile
        xor     a
        ld      [hl],a
        ld      h,((attributeBuffer>>8) & $ff)
        ld      [hl],a
        ret

;---------------------------------------------------------------------
; Routine:      ChooseFromDialogAlternates
; Arguments:    de - pointer to gtx text
; Returns:      de - adjusted pointer
; Alters:       de
; Description:  de points to start of an indeterminate number of
;               byte triplets of the form:
;                 [mask] [offsetL] [offsetH]
;               This routine finds a mask that (when ANDed) matches
;               the value in [dialogSpeakerIndex] and jumps to the
;               gtx alternate beginning at the given offset.  The
;               offset given for the cursor being at a position of
;               1 past [offsetH] of the matching triplet.
;---------------------------------------------------------------------
ChooseFromDialogAlternates:
        push    af
        push    bc
        push    hl

        call    SetActiveROM

        ld      h,d
        ld      l,e

        ld      a,[dialogSpeakerIndex]
        ld      c,a

.attemptMatch
        ld      a,[hl+]   ;mask
        and     c
        jr      nz,.foundMatch

        inc     hl        ;skip offset to look at next mask
        inc     hl
        jr      .attemptMatch

.foundMatch
        ld      a,[hl+]   ;retrieve offset to start of gtx proper
        ld      e,a
        ld      a,[hl+]
        ld      d,a
        add     hl,de

        ld      d,h
        ld      e,l

        pop     hl
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      CheckSkip
; Arguments:    None.
; Returns:      Nothing.
; Alters:       af
; Description:  Intended for use in cinemas and in-game dialog,
;               resets the pc and sp to an address set with
;               SetDialogSkip.  Sets to the skip address if start is
;               pushed, to fast-forward address if B is pushed.
;---------------------------------------------------------------------
CheckSkip::
        push    hl

        ld      a,[displayType]
        cp      1
        jr      z,.cinemaType
        ld      a,[canJoinMap]   ;asynchronous join?
        cp      2
        jr      z,.cinemaType

        ld      hl,curInput0
        ld      a,[dialogJoyIndex]   ;0 or 1
        add     l
        ld      l,a
        jr      .afterSetJoy

.cinemaType
        ld      hl,myJoy

.afterSetJoy
        ld      a,[hl]               ;get the input
        and     JOY_START
        jr      nz,.startPressed

        ld      a,[hl]
        and     JOY_B
        jr      z,.done     ;no buttons pushed

.abPressed
        push    hl
        ld      hl,levelCheckSkip    ;fast forward address
        jr      .restore

.startPressed
        push    hl
        ld      hl,levelCheckSkip+2  ;skip address

.restore
        ld      a,[hl]
        or      a
        jr      nz,.addressOkay
        inc     hl
        ld      a,[hl-]
        or      a
        jr      nz,.addressOkay

        pop     hl
        jr      .done

.addressOkay
        ;make the class/object ROM the current
        ld      a,OBJROM
        call    SetActiveROM
        xor     a
        ld      e,[hl]
        ld      [hl],a
        inc     hl
        ld      d,[hl]
        ld      [hl],a
        pop     hl
        cp      d
        jr      nz,.addrOkay
        cp      e
        jr      z,.done   ;null address

.addrOkay
        ld      a,$f0
        call    WaitInputZero

        ;reset all one-shot dialog options
        ld      hl,dialogSettings
        res     DLG_BRAINIAC_BIT,[hl]
        res     DLG_NOCLEAR_BIT,[hl]
        res     DLG_CLEARSKIP_BIT,[hl]

        ;restore stack pointer
        ld      a,[levelCheckStackPos]
        ld      l,a
        ld      a,[levelCheckStackPos+1]
        ld      h,a
        ld      sp,hl

        ;push return address on stack and go there
        push    de
        ret

.done
        pop     hl
        ret


;---------------------------------------------------------------------
; Routine:      Delay
; Arguments:    a  - number of 1/60 seconds to delay
; Alters:       af
; Description:  Updates and displays objects for specified number of
;               1/60 seconds.  Jumps to [levelCheckSkip] if start
;               button is pressed if addr is non-null.
;---------------------------------------------------------------------
Delay::
        push    bc
        push    de
        push    hl


.delay  push    af
        call    UpdateObjects
        call    RedrawMap

        call    CheckSkip
.keepGoing
        pop     af
        dec     a
        jr      nz,.delay

.waitBlit
        ldio    a,[backBufferReady]
        or      a
        jr      nz,.waitBlit

        ;if we're in a cinema and we get a YANK from the remote player
        ;then we need to kill into the cinema script
        ld      a,[timeToChangeLevel]
        or      a
        jr      z,.done

        ld      a,[inLoadMethod]
        or      a
        jr      z,.done

        call    BlackoutPalette
        ld      a,[loadStackPosL]
        ld      l,a
        ld      a,[loadStackPosH]
        ld      h,a
        ld      sp,hl
        jp      AfterLoadLevelMethod

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetRandomNumZeroToN
; Arguments:    a  - maximum desired random number "N"
; Returns:      a  - random number between 0 and N
; Alters:       af
;---------------------------------------------------------------------
GetRandomNumZeroToN::
        or      a
        ret     z

        push    bc
        push    hl

        inc     a
        jr      z,.handleFF
        ld      b,a        ;b is N

        PUSHROM
        ld      a,BANK(randomTable)
        call    SetActiveROM

        ld      hl,randomLoc
        inc     [hl]
        ld      l,[hl]
        ld      h,((randomTable>>8) & $ff)

        ld      a,[hl]
        bit     7,b
        jr      nz,.loop     ;N+1>=128

        ;divide raw number by two until it's less than limit*2
        ld      c,b
        sla     c            ;c = (limit * 2) + 1
        inc     c
.fastReduce
        cp      c            ;a < limit*2 + 1?
        jr      c,.loop      ;yes, go to slower precision work
        srl     a            ;a/=2
        jr      .fastReduce

.loop   cp      b            ;subtract N while r > N
        jr      c,.done
        sub     b
        jr      .loop

.done
        ld      b,a
        POPROM
        ld      a,b
        pop     hl
        pop     bc
        ret

.handleFF
        PUSHROM
        ld      a,BANK(randomTable)
        call    SetActiveROM

        ld      hl,randomLoc
        inc     [hl]
        ld      l,[hl]
        ld      h,((randomTable>>8) & $ff)

        ld      a,[hl]
        ld      b,a
        POPROM
        ld      a,b
        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      GetRandomNumMask
; Arguments:    a  - bit mask for random number
; Returns:      a  - random number
; Alters:       af
;---------------------------------------------------------------------
GetRandomNumMask::
        push    bc
        push    hl

        ld      b,a          ;b is bitmask

        PUSHROM
        ld      a,BANK(randomTable)
        call    SetActiveROM

        ld      hl,randomLoc
        inc     [hl]
        ld      l,[hl]
        ld      h,((randomTable>>8) & $ff)

        ld      a,[hl]
        and     b

.done
        ld      b,a
        POPROM
        ld      a,b
        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeFromWhite
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeFromWhite::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set cur palette to be all white
        ld      hl,fadeCurPalette
        call    FadeCommonSetPaletteToWhite

        ;set final palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

FadeCommonSetPaletteToWhite::
        ld      c,64
.loop
        ld      a,$ff
        ld      [hl+],a
        ld      a,$7f
        ld      [hl+],a
        dec     c
        jr      nz,.loop
        ret

CopyPalette64::
FadeCommonCopyPalette::
        push    bc
        push    de
        push    hl
        ld      a,FADEBANK
        ld      [$ff70],a
        ld      c,128
.loop   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop
        pop     hl
        pop     de
        pop     bc
        ret

CopyPalette32::
        push    bc
        push    de
        push    hl
        ld      a,FADEBANK
        ld      [$ff70],a
        ld      c,64
.loop   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      InstallGamePalette
; Arguments:    None.
; Alters:       af
; Description:  Sets gamePalette to be installed to the hardware
;               on the next VBlank.
;---------------------------------------------------------------------
InstallGamePalette::
        push    hl
        push    de
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      a,1
        ldio    [paletteBufferReady],a
.wait
        ldio    a,[paletteBufferReady]  ;wait for vblank to install it
        or      a
        jr      nz,.wait

        pop     de
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeToWhite
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeToWhite::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set final palette to be all white
        ld      hl,fadeFinalPalette
        call    FadeCommonSetPaletteToWhite

        ;set cur palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeFromBlack
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeFromStandard::
SetupFadeFromBlack::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set cur palette to be all white
        ld      hl,fadeCurPalette
        call    FadeCommonSetPaletteToBlack

        ;set final palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeToBlack
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeToStandard::
SetupFadeToBlack::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set final palette to be all black
        ld      hl,fadeFinalPalette
        call    FadeCommonSetPaletteToBlack

        ;set cur palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

FadeCommonSetPaletteToBlack::
        ld      c,64
        xor     a
.loop
        ld      [hl+],a
        ld      [hl+],a
        dec     c
        jr      nz,.loop
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeFromBlackBGOnly
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeFromBlackBGOnly::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        ;set cur palette to be all black
        ld      hl,fadeCurPalette
        call    FadeCommonSetPaletteToBlackBGOnly

        ;set final palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ld      a,32
        ld      [fadeRange],a

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      BlackoutPalette
; Arguments:
; Alters:       af
; Description:  Sets fadeCurPalette and final palette to all black
;---------------------------------------------------------------------
BlackoutPalette::
        push    bc
        push    de
        push    hl

        ld      a,FADEBANK
        ld      [$ff70],a

        ld      hl,fadeFinalPalette
        call    FadeCommonSetPaletteToBlack

        ld      hl,fadeCurPalette
        call    FadeCommonSetPaletteToBlack

        ;turn off any existing fade
        ld      hl,specialFX
        res     0,[hl]        ;reset fade bit

        ;install the current palette on the next VBlank
        ld      a,1
        ldio    [paletteBufferReady],a
.wait
        ldio    a,[paletteBufferReady]  ;wait for vblank to install it
        or      a
        jr      nz,.wait

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeToBlackBGOnly
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeToBlackBGOnly::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ;set final palette BG Colors to be all black
        ld      hl,fadeFinalPalette
        call    FadeCommonSetPaletteToBlackBGOnly

        ;set cur palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        ld      a,32
        ld      [fadeRange],a

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

FadeCommonSetPaletteToBlackBGOnly::
        ld      c,32
        xor     a
.loop
        ld      [hl+],a
        ld      [hl+],a
        dec     c
        jr      nz,.loop
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeFromSaturated
; Arguments:    a  - steps
;               b  - amount of saturation (white) to start at
; Alters:       af
;---------------------------------------------------------------------
SetupFadeFromSaturated::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;copy game palette to starting palette and ending palette
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        ld      l,b    ;saturation

        ;add saturation to each color
        ld      h,64
.setup  call    FadeCommonGetColor
        dec     de
        dec     de
        call    GetRedComponent
        call    .saturate
        call    SetRedComponent
        call    GetGreenComponent
        call    .saturate
        call    SetGreenComponent
        call    GetBlueComponent
        call    .saturate
        call    SetBlueComponent

        ;save color
        ld      a,c
        ld      [de],a
        inc     de
        ld      a,b
        ld      [de],a
        inc     de

        dec     h
        jr      nz,.setup

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

.saturate
        add     l
        bit     7,l
        jr      nz,.satneg
        cp      32           ;over the limit?
        ret     c

        ld      a,$1f
        ret

.satneg
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeToGamePalette
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeToGamePalette::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set final palette to be current game palette
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetupFadeToHalfbrite
; Arguments:    a - steps
; Alters:       af
;---------------------------------------------------------------------
SetupFadeToHalfbrite::
        push    bc
        push    de
        push    hl

        push    af

        ld      a,FADEBANK
        ld      [$ff70],a

        ;set final palette to be halfbrite game palette
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        ld      c,64
.copyHalfbrite
        push    bc
        ld      a,[hl+]
        ld      c,a
        ld      a,[hl-]
        ld      b,a
        call    GetRedComponent
        srl     a
        call    SetRedComponent
        call    GetGreenComponent
        srl     a
        call    SetGreenComponent
        call    GetBlueComponent
        srl     a
        call    SetBlueComponent
        ld      a,c
        ld      [hl+],a
        ld      a,b
        ld      [hl+],a
        pop     bc
        dec     c
        jr      nz,.copyHalfbrite

        ;set cur palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        pop     af
        call    FadeInit

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FadeCommonGetColor
; Arguments:    de - ptr to next color
; Returns:      bc - next color
; Alters:       af,de
;---------------------------------------------------------------------
FadeCommonGetColor:
        ld      a,[de]
        inc     de
        ld      c,a
        ld      a,[de]
        inc     de
        ld      b,a
        ret

;---------------------------------------------------------------------
; Routine:      FadeInit
; Arguments:    a - number of steps
;               [fadeCurPalette], [fadeFinalPalette] already setup
;               with palettes to fade between
; Alters:       af
; Description:  Sets up and uses fadeDelta[32*3]
;               and fadeError[32*3].
;               FadeStep must then be called every vblank until
;               [specialFX:0] becomes zero.
;---------------------------------------------------------------------
FadeInit::
        push    bc
        push    de
        push    hl

        ld      [fadeSteps],a
        ld      [fadeStepsToGo],a

        ld      a,FADEBANK
        ld      [$ff70],a

        ;for each color component, difference is (c2-c1)
        ;subtract each element of fadeCurPalette from fadeFinalPalette
        ;and store separate RGB offsets in fadeDelta.
        ;fadeCurPalette RGB elements in fadeCurRGB.

        ;clear out fadeError and fadeDelta
        ld      hl,fadeError
        ld      de,fadeDelta
        ld      c,192
        xor     a
.clearError
        ld      [hl+],a
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.clearError

        ;begin by storing each color component of each color in
        ;fadeCurPalette into fadeDelta
        ld      a,64
        ld      hl,fadeDelta
        ld      de,fadeCurPalette

.copyCurToDelta
        push    af
        call    FadeCommonGetColor
        call    GetRedComponent
        ld      [hl+],a
        call    GetGreenComponent
        ld      [hl+],a
        call    GetBlueComponent
        ld      [hl+],a
        pop     af
        dec     a
        jr      nz,.copyCurToDelta

        ;copy fadeDelta[192] to fadeCurRGB[192].
        ;ld      hl,fadeDelta
        ;ld      de,fadeCurRGB
        ;ld      c,192
;.copyToCurRGB
        ;ld      a,[hl+]
        ;ld      [de],a
        ;inc     de
        ;dec     c
        ;jr      nz,.copyToCurRGB

        ;fadeDelta[...] = fadeFinalPalette[...] - fadeDelta[...]
        ld      a,64
        ld      hl,fadeDelta
        ld      de,fadeFinalPalette

.findStep
        push    af
        call    FadeCommonGetColor
        call    GetRedComponent
        sub     [hl]
        ld      [hl+],a
        call    GetGreenComponent
        sub     [hl]
        ld      [hl+],a
        call    GetBlueComponent
        sub     [hl]
        ld      [hl+],a
        pop     af
        dec     a
        jr      nz,.findStep


        ;indicate we've got a fade goin on
        ld      a,FX_FADE
        ld      [specialFX],a

        pop     hl
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      FadeStep
; Alters:       af
; Description:  Peforms the next step of the fade in progress.
;               Should only be called if [specialFX] & FX_FADE is 1.
;               fadeRange is reset to 64 afterwards.
;---------------------------------------------------------------------
FadeStep::
        push    bc
        push    de
        push    hl

.waitReady
        ldio    a,[paletteBufferReady]  ;wait for vblank
        or      a
        jr      nz,.waitReady

        ;loop 64 times, adding the fade delta for each component
        ;to the error.  If error >= 32:
        ;  error -= 32;
        ;  increment component;
        ;Then flag the newly created palette to be displayed
        ld      a,FADEBANK
        ld      [$ff70],a

        ld      a,[fadeStepsToGo]
        dec     a
        ld      [fadeStepsToGo],a
        jr      z,.lastFade

        ;ld      c,64
        ;ld      hl,fadeError
        ;ld      de,fadeCurRGB
;
;.fadeInner
        ;ld      a,[de]     ;red component
        ;call    .addDeltaToError
        ;ld      [de],a
        ;inc     de
;
        ;ld      a,[de]     ;green component
        ;call    .addDeltaToError
        ;ld      [de],a
        ;inc     de

        ;ld      a,[de]     ;blue component
        ;call    .addDeltaToError
        ;ld      [de],a
        ;inc     de
        ;;dec     c
        ;jr      nz,.fadeInner

        ;copy RGB palette to 15-bit palette
        ;ld      a,64
        ;ld      bc,0
        ;ld      hl,fadeCurRGB
        ;ld      de,fadeCurPalette
;.RGBtoCur
        ;push    af
        ;ld      a,[hl+]
        ;call    SetRedComponent
        ;ld      a,[hl+]
        ;call    SetGreenComponent
        ;ld      a,[hl+]
        ;call    SetBlueComponent
        ;ld      a,c
        ;ld      [de],a
        ;inc     de
        ;ld      a,b
        ;ld      [de],a
        ;inc     de
        ;pop     af
        ;dec     a
        ;jr      nz,.RGBtoCur


        ld      a,[fadeRange]
        ld      hl,fadeError
        ld      de,fadeCurPalette

.fadeInner
        push    af

        ;get current color in bc, though keep de where it was
        call    FadeCommonGetColor
        dec     de
        dec     de

        call    GetRedComponent
        call    .addDeltaToError
        call    SetRedComponent       ;store component

        call    GetGreenComponent
        call    .addDeltaToError
        call    SetGreenComponent     ;store component

        call    GetBlueComponent
        call    .addDeltaToError
        call    SetBlueComponent      ;store component

        ;store back in cur table
        ld      a,c
        ld      [de],a
        inc     de
        ld      a,b
        ld      [de],a
        inc     de

        pop     af
        dec     a
        jr      nz,.fadeInner

.install
        ;make mapColor the current color 0
        ld      de,mapColor
        ld      hl,fadeCurPalette
        ld      a,[hl+]
        ld      [de],a
        inc     de
        ld      a,[hl+]
        ld      [de],a

        ;install the current palette on the next VBlank
        ld      a,1
        ldio    [paletteBufferReady],a

        pop     hl
        pop     de
        pop     bc
        ret


.lastFade
        ;finally copy actual palette
        ld      hl,fadeFinalPalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        ld      a,64
        ld      [fadeRange],a

        xor     a
        ld      [specialFX],a
        jr      .install

.addDeltaToError
        ;accepts:  a - color value
        ;returns:  a - new color value
        push    bc
        push    af

        ld      a,[fadeSteps]
        ld      b,a
        cpl
        add     1
        ld      c,a

        push    hl
        push    de
        ld      de,$ff40         ;-192
        add     hl,de
        pop     de

        ld      a,[hl]
        pop     hl

        bit     7,a             ;negative?
        jr      nz,.negative

.positive
        add     a,[hl]
        cp      b
        jr      c,.done

        ;>=32
        ld      c,0
.while_pos_ge_32
        sub     b
        inc     c
        cp      b
        jr      nc,.while_pos_ge_32

        ld      [hl+],a
        pop     af
        add     c
        pop     bc
        ret

.negative
        add     a,[hl]
        cp      c
        jr      nc,.done

        ;<= -32
        ld      b,0
.while_neg_le_n32
        sub     c
        inc     b
        cp      c
        jr      c,.while_neg_le_n32
        ld      [hl+],a
        pop     af
        sub     b
        pop     bc
        ret

.done
        ld      [hl+],a
        pop     af
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetColor0AllPalettes
; Arguments:    bc - color to set to
;               hl - ptr to start of palettes
; Alters:       af
;---------------------------------------------------------------------
SetColor0AllPalettes::
        push    de
        push    hl

        ld      d,16
.loop   ld      a,c
        ld      [hl+],a
        ld      a,b
        ld      [hl+],a
        ld      a,l
        add     6
        ld      l,a
        dec     d
        jr      nz,.loop

        pop     hl
        pop     de
        ret


;---------------------------------------------------------------------
; Routine:      SetColors123AllPalettes
; Arguments:    bc - color to set to
;               hl - ptr to start of palettes
; Alters:       af
;---------------------------------------------------------------------
SetColors123AllPalettes::
        push    de
        push    hl

        ld      d,16
.loop
        inc     hl
        inc     hl
        ld      e,3
.inner
        ld      a,c
        ld      [hl+],a
        ld      a,b
        ld      [hl+],a
        dec     e
        jr      nz,.inner

        dec     d
        jr      nz,.loop

        pop     hl
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      LighteningOut
; Alters:       af
;---------------------------------------------------------------------
LighteningOut::
        push    bc
        push    de
        push    hl

        ld      a,FADEBANK
        ld      [$ff70],a

        ;white background
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeCurPalette
        ld      bc,$7fff
        call    SetColor0AllPalettes
        ld      a,128
        ldio    [paletteBufferReady],a

        ld      c,3
        call    .pause

        ld      bc,0
        ld      hl,fadeCurPalette
        call    SetColors123AllPalettes

        ld      a,128
        ldio    [paletteBufferReady],a

        ld      c,7
        call    .pause

        pop     hl
        pop     de
        pop     bc
        ret

.pause  call    VWait
        dec     c
        jr      nz,.pause
        ret

;---------------------------------------------------------------------
; Routine:      LighteningIn
; Alters:       af
;---------------------------------------------------------------------
LighteningIn::
        push    bc
        push    de
        push    hl

        ld      a,FADEBANK
        ld      [$ff70],a

        ;black fg on white background
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeCurPalette
        ld      bc,$7fff
        call    SetColor0AllPalettes
        ld      bc,0
        call    SetColors123AllPalettes

        ld      a,128
        ldio    [paletteBufferReady],a

        ld      c,7
        call    .pause

        ;normal fg on white background
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeCurPalette
        ld      bc,$7fff
        call    SetColor0AllPalettes

        ld      a,128
        ldio    [paletteBufferReady],a

        ld      c,3
        call    .pause

        ;normal
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      a,128
        ldio    [paletteBufferReady],a

        pop     hl
        pop     de
        pop     bc
        ret

.pause  call    VWait
        dec     c
        jr      nz,.pause
        ret

;---------------------------------------------------------------------
; Routines:     GetRedComponent
;               GetGreenComponent
;               GetBlueComponent
;               SetRedComponent
;               SetGreenComponent
;               SetBlueComponent
; Arguments:    Get:  bc - 15 bit BGR value
;               Set:  bc - 15 bit BGR value, a - value to set
; Returns:      Get:  a - color component
; Alters:       af, bc
;---------------------------------------------------------------------
GetRedComponent::
        ld      a,c
        and     %00011111
        ret

GetGreenComponent::
        push    de
        ld      a,b
IF 1
        ld      e,c
        sla     e
        rla
        sla     e
        rla
        sla     e
        rla
        and     %00011111
        pop     de
        ret
ENDC

IF 0
        ld      e,c
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        ld      a,d
        and     %00011111
        pop     de
        ret
ENDC

GetBlueComponent::
        ld      a,b
        rrca
        rrca
        and     %00011111
        ret

SetRedComponent::
        push    af
        ld      a,c
        and     %11100000
        ld      c,a
        pop     af
        or      c
        ld      c,a
        ret

SetGreenComponent::
        push    de
        ld      d,a
        rrca
        rrca
        rrca
        and     %00000011
        ld      e,a

        ld      a,b
        and     %01111100
        or      e
        ld      b,a

        ld      a,d
        swap    a
        rlca
        and     %11100000
        ld      d,a

        ld      a,c
        and     %00011111
        or      d
        ld      c,a

        pop     de
        ret

SetBlueComponent::
        push    af
        ld      a,b
        and     %00000011
        ld      b,a
        pop     af
        rlca
        rlca
        or      b
        ld      b,a
        ret

;---------------------------------------------------------------------
; Routine:      PlaySound
; Arguments:    hl - addr of table 1st byte of which indicates sound
;                    type (1-4) and remainder is data specific to that
;                    type.
; Alters:       af, hl
;---------------------------------------------------------------------
PlaySound::
        ld      a,[hl+]
        cp      1
        jr      nz,.check2

        xor     a
        ld      [musicOverride1],a
        call    PlaySoundChannel1
        ld      a,3
        ld      [musicOverride1],a
        ret
.check2
        cp      2
        jr      nz,.check4
        call    PlaySoundChannel2
        ret
.check4
        cp      4
        jr      nz,.done

        xor     a
        ld      [musicOverride4],a
        call    PlaySoundChannel4
        ld      a,3
        ld      [musicOverride4],a
        ret

.done
        ret

;---------------------------------------------------------------------
; Routine:      PlaySoundChannel1
; Arguments:    hl - addr of 5 sound bytes for sweep, duty/len,
;                    envelope, freq_lo, and freq_high
; Alters:       af, hl
;---------------------------------------------------------------------
PlaySoundChannel1::
        ld      a,[musicOverride1]
        or      a
        ret     nz

.playSound
        ld      a,[hl+]
        ldio    [$ff10],a
        ld      a,[hl+]
        ldio    [$ff11],a
        ld      a,[hl+]
        ldio    [$ff12],a
        ld      a,[hl+]
        ldio    [$ff13],a
        ld      a,[hl+]
        ldio    [$ff14],a
        ret

;---------------------------------------------------------------------
; Routine:      PlaySoundChannel2
; Arguments:    hl - addr of 4 sound bytes for duty/len,
;                    envelope, freq_lo, and freq_high
; Alters:       af, hl
;---------------------------------------------------------------------
PlaySoundChannel2::
        ld      a,[hl+]
        ldio    [$ff16],a
        ld      a,[hl+]
        ldio    [$ff17],a
        ld      a,[hl+]
        ldio    [$ff18],a
        ld      a,[hl+]
        ldio    [$ff19],a
        ret

;---------------------------------------------------------------------
; Routine:      PlaySoundChannel3
; Arguments:    hl - addr of 4 sound bytes channel 4
; Alters:       af, hl
;---------------------------------------------------------------------
PlaySoundChannel3::
        ld      a,$80
        ldio    [$ff1a],a
        ld      a,[hl+]
        ldio    [$ff1b],a
        ld      a,[hl+]
        ldio    [$ff1c],a
        ld      a,[hl+]
        ldio    [$ff1d],a
        ld      a,[hl+]
        ldio    [$ff1e],a
        ret

;---------------------------------------------------------------------
; Routine:      PlaySoundChannel4
; Arguments:    hl - addr of 4 sound bytes for length, envelope,
;                    frequency, and consecutive
; Alters:       af, hl
;---------------------------------------------------------------------
PlaySoundChannel4::
        ld      a,[musicOverride4]
        or      a
        ret     nz

.playSound
        ld      a,[hl+]
        ldio    [$ff20],a
        ld      a,[hl+]
        ldio    [$ff21],a
        ld      a,[hl+]
        ldio    [$ff22],a
        ld      a,[hl+]
        ldio    [$ff23],a
        ret

;---------------------------------------------------------------------
; Routine:      WaitInput
; Arguments:    a - button mask [7:4] buttons, [3:0] dpad
; Alters:       af
;---------------------------------------------------------------------
WaitInput::
        push    bc
        push    de
        ld      b,a
.wait
        push    bc
        push    hl
        call    UpdateObjects
        call    RedrawMap
        pop     hl
        pop     bc
        ld      h,((curJoy0>>8) & $ff)
        ld      a,[dialogJoyIndex]
        add     (curJoy0 & $ff)
        ld      l,a
        ld      a,[hl]
        and     b
        jr      z,.wait
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      WaitInputZero
; Arguments:    a  - button mask [7:4] buttons, [3:0] dpad
;               hl - address of joystick button code to check
; Alters:       af
;---------------------------------------------------------------------
WaitInputZero::
        push    bc
        push    de
        ld      b,a
.wait
        push    bc
        push    hl
        call    UpdateObjects
        call    RedrawMap
        pop     hl
        pop     bc
        ld      a,[hl]
        and     b
        jr      nz,.wait
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      WaitInputClick
; Arguments:    a - button mask [7:4] buttons, [3:0] dpad
; Alters:       af
; Description:  WaitInputZero
;               WaitInput
;               WaitInputZero
;---------------------------------------------------------------------
WaitInputClick::
        push    bc
        push    hl

        ld      b,a
        ld      hl,myJoy
        call    WaitInputZero
        ld      a,b
        call    WaitInput
        ld      a,b
        call    WaitInputZero

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ResetSprites
; Arguments:    none
; Alters:       af
; Description:  Sets all spritesUsed flags to false and sets each
;               sprite y position in the OAM buffer to zero.
;---------------------------------------------------------------------
ResetSprites::
        push    bc
        push    de
        push    hl

        ;clear sprites used table
        ld      a,TILEINDEXBANK
        ld      [$ff70],a

        ld      hl,spritesUsed
        xor     a
        ld      c,40
.clr2   ld      [hl+],a
        dec     c
        jr      nz,.clr2

        ;clear sprites
        ld      hl,spriteOAMBuffer
        ld      c,40
        ld      de,3
.clr3
        ld      [hl+],a
        add     hl,de
        dec     c
        jr      nz,.clr3

        xor     a
        ld      [oamFindPos],a
        ld      a,40
        ld      [numFreeSprites],a

        pop     hl
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      AllocateSprite
; Arguments:    none
; Returns:      a - 00-9C=success (lowptr), ff=failure
; Alters:       af
; Description:  Loops through spritesUsed flag table, finds a free
;               sprite, and returns that sprite's loPtr.
;---------------------------------------------------------------------
AllocateSprite::
        ;any free sprites?
        ld      a,[numFreeSprites]
        or      a
        jr      nz,.freeSpriteExists

        ld      a,$ff
        ret

.freeSpriteExists
        push    bc
        push    de
        push    hl

        dec     a
        ld      [numFreeSprites],a

        ;we know there's at least one free sprite so start at
        ;the the search position (which is guaranteed to be
        ;<= pos of first free) and loop till we find it

        ld      a,TILEINDEXBANK
        ld      [$ff70],a

        ld      h,((spritesUsed>>8)&$ff)
        ld      a,[oamFindPos]
        ld      l,a

.loop   ld      a,[hl+]       ;get sprite used flag
        or      a
        jr      nz,.loop      ;not free

.foundSprite
        dec     hl
        ld      a,1           ;mark sprite as used
        ld      [hl],a

        ld      a,l           ;return loptr in a
        inc     a
        ld      [oamFindPos],a

        ld      a,l

        ;change 1-byte offset to 4-byte offset (loPtr)
        rlca                  ;times 2
        rlca                  ;times 2 again

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FreeSprite
; Arguments:    a - loptr to sprite
; Alters:       af
; Description:  Sets the sprite's YPOS to zero
;               Flags the sprite as unused
;               oamFindPos = min(thisPos, oamFindPos)
;               numFreeSprites++
;---------------------------------------------------------------------
FreeSprite::
        ;if loptr is $ff then don't bother
        cp      $ff
        ret     z

        push    hl

        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)

        xor     a
        ld      [hl],a     ;ypos to zero

        ld      a,TILEINDEXBANK
        ld      [$ff70],a

        rrc     l          ;convert loptr to sprite index
        rrc     l
        ld      h,((spritesUsed>>8) & $ff)

        xor     a
        ld      [hl],a     ;clear sprite used flag

        ;set find pos to be mininum
        ld      a,[oamFindPos]
        cp      l
        jr      c,.findPosIsMin

        ld      a,l
        ld      [oamFindPos],a

.findPosIsMin
        ;add one to # of free sprites
        ld      hl,numFreeSprites
        inc     [hl]

        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      CreateMetaSprite
; Arguments:
;               bc - width (b) and height (c) of metasprite, in 8x8
;                    tiles.
;               d  - initial pattern number for first sprite.
;               e  - default attributes for each sprite.
;               hl - ptr to location to store metasprite info.  Should
;                    be w*h + 1 in size.
;               [metaSprite_x], [metaSprite_y] - location of TL corner
; Alters:       af
;---------------------------------------------------------------------
CreateMetaSprite::
        push    bc
        push    de
        push    hl

        ld      a,[metaSprite_x]
        ld      [metaSprite_first_x],a

        ;calculate width times height
        push    bc
        xor     a
.calcTotalSize
        add     a,b
        dec     c
        jr      nz,.calcTotalSize
        pop     bc

        ;store total sprites used in metaSpriteInfo
        ld      [hl+],a

        ;go through and allocate each sprite, set it up, and store its
        ;loptr in the metaSpriteInfo
        push    bc
.height pop     af     ;setup width from original value
        push    af
        ld      b,a
        ld      a,[metaSprite_first_x]
        ld      [metaSprite_x],a

.width  call    AllocateSprite
        ld      [hl+],a    ;save loptr

        ;set up sprite
        push    hl
        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      a,[metaSprite_y]
        ld      [hl+],a
        ld      a,[metaSprite_x]
        ld      [hl+],a
        add     8
        ld      [metaSprite_x],a
        ld      a,d              ;pattern number
        ld      [hl+],a
        inc     d
        ld      [hl],e           ;attributes
        pop     hl

        dec     b
        jr      nz,.width

        ld      a,[metaSprite_y]
        add     8
        ld      [metaSprite_y],a
        dec     c
        jr      nz,.height

.done
        pop     bc

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CreateMetaSpriteUsingMask
; Arguments:
;               bc - width (b) and height (c) of metasprite, in 8x8
;                    tiles.
;               d  - initial pattern number for first sprite.
;               e  - default attributes for each sprite.
;               hl - ptr to location to store metasprite info.  Should
;                    be w*h + 1 in size and location 1+ should contain
;                    a zero if its corresponding sprite is not to
;                    be allocated after all.
;               [metaSprite_x], [metaSprite_y] - location of TL corner
; Alters:       af
;---------------------------------------------------------------------
CreateMetaSpriteUsingMask::
        push    bc
        push    de
        push    hl

        ld      a,[metaSprite_x]
        ld      [metaSprite_first_x],a

        ;calculate width times height
        push    bc
        xor     a
.calcTotalSize
        add     a,b
        dec     c
        jr      nz,.calcTotalSize
        pop     bc

        ;store total sprites used in metaSpriteInfo
        ld      [hl+],a

        ;go through and allocate each sprite marked with non-zero,
        ;set it up, and store its loptr in the metaSpriteInfo
        push    bc
.height pop     af     ;setup width from original value
        push    af
        ld      b,a
        ld      a,[metaSprite_first_x]
        ld      [metaSprite_x],a

.width  ld      a,[hl]     ;load flag from destination
        or      a
        ld      a,$ff
        jr      z,.afterAllocate
        call    AllocateSprite

.afterAllocate
        ld      [hl+],a    ;save loptr

        cp      $ff
        jr      z,.afterSetup

        ;set up sprite
        push    hl
        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      a,[metaSprite_y]
        ld      [hl+],a
        ld      a,[metaSprite_x]
        ld      [hl+],a
        ld      a,d              ;pattern number
        ld      [hl+],a
        ld      [hl],e           ;attributes
        pop     hl

.afterSetup
        ld      a,[metaSprite_x]
        add     8
        ld      [metaSprite_x],a
        inc     d
        dec     b
        jr      nz,.width

        ld      a,[metaSprite_y]
        add     8
        ld      [metaSprite_y],a
        dec     c
        jr      nz,.height

.done
        pop     bc

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ScrollMetaSprite
; Arguments:    bc - x (b) and y (c) offset to scroll each sprite.
;               hl - ptr to metaSpriteInfo created with
;                    CreateMetaSprite
; Alters:       af
;---------------------------------------------------------------------
ScrollMetaSprite::
        push    de

        ld      a,[hl+]   ;number of sprites
.loop
        push    af
        ld      a,[hl+]   ;loptr to sprite
        ld      e,a
        ld      d,((spriteOAMBuffer>>8) & $ff)

        ld      a,[de]    ;get the y position
        add     c         ;add y offset
        ld      [de],a
        inc     de
        ld      a,[de]    ;get the x position
        add     b         ;add x offset
        ld      [de],a
        inc     de

        pop     af
        dec     a
        jr      nz,.loop
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      SetMetaSpritePos
; Arguments:    bc - desired x (b) and y (c) pixel position in sprite
;                    coords
;               hl - ptr to metaSpriteInfo created with
;                    CreateMetaSprite
; Alters:       af
;---------------------------------------------------------------------
SetMetaSpritePos::
        push    bc

        push    hl

        inc     hl     ;go to y pos of first sprite
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)

        ld      a,c    ;desired y pos
        sub     [hl]
        ld      c,a    ;becomes offset to scroll

        inc     hl
        ld      a,b
        sub     [hl]
        ld      b,a    ;becomes offset to scroll

        pop     hl

        call    ScrollMetaSprite

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FreeMetaSprite
; Arguments:    hl - ptr to metaSpriteInfo created with
;                    CreateMetaSprite
; Alters:       af
;---------------------------------------------------------------------
FreeMetaSprite::
        push    bc
        push    hl

        ld      a,[hl+]     ;number of sprites
        ld      c,a

.freeASprite
        ld      a,[hl+]     ;get loptr
        call    FreeSprite
        dec     c
        jr      nz,.freeASprite

        pop     hl
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      CreateBigExplosion
; Arguments:    bc - tile width and height of explosion area
;               d  - max sprites (must be >0)
;               e  - flags for allowed explosion types:
;                    :0 - small round explosions
;                    :1 - shrapnel plus
;                    :2 - big (2x2) round explosions (4 sprites ea)
;               hl - TL map corner (e.g. $d0ca) of explosion
;               [bulletColor]
; Returns:      Nothing.
; Alters:       af
; Description:  Creates a big explosion of randomly dispersed smaller
;               explosions within the given area.
;
;---------------------------------------------------------------------
CreateBigExplosion::
        push    bc
        push    de
        push    hl

        ;limit the number of sprites according to the system's
        ;resources
        ld      a,[numFreeSprites]
        cp      d
        jr      nc,.numSpritesOkay
        ld      d,a
.numSpritesOkay
        or      a
        jr      nz,.continue
        jp      .done
.continue
        call    ConvertLocHLToXY
        ld      a,[bulletColor]

.loop   ;limit myself to smaller explosions if I have less than 4
        ;sprites left
        push    af
        push    hl

        ld      a,d
        cp      4
        jr      nc,.afterLimitToSmaller
        res     2,e    ;remove larger fr possible explosions flags
        ld      a,e
        or      a
        jr      nz,.afterLimitToSmaller
        ld      d,1
        jr      .afterCreateExplosion
.afterLimitToSmaller

        ;select random tile position within area

        ;width
        ld      a,b
        dec     a
        call    GetRandomNumZeroToN
        add     h
        ld      h,a

        ;height
        ld      a,c
        dec     a
        call    GetRandomNumZeroToN
        add     l
        ld      l,a

        call    ConvertXYToLocHL
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a

        ;choose random explosion
        ld      a,e
        call    GetRandomNumMask
        bit     2,a
        jr      z,.checkType1

.isType2
        bit     2,e   ;this type allowed?
        jr      z,.isType0
        ;type two - big 2x2 explosion
        ld      a,6
        ld      [bulletColor],a

        push    bc
        ld      b,32
        call    .create2x2Frame
        inc     hl
        call    .create2x2Frame
        push    de
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        pop     de
        dec     hl
        call    .create2x2Frame
        inc     hl
        call    .create2x2Frame
        pop     bc

        dec     d
        dec     d
        dec     d
        jr      .afterCreateExplosion

.checkType1
        bit     1,a
        jr      z,.isType0

.isType1
        bit     1,e   ;this type allowed?
        jr      z,.isType2
        ;type one - shrapnel
        ld      a,64
        jr      .determinedFrame

.isType0  ;default
        bit     0,e   ;this type allowed?
        jr      z,.isType1
        ;type zero - small round explosion
        ld      a,5
        ld      [bulletColor],a
        ld      a,16

.determinedFrame
        push    bc
        ld      b,a
        call    CreateExplosion
        call    .offsetSprite
        pop     bc

.afterCreateExplosion
        pop     hl
.beforeRestoreColor
        pop     af
        ld      [bulletColor],a

        dec     d
        jr      z,.done
        jp      .loop

.done
        pop     hl
        pop     de
        pop     bc
        ret

.offsetSprite
        or      a
        ret     z
        push    de
        push    hl
        call    IndexToPointerHL  ;get ptr to explosion class
        ld      a,OBJBANK
        ldio    [$ff70],a
        ld      de,OBJ_SPRITELO
        add     hl,de
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      a,%111
        call    GetRandomNumMask
        add     [hl]
        ld      [hl+],a
        ld      a,%111
        call    GetRandomNumMask
        add     [hl]
        ld      [hl],a
        pop     hl
        pop     de
        ret

.create2x2Frame
        ld      a,l
        ld      [bulletLocation],a
        ld      a,h
        ld      [bulletLocation+1],a
        call    CreateExplosion
        ld      a,b
        add     8
        ld      b,a
        ret

;---------------------------------------------------------------------
; Routine:      BlitMap
; Arguments:    bc - tile width and height of area to copy
;               de - destination XY coords
;               hl - source XY coords
; Returns:      Nothing.
; Alters:       af
; Description:  Copies a section of the current map, not overwriting
;               any objects
;---------------------------------------------------------------------
BlitMap::
        push    bc
        push    de
        push    hl

        push    hl
        ld      h,d
        ld      l,e
        call    ConvertXYToLocHL
        ld      d,h
        ld      e,l
        pop     hl
        call    ConvertXYToLocHL
        ld      a,MAPBANK
        ldio    [$ff70],a

.blitMapOuter
        push    bc
        push    de
        push    hl
        ldio    a,[firstMonster]
        ld      c,a

.blitMapInner
        ld      a,[de]
        cp      c       ;< first monster?
        jr      nc,.blitSkip

        ld      a,[hl]
        ld      [de],a
.blitSkip
        inc     hl
        inc     de
        dec     b
        jr      nz,.blitMapInner

        pop     hl
        pop     de
        push    hl
        ld      a,[mapPitch]
        ld      h,0
        ld      l,a
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl
        ld      a,[mapPitch]
        ld      b,0
        ld      c,a
        add     hl,bc

        pop     bc
        dec     c
        jr      nz,.blitMapOuter

        pop     hl
        pop     de
        pop     bc

        ret

;---------------------------------------------------------------------
; Routine:      ConvertLocHLToXY
; Arguments:    hl  - location ($D000-$DFFF)
; Returns:      hl  - h = x index, l = y index
; Alters:       a,hl
; Description:  x = location & (pitch-1)
;               y = (location - $D000) / pitch
;---------------------------------------------------------------------
ConvertLocHLToXY::
        ld      a,[mapPitchMinusOne]
        and     l
        push    af          ;push a (x index) on stack

        ld      a,h         ;subtract $D000 from hl by adding $3000
        add     $30
        ld      h,a
        ld      a,[mapPitchMinusOneComplement]  ;times to left-shift
.shift  rlca                      ;shift a bit left out of a
        jr      nc,.shiftDone     ;hl<<=1 if bits left in a
        sla     l
        rl      h
        jr      .shift

.shiftDone
        ld      l,h
        pop     af
        ld      h,a               ;h = x index, l = y index

        ret

;---------------------------------------------------------------------
; Routine:      ConvertXYToLocHL
; Arguments:    hl  - h = x index, l = y index
; Returns:      hl  - location ptr ($D000-$DFFF)
; Alters:       a,hl
; Description:  hl = $d000 + (y * pitch) + x
;               Instead of having y in the LoByte and left-shifting it
;               by the bits in the pitch, we'll put y in the HiByte
;               and right-shift it by 8-bitsInPitch.  Fewer ops.
;---------------------------------------------------------------------
ConvertXYToLocHL::
        push    de

        ;multiply y*pitch
        ld      a,[mapPitchMinusOneComplement]
        ld      d,l
        ld      e,0

.shift  rlca        ;if bits left in A then keep shifting
        jr      nc,.shiftDone
        srl     d
        rr      e
        jr      .shift

.shiftDone
        ld      l,h         ;add x + $d000
        ld      h,$d0
        add     hl,de

        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      LCheckGetVectorToState
; Arguments:    hl  - address of method table
; Returns:      hl  - methodTable[mapState]
; Alters:       af,hl
; Description:  Use the VECTORTOSTATE macro.
;---------------------------------------------------------------------
LCheckGetVectorToState::
        push    de
        ldio    a,[mapState]
        ld      d,0
        ld      e,a
        sla     e
        rl      d
        add     hl,de
        pop     de
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        ret

;---------------------------------------------------------------------
; Routine:      SaveIdle
; Arguments:    None.
; Returns:
; Alters:       af,hl
; Description:  Saves the current state of [heroesIdle] and [allIdle]
;               in [dialogIdleSettings] and activates both idle
;               settings
;---------------------------------------------------------------------
SaveIdle::
        ld      a,[heroesIdle]
        rlca
        ld      hl,allIdle
        or      [hl]
        ld      [dialogIdleSettings],a

        ld      a,1
        ld      [heroesIdle],a
        ld      [allIdle],a
        ret

;---------------------------------------------------------------------
; Routine:      RestoreIdle
; Arguments:    None.
; Returns:
; Alters:       af,hl
; Description:  Restores the idle settings to what they were previous
;               to SaveIdle
;---------------------------------------------------------------------
RestoreIdle::
        ld      a,[dialogIdleSettings]
        push    af
        and     1
        ld      [allIdle],a
        pop     af
        srl     a
        ld      [heroesIdle],a
        ret

;---------------------------------------------------------------------
; Routine:      MakeIdle
; Arguments:    None.
; Returns:
; Alters:       af
; Description:  Sets [heroesIdle] and [allIdle] to 1
;---------------------------------------------------------------------
MakeIdle::
        ld      a,1
        ld      [heroesIdle],a
        ld      [allIdle],a
        ret

;---------------------------------------------------------------------
; Routine:      MakeNonIdle
; Arguments:    None.
; Returns:
; Alters:       af
; Description:  Sets [heroesIdle] and [allIdle] to 0
;---------------------------------------------------------------------
MakeNonIdle::
        xor     a
        ld      [heroesIdle],a
        ld      [allIdle],a
        ret

;---------------------------------------------------------------------
; Routine:      UseAlternatePalette
; Arguments:    None.
; Returns:      Nothing.
; Alters:       af
; Description:  Darkens colors 1 & 2 of each palette, intended for
;               use on the light-background maps.
;---------------------------------------------------------------------
UseAlternatePalette::
        push    bc
        push    hl

        ld      a,FADEBANK
        ldio    [$ff70],a

        ld      c,16
        ld      hl,gamePalette+2
.loop   call    .halve
        call    .halve
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        dec     c
        jr      nz,.loop

        pop     hl
        pop     bc
        ret

.halve
        ld      a,[hl+]     ;color[i]>>=1;
        ld      b,a
        ld      a,[hl]
        rrca
        rr      b
        and     %00111101
        ld      [hl-],a
        ld      a,b
        and     %11101111
        ld      [hl+],a
        inc     hl
        ret

;---------------------------------------------------------------------
; Routine:      GetMyHero
; Arguments:    None.
; Returns:      a  - class index of local hero (i.e. not remote)
;               hl - pointer to hero0_data or hero1_data approprately
; Alters:       af, hl
;---------------------------------------------------------------------
GetMyHero::
        ld      a,[amLinkMaster]
        cp      0
        jr      z,.getHero1

        ;get hero zero if link master
        ld      a,[hero0_index]
        ld      hl,hero0_data
        ret

.getHero1
        ld      a,[hero1_index]
        ld      hl,hero1_data
        ret

;---------------------------------------------------------------------
; Routine:      GetBGAttributes
; Arguments:    a - class index
; Alters:       af
; Returns:      a - attributes for given class index
;               Returns full set off attributes including:
;               [2:0] - color           FLAG_PALETTE
;               [3]   - can walk over   FLAG_WALKOVER
;               [4]   - can shoot over  FLAG_SHOOTOVER
;---------------------------------------------------------------------
GetBGAttributes::
        push    hl
        ld      l,a
        ld      h,((bgAttributes>>8) & $ff)
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      a,[hl]
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      UpdateDialogBalloons
; Arguments:    de - intial pos in [spritesUsed]
;               hl - initial pos in spriteOAMBuffer
; Alters:       af, de, hl
;---------------------------------------------------------------------
UpdateDialogBalloons::
        ld      a,[amShowingDialog]
        or      a
        ret     nz        ;no balloons during dialog

        ldio    a,[updateTimer]
        and     %00010000
        ret     z         ;all blank

        push    bc
        call    FindNextFreeSprite
        jr      z,.done
        ld      a,[dialogBalloonClassIndex]
        ld      c,a
        call    GetFirst
.setNextBalloon
        or      a
        jr      z,.done

        call    PutBalloonAboveObject

        ;remake de from hl
        push    de
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        call    .remakeDEfromHL
        call    FindNextFreeSprite
        pop     de
        jr      z,.done

        call    GetNextObject
        jr      .setNextBalloon

.done
        call    .remakeDEfromHL
        pop     bc
        ret

.remakeDEfromHL
        ld      a,l     ;e = l/4
        rrca
        rrca
        ld      e,a
        ld      d,((spritesUsed>>8)&$ff)
        ret

;---------------------------------------------------------------------
; Routine:      DisableDialogBalloons
; Arguments:    a  - mask of objects (up to 8) to disable.  %101
;                    would disable the first and third speakers, etc.
;                    Speakers after the eigth are disabled.
; Alters:       af
;---------------------------------------------------------------------
DisableDialogBalloons::
        push    bc
        push    de
        push    hl

        ld      b,a

        ld      a,[dialogBalloonClassIndex]
        or      a
        jr      z,.done

        ld      c,a
        call    GetFirst
.disableNext
        or      a
        jr      z,.done

        ld      a,b
        or      a
        jr      z,.disableAfter8

        and     1
        jr      z,.continue

        ld      a,1
        call    SetMisc

.continue
        srl     b
        call    GetNextObject
        jr      .disableNext

.disableAfter8
        ld      b,8
        ld      a,[dialogBalloonClassIndex]
        ld      c,a
        call    GetFirst
.find9th
        or      a
        jr      z,.done

        call    GetNextObject
        dec     b
        jr      nz,.find9th

.disableAfter8Next
        or      a
        jr      z,.done

        ld      a,1
        call    SetMisc

        call    GetNextObject
        jr      .disableAfter8Next

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FindNextFreeSprite
; Arguments:    de - ptr to position within spritesUsed to begin
;                    resetting
;               hl - ptr to sprite OAM buffer corresponding to
;                    de
; Alters:       af,de,hl
; Returns:      a  - 0 on failure
;---------------------------------------------------------------------
FindNextFreeSprite:
        ld      a,e
        cp      40
        jr      nc,.notFound

        push    bc
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      bc,4

.checkNext
        ld      a,[de]
        or      a
        jr      z,.foundIt

        inc     de
        add     hl,bc
        ld      a,e
        cp      40
        jr      c,.checkNext

        pop     bc
.notFound
        xor     a
        ret

.foundIt
        ld      a,1
        or      a
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      PutBalloonAboveObject
; Arguments:    de - ptr to object
;               hl - ptr to sprite OAM buffer
; Alters:       af
;---------------------------------------------------------------------
PutBalloonAboveObject:
        push    de
        push    hl

        ld      [hl],0      ;zero sprite in case we don't use it
        push    hl
        call    GetMisc
        pop     hl
        or      a
        jr      nz,.done    ;already spoke
        call    GetCurLocation
        call    ConvertLocHLToSpriteCoords
        ld      d,h
        ld      e,l
        pop     hl
        push    hl
        ld      a,e
        or      a
        jr      z,.afterAdjustCoords   ;leave zero at zero

        sub     8
        ld      e,a
        ld      a,d
        add     8
        ld      d,a

.afterAdjustCoords
        ld      [hl],e    ;y coord
        inc     hl
        ld      [hl],d    ;x coord
        inc     hl
        ld      a,80      ;pattern number
        ld      [hl+],a
        xor     a
        ld      [hl],a    ;palette/etc
.done
        pop     hl
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      ResetFreeSprites
; Arguments:    de - ptr to position within spritesUsed to begin
;                    resetting
;               hl - ptr to sprite OAM buffer corresponding to
;                    de
; Alters:       af,de,hl
; Returns:      Nothing.
; Description:  Sets y=0 of all sprites after initial position not
;               flagged as in use; necessary for resetting
;               environmental effects
;---------------------------------------------------------------------
ResetFreeSprites::
        ld      a,e
        cp      40
        ret     nc

        push    bc

        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      bc,4

.resetNext
        ld      a,[de]
        or      a
        jr      nz,.afterReset

        ld      [hl],a     ;ypos = 0

.afterReset
        add     hl,bc
        inc     de
        ld      a,e
        cp      40
        jr      c,.resetNext

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetEnvEffect
; Arguments:    a - env effect such as ENV_RAIN
; Alters:       af
; Returns:      Nothing.
; Description:  Sets an environmental effect and quickly updates it
;               a number of times to be in full swing by the time
;               the player sees it
;---------------------------------------------------------------------
SetEnvEffect::
        push    bc
        ld      [envEffectType],a

        ld      c,16
.updateEffect
        call    UpdateEnvEffect
        dec     c
        jr      nz,.updateEffect

        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      UpdateEnvEffect
; Arguments:    None.
; Alters:       af
; Returns:      Nothing.
; Description:  Sets unused sprites to be dialog/rain/snow etc based
;               on [envEffectType].  Calls UpdateDialogBalloons and
;               ResetFreeSprites
;---------------------------------------------------------------------
UpdateEnvEffect::
        push    bc
        push    de
        push    hl

        ld      de,spritesUsed
        ld      hl,spriteOAMBuffer

        ld      c,0

        ld      a,[dialogBalloonClassIndex]
        or      a
        jr      z,.afterUpdateBalloons

        inc     c
        call    nz,UpdateDialogBalloons

.afterUpdateBalloons
        ld      a,[envEffectType]
        or      a
        jr      z,.afterEffect

        ldio    a,[randomLoc]
        push    af
        ld      a,[asyncRandLoc]
        ldio    [randomLoc],a
        ld      a,[envEffectType]
        call    .updateAppropriate
        ldio    a,[randomLoc]
        ldio    [asyncRandLoc],a
        pop     af
        ldio    [randomLoc],a

.afterEffect
        call    ResetFreeSprites

        pop     hl
        pop     de
        pop     bc
        ret

.updateAppropriate
        inc     c

        cp      ENV_RAIN
        jr      nz,.checkSnow

        ld      d,e
        LONGCALLNOARGS     EnvRain
        ret

.checkSnow
        cp      ENV_SNOW
        jr      nz,.checkDirt

        ld      d,e
        LONGCALLNOARGS     EnvSnow
        ret

.checkDirt
        cp      ENV_DIRT
        jr      nz,.checkClouds

        ld      d,e
        LONGCALLNOARGS     EnvDirt
        ret

.checkClouds
        cp      ENV_CLOUDS
        jr      nz,.checkWindySnow

        ld      d,e
        LONGCALLNOARGS     EnvClouds
        ret

.checkWindySnow
        cp      ENV_WINDYSNOW
        jr      nz,.checkCounter

        ld      d,e
        LONGCALLNOARGS     EnvWindySnow
        ret

.checkCounter
        cp      ENV_COUNTER
        jr      nz,.checkDisco

        ;reset first two sprites to y=16
        ld      hl,spriteOAMBuffer
        ld      de,4
        ld      [hl],16
        add     hl,de
        ld      [hl],16
        ret

.checkDisco
        cp      ENV_DISCO
        ret     nz

        LONGCALLNOARGS     EnvDisco
        ret

;---------------------------------------------------------------------
SECTION  "GfxSupport",ROMX
;---------------------------------------------------------------------
EnvRain:
        call    EnvSetupDEHL
        ld      b,0
.nextDrop
        call    FindNextFreeSprite
        ret     z

        inc     b

        ld      a,[hl]
        or      a
        jr      nz,.updatePosition

.newDrop
        ;create new raindrop
        ld      a,63
        call    GetRandomNumMask
        cpl
        add     16
        ld      [hl+],a    ;ypos

        ld      a,255
        call    GetRandomNumMask
        ;add     8
        ;ld      [hl],a
        ;ld      a,63
        ;call    GetRandomNumMask
        ;add     [hl]
        ;sub     64
        ld      [hl+],a     ;xpos

        ld      [hl],81    ;pattern
        inc     hl
        ld      [hl],2     ;palette
        inc     hl
        inc     de
        jr      .nextDrop

.updatePosition
        ld      a,[hl]
        add     8
        ld      [hl],a
        and     184
        cp      184
        jr      nz,.afterRemove

.remove
        ld      [hl],0
.afterRemove
        inc     hl
        ld      a,[hl]
        add     4
        ld      [hl+],a
        ld      a,[hl+]
        cp      81         ;rain pattern
        jr      z,.dropOkay

        ;change into a rain sprite
        dec     hl
        ld      [hl],81
        inc     hl
        ld      [hl],2

        ;push    hl
        ;dec     hl
        ;dec     hl
        ;ld      [hl],0     ;reset sprite
        ;pop     hl

.dropOkay
        inc     hl
        inc     de
        jp      .nextDrop

EnvSnow:
        call    EnvSetupDEHL
        ld      b,0
.nextFlake
        call    FindNextFreeSprite
        ret     z

        inc     b

        ld      a,[hl]
        or      a
        jr      nz,.updatePosition

.newFlake
        ;create new snowflake
        ld      a,63
        call    GetRandomNumMask
        cpl
        add     16
        ld      [hl+],a    ;ypos

        ld      a,255
        call    GetRandomNumMask
        ;add     8
        ;ld      [hl],a
        ;ld      a,63
        ;call    GetRandomNumMask
        ;add     [hl]
        ;sub     10
        ld      [hl+],a     ;xpos

        ld      [hl],74    ;pattern
        inc     hl
        ld      [hl],0     ;palette
        inc     hl
        inc     de
        jr      .nextFlake

.updatePosition
        ld      a,[hl]
        ;add     4
        inc     a
        ld      [hl],a
        and     184
        cp      184
        jr      nz,.afterRemove

.remove
        ld      [hl],0
.afterRemove
        ;get deltax offset for this flake mem loc + y loc
        ld      a,l
        rrca
        rrca
        add     [hl]       ;plus y coord
        and     63

        push    hl
        add     (flakeSineTable & $ff)
        ld      l,a
        ld      a,0
        adc     ((flakeSineTable>>8)&$ff)
        ld      h,a
        ld      a,[hl]
        pop     hl
        inc     hl
        add     [hl]
        ld      [hl+],a    ;new x coord
        ld      a,[hl+]
        cp      74         ;flake pattern
        jr      z,.flakeOkay

        ;change into a snowflake sprite
        dec     hl
        ld      [hl],74
        inc     hl
        ld      [hl],0

        ;push    hl
        ;dec     hl
        ;dec     hl
        ;ld      [hl],0     ;reset sprite
        ;pop     hl

.flakeOkay
        inc     hl
        inc     de
        jp      .nextFlake


EnvDirt:
        call    EnvSetupDEHL
        ld      b,0
.nextGrit
        call    FindNextFreeSprite
        ret     z

        inc     b

        ld      a,[hl]
        or      a
        jr      nz,.updatePosition

.newGrit
        ;create new sand
        ld      a,127
        call    GetRandomNumMask
        ld      [hl],a    ;ypos
        ld      a,31
        call    GetRandomNumMask
        add     [hl]
        sub     10
        ld      [hl+],a

        ld      a,63
        call    GetRandomNumMask
        cpl
        add     8
        ld      [hl+],a     ;xpos

        ld      [hl],72    ;pattern
        inc     hl
        ld      [hl],6     ;palette
        inc     hl
        inc     de
        jr      .nextGrit

.updatePosition
        ld      a,l    ;y += (-1,0,1,2)
        rrca
        rrca
        and     %11
        sub     1
        add     [hl]
        ld      [hl+],a

        ld      a,[hl]
        add     8
        ld      [hl+],a
        and     184
        cp      184
        jr      nz,.afterRemove

.remove
        push    hl
        dec     hl
        dec     hl
        ld      [hl],0
        pop     hl
.afterRemove
        ld      a,[hl+]
        cp      72         ;grit pattern
        jr      z,.gritOkay

        push    hl
        dec     hl
        dec     hl
        dec     hl
        ld      [hl],0     ;reset sprite
        pop     hl

.gritOkay
        inc     hl
        inc     de
        jp      .nextGrit

EnvWindySnow:
        call    EnvSetupDEHL
        ld      b,0
.nextFlake
        call    FindNextFreeSprite
        ret     z

        inc     b

        ld      a,[hl]
        or      a
        jr      nz,.updatePosition

.newFlake
        ;create new flake
        ld      a,127
        call    GetRandomNumMask
        ld      [hl],a    ;ypos
        ld      a,31
        call    GetRandomNumMask
        add     [hl]
        sub     10
        ld      [hl+],a

        ld      a,63
        call    GetRandomNumMask
        cpl
        add     168
        ld      [hl+],a     ;xpos

        ld      [hl],74    ;pattern
        inc     hl
        ld      [hl],0     ;palette
        inc     hl
        inc     de
        jr      .nextFlake

.updatePosition
        ld      a,l    ;y += (-1,0,1,2)
        rrca
        rrca
        and     %11
        sub     1
        add     [hl]
        ld      [hl+],a

        ld      a,[hl]
        sub     8
        ld      [hl+],a
        and     248
        cp      248
        jr      nz,.afterRemove

.remove
        push    hl
        dec     hl
        dec     hl
        ld      [hl],0
        pop     hl
.afterRemove
        ld      a,[hl+]
        cp      74         ;flake pattern
        jr      z,.flakeOkay

        ;change into a snowflake sprite
        dec     hl
        ld      [hl],74
        inc     hl
        ld      [hl],0

        ;push    hl
        ;dec     hl
        ;dec     hl
        ;dec     hl
        ;ld      [hl],0     ;reset sprite
        ;pop     hl

.flakeOkay
        inc     hl
        inc     de
        jp      .nextFlake

EnvClouds:
        call    EnvSetupDEHL
        ld      b,0
.nextCloud
        call    FindNextFreeSprite
        ret     z

        inc     b

        ld      a,[hl]
        or      a
        jr      nz,.updatePosition

        ld      a,b
        and     %11
        jr      nz,.addToCloud

        ;one in 8 chance of creating a cloud
        ld      a,1
        call    GetRandomNumMask
        or      a
        jr      z,.newCloud

        inc     hl
        inc     hl
        inc     hl
        inc     hl
        inc     de
        jr      .nextCloud

.newCloud
        ;create new cloud
        ld      a,144
        call    GetRandomNumZeroToN
        add     16
        ld      [hl+],a    ;ypos
        ld      [$c01e],a

        ld      a,63
        call    GetRandomNumMask
        cpl
        ld      [hl+],a     ;xpos
        ld      [$c01f],a

        ld      a,3
        call    GetRandomNumMask
        add     82
        ld      [hl+],a    ;pattern
        ld      [hl],4     ;palette
        inc     hl
        inc     de
        jr      .nextCloud

.addToCloud
        push    de
        ld      a,7
        call    GetRandomNumMask
        ld      d,a
        ld      a,[$c01e]
        add     d
        ld      [hl+],a    ;ypos

        ld      a,7
        call    GetRandomNumMask
        ld      d,a
        ld      a,[$c01f]
        add     d
        ld      [hl+],a     ;xpos

        ld      a,3
        call    GetRandomNumMask
        add     82
        ld      [hl+],a    ;pattern
        ld      [hl],4     ;palette
        inc     hl
        pop     de
        inc     de
        jr      .nextCloud

.updatePosition
        inc     hl
        ;bit     2,l
        ;jr      z,.updateOnTimer
        jr      .updateOnTimer
        inc     [hl]
        jr      .afterIncr
.updateOnTimer
        ldio    a,[updateTimer]
        and     1
        jr      z,.afterIncr
        inc     [hl]
.afterIncr
        ld      a,[hl]
        cp      178
        jr      nz,.afterRemove

        dec     hl
        ld      [hl],0
        inc     hl
.afterRemove
        inc     hl
        inc     hl
        inc     hl
        inc     de
        jp      .nextCloud

EnvSetupDEHL:
        ld      d,((spritesUsed>>8)&$ff)
        ld      a,e
        rlca
        rlca
        ld      l,a
        ld      h,((spriteOAMBuffer>>8)&$ff)
        ret

flakeSineTable:
  DB $ff,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  DB 0,0,1,0,0,1,0,1,0,0,1,0,0,1,0,0
  DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$ff
  DB 0,0,$ff,0,0,$ff,0,0,$ff,0,$ff,0,0,$ff,0,0

;---------------------------------------------------------------------
; EnvDisco
; Uses binary data "discoLights" to set all colors to purple in
; drawing buffer except where lights are flashing.  Uses levelVars[0]
; to determine current frame
;---------------------------------------------------------------------
EnvDisco:
        push    bc
        push    de
        push    hl

        ;setup hl to point to light data for appropriate frame
        ld      de,20*18
        ld      hl,discoLights
        ld      a,[levelVars]
        or      a
        jr      z,.frameSet

.times360
        add     hl,de
        dec     a
        jr      nz,.times360

.frameSet
        ld      de,attributeBuffer
        ld      b,18    ;18 rows
.outer
        ld      c,20    ;20 columns
.inner
        ld      a,[hl+]
        or      a
        jr      nz,.afterSetColor

        ld      a,[de]
        or      %111
        ld      [de],a

.afterSetColor
        inc     de

        dec     c
        jr      nz,.inner

        push    hl
        ld      hl,12
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        dec     b
        jr      nz,.outer

        pop     hl
        pop     de
        pop     bc
        ret

discoLights:
INCBIN "Data/discolights.dat"

;Not in HOME

;---------------------------------------------------------------------
SECTION  "FontSection",ROMX,BANK[MAP0ROM]
fontData:
  INCBIN "Data/font.bin"

blankTileData:
  DW 0,0,0,0,0,0,0,0

explosionSprites:
INCBIN "explosions0-85.bin"

SECTION "ReservedSpriteDMAHandler",HRAM[$FF80]
SpriteDMAHandler::
        DS      (oamHandlerFinish - oamHandlerStart)

;---------------------------------------------------------------------
SECTION "GfxSupportSection",ROMX[$4000]
;---------------------------------------------------------------------
;$4000
randomTable:
DB $9f,$d2,$e6,$e7,$70,$db,$11,$63,$6b,$37,$99,$98,$30,$9c,$d9,$35
DB $65,$af,$56,$ee,$b1,$00,$fd,$c7,$61,$48,$df,$45,$2e,$41,$6d,$9b
DB $13,$40,$d8,$fa,$91,$02,$29,$e0,$cb,$5d,$28,$fb,$2f,$77,$ea,$f9
DB $7e,$92,$5b,$75,$b5,$fc,$ae,$a2,$71,$cc,$a9,$3f,$7f,$7d,$ad,$7c
DB $73,$a5,$f8,$03,$9e,$25,$f6,$e8,$4d,$33,$b3,$44,$aa,$26,$08,$6e
DB $82,$97,$96,$19,$c8,$b4,$ba,$d3,$1f,$d0,$f5,$06,$54,$86,$49,$e2
DB $69,$43,$0b,$b0,$f1,$83,$a8,$9d,$38,$42,$ef,$e4,$74,$12,$20,$a0
DB $55,$01,$66,$23,$3d,$51,$c0,$79,$10,$de,$eb,$d5,$09,$8e,$5e,$67
DB $4a,$7a,$3e,$4b,$68,$8d,$e9,$62,$1b,$dd,$da,$bb,$53,$22,$3c,$b6
DB $ff,$81,$24,$8b,$d4,$6f,$d7,$9a,$d6,$21,$f4,$0a,$b2,$bc,$a7,$36
DB $34,$64,$c5,$a6,$4e,$b9,$f3,$0e,$f0,$3b,$cd,$0d,$17,$ec,$1a,$8a
DB $e3,$16,$93,$05,$c9,$14,$c1,$cf,$52,$2c,$1e,$bf,$88,$27,$1d,$f7
DB $5c,$ac,$ab,$3a,$bd,$a1,$f2,$04,$e5,$2d,$e1,$c2,$15,$fe,$8c,$6a
DB $2b,$84,$1c,$d1,$47,$c6,$58,$c3,$0f,$ce,$5f,$90,$8f,$76,$60,$0c
DB $94,$2a,$6c,$89,$39,$46,$18,$95,$7b,$dc,$b7,$72,$78,$5a,$57,$ca
DB $4f,$a4,$59,$07,$32,$c4,$ed,$b8,$50,$85,$a3,$31,$4c,$87,$80,$be

;0=star 1=moon 2=flower 3=crouton 4=i 5=monkey 6=wrench 7=man
;$4100
init_flightCodes:
DB $0f
DB $00,$00,$06
DB $00,$00,$23
DB $00,$00,$29
DB $00,$00,$3a
DB $00,$00,$47
DB $00,$00,$59
DB $00,$00,$66
DB $00,$00,$a3
DB $00,$00,$a8
DB $00,$00,$0a
DB $00,$00,$3d
DB $63,$02,$71   ;initial landing star flower wrench crouton
DB $33,$53,$81   ;mouse landing monkey crouton crouton crouton
DB $65,$70,$c7   ;farm landing man star wrench monkey
DB $12,$01,$55   ;palace star moon moon flower
DB $00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


;SECTION "InGameGraphicsSection1",ROMX
;select_hero_bg::
;  INCBIN "gamebg\\select_hero.bg"

