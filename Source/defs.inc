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
EXPORT encodeControlByteTable
EXPORT decodeControlByteTable

;user.asm
EXPORT SetActiveROM
EXPORT LongCall
EXPORT LongCallNoArgs
EXPORT WaitFade
EXPORT GetInput
EXPORT VWait
EXPORT UpdateObjects
EXPORT RedrawMap
EXPORT HandleRemoteInput
EXPORT TransmitByte
EXPORT ReceiveByte
EXPORT ExchangeByte
EXPORT TransmitData
EXPORT ReceiveData
EXPORT TransmitCompressedData
EXPORT ReceiveCompressedData
EXPORT CheckSimultaneousLCC
EXPORT YankRemotePlayer
EXPORT RemoveRemoteHero
EXPORT DebugMesg
EXPORT DebugVal
EXPORT SetDialogSkip
EXPORT SetDialogForward
EXPORT ClearDialogSkipForward
EXPORT ClearSkipForward
EXPORT SetSkipStackPos
EXPORT OnHBlank 
EXPORT CinemaOnHBlank 
EXPORT HOffsetOnHBlank 
EXPORT SeasonsOnHBlank 
EXPORT UpdateObjTimers
EXPORT InstallHBlankHandler
EXPORT PlaySample
EXPORT samplePlaying
EXPORT sampleBank
EXPORT sampleAddress
EXPORT sampleMask
EXPORT AddAppomattoxIfPresent
EXPORT Lookup8
EXPORT Lookup16
EXPORT LookupIndexOfData8
EXPORT FindFirstBGLoc
EXPORT LinkTransmitMemoryLocation

EXPORT curInput0
EXPORT curInput1
EXPORT dialogJoyIndex
EXPORT dialogSpeakerIndex
EXPORT getLocInitFacing
EXPORT losLimit
EXPORT longCallTempA
EXPORT amChangingMap
EXPORT curHeroAddressL
EXPORT heroesPresent
EXPORT vblankTimer
EXPORT backBufferReady
EXPORT backBufferDestHighByte
EXPORT paletteBufferReady
EXPORT dmaLoad
EXPORT randomLoc
EXPORT jiggleDuration
EXPORT jiggleType
EXPORT transmitACK
EXPORT hblankVector

EXPORT objTimerBase
EXPORT objTimer60ths
EXPORT heroTimerBase
EXPORT heroTimer60ths
EXPORT levelCheckSkip
EXPORT dialogSettings
EXPORT fadeRange
EXPORT moveAlignPrecision
EXPORT fireBulletDirection
EXPORT fireBulletDamage
EXPORT fireBulletSound
EXPORT fireBulletLocation
EXPORT explosionInitialFrame
EXPORT myGroup
EXPORT myFacing
EXPORT secondChoiceDirection

EXPORT curLevelIndex
EXPORT curLevelStateIndex
EXPORT timeToChangeLevel
EXPORT mapTotalSize
EXPORT mapExitLinks
EXPORT specialFX
EXPORT dmaLoadSrc0
EXPORT dmaLoadDest0
EXPORT dmaLoadLen0
EXPORT dmaLoadSrc1
EXPORT dmaLoadDest1
EXPORT dmaLoadLen1
EXPORT bgFlags
EXPORT baMoved
EXPORT bsMoved
EXPORT heroJoyIndex
EXPORT myJoy
EXPORT levelCheckStackPos
EXPORT displayType
EXPORT scrollSprites
EXPORT heroesIdle
EXPORT allIdle
EXPORT dialogIdleSettings
EXPORT canJoinMap
EXPORT checkTemp
EXPORT metaSprite_y
EXPORT metaSprite_x
EXPORT metaSprite_first_x

EXPORT curJoy0
EXPORT hero0_data
EXPORT hero0_index
EXPORT hero0_object
EXPORT hero0_bullet_index
EXPORT hero0_class
EXPORT hero0_enterLevelFacing
EXPORT hero0_enterLevelLocation
EXPORT hero0_i
EXPORT hero0_j
EXPORT hero0_type
EXPORT hero0_health
EXPORT hero0_moved
EXPORT hero0_puffCount

