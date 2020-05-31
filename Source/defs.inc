INCLUDE "Source/class.inc"

DEBUG EQU 0
EMULATORCOMPATIBLE EQU 1

ENV_NONE       EQU 0
ENV_RAIN       EQU 1
ENV_SNOW       EQU 2
ENV_WINDYSNOW  EQU 3
ENV_DIRT       EQU 4
ENV_CLOUDS     EQU 5
ENV_COUNTER    EQU 6
ENV_DISCO      EQU 7

HERODATASIZE EQU 16

HERODATA_DATA         EQU   0
HERODATA_JOY          EQU   0
HERODATA_INDEX        EQU   1
HERODATA_OBJ          EQU   2
HERODATA_BULLET_INDEX EQU   4
HERODATA_CLASS        EQU   5
HERODATA_ENTERDIR     EQU   7
HERODATA_ENTERLOC     EQU   8
HERODATA_I            EQU  10
HERODATA_J            EQU  11
HERODATA_TYPE         EQU  12
HERODATA_HEALTH       EQU  13
HERODATA_MOVED        EQU  14    ;to help with strafe etc
HERODATA_PUFFCOUNT    EQU  15

DLG_BORDER EQU %00000001
DLG_PRESSB EQU %00000010
DLG_WAITRELEASE EQU %00000100
DLG_NOCLEAR     EQU %00001000
DLG_BRAINIAC    EQU %00010000
DLG_CLEARSKIP   EQU %00100000

DLG_BORDER_BIT      EQU 0
DLG_PRESSB_BIT      EQU 1
DLG_WAITRELEASE_BIT EQU 2
DLG_NOCLEAR_BIT     EQU 3
DLG_BRAINIAC_BIT    EQU 4
DLG_CLEARSKIP_BIT   EQU 5
;dialog settings are tweaked in CheckSkip

JOY_START      EQU $80
JOY_SELECT     EQU $40
JOY_B          EQU $20
JOY_A          EQU $10
JOY_DOWN       EQU $08
JOY_UP         EQU $04
JOY_LEFT       EQU $02
JOY_RIGHT      EQU $01

JOY_START_BIT  EQU 7
JOY_SELECT_BIT EQU 6
JOY_B_BIT      EQU 5
JOY_A_BIT      EQU 4
JOY_DOWN_BIT   EQU 3
JOY_UP_BIT     EQU 2
JOY_LEFT_BIT   EQU 1
JOY_RIGHT_BIT  EQU 0

FIRSTOBJTILE   EQU 160
TOTALOBJTILE   EQU 80
TOTALTILES     EQU ((FIRSTOBJTILE - TOTALOBJTILE) - 1)

;reserved classes indicate that a tile in the map is part of a larger
;creature.  If a tile were "CLASS_ADJOIN_N", for example, then the tile
;to the north would be either the actual monster or a pointer indicating
;which direction to look next
CLASS_ADJOIN_N EQU $fc
CLASS_ADJOIN_E EQU $fd
CLASS_ADJOIN_S EQU $fe
CLASS_ADJOIN_W EQU $ff

DIR_NORTH EQU 0
DIR_EAST  EQU 1
DIR_SOUTH EQU 2
DIR_WEST  EQU 3

EXIT_N    EQU 1
EXIT_E    EQU 2
EXIT_S    EQU 3
EXIT_W    EQU 4
EXIT_U    EQU 5
EXIT_D    EQU 6
EXIT_X    EQU 7

;RAM banks
MAPBANK       EQU 1
TILEINDEXBANK EQU 2
OBJLISTBANK   EQU 2
OBJBANK       EQU 3
TILESHADOWBANK EQU 4
ATTRSHADOWBANK EQU 5
ZONEBANK       EQU 6
WAYPOINTBANK   EQU 7
LEVELSTATEBANK EQU 7
FADEBANK       EQU 7
MUSICBANK      EQU 7
FLIGHTCODEBANK EQU 7

