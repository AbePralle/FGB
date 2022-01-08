;12.29.1999

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"


;world map











;miscellaneous areas





SECTION "SysVariables",WRAM0[$c000]
backBuffer::  DS 608 ;32x19; automatically copied to VRAM every vblank
                     ;NOTE: addr must start on multiple of 16
                     ;NOTE: attribute buffer starts 160 bytes later
                     ;at $c300

;0 - $c260 - map attributes & calculation helpers
mapOffsetNorth::        DS 2   ;this memory location + 6 must not
mapOffsetEast::         DS 2   ;have carry
mapOffsetSouth::        DS 2
mapOffsetWest::         DS 2

;8
mapWidth::              DS 1        ;8    $c268
mapPitch::              DS 1        ;9    $c269
mapPitchMinusOne::      DS 1        ;10   $c26a
mapPitchMinusOneComplement :: DS 1  ;11   $c26b
mapSkip::               DS 1        ;difference between width and pitch
mapHeight::             DS 1        ;13   $c26d
mapColor:               DS 2        ;14   $c26e
firstHero::             DS 1        ;16 $c270 class index of first hero
numBGTiles:             DS 1        ;17   $c271
bgDestPtr:              DS 2        ;18   $c272
numFGTiles::            DS 1        ;20   $c274
numFGTiles_save:        DS 1    ;addr by offset in SaveFGTileInfo
numClasses::            DS 1        ;22 $ c276
numClasses_save:        DS 1        ;     $c277
fgDestPtr::             DS 2    ;ref by offset in SaveFGTileInfo
fgDestPtr_save:         DS 2    ;for use in SaveFGTileInfo
loadTileL:              DS 1        ;     $c27c
loadTileH:              DS 1        ;     $c27d

;30
mapLeft::               DS 1        ;     $c27e
mapRight::              DS 1        ;     $c27f
mapRightPlusOne::       DS 1        ;     $c280
mapTop::                DS 1        ;     $c281
mapBottom::             DS 1        ;     $c282
mapBottomPlusOne::      DS 1        ;     $c283
mapMaxLeft::            DS 1        ;     $c284
mapMaxTop::             DS 1        ;     $c285
camera_i::              DS 1        ;     $c286
camera_j::              DS 1        ;     $c287
distToWall_N::          DS 1        ;     $c288
distToWall_E::          DS 1        ;     $c289
distToWall_S::          DS 1        ;     $c28a
distToWall_W::          DS 1        ;     $c28b

;44
mapTotalSize::          DS 2  ;location 1 beyond end, e.g. $dc00  ($c28c)
mapExitLinks::          DS 16       ;     $c28e

desiredMapLeft::        DS 1       ;     $c29e
desiredMapTop::         DS 1       ;     $c29f
curPixelOffset_x::      DS 1       ;     $c2a0
curPixelOffset_y::      DS 1       ;     $c2a1
desiredPixelOffset_x::  DS 1       ;     $c2a2
desiredPixelOffset_y::  DS 1       ;     $c2a3
scrollAccelState_x::    DS 1       ;     $c2a4
scrollAccelState_y::    DS 1       ;     $c2a5

mapBank::               DS 2       ;     $c2a6
mapContents::           DS 2       ;     $c2a8
dialogBank::            DS 1       ;     $c2aa    xlink
curTrackStackL::        DS 1       ;     $c2ab    for music

;----routine parameters----------------------------------------------
;74
methodParamL::          DS 1       ;     $c2ac
methodParamH::          DS 1       ;     $c2ad
bulletDirection::       DS 1       ;     $c2ae
bulletLocation::        DS 2       ;     $c2af
bulletColor::           DS 1       ;     $c2b1
tempL::                 DS 1       ;     $c2b2
tempH::                 DS 1       ;     $c2b3
delTempL::              DS 1       ;     $c2b4
delTempH::              DS 1       ;     $c2b5

;84
moveAlignPrecision::    DS 1       ;     $c2b6
fireBulletDirection::   DS 1       ;     $c2b7
bulletDamage::
fireBulletDamage::      DS 1       ;     $c2b8
fireBulletSound::       DS 2       ;     $c2b9
fireBulletLocation::    DS 2       ;     $c2bb
explosionInitialFrame:: DS 1       ;     $c2bd
myGroup::               DS 1       ;     $c2be
myFacing::              DS 1       ;     $c2bf
secondChoiceDirection:: DS 1       ;     $c2c0

;95
fadeSteps::             DS 1       ;     $c2c1
fadeStepsToGo::         DS 1       ;     $c2c2

dmaLoadSrc0::           DS 2       ;     $c2c3
dmaLoadDest0::          DS 2       ;     $c2c5
dmaLoadLen0::           DS 1       ;     $c2c7
dmaLoadSrc1::           DS 2       ;     $c2c8
dmaLoadDest1::          DS 2       ;     $c2ca
dmaLoadLen1::           DS 1       ;     $c2cc

;97
metaSprite_y::          DS 1       ;     $c2cd
metaSprite_x::          DS 1       ;     $c2ce
metaSprite_first_x::    DS 1       ;     $c2cf

bgFlags::               DS 1    ;set in some methods to look at later
                                ;$c2d0

;----environment info and control------------------------------------
;101
mapDialogClassIndex::   DS 10   ;$c2d1
mapHeroZone::           DS 1    ;$c2db

specialFX::             DS 1    ;$c2dc
displayType::           DS 1    ;0 for map, 1 for cinema  $c2dd
scrollSprites::         DS 1    ;$c2de
heroesIdle::            DS 1    ;1=idle, 0=active  ;$c2df


;----class stuff-----------------------------------------------------
;116
oldZone::               DS 1     ;$c2e0
firstFreeObj::          DS 1     ;index of first free node $c2e1
curObjIndex::           DS 1     ;$c2e2
iterateNext::           DS 2     ;$c2e3
oamFindPos::            DS 1     ;$c2e5
numFreeSprites::        DS 1     ;$c2e6
nextObjIndex::          DS 1     ;$c2e7
levelCheckStackPos::    DS 2     ;$c2e8

;126
objTimerBase::          DS 1     ;$c2ea
objTimer60ths::         DS 1     ;$c2eb
heroTimerBase::         DS 1     ;$c2ec
heroTimer60ths::        DS 1     ;$c2ed

;130
baMoved::               DS 1    ;used in BA check  $c2ee
bsMoved::               DS 1    ;used in BS check  $c2ef
  ;--set above to zero in LinkRemakeList
heroJoyIndex::          DS 1    ;bits 5:0 grenade, lady, captain,
                                ;haiku, bs, ba     $c2f0

myJoy::                 DS 1    ;$c2f1
curInput0::             DS 1    ;$c2f2
curInput1::             DS 1    ;$c2f3
dialogJoyIndex::        DS 1    ;0 or 1   $c2f4
getLocInitFacing::      DS 1    ;$c2f5
losLimit::              DS 1    ;tiles to scan (0=infinite or 1) $c2f6
dialogSpeakerIndex::    DS 1    ;in ChooseFromDialogAlterates $c2f7

levelCheckSkip::        DS 4     ;$c2f8
jiggleLoc::             DS 1    ;random pos for async jiggle $c2fc
dialogSettings::        DS 1    ;[:0] show border, [:1] show continue
                                ;[:2] wait release (see defs.h DLG_*)
fadeRange::             DS 1    ;defaults to 64 (all colors) but
                                ;can be set to 32 (or the like) for
                                ;BG fades only (is reset to 64 after)
guardAlarm::            DS 1    ;guard sounded the alarm?
;next pos:  $c2fe
;160/160

blankSpace:
PRINT "blank space 1: "
PRINT (768 - (blankSpace - backBuffer))
PRINT "\n"

DS (768 - (blankSpace - backBuffer))

attributeBuffer::       DS 608   ;see notes on backBuffer above

;game state variables $c560
gameState::
heroesAvailable::       DS 2  ;$c560
heroesUsed::            DS 1  ;$c562
heroesLocked::          DS 1  ;$c563
appomattoxMapIndex::    DS 1  ;$c564
respawnMap::            DS 2  ;$c565  ;map to go to after dying
joinMap::               DS 2  ;$c567  ;map to join for 2nd player

;pad
allIdle::               DS 1  ;$c569  ;no one allowed to move
dialogIdleSettings::    DS 1  ;$c56a
canJoinMap::            DS 1  ;$c56b
checkTemp::             DS 1  ;$c56c

amLinkMaster::          DS 1  ;$ff=no link/slave, $fe=no link/master
                              ;1=link/master, 0=link/slave  $c56d
lastLinkAction::        DS 1  ;$00=receive, $01=transmit    $c56e
checkInputInMainLoop::  DS 1  ;$c56f
amShowingDialog::       DS 1  ;$c570
amSynchronizing:        DS 1  ;$c571
longCallTempA::         DS 1  ;$c572
amChangingMap::         DS 1  ;$c573
curHeroAddressL::       DS 1  ;LCByte of hero address        $c574
heroesPresent::         DS 1  ;%000000ba, b=hero1, a=hero0   $c575

curLevelIndex::         DS 2  ;in BCD  $c576
curLevelStateIndex::    DS 1  ;0-255   $c578
timeToChangeLevel::     DS 1  ;$c579

musicOverride1::        DS 1  ;$c57a
musicOverride4::        DS 1  ;$c57b

linkBailOut::           DS 4  ;$c57c

fadeCurPalette::        DS 128   ;$c580
;128

bgTileMap::             DS 256   ;$c600
bgAttributes::          DS 256   ;$c700

;$c800-$c81f hero data
hero0_data::
curJoy0::               DS 1  ;NOTE:  MSByte of address should not
hero0_index::           DS 1  ;change between here and the end of
hero0_object::          DS 2  ;the hero stuff
hero0_bullet_index::    DS 1
hero0_class::           DS 2
hero0_enterLevelFacing::    DS 1  ;misnomer, actually exit direction
hero0_enterLevelLocation::  DS 2
hero0_i::               DS 1
hero0_j::               DS 1
hero0_type::            DS 1  ;HERO_BA_FLAG etc
hero0_health::          DS 1
hero0_moved::           DS 1
hero0_puffCount::       DS 1
;NOTE change HERODATASIZE if adding more than 16 vars here

;$c810
hero1_data::
curJoy1::               DS 1
hero1_index::           DS 1
hero1_object::          DS 2
hero1_bullet_index::    DS 1  ;See NOTE above
hero1_class::           DS 2  ;e.g. 1030 = BA
hero1_enterLevelFacing::    DS 1  ;misnomer, actually exit direction
hero1_enterLevelLocation::  DS 2
hero1_i::               DS 1
hero1_j::               DS 1
hero1_type::            DS 1  ;HERO_BA_FLAG etc
hero1_health::          DS 1
hero1_moved::           DS 1
hero1_puffCount::       DS 1
;NOTE change HERODATASIZE if adding more than 16 vars here

;$c820 variables for level check in RAM
levelVars::             DS 64

;$c860 music vars
musicBank::              DS  1   ;c860
musicNoteCountdownInit:: DS  1   ;c861
musicNoteCountdown::     DS  1   ;c862
musicTrack1Pos::         DS  2   ;c863
musicTrack2Pos::         DS  2   ;c865
musicTrack3Pos::         DS  2   ;c867
musicTrack4Pos::         DS  2   ;c869
musicInstrument1::       DS  5   ;c86b
musicInstrument2::       DS  4   ;c870
musicInstrument3::       DS  4   ;c874
musicInstrument4::       DS  4   ;c878
musicWaveform::          DS  16  ;c87c
musicStackL1::           DS  1   ;c88c
musicStackL2::           DS  1   ;c88d
musicStackL3::           DS  1   ;c88e
musicStackL4::           DS  1   ;c88f
musicRegisters::         DS  16  ;c890  r[15] = flags, :0 = z

numFreeObjects::         DS  1   ;$c8a0
fgFlags::                DS  1   ;$c8a1  temp variable, set in GetFGAttributes
lineZeroHorizontalOffset:: DS 1  ;$c8a2
musicAddress::           DS 2    ;$c8a3-c8a4
hblankVector::           DS 3    ;c8a5-c8a7
exitTileIndex::          DS 1    ;c8a8
bulletClassIndex::       DS 1    ;c8a9
inventory:               DS 16   ;c8aa-c8b9
dialogNPC_speakerIndex:: DS 1    ;c8ba   who's talking
dialogNPC_heroIndex::    DS 1    ;c8bb   hero being talked to
dialogBalloonClassIndex:: DS 1   ;c8bc   class that has dialog balloons
envEffectType::           DS 1   ;c8bd   type of env effect in use
bsUpgrades::              DS 1   ;c8be
baUpgrades::              DS 1   ;c8bf
haikuUpgrades::           DS 1   ;c8c0
iterateNumObjects::       DS 1   ;c8c1   try to keep frame rate at 30fps (UNUSED, screws synch)
standardFadeColor::       DS 1   ;c8c2
inLoadMethod::            DS 1   ;c8c3
loadStackPosL::           DS 1   ;c8c4
loadStackPosH::           DS 1   ;c8c5

;$c8c2 - $c8ff free space

SECTION "LevelCheckMethodSection",WRAM0[$c900]
levelCheckRAM::         DS $500      ;1.25 k of data

SECTION "SpriteMemory",WRAM0[$ce00]
spriteOAMBuffer::       DS $A0   ;must start on even $100

;In the following definitions note that some of the labels that are defined
;as the same address will be used to store values in different
;memory banks
SECTION "MapAndObjVars",WRAMX[$d000]
map::
objects::
headTable::
tileShadowBuffer::
attributeShadowBuffer::
zoneBuffer::
wayPointList::
  DS 256         ;bank 1, first 256 bytes of map
                 ;bank 2, start of 256 bytes of linked list head indices
                 ;bank 3, start of 4k of object storage
                 ;bank 4, start of 4k of tile shadow buffer
                 ;bank 5, start of 4k of attribute shadow buffer
                 ;bank 6, start of 4k of zone info
                 ;bank 7, start of 512 byte wayPointList

tailTable::
  DS 256         ;bank 1, bytes 256-512 of map
                 ;bank 2, indices of objects at tail of list
                 ;bank 3, bytes 256-512 of object storage
                 ;bank 7, wayPointList continued

pathList::
rainbowColors::
  ;$d200
  DS 256         ;bank 1, bytes 512-1024 of map (512 bytes)
                 ;bank 2, free
                 ;bank 3, bytes 512-1024 of object storage (512 bytes)
                 ;bank 7, start of 1024-byte pathList (512 bytes)

