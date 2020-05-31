; l0014.asm
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level0014Section",ROMX
;---------------------------------------------------------------------

L0014_Contents::
  DW L0014_Load
  DW L0014_Init
  DW L0014_Check
  DW L0014_Map

dialog:
haiku_warn_gtx:
  INCBIN "gtx\\intro_haiku\\haiku_warn.gtx"
haiku_askOkay_gtx:
  INCBIN "gtx\\intro_haiku\\haiku_askOkay.gtx"
quatrain_gtx:
  INCBIN "gtx\\intro_haiku\\quatrain.gtx"
haiku_goAhead_gtx:
  INCBIN "gtx\\intro_haiku\\haiku_goAhead.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0014_Load:
        DW ((L0014_LoadFinished - L0014_Load2))  ;size
L0014_Load2:
        call    ParseMap

        ;load in tiles used for sprite ship
        ;bg tiles 1386-1389 to Bank 0 100-103
        ldio    a,[curROMBank]
        push    af
        ld      a,BANK(BGTiles1024)
        call    SetActiveROM

        xor     a         ;bank 0
        ld      c,4       ;number of tiles to copy
        ld      de,$8000+1600
        ld      hl,BGTiles1024 + (1386-1024)*16
        call    VMemCopy
        pop     af
        call    SetActiveROM
        ret

L0014_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0014_Map:
INCBIN "..\\fgbeditor\\l0014_intro_haiku1.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
CRATERINDEX   EQU  3
RADARINDEX    EQU 50
CRACKMIDINDEX EQU 81
CRACKTOPINDEX EQU 82
QUATRAININDEX EQU 107
SOLDIERINDEX  EQU 108
IAMBICINDEX   EQU 109
LAVAINDEX EQU 74

VAR_RADAR        EQU 0
VAR_CRACK_TOP    EQU 1
VAR_CRACK_BOTTOM EQU 2
VAR_DELAY        EQU 3
VAR_LAVA         EQU 4
VAR_METASPRITE   EQU 5  ;5-9

STATE_CROSSCRACK     EQU 0
STATE_BOMBER1        EQU 2
STATE_BOMBER2        EQU 3
STATE_LAVA           EQU 4
STATE_LAVA2          EQU 5
STATE_LAVA3          EQU 6
STATE_DIALOG2_1      EQU 7
STATE_DIALOG2_2      EQU 8
STATE_DIALOG2_3      EQU 9
STATE_DIALOG_WAIT    EQU 10
STATE_NORMAL         EQU 11


L0014_Init:
        DW ((L0014_InitFinished - L0014_Init2))  ;size
L0014_Init2:
;ld a,STATE_NORMAL
;ldio [mapState],a

        ld      hl,$0014
        call    SetJoinMap

        ld      hl,$0014
        call    SetRespawnMap

        call    SetPressBDialog
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,BANK(moon_base_haiku_gbm)
        ld      hl,moon_base_haiku_gbm
        call    InitMusic

        ld      a,[bgTileMap+RADARINDEX]
        ld      [levelVars+VAR_RADAR],a

        ld      a,[bgTileMap+LAVAINDEX]
        ld      [levelVars+VAR_LAVA],a

        ;----soldiers do nothing
        ld      bc,classB12Soldier
        ld      de,classDoNothing
        call    ChangeClass

        ;fill in hole at $d190, $d191 if not occupied
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d190
        ld      a,[hl]
        or      a
        jr      nz,.firstFilled
        ld      [hl],45
.firstFilled
        inc     hl
        ld      a,[hl]
        or      a
        jr      nz,.secondFilled
        ld      [hl],46
.secondFilled

        ld      a,10
        ld      [camera_i],a
        ld      [camera_j],a
        ld      a,1
        ld      [mapLeft],a
        ld      a,1
        ld      [mapTop],a

        ld      a,10
        ld      [levelVars + VAR_CRACK_TOP],a
        inc     a
        ld      [levelVars + VAR_CRACK_BOTTOM],a

        ldio    a,[mapState]
        cp      STATE_CROSSCRACK
        jr      nz,.checkBomber1

        ld      a,1
        ld      [heroesIdle],a
        call    ((.createCompanions-L0014_Init2)+levelCheckRAM)
        jr      .createBomber1