;ROM banks
;0 - HOME:   All map- and gfx-loading routines are here as well as the
;            main control structures.  The class vector table is also
;            stored here.
;1 - CLASS:  All class+object methods for the main game are here.  This 
;            bank is switched in after a level has been loaded.
;2 - Tile0:  First set of tile bitmap data and attribute tables.
;3 - Map0:   First set of level data
CLASSROM     EQU  1
OBJROM       EQU  1
BGTILEROM1   EQU  2
BGTILEROM2   EQU  5
FGTILEROM    EQU  3
MAP0ROM      EQU  4

FX_FADE      EQU  1

;Flags (BGAttributes)
BG_FLAG_SPECIAL    EQU  %00111000
BG_FLAG_WALKOVER   EQU  %00001000
BG_FLAG_SHOOTOVER  EQU  %00010000
BG_FLAG_ATTACKABLE EQU  %00100000

BG_BIT_WALKOVER   EQU 3
BG_BIT_SHOOTOVER  EQU 4
BG_BIT_ATTACKABLE EQU 5

;Game State Flags
HERO_BA_FLAG       EQU  %00000001
HERO_CS_FLAG       EQU  %00000001

HERO_BS_FLAG         EQU  %00000010
HERO_RA_FLAG         EQU  %00000010
HERO_FREEVERSE_FLAG  EQU  %00000010

HERO_HAIKU_FLAG    EQU  %00000100
HERO_FLOUR_FLAG    EQU  %00001000
HERO_FLOWER_FLAG   EQU  %00010000
HERO_GRENADE_FLAG  EQU  %00100000

HERO_BA_BIT        EQU  0
HERO_BS_BIT        EQU  1
HERO_HAIKU_BIT     EQU  2
HERO_FLOUR_BIT     EQU  3
HERO_FLOWER_BIT    EQU  4
HERO_GRENADE_BIT   EQU  5

;link cable codes
LTRUE          EQU 1
LSYNCHREADY    EQU 1
LSYNCHWAIT     EQU 2
LNULL          EQU $40    ;control code %01000000 = no buttons
LGETGAMESTATE  EQU $81
LGETMAPINDEX   EQU $82
LUPDATESTATE   EQU $83
LUPDATEHERO    EQU $84
LSYNCHRONIZE   EQU $85
LYANKPLAYER    EQU $86    ;yank player to specified map
LTERMINATE     EQU $87    ;terminate the current link
LRESYNCHRONIZE EQU $88 
LGETRANDOMSEED EQU $89 
LLOCKHEROES    EQU $8a
LCHANGEAPPXMAP EQU $8b
LADDINVITEM    EQU $8c
LREMINVITEM    EQU $8d
LUPDATEMEMORY  EQU $8e
LLINKTEST      EQU $90
LNOLINK        EQU $ff

;main.asm
GLOBAL encodeControlByteTable
GLOBAL decodeControlByteTable

;user.asm
GLOBAL SetActiveROM
GLOBAL LongCall
GLOBAL LongCallNoArgs
GLOBAL WaitFade
GLOBAL GetInput
GLOBAL VWait
GLOBAL UpdateObjects
GLOBAL RedrawMap
GLOBAL HandleRemoteInput
GLOBAL TransmitByte
GLOBAL ReceiveByte
GLOBAL ExchangeByte
GLOBAL TransmitData
GLOBAL ReceiveData
GLOBAL TransmitCompressedData
GLOBAL ReceiveCompressedData
GLOBAL CheckSimultaneousLCC
GLOBAL YankRemotePlayer
GLOBAL RemoveRemoteHero
GLOBAL DebugMesg
GLOBAL DebugVal
GLOBAL SetDialogSkip
GLOBAL SetDialogForward
GLOBAL ClearDialogSkipForward
GLOBAL ClearSkipForward
GLOBAL SetSkipStackPos
GLOBAL OnHBlank 
GLOBAL CinemaOnHBlank 
GLOBAL HOffsetOnHBlank 
GLOBAL SeasonsOnHBlank 
GLOBAL UpdateObjTimers
GLOBAL InstallHBlankHandler
GLOBAL PlaySample
GLOBAL samplePlaying
GLOBAL sampleBank
GLOBAL sampleAddress
GLOBAL sampleMask
GLOBAL AddAppomattoxIfPresent
GLOBAL Lookup8
GLOBAL Lookup16
GLOBAL LookupIndexOfData8
GLOBAL FindFirstBGLoc
GLOBAL LinkTransmitMemoryLocation

