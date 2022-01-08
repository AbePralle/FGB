; L1300.asm appomattox interior
; Generated 02.16.2001 by mlevel
; Modified  02.16.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Start.inc"

DICEINDEX     EQU 6
GRENADE_INDEX EQU 170
BAINDEX       EQU 173
BSINDEX       EQU 174
HAIKUINDEX    EQU 175

VAR_DICELIGHT     EQU 0
VAR_HEROESUSED EQU 1
VAR_BA            EQU 2
VAR_BS            EQU 3
VAR_HAIKU         EQU 4


;---------------------------------------------------------------------
SECTION "Level1300Section",ROMX
;---------------------------------------------------------------------

L1300_Contents::
  DW L1300_Load
  DW L1300_Init
  DW L1300_Check
  DW L1300_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1300_Load:
        DW ((L1300_LoadFinished - L1300_Load2))  ;size
L1300_Load2:
        call    ParseMap

        ;reset heroes to full health
        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a
        ret

L1300_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1300_Map:
INCBIN "Data/Levels/L1300_appomattox.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1300_Init:
        DW ((L1300_InitFinished - L1300_Init2))  ;size
L1300_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      hl,$1100
        call    SetJoinMap
        call    SetRespawnMap

        ld      a,[bgTileMap+DICEINDEX]  ;tile index of first light
        ld      [levelVars+VAR_DICELIGHT],a

        ld      a,0
        ld      [levelVars+VAR_HEROESUSED],a

        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      a,[fgTileMap+BAINDEX]
        ld      [levelVars+VAR_BA],a
        ld      a,[fgTileMap+BSINDEX]
        ld      [levelVars+VAR_BS],a
        ld      a,[fgTileMap+HAIKUINDEX]
        ld      [levelVars+VAR_HAIKU],a

        ;get rid of king grenade if he's not available
        ld      a,[heroesAvailable]
        and     HERO_GRENADE_FLAG
        jr      nz,.afterRemoveKingGrenade

        ld      bc,classGeneric
        call    DeleteObjectsOfClass
.afterRemoveKingGrenade

        ;link down exit to appomattox map
        ld      a,[appomattoxMapIndex]
        or      a
        jr      z,.afterLinkDownExit

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

IF FORCE_EXIT
ld de,FORCE_EXIT_MAP
ENDC
        ;store in exit list
        ld      hl,mapExitLinks+EXIT_D*2
        ld      [hl],e
        inc     hl
        ld      [hl],d

.afterLinkDownExit
        ;if player is king grenade and appx is not at base camp,
        ;set exit to "back inside" level
        LDHL_CURHERODATA HERODATA_TYPE
        ld      a,[hl]
        cp      HERO_GRENADE_FLAG
        jr      nz,.afterLinkGrenade

        ld      a,[appomattoxMapIndex]
        cp      $000a
        jr      z,.afterLinkGrenade

        ld      de,$1304
        ld      hl,mapExitLinks+EXIT_D*2
        ld      [hl],e
        inc     hl
        ld      [hl],d

.afterLinkGrenade
        ;kill north exit (flight) if at space station
        ld      a,[appomattoxMapIndex]
        cp      $b7
        jr      nz,.afterApocalypse

        ld      de,$4040    ;null exit
        ld      hl,mapExitLinks+EXIT_N*2
        ld      [hl],e
        inc     hl
        ld      [hl],d

.afterApocalypse
        ret

L1300_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1300_Check:
        DW ((L1300_CheckFinished - L1300_Check2))  ;size
L1300_Check2:
        call    ((.animateDiceLights-L1300_Check2)+levelCheckRAM)

        ld      a,[levelVars+VAR_HEROESUSED]
        ld      hl,heroesUsed
        xor     [hl]
        jr      z,.afterChangeLounge

        ld      a,[hl]
        ld      [levelVars+VAR_HEROESUSED],a
        ld      b,a

        bit     HERO_BA_BIT,b
        jr      z,.BAinLounge
        call    ((.removeBA-L1300_Check2)+levelCheckRAM)
        jr      .afterCheckBA
.BAinLounge
        call    ((.addBA-L1300_Check2)+levelCheckRAM)
.afterCheckBA

        bit     HERO_BS_BIT,b
        jr      z,.BSinLounge
        call    ((.removeBS-L1300_Check2)+levelCheckRAM)
        jr      .afterCheckBS
.BSinLounge
        call    ((.addBS-L1300_Check2)+levelCheckRAM)
.afterCheckBS

        bit     HERO_HAIKU_BIT,b
        jr      z,.HaikuInLounge
        call    ((.removeHaiku-L1300_Check2)+levelCheckRAM)
        jr      .afterCheckHaiku
.HaikuInLounge
        call    ((.addHaiku-L1300_Check2)+levelCheckRAM)
.afterCheckHaiku

        bit     HERO_GRENADE_BIT,b
        jr      z,.GrenadeInLounge
        call    ((.removeGrenade-L1300_Check2)+levelCheckRAM)
        jr      .afterCheckGrenade
.GrenadeInLounge
        call    ((.addGrenade-L1300_Check2)+levelCheckRAM)
.afterCheckGrenade

.afterChangeLounge
        ret

.removeHaiku
        ld      c,HAIKUINDEX
        jr      .removeIndex
.removeBS
        ld      c,BSINDEX
        jr      .removeIndex
.removeBA
        ld      c,BAINDEX
.removeIndex
        push    bc
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      l,c
        ld      h,((fgTileMap>>8)&$ff)
        ld      [hl],$ff
        call    GetFirst
        ld      b,METHOD_DRAW
        call    CallMethod
        pop     bc
        ret

.removeGrenade
        ld      bc,classGeneric
        call    DeleteObjectsOfClass
        ret

.addHaiku
        ld      l,HAIKUINDEX
        ld      a,[levelVars+VAR_HAIKU]
        jr      .addIndex
.addBS
        ld      l,BSINDEX
        ld      a,[levelVars+VAR_BS]
        jr      .addIndex
.addBA
        ld      l,BAINDEX
        ld      a,[levelVars+VAR_BA]
.addIndex
        push    bc
        ld      c,a
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      a,c
        ld      h,((fgTileMap>>8)&$ff)
        ld      [hl],a
        ld      c,l
        call    GetFirst
        ld      b,METHOD_DRAW
        call    CallMethod
        pop     bc
        ret

.addGrenade
        ld      a,[heroesAvailable]
        and     HERO_GRENADE_FLAG
        ret     z

        ld      c,GRENADE_INDEX
        call    GetFirst
        or      a
        ret     nz   ;already exists

        ld      hl,$d253
        call    CreateInitAndDrawObject
        ret

.animateDiceLights
        ;animate dice lights
        ld      a,[levelVars+VAR_DICELIGHT]
        ld      b,a

        ;slow lights
        ldio    a,[updateTimer]
        swap    a
        and     %00000011
        add     b

        ld      hl,bgTileMap+DICEINDEX
        call    ((.updateTwoLights - L1300_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L1300_Check2) + levelCheckRAM)
        ret

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L1300_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret


L1300_CheckFinished:
PRINT "1300 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1300_LoadFinished - L1300_Load2)
PRINT " / "
PRINT (L1300_InitFinished - L1300_Init2)
PRINT " / "
PRINT (L1300_CheckFinished - L1300_Check2)
PRINT "\n"