horizontalOffset::
  DS 144         ;bank 1, bytes 768-1024 of map (256)
                 ;bank 2, horizontal scroll position for each line (144)
                 ;bank 3, bytes 768-1024 of object storage (256)
                 ;bank 7, pathList continued (256)

  DS 112         ;bank 2, free

objExists::
  ;$d400
  DS 256         ;bank 1, bytes 1024-1535 of map
                 ;bank 2, 256 bytes validity of object index n
                 ;bank 3, bytes 1024-1535 of object storage
                 ;bank 7, pathList continued

FOFTable::
  ;$d500
  DS 256         ;bank 1, bytes 1024-1279 of map
                 ;bank 2, Group FOF table
                 ;bank 3, bytes 1024-1279 of object storage
                 ;bank 7, pathList continued

pathMatrix::
  ;$d600
  DS 256         ;bank 1, bytes 1536-1791 of map
                 ;bank 2, free
                 ;bank 3, bytes 1536-1791 of object storage
                 ;bank 7, 256 byte pathMatrix[16][16]

levelState::
fgTileMap::      ;bank 1, bytes 1792-2047 of map
  ;$d700
  DS 256         ;bank 2, index of first tile for each class
                 ;bank 3, bytes 1792-2047 of object storage
                 ;bank 7, 256 byte map state save levelState[256]

objClassLookup::
heroState::     ;UNUSED!
  ;$d800
  DS 256         ;bank 1, bytes 2048-2303 of map
                 ;bank 2, 256 byte lookup table for class type
                 ;bank 3, bytes 2048-2303 of object storage
                 ;bank 7, 256 byte heroState storage (16 bytes/hero)   UNUSED!

musicStack::
  ;$d900
  DS 256         ;bank 1, bytes 2304-2559 of map
                 ;bank 2, unused
                 ;bank 3, bytes 2304-2559 of object storage
                 ;bank 7, 128 byte stack for music code

associatedIndex::
flightCode::
  ;$da00
  DS 256         ;bank 1, bytes 2560-2815 of map
                 ;bank 2, 256 byte table of associated class indices
                 ;bank 3, bytes 2560-2815 of object storage
                 ;bank 7, 1-byte count + 85 3-byte flight codes

spritesUsed::
  ;$db00
  DS 128         ;bank 1, bytes 2816-3071 of map
                 ;bank 2, 40-byte lookup (1=sprite used, 0=free)
                 ;bank 3, bytes 2816-3071 of object storage
fadeFinalPalette::
  DS 128         ;bank 7, 128-byte fade final palette


;bgAttributes::
  ;$dc00
  DS 256         ;bank 2, free

fgAttributes::
  ;$dd00
  DS 256         ;bank 2, tile attributes for FG tiles
                 ;bank 1, bytes 3328-3583 of map
                 ;bank 3, bytes 3328-3583 of object storage

classLookup::
fadeDelta::      ;bank 1, bytes 3584-4095 of map
  ;$de00
  DS 192         ;bank 2, 512 byte table for class info
                 ;bank 3, bytes 3584-4095 of object storage
                 ;bank 7, 192 bytes of fade info
fadeError::
  DS 192         ;bank 7, 192 bytes of fade info

gamePalette::
  ;$df80
  DS 128         ;bank 7, 128 bytes of "true" game palette



SECTION "MapLoader",ROM0
;---------------------------------------------------------------------
; Routine:      LoadMap
; Arguments:    hl - index of map xxyy 0000 - 1515 in BCD
; Alters:       af
; Description:  Loads specified map
;---------------------------------------------------------------------
LoadMap::
        push    bc
        push    de
        push    hl

        push    hl

        ;clear out zone & exit memory
        ld      a,ZONEBANK
        ld      [$ff70],a
        ld      hl,$d000
        xor     a
        ld      [displayType],a

        ld      c,0     ;256
.clr1_o ld      b,16    ;*16
.clr1_i ld      [hl+],a
        dec     b
        jr      nz,.clr1_i
        dec     c
        jr      nz,.clr1_o

        pop     hl

        call    MapCoordsToIndex
        ld      l,a
        ld      h,0

        ;load in the level state for this level
        ld      a,l
        ld      [curLevelStateIndex],a
        ld      a,LEVELSTATEBANK
        ld      [$ff70],a
        push    hl
        ld      h,((levelState>>8) & $ff)
        ld      a,[hl]
        ldio    [mapState],a
        xor     a
        ldio    [mapState+1],a
        pop     hl

        ;multiply map index by 4 to find offset into address lookup
        sla     l       ;shift <<= 2
        rl      h
        sla     l
        rl      h
        ld      de,MapLookupTable
        add     hl,de

        ld      a,BANK(MapLookupTable)
        call    SetActiveROM

        ld      de,mapBank      ;start of 4 bytes of info storage
        ld      c,4
.loop   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop

        xor     a
        ld      [amSynchronizing],a
        ld      [hero0_index],a
        ld      [hero1_index],a
        ld      [heroJoyIndex],a

        ;set up one hero for now, hero 0 if we're master and hero 1
        ;if we're slave.
        ld      a,[amLinkMaster]
        or      a
        jr      z,.setMyHeroAs1

        ld      a,1
        ld      [hero0_index],a
        ld      a,[hero0_type]
        ;note joy index remains zero if we're master
        jr      .afterSetMyHero

.setMyHeroAs1
        ld      hl,heroJoyIndex
        ld      a,1
        ld      [hero1_index],a
        ld      a,[hero1_type]
        or      [hl]
        ld      [hl],a

.afterSetMyHero

        ;Check if we're linked up to another game
        ld      a,[amLinkMaster]
        bit     7,a
        jr      z,.amLinked
        jp      .afterLinkCheck

.amLinked
        ;am linked up.  See if I'm trying to join the same map
        ;as is already playing on the remote machine.
.checkSameMap
        ld      a,LGETMAPINDEX
        call    ExchangeByte
        cp      LGETMAPINDEX
        jr      z,.linkMachineChangingMapAlso
        call    CheckSimultaneousLCC
        jr      nz,.checkSameMap      ;must repeat
        jr      .compareMapIndex

.linkMachineChangingMapAlso
        ;Proceed if I'm the Link Master, wait and try again
        ;if I'm the slave.
        ld      a,[amLinkMaster]
        or      a
        jr      z,.checkSameMapTryAgain

        ;call    KillWaitScreen
        jp      .afterLinkCheck

.checkSameMapTryAgain
        call    ShowWaitScreen

        ;kill some time to allow host to do its thing
        ld      c,10
.checkSameMapDelay
        ld      a,LNULL
        call    ExchangeByte
        call    HandleRemoteInput
        dec     c
        jr      nz,.checkSameMapDelay
        jr      .checkSameMap

.compareMapIndex
        call    ReceiveByte   ;next byte will be the map index
        cp      $ff           ;wait code?
        jr      z,.checkSameMapTryAgain
        ld      b,a
        ;call    KillWaitScreen
        ld      a,[curLevelStateIndex]
        cp      b
        jr      z,.isSameMap
        jp      .afterLinkCheck        ;not the same map

.isSameMap
        ;same map; go ahead and synchronize to it
.requestSynchronize
        ld      a,LSYNCHRONIZE
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.requestSynchronize

        call    ReceiveByte  ;get the response
        cp      LSYNCHREADY
        jr      z,.readyToSynchronize

        ;Not ready.  Send a few null control codes to allow the other
        ;machine to continue game-play and then try again.
        call    ShowWaitScreen

.nullDelay_init
        ld      c,10
.nullDelay
        ld      a,LNULL
        call    ExchangeByte
        call    HandleRemoteInput
        dec     c
        jr      nz,.nullDelay
        ;jr      .requestSynchronize
        jr      .checkSameMap

.readyToSynchronize
        ld      hl,BailOutAddress
        xor     a
        call    SetLinkBailOutAddress

        call    KillWaitScreen

        ;send my desired entry direction so host can evaluate if there's
        ;a free spot
        ld      a,1                ;just a precaution for slave, host MUST do this
        ldio    [curObjWidthHeight],a
        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,[hl]
        call    TransmitByte

        call    ReceiveByte     ;go/nogo signal from host
        or      a
        jr      nz,.goSignal

        ;nogo
        jr      .nullDelay_init

.goSignal
        call    ReceiveByte
        ldio    [mapState],a
        call    ReceiveByte
        ldio    [mapState+1],a

        call    GuestExchangeHeroData

        ld      hl,heroJoyIndex
        ld      a,[hero1_type]
        or      [hl]
        ld      [hl],a

        ld      a,1
        ld      [amSynchronizing],a

.afterLinkCheck
        call    KillWaitScreen

        ;Let the map figure out how to load itself.  Typically
        ;will be just a call to ParseMap, but it could be different
        ;to do some cinematic stuff
        call    ClearBackBuffer

        ld      a,LVLOFFSET_LOAD
        call    CopyMapMethodToRAM
        ld      a,OBJROM
        call    SetActiveROM

        ld      hl,sp+0
        ld      a,l
        ld      [loadStackPosL],a
        ld      a,h
        ld      [loadStackPosH],a
        ld      a,1
        ld      [inLoadMethod],a

        call    levelCheckRAM
AfterLoadLevelMethod::
        xor     a
        ld      [inLoadMethod],a

        ld      a,[timeToChangeLevel]
        or      a
        jr      z,.stillOkay

        ;need to redo (perhaps cinematic)
        ;save the map state back where it came from
        ;if zero set to one to indicate we've been here
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
        jr      .done

.stillOkay
        ld      a,OBJROM
        call    SetActiveROM
        call    AddObjectsToObjList
        call    InitFOF

        ;Add the heroes to the map.  Add Host's hero first.
        ld      a,[amSynchronizing]
        or      a
        jr      z,.addZeroThenOne

        ld      a,[amLinkMaster]
        or      a
        jr      z,.addZeroThenOne

        ;add one then zero
        ld      hl,hero0_index
        push    hl
        ld      hl,hero1_index
        jr      .decidedHeroLoadOrder

.addZeroThenOne
        ld      hl,hero1_index
        push    hl
        ld      hl,hero0_index

.decidedHeroLoadOrder
        call    PrepSetupHero
        pop     hl
        call    PrepSetupHero

        call    PrepareForInitialMapDraw  ;adjust camera & calc offsets

        ld      a,LVLOFFSET_INIT
        call    CopyMapMethodToRAM
        ld      a,OBJROM
        call    SetActiveROM
        call    levelCheckRAM

        call    ClearBackBuffer

        ld      a,LVLOFFSET_CHECK
        call    CopyMapMethodToRAM
        ld      a,OBJROM
        call    SetActiveROM

        ;----continue synchronizing if warranted----------------------
        ld      a,[amSynchronizing]
        or      a
        jr      z,.afterSynchronization

.continueSynchronization
        LONGCALLNOARGS GuestContinueSynchronization

.afterSynchronization
        xor     a
        ld      [amSynchronizing],a

        ;turn LCD on and stuff
        ld      a,%11000011
        ld      [$ff40], a       ;lcdc control

.done
LoadMapDone:
        pop     hl
        pop     de
        pop     bc
        ret

BailOutAddress:
        ld      hl,0
        xor     a
        call    SetLinkBailOutAddress
        ld      a,1
        ld      [timeToChangeLevel],a
        jr      LoadMapDone

ShowWaitScreen:
        ld      a,[displayType]     ;shown the "waiting" screen yet
        or      a
        ret     nz

        ;load the "Waiting To Join" screen
        ld      a,BANK(waitingToJoin_bg)
        ld      hl,waitingToJoin_bg
        call    LoadCinemaBG
        ld      a,1
        call    Delay

        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade
        ret

KillWaitScreen:
        ;was I showing the "waiting to join" screen?
        ld      a,[displayType]
        or      a
        ret     z

        push    bc
        push    de
        push    hl
        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade
        ;call    DisplayOff
        xor     a
        ld      [displayType],a
        pop     hl
        pop     de
        pop     bc
        ret

.afterRemoveWaitScreen


.addHeroToMap
PrepSetupHero::
        ld      a,[hl+]           ;get hero index
        or      a
        ret     z                 ;hero not present

        ld      a,l               ;get hero number 0 or 1
IF HERODATASIZE!=16
  jr fix this
ENDC
        and     16
        swap    a
        ld      d,a               ;d is 0 or 1

        inc     hl                ;skip object L,H
        inc     hl
        inc     hl                ;skip bullet_index
        ld      a,[hl+]           ;bc = heroClass
        ld      c,a
        ld      a,[hl+]
        ld      b,a
        ld      a,[hl+]           ;enter level direction
        push    af
        ld      a,[hl+]           ;hl = entry location in XY
        ld      h,[hl]
        ld      l,a
        pop     af                ;retrieve entry direction
        call    SetupHero
        ret

PrepSetupHeroBC::
        ld      h,b
        ld      l,c
        jr      PrepSetupHero   ;ret will return to my caller

GuestExchangeHeroData:
        ;get the host's hero data
        ld      a,[amLinkMaster]
        or      a
        jr      z,.recvHero0_sendHero1   ;slave exchange

.recvHero1_sendHero0    ;master exchange
        ;turn on hero 1
        ld      a,1
        ld      [hero1_index],a

        ;set hero 1 joy index
        ld      hl,hero0_data    ;send this second
        push    hl

        ld      hl,hero1_data    ;recv this first
        jr      .afterExchangeHeroData

.recvHero0_sendHero1
        ;turn on hero 0
        ld      a,1
        ld      [hero0_index],a

        ld      hl,hero1_data
        push    hl
        ld      hl,hero0_data   ;recv dest

.afterExchangeHeroData
        ld      bc,HERODATASIZE
        xor     a
        call    ReceiveData

        ;send my hero data
        pop     hl
        ld      bc,HERODATASIZE
        xor     a
        call    TransmitData

        ret


;---------------------------------------------------------------------
; Routine:      MapCoordsToIndex
; Arguments:    hl - map number in bcd (e.g. 0205)
; Returns:      a - converted number (e.g. 82)
; Alters:       af
; Description:  Returns FromBCD(L) * 16 + FromBCD(H)
;---------------------------------------------------------------------
MapCoordsToIndex::
        push    hl

        ;Change bytes hl from BCD to normal
        ld      a,h
        call    BCDToNumber
        ld      h,a
        ld      a,l
        call    BCDToNumber
        ld      l,a

        ;a = l*16 + h  (h & l must be 0-15 for this code)
        ld      a,l
        swap    a
        add     h

        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      BCDToNumber
