;level0205.asm bridge
;Abe Pralle 3.4.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATER_INDEX     EQU 7 
DARKWATER_INDEX EQU 22
FLOOR_INDEX     EQU 40
STONEHEAD_INDEX EQU 41
STUNNED_INDEX   EQU 42

STATE_BROKEN        EQU 1
STATE_BROKEN_TALKED EQU 2
STATE_FIXED         EQU 3
STATE_TALK_WHAT     EQU 4
STATE_TALK_FORGIVE  EQU 5
STATE_TALK_OKAY     EQU 6
STATE_TALK_GOWEST   EQU 7
STATE_TALK_AFTER    EQU 8
STATE_WAIT_DIALOG   EQU 9

;from l0312
STATE_HIVE_DESTROYED EQU 2


;---------------------------------------------------------------------
SECTION "LevelsSection0205",DATA,BANK[MAP0ROM]
;---------------------------------------------------------------------

dialog:
l0205_idiot_gtx:
  INCBIN "gtx\\talk\\l0205_idiot.gtx"

l0205_what_gtx:
  INCBIN "gtx\\talk\\l0205_what.gtx"

l0205_forgive_gtx:
  INCBIN "gtx\\talk\\l0205_forgive.gtx"

l0205_okay_gtx:
  INCBIN "gtx\\talk\\l0205_okay.gtx"

l0205_west_gtx:
  INCBIN "gtx\\talk\\l0205_west.gtx"

L0205_Contents::
  DW L0205_Load
  DW L0205_Init
  DW L0205_Check
  DW L0205_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0205_Load:
        DW ((L0205_LoadFinished - L0205_Load2))  ;size
L0205_Load2:
        call    ParseMap
				ret

L0205_LoadFinished:

L0205_Map:
INCBIN "..\\fgbeditor\\l0205_bridge.lvl"

;gtx_intro:                INCBIN  "gtx\\Landing\\intro.gtx"
;gtx_intro2:               INCBIN  "gtx\\Landing\\intro2.gtx"
;gtx_finished:             INCBIN  "gtx\\Landing\\finished.gtx"
;gtx_finished2:            INCBIN  "gtx\\Landing\\finished2.gtx"

;---------------------------------------------------------------------
L0205_Init:
;---------------------------------------------------------------------
        DW ((L0205_InitFinished - L0205_Init2))  ;size
L0205_Init2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a
        call    SetPressBDialog

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$c3]   ;bee house in sunset
        cp      STATE_HIVE_DESTROYED
        jr      nz,.notFixed

        ld      a,STATE_FIXED
        ldio    [mapState],a
.notFixed

        ldio    a,[mapState]
        ld      hl,((.resetStateTable-L0205_Init2)+levelCheckRAM)
        call    Lookup8
        ldio    [mapState],a

        cp      STATE_BROKEN
        jr      nz,.fixed
        call    ((.removeBridge-L0205_Init2)+levelCheckRAM)
        jr      .statesDone
.fixed
        ld      bc,classWallCreature
        call    DeleteObjectsOfClass
.statesDone

        ret

.removeBridge
				ld      bc,classWallCreature
				ld      de,classWallTalker
				call    ChangeClass
        ld      bc,classStunnedWall
        call    DeleteObjectsOfClass
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d34f
        call    ((.remove10Tiles-L0205_Init2)+levelCheckRAM)
        ld      hl,$d350
        call    ((.remove10Tiles-L0205_Init2)+levelCheckRAM)
        ret

.remove10Tiles
        ld      a,[mapPitch]
        ld      e,a
        ld      d,0
        ld      c,10
        ld      a,WATER_INDEX
.remove10TilesLoop
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.remove10TilesLoop
        ret

.resetStateTable
        DB STATE_BROKEN,STATE_BROKEN,STATE_BROKEN
        DB STATE_FIXED,STATE_FIXED

L0205_InitFinished:


;---------------------------------------------------------------------
L0205_Check:
;---------------------------------------------------------------------
        DW ((L0205_CheckFinished - L0205_Check) - 2)  ;size
L0205_Check2:
				call    SetSkipStackPos
        call    CheckSkip

        call    ((.animateWater-L0205_Check2)+levelCheckRAM)

				VECTORTOSTATE ((.stateTable - L0205_Check2) + levelCheckRAM)
        ret

.stateTable
        DW ((.checkDialog-L0205_Check2)+levelCheckRAM)
        DW ((.checkDialog-L0205_Check2)+levelCheckRAM)
        DW ((.normal-L0205_Check2)+levelCheckRAM)
        DW ((.normal-L0205_Check2)+levelCheckRAM)
        DW ((.what-L0205_Check2)+levelCheckRAM)
        DW ((.forgive-L0205_Check2)+levelCheckRAM)
        DW ((.okay-L0205_Check2)+levelCheckRAM)
        DW ((.gowest-L0205_Check2)+levelCheckRAM)
        DW ((.afterDialog-L0205_Check2)+levelCheckRAM)
        DW ((.waitDialog-L0205_Check2)+levelCheckRAM)

.normal
        ret

.checkDialog
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        ld      a,%1
        call    DisableDialogBalloons

        call    MakeIdle

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ;Idiot says what?
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,((.what-L0205_Check2) + levelCheckRAM)
        call    SetDialogForward
        ld      de,((.afterDialog-L0205_Check2) + levelCheckRAM)
        call    SetDialogSkip
        DIALOGTOP l0205_idiot_gtx
				WAITDIALOG STATE_TALK_WHAT
        ret

.what
        ;what?
        call    ClearDialog
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        DIALOGBOTTOM l0205_what_gtx
				WAITDIALOG STATE_TALK_FORGIVE
        ret

.forgive
        ;Forgive me
        call    ClearDialog
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        DIALOGTOP l0205_forgive_gtx
				WAITDIALOG STATE_TALK_OKAY
        ret

.okay
        ;okay
        call    ClearDialog
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        DIALOGBOTTOM l0205_okay_gtx
				WAITDIALOG STATE_TALK_GOWEST
        ret

.gowest
        ;go west
        call    ClearDialog
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        DIALOGTOP l0205_west_gtx
				WAITDIALOG STATE_TALK_AFTER
        ret

.afterDialog
        ld      a,STATE_BROKEN_TALKED
        ldio    [mapState],a
        call    ClearDialog
        call    MakeNonIdle

        ld      de,0
        call    SetDialogForward
        call    SetDialogSkip

        xor     a
        ld      [dialogNPC_speakerIndex],a

        ret


.animateWater
        ldio    a,[updateTimer]
        and     %11
        ret     nz

        ;animate water by cycling the tile mapping of class 7 from
				;7-10 and class 22 from 22-25
        ld      a,TILEINDEXBANK
				ld      [$ff70],a

				ld      hl,bgTileMap+WATER_INDEX
				ld      a,[hl]
				sub     WATER_INDEX
				inc     a
				and     %11
				add     WATER_INDEX
				ld      [hl],a

				ld      hl,bgTileMap+DARKWATER_INDEX
				ld      a,[hl]
				sub     DARKWATER_INDEX
				inc     a
				and     %11
				add     DARKWATER_INDEX
				ld      [hl],a

				ret

.waitDialog
        STDWAITDIALOG
        ret

L0205_CheckFinished:


PRINTT "  0205 Level Check Size: "
PRINTV (L0205_CheckFinished - L0205_Check2)
PRINTT "/$500 bytes"

