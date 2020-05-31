;------------------------------------------------------------------------
; cinema.asm
; 1-5-2000 by Martin Casado
; 4.27.2000 by Abe Pralle
;
; Description:  Routines to handle drawing and minipulating cinema 
;               tiles and sprites
;
; Contents:
;   LoadCinemaBG
;   LoadCinemaSprite
;   LoadCinemaTextBox
;------------------------------------------------------------------------

INCLUDE "Source/defs.inc"

FIRST_TEXTBOX_TILE EQU 136

SECTION "Cinema",ROM0

;---------------------------------------------------------------------
; Routine:      LoadCinemaBG
; Arguments:    a  - bank containing data
;               hl - addr of .bg data to load
; Alters:       af
; Description:  Uses DMA to load in new tile patterns, then loads
;               in tile layout data into tileShadowBuffer and
;               attributeShadowBuffer
;---------------------------------------------------------------------
LoadCinemaBG::
        push    bc
        push    de
        push    hl

        ld      de,$9000
        call    LoadTileDefs

        ld      a,[hl+]
        ld      [mapWidth],a

        ld      b,a
        ld      a,1
.findPitch
        rlca
        cp      b
        jr      c,.findPitch
        ld      [mapPitch],a

        ld      a,[hl+]
        ld      [mapHeight],a

        call    SetupMapVarsFromWidthPitchAndHeight
        push    hl
        ld      hl,mapMaxLeft
        inc     [hl]
        ld      hl,mapMaxTop
        inc     [hl]
        pop     hl

        ;load tile indices
        ld      a,TILESHADOWBANK
        ld      [$ff70],a

        call    CinemaCommonClearBank

        ld      de,tileShadowBuffer

        ld      a,[mapHeight]
        ld      b,a

.tileIndexOuter
        ld      a,[mapWidth]
        ld      c,a

.tileIndexInner
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.tileIndexInner

        ;skip remaining pitch
        call    CinemaCommonSkipPitch

        dec     b
        jr      nz,.tileIndexOuter

        
        ;load tile attributes (packed 2:1 per byte)
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a

        call    CinemaCommonClearBank

        ld      de,attributeShadowBuffer

        ld      a,[mapHeight]
        ld      b,a

.tileAttrOuter
        ld      a,[mapWidth]
        srl     a
        ld      c,a

.tileAttrInner
        ld      a,[hl+]
        push    af
        swap    a
        and     %00001111
        ld      [de],a
        inc     de
        pop     af
        and     %00001111
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.tileAttrInner

        ;skip remaining pitch
        call    CinemaCommonSkipPitch

        dec     b
        jr      nz,.tileAttrOuter

        ld      a,0
        call    LoadCinemaPalette

.done
        ld      a,OBJROM
        call    SetActiveROM

        call    PrepareForInitialMapDraw

        ;call    VWait
        ld      a,1     ;necessary though I'm not sure why!!
        call    Delay

        pop     hl
        pop     de
        pop     bc
        ret

CinemaCommonClearBank:
        push    hl
        ld      hl,map
.clearBankLoop
        xor     a
        ld      [hl+],a
        ld      a,h
        cp      $e0
        jr      c,.clearBankLoop

        pop     hl
        ret

CinemaCommonSkipPitch:
        push    hl
        ld      a,[mapSkip]
        ld      l,a
        ld      h,0
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      LoadCinemaSprite
; Arguments:    a  - bank containing data
;               hl - addr of .sp data to load
; Alters:       af
; Description:  Uses DMA to load in new sprite patterns, then loads
;               in metasprite layout data into spriteOAMBuffer
;---------------------------------------------------------------------
LoadCinemaSprite::
        push    bc
        push    de
        push    hl

        ld      de,$8000
        call    LoadTileDefs

        ;switch to 8x16 sprites
        ld      a,[$ff40]
        or      %00000100
        ld      [$ff40],a

        ;load oam definitions
        inc     hl                ;discard width, pitch, and height
        inc     hl
        inc     hl

        ld      a,[hl+]           ;num sprites
        ld      c,a