GLOBAL curInput0
GLOBAL curInput1
GLOBAL dialogJoyIndex
GLOBAL dialogSpeakerIndex
GLOBAL getLocInitFacing
GLOBAL losLimit
GLOBAL longCallTempA
GLOBAL amChangingMap
GLOBAL curHeroAddressL
GLOBAL heroesPresent
GLOBAL vblankTimer
GLOBAL backBufferReady
GLOBAL backBufferDestHighByte
GLOBAL paletteBufferReady
GLOBAL dmaLoad
GLOBAL randomLoc
GLOBAL jiggleDuration
GLOBAL jiggleType
GLOBAL transmitACK
GLOBAL hblankVector

GLOBAL objTimerBase
GLOBAL objTimer60ths
GLOBAL heroTimerBase
GLOBAL heroTimer60ths
GLOBAL levelCheckSkip
GLOBAL dialogSettings
GLOBAL fadeRange
GLOBAL moveAlignPrecision
GLOBAL fireBulletDirection
GLOBAL fireBulletDamage
GLOBAL fireBulletSound
GLOBAL fireBulletLocation
GLOBAL explosionInitialFrame
GLOBAL myGroup
GLOBAL myFacing
GLOBAL secondChoiceDirection

GLOBAL curLevelIndex
GLOBAL curLevelStateIndex
GLOBAL timeToChangeLevel
GLOBAL mapTotalSize
GLOBAL mapExitLinks
GLOBAL specialFX
GLOBAL dmaLoadSrc0
GLOBAL dmaLoadDest0
GLOBAL dmaLoadLen0
GLOBAL dmaLoadSrc1
GLOBAL dmaLoadDest1
GLOBAL dmaLoadLen1
GLOBAL bgFlags
GLOBAL baMoved
GLOBAL bsMoved
GLOBAL heroJoyIndex
GLOBAL myJoy
GLOBAL levelCheckStackPos
GLOBAL displayType
GLOBAL scrollSprites
GLOBAL heroesIdle
GLOBAL allIdle
GLOBAL dialogIdleSettings
GLOBAL canJoinMap
GLOBAL checkTemp
GLOBAL metaSprite_y
GLOBAL metaSprite_x
GLOBAL metaSprite_first_x

GLOBAL curJoy0
GLOBAL hero0_data
GLOBAL hero0_index
GLOBAL hero0_object
GLOBAL hero0_bullet_index
GLOBAL hero0_class
GLOBAL hero0_enterLevelFacing
GLOBAL hero0_enterLevelLocation
GLOBAL hero0_i
GLOBAL hero0_j
GLOBAL hero0_type
GLOBAL hero0_health
GLOBAL hero0_moved
GLOBAL hero0_puffCount

GLOBAL curJoy1
GLOBAL hero1_data
GLOBAL hero1_index
GLOBAL hero1_object
GLOBAL hero1_bullet_index
GLOBAL hero1_class
GLOBAL hero1_enterLevelFacing
GLOBAL hero1_enterLevelLocation
GLOBAL hero1_i
GLOBAL hero1_j
GLOBAL hero1_type
GLOBAL hero1_health
GLOBAL hero1_moved
GLOBAL hero1_puffCount

GLOBAL levelVars

GLOBAL linkBailOut

GLOBAL musicEnabled
GLOBAL musicOverride1
GLOBAL musicOverride4
GLOBAL musicBank
GLOBAL musicNoteCountdownInit
GLOBAL musicNoteCountdown
GLOBAL musicTrack1Pos
GLOBAL musicTrack2Pos
GLOBAL musicTrack3Pos
GLOBAL musicTrack4Pos
GLOBAL musicInstrument1
GLOBAL musicInstrument2
GLOBAL musicInstrument3
GLOBAL musicInstrument4
GLOBAL musicWaveform
GLOBAL musicStack
GLOBAL curTrackStackL
GLOBAL musicStackL1
GLOBAL musicStackL2
GLOBAL musicStackL3
GLOBAL musicStackL4
GLOBAL musicRegisters
GLOBAL musicAddress