; Arguments:    a - a number in BCD (e.g. hex $19 = dec 19)
; Returns:      a - converted number
; Alters:       af
;---------------------------------------------------------------------
BCDToNumber:
        push    bc
        push    hl

        ;convert back to normal with:
        ;  a = a[7:4] * 10 + a[3:0]
        ld      b,a                     ;save A
        swap    a
        and     %00001111
        ld      hl,.lookupTimes10
        add     l
        ld      l,a
        ld      a,0
        adc     h
        ld      h,a
        ld      a,[hl]                  ;Upper nibble times 10
        ld      c,a
        ld      a,b
        and     %00001111
        add     c

        pop     hl
        pop     bc
        ret

.lookupTimes10
        DB  0,10,20,30,40,50,60,70,80,90

;---------------------------------------------------------------------
; Routine:      NumberToBCD
; Arguments:    a - a number (e.g. 19)
; Returns:      a - converted number (e.g. $19)
; Alters:       af
;---------------------------------------------------------------------
NumberToBCD::
        ;a[7:4] = num / 10, a[3:0] = num % 10;
        push    bc
        ld      b,0

.divide10
        cp      10
        jr      c,.dividedOut10

        inc     b
        sub     10
        jr      .divide10

.dividedOut10
        swap    b
        or      b

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      LookupInMapContents
; Arguments:    a  - offset in contents table to look up
;               [mapContents] must have been initialized
; Returns:      hl - address stored at requested offset
; Alters:       af, hl
; Description:  Adds the offset to the start of the MapContents and
;               returns the 16-bit value stored there
;---------------------------------------------------------------------
LookupInMapContents:
        push    de

        ld      d,0
        ld      e,a

        ld      a,[mapBank]
        call    SetActiveROM

        ld      a,[mapContents]
        ld      l,a
        ld      a,[mapContents+1]
        ld      h,a

        add     hl,de
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      SetupMapVarsFromWidthPitchAndHeight
; Arguments:    [mapWidth],[mapPitch],[mapHeight]
; Description:  Sets up:
;                 mapMaxLeft
;                 mapPitchMinusOne
;                 mapPitchMinusOneComplement
;                 mapSkip
;                 mapMaxTop
;---------------------------------------------------------------------
SetupMapVarsFromWidthPitchAndHeight::
        push    bc

        ;Get level dimensions width, pitch, and height
        ld      a,[mapWidth]
        ld      c,a
        sub     21
        ld      [mapMaxLeft],a
        ld      a,[mapPitch]
        push    af
        dec     a
        ld      [mapPitchMinusOne],a
        cpl
        ld      [mapPitchMinusOneComplement],a
        pop     af
        sub     c
        ld      [mapSkip],a          ;skip width calculated fr width & pitch
        ld      a,[mapHeight]
        ld      b,a                  ;height in b
        sub     19
        ld      [mapMaxTop],a

        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ParseMap
; Arguments:    [mapBank]/[mapContents]
; Description:  Loads a map
;---------------------------------------------------------------------
ParseMap::
        ;set bank and ptr to map
        ld      a,LVLOFFSET_MAP
        call    LookupInMapContents  ;point hl at map

        ld      a,[hl+]              ;get and discard version number
        ld      a,[hl+]              ;get # of classes
        ld      [numClasses],a       ;store # classes

        ;Clear/initialize memory locations
        ;set initial # of bg/fg tiles
        ld      a,40                 ;leave room for 2 sets of 4x4 hero
        ld      [numFGTiles],a       ;tiles (20*2)
        ld      a,1
        ld      [numBGTiles],a

        ;Set up ptrs to bg tile pattern mem and fg tile pattern mem
        ld      a,$80
        ld      [fgDestPtr],a        ;fg ptr gets $9280 (low byte)
        ld      a,$92                ;high byte
        ld      [fgDestPtr+1],a
        ld      a,$10
        ld      [bgDestPtr],a        ;bg ptr gets $9010 (low byte)
        ld      a,$90                ;high byte
        ld      [bgDestPtr+1],a

        ;Get index # of first monster
        ld      a,[hl+]
        ldio    [firstMonster],a

        ;discard first monster class (2 bytes)
        ld      a,[hl+]
        ld      a,[hl+]

        ;Load in class lookup table
        ld      a,[numClasses]
        ld      c,a                  ;set counter at # of classes
        ld      b,1                  ;index currently loading
        ;ld      de,classLookup+2     ;lookup table to store classes in

.loop   ld      a,[hl+]              ;load in low byte of class
        ld      [loadTileL],a
        ld      a,[hl+]              ;repeat with high byte
        ld      [loadTileH],a

        ;set classLookup[i] to point to addr of class methods
        call    SetClassLookupEntryForTile

        ;determine whether we're loading a BG tile or a monster tile
        ldio    a,[firstMonster]
        cp      b                    ;is firstMonster <= cur index?
        push    bc
        jr      z,.isMonsterTile
        jr      c,.isMonsterTile

.isBackgroundTile
        ld      c,0                  ;set c=0 to indicate BG tile
        jr      .nowLoadTile

.isMonsterTile
        ld      c,1                  ;set c=1 to indicate FG tile

.nowLoadTile
        call    LoadTile

        ;make sure we're back to the map bank
        ld      a,[mapBank]
        call    SetActiveROM

        pop     bc
        inc     b            ;next class

        ldio    a,[firstMonster]    ;just loaded last bg tile?
        cp      b
        jr      nz,.terminationTest
        ld      a,[numBGTiles]      ;already copied the remaining buffer?
        and     31
        call    nz,CopyBGWorkToVRAM ;not yet

.terminationTest
        dec     c            ;one less to go
        jr      nz,.loop

        ;current value of numClasses will be value of firstHero
        ld      a,[numClasses]
        ld      [firstHero],a

        ;final value of numClasses (past 2 heroes+bullets)
        add     4
        ld      [numClasses],a

        ;Get level dimensions width, pitch, and height
        ld      a,[hl+]              ;width
        ld      [mapWidth],a
        ld      a,[hl+]              ;pitch
        ld      [mapPitch],a
        ld      a,[hl+]              ;height
        ld      [mapHeight],a
        ld      b,a                  ;height in b
        call    SetupMapVarsFromWidthPitchAndHeight

        ;Get width*height class indices
        ld      a,MAPBANK            ;switch to map RAM bank
        ld      [$ff00+$70],a
        ld      d,h                  ;Switch to using de for retrieval
        ld      e,l
        ld      hl,map               ;and hl for storage


.outer0
        ld      a,[mapWidth]         ;width in c
        ld      c,a

        ;Load a row into memory
.inner0 ld      a,[de]               ;get a tile class index
        inc     de
        ld      [hl+],a              ;store it in RAM

        dec     c
        jr      nz,.inner0

        ;load excess with zero to make internal map power of two wide
        ld      a,[mapSkip]
        or      a
        jr      z,.afterFillExtra
        ld      c,a
        xor     a
.fillExtra
        ld      [hl+],a
        dec     c
        jr      nz,.fillExtra

.afterFillExtra
        dec     b
        jr      nz,.outer0

        ;hl contains location 1 beyond end of map
        ld      a,l
        ld      [mapTotalSize],a
        ld      a,h
        ld      [mapTotalSize+1],a

        ;Load background color
        ld      a,[de]               ;bg color low byte
        inc     de
        ld      [mapColor],a
        ld      l,a
        ld      a,[de]               ;bg color high byte
        inc     de
        ld      [mapColor+1],a
        ld      h,a
        ld      b,%10000000
        push    de
        ld      d,h
        ld      e,l
        call    SetupCommonColor
        pop     de

        call    ParseWayPointStuff
        call    ParseZones
        call    ParseExits
        call    SetBGSpecialFlags

        ld      b,255
        ld      hl,classExplosion
        call    SetClassLookupEntry

        ret

;---------------------------------------------------------------------
; Routine:      ClearBackBuffer
; Arguments:    None.
; Returns:      Nothing.
; Alters:       af
; Description:  Clears the backBuffer and attributeBuffer so that
;               horizontal offsets don't show any garbage
;---------------------------------------------------------------------
ClearBackBuffer::
        push    bc
        push    de
        push    hl

        ld      bc,608
        ld      d,0
        ld      hl,backBuffer
        xor     a
        call    MemSet

        ld      bc,608
        ld      d,0
        ld      hl,attributeBuffer
        xor     a
        call    MemSet

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetClassLookupEntryForTile
; Arguments:    [loadTileL/H] - tile index being loaded
;               b  - index in classLookup to load into
; Alters:
; Description:
;---------------------------------------------------------------------
SetClassLookupEntryForTile:
        push    bc
        push    de
        push    hl

        ld      a,OBJLISTBANK
        ld      [$ff70],a

        ;set de to point to classLookup[b] (times two)
        ld      d,0
        ld      e,b
        sla     e
        rl      d
        ld      hl,classLookup
        add     hl,de
        ld      d,h
        ld      e,l

        ld      a,[loadTileH]
        ld      h,a
        ld      a,[loadTileL]
        ld      l,a

        sla     l
        rl      h              ;hl *= 2
        ld      bc,classTable
        add     hl,bc

        ld      a,BANK(classTable)
        call    SetActiveROM
        ld      a,[hl+]        ;low byte of addr of class methods
        ld      [de],a
        inc     de
        ld      a,[hl+]        ;high byte
        ld      [de],a
        ld      a,OBJROM
        call    SetActiveROM
        ;inc     de

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      SetClassLookupEntry
; Arguments:    b  - index in classLookup to set
;               hl - ptr to class
; Alters:
; Description:
;---------------------------------------------------------------------
SetClassLookupEntry:
        push    bc
        push    de

        ld      a,OBJLISTBANK
        ld      [$ff70],a

        ;set de to point to classLookup[b] (times two)
        push    hl
        ld      d,0
        ld      e,b
        sla     e
        rl      d
        ld      hl,classLookup
        add     hl,de
        ld      d,h
        ld      e,l
        pop     hl

        ld      a,l            ;low byte of addr of class methods
        ld      [de],a
        inc     de
        ld      a,h            ;high byte
        ld      [de],a

        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ParseZones
; Arguments:    hl - pointer to start of zone data
; Alters:       all registers
; Description:  loads in zone attributes (parallel buffer to map)
;               Stored using 2:1 backed bytes and run-length encoding
;---------------------------------------------------------------------
ParseZones:
        ld      a,ZONEBANK       ;switch in RAM bank for zones
        ld      [$ff00+$70],a

        ld      hl,zoneBuffer    ;dest

        call    .getNextRLEData

        ;loop as usual
        ld      a,[mapHeight]    ;# of rows
        ld      b,a

.outer  ld      a,[mapWidth]     ;# of columns
        ld      c,a
        srl     c                ;divide by two

        ;save two bytes for each count
.inner  ld      a,[loadTileL]      ;what's our RLE count look like?
        or      a
        jr      nz,.continue

        push    bc
        call    .getNextRLEData
        pop     bc

.continue
        ld      a,[tempH]
        ld      [hl+],a
        ld      a,[tempL]
        ld      [hl+],a

        ld      a,[loadTileL]      ;decrement RLE count
        dec     a
        ld      [loadTileL],a
        ;jr      nz,.continue

        ;push    bc
        ;call    .getNextRLEData
        ;pop     bc

;.continue

        dec     c
        jr      nz,.inner

        ;reached the end of a row, advance destptr to next row
        push    bc
        xor     a
        ld      b,a
        ld      a,[mapSkip]
        ld      c,a
        add     hl,bc
        pop     bc

        dec     b
        jr      nz,.outer

        ret

.getNextRLEData
        ld      a,[de]           ;read in a run length
        inc     de
        ld      [loadTileL],a    ;store remaining # of bytes
        ld      a,[de]           ;read in run data
        inc     de
        ld      b,a
        swap    a
        and     $f               ;zone for first byte
        ld      [tempH],a
        ld      a,b
        and     $f
        ld      [tempL],a        ;zone for second byte
        ret


;---------------------------------------------------------------------
; Routine:      ParseExits
; Arguments:    hl - pointer to start of exit data
; Alters:       all registers
; Description:  loads in exit attributes (parallel buffer to map)
;               Stored using 2:1 backed bytes and run-length encoding
;---------------------------------------------------------------------
ParseExits:
        ld      a,ZONEBANK       ;switch in RAM bank for zones
        ld      [$ff00+$70],a

        ld      hl,zoneBuffer    ;dest

        call    .getNextRLEData

        ;loop as usual
        ld      a,[mapHeight]    ;# of rows
        ld      b,a

.outer  ld      a,[mapWidth]     ;# of columns
        ld      c,a
        srl     c                ;divide by two

        ;save two bytes for each count
.inner  ld      a,[loadTileL]      ;what's our RLE count look like?
        or      a
        jr      nz,.continue

        push    bc
        call    .getNextRLEData
        pop     bc

.continue
        ld      a,[tempH]
        or      [hl]
        ld      [hl+],a            ;exit in 7:4, zone in 3:0
        ld      a,[tempL]
        or      [hl]
        ld      [hl+],a

        ld      a,[loadTileL]      ;decrement RLE count
        dec     a
        ld      [loadTileL],a

        dec     c
        jr      nz,.inner

        ;reached the end of a row, advance destptr to next row
        push    bc
        xor     a
        ld      b,a
        ld      a,[mapSkip]
        ld      c,a
        add     hl,bc
        pop     bc

        dec     b
        jr      nz,.outer

        ;read in 16 bytes of map links
        ld      c,16
        ld      hl,mapExitLinks
.readLink
        ld      a,[de]
        inc     de
        ld      [hl+],a
        dec     c
        jr      nz,.readLink

        ret

.getNextRLEData
        ld      a,[de]           ;read in a run length
        inc     de
        ld      [loadTileL],a    ;store remaining # of bytes
        ld      a,[de]           ;read in run data
        inc     de
        ld      b,a
        and     $f0              ;exit for first byte (in 7:4)
        ld      [tempH],a
        ld      a,b
        swap    a
        and     $f0
        ld      [tempL],a        ;exit for second byte
        ret

;---------------------------------------------------------------------
; Routine:      SetBGSpecialFlags
; Arguments:    none
; Alters:       af
; Description:  Loops through the loaded map and for each background
;               tile with a special flag (WalkOver, ShootOver) sets
;               bit 7 of the exit/zone map.
;---------------------------------------------------------------------
SetBGSpecialFlags::
        push    bc
        push    de
        push    hl

        ;clear out bit 7 in zone bank
        ld      a,ZONEBANK
        ldio    [$ff70],a

        ld      hl,$d000
        ld      a,$e0
.clearZone
        res     7,[hl]
        inc     hl
        cp      h
        jr      nz,.clearZone


        ld      hl,map
        ld      de,bgAttributes

        ld      a,[mapHeight]
        ld      b,a