EXPORT curJoy1
EXPORT hero1_data
EXPORT hero1_index
EXPORT hero1_object
EXPORT hero1_bullet_index
EXPORT hero1_class
EXPORT hero1_enterLevelFacing
EXPORT hero1_enterLevelLocation
EXPORT hero1_i
EXPORT hero1_j
EXPORT hero1_type
EXPORT hero1_health
EXPORT hero1_moved
EXPORT hero1_puffCount

EXPORT levelVars

EXPORT linkBailOut

EXPORT musicEnabled
EXPORT musicOverride1
EXPORT musicOverride4
EXPORT musicBank
EXPORT musicNoteCountdownInit
EXPORT musicNoteCountdown
EXPORT musicTrack1Pos
EXPORT musicTrack2Pos
EXPORT musicTrack3Pos
EXPORT musicTrack4Pos
EXPORT musicInstrument1
EXPORT musicInstrument2
EXPORT musicInstrument3
EXPORT musicInstrument4
EXPORT musicWaveform
EXPORT musicStack
EXPORT curTrackStackL
EXPORT musicStackL1
EXPORT musicStackL2
EXPORT musicStackL3
EXPORT musicStackL4
EXPORT musicRegisters
EXPORT musicAddress

EXPORT numFreeObjects
EXPORT fgFlags
EXPORT lineZeroHorizontalOffset
EXPORT exitTileIndex

EXPORT hblankWinOn
EXPORT hblankWinOff
EXPORT hblankFlag

;gfx.asm
EXPORT LoadNextLevel
EXPORT temp
EXPORT drawMapTemp
EXPORT SpriteDMAHandler
EXPORT InitGfx
EXPORT DisplayOff
EXPORT VMemCopy
EXPORT MemSet
EXPORT MemCopy
EXPORT InitDMALoad
EXPORT WaitDMALoad
EXPORT DMALoad
EXPORT SetupCommonColor
EXPORT AddHL16
EXPORT AddDE16
EXPORT GenerateFacings
EXPORT LoadSprites
EXPORT LoadFont
EXPORT PrepareForInitialMapDraw
EXPORT DrawMapToBackBuffer
EXPORT DrawCinemaToBackBuffer
EXPORT AdjustCameraToHero
EXPORT GentleCameraAdjust
EXPORT RestrictCameraToBounds
EXPORT ScrollToCamera
EXPORT ScrollSpritesLeft
EXPORT ScrollSpritesRight
EXPORT ScrollSpritesUp
EXPORT ScrollSpritesDown
EXPORT GetRandomNumZeroToN
EXPORT GetRandomNumMask
EXPORT SetupFadeFromWhite
EXPORT SetupFadeFromStandard
EXPORT FadeCommonSetPaletteToWhite
EXPORT FadeCommonSetPaletteToBlack
EXPORT FadeCommonSetPaletteToBlackBGOnly
EXPORT SetupFadeToWhite
EXPORT SetupFadeToStandard
EXPORT SetupFadeFromBlack
EXPORT BlackoutPalette
EXPORT SetupFadeToBlack
EXPORT SetupFadeFromBlackBGOnly
EXPORT SetupFadeToBlackBGOnly
EXPORT SetupFadeFromSaturated
EXPORT SetupFadeToGamePalette
EXPORT SetupFadeToHalfbrite
EXPORT FadeCommonCopyPalette
EXPORT CopyPalette64
EXPORT CopyPalette32
EXPORT InstallGamePalette
EXPORT FadeInit
EXPORT FadeStep
EXPORT LighteningOut
EXPORT LighteningIn
EXPORT GetRedComponent
EXPORT GetGreenComponent
EXPORT GetBlueComponent
EXPORT SetRedComponent
EXPORT SetGreenComponent
EXPORT SetBlueComponent
EXPORT PlaySound
EXPORT PlaySoundChannel1
EXPORT PlaySoundChannel2
EXPORT PlaySoundChannel3
EXPORT PlaySoundChannel4