GLOBAL numFreeObjects
GLOBAL fgFlags
GLOBAL lineZeroHorizontalOffset
GLOBAL exitTileIndex

GLOBAL hblankWinOn
GLOBAL hblankWinOff
GLOBAL hblankFlag

;gfx.asm
GLOBAL LoadNextLevel
GLOBAL temp
GLOBAL drawMapTemp
GLOBAL SpriteDMAHandler
GLOBAL InitGfx
GLOBAL DisplayOff
GLOBAL VMemCopy
GLOBAL MemSet
GLOBAL MemCopy
GLOBAL InitDMALoad
GLOBAL WaitDMALoad
GLOBAL DMALoad
GLOBAL SetupCommonColor
GLOBAL AddHL16
GLOBAL AddDE16
GLOBAL GenerateFacings
GLOBAL LoadSprites
GLOBAL LoadFont
GLOBAL PrepareForInitialMapDraw
GLOBAL DrawMapToBackBuffer
GLOBAL DrawCinemaToBackBuffer
GLOBAL AdjustCameraToHero
GLOBAL GentleCameraAdjust
GLOBAL RestrictCameraToBounds
GLOBAL ScrollToCamera
GLOBAL ScrollSpritesLeft
GLOBAL ScrollSpritesRight
GLOBAL ScrollSpritesUp
GLOBAL ScrollSpritesDown
GLOBAL GetRandomNumZeroToN
GLOBAL GetRandomNumMask
GLOBAL SetupFadeFromWhite
GLOBAL SetupFadeFromStandard
GLOBAL FadeCommonSetPaletteToWhite
GLOBAL FadeCommonSetPaletteToBlack
GLOBAL FadeCommonSetPaletteToBlackBGOnly
GLOBAL SetupFadeToWhite
GLOBAL SetupFadeToStandard
GLOBAL SetupFadeFromBlack
GLOBAL BlackoutPalette
GLOBAL SetupFadeToBlack
GLOBAL SetupFadeFromBlackBGOnly
GLOBAL SetupFadeToBlackBGOnly
GLOBAL SetupFadeFromSaturated
GLOBAL SetupFadeToGamePalette
GLOBAL SetupFadeToHalfbrite
GLOBAL FadeCommonCopyPalette
GLOBAL CopyPalette64
GLOBAL CopyPalette32
GLOBAL InstallGamePalette
GLOBAL FadeInit
GLOBAL FadeStep
GLOBAL LighteningOut
GLOBAL LighteningIn
GLOBAL GetRedComponent
GLOBAL GetGreenComponent
GLOBAL GetBlueComponent
GLOBAL SetRedComponent
GLOBAL SetGreenComponent
GLOBAL SetBlueComponent
GLOBAL PlaySound
GLOBAL PlaySoundChannel1
GLOBAL PlaySoundChannel2
GLOBAL PlaySoundChannel3
GLOBAL PlaySoundChannel4

GLOBAL WaitInput
GLOBAL WaitInputZero
GLOBAL WaitInputClick
GLOBAL CreateBigExplosion
GLOBAL BlitMap
GLOBAL LCheckGetVectorToState
GLOBAL SaveIdle
GLOBAL RestoreIdle
GLOBAL MakeIdle
GLOBAL MakeNonIdle
GLOBAL UseAlternatePalette
GLOBAL UpdateDialogBalloons
GLOBAL DisableDialogBalloons
GLOBAL ResetFreeSprites
GLOBAL UpdateEnvEffect
GLOBAL SetEnvEffect

GLOBAL CheckEachHero
GLOBAL RemoveHero
GLOBAL SetRespawnMap
GLOBAL SetJoinMap
GLOBAL SetLinkBailOutAddress
GLOBAL SetHBlankHandler
GLOBAL GetMethodAddrFromPointer
GLOBAL CallBGAction