.outer
        push    bc
        ldio    a,[firstMonster]
        ld      b,a
        ld      a,[mapPitch]
        ld      c,a
        ld      a,MAPBANK
        ld      [$ff00+$70],a

.inner
        ld      a,[hl]             ;get a tile
        or      a
        jr      z,.notSpecial
        cp      b
        jr      nc,.notSpecial

        ;might be a Special tile
        ld      e,a                ;look up its BG attributes
        ld      a,TILEINDEXBANK
        ld      [$ff00+$70],a
        ld      a,[de]
        and     BG_FLAG_SPECIAL
        jr      z,.notSpecialResetRAMBank

        ;is Special type
        ld      a,ZONEBANK
        ld      [$ff00+$70],a

        set     7,[hl]

.notSpecialResetRAMBank
        ld      a,MAPBANK
        ld      [$ff00+$70],a

.notSpecial
        inc     hl
        dec     c
        jr      nz,.inner

        pop     bc
        dec     b
        jr      nz,.outer

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      ResetMyBGSpecialFlags
; Arguments:    hl - map location
; Alters:       af
; Description:  If this background tile has any special flags then
;               bit 7 of the exit/zone map is set.
;---------------------------------------------------------------------
ResetMyBGSpecialFlags::
        push    bc
        push    de

        ldio    a,[firstMonster]
        ld      b,a

        ld      a,MAPBANK
        ldio    [$ff70],a

        ld      a,[hl]             ;get a tile
        or      a
        jr      z,.notSpecial
        cp      b
        jr      c,.maybeSpecial

.isMonster
        ;get tile under monster
        ld      a,TILESHADOWBANK
        ld      [$ff70],a
        or      a
        jr      z,.notSpecial

.maybeSpecial
        ;might be a Special tile
        ld      d,((bgAttributes>>8)&$ff)
        ld      e,a                ;look up its BG attributes
        ld      a,TILEINDEXBANK
        ld      [$ff70],a
        ld      a,[de]
        and     BG_FLAG_SPECIAL
        jr      z,.notSpecial

        ;is Special type
        ld      a,ZONEBANK
        ld      [$ff00+$70],a

        set     7,[hl]
        jr      .done

.notSpecial
        ld      a,ZONEBANK
        ld      [$ff70],a
        res     7,[hl]

.done
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      ParseWayPointStuff
; Arguments:    hl - pointer to start of stored way point stuff
; Alters:       all registers
;---------------------------------------------------------------------
ParseWayPointStuff:
        ld      a,WAYPOINTBANK       ;switch in waypoint RAM bank
        ld      [$ff00+$70],a

        ;zero out waypoint list
        push    hl
        ld      c,0
        xor     a
        ld      hl,wayPointList
.zeroWayPoints
        ld      [hl+],a
        ld      [hl+],a
        dec     c
        jr      nz,.zeroWayPoints
        pop     hl

        ;512-byte wayPoint list (location*[256])
        ld      a,[de]               ;number of waypoints
        inc     de
        ld      [wayPointList],a
        or      a
        jr      nz,.continue

        ret     ;no waypoints, no nothing

.continue
        ld      c,a                  ;c is number of waypoints
        ld      a,[de]               ;pad, discard
        inc     de
        ld      hl,wayPointList+2    ;&wayPointList[1]

.wpLoad ld      a,[de]               ;copy high/low byte of waypoint
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a

        dec     c
        jr      nz,.wpLoad

        ;load paths
        ld      a,[de]               ;num paths
        inc     de
        ld      [pathList],a
        or      a
        jr      z,.afterPaths

        ld      c,a
        ld      hl,pathList+4        ;&pathList[1][0]

.pathLoad
        ld      a,[de]               ;each path has 4 waypoint indices
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

        dec     c
        jr      nz,.pathLoad

.afterPaths
        ;load pathMatrix[16][16]
        ld      hl,pathMatrix

        ld      b,16

.outer  ld      c,16

.inner  ld      a,[de]
        inc     de
        ld      [hl+],a

        dec     c
        jr      nz,.inner

        dec     b
        jr      nz,.outer

        ret


;---------------------------------------------------------------------
; Routine:      LoadTile
; Arguments:    [loadTileL/H] - tile number
;               b - index of class being loaded (0-255)
;               c - 0=bg tile, 1=fg tile
; Description:  Switches in the ROM bank containing the tile to be
;               loaded, sets a ptr to the source address, and calls
;               LoadBGTile or LoadFGTile appropriately
;---------------------------------------------------------------------
LoadTile:
        push    af
        push    bc
        push    de
        push    hl

        ;figure out which bank the tile is in
        ld      a,[loadTileL]
        ld      l,a
        ld      a,[loadTileH]
        ld      h,a
        cp      $08              ;bg if tile # less than 2048 ($800)?
        jr      c,.bgTileSet

        ;fg tile set
        ld      a,BANK(FGTiles)   ;Swap in the right bank
        call    SetActiveROM
        ld      de,FGTiles
        ld      a,h
        sub     $08               ;minus 2048 (fg tiles new bank)
        ld      h,a

        jp      .loadTile

.bgTileSet
        cp      $04               ;first or second bank?
        jr      c,.bgSet1

.bgSet2
        sub     $04
        ld      h,a
        ld      a,BANK(BGTiles1024)
        ld      de,BGTiles1024
        jr      .gotBank

.bgSet1
        ld      a,BANK(BGTiles)   ;Swap in the right bank
        ld      de,BGTiles

.gotBank
        call    SetActiveROM

.loadTile
        ;Convert hl into a src address offset (hl<<=4) and add base addr de
        ld      a,h
        sla     l
        rla
        sla     l
        rla
        sla     l
        rla
        sla     l
        rla
        ld      h,a
        add     hl,de

        ;BG or FG class?
        ld      a,c
        or      a
        jr      nz,.fgTile

.bgTile
        call    LoadBGTile
        jr      .done

.fgTile
        call    LoadFGTile

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      LoadBGTile
; Arguments:    b  - index of class being loaded
;               hl - src ptr to tile ROM
; Note:         [bgDestPtr]   - assumed to point to destination in VRAM
;                               tile bank 0
;               [numBGTiles]  - index of tile in tile bank 0
; Description:  Loads in a tile to tile bank 0 at the given address.
;               bgTileMap[index] is set to numBGTiles-1
;---------------------------------------------------------------------
LoadBGTile:
        push    af
        push    bc
        push    de
        push    hl

        ld      a,TILEINDEXBANK  ;select RAM bank of tile index maps
        ld      [$ff70],a
        ld      de,bgTileMap     ;setup de with &bgTileMap[classIndex]
        ld      e,b              ;b is class index

        ;set the attributes byte for this BG tile
        PUSHROM
        ld      a,BANK(bg_colorTable)
        call    SetActiveROM
        push    de
        push    hl
        push    de
        ld      a,[loadTileL]
        ld      e,a
        ld      a,[loadTileH]
        ld      d,a
        ld      hl,bg_colorTable
        add     hl,de
        pop     de
        ld      d,((bgAttributes>>8)&$ff)
        ld      a,[hl]
        ld      [de],a
        pop     hl
        pop     de
        POPROM

        ;Increment number of BG tiles counter
        ld      a,[numBGTiles]
        ld      [de],a           ;cur tile index into bgTileMap[classIndex]
        inc     a
        ld      [numBGTiles],a

        ;Load in 16 bytes to the work buffer ($c000 + (bgDestPtr&511))
        ;(32 * 16 = 511)
        ld      a,[bgDestPtr]
        ld      e,a
        ld      a,[bgDestPtr+1]
        ld      d,a
        push    de
        and     1
        add     $c0
        ld      d,a

        ld      c,16
.loop   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop

        pop     de
        call    AddDE16

        ;copy the work buffer to VRAM if numBGTiles is a multiple of 32
        ld      a,[numBGTiles]
        and     31
        call    z,CopyBGWorkToVRAM

IF 0
        ;Load in 16 bytes
        ld      a,0
        ld      [$ff00+$4f],a    ;load into bank 0
        ld      a,[bgDestPtr]    ;set de=destPtr
        ld      e,a
        ld      a,[bgDestPtr+1]
        ld      d,a
        ld      c,16             ;# of bytes to load

.loop   ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      nz,.loop
ENDC

        ;store modified destptr
        ld      a,e
        ld      [bgDestPtr],a
        ld      a,d
        cp      $98
        jr      c,.checkedNegative
        sub     $10
.checkedNegative
        ld      [bgDestPtr+1],a

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

CopyBGWorkToVRAM:
        push    bc
        push    de
        push    hl

        ;set destptr to be bgDestPtr & (~511)
        ld      e,0
        ld      a,[bgDestPtr+1]
        and     $fe
        ld      d,a

        ;if bgDestPtr is $9000 (1st tile) set $c000-$c00f to black
        ;for the blank tile
        ld      a,e
        or      a
        jr      nz,.afterCopyBlank
        ld      a,d
        cp      $90
        jr      nz,.afterCopyBlank
        ld      c,16
        ld      hl,$c000
        xor     a
.setBlankLoop
        ld      [hl+],a
        dec     c
        jr      nz,.setBlankLoop

.afterCopyBlank
        ld      a,[numBGTiles]
        dec     a
        and     31
        inc     a
        ld      c,a
        xor     a
        ld      hl,$c000
        call    VMemCopy
        pop     hl
        pop     de
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      LoadFGTile
; Arguments:    b  - index of class being loaded
;               hl - src ptr to tile ROM
; Note:         [fgDestPtr]   - assumed to point to destination in VRAM
;                               tile bank 1
;               [numFGTiles]  - index of tile in tile bank 1
; Description:  Loads in a tile to tile bank 0 at the given address.
;               fgTileMap[index] is set to numFGTiles-1
;               Duplicates any tiles loaded into $9000-$9800 into
;               $8000-$8800 for tile<->sprite conversion purposes
;---------------------------------------------------------------------
LoadFGTile:
        push    af
        push    bc
        push    de
        push    hl

        ld      a,TILEINDEXBANK  ;select RAM bank of tile index maps
        ld      [$ff00+$70],a
        ld      de,fgTileMap     ;setup de with &fgTileMap[classIndex]
        ld      e,b              ;b is class index

        ;set the attributes byte for this FG tile
        push    de
        push    hl
        push    de
        ld      a,[loadTileL]
        ld      e,a
        ld      a,[loadTileH]
        and     $03
        ld      d,a
        ld      hl,fg_colorTable
        add     hl,de
        pop     de
        ld      d,((fgAttributes>>8)&$ff)
        ld      a,[hl]
        ld      [de],a
        ld      b,a      ;save the attributes byte in b
        ldio    [curObjWidthHeight],a
        pop     hl
        pop     de

        ;Place tile index in fgTileMap
        ld      a,[numFGTiles]
        ld      [de],a           ;cur tile index into fgTileMap[classIndex]
        push    af

        ;load in 2 tiles for a FG object
        ;b has bit 5 set for 2x2 or cleared for 1x1;
        ;manipulate b to have either 8 for 2x2 or 2 for 1x1.
        bit     5,b
        jr      nz,.load8Tiles
        ld      b,2
        jr      .setNumTilesToLoad
.load8Tiles
        ld      b,8
.setNumTilesToLoad
        ld      de,$c000          ;load to work buffer

.nextTile
        ;Increment number of FG tiles counter
        ld      a,[numFGTiles]
        inc     a
        ld      [numFGTiles],a

        ;Load in 16 bytes
        ld      c,16
.nextByte
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.nextByte

        dec     b
        jr      nz,.nextTile

        ;retrieve index of first tile to generate facings with
        pop     af                 ;retrieve index of first tile
        call    GenerateFacings    ;expand 2 tiles into 6 tiles

        ;Increment number of FG tiles counter to account for the new
        ;tiles added in Generate Facings (4 for 1x1 or 12 for 2x2)
        ldio    a,[curObjWidthHeight]   ;xxFxxxxx
        rrca                            ;xxxFxxxx
        rrca                            ;xxxxFxxx
        and     %00001000               ;0000F000
        or      %00000100               ;0000F100  4 or 12
        ld      b,a
        ld      a,[numFGTiles]
        add     b
        ld      [numFGTiles],a

        ;store modified destptr (plus n*16 extra tiles)
        ld      a,[fgDestPtr]
        ld      e,a
        ld      a,[fgDestPtr+1]
        ld      d,a
        ld      h,0
        ld      l,b        ;num extra tiles
        swap    l          ;*16
        add     hl,de
        ld      a,l
        ld      [fgDestPtr],a
        ld      a,h
        cp      a,$98
        jr      c,.doneCheckNegative

        sub     $10
.doneCheckNegative
        ld      [fgDestPtr+1],a

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      LoadAssociatedClass
; Arguments:    a  - check if it exists already (1=yes, 0=no)
;               c  - class index of calling class method
;               de - class ptr for new class (vector table address)
;               hl - tile index of class to load
; Alters:       af
; Description:  Loads in the specified class IF NOT ALREADY PRESENT
;               and regardless puts its index in the "associated"
;               array of the calling class.
;---------------------------------------------------------------------
LoadAssociatedClass::
        push    bc
        push    hl

        or      a
        jr      z,.notFound  ;don't look for it

        push    bc
        ld      b,d
        ld      c,e
        call    FindClassIndex
        pop     bc
        or      a
        jr      z,.notFound

.foundMatch
        ld      b,a
        jr      .setAssociated

.notFound

        ;-------------------------------------------------------------
        ;Didn't find it; go ahead and load it into the next available
        ;slot
        ;-------------------------------------------------------------
        ld      a,l
        ld      [loadTileL],a
        ld      a,h
        ld      [loadTileH],a

        ld      a,[numClasses]
        inc     a
        ld      [numClasses],a
        ld      b,a

        ld      a,OBJLISTBANK
        ld      [$ff70],a

        ;----------Set classLookup to point to vector table----------
        ;set hl to point to classLookup[b] (times two)
        push    de
        ld      h,0
        ld      l,b
        sla     l
        rl      h
        ld      de,classLookup
        add     hl,de
        pop     de
        ld      [hl],e
        inc     hl
        ld      [hl],d

        ;-----------Load in the tile--------------------------------
        push    bc
        ld      c,1                  ;loading fg tile
        call    LoadTile
        pop     bc

        ld      a,OBJROM
        call    SetActiveROM

.setAssociated
        ;-------------------------------------------------------------
        ;Expecting calling class index in c, new class index in b
        ;-------------------------------------------------------------
        call    SetAssociated
        pop     hl
        pop     bc
        ret