EXPORT WaitInput
EXPORT WaitInputZero
EXPORT WaitInputClick
EXPORT CreateBigExplosion
EXPORT BlitMap
EXPORT LCheckGetVectorToState
EXPORT SaveIdle
EXPORT RestoreIdle
EXPORT MakeIdle
EXPORT MakeNonIdle
EXPORT UseAlternatePalette
EXPORT UpdateDialogBalloons
EXPORT DisableDialogBalloons
EXPORT ResetFreeSprites
EXPORT UpdateEnvEffect
EXPORT SetEnvEffect

EXPORT CheckEachHero
EXPORT RemoveHero
EXPORT SetRespawnMap
EXPORT SetJoinMap
EXPORT SetLinkBailOutAddress
EXPORT SetHBlankHandler
EXPORT GetMethodAddrFromPointer
EXPORT CallBGAction

EXPORT ResetSprites

;cinema.asm
EXPORT LoadCinemaBG
EXPORT LoadCinemaSprite
EXPORT LoadCinemaTextBox
EXPORT CinemaBlitRect
EXPORT CinemaSpotAnimationRandomVerticalFrames
EXPORT CinemaSpotAnimationRandomHorizontalFrames
EXPORT StdWaitDialogNoClear
EXPORT StdWaitDialog

;cinema character animation routines
EXPORT AnimateSkippy
EXPORT AnimateFlour
EXPORT AnimateHaiku
EXPORT AnimateBRAINIAC
EXPORT AnimateLadyFlower
EXPORT AnimateFlourDriving
EXPORT AnimateBS
EXPORT AnimateBA
EXPORT AnimateLadyFlowerDistress
EXPORT AnimateCaptainGunpoint
EXPORT State0To1


;map.asm
EXPORT BGTiles1024
EXPORT LoadMap
EXPORT MapCoordsToIndex
EXPORT SetupMapVarsFromWidthPitchAndHeight
EXPORT ParseMap
EXPORT ClearBackBuffer
EXPORT SetBGSpecialFlags
EXPORT ResetMyBGSpecialFlags
EXPORT CallMapInit
EXPORT LoadAssociatedClass
EXPORT SaveFGTileInfo
EXPORT RestoreFGTileInfo
EXPORT PrepSetupHero
EXPORT PrepSetupHeroBC
EXPORT SetupHero
EXPORT FindExitLocation
EXPORT FindClassIndex
EXPORT ChangeClass
EXPORT ChangeFirstClass
EXPORT ChangeMyClass
EXPORT ChangeMyClassAndRedraw
EXPORT ChangeMyClassToAssociatedAndRedraw
EXPORT RemoveObjectFromList
EXPORT AddObjectToList
EXPORT CopyMapMethodToRAM
EXPORT HandleExitFromMap
EXPORT HasInventoryItem
EXPORT AddInventoryItem
EXPORT GetFirstInventoryIndex
EXPORT GetNextInventoryIndex
EXPORT RemoveInventoryItem
EXPORT GuestContinueSynchronization

EXPORT map
EXPORT zoneBuffer
EXPORT backBuffer
EXPORT attributeBuffer
EXPORT tileShadowBuffer
EXPORT attributeShadowBuffer
EXPORT gamePalette
EXPORT objBackBuffer
EXPORT objAttributeBuffer
EXPORT mapOffsetNorth
EXPORT mapOffsetEast
EXPORT mapOffsetSouth
EXPORT mapOffsetWest
EXPORT mapWidth
EXPORT mapPitch
EXPORT mapPitchMinusOne
EXPORT mapPitchMinusOneComplement
EXPORT mapSkip
EXPORT mapHeight
EXPORT numClasses
EXPORT firstHero
EXPORT numFGTiles
EXPORT fgDestPtr
EXPORT firstMonster
EXPORT mapColor
EXPORT mapLeft
EXPORT mapTop
EXPORT mapRight
EXPORT mapBottom
EXPORT mapRightPlusOne
EXPORT mapBottomPlusOne
EXPORT mapMaxLeft
EXPORT mapMaxTop
EXPORT camera_i;
EXPORT camera_j;
EXPORT distToWall_N
EXPORT distToWall_E
EXPORT distToWall_S
EXPORT distToWall_W