.loadSprite
        call    AllocateSprite
        cp      $ff
        jr      z,.noSpritesLeft

        ld      d,((spriteOAMBuffer>>8) & $ff)
        ld      e,a
        ld      a,[hl+]     ;y position
        ld      [de],a
        inc     de
        ld      a,[hl+]     ;x position
        ld      [de],a
        inc     de
        ld      a,[hl+]     ;tile index
        ld      [de],a
        inc     de
        ld      a,[hl+]     ;attributes
        ld      [de],a

        dec     c
        jr      nz,.loadSprite
        jr      .loadPalette


.noSpritesLeft
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        dec     c
        jr      nz,.noSpritesLeft

.loadPalette
        ld      a,64
        call    LoadCinemaPalette

.done
        ld      a,OBJROM
        call    SetActiveROM

        ;necessary (for loadbg) though I'm not sure why!!
        call    VWait
        ;ld      a,1     
        ;call    Delay

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      LoadTileDefs
; Arguments:    a  - bank containing data
;               de - starting location to load tile patterns into,
;                    e.g. $9000 for backgrounds or $8000 for sprites.
;               hl - addr of .bg or .sp data to load
; Alters:       af, hl
; Description:  Does some setup work for either Cinema backgrounds OR
;               Cinema sprites then uses DMA to load in new tile or 
;               sprite patterns
;---------------------------------------------------------------------
LoadTileDefs:
        push    bc
        push    de

        call    SetActiveROM
        ld      a,1
        ld      [displayType],a

        ;replace HBlank handler if default one
        ld      a,[hblankVector+1]
        cp      (OnHBlank & $ff)
        jr      nz,.afterInstallHandler
        ld      a,[hblankVector+2]
        cp      ((OnHBlank>>8) & $ff)
        jr      nz,.afterInstallHandler

.replaceHandler
        push    hl
        ld      hl,CinemaOnHBlank
        call    InstallHBlankHandler
        pop     hl
.afterInstallHandler

        ;xor     a
        ;ld      [levelCheckSkip],a
        ;ld      [levelCheckSkip+1],a

        ;ensure VBlank interrupt is enabled and interrupts are enabled
        ldio    a,[$ffff]
        or      %11
        ldio    [$ffff],a
        ei

        ;turn LCD on 
        ld      a,[$ff40]
        or      a,%11000011
        ld      [$ff40], a       ;lcdc control

        ;indicate we've settled in
        xor     a
        ld      [amChangingMap],a

        ld      a,[hl+]     ;bank zero tiles exist?
        or      a
        jr      z,.checkBank1Tiles

        ld      a,[hl+]     ;number of bank zero tiles
        ld      b,a
        call    .copyTilesToMapRAM  ;copy to buffer to ensure alignment
        xor     a
        call    .loadTiles

.checkBank1Tiles
        ld      a,[hl+]     ;bank one tiles exist?
        or      a
        jr      z,.loadLayout
        ld      a,[hl+]     ;number of bank one tiles
        ld      b,a
        call    .copyTilesToMapRAM  ;copy to buffer to ensure alignment
        ld      a,1
        call    .loadTiles

.loadLayout
        ;switch back to VRAM bank 0
        xor     a
        ld      [$ff4f],a

        pop     de
        pop     bc
        ret

.copyTilesToMapRAM
        push    de
        push    bc

        ld      a,MAPBANK
        ld      [$ff70],a
        ld      de,map

.copyTilesOuter
        ld      c,16

.copyTilesInner
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.copyTilesInner

        dec     b
        jr      nz,.copyTilesOuter

        pop     bc
        pop     de
        ret

.loadTiles
        ;load sets of 64 tiles and then leftover
        push    bc         
        push    de
        push    hl
        push    af          ;save bank

        ld      hl,map

.continueLoadTiles
        ld      a,b 
        or      a           ;zero equivalent to 256 in this case
        jr      z,.gt_64_bank
        cp      65          ;<=64 tiles left?
        jr      nc,.gt_64_bank

        ld      c,b         ;# of tiles IS # of sets of 16
        jr      .got_loadsize

.gt_64_bank
        ld      c,64        ;load 64 tiles