;---------------------------------------------------------------------
; Routine:      SaveFGTileInfo
; Arguments:    None.
; Alters:       af
; Description:  Saves [numClasses], [fgDestPtr], and [numFGTiles] into
;               temporary variables.
;---------------------------------------------------------------------
SaveFGTileInfo::
        push    de
        push    hl

        ld      hl,numFGTiles
        ld      a,[hl+]        ;get numFGTiles
        ld      [hl+],a        ;put numFGTiles_save
        ld      a,[hl+]        ;get numClasses
        ld      [hl+],a        ;put numClasses_save
        ld      a,[hl+]        ;get fgTilePtrL
        ld      e,a
        ld      a,[hl+]        ;get fgTilePtrH
        ld      d,a
        ld      a,e
        ld      [hl+],a        ;put fgTilePtrL
        ld      [hl],d         ;put fgTilePtrH

        pop     hl
        pop     de
        ret


;---------------------------------------------------------------------
; Routine:      RestoreFGTileInfo
; Arguments:    None.
; Alters:       af
; Description:  Restores [numClasses], [fgDestPtr] and [numFGTiles]
;               from temp vars.
;---------------------------------------------------------------------
RestoreFGTileInfo::
        push    de
        push    hl

        ld      hl,fgDestPtr_save+1
        ld      a,[hl-]      ;get fgDestPtrH
        ld      d,a
        ld      a,[hl-]      ;get fgDestPtrL
        ld      e,a
        ld      a,d
        ld      [hl-],a      ;put fgDestPtrH
        ld      a,e
        ld      [hl-],a      ;put fgDestPtrL
        ld      a,[hl-]      ;get numClasses
        ld      [hl-],a      ;put numClasses
        ld      a,[hl-]      ;get numFGTiles
        ld      [hl],a       ;put numFGTiles

        pop     hl
        pop     de
        ret

;---------------------------------------------------------------------
; Routine:      SetupHero
; Arguments:    a  - type of exit to place hero at:
;                    1=N, 2=E, 3=S, 4=W, 5=U, 6=D, 7=X
;               bc - tile index of hero class to load
;               d  - hero number (0 or 1)
;               hl - suggested location to start searching for exit
;                    in XY format.
; Alters:       af
; Description:  Loads in the hero tile & class
;               Sets up [heroX_index], [heroX_class], [heroX_object]
;               Sets heroes health to be [heroX_health] unless that's
;               zero then it leaves it as initialized.
;               Sets heroes puffCount from [heroX_puffCount]
;---------------------------------------------------------------------
SetupHero::
        push    bc
        push    de
        push    hl

        ld      e,a                  ;save exit type for a bit

        ;save tile to load into method parameters
        ld      a,c
        ld      [loadTileL],a
        ld      a,b
        ld      [loadTileH],a

        ;pick one of two reserved tile sets to load hero into
        call    SaveFGTileInfo
        ld      a,d                  ;hero number
        or      a
        jr      nz,.loadHero1

        ld      a,[firstHero]
        ld      [numClasses],a
        xor     a
        ld      bc,$9000
        jr      .decidedOnTileSet

.loadHero1
        ld      a,[firstHero]
        add     2
        ld      [numClasses],a
        ld      a,20
        ld      bc,$9140
.decidedOnTileSet
        ld      [numFGTiles],a
        ld      a,c
        ld      [fgDestPtr],a
        ld      a,b
        ld      [fgDestPtr+1],a
        ld      a,1
        ldio    [curObjWidthHeight],a

.setupBC_heroX_index
        ;setup bc with addr of hero0_index or hero1_index
        ld      bc,hero0_index
        ld      a,d                  ;want hero 0 or 1?
        or      a
        jr      nz,.wantHero1

.wantHero0
        ld      a,[hero0_type]
        cp      HERO_GRENADE_FLAG
        jr      nz,.hero0_afterSetWH

        ld      a,2
        ldio    [curObjWidthHeight],a

.hero0_afterSetWH
        ld      a,[heroesPresent]
        or      %01
        jr      .heroDataPtrOkay

.wantHero1
        ld      a,[hero1_type]
        cp      HERO_GRENADE_FLAG
        jr      nz,.hero1_afterSetWH

        ld      a,2
        ldio    [curObjWidthHeight],a

.hero1_afterSetWH
        ld      a,[heroesPresent]
        or      %10
        ld      c,(hero1_index & $ff)

.heroDataPtrOkay
        ld      [heroesPresent],a

        ld      a,e                  ;retrieve desired exit
        push    bc                   ;save &heroX_index

        call    FindExitLocation     ;returns exit loc in hl
        push    hl                   ;save it for later

        ld      h,b
        ld      l,c
        ld      a,[numClasses]
        inc     a
        ld      [numClasses],a
        ld      b,a
        ld      [hl+],a         ;store class index in heroX_index
        inc     hl              ;hl = &heroX_classL
        inc     hl
        inc     hl
        push    af              ;save the hero class index

        call    SetClassLookupEntryForTile

        ld      c,1                  ;loading fg tile
        call    LoadTile

        ld      a,OBJROM
        call    SetActiveROM

        pop     af                   ;retrieve hero class index
        ld      c,a
        pop     hl                   ;starting location
        call    CreateObject         ;returns objPtr in de

        pop     hl                   ;retrieve &heroX_index
        inc     hl                   ;hl = &heroX_objectL
        ld      [hl],e
        inc     hl
        ld      [hl],d

        call    RestoreFGTileInfo

        ld      b,METHOD_INIT
        call    CallMethod

        ;face opposite direction coming in
        call    GetFacing
        and     %11111000
        ld      b,a
        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,[hl]
        cp      EXIT_U
        jr      c,.cardinal

        ;we're coming in up, down, or X; let's just face east
        ld      a,DIR_EAST
        jr      .gotDir

.cardinal
        add     1
        and     %11
.gotDir
        or      b
        call    SetFacing

        ;reset health of hero
        ;push    de
        ;ld      a,l
        ;and     (255 - (HERODATASIZE-1))     ;set back to heroX_data
        ;ld      l,a
        ;ld      de,HERODATA_HEALTH
        ;add     hl,de
        ;pop     de
        LDHL_CURHERODATA HERODATA_HEALTH
        ld      a,[hl]
        or      a
        jr      z,.afterInitHealth

        ;push    hl
        call    SetHealth
        ;pop     hl

        ;reset hero puffs
        LDHL_CURHERODATA HERODATA_PUFFCOUNT
        ld      a,[hl]
        and     %1111
        call    SetPuffCount

        ;inc     hl
        ;inc     hl    ;hl = heroX_puffCount
        ;ld      a,[hl]
        ;call    SetPuffCount

.afterInitHealth
        ld      b,METHOD_DRAW
        call    CallMethod

        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      FindExitLocation
; Arguments:    a  - type of exit to find:
;                    1=N, 2=E, 3=S, 4=W, 5=U, 6=D, 7=X
;               hl - "suggested" location to start searching for exit
;                    in XY format.
;               [curObjWidthHeight]
; Returns:      hl - location of first exit found or $0000
; Alters:       af
; Description:  First adjusts suggested location to be opposite side
;               if NESW and restricts it to map bounds.
;
;               Searches forward through the map beginning at hl and
;               stopping on an exit of the specified type.
;
;               If there are no exits found once it reaches the end
;               of the map it searches through once more starting at
;               the first map cell.  If there are STILL no exits found
;               it returns location (1,1).
;---------------------------------------------------------------------
FindExitLocation::
        push    bc
        push    de

        ld      b,a                 ;save exit type

        ;swap sides if exit type is NESW
        ld      a,b
        dec     a
        and     %11111100
        jr      nz,.afterSwapExit

        ld      a,b
        dec     a
        bit     0,a
        jr      nz,.east_or_west

        ;north or south
        bit     1,a
        jr      nz,.south

.north  ;looking for north entrance so coming from south, place at top
        ld      l,1
        jr      .afterSwapExit

.south  ;entering south means coming from north, place at bottom
        ld      a,[mapHeight]
        dec     a
        dec     a
        ld      l,a
        jr      .afterSwapExit

.east_or_west
        bit     0,a
        jr      nz,.west

        ;entering east, place at right
        ld      a,[mapWidth]
        dec     a
        dec     a
        ld      h,a
        jr      .afterSwapExit

.west   ;entering west, place at left
        ld      h,1

.afterSwapExit
        ;make sure x & y are within bounds
        ld      a,[mapWidth]
        cp      h                 ;width > x?
        jr      z,.xOutOfBounds
        jr      nc,.xInBounds

.xOutOfBounds
        sub     2   ;x out-of-bounds, set to width-2
        ld      h,a

.xInBounds
        ld      a,[mapHeight]
        cp      l
        jr      z,.yOutOfBounds
        jr      nc,.yInBounds

.yOutOfBounds
        sub     2
        ld      l,a

.yInBounds
        call    ConvertXYToLocHL    ;location back to ptr

        swap    b
        ld      c,$f0       ;put mask in register for faster ANDing

        ;setup de with first out-of-bounds index
        ld      a,[mapTotalSize]
        ld      e,a
        ld      a,[mapTotalSize+1]
        ld      d,a

        ld      a,ZONEBANK
        ld      [$ff70],a

.loop    ld      a,h
        cp      d
        jr      nz,.continue
        ld      a,l
        cp      e
        jr      nz,.continue

        ;reached end of map
        jr      .didntFind

.continue
        ld      a,[hl+]
        and     c
        cp      b
        jr      nz,.loop

        ;found an exit location; see if it's empty
        call    .isValidExit
        jr      nz,.done
        inc     hl
        jr      .loop

.didntFind      ;look again starting at beginning
        ld      hl,map
        ld      a,[mapHeight]
        ld      d,a

.outer  ld      a,[mapPitch]
        ld      e,a
.inner  ld      a,[hl+]
        and     c
        cp      b
        jr      nz,.notFoundYet

        ;maybe found; check if map location occupied
        call    .isValidExit
        jr      nz,.done
        inc     hl

.notFoundYet
        dec     e
        jr      nz,.inner
        dec     d
        jr      nz,.outer

;didnt find it after searching the WHOLE map
        ld      hl,$0000

.done
        pop     de
        pop     bc
        ret

.isValidExit
        ld      a,MAPBANK
        ld      [$ff70],a
        dec     hl
        ld      a,[hl]       ;get this location in the map array
        push    af           ;save it for a sec
        ld      a,ZONEBANK   ;switch back to zones just in case
        ld      [$ff70],a
        pop     af
        or      a
        jr      nz,.validFalse

        ldio    a,[curObjWidthHeight]
        cp      1
        jr      z,.validTrue

        ;2x2; must check locations to right, down-right, and down
        ld      a,MAPBANK
        ld      [$ff70],a
        push    hl

        inc     hl
        ld      a,[hl]
        or      a
        jr      nz,.validFalseCleanUp

        push    de
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        add     hl,de
        pop     de

        ld      a,[hl]
        or      a
        jr      nz,.validFalseCleanUp

        dec     hl
        ld      a,[hl]
        or      a
        jr      nz,.validFalseCleanUp

.validTrueCleanUp
        pop     hl
        ld      a,ZONEBANK   ;switch back to zones
        ld      [$ff70],a
        jr      .validTrue

.validFalseCleanUp
        pop     hl
        ld      a,ZONEBANK   ;switch back to zones
        ld      [$ff70],a
        xor     a
        ret

.validTrue
        ld      a,1
        or      a
        ret

.validFalse
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      FindClassIndex
; Arguments:    bc - class to find
; Returns:      a  - class index
;               zflag - result of "OR a"
; Alters:       af
; Description:  Finds first class index of class "bc" & returns class
;               index or 0 if it doesn't exist
;---------------------------------------------------------------------
FindClassIndex::
        push    de
        push    hl

        ld      a,OBJLISTBANK
        ld      [$ff70],a

        ld      a,[numClasses]
        ld      d,a
        ld      e,1

        ld      hl,classLookup+2

.loop   ld      a,[hl+]
        cp      c
        jr      nz,.afterCheck
        ld      a,[hl]
        cp      b
        jr      nz,.afterCheck

        ;found it!
        ld      a,e           ;a is class index
        or      a
        pop     hl
        pop     de
        ret

.afterCheck
        inc     hl
        inc     e
        dec     d
        jr      nz,.loop

        pop     hl
        pop     de
        xor     a             ;didn't find it
        ret

;---------------------------------------------------------------------
; Routine:      ChangeClass
; Arguments:    bc - class to change
;               de - pointer to new class
; Alters:       af,hl
; Description:  Changes all objects of the "old" class type to the
;               "new" class type
;---------------------------------------------------------------------
ChangeClass::
        ld      a,OBJLISTBANK
        ld      [$ff70],a

        ld      a,$ff
        ld      hl,classLookup+2

.loop   push    af
        ld      a,[hl+]
        cp      c
        jr      nz,.afterCheck
        ld      a,[hl]
        cp      b
        jr      nz,.afterCheck

        ;replace old class with new
        ld      [hl],d
        dec     hl
        ld      [hl],e
        inc     hl

.afterCheck
        inc     hl
        pop     af
        dec     a
        jr      nz,.loop

        ret

;---------------------------------------------------------------------
; Routine:      ChangeFirstClass
; Arguments:    bc - class to change
;               de - pointer to new class
; Alters:       af,hl
; Description:  Changes of first class found to match the "old" class
;               type to the "new" class type
;---------------------------------------------------------------------
ChangeFirstClass::
        ld      a,OBJLISTBANK
        ld      [$ff70],a

        ld      a,$ff
        ld      hl,classLookup+2

.loop   push    af
        ld      a,[hl+]
        cp      c
        jr      nz,.afterCheck
        ld      a,[hl]
        cp      b
        jr      nz,.afterCheck

        ;replace old class with new
        ld      [hl],d
        dec     hl
        ld      [hl],e
        inc     hl
        pop     af
        ret

.afterCheck
        inc     hl
        pop     af
        dec     a
        jr      nz,.loop

        ret

;---------------------------------------------------------------------
; Routines:     CopyMapMethodToRAM
; Arguments:    a  - offset of method in map contents
;               [mapMethodContents] be set up
; Returns:      nothing.
; Alters:       nothing.
; Description:  Copies the Map Check or Init Method to RAM so it can
;               be called w/o switching ROM banks
;---------------------------------------------------------------------
CopyMapMethodToRAM::
        push    af
        push    bc
        push    de
        push    hl

        call    LookupInMapContents    ;set hl to point to source

        ;setup bc as # bytes to copy
        ld      c,[hl]            ;low byte of size
        inc     hl
        ld      b,[hl]            ;high byte of size
        inc     hl

        ld      de,levelCheckRAM  ;dest addr

        ;copy sets of 256
        ld      a,b
        or      a
        jr      z,.copy_lt_256
        push    bc
