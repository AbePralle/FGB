; l0013.asm - first map, ba lands on the moon
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

DROPSPEED1 EQU $ff00   ;normal
DROPSPEED2 EQU $0001  

;DROPSPEED1 EQU $fc00   ;fast
;DROPSPEED2 EQU $0004  


;---------------------------------------------------------------------
SECTION "Level0013Section",ROMX
;---------------------------------------------------------------------

L0013_Contents::
  DW L0013_Load
  DW L0013_Init
  DW L0013_Check
  DW L0013_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0013_Load:
        DW ((L0013_LoadFinished - L0013_Load2))  ;size
L0013_Load2:
        call    ParseMap

        ;load in tiles used for sprite ships
        ;bg tiles 1153-1242 to Bank 0 100-189
        ldio    a,[curROMBank]
        push    af

        ld      a,BANK(BGTiles1024)
        call    SetActiveROM

        xor     a         ;bank 0
        ld      c,90      ;number of tiles to copy
        ld      de,$8000+1600
        ld      hl,BGTiles1024 + 129*16
        call    VMemCopy

        pop     af
        call    SetActiveROM
        ret

L0013_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0013_Map:
INCBIN "..\\fgbeditor\\l0013_intro_ba1.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
ORIGINALTILE EQU 0
VAR_HERO0_INDEX   EQU 1
VAR_HERO1_INDEX   EQU 2

HULKINDEX      EQU 73
GRUNTINDEX     EQU 74
B12PURPLEINDEX EQU 75
B12GREYINDEX   EQU 76
B12YELLOWINDEX EQU 77

STATE_INITIALDRAW      EQU 0
STATE_B12DROP_INIT     EQU 1
STATE_B12DROP          EQU 2
STATE_CROUTONDROP_INIT EQU 3
STATE_CROUTONDROP      EQU 4
STATE_NORMAL           EQU 5

L0013_Init:
        DW ((L0013_InitFinished - L0013_Init2))  ;size
L0013_Init2:
        ld      a,BANK(moon_base_ba_gbm)
        ld      hl,moon_base_ba_gbm
        call    InitMusic

        ld      hl,$0013
        call    SetJoinMap

        ld      hl,$0013
        call    SetRespawnMap

        ld      a,$13
        ld      [respawnMap],a
        ld      [joinMap],a
        ld      a,$00
        ld      [respawnMap+1],a
        ld      [joinMap+1],a

        ;get rid of existing monsters
        ld      a,HULKINDEX
        call    DeleteObjectsOfClassIndex
        ld      a,GRUNTINDEX
        call    DeleteObjectsOfClassIndex
        ld      a,B12PURPLEINDEX
        call    DeleteObjectsOfClassIndex
        ld      a,B12GREYINDEX
        call    DeleteObjectsOfClassIndex
        ld      a,B12YELLOWINDEX
        call    DeleteObjectsOfClassIndex

        ld      a,[bgTileMap+48]
        ld      [levelVars+ORIGINALTILE],a

        ld      bc,((GROUP_MONSTERB<<8) | GROUP_HERO)
        ld      a,1    ;make soldiers friends with hero
        call    SetFOF

        ldio    a,[mapState]
        cp      STATE_NORMAL
        jr      z,.afterRemoveHeroes

        cp      STATE_CROUTONDROP_INIT
        jr      z,.removeHeroes
        cp      STATE_CROUTONDROP
        jr      z,.removeHeroes
        xor     a
        ld      [canJoinMap],a

.removeHeroes
        ;remove heroes
        ld      a,[hero0_index]
        call    ((.heroInvisible - L0013_Init2) + levelCheckRAM)

        ld      a,[hero1_index]
        call    ((.heroInvisible - L0013_Init2) + levelCheckRAM)

        ld      a,1
        ld      [heroesIdle],a
.afterRemoveHeroes
        ret

.heroInvisible
        or      a
        ret     z
        ld      c,a
        call    GetFirst
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        ret


L0013_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
CROUTON_DROPY EQU 22

L0013_Check:
        DW ((L0013_CheckFinished - L0013_Check2))  ;size