.got_loadsize
        pop     af          ;retrieve bank
        push    af          ;save bank again
        call    DMALoad

        ;push    bc
        ;push    de
        ;push    hl
        ;call    GetInput
        ;pop     hl
        ;pop     de
        ;pop     bc

        ;subtract from count tiles we took care of
        ld      a,b         
        sub     c
        jr      z,.loadTilesDone
        ld      b,a

        ;advance source
        push    de
        ld      de,1024
        add     hl,de
        pop     de

        ;advance destination
        push    hl
        ld      hl,1024 
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        ;if >= $9800 then wrap to $8800
        ld      a,d
        cp      $98
        jr      c,.continueLoadTiles

        sub     $10
        ld      d,a

        jr      .continueLoadTiles

.loadTilesDone
        pop     af
        pop     hl
        pop     de
        pop     bc

        ret
        
;---------------------------------------------------------------------
; Routine:      LoadCinemaPalette
; Arguments:    a  - byte offset to load into (e.g. 0 for tile 
;                    palette, 64 for sprite palette, 56 for text box
;                    palette)
;                    (32-63)
;               hl - addr of palette data to load (expecting
;                    spec, lobyte, hibyte triplets)
; Alters:       af, hl
; Description:  Loads the specified palette into GamePalette using
;               the spec byte to calculate where to store
;---------------------------------------------------------------------
LoadCinemaPalette:
        push    bc
        push    de

        ld      b,a   ;b is offset for bg or sprite palette
        ld      a,FADEBANK
        ld      [$ff70],a

        ;load palette into [gamePalette]
        ld      a,[hl+]        ;num colors
        ld      c,a

.loadPalette
        ld      d,((gamePalette>>8) & $ff)
        ld      a,[hl+]        ;read spec & determine correct pos
        and     63
        add     b 
        add     (gamePalette & $ff)
        ld      e,a

        ld      a,[hl+]        ;low byte of color
        ld      [de],a 
        inc     de
        ld      a,[hl+]        ;high byte of color
        ld      [de],a 
        inc     de
        dec     c
        jr      nz,.loadPalette

        pop     de
        pop     hl
        ret


;---------------------------------------------------------------------
; Routine:      LoadCinemaTextBox
; Arguments:    a  - bank containing data
;               hl - addr of .bg data to load
; Alters:       af
; Description:  Loads in normal BG file with the following 
;               alterations:
;                 - tile map size should be 20x6
;                 - loads tile defs to $8880 e.g. 136-255 (overwriting 
;                   font)
;                 - adds 136 to each tile index
;                 - loads the tile map to $9c00
;                 - palette is loaded to gamePalette colors 28-31 
;                   regardless
;                 - of original index values
;---------------------------------------------------------------------
LoadCinemaTextBox::
        push    bc
        push    de
        push    hl

        ld      de,$8880
        call    LoadTileDefs

        ld      a,[hl+]  ;discard tile width (should be 20)
        ld      a,[hl+]  ;discard tile height (should be 6) 

        ;load tile indices
        ld      de,backBuffer

        ld      b,6  ;height loop

.tileIndexOuter
        ld      c,20 ;width loop

.tileIndexInner
        ld      a,[hl+]
        add     a,FIRST_TEXTBOX_TILE
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.tileIndexInner

        ;skip remaining pitch (32-20 = 12)
        push    hl
        ld      hl,12
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        dec     b
        jr      nz,.tileIndexOuter

        
        ;load tile attributes (packed 2:1 per byte)
        ld      de,attributeBuffer

        ld      b,6     ;height loop

.tileAttrOuter
        ld      c,10    ;width loop (20 tiles / 2 attr per tile)

.tileAttrInner
        ld      a,[hl+]
        push    af
        swap    a
        and     %00001111
        or      %00000111    ;make palette 7
        ld      [de],a
        inc     de
        pop     af
        and     %00001111
        or      %00000111    ;make palette 7
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.tileAttrInner

        ;skip remaining pitch (32-20 = 12)
        push    hl
        ld      hl,12
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        dec     b
        jr      nz,.tileAttrOuter

        ld      a,56  ;load palette 0 as palette 7 (colors 0-3 to 28-31)
        call    LoadCinemaPalette