.outer  ld      c,0
.inner  ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.inner
        dec     b
        jr      nz,.outer
        pop     bc

.copy_lt_256
        ;copy remaining < 256 bytes
        ld      a,c
        or      a
        jr      z,.done
.loop   ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.loop

.done
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

;---------------------------------------------------------------------
; Routine:      HandleExitFromMap
; Arguments:    c  - hero class index
;               de - ptr to object
; Returns:      Nothing.
; Alters:       af
; Description:  If the hero exiting is the one controlled by this
;               machine, sets the paramaters which will cause a new
;               map to be loaded (in user.asm) if the exit has a map
;               associated with it.
;
;               Deletes the remote hero if an exit is found.
;---------------------------------------------------------------------
HandleExitFromMap::
        push    bc
        push    de
        push    hl

        ;save exit type in B
        call    GetCurLocation
        ldio    a,[curObjWidthHeight]
        cp      2
        jr      nz,.locationSet

        call    GetFacing
        and     %11
        cp      DIR_NORTH
        jr      z,.locationSet
        cp      DIR_WEST
        jr      z,.locationSet
        push    af
        call    ConvertLocHLToXY
        pop     af
        cp      DIR_EAST
        jr      z,.incH

        inc     l
        jr      .locationAltered

.incH
        inc     h

.locationAltered
        call    ConvertXYToLocHL

.locationSet
        ld      a,ZONEBANK
        ld      [$ff70],a
        ld      a,[hl]
        swap    a
        and     %00000111
        ld      b,a

        ;save exit location as entry location
        call    ConvertLocHLToXY

        push    de
        ld      d,((hero0_data>>8) & $ff)
        ld      a,[curHeroAddressL]
        add     HERODATA_ENTERLOC
        ld      e,a
        ld      a,l
        ld      [de],a
        inc     de
        ld      a,h
        ld      [de],a
        pop     de

        ;lookup link in link table
        ld      a,b
        sla     a
        add     (mapExitLinks & $ff)
        ld      l,a
        ld      a,0
        adc     ((mapExitLinks>>8) & $ff)
        ld      h,a

        ;store 16-bit BCD link value in hl
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        ld      a,$40
        cp      h
        jr      nz,.linkOkay
        cp      l
        jr      nz,.linkOkay
        jp      .done              ;link is $4040 = (+0,+0) = no link

.linkOkay
        ;if remote hero exiting then don't change my map
        push    hl
        LDHL_CURHERODATA HERODATA_INDEX
        ld      a,[hl]
        pop     hl
        cp      c            ;cur hero index == cur index?
        jr      z,.localHero
        jp      .removeRemoteHero

.localHero
        call    RemoveHero
        ld      a,h          ;x link/offset
        and     %11000000
        jr      nz,.xlinkRelative

        ld      a,h
        jr      .doY

.xlinkRelative
        bit     6,h          ;positive offset?
        jr      z,.negative_x_offset

        ;positive offset
        call    .setupH
        call    BCDToNumber
        add     h
        call    NumberToBCD
        jr      .doY

.negative_x_offset
        call    .setupH
        call    BCDToNumber
        sub     h
        call    NumberToBCD
        jr      .doY

.setupH
        ld      a,h
        and     %00111111
        ld      h,a
        ld      a,[curLevelIndex+1]
        ret

.doY
        ld      [curLevelIndex+1],a

        ld      a,l          ;y link/offset
        and     %11000000
        jr      nz,.ylinkRelative

        ld      a,l
        jr      .finishedY

.ylinkRelative
        bit     6,l          ;positive offset?
        jr      z,.negative_y_offset

        ;positive offset
        call    .setupL
        call    BCDToNumber
        add     l
        call    NumberToBCD
        jr      .finishedY

.negative_y_offset
        call    .setupL
        call    BCDToNumber
        sub     l
        call    NumberToBCD
        jr      .finishedY

.setupL
        ld      a,l
        and     %00111111
        ld      l,a
        ld      a,[curLevelIndex]
        ret

.finishedY
        ld      [curLevelIndex],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ;switch NESW to be opposite
        ld      a,b
        dec     a
        and     %11111100
        jr      nz,.switchUp

        ld      a,b
        inc     a           ;same as a--, a+=2
        and     %00000011
        inc     a
        ld      b,a
        jr      .afterSwitchToOpposite

.switchUp
        ld      a,b
        cp      EXIT_U
        jr      nz,.switchDown
        ld      b,EXIT_D
        ld      a,b
        jr      .afterSwitchToOpposite

.switchDown
        cp      EXIT_D
        jr      nz,.afterSwitchToOpposite
        ld      b,EXIT_U
        ld      a,b

.afterSwitchToOpposite
        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,b
        ld      [hl],a

.updateState
        ;don't update the state if it's an asynchronous can-join
        ;map or a cinema
        ld      a,[canJoinMap]
        cp      2
        jr      z,.afterUpdateState
        ld      a,[displayType]
        cp      1
        jr      z,.afterUpdateState

        call    UpdateState

.removeRemoteHero
        call    RemoveHero

.afterUpdateState
.zeroIndex
        ld      a,[hero0_index]
        cp      c
        jr      nz,.zeroIndex1

        xor     a
        ld      [hero0_index],a
        jr      .done

.zeroIndex1
        ld      a,[hero1_index]
        cp      c
        jr      nz,.done
        xor     a
        ld      [hero1_index],a

.done
        pop     hl
        pop     de
        pop     bc
        ret

UpdateState::
        ld      a,[amLinkMaster]
        bit     7,a
        ret     nz    ;no link

.updateState
        ld      a,LUPDATESTATE
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.updateState      ;must repeat

        ld      a,[curLevelStateIndex]
        call    TransmitByte
        ldio    a,[mapState]
        or      a
        jr      nz,.stateNotZero
        ld      a,1
.stateNotZero
        call    TransmitByte
        ret


;---------------------------------------------------------------------
; Routines:     HasInventoryItem
;               AddInventoryItem
;               RemoveInventoryItem
; Arguments:    bc - b=item byte, c=bitmask
; Alters:       af
; Returns:      a, zflag
; Description:  Returns !0 if inventory item exists, 0 otherwise
;---------------------------------------------------------------------
HasInventoryItem::
        push    hl
        call    PointHLToInventory
        pop     hl
        and     c
        ret

AddInventoryItem::
        ;duplicate code also in user.asm
        push    hl
        call    PointHLToInventory
        or      c
        ld      [hl],a

        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.afterUpdateRemote

.updateRemote
        ld      a,LADDINVITEM
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.updateRemote      ;must repeat
        ld      a,c
        call    TransmitByte
        ld      a,b
        call    TransmitByte
.afterUpdateRemote

        pop     hl
        ret

RemoveInventoryItem::
        ;duplicate code also in user.asm
        push    hl
        call    PointHLToInventory
        xor     $ff
        or      c
        xor     $ff
        ld      [hl],a

        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.afterUpdateRemote

.updateRemote
        ld      a,LREMINVITEM
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.updateRemote      ;must repeat
        ld      a,c
        call    TransmitByte
        ld      a,b
        call    TransmitByte
.afterUpdateRemote

        pop     hl
        ret

PointHLToInventory::
        ld      h,((inventory>>8)&$ff)
        ld      a,(inventory & $ff)
        add     b
        ld      l,a
        ld      a,[hl]
        ret

;---------------------------------------------------------------------
; Routines:     GetFirstInventoryIndex
;               GetNextInventoryIndex
; Arguments:    a - previous inventory index (for GetNextII)
; Alters:       af
; Description:  Returns $ff for none, index otherwise (0,1,2,....)
;---------------------------------------------------------------------
GetFirstInventoryIndex:
        ld      a,$ff

GetNextInventoryIndex:
        inc     a
        cp      48        ;reached max inventory items?
        jr      c,.notDone

        ld      a,$ff
        ret

.notDone
        push    bc
        push    de
        push    hl
        ld      b,a

        ;position hl at current byte of inventory
        ld      h,((inventory >> 8) & $ff)
        rrca            ;itemIndex /= 8
        rrca
        rrca
        and     %00011111
        add     (inventory & $ff)
        ld      l,a

        ;jump to routine checking appropriate bit of inventory
        ld      a,b
        rlca
        and     %1110
        add     (.vectorTable & $ff)
        ld      e,a
        ld      a,0
        adc     ((.vectorTable>>8) & $ff)
        ld      d,a
        ld      a,[hl]
        push    de   ;jump to [de]
        ret

.vectorTable
        jr      .bit0
        jr      .bit1
        jr      .bit2
        jr      .bit3
        jr      .bit4
        jr      .bit5
        jr      .bit6
        jr      .bit7

.bit0
        bit     0,a
        jr      nz,.foundIt
        inc     b
.bit1
        bit     1,a
        jr      nz,.foundIt
        inc     b
.bit2
        bit     2,a
        jr      nz,.foundIt
        inc     b
.bit3
        bit     3,a
        jr      nz,.foundIt
        inc     b
.bit4
        bit     4,a
        jr      nz,.foundIt
        inc     b
.bit5
        bit     5,a
        jr      nz,.foundIt
        inc     b
.bit6
        bit     6,a
        jr      nz,.foundIt
        inc     b
.bit7
        bit     7,a
        jr      nz,.foundIt
        inc     b
        inc     hl
        ld      a,l
        cp      ((inventory+16)&$ff)
        jr      z,.didntFind
        ld      a,[hl]
        jr      .bit0

.didntFind
        ld      a,$ff
        jr      .done

.foundIt
        ld      a,b    ;index

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      State0To1
; Arguments:    [mapState]
; Alters:       af, [mapState]
; Returns:      a - [mapState]
; Description:  If [mapState] is 0 it is changed to 1, otherwise it
;               is unmodified.  The new map state is returned in a.
;---------------------------------------------------------------------
State0To1::
        ldio    a,[mapState]
        or      a
        ret     nz
        ld      a,1
        ldio    [mapState],a
        ret

;---------------------------------------------------------------------
; map data
;---------------------------------------------------------------------
SECTION "MapSupportSection",ROMX

;---------------------------------------------------------------------
; Routine:      GuestContinueSynchronization
; Arguments:    None.
; Alters:       af
; Returns:      Nothing.
; Description:
;---------------------------------------------------------------------
GuestContinueSynchronization::
        push    bc
        push    de
        push    hl

        xor     a
        ld      [backBufferReady],a

        ld      a,LSYNCHREADY
        call    TransmitByte

        ;receive fresh copy of all my hero data from host
        ld      hl,hero0_data
        ld      bc,HERODATASIZE*2
        xor     a
        call    ReceiveData

        LONGCALLNOARGS ResetList

        call    ReceiveByte
        ld      [randomLoc],a

        call    ReceiveByte
        ld      [heroesIdle],a

        ld      hl,map
        ld      bc,4096
        ld      a,MAPBANK
        call    ReceiveData

        ;fadeCurPalette
        ld      hl,fadeCurPalette
        ld      bc,128
        xor     a
        call    ReceiveData

        ;gamePalette
        ld      hl,gamePalette
        ld      bc,128
        ld      a,FADEBANK
        call    ReceiveData

        ;first 16 bytes of level check RAM
        ld      hl,levelCheckRAM
        ld      bc,16
        xor     a
        call    ReceiveData

        ;spriteOAMdata
        ld      hl,spriteOAMBuffer
        ld      bc,160
        xor     a
        call    ReceiveData

        ld      hl,headTable    ;headTable - linked list head
        ld      bc,256
        ld      a,OBJLISTBANK
        call    ReceiveData

        ld      hl,objExists     ;objExists, FOF table
        ld      bc,512
        ld      a,OBJLISTBANK
        call    ReceiveCompressedData

        call    ReceiveByte
        ld      [numClasses],a
        ld      b,0    ;bc = numClasses*2 + 2
        ld      c,a
        sla     c
        rl      b
        inc     bc
        inc     bc

        ld      hl,classLookup
        ;ld      bc,512 numClasses*2
        ld      a,OBJLISTBANK
        call    ReceiveData

        ld      hl,fgTileMap
        ld      a,[numClasses]
        ld      b,0
        ld      c,a
        ld      a,OBJLISTBANK
        call    ReceiveData

        ld      hl,objClassLookup   ;class indices for each obj
        ld      bc,256
        ld      a,OBJLISTBANK
        call    ReceiveData

        ld      hl,associatedIndex
        ld      bc,256
        ld      a,OBJLISTBANK
        call    ReceiveData

        ld      hl,spritesUsed
        ld      bc,40
        ld      a,OBJLISTBANK
        call    ReceiveCompressedData

        ;---------------receive  used objects-------------------------
        ld      a,OBJLISTBANK
        ld      [$ff70],a
        ld      de,objExists+1
.receiveUsedObject
        ld      a,[de]            ;is this object used?
        or      a
        jr      z,.afterReceiveUsedObject  ;not used

        PREPLONGCALL .afterCvtIndexToPtr
        ld      a,e           ;get object index
        LONGCALL IndexToPointerHL       ;cvt to ptr
.afterCvtIndexToPtr
        ld      bc,16
        ld      a,OBJBANK
        call    ReceiveData
        ld      a,OBJLISTBANK
        ld      [$ff70],a

.afterReceiveUsedObject
        inc     de
        ld      a,e
        or      a
        jr      nz,.receiveUsedObject

        call    ReceiveByte
        ld      [numFreeSprites],a

        call    ReceiveByte
        ld      [firstFreeObj],a

        call    ReceiveByte
        ld      [randomLoc],a

        call    ReceiveByte
        ld      [guardAlarm],a

        ;call    ReceiveByte
        ;ld      [dialogBank],a

        call    ReceiveByte
        ld      [respawnMap],a
        call    ReceiveByte
        ld      [respawnMap+1],a

        call    ReceiveByte
        ldio    [mapState],a
        call    ReceiveByte
        ldio    [mapState+1],a

        ld      hl,levelVars
        ld      bc,64
        xor     a
        call    ReceiveData

        ;my music to off
        xor     a
        ld      [musicEnabled],a

        ld      hl,musicBank
        ld      bc,64
        xor     a
        call    ReceiveData

        ;setup the wave table
        ld      c,16
        ld      de,$ff30
        ld      hl,musicWaveform