L0013_Check2:
        ;animate the radar tower (index 48-53) based on timer/8
        ldio    a,[updateTimer]
        rrca                    ;(t/8)*6 == t/4*3
        and     %00000110
        ld      b,a
        add     b
        add     b
        ld      b,a
        ld      a,[levelVars+ORIGINALTILE]
        add     b

        ld      hl,bgTileMap + 48
        ld      c,6
.animateTower
        ld      [hl+],a
        inc     a
        dec     c
        jr      nz,.animateTower

        ldio    a,[mapState]
        cp      STATE_INITIALDRAW
        jr      nz,.checkB12DropInit

        ld      a,STATE_B12DROP_INIT
        ldio    [mapState],a
        ret

.checkB12DropInit
        cp      STATE_B12DROP_INIT
        jr      nz,.checkB12Drop

;ld a,STATE_NORMAL
;ldio [mapState],a
;ret
        ;----b12 drop init--------------------------------------------
        ;set up mask table
        call    ((.clearMask - L0013_Check2) + levelCheckRAM)
        call    ((.createB12Ship - L0013_Check2) + levelCheckRAM)
        call    ((.fadeOut - L0013_Check2) + levelCheckRAM)

        ld      a,STATE_B12DROP
        ldio    [mapState],a
        ret

.checkB12Drop
        cp      STATE_B12DROP
        jr      z,.inB12Drop
        jp      ((.checkCroutonDropInit-L0013_Check2)+levelCheckRAM)

.inB12Drop
        ;b12 dropship
        ld      bc,DROPSPEED1
        ld      hl,$cdc0
        call    ScrollMetaSprite

        call    ((.animateB12Thrusters - L0013_Check2) + levelCheckRAM)

        ;remove ship if nose sprite is 192
        ;get the x position of the first sprite on third row
        ld      a,[$cdc0 + 16 + 1]
        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)
        inc     hl
        ld      a,[hl]
        cp      192
        jr      nz,.afterRemoveShip

        ld      hl,$cdc0
        call    FreeMetaSprite
        ld      a,STATE_CROUTONDROP_INIT
        ldio    [mapState],a
        ld      hl,((.shipFadeSound - L0013_Check2) + levelCheckRAM)
        call    PlaySound
        call    ((.fadeIn - L0013_Check2) + levelCheckRAM)
        ld      a,30
        ldio    [mapState+1],a   ;delay until next ship
        ret

.afterRemoveShip
        ;drop soldiers when ship is at specific pixel positions
        cp      48
        jr      nz,.checkSoldierDrop2

        ld      c,B12YELLOWINDEX
        ld      hl,$d0ca
        push    hl
        ld      hl,$d0ea
        push    hl
        ld      hl,$d10a
        push    hl
        jp      ((.createSoldiers - L0013_Check2) + levelCheckRAM)
        
.checkSoldierDrop2
        cp      40
        jr      nz,.checkSoldierDrop3

        ld      c,B12YELLOWINDEX
        ld      hl,$d0c9
        push    hl
        ld      hl,$d0e9
        push    hl
        ld      hl,$d109
        push    hl
        jp      ((.createSoldiers - L0013_Check2) + levelCheckRAM)
        
.checkSoldierDrop3
        cp      32
        jr      nz,.checkSoldierDrop4

        ld      c,B12PURPLEINDEX
        ld      hl,$d0c8
        push    hl
        ld      hl,$d0e8
        push    hl
        ld      hl,$d108
        push    hl
        jp      ((.createSoldiers - L0013_Check2) + levelCheckRAM)
        
.checkSoldierDrop4
        cp      24
        jr      nz,.checkSoldierDrop5

        ld      c,B12PURPLEINDEX
        ld      hl,$d0c7
        push    hl
        ld      hl,$d0e7
        push    hl
        ld      hl,$d107
        push    hl
        jp      ((.createSoldiers - L0013_Check2) + levelCheckRAM)

.checkSoldierDrop5
        cp      16
        jr      nz,.checkSoldierDrop6

        ;make heroes visible
        ld      a,[hero0_index]
        call    ((.heroVisible - L0013_Check2) + levelCheckRAM)

        ld      a,[hero1_index]
        call    ((.heroVisible - L0013_Check2) + levelCheckRAM)

        ret