EXPORT curROMBank
EXPORT updateTimer
EXPORT curObjWidthHeight
EXPORT scrollSpeed

EXPORT gameState
EXPORT heroesAvailable
EXPORT heroesUsed
EXPORT heroesLocked
EXPORT appomattoxMapIndex
EXPORT respawnMap
EXPORT joinMap
EXPORT guardAlarm
EXPORT amLinkMaster
EXPORT lastLinkAction
EXPORT checkInputInMainLoop
EXPORT amShowingDialog
EXPORT gameStatePad

EXPORT desiredMapLeft
EXPORT desiredMapTop
EXPORT curPixelOffset_x
EXPORT curPixelOffset_y
EXPORT desiredPixelOffset_x
EXPORT desiredPixelOffset_y
EXPORT scrollAccelState_x
EXPORT scrollAccelState_y

EXPORT tempL,tempH
EXPORT delTempL,delTempH

EXPORT methodParamL
EXPORT methodParamH
EXPORT bulletDirection
EXPORT bulletLocation
EXPORT bulletColor
EXPORT bulletClassIndex
EXPORT bulletDamage

EXPORT inventory
EXPORT dialogNPC_speakerIndex
EXPORT dialogNPC_heroIndex
EXPORT dialogBalloonClassIndex
EXPORT envEffectType
EXPORT bsUpgrades
EXPORT baUpgrades
EXPORT haikuUpgrades

EXPORT mapBank
EXPORT mapContents
EXPORT mapState
EXPORT mapDialogClassIndex
EXPORT mapHeroZone

EXPORT dialogBank
EXPORT classLookup

EXPORT bgTileMap
EXPORT bgAttributes
EXPORT fgTileMap
EXPORT fgAttributes
EXPORT spritesUsed
EXPORT associatedIndex
EXPORT flightCode
EXPORT fadeCurPalette
EXPORT fadeFinalPalette
EXPORT fadeCurRGB
EXPORT fadeDelta
EXPORT fadeError
EXPORT fadeSteps
EXPORT fadeStepsToGo

EXPORT FOFTable
EXPORT wayPointList
EXPORT pathList
EXPORT pathMatrix
EXPORT levelState
EXPORT heroState

EXPORT rainbowColors
EXPORT horizontalOffset

EXPORT levelCheckRAM
levelCheckADDR EQU $c900
EXPORT spriteOAMBuffer

EXPORT ShowTitle
EXPORT SetSpeakerToFirstHero
EXPORT SetSpeakerFromHeroIndex
EXPORT SetPressBDialog
EXPORT CheckDialogContinue
EXPORT ShowDialogNPC
EXPORT ShowDialogHero
EXPORT ShowDialogAtTop
EXPORT ShowDialogAtTopNoWait
EXPORT ShowDialogAtTopCommon
EXPORT ShowDialogAtBottom
EXPORT ShowDialogAtBottomNoWait
EXPORT ShowDialogAtBottomCommon
EXPORT ShowDialogWait
EXPORT ClearGTXLine
EXPORT WriteGTXLine
EXPORT ClearDialog
EXPORT GfxBlitBackBufferToWindow
EXPORT GfxShowStandardTextBox
EXPORT CheckSkip
EXPORT Delay

;music.asm
EXPORT InitMusic
EXPORT PlayMusic
EXPORT StopMusic
EXPORT IsCurMusic

EXPORT beehive_gbm
EXPORT hoedown_gbm
EXPORT alarm_gbm
EXPORT intro_cinema_gbm
EXPORT bs_gbm
EXPORT lady_flower_gbm
EXPORT main_in_game_gbm
EXPORT haiku_gbm
EXPORT moon_base_ba_gbm
EXPORT moon_base_haiku_gbm
;EXPORT shroom_gbm
EXPORT cowboy_gbm
EXPORT frosty_gbm
EXPORT fgbwar_gbm
EXPORT wedding_gbm
EXPORT takeoff_gbm
EXPORT spaceish_gbm
EXPORT death_gbm
EXPORT jungle_gbm
EXPORT mysterious_gbm

EXPORT GetNumObjects

INCLUDE "Source/macro.inc"