.setupWave
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.setupWave

        ;set default instruments
        ld      hl,musicInstrument1
        ld      de,$ff10
        ld      bc,4
        xor     a
        call    MemCopy
        ld      hl,musicInstrument2
        ld      de,$ff16
        ld      bc,3
        call    MemCopy
        ld      hl,musicInstrument3
        ld      de,$ff31
        call    MemCopy
        ld      hl,musicInstrument4
        ld      de,$ff20
        call    MemCopy

        ;disable sound
        xor     a
        ldio    [$ff26],a

        ldio    [$ff12],a    ;zero envelope all instruments
        ldio    [$ff17],a
        ldio    [$ff1c],a
        ldio    [$ff21],a

        ;enable sound
        ld      a,$80
        ldio    [$ff26],a   ;master
        ld      a,$ff
        ldio    [$ff24],a   ;volume
        ldio    [$ff25],a   ;sound output terminals

        ld      hl,musicStack
        ld      bc,128
        ld      a,MUSICBANK
        call    ReceiveData

        call    ReceiveByte
        ldio    [musicEnabled],a


        LONGCALLNOARGS LinkRemakeLists

.done
        pop     hl
        pop     de
        pop     bc
        ret

;---------------------------------------------------------------------
; Routine:      RandomizeFlightCodes
; Arguments:    None.
; Alters:       all
; Returns:      Nothing.
; Description:  Randomizes the flight codes
;---------------------------------------------------------------------
RandomizeFlightCodes::
        ;randomize 11/15 flight codes
        ld      a,FLIGHTCODEBANK
        ldio    [$ff70],a

        ldio    a,[randomLoc]
        push    af
        ldio    a,[vblankTimer]
        ldio    [randomLoc],a

        ld      hl,flightCode+1
        ld      a,11
.loop
        push    af

        ;get a random octal coordinate in bc
        ld      a,7
        call    GetRandomNumMask
        swap    a
        ld      b,a
        ld      a,7
        call    GetRandomNumMask
        or      b
        ld      b,a
        ld      a,7
        call    GetRandomNumMask
        swap    a
        ld      c,a
        ld      a,7
        call    GetRandomNumMask
        or      c
        ld      c,a
.validateCode
        call    .checkCodeExists
        jr      nz,.placeCode
        call    .incrementCode
        jr      .validateCode

.placeCode
        ld      [hl],c
        inc     hl
        ld      [hl],b
        inc     hl
        inc     hl
        pop     af
        dec     a
        jr      nz,.loop

        ldio    a,[randomLoc]
        ldio    [asyncRandLoc],a
        pop     af
        ldio    [randomLoc],a
        ret

.incrementCode
        ;separate code bc into bcde
        ld      a,c
        and     7
        ld      e,a
        ld      a,c
        swap    a
        and     7
        ld      d,a
        ld      a,b
        and     7
        ld      c,a
        ld      a,b
        swap    a
        and     7
        ld      b,a

        inc     e
        ld      a,e
        cp      8
        jr      nz,.incrementDone

        ld      e,0
        inc     d
        ld      a,d
        cp      8
        jr      nz,.incrementDone

        ld      d,0
        inc     c
        ld      a,c
        cp      8
        jr      nz,.incrementDone

        ld      c,0
        inc     b
        ld      a,b
        cp      8
        jr      nz,.incrementDone

        ld      b,0

.incrementDone
        ;reassemble bcde into bc
        swap    b
        ld      a,c
        or      b
        ld      b,a
        swap    d
        ld      a,e
        or      d
        ld      c,a
        ret

.checkCodeExists
        push    bc
        push    hl

        ld      hl,flightCode
        ld      c,[hl]
        inc     hl