GLOBAL ResetSprites

;cinema.asm
GLOBAL LoadCinemaBG
GLOBAL LoadCinemaSprite
GLOBAL LoadCinemaTextBox
GLOBAL CinemaBlitRect
GLOBAL CinemaSpotAnimationRandomVerticalFrames
GLOBAL CinemaSpotAnimationRandomHorizontalFrames
GLOBAL StdWaitDialogNoClear
GLOBAL StdWaitDialog

;cinema character animation routines
GLOBAL AnimateSkippy
GLOBAL AnimateFlour
GLOBAL AnimateHaiku
GLOBAL AnimateBRAINIAC
GLOBAL AnimateLadyFlower
GLOBAL AnimateFlourDriving
GLOBAL AnimateBS
GLOBAL AnimateBA
GLOBAL AnimateLadyFlowerDistress
GLOBAL AnimateCaptainGunpoint
GLOBAL State0To1


;map.asm
GLOBAL BGTiles1024
GLOBAL LoadMap
GLOBAL MapCoordsToIndex
GLOBAL SetupMapVarsFromWidthPitchAndHeight
GLOBAL ParseMap
GLOBAL ClearBackBuffer
GLOBAL SetBGSpecialFlags
GLOBAL ResetMyBGSpecialFlags
GLOBAL CallMapInit
GLOBAL LoadAssociatedClass
GLOBAL SaveFGTileInfo
GLOBAL RestoreFGTileInfo
GLOBAL PrepSetupHero
GLOBAL PrepSetupHeroBC
GLOBAL SetupHero
GLOBAL FindExitLocation
GLOBAL FindClassIndex
GLOBAL ChangeClass
GLOBAL ChangeFirstClass
GLOBAL ChangeMyClass
GLOBAL ChangeMyClassAndRedraw
GLOBAL ChangeMyClassToAssociatedAndRedraw
GLOBAL RemoveObjectFromList
GLOBAL AddObjectToList
GLOBAL CopyMapMethodToRAM
GLOBAL HandleExitFromMap
GLOBAL HasInventoryItem
GLOBAL AddInventoryItem
GLOBAL GetFirstInventoryIndex
GLOBAL GetNextInventoryIndex
GLOBAL RemoveInventoryItem
GLOBAL GuestContinueSynchronization

GLOBAL map
GLOBAL zoneBuffer
GLOBAL backBuffer
GLOBAL attributeBuffer
GLOBAL tileShadowBuffer
GLOBAL attributeShadowBuffer
GLOBAL gamePalette
GLOBAL objBackBuffer
GLOBAL objAttributeBuffer
GLOBAL mapOffsetNorth
GLOBAL mapOffsetEast
GLOBAL mapOffsetSouth
GLOBAL mapOffsetWest
GLOBAL mapWidth
GLOBAL mapPitch
GLOBAL mapPitchMinusOne
GLOBAL mapPitchMinusOneComplement
GLOBAL mapSkip
GLOBAL mapHeight
GLOBAL numClasses
GLOBAL firstHero
GLOBAL numFGTiles
GLOBAL fgDestPtr
GLOBAL firstMonster
GLOBAL mapColor
GLOBAL mapLeft
GLOBAL mapTop
GLOBAL mapRight
GLOBAL mapBottom
GLOBAL mapRightPlusOne
GLOBAL mapBottomPlusOne
GLOBAL mapMaxLeft
GLOBAL mapMaxTop
GLOBAL camera_i;
GLOBAL camera_j;
GLOBAL distToWall_N
GLOBAL distToWall_E
GLOBAL distToWall_S
GLOBAL distToWall_W

GLOBAL curROMBank
GLOBAL updateTimer
GLOBAL curObjWidthHeight
GLOBAL scrollSpeed

GLOBAL gameState
GLOBAL heroesAvailable
GLOBAL heroesUsed
GLOBAL heroesLocked
GLOBAL appomattoxMapIndex
GLOBAL respawnMap
GLOBAL joinMap
GLOBAL guardAlarm
GLOBAL amLinkMaster
GLOBAL lastLinkAction
GLOBAL checkInputInMainLoop
GLOBAL amShowingDialog
GLOBAL gameStatePad