.done
        ld      a,OBJROM
        call    SetActiveROM

        call    GfxBlitBackBufferToWindow

        ;necessary (for loadbg) though I'm not sure why!!
        call    VWait
        ;ld      a,1     ;necessary (for loadbg) though I'm not sure why!!
        ;call    Delay

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CinemaBlitRect
; Arguments:    bc - tile width, height to copy
;               de - dest tile (i,j) to blit to
;               hl - source tile (i,j) to blit from
; Alters:       af
; Description:  Copies tiles from the tileShadowBuffer and the
;               attributeShadowBuffer from one place to another
;---------------------------------------------------------------------
CinemaBlitRect::
        push    bc
        push    de
        push    hl

        ;get destination address (tileShadowBuffer + j*pitch + i)
        push    hl
        ld      h,d
        ld      l,e
        call    ConvertXYToLocHL
        ld      d,h
        ld      e,l
        pop     hl

        ;get start address
        call    ConvertXYToLocHL

        ;blit the tile indices
        ld      a,TILESHADOWBANK
        ld      [$ff70],a
        call    .blitSubroutine

        ;switch to attributes and copy those too
        ld      a,ATTRSHADOWBANK
        ld      [$ff70],a
        call    .blitSubroutine

        pop     hl
        pop     de
        pop     bc
        ret

.blitSubroutine
        ;hl source, de dest, bc width & height
        push    bc
        push    de
        push    hl

.outer  ;copy a row
        push    bc          ;save width & height
        push    hl          ;save source start
        push    de          ;save dest start

.inner  ;copy a byte
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     b
        jr      nz,.inner

        pop     de          ;retrieve dest start & add pitch to it
        ld      h,0
        ld      a,[mapPitch]
        ld      l,a
        add     hl,de
        ld      d,h
        ld      e,l

        pop     hl          ;retrieve source start & add pitch to it
        push    de
        ld      d,0
        ld      e,a         ;a set above
        add     hl,de
        pop     de

        pop     bc          ;retrieve width & height
        dec     c           ;one more row taken care of
        jr      nz,.outer

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CinemaSpotAnimationRandomHorizontalFrames
; Arguments:    a  - number of possible frames
;               bc - metatile width, height to copy
;               de - dest metatile (i,j) to blit to
;               hl - corner of first source metatile (i,j) blit from
; Alters:       af
; Description:  Picks a new random frame and blits it to the image.
;---------------------------------------------------------------------
CinemaSpotAnimationRandomHorizontalFrames::
        push    bc
        push    hl

        ;pick a random frame
        dec     a
        call    GetRandomNumZeroToN

        ;scoot source over by (numframe * width of one frame)
        push    bc
        ld      c,a
        xor     a
.timesWidth
        add     b
        dec     c
        jr      nz,.timesWidth
        add     h
        ld      h,a
        pop     bc

        call    CinemaBlitRect

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      CinemaSpotAnimationRandomVerticalFrames
; Arguments:    a  - number of possible frames
;               bc - metatile width, height to copy
;               de - dest metatile (i,j) to blit to
;               hl - corner of first source metatile (i,j) blit from
; Alters:       af
; Description:  Picks a new random frame and blits it to the image.
;---------------------------------------------------------------------
CinemaSpotAnimationRandomVerticalFrames::
        push    bc
        push    hl

        ;pick a random frame
        dec     a
        call    GetRandomNumZeroToN

        ;scoot source down by (numframe * height of one frame)
        push    bc
        ld      b,a
        xor     a
.timesWidth
        add     c
        dec     b
        jr      nz,.timesWidth
        add     l
        ld      l,a
        pop     bc

        call    CinemaBlitRect

        pop     hl
        pop     bc
        ret

;---------------------------------------------------------------------
; Routines:     StdWaitDialog
;               StdWaitDialogNoClear
; Arguments:    a - desired next state after dialog
; Alters:       af,hl
;---------------------------------------------------------------------
StdWaitDialogNoClear::
        push    hl
        ld      hl,dialogSettings
        set     DLG_NOCLEAR_BIT,[hl]
        pop     hl
StdWaitDialog::
        ld      a,h
        ldio    [mapState+1],a
        ld      a,l
        ldio    [mapState],a
        call    SaveIdle
        ret