.checkCodeLoop
        ld      a,[hl+]
        cp      c
        jr      nz,.keepGoing

        ld      a,[hl]
        cp      b
        jr      nz,.keepGoing

        ;found a match :(
        xor     a
        pop     hl
        pop     bc
        ret

.keepGoing
        inc     hl
        inc     hl
        dec     c
        jr      nz,.checkCodeLoop

        ;no match!
        ld      a,1
        or      a
        pop     hl
        pop     bc
        ret

;WARNING not home section

;---------------------------------------------------------------------
; map data
;---------------------------------------------------------------------
SECTION "MapLookupTableSection",ROMX
MapLookupTable:

;calculate index number 0-255 from xxyy with "i = yy*16 + xx"
;e.g. L0205 = 5*16 + 2 = 82
DW      BANK(L0000_Contents),L0000_Contents  ;0 The Hive
DW      0,0                                  ;1
DW      BANK(L0200_Contents),L0200_Contents  ;2
DW      BANK(L0300_Contents),L0300_Contents  ;3
DW      BANK(L0400_Contents),L0400_Contents  ;4
DW      BANK(L0500_Contents),L0500_Contents  ;5
DW      BANK(L0600_Contents),L0600_Contents  ;6
DW      BANK(L0700_Contents),L0700_Contents  ;7
DW      BANK(L0800_Contents),L0800_Contents  ;8
DW      BANK(L0900_Contents),L0900_Contents  ;9
DW      BANK(L1000_Contents),L1000_Contents  ;10
DW      BANK(L1100_Contents),L1100_Contents  ;11 (1100, char select)
DW      BANK(L1200_Contents),L1200_Contents  ;12 (1200, demo intro)
DW      BANK(L1300_Contents),L1300_Contents  ;13
DW      BANK(L1400_Contents),L1400_Contents  ;14
DW      BANK(L1500_Contents),L1500_Contents  ;15
DW      BANK(L0001_Contents),L0001_Contents  ;16
DW      0,0                                  ;17
DW      BANK(L0201_Contents),L0201_Contents  ;18
DW      BANK(L0301_Contents),L0301_Contents  ;19
DW      BANK(L0401_Contents),L0401_Contents  ;20
DW      BANK(L0501_Contents),L0501_Contents  ;21
DW      BANK(L0601_Contents),L0601_Contents  ;22
DW      BANK(L0701_Contents),L0701_Contents  ;23
DW      BANK(L0801_Contents),L0801_Contents  ;24
DW      BANK(L0901_Contents),L0901_Contents  ;25
DW      BANK(L1001_Contents),L1001_Contents  ;26
DW      BANK(L1101_Contents),L1101_Contents  ;27 (1101, Main Menu)
DW      BANK(L1201_Contents),L1201_Contents  ;28 (join game)
DW      BANK(L1301_Contents),L1301_Contents  ;29
DW      BANK(L1401_Contents),L1401_Contents  ;30
DW      0,0                                  ;31
DW      BANK(L0002_Contents),L0002_Contents  ;32
DW      0,0                                  ;33
DW      0,0                                  ;34
DW      BANK(L0302_Contents),L0302_Contents  ;35
DW      BANK(L0402_Contents),L0402_Contents  ;36
DW      BANK(L0502_Contents),L0502_Contents  ;37
DW      BANK(L0602_Contents),L0602_Contents  ;38
DW      BANK(L0702_Contents),L0702_Contents  ;39
DW      BANK(L0802_Contents),L0802_Contents  ;40
DW      BANK(L0902_Contents),L0902_Contents  ;41
DW      BANK(L1002_Contents),L1002_Contents  ;42
DW      BANK(L1102_Contents),L1102_Contents  ;43 (1102, main intro)
DW      BANK(L1202_Contents),L1202_Contents  ;44 (1202, dropship lv v.t.)
DW      BANK(L1302_Contents),L1302_Contents  ;45 (1302 ba corners gyro)
DW      BANK(L1402_Contents),L1402_Contents  ;46 (1402 b12 surrenders)
DW      BANK(L1502_Contents),L1502_Contents  ;47
DW      BANK(L0003_Contents),L0003_Contents  ;48
DW      BANK(L0103_Contents),L0103_Contents  ;49
DW      BANK(L0203_Contents),L0203_Contents  ;50
DW      BANK(L0303_Contents),L0303_Contents  ;51
DW      BANK(L0403_Contents),L0403_Contents  ;52
DW      BANK(L0503_Contents),L0503_Contents  ;53
DW      BANK(L0603_Contents),L0603_Contents  ;54
DW      BANK(L0703_Contents),L0703_Contents  ;55
DW      BANK(L0803_Contents),L0803_Contents  ;56
DW      BANK(L0903_Contents),L0903_Contents  ;57
DW      BANK(L1003_Contents),L1003_Contents  ;58
DW      BANK(L1103_Contents),L1103_Contents  ;59
DW      BANK(L1203_Contents),L1203_Contents  ;60
DW      0,0                                  ;61
DW      BANK(L1403_Contents),L1403_Contents  ;62
DW      BANK(L1503_Contents),L1503_Contents  ;63
DW      BANK(L0004_Contents),L0004_Contents  ;64
DW      BANK(L0104_Contents),L0104_Contents  ;65
DW      BANK(L0204_Contents),L0204_Contents  ;66
DW      BANK(L0304_Contents),L0304_Contents  ;67 0304 shroom
DW      BANK(L0404_Contents),L0404_Contents  ;68
DW      BANK(L0504_Contents),L0504_Contents  ;69
DW      BANK(L0604_Contents),L0604_Contents  ;70
DW      BANK(L0704_Contents),L0704_Contents  ;71
DW      BANK(L0804_Contents),L0804_Contents  ;72
DW      BANK(L0904_Contents),L0904_Contents  ;73
DW      BANK(L1004_Contents),L1004_Contents  ;74
DW      BANK(L1104_Contents),L1104_Contents  ;75
DW      BANK(L1204_Contents),L1204_Contents  ;76
DW      BANK(L1304_Contents),L1304_Contents  ;77
DW      0,0                                  ;78
DW      BANK(L1504_Contents),L1504_Contents  ;79
DW      BANK(L0005_Contents),L0005_Contents  ;80
DW      BANK(L0105_Contents),L0105_Contents  ;81  path
DW      BANK(L0205_Contents),L0205_Contents  ;82  bridge
DW      BANK(L0305_Contents),L0305_Contents  ;83
DW      BANK(L0405_Contents),L0405_Contents  ;84
DW      BANK(L0505_Contents),L0505_Contents  ;85
DW      BANK(L0605_Contents),L0605_Contents  ;86
DW      BANK(L0705_Contents),L0705_Contents  ;87
DW      BANK(L0805_Contents),L0805_Contents  ;88
DW      BANK(L0905_Contents),L0905_Contents  ;89
DW      BANK(L1005_Contents),L1005_Contents  ;90
DW      BANK(L1105_Contents),L1105_Contents  ;91
DW      0,0                                  ;92
DW      0,0                                  ;93
DW      0,0                                  ;94
DW      0,0                                  ;95
DW      BANK(L0006_Contents),L0006_Contents  ;96
DW      BANK(L0106_Contents),L0106_Contents  ;97   path
DW      0,0                                  ;98
DW      BANK(L0306_Contents),L0306_Contents  ;99
DW      BANK(L0406_Contents),L0406_Contents  ;100
DW      BANK(L0506_Contents),L0506_Contents  ;101
DW      BANK(L0606_Contents),L0606_Contents  ;102
DW      BANK(L0706_Contents),L0706_Contents  ;103
DW      BANK(L0806_Contents),L0806_Contents  ;104
DW      BANK(L0906_Contents),L0906_Contents  ;105
DW      BANK(L1006_Contents),L1006_Contents  ;106
DW      0,0                                  ;107
DW      0,0                                  ;108
DW      0,0                                  ;109
DW      0,0                                  ;110
DW      0,0                                  ;111
DW      BANK(L0007_Contents),L0007_Contents  ;112
DW      BANK(L0107_Contents),L0107_Contents  ;113  path
DW      0,0                                  ;114
DW      BANK(L0307_Contents),L0307_Contents  ;115
DW      BANK(L0407_Contents),L0407_Contents  ;116
DW      BANK(L0507_Contents),L0507_Contents  ;117
DW      BANK(L0607_Contents),L0607_Contents  ;118
DW      BANK(L0707_Contents),L0707_Contents  ;119
DW      BANK(L0807_Contents),L0807_Contents  ;120
DW      BANK(L0907_Contents),L0907_Contents  ;121
DW      BANK(L1007_Contents),L1007_Contents  ;122
DW      0,0                                  ;123
DW      0,0                                  ;124
DW      0,0                                  ;125
DW      0,0                                  ;126
DW      0,0                                  ;127
DW      BANK(L0008_Contents),L0008_Contents
DW      BANK(L0108_Contents),L0108_Contents
DW      0,0                                  ;130
DW      BANK(L0308_Contents),L0308_Contents
DW      BANK(L0408_Contents),L0408_Contents
DW      BANK(L0508_Contents),L0508_Contents
DW      BANK(L0608_Contents),L0608_Contents
DW      BANK(L0708_Contents),L0708_Contents
DW      BANK(L0808_Contents),L0808_Contents
DW      BANK(L0908_Contents),L0908_Contents
DW      BANK(L1008_Contents),L1008_Contents
DW      0,0                                  ;139
DW      0,0                                  ;140
DW      0,0                                  ;141
DW      0,0                                  ;142
DW      0,0                                  ;143
DW      BANK(L0009_Contents),L0009_Contents
DW      BANK(L0109_Contents),L0109_Contents
DW      0,0                                  ;146
DW      BANK(L0309_Contents),L0309_Contents
DW      BANK(L0409_Contents),L0409_Contents
DW      BANK(L0509_Contents),L0509_Contents
DW      BANK(L0609_Contents),L0609_Contents
DW      BANK(L0709_Contents),L0709_Contents
DW      BANK(L0809_Contents),L0809_Contents
DW      BANK(L0909_Contents),L0909_Contents
DW      BANK(L1009_Contents),L1009_Contents
DW      0,0                                  ;155
DW      0,0                                  ;156
DW      0,0                                  ;157
DW      0,0                                  ;158
DW      0,0                                  ;159
DW      BANK(L0010_Contents),L0010_Contents
DW      BANK(L0110_Contents),L0110_Contents
DW      0,0                                  ;162
DW      BANK(L0310_Contents),L0310_Contents
DW      BANK(L0410_Contents),L0410_Contents
DW      BANK(L0510_Contents),L0510_Contents
DW      BANK(L0610_Contents),L0610_Contents
DW      BANK(L0710_Contents),L0710_Contents
DW      BANK(L0810_Contents),L0810_Contents
DW      BANK(L0910_Contents),L0910_Contents
DW      BANK(L1010_Contents),L1010_Contents
DW      0,0                                  ;171
DW      0,0                                  ;172
DW      0,0                                  ;173
DW      0,0                                  ;174
DW      0,0                                  ;175
DW      BANK(L0011_Contents),L0011_Contents
DW      BANK(L0111_Contents),L0111_Contents
DW      BANK(L0211_Contents),L0211_Contents
DW      BANK(L0311_Contents),L0311_Contents
DW      BANK(L0411_Contents),L0411_Contents
DW      0,0                                  ;181
DW      0,0                                  ;182
DW      BANK(L0711_Contents),L0711_Contents
DW      BANK(L0811_Contents),L0811_Contents
DW      BANK(L0911_Contents),L0911_Contents
DW      BANK(L1011_Contents),L1011_Contents
DW      BANK(L1111_Contents),L1111_Contents
DW      0,0                                  ;188
DW      0,0                                  ;189
DW      0,0                                  ;190
DW      0,0                                  ;191
DW      BANK(L0012_Contents),L0012_Contents
DW      BANK(L0112_Contents),L0112_Contents
DW      BANK(L0212_Contents),L0212_Contents
DW      BANK(L0312_Contents),L0312_Contents
DW      BANK(L0412_Contents),L0412_Contents
DW      BANK(L0512_Contents),L0512_Contents
DW      BANK(L0612_Contents),L0612_Contents
DW      BANK(L0712_Contents),L0712_Contents
DW      BANK(L0812_Contents),L0812_Contents
DW      BANK(L0912_Contents),L0912_Contents
DW      BANK(L1012_Contents),L1012_Contents
DW      BANK(L1112_Contents),L1112_Contents
DW      BANK(L1212_Contents),L1212_Contents
DW      BANK(L1312_Contents),L1312_Contents
DW      BANK(L1412_Contents),L1412_Contents
DW      BANK(L1512_Contents),L1512_Contents
DW      BANK(L0013_Contents),L0013_Contents  ;208 intro_ba1
DW      BANK(L0113_Contents),L0113_Contents  ;209 intro_ba2
DW      BANK(L0213_Contents),L0213_Contents  ;210 intro_ba3
DW      BANK(L0313_Contents),L0313_Contents  ;211 intro_ba4
DW      BANK(L0413_Contents),L0413_Contents  ;212
DW      0,0                                  ;213
DW      0,0                                  ;214
DW      0,0                                  ;215
DW      0,0                                  ;216
DW      0,0                                  ;217
DW      0,0                                  ;218
DW      0,0                                  ;219
DW      0,0                                  ;220
DW      0,0                                  ;221
DW      0,0                                  ;222
DW      0,0                                  ;223
DW      BANK(L0014_Contents),L0014_Contents  ;224 intro haiku 1
DW      BANK(L0114_Contents),L0114_Contents  ;225 intro haiku 2
DW      BANK(L0214_Contents),L0214_Contents  ;226 intro haiku 3
DW      BANK(L0314_Contents),L0314_Contents  ;227 intro haiku 4 (escape)
DW      0,0                                  ;228
DW      0,0                                  ;229
DW      0,0                                  ;230
DW      0,0                                  ;231
DW      0,0                                  ;232
DW      0,0                                  ;233
DW      0,0                                  ;234
DW      0,0                                  ;235
DW      0,0                                  ;236
DW      0,0                                  ;237
DW      0,0                                  ;238
DW      0,0                                  ;239
DW      BANK(L0015_Contents),L0015_Contents  ;240 intro bs 1
DW      BANK(L0115_Contents),L0115_Contents  ;241 intro bs 2
DW      BANK(L0215_Contents),L0215_Contents  ;242 intro bs 3
DW      BANK(L0315_Contents),L0315_Contents  ;243 intro bs 4
DW      0,0                                  ;244
DW      0,0                                  ;245
DW      0,0                                  ;246
DW      0,0                                  ;247
DW      0,0                                  ;248
DW      0,0                                  ;249
DW      0,0                                  ;250
DW      0,0                                  ;251
DW      0,0                                  ;252
DW      0,0                                  ;253
DW      0,0                                  ;254
DW      0,0                                  ;255

;SECTION "BGTileSection",ROMX,BANK[BGTILEROM]
SECTION "BGTileSection",ROMX[$4000],BANK[BGTILEROM1]
BGTiles::
DB     0,0,0,0, 0,0,0,0, 0,0,0,0,0,0,0,0  ;blank tile zero
INCBIN "Data/Tiles/bgTiles1-256.bin"
INCBIN "Data/Tiles/bgTiles257-512.bin"
INCBIN "Data/Tiles/bgTiles513-768.bin"
INCBIN "Data/Tiles/bgTiles769-979.bin"

SECTION "BGTileSection2",ROMX[$4000],BANK[BGTILEROM2]
BGTiles1024::
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
INCBIN "Data/Tiles/bgTiles1024-1279.bin"
INCBIN "Data/Tiles/bgTiles1280-1535.bin"
INCBIN "Data/Tiles/bgTiles1536-1791.bin"
INCBIN "Data/Tiles/bgTiles1792-2047.bin"

;DS     16*((1024-256)-1)       ;pad tiles

SECTION "BGColorTable",ROMX[$4000]
bg_colorTable::  ;defines a byte for the tile attribute (color) for each class
;0=Grey, 1=Red, 2=Blue, 3=Green, 4=Purple, 5=Yellow, 6=Brown/Orange, 7=Fuscia
;+8=can walk over
;+16=can shoot over
;+32=attackable

  ;bg tiles
;     1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0
  DB  0                                        ;  0
  DB  0, 0, 0, 4, 2, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;  1- 20
  DB  0, 3, 3, 3, 3, 3,34,34,34,34,34,34,34,34,34,34,34,34,34,34  ; 21- 40
  DB 34,34,34,34,34,34,34,34,34,34, 1, 1, 1, 1, 2, 2, 2, 2, 6, 6  ; 41- 60
  DB  6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ; 61- 80
  DB  6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; 81-100
  DB  0, 0, 0, 0, 0,38,38,38,38, 2,36,36,36,36,36,36,36,36,36,36  ;101-120
  DB 36,36,39, 6, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 4, 4, 4, 4, 5  ;121-140
  DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2  ;141-160
  DB  2, 2, 2, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;161-180
  DB  0, 0, 0, 6, 4, 1, 5, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4  ;181-200
  DB  4, 4, 4, 4, 6, 6, 6, 6, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3  ;201-220
  DB  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3  ;221-240
  DB  3, 3, 3, 3, 3, 3, 0,16, 0, 6, 6, 3, 3, 3, 3, 0,37,37,37,37  ;241-260
  DB 37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37  ;261-280
  DB 37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37  ;281-300
  DB 37,37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;301-320
  DB  0, 0,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18  ;321-340
  DB 18,18, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;341-360
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3  ;361-380
  DB  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0  ;381-400
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6  ;401-420
  DB  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 6, 5, 5, 5, 5  ;421-440
  DB  5, 5, 5, 6,18,18,18,18,18,18,18,18,18,18,18,18, 0, 0, 0,18  ;441-460   ;water
  DB 18,18,18,22,22,22,22,22,22,22,22,22,22,22,22,22,22, 7, 4, 4  ;461-480 ;bank
  DB  4, 4, 4, 4, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 3, 3  ;481-500
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3  ;501-520
  DB  3, 3, 3, 3, 3, 3, 3, 3, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2  ;521-540
  DB  2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2  ;541-560
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;561-580
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;581-600
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1  ;601
  DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0  ;621
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;641
  DB  0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4  ;661
  DB  4, 4, 4, 6, 6, 6, 6, 3, 6, 6, 6, 6, 6, 6, 6, 6, 6, 3, 6, 3  ;681
  DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 3, 3, 3, 3  ;701
  DB  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1  ;721
  DB  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  ;741
  DB  1, 1, 1, 1, 1, 1, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;761
  DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;781
  DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;801
  DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;821
  DB  6, 6, 6, 6, 6,38, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,38, 6, 0  ;841
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6  ;861
  DB  1, 1, 1, 1, 1, 1, 0, 0, 0, 0,32, 0, 3, 3, 3, 3,35, 3, 5, 5  ;881
  DB  5, 5,37, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6  ;901
  DB  6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3  ;921
  DB  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;941
  DB  0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5,37, 5, 1, 1, 1, 1  ;961
  DB  5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;981
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1001
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1021
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1041
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,34,34,34,34, 2, 2, 2, 2  ;1061
  DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2  ;1081
  DB  1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1,24,24,24,24  ;1101
  DB 24,24,24,24,24,24,24,24,24,24,24,24, 0, 0, 0, 2, 2, 0, 0, 0  ;1121
;     1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0
;0=Grey, 1=Red, 2=Blue, 3=Green, 4=Purple, 5=Yellow, 6=Brown/Orange, 7=Fuscia
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,32  ;1141
  DB 32, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1161
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1181
  DB  3, 6, 6, 6, 6, 3, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;1201
  DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 3, 3, 3  ;1221
  DB  3, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4  ;1241
  DB  4,32,32,32,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 6, 0  ;1261
  DB  2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 0,32,32, 0, 0, 0, 0, 0, 0, 0  ;1281
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1301
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2  ;1321
  DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 5, 2, 2, 3  ;1341
  DB  3, 3, 3, 1, 1, 3, 3, 3, 3, 3, 6, 5, 5, 3, 3, 3, 2, 2, 2, 2  ;1361
  DB  2, 2, 2, 0, 0, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1381
  DB  0,35,35,35,35,35, 8, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1401
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1421
  DB  0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 5, 6, 6  ;1441
  DB  1, 3, 2,33,33,33,33,34,34,34,34,38,38,38,38,32,32,32,32,32  ;1461
  DB 32,32,32,32,32,32,32,32,32,33,33,33,33,35,35,35,35,35,35,35  ;1481
  DB 35,35,35,35,35,35,35,35,35,35,35,29,37,37,37,37,37,37,37,37  ;1501
  DB 37,37,37,37,37,37,37,37,37,37,37,37,16,25,25,25,29,30,32,32  ;1521
  DB 32,32,32,32,32,32, 4, 4, 4, 4,53,53,53,53,53,53,53,53,53,53  ;1541
  DB 53,53,53,53,53,53,53,53, 0, 0, 0,30,29, 2, 2, 2, 2, 2, 2, 2  ;1561
  DB  2, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;1581
  DB  6, 6, 6, 6, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0  ;1601
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1621
  DB  0, 0,32,32,32,32,32,32,32,32,32,30, 6, 6, 6, 6, 6, 6, 6, 6  ;1641
  DB  6, 6, 6, 6, 6, 6, 6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0  ;1661
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2  ;1681
  DB  2, 2, 2, 0, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6  ;1701
  DB  6, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6  ;1721
  DB  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 3, 3, 3, 0  ;1741
  DB  0, 3, 3, 3, 0,32,32,32,32,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1761
  DB  0,32,32, 0, 0,32,32, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2  ;1781
  DB  2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1  ;1801
  DB  1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2  ;1821
  DB  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,33, 1,34, 2,33,33  ;1841
  DB  1, 1,34,34, 2, 2,33,33, 1, 1,34,34, 2, 2, 6, 0, 0, 0, 0,24  ;1861
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1881
  DB  1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1901
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1921
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1941
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1961
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;1981
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;2001
  DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 5  ;2021
  DB  0, 0,25, 0, 0, 5, 1                                         ;2041
;     1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0
;0=Grey, 1=Red, 2=Blue, 3=Green, 4=Purple, 5=Yellow, 6=Brown/Orange, 7=Fuscia
;+8=can walk over
;+16=can shoot over
;+32=attackable

SECTION "FGTileSection",ROMX[$4800]
FGTiles:
INCBIN "Data/Tiles/fgTiles2048-2302.bin"  ;monsta tiles
INCBIN "Data/Tiles/fgTiles2304-2559.bin"  ;monsta tiles


fg_colorTable::  ;defines a byte for the tile attribute (color) for each class
;0=Grey, 1=Red, 2=Blue, 3=Green, 4=Purple, 5=Yellow, 6=Brown/Orange, 7=Fuscia
; + any combination of:
;16 = is bullet
;32 = 2x2 monster
;64 = no rotate when facing N/S
;128 = can't be thrown (probably stationary)

;obj tiles
;  +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +0 +1 +2 +3 +4 +5 +6 +7 +8 +9
;   8  9  0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7
DB  4, 4, 2, 2, 5, 5, 1, 1, 2, 2, 3, 3, 3, 3,64, 2, 2, 6, 6,64  ;2048 +0
DB  0,133,5, 0, 0, 0, 0, 0, 0, 1, 0, 6, 6, 4, 0, 4, 0, 5, 5, 5  ;2068 +20
DB  5,195,195,0,0,65,65, 6, 6,70,70,67, 0, 0,35,35,35,35,35,35  ;2088 +40
DB  0, 0, 0, 0, 2, 2, 5, 5, 6, 6, 0, 0,38,38,38,38,38,38,38,38  ;2108 +60
DB  6, 6,16,16,16,16,16,16, 3, 3, 0, 0,165,165,165,165,2,2,1,1  ;2128 +80
DB  4, 0, 0, 0, 2, 2, 3, 3, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5  ;2148 +100
DB 166,0, 0, 0, 0, 0,70,70,70,70,64,64,65,65,66,66,35,35,35,35  ;2168 +120
DB 35,35, 0, 0, 6, 6, 6, 6,66,66,70,70, 6, 6,16,16, 6, 6,16,16  ;2188 +140
DB  0, 0,16,16,16,16,16,16,16,16,16,16, 6, 6,38,38,38,38,38,38  ;2208 +160
DB 38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,37,37  ;2228 +180
DB 37,37,37,37,37,37, 3, 3, 5, 5,33,33,33,33,33,33,33,33, 1, 1  ;2248 +200
DB 34,34,34,34,34,34,34,34, 5, 5, 4, 4, 0, 0, 5, 5, 5, 5, 0, 0  ;2268 +220
DB  3, 3, 1, 1, 4, 4,16,16,34,34,34,34,19,19, 0, 0,64,64,65,65  ;2288 +240
DB  3, 3, 5, 5, 0, 0, 0, 6, 6,21,21,38,38,38,38,38,38,38,38, 3  ;2308 +260
DB  3, 7, 7, 5, 6, 6, 6,37, 5, 5, 5,37, 5, 5, 5,163,3, 3, 3, 6  ;2328 +280
DB  6, 6, 6,35, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,32, 0, 0, 0, 0, 0  ;2348 +300
DB  0, 0,32, 0, 0, 0,38, 0, 0, 0, 0, 0, 0, 0,16, 0, 1, 0, 2, 0  ;2368 +320
DB  3, 0,35, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0,70, 0, 0, 0, 0, 0  ;2388 +340
DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;2408 +360
DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;2428 +380
DB  0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 2, 0, 5, 0, 1, 0, 0, 0, 0, 0  ;2448 +400
DB  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ;2468 +420

;  +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +0 +1 +2 +3 +4 +5 +6 +7 +8 +9
;   8  9  0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7

;---------------------------------------------------------------------
SECTION "MapBGPix",ROMX
;---------------------------------------------------------------------
waitingToJoin_bg:
  INCBIN "Data/Cinema/menu/WaitingToJoin.bg"