.checkBomber1
        cp      STATE_BOMBER1
        jr      nz,.checkBomber2

        ld      a,1
        ld      [heroesIdle],a

.createBomber1
        ld      bc,$0202
        ld      d,100
        ld      e,6
        ld      hl,levelVars+VAR_METASPRITE
        ld      a,220
        ld      [metaSprite_x],a
        ld      a,52
        ld      [metaSprite_y],a
        call    CreateMetaSprite
        ret

.checkBomber2
        cp      STATE_BOMBER2
        jr      nz,.checkLava1

        ld      a,1
        ld      [heroesIdle],a
        call    ((.createCompanions-L0014_Init2)+levelCheckRAM)
        ld      bc,$0202
        ld      d,100
        ld      e,6
        ld      hl,levelVars+VAR_METASPRITE
        ld      a,220
        ld      [metaSprite_x],a
        ld      a,88
        ld      [metaSprite_y],a
        call    CreateMetaSprite
        ret

.checkLava1
        ;cp      STATE_LAVA1
        ;jr      nz,.checkLava2

.checkLava2
        ;cp      STATE_LAVA2
        ;jr      nz,.checkLava3

.checkLava3
        ;cp      STATE_LAVA3
        cp      STATE_NORMAL
        jr      z,.checkNormal

        ld      a,1
        ld      [heroesIdle],a

.checkNormal
        ld      a,STATE_NORMAL
        ldio    [mapState],a    ;be sure

        ld      bc,$1614
        ld      de,0
        ld      hl,$2c00
        call    BlitMap
        call    SetBGSpecialFlags
        ret

.createCompanions
        ld      c,QUATRAININDEX
        ld      hl,$d48d
        call    CreateInitAndDrawObject
        ld      hl,$d306
        call    SetActorDestLoc
        ld      c,IAMBICINDEX
        ld      hl,$d50d
        call    CreateInitAndDrawObject
        ld      hl,$d387
        call    SetActorDestLoc
        ld      bc,classQuatrain
        ld      de,classActor
        call    ChangeClass
        ret

L0014_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0014_Check:
        DW ((L0014_CheckFinished - L0014_Check2))  ;size
L0014_Check2:

        ;if any soldiers are killed change them to class B12 Soldier
        ld      c,SOLDIERINDEX
        call    GetFirst
        or      a
        jr      z,.animateRadar

        call    GetNextObject
        or      a
        jr      nz,.animateRadar

.soldierDefend
        ld      bc,classDoNothing
        ld      de,classB12Soldier
        call    ChangeClass

        ld      bc,(GROUP_HERO<<8) | GROUP_MONSTERB
        xor     a ;enemies
        call    SetFOF

.animateRadar
        ;animate the radar tower (index 47-52) based on timer/8
        ldio    a,[updateTimer]
        rrca                    ;(t/8)*6 == t/4*3
        and     %00000110
        ld      b,a
        add     b
        add     b
        ld      b,a
        ld      a,[levelVars+VAR_RADAR]
        add     b

        ld      hl,bgTileMap + RADARINDEX
        ld      c,6
.animateTower
        ld      [hl+],a
        inc     a
        dec     c
        jr      nz,.animateTower

        ;animate the lava on updateTimer / 16
        ldio    a,[updateTimer]
        rlca
        swap    a
        and     %00000011
        ld      b,a
        ld      a,[levelVars+VAR_LAVA]
        add     b
        ld      [bgTileMap + LAVAINDEX],a

        ldio    a,[mapState]
        cp      STATE_NORMAL
        jr      nz,.checkDialogWait

        ;normal
        xor     a
        ld      [heroesIdle],a

        ret

.checkDialogWait
        cp      STATE_DIALOG_WAIT
        jr      nz,.checkCrossCrack

        call    CheckDialogContinue
        or      a
        ret     z

        ldio    a,[mapState+1]
        ldio    [mapState],a
        ret