;---------------------------------------------------------------------
SECTION "CharacterAnimationCode",ROMX
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Routines:     AnimateSkippy
;               AnimateFlour
;               AnimateFlourDriving
;               AnimateBA
;               AnimateBS
;               AnimateHaiku
;               AnimateBRAINIAC
; Arguments:    d - duration (roughly d*100 60ths or d*1.6 sec)
;---------------------------------------------------------------------
AnimateSkippy::
        ld      b,d
.skippyEyes
        ld      c,10

.skippyTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      3
        ld      a,3
        jr      nc,.animateSkippyMouth
        ld      a,1

.animateSkippyMouth
        ;animate mouth
        ld      bc,$0402
        ld      de,$0609
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     c
        jr      nz,.skippyTalk

        ;animate eyes
        push    bc
        ld      a,5
        ld      bc,$0403
        ld      de,$0606
        ld      hl,$1402
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.skippyEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0403
        ld      de,$0606
        ld      hl,$1402
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

AnimateFlour::
        ld      b,d
.flourEyes
        ld      c,10

.flourTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      1
        ld      a,4
        jr      nz,.animateFlourMouth
        ld      a,1

.animateFlourMouth
        ;animate mouth
        ld      bc,$0502
        ld      de,$0906
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.flourTalk

        ;animate eyes
        push    bc
        ld      a,3
        ld      bc,$0603
        ld      de,$0903
        ld      hl,$1900
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.flourEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0603
        ld      de,$0903
        ld      hl,$1900
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

AnimateFlourDriving::
        ld      b,1
.flourEyes
        ld      a,d    ;c=d*10
        rlca
        rlca
        rlca
        add     d
        add     d
        ld      c,a

.flourTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,c
        cp      1
        ld      a,6
        jr      nz,.animateFlourMouth
        ld      a,1

.animateFlourMouth
        ;animate mouth
        ld      bc,$0604
        ld      de,$0703
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     c
        jr      nz,.flourTalk

        dec     b
        jr      nz,.flourEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0604
        ld      de,$0703
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        ld      a,10
        call    Delay
        ret

AnimateBA::
        ld      b,1

        ld      a,d    ;c=d*10
        rlca
        rlca
        rlca
        add     d
        add     d
        ld      c,a

.baEyes
        push    bc
        ld      a,5
        call    Delay

        ld      a,c
        cp      1
        ld      a,3
        jr      nz,.animateFrames
        ld      a,1

.animateFrames
        ;animate mouth
        ld      bc,$0702
        ld      de,$0604
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.baEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0702
        ld      de,$0604
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

AnimateBS::
        ld      b,1

        ld      a,d    ;c=d*10
        rlca
        rlca
        rlca
        add     d
        add     d
        ld      c,a

.bsEyes
        push    bc
        ld      a,5
        call    Delay

        ld      a,c
        cp      1
        ld      a,3
        jr      nz,.animateFrames
        ld      a,1

.animateFrames
        ;animate mouth
        ld      bc,$0401
        ld      de,$0604
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.bsEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0401
        ld      de,$0604
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

AnimateHaiku::
        ld      b,21
.haikuHand
        ld      c,2

.haikuTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      1
        ld      a,4
        jr      nz,.animateHaikuMouth
        ld      a,1

.animateHaikuMouth
        ;animate mouth
        ld      bc,$0404
        ld      de,$0605
        ld      hl,$1408
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     c
        jr      nz,.haikuTalk

        ;animate hand
        push    bc
        ld      a,21
        sub     b     ;frame of hand (1-21)
        cp      6
        jr      c,.handFrameSet   ;1st line 0-5
        sub     6
        cp      6
        jr      c,.handFrameSet   ;2nd line 0-5
        sub     5
        cp      3
        jr      c,.handFrameSet   ;2nd line 1-2
        sub     3
        cp      6
        jr      c,.handFrameSet   ;3rd line 0-5
        xor     a                 ;final, done
.handFrameSet
        ;times six
        rlca           ;times 2
        ld      b,a    ;b = a*2
        rlca           ;times 2 again (a0 * 4)
        add     b      ;a*6 = a*2 + a*4
        add     20
        ld      h,a
        ld      l,0
        ld      bc,$0608
        ld      de,$0e04
        call    CinemaBlitRect
        pop     bc
        dec     b
        jr      nz,.haikuHand

        ld      a,40
        call    Delay

        ret

AnimateBRAINIAC::
        ld      b,d
