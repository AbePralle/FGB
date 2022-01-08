; L0304.asm pansies eat shrooms
; Generated 08.03.2000 by mlevel
; Modified  08.03.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"


;---------------------------------------------------------------------
SECTION "Level0304Section",ROMX
;---------------------------------------------------------------------

dialog:
L0304_spores_gtx:
  INCBIN "Data/Dialog/Talk/L0304_spores.gtx"

L0304_Contents::
  DW L0304_Load
  DW L0304_Init
  DW L0304_Check
  DW L0304_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0304_Load:
        DW ((L0304_LoadFinished - L0304_Load2))  ;size
L0304_Load2:
        call    ParseMap
        ret

L0304_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0304_Map:
INCBIN "Data/Levels/L0304_shroom.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
PANSYINDEX1  EQU 45
PANSYINDEX2  EQU 46
PANSYINDEX3  EQU 47
LOWSHROOMINDEX  EQU  2
HIGHSHROOMINDEX EQU 13

MAPPITCH EQU 32

STATE_NORMAL_INIT   EQU 1
STATE_NORMAL_TALK   EQU 2
STATE_NORMAL        EQU 3
STATE_SOLVED_INIT   EQU 4
STATE_SOLVED_TALK   EQU 5
STATE_SOLVED        EQU 6

L0304_Init:
        DW ((L0304_InitFinished - L0304_Init2))  ;size
L0304_Init2:
        ldio    a,[mapState]
        ld      hl,((.resetStateTable-L0304_Init2)+levelCheckRAM)
        call    Lookup8
        ldio    [mapState],a

        STDSETUPDIALOG

        ld      bc,ITEM_SPOREMASK
        call    HasInventoryItem
        jr      nz,.hasMask

        ld      hl,HOffsetOnHBlank
        call    InstallHBlankHandler
.hasMask

        ;ld      a,BANK(shroom_gbm)
        ;ld      hl,shroom_gbm
        ;call    InitMusic

        ;set the pansies to be friendly and to eat the shrooms
        ld      c,PANSYINDEX1
        call    ((.makeFriendly-L0304_Init2)+levelCheckRAM)
        ld      c,PANSYINDEX2
        call    ((.makeFriendly-L0304_Init2)+levelCheckRAM)
        ld      c,PANSYINDEX3
        call    ((.makeFriendly-L0304_Init2)+levelCheckRAM)

        ld      bc,classPansy
        ld      de,classHippiePansy
        call    ChangeClass

        ;remove the shrooms blocking the exit if level solved already
        ldio    a,[mapState]
        cp      STATE_SOLVED_INIT
        ret     nz

        ld      hl,$d1dd
        call    ((.remove2x2-L0304_Init2)+levelCheckRAM)

        ld      hl,$d23d
        call    ((.remove2x2-L0304_Init2)+levelCheckRAM)
        ret

.makeFriendly
        call    GetFirst
        or      a
        ret     z

.continue
        ld      a,GROUP_MONSTERB
        call    SetGroup
        ld      hl,((HIGHSHROOMINDEX<<8) | LOWSHROOMINDEX)
        call    SetActorDestLoc
        call    GetNextObject
        or      a
        jr      nz,.continue
        ret

.remove2x2
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [hl+],a
        ld      [hl-],a
        ld      de,MAPPITCH
        add     hl,de
        ld      [hl+],a
        ld      [hl],a
        ret

.resetStateTable
        DB STATE_NORMAL_INIT,STATE_NORMAL_INIT,STATE_NORMAL_INIT
        DB STATE_NORMAL_INIT,STATE_SOLVED_INIT,STATE_SOLVED_INIT
        DB STATE_SOLVED_INIT

L0304_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0304_Check:
        DW ((L0304_CheckFinished - L0304_Check2))  ;size
L0304_Check2:
        call    ((.updateWave-L0304_Check2)+levelCheckRAM)
        ldio    a,[mapState]

        cp      STATE_NORMAL_INIT
        jr      z,.initialUpdate
        cp      STATE_SOLVED_INIT
        jr      z,.initialUpdate

        cp      STATE_NORMAL_TALK
        jr      z,.talk
        cp      STATE_SOLVED_TALK
        jr      z,.talk

        ld      a,1
        ld      hl,((.checkSolved-L0304_Check2)+levelCheckRAM)
        call    CheckEachHero
        ret

.initialUpdate
        inc     a
        ldio    [mapState],a
        ret

.talk
        ld      bc,ITEM_SPOREMASK
        call    HasInventoryItem
        jr      nz,.afterTalk

        call    MakeIdle

        ld      de,((.afterTalk-L0304_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerToFirstHero
        ld      de,L0304_spores_gtx
        call    ShowDialogAtBottom
.afterTalk
        call    ClearDialogSkipForward
        call    MakeNonIdle
        ldio    a,[mapState]
        inc     a
        ldio    [mapState],a
        ret

.checkSolved
        or      a
        ret     z

        ld      c,a
        call    GetFirst        ;get my hero object
        call    GetCurZone
        cp      2
        jr      z,.inZone2
        xor     a   ;return false
        ret 

.inZone2
        ;in zone 2, level solved
        ld      a,STATE_SOLVED
        ldio    [mapState],a
        ld      a,1  ;return true
        ret

.updateWave
        ld      bc,ITEM_SPOREMASK
        call    HasInventoryItem
        ret     nz

        ;fill the horizontalOffset table with values from the sine table
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ldio    a,[updateTimer]
        and     63
        ld      e,a
        ld      d,0
        ld      hl,((.sineTable-L0304_Check2)+levelCheckRAM)
        add     hl,de
        ld      de,horizontalOffset
        ld      c,144
.updateLoop
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.updateLoop

        ld      a,[horizontalOffset]
        ld      [lineZeroHorizontalOffset],a

        ld      hl,hblankFlag
        set     2,[hl]

        ret

.sineTable   ;four 64-byte sine waves, values between 0 and 7
REPT 4
DB  4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7
DB  7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 4, 4
DB  4, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
DB  0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3
ENDR

L0304_CheckFinished:
PRINT "0304 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0304_LoadFinished - L0304_Load2)
PRINT " / "
PRINT (L0304_InitFinished - L0304_Init2)
PRINT " / "
PRINT (L0304_CheckFinished - L0304_Check2)
PRINT "\n"