.heroVisible
        or      a
        ret     z
        ld      c,a
        call    GetFirst
        ld      b,METHOD_DRAW
        call    CallMethod
        ret

        ;ld      c,B12PURPLEINDEX
        ;ld      hl,$d0c6
        ;push    hl
        ;ld      hl,$d0e6
        ;push    hl
        ;ld      hl,$d106
        ;push    hl
        ;jp      ((.createSoldiers - L0013_Check2) + levelCheckRAM)

.checkSoldierDrop6
        ret

.checkCroutonDropInit
        cp      STATE_CROUTONDROP_INIT
        jr      nz,.checkCroutonDrop

        ;crouton drop init

        ld      hl,mapState+1
        ld      a,[hl]
        or      a
        jr      z,.afterDelay

        dec     [hl]
        ret

.afterDelay
        ;set up mask table
        call    ((.clearMask - L0013_Check2) + levelCheckRAM)
        call    ((.createCroutonShip - L0013_Check2)+levelCheckRAM)

        ld      hl,((.croutonShipApproachSound - L0013_Check2) + levelCheckRAM)
        call    PlaySound
        call    ((.fadeOut - L0013_Check2) + levelCheckRAM)

        ld      a,STATE_CROUTONDROP
        ldio    [mapState],a
        ret

.checkCroutonDrop
        cp      STATE_CROUTONDROP
        jr      z,.inCroutonDrop

        ld      a,1               ;can join now
        ld      [canJoinMap],a

        jp      ((.checkNormal - L0013_Check2)+levelCheckRAM)

.inCroutonDrop
        ;crouton dropship
        ld      bc,DROPSPEED2
        ld      hl,$cdc0
        call    ScrollMetaSprite

        call    ((.animateCroutonThrusters-L0013_Check2)+levelCheckRAM)

        ;remove ship if top sprite is 161
        ;get the y position of the first sprite
        ld      a,[$cdc0 + 1]
        ld      l,a
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      a,[hl]
        cp      162
        jr      nz,.afterRemoveCroutonShip

        ld      hl,$cdc0
        call    FreeMetaSprite
        ld      a,STATE_NORMAL
        ldio    [mapState],a
        ld      hl,((.croutonShipFadeSound - L0013_Check2) + levelCheckRAM)
        call    PlaySound
        call    ((.fadeIn - L0013_Check2) + levelCheckRAM)
        ld      hl,musicEnabled  ;enable track 4
        set     3,[hl]

        ;everybody start fighting
        ld      bc,classDoNothing
        ld      de,classB12Soldier
        call    ChangeClass

        ld      bc,classDoNothing2
        ld      de,classCroutonGrunt
        call    ChangeClass

        ld      bc,classDoNothing3
        ld      de,classCroutonHulk
        call    ChangeClass

        ;let the heroes move 
        xor     a
        ld      [heroesIdle],a

        ld      a,STATE_NORMAL
        ldio    [mapState],a
        ret