.brainiacEyes
        ld      c,10

.brainiacTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      1
        ld      a,2
        jr      nz,.animate
        ld      a,1

.animate
        ;animate mouth
        ld      bc,$0402
        ld      de,$0908
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     c
        jr      nz,.brainiacTalk

        ;animate eyes
        push    bc
        ld      a,4
        ld      bc,$0702
        ld      de,$0604
        ld      hl,$1402
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.brainiacEyes
        ret

AnimateLadyFlower::
        ld      b,d
.eyes
        ld      c,10

.talk
        push    bc
        ld      a,5
.animateBeeLoop
        call    .animateBee
        dec     a
        jr      nz,.animateBeeLoop

        ld      a,b
        cp      1
        ld      a,2
        jr      nz,.animate
        ld      a,1

.animate
        ;animate mouth
        ld      bc,$0101
        ld      de,$0a06
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.talk

        ;animate eyes
        push    bc
        ld      a,3
        ld      bc,$0302
        ld      de,$0904
        ld      hl,$1500
        call    CinemaSpotAnimationRandomVerticalFrames

        ;animate bg flowers
        ld      a,2
        ld      bc,$0302
        ld      de,$0008
        ld      hl,$1406
        call    CinemaSpotAnimationRandomVerticalFrames

        ld      a,2
        ld      bc,$0202
        ld      de,$0508
        ld      hl,$140a
        call    CinemaSpotAnimationRandomHorizontalFrames

        ld      a,2
        ld      bc,$0201
        ld      de,$020a
        ld      hl,$140c
        call    CinemaSpotAnimationRandomHorizontalFrames

        ld      a,2
        ld      bc,$0202
        ld      de,$0f0a
        ld      hl,$140d
        call    CinemaSpotAnimationRandomHorizontalFrames

        ld      a,2
        ld      bc,$0202
        ld      de,$1208
        ld      hl,$140f
        call    CinemaSpotAnimationRandomHorizontalFrames

        pop     bc
        dec     b
        jr      nz,.eyes
        ret

VAR_BEEPOS EQU 0
.animateBee
        push    af
        push    bc
        push    hl

        ld      a,1
        call    Delay

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

        pop     hl
        pop     bc
        pop     af

        ret

AnimateLadyFlowerDistress::
        ld      a,d
        and     %10000000
        ld      b,a

        ld      a,d    ;c=d*8
        and     %01111111
        rlca
        rlca
        rlca
        ld      c,a

.ladyFace
        push    bc

        bit     7,b
        jr      z,.afterJiggle
        ld      a,%111
        call    GetRandomNumMask
        or      a
        jr      nz,.afterJiggle

        ld      a,15
        ldio    [jiggleDuration],a

.afterJiggle
        ld      a,8
        call    Delay

        ld      a,c
        cp      1
        ld      a,4
        jr      nz,.animateFrames
        ld      a,1

.animateFrames
        ;animate mouth
        ld      bc,$0506
        ld      de,$0702
        ld      hl,$1500
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.ladyFace

        ;open eyes at end
        ld      a,1
        ld      bc,$0506
        ld      de,$0702
        ld      hl,$1500
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

AnimateLadyFlowerRamp::
        ld      b,d
.ladyEyes
        ld      c,10

.ladyTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      2
        ld      a,2
        jr      nc,.animateLadyMouth
        ld      a,1

.animateLadyMouth
        ;animate mouth
        ld      bc,$0202
        ld      de,$0806
        ld      hl,$250c
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.ladyTalk

        ;animate eyes
        push    bc
        ld      a,4
        ld      bc,$0403
        ld      de,$0703
        ld      hl,$2500
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.ladyEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0403
        ld      de,$0703
        ld      hl,$2500
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

AnimateCaptainRamp::
        ld      b,d
.flourEyes
        ld      c,10

.flourTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      2
        ld      a,4
        jr      nc,.animateFlour
        ld      a,1

.animateFlour
        ;animate mouth
        ld      bc,$0402
        ld      de,$1312
        ld      hl,$2009
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.flourTalk

        ;animate eyes
        push    bc
        ld      a,3
        ld      bc,$0503
        ld      de,$130f
        ld      hl,$2000
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.flourEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0503
        ld      de,$130f
        ld      hl,$2000
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