GLOBAL desiredMapLeft
GLOBAL desiredMapTop
GLOBAL curPixelOffset_x
GLOBAL curPixelOffset_y
GLOBAL desiredPixelOffset_x
GLOBAL desiredPixelOffset_y
GLOBAL scrollAccelState_x
GLOBAL scrollAccelState_y

GLOBAL tempL,tempH
GLOBAL delTempL,delTempH

GLOBAL methodParamL
GLOBAL methodParamH
GLOBAL bulletDirection
GLOBAL bulletLocation
GLOBAL bulletColor
GLOBAL bulletClassIndex
GLOBAL bulletDamage

GLOBAL inventory
GLOBAL dialogNPC_speakerIndex
GLOBAL dialogNPC_heroIndex
GLOBAL dialogBalloonClassIndex
GLOBAL envEffectType
GLOBAL bsUpgrades
GLOBAL baUpgrades
GLOBAL haikuUpgrades

GLOBAL mapBank
GLOBAL mapContents
GLOBAL mapState
GLOBAL mapDialogClassIndex
GLOBAL mapHeroZone

GLOBAL dialogBank
GLOBAL classLookup

GLOBAL bgTileMap
GLOBAL bgAttributes
GLOBAL fgTileMap
GLOBAL fgAttributes
GLOBAL spritesUsed
GLOBAL associatedIndex
GLOBAL flightCode
GLOBAL fadeCurPalette
GLOBAL fadeFinalPalette
GLOBAL fadeCurRGB
GLOBAL fadeDelta
GLOBAL fadeError
GLOBAL fadeSteps
GLOBAL fadeStepsToGo

GLOBAL FOFTable
GLOBAL wayPointList
GLOBAL pathList
GLOBAL pathMatrix
GLOBAL levelState
GLOBAL heroState

GLOBAL rainbowColors
GLOBAL horizontalOffset

GLOBAL levelCheckRAM
levelCheckADDR EQU $c900
GLOBAL spriteOAMBuffer

GLOBAL ShowTitle
GLOBAL SetSpeakerToFirstHero
GLOBAL SetSpeakerFromHeroIndex
GLOBAL SetPressBDialog
GLOBAL CheckDialogContinue
GLOBAL ShowDialogNPC
GLOBAL ShowDialogHero
GLOBAL ShowDialogAtTop
GLOBAL ShowDialogAtTopNoWait
GLOBAL ShowDialogAtTopCommon
GLOBAL ShowDialogAtBottom
GLOBAL ShowDialogAtBottomNoWait
GLOBAL ShowDialogAtBottomCommon
GLOBAL ShowDialogWait
GLOBAL ClearGTXLine
GLOBAL WriteGTXLine
GLOBAL ClearDialog
GLOBAL GfxBlitBackBufferToWindow
GLOBAL GfxShowStandardTextBox
GLOBAL CheckSkip
GLOBAL Delay

;music.asm
GLOBAL InitMusic
GLOBAL PlayMusic
GLOBAL StopMusic
GLOBAL IsCurMusic

GLOBAL beehive_gbm
GLOBAL hoedown_gbm
GLOBAL alarm_gbm
GLOBAL intro_cinema_gbm
GLOBAL bs_gbm
GLOBAL lady_flower_gbm
GLOBAL main_in_game_gbm
GLOBAL haiku_gbm
GLOBAL moon_base_ba_gbm
GLOBAL moon_base_haiku_gbm
;GLOBAL shroom_gbm
GLOBAL cowboy_gbm
GLOBAL frosty_gbm
GLOBAL fgbwar_gbm
GLOBAL wedding_gbm
GLOBAL takeoff_gbm
GLOBAL spaceish_gbm
GLOBAL death_gbm
GLOBAL jungle_gbm
GLOBAL mysterious_gbm

GLOBAL GetNumObjects

INCLUDE "Source/macro.inc"