.afterRemoveCroutonShip
        ;place croutons under ship based on y position
        cp      CROUTON_DROPY
        jr      nz,.placeCroutons2

        ld      hl,$d06e
        jp      ((.placeCroutonSingleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons2
        cp      CROUTON_DROPY + 8*1
        jr      nz,.placeCroutons3

        ld      hl,$d08e
        jp      ((.placeCroutonSingleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons3
        cp      CROUTON_DROPY + 8*2
        jr      nz,.placeCroutons4

        ld      hl,$d0ae
        jp      ((.placeCroutonDoubleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons4
        cp      CROUTON_DROPY + 8*4
        jr      nz,.placeCroutons5

        ld      hl,$d0ee
        jp      ((.placeCroutonSingleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons5
        cp      CROUTON_DROPY + 8*5
        jr      nz,.placeCroutons6

        ld      hl,$d10e
        jp      ((.placeCroutonDoubleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons6
        cp      CROUTON_DROPY + 8*7
        jr      nz,.placeCroutons7

        ld      hl,$d14e
        jp      ((.placeCroutonSingleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons7
        cp      CROUTON_DROPY + 8*8
        jr      nz,.placeCroutons8

        ld      hl,$d16e
        jp      ((.placeCroutonDoubleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons8
        cp      CROUTON_DROPY + 8*10
        jr      nz,.placeCroutons9

        ld      hl,$d1ae
        jp      ((.placeCroutonSingleRow-L0013_Check2)+levelCheckRAM)

.placeCroutons9
        cp      CROUTON_DROPY + 8*11
        ret     nz

        ld      hl,$d1ce
        jp      ((.placeCroutonSingleRow-L0013_Check2)+levelCheckRAM)

.checkNormal
        ret

.createSoldiers
        push    bc
        ld      bc,classDoNothing
        ld      de,classB12Soldier
        call    ChangeClass
        pop     bc
        ld      b,3
.createSoldiersLoop
        pop     hl
        push    bc
        call    CreateObject
        ld      b,METHOD_INIT
        call    CallMethod
        ld      a,DIR_EAST
        call    SetFacing
        ld      b,METHOD_DRAW
        call    CallMethod
        pop     bc
        dec     b
        jr      nz,.createSoldiersLoop
        ld      bc,classB12Soldier
        ld      de,classDoNothing
        call    ChangeClass
        ret

.clearMask
        ld      hl,$cdc0
        ld      c,49
        ld      a,1
.clearMaskLoop
        ld      [hl+],a
        dec     c
        jr      nz,.clearMaskLoop
        ret

.createB12Ship
        ;clear spots in the mask
        xor     a
        ld      [$cdc0 + 0 + 1],a
        ld      [$cdc0 + 1 + 1],a
        ld      [$cdc0 + 7 + 1],a
        ld      [$cdc0 + 1*8+0 + 1],a
        ld      [$cdc0 + 1*8+7 + 1],a
        ld      [$cdc0 + 4*8+0 + 1],a
        ld      [$cdc0 + 4*8+7 + 1],a
        ld      [$cdc0 + 5*8+0 + 1],a
        ld      [$cdc0 + 5*8+1 + 1],a
        ld      [$cdc0 + 5*8+7 + 1],a

        ld      a,192  ;190
        ld      [metaSprite_x],a
        ld      a,44
        ld      [metaSprite_y],a

        ld      bc,$0806         ;width and height of metasprite
        ld      d,100            ;starts at pattern #100
        ld      e,5              ;default attributes (palette)
        ld      hl,$cdc0
        call    CreateMetaSpriteUsingMask

        ld      hl,musicEnabled  ;disable track 4
        res     3,[hl]
        ld      hl,((.shipApproachSound - L0013_Check2) + levelCheckRAM)
        call    PlaySound
        ret

.animateB12Thrusters
        ;animate thrusters by setting or clearing +128 to each
        ;thruster sprite's y position
        ld      hl,$cdc0 + 6 + 1
        push    hl
        ld      hl,$cdc0 + 8 + 6 + 1
        push    hl
        ld      hl,$cdc0 + 8*4 + 6 + 1
        push    hl
        ld      hl,$cdc0 + 8*5 + 6 + 1
        push    hl

        ld      b,0
        ld      a,[updateTimer]
        bit     0,a
        jr      nz,.afterSetMask
        ld      b,%10000000
.afterSetMask
        ld      c,4
.thrusterChangeLoop
        pop     hl
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      a,[hl]
        and     %01111111
        or      b
        ld      [hl],a
        dec     c
        jr      nz,.thrusterChangeLoop
        ret
         
.createCroutonShip
        ;clear spots in the mask
        xor     a
        ld      [$cdc0 + 5*6+1 + 1],a
        ld      [$cdc0 + 5*6+4 + 1],a
        ld      [$cdc0 + 6*6+1 + 1],a
        ld      [$cdc0 + 6*6+2 + 1],a
        ld      [$cdc0 + 6*6+3 + 1],a
        ld      [$cdc0 + 6*6+4 + 1],a

        ld      a,104
        ld      [metaSprite_x],a
        ld      a,166
        ld      [metaSprite_y],a

        ld      bc,$0607         ;width and height of metasprite
        ld      d,$94            ;initial pattern number
        ld      e,6              ;default attributes (palette)
        ld      hl,$cdc0
        call    CreateMetaSpriteUsingMask
        ret

.animateCroutonThrusters
        ;animate thrusters by setting or clearing +128 to each
        ;thruster sprite's y position
        ld      hl,$cdc0 + 1
        push    hl
        ld      hl,$cdc0 + 5 + 1
        push    hl

        ld      b,0
        ld      a,[updateTimer]
        bit     0,a
        jr      nz,.afterSetCroutonMask
        ld      b,80
.afterSetCroutonMask
        ld      c,2
.croutonThrusterChangeLoop
        pop     hl
        ld      l,[hl]
        ld      h,((spriteOAMBuffer>>8) & $ff)
        inc     hl      ;to sprite x pos
        ld      a,[hl]
        cp      160
        jr      c,.xposOriginal
        sub     80
.xposOriginal
        add     b
        ld      [hl],a
        dec     c
        jr      nz,.croutonThrusterChangeLoop
        ret

.placeCroutonSingleRow
        ld      b,2
        ld      c,GRUNTINDEX
        push    hl
        inc     hl
        push    hl
        jr      .createCroutons

.placeCroutonDoubleRow
        push    hl
        ld      bc,((.drowRetAddr-L0013_Check2)+levelCheckRAM)
        push    bc 
        jr      .placeCroutonSingleRow
.drowRetAddr
        pop     hl
        push    hl
        ld      bc,32
        add     hl,bc
        ld      bc,((.drowRetAddr2-L0013_Check2)+levelCheckRAM)
        push    bc 
        jr      .placeCroutonSingleRow
.drowRetAddr2
        pop     hl

        ld      bc,((.afterCreateHulk-L0013_Check2)+levelCheckRAM)
        push    bc
        inc     hl
        inc     hl
        push    hl

        ld      bc,classDoNothing3
        ld      de,classCroutonHulk
        call    ChangeClass

        ld      b,1
        ld      c,HULKINDEX
        jr      .createCroutons
.afterCreateHulk
        ld      bc,classCroutonHulk
        ld      de,classDoNothing3
        call    ChangeClass
        ret

.createCroutons
        push    bc
        ld      bc,classDoNothing2
        ld      de,classCroutonGrunt
        call    ChangeClass
        pop     bc
        pop     hl
        push    bc
        call    CreateObject
        ld      b,METHOD_INIT
        call    CallMethod
        ld      a,DIR_WEST
        call    SetFacing
        ld      b,METHOD_DRAW
        call    CallMethod
        pop     bc
        dec     b
        jr      nz,.createCroutons
        ld      bc,classCroutonGrunt
        ld      de,classDoNothing2
        call    ChangeClass
        ret

.fadeOut
        ld      a,FADEBANK
        ld      [$ff70],a

        ;set final bg palette to be all white w/black bg
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ld      hl,fadeFinalPalette
        call    ((.setPaletteToWhiteBlackBG-L0013_Check2)+levelCheckRAM)

        ;set cur palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette

        ld      a,120
        call    FadeInit
        ret

.fadeIn
        ld      a,FADEBANK
        ld      [$ff70],a

        ;set cur palette to be all white w black bg
        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    FadeCommonCopyPalette
        ld      hl,fadeCurPalette
        call    ((.setPaletteToWhiteBlackBG-L0013_Check2)+levelCheckRAM)

        ;set final palette to be copy of current game palette
        ld      hl,gamePalette
        ld      de,fadeFinalPalette
        call    FadeCommonCopyPalette

        ld      a,30
        call    FadeInit
        ret

.setPaletteToWhiteBlackBG
        ld      c,8
.setBlackLoop
        ld      a,$ff
        ld      [hl+],a
        ld      a,$7f
        ld      [hl+],a
        ld      b,3
.setWhiteLoop
        ld      a,$b5
        ld      [hl+],a
        ld      a,$56
        ld      [hl+],a
        dec     b
        jr      nz,.setWhiteLoop
        dec     c
        jr      nz,.setBlackLoop
        ret

.shipApproachSound
        DB      4,$00,$0f,$81,$80
.shipFadeSound
        DB      4,$00,$f7,$81,$80
.croutonShipApproachSound
        DB      4,$00,$0f,$82,$80
.croutonShipFadeSound
        DB      4,$00,$f7,$82,$80

L0013_CheckFinished:
PRINTT "0013 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0013_LoadFinished - L0013_Load2)
PRINTT " / "
PRINTV (L0013_InitFinished - L0013_Init2)
PRINTT " / "
PRINTV (L0013_CheckFinished - L0013_Check2)
PRINTT "\n"