AnimateCaptainGunpoint::
        ld      a,d
        rlca         ;frames *8
        rlca
        ld      b,a
.flourEyes
        ld      c,3

.flourTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      8
        ld      a,2
        jr      nc,.animateFlour
        ld      a,1

.animateFlour
        ;animate mouth
        ld      bc,$0402
        ld      de,$0c06
        ld      hl,$1402
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     c
        jr      nz,.flourTalk

        ;animate eyes
        push    bc
        ld      a,2
        ld      bc,$0602
        ld      de,$0b04
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        pop     bc
        dec     b
        jr      nz,.flourEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0602
        ld      de,$0b04
        ld      hl,$1400
        call    CinemaSpotAnimationRandomHorizontalFrames
        ld      a,10
        call    Delay

        ret

AnimatePreacher::
        ld      b,1

        ld      a,d    ;c=d*10
        rlca
        rlca
        rlca
        add     d
        add     d
        ld      c,a

.preacherEyes
        push    bc
        ld      a,5
        call    Delay

        ld      a,c
        cp      1
        ld      a,2
        jr      nz,.animateFrames
        ld      a,1

.animateFrames
        ;animate mouth
        ld      bc,$0302
        ld      de,$0906
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.preacherEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0302
        ld      de,$0906
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

AnimateCaptainAtWedding::
        ld      b,1

        ld      a,d    ;c=d*10
        rlca
        rlca
        rlca
        add     d
        add     d
        ld      c,a

.captainEyes
        push    bc
        ld      a,5
        call    Delay

        ld      a,c
        cp      1
        ld      a,4
        jr      nz,.animateFrames
        ld      a,1

.animateFrames
        ;animate mouth
        ld      bc,$0404
        ld      de,$0505
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.captainEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0404
        ld      de,$0505
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

AnimateLadyAtWedding::
        ld      b,d
.ladyEyes
        ld      c,10

.ladyTalk
        push    bc
        ld      a,5
        call    Delay

        ld      a,b
        cp      2
        ld      a,2
        jr      nc,.animateLadyMouth
        ld      a,1

.animateLadyMouth
        ;animate mouth
        ld      bc,$0202
        ld      de,$0b05
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.ladyTalk

        ;animate eyes
        push    bc
        ld      a,2
        ld      bc,$0402
        ld      de,$0a03
        ld      hl,$1404
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.ladyEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0402
        ld      de,$0a03
        ld      hl,$1404
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

AnimateGyroAtWedding::
        ld      b,d
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
        jr      nc,.animateGyroMouth
        ld      a,1

.animateGyroMouth
        ;animate mouth
        ld      bc,$0a05
        ld      de,$0606
        ld      hl,$1800
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.gyroTalk

        ;animate eyes
        push    bc
        ld      a,4
        ld      bc,$0402
        ld      de,$0604
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.gyroEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0402
        ld      de,$0604
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

AnimateGyroOnScreen::
        ld      b,d
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
        jr      nc,.animateGyroMouth
        ld      a,1

.animateGyroMouth
        ;animate mouth
        ld      bc,$0903
        ld      de,$0607
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.gyroTalk

        ;animate eyes
        push    bc
        ld      a,3
        ld      bc,$0301
        ld      de,$0705
        ld      hl,$1406
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     b
        jr      nz,.gyroEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0301
        ld      de,$0705
        ld      hl,$1406
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay

        ret

AnimateBSDriving::
        ld      b,1

        ld      a,d    ;c=d*10
        rlca
        rlca
        rlca
        add     d
        add     d
        ld      c,a

.bsEyes
        push    bc
        ld      a,5
        call    Delay

        ld      a,c
        cp      1
        ld      a,3
        jr      nz,.animateFrames
        ld      a,1

.animateFrames
        ;animate mouth
        ld      bc,$0402
        ld      de,$0803
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        pop     bc
        dec     c
        jr      nz,.bsEyes

        ;open eyes at end
        ld      a,1
        ld      bc,$0402
        ld      de,$0803
        ld      hl,$1400
        call    CinemaSpotAnimationRandomVerticalFrames
        ld      a,10
        call    Delay
        ret

;***WARNING*** Not HOME Section

