; l0412.asm sunset village stonehead house
; Generated 08.31.2000 by mlevel
; Modified  08.31.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


STATE_TALK_MISSION   EQU 1
STATE_MISSION_TALKED EQU 2
STATE_TALK_FIXED     EQU 3
STATE_FIXED_TALKED   EQU 4

STATE_HIVE_DESTROYED EQU 2   ;from 0312

;---------------------------------------------------------------------
SECTION "Level0412Section",ROMX
;---------------------------------------------------------------------

dialog:
l0006_avacado_gtx:
  INCBIN "gtx\\talk\\l0006_avacado.gtx"

l0006_hero_sayagain_gtx:
  INCBIN "gtx\\talk\\l0006_hero_sayagain.gtx"

l0006_fixbridge_gtx:
  INCBIN "gtx\\talk\\l0006_fixbridge.gtx"

l0006_fixed_gtx:
  INCBIN "gtx\\talk\\l0006_fixed.gtx"

L0412_Contents::
  DW L0412_Load
  DW L0412_Init
  DW L0412_Check
  DW L0412_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0412_Load:
        DW ((L0412_LoadFinished - L0412_Load2))  ;size
L0412_Load2:
        call    ParseMap
        ret

L0412_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0412_Map:
INCBIN "..\\fgbeditor\\l0412_sunsethousewest.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0412_Init:
        DW ((L0412_InitFinished - L0412_Init2))  ;size
L0412_Init2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a
        call    SetPressBDialog

        ldio    a,[mapState]
        cp      STATE_TALK_FIXED
        jr      nc,.fixed

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState + $c3]   ;hive in house map
        cp      STATE_HIVE_DESTROYED
        jr      z,.fixed

        ld      a,STATE_TALK_MISSION
        ldio    [mapState],a
        jr      .stateSet

.fixed
        ld      a,STATE_TALK_FIXED
        ldio    [mapState],a
.stateSet
        ld      bc,classWallCreature
        ld      de,classWallTalker
        call    ChangeClass
        ret

L0412_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0412_Check:
        DW ((L0412_CheckFinished - L0412_Check2))  ;size
L0412_Check2:
        call    ((.checkDialog-L0412_Check2)+levelCheckRAM)
        ret

.checkDialog
        ldio    a,[mapState]
        cp      STATE_MISSION_TALKED
        ret     z
        cp      STATE_FIXED_TALKED
        ret     z

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        ld      a,%11
        call    DisableDialogBalloons
        ld      bc,classStunnedWall
        call    FindClassIndex
        or      a
        jr      z,.afterDisableDialogStunned

        ;disable dialog for any stunned walls
        ld      c,a
        call    GetFirst
        ld      a,1
        call    SetMisc
        call    GetNextObject
        or      a
        jr      z,.afterDisableDialogStunned
        ld      a,1
        call    SetMisc

.afterDisableDialogStunned
        call    MakeIdle

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ldio    a,[mapState]
        cp      STATE_TALK_FIXED
        jr      z,.fixed

        ld      de,((.afterFixDialog-L0412_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;Crush you like avacado
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,l0006_avacado_gtx   
        call    ShowDialogAtTop
        call    ClearDialog

        ;say again?
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        ld      de,l0006_hero_sayagain_gtx
        call    ShowDialogAtBottom
        call    ClearDialog

        ;Fix bridge
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,l0006_fixbridge_gtx
        call    ShowDialogAtTop

.afterFixDialog
        call    ClearDialog
        ld      a,STATE_MISSION_TALKED
        ldio    [mapState],a
        jr      .afterDialog

.fixed
        ld      de,((.afterFixedDialog-L0412_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;bridge fixed
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,l0006_fixed_gtx
        call    ShowDialogAtTop
.afterFixedDialog 
        call    ClearDialog
        ld      a,STATE_FIXED_TALKED
        ldio    [mapState],a

.afterDialog
        call    MakeNonIdle

        xor     a
        ld      [dialogNPC_speakerIndex],a

        ret

L0412_CheckFinished:
PRINTT "0412 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0412_LoadFinished - L0412_Load2)
PRINTT " / "
PRINTV (L0412_InitFinished - L0412_Init2)
PRINTT " / "
PRINTV (L0412_CheckFinished - L0412_Check2)
PRINTT "\n"