.checkCrossCrack
        cp      STATE_CROSSCRACK
        jr      nz,.checkBomber1

        ld      c,QUATRAININDEX
        call    GetFirst
        call    IsActorAtDest
        or      a
        ret     z

        ld      c,IAMBICINDEX
        call    GetFirst
        call    IsActorAtDest
        or      a
        ret     z

        ld      de,((.setBomber1-L0014_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        ld      de,haiku_warn_gtx
        call    ShowDialogAtBottomNoWait

        ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a
        ld      a,STATE_BOMBER1
        ldio    [mapState+1],a
        ret

.checkDialog2
        cp      STATE_DIALOG2_1
        jr      nz,.checkBomber1

        ret

.setBomber1
        call    ClearDialog
        ld      a,STATE_BOMBER1
        ldio    [mapState],a

.checkBomber1
        cp      STATE_BOMBER1
        jr      nz,.checkBomber2

        ld      de,0
        call    SetDialogSkip

        ;bomber1
        ld      hl,levelVars+VAR_METASPRITE   ;bomber metasprite
        ld      bc,$fc00   ;x -= 4
        call    ScrollMetaSprite

        ld      a,[levelVars+VAR_METASPRITE+1]  ;get x pos of first sprite
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      l,a
        inc     hl
        ld      a,[hl]
        cp      224
        jr      nz,.bomber1StillActive

        ;reset bomber to second fly-by position
        ld      bc,$dc58
        ld      hl,levelVars+VAR_METASPRITE
        call    SetMetaSpritePos
        ld      a,STATE_BOMBER2
        ldio    [mapState],a

.bomber1StillActive
        cp      188
        jr      nz,.afterBombSound1

        ld      hl,((.bombSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound
.afterBombSound1

        cp      88
        jr      nz,.b1CheckPos2

        ld      a,20
        ld      b,8
        call    SetupFadeFromSaturated
        call    ((.explosion1 - L0014_Check2) + levelCheckRAM)

        ;create a 2x2 crater
        ld      a,MAPBANK
        ldio    [$ff70],a

        ld      hl,$d30d
        ld      a,CRATERINDEX
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        ld      hl,$d38d
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ret

.b1CheckPos2
        cp      64
        ret     nz
        call    ((.explosion1 - L0014_Check2) + levelCheckRAM)
        ld      c,QUATRAININDEX
        call    GetFirst
        ld      hl,$d586
        call    SetActorDestLoc
        ld      c,IAMBICINDEX
        call    GetFirst
        ld      hl,$d607
        call    SetActorDestLoc
        ret


.checkBomber2
        cp      STATE_BOMBER2
        jr      nz,.checkLava

        ;bomber2
        ld      hl,levelVars+VAR_METASPRITE   ;bomber metasprite
        ld      bc,$fc00   ;x -= 4
        call    ScrollMetaSprite

        ld      a,[levelVars+VAR_METASPRITE+1]  ;get x pos of first sprite
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      l,a
        inc     hl
        ld      a,[hl]
        cp      224
        jr      nz,.bomber2StillActive

        ;kill bomber
        ld      hl,levelVars+VAR_METASPRITE
        call    FreeMetaSprite
      
        ld      c,QUATRAININDEX
        call    GetFirst
        ld      hl,$d888   ;run in circles
        call    SetActorDestLoc
        ld      c,IAMBICINDEX
        call    GetFirst
        ld      hl,$d888
        call    SetActorDestLoc

        ld      a,STATE_LAVA
        ldio    [mapState],a

.bomber2StillActive
        cp      144
        jr      nz,.afterBombSound2
        ld      hl,((.bombSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound
.afterBombSound2

        cp      44
        jr      nz,.checkPos20

        ld      a,20
        ld      b,8
        call    SetupFadeFromSaturated
        call    ((.explosion2 - L0014_Check2) + levelCheckRAM)
        call    ((.drawCrack1 - L0014_Check2) + levelCheckRAM)
        ret

.checkPos20
        cp      20
        ret     nz
        call    ((.explosion2 - L0014_Check2) + levelCheckRAM)
        ld      c,QUATRAININDEX
        call    GetFirst
        ld      hl,$d306
        call    SetActorDestLoc
        ld      c,IAMBICINDEX
        call    GetFirst
        ld      hl,$d387
        call    SetActorDestLoc
        ret

.checkLava
        cp      STATE_LAVA
        jr      nz,.checkLava2

        ;extend crack to top and bottom
        ld      hl,levelVars + VAR_DELAY
        dec     [hl]
        ret     nz

        ld      a,[updateTimer]
        and     %1000
        jr      nz,.afterQuakeSound1
        ld      hl,((.earthquakeSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound
.afterQuakeSound1

        ld      a,[levelVars + VAR_CRACK_TOP]
        or      a
        jr      nz,.crackNotDone

        ld      a,[levelVars + VAR_CRACK_BOTTOM]
        cp      19
        jr      nz,.crackNotDone

        ld      a,30
        ld      [levelVars + VAR_DELAY],a

        ld      a,STATE_LAVA2  ;crack has extended
        ldio    [mapState],a
        ret

.crackNotDone
        ld      a,[levelVars + VAR_CRACK_TOP]
        or      a
        jr      z,.afterCheckTop

        dec     a
        ld      [levelVars + VAR_CRACK_TOP],a

.afterCheckTop
        ld      a,[levelVars + VAR_CRACK_BOTTOM]
        cp      19
        jr      z,.afterCheckBottom

        inc     a
        ld      [levelVars + VAR_CRACK_BOTTOM],a

.afterCheckBottom
        call    ((.drawCrack1 - L0014_Check2) + levelCheckRAM)
        ret

.checkLava2
        cp      STATE_LAVA2
        jr      nz,.checkLava3

        ld      a,10
        ldio    [jiggleDuration],a

        ld      a,[updateTimer]
        and     %1000
        jr      nz,.afterQuakeSound2
        ld      hl,((.earthquakeSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound
.afterQuakeSound2

        ld      hl,levelVars + VAR_DELAY
        dec     [hl]
        ret     nz

        ;blit the second stage of lava to the screen
        call    ((.scootObjects - L0014_Check2) + levelCheckRAM)
        ld      bc,$1614
        ld      de,0
        ld      hl,$1600
        call    BlitMap
        call    SetBGSpecialFlags

        ld      a,30
        ld      [levelVars + VAR_DELAY],a

        ld      a,STATE_LAVA3
        ldio    [mapState],a

        ret

.checkLava3
        cp      STATE_LAVA3
        jr      nz,.checkDialog2_1

        ld      a,10
        ldio    [jiggleDuration],a

        ld      a,[updateTimer]
        and     %1000
        jr      nz,.afterQuakeSound3
        ld      hl,((.earthquakeSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound
.afterQuakeSound3

        ld      hl,levelVars + VAR_DELAY
        dec     [hl]
        ret     nz

        ;blit the third stage of lava to the screen
        call    ((.scootObjects - L0014_Check2) + levelCheckRAM)
        ld      bc,$1614
        ld      de,0
        ld      hl,$2c00
        call    BlitMap
        call    SetBGSpecialFlags

        ld      c,QUATRAININDEX
        call    GetFirst
        ld      hl,$d403
        call    SetActorDestLoc
        ld      c,IAMBICINDEX
        call    GetFirst
        ld      hl,$d502
        call    SetActorDestLoc

        ld      a,30
        ld      [levelVars + VAR_DELAY],a

        ld      a,STATE_DIALOG2_1
        ldio    [mapState],a

        ret

.checkDialog2_1
        cp      STATE_DIALOG2_1
        jr      nz,.checkDialog2_2

        ld      de,((.setNormal-L0014_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        ld      de,haiku_askOkay_gtx
        call    ShowDialogAtBottomNoWait

        ld      a,STATE_DIALOG2_2
        ldio    [mapState+1],a
        ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a
        ret

.checkDialog2_2
        cp      STATE_DIALOG2_2
        jr      nz,.checkDialog2_3

        call    SetSpeakerToFirstHero
        ld      de,quatrain_gtx
        ld      c,QUATRAININDEX
        call    ShowDialogAtTopNoWait

        ld      a,STATE_DIALOG2_3
        ldio    [mapState+1],a
        ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a
        ret

.checkDialog2_3
        call    SetSpeakerToFirstHero
        ld      de,haiku_goAhead_gtx
        call    ShowDialogAtBottomNoWait

        ld      a,STATE_NORMAL
        ldio    [mapState+1],a
        ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a
        ret

.setNormal
        call    ClearDialog
        ld      a,STATE_NORMAL
        ldio    [mapState],a
        ret

.explosion1
        ;drop the bomb
        ld      bc,$0404
        ld      de,$0a01
        ld      hl,$d28c
        call    CreateBigExplosion
        ld      hl,((.bigExplosionSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound

        ld      a,10
        ldio    [jiggleDuration],a
        ret

.explosion2
        ;drop the bomb
        ld      bc,$0404
        ld      de,$0a01
        ld      hl,$d488
        call    CreateBigExplosion
        ld      hl,((.bigExplosionSound-L0014_Check2)+levelCheckRAM)
        call    PlaySound

        ld      a,10
        ldio    [jiggleDuration],a
        ret

.drawCrack1
        call    ((.drawCrackTop - L0014_Check2) + levelCheckRAM)
        call    ((.drawCrackMid1 - L0014_Check2) + levelCheckRAM)
        call    ((.drawCrackBottom - L0014_Check2) + levelCheckRAM)
        ld      a,3
        ld      [levelVars + VAR_DELAY],a
        ld      a,6
        ldio    [jiggleDuration],a
        ret

.drawCrackTop
        ld      h,9    ;x coord
        ld      a,[levelVars + VAR_CRACK_TOP]
        ld      l,a
        call    ConvertXYToLocHL

        ld      a,MAPBANK
        ldio    [$ff70],a

        ld      a,CRACKTOPINDEX
        ld      [hl+],a
        inc     a
        ld      [hl],a
        ret

.drawCrackMid1
        ld      h,9    ;x coord
        ld      a,[levelVars + VAR_CRACK_TOP]
        ld      l,a
        ld      c,a
        inc     l
        call    ConvertXYToLocHL

        ld      a,[levelVars + VAR_CRACK_BOTTOM]
        sub     c
        ret     z
        dec     a
        ret     z
        ld      c,a         ;c is (bottom_y - top_y) - 1 (is >= 0)

        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      de,128      ;level pitch

.drawMid1Loop
        ld      a,CRACKMIDINDEX 
        ld      [hl+],a
        dec     a
        ld      [hl-],a
        add     hl,de
        dec     c
        jr      nz,.drawMid1Loop
        ret

.drawCrackBottom
        ld      h,9    ;x coord
        ld      a,[levelVars + VAR_CRACK_BOTTOM]
        ld      l,a
        call    ConvertXYToLocHL

        ld      a,MAPBANK
        ldio    [$ff70],a

        ld      a,CRACKTOPINDEX + 2
        ld      [hl+],a
        inc     a
        ld      [hl],a
        ret

.scootObjects
        ;scoots everyone < half left, >half right
        ;loop through 255 objects
        ld      a,OBJLISTBANK
        ldio    [$ff70],a
        ld      b,((objExists>>8) & $ff)
        ld      c,1
.scootLoop
        ld      a,[bc]
        or      a
        jr      z,.nextObj

        ld      a,c
        push    bc
        call    IndexToPointerDE
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        call    GetCurLocation
        call    ConvertLocHLToXY
        ld      a,h    ;x coord
        cp      9      ;< half?
        jr      nc,.greaterThanHalf
        dec     h
        jr      .setNewLoc
.greaterThanHalf
        inc     h
.setNewLoc
        call    ConvertXYToLocHL
        call    SetCurLocation
        call    GetClass
        ld      b,METHOD_DRAW
        call    CallMethod

        ld      a,OBJLISTBANK
        ldio    [$ff70],a
        pop     bc
.nextObj
        inc     c
        jr      nz,.scootLoop
        ret

.bombSound
  DB 1,$1f,$80,$f5,$80,$86

.bigExplosionSound
  DB 4,$00,$f3,$81,$80

.earthquakeSound
  DB 4,$00,$f7,$67,$80


L0014_CheckFinished:
PRINTT "0014 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0014_LoadFinished - L0014_Load2)
PRINTT " / "
PRINTV (L0014_InitFinished - L0014_Init2)
PRINTT " / "
PRINTV (L0014_CheckFinished - L0014_Check2)
PRINTT "\n"

