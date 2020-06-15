; L0405.asm west gardens
; Generated 10.16.2000 by mlevel
; Modified  10.16.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

WATERINDEX  EQU 40
LOW_INDEX   EQU 46
HIGH_INDEX  EQU 49

VAR_WATER   EQU 0
VAR_ALARM   EQU 1

STATE_NORMAL EQU 1
STATE_TALKED EQU 2

;for L0505
STATE_AFTERWEDDING EQU 2


;---------------------------------------------------------------------
SECTION "Level0405Section",ROMX
;---------------------------------------------------------------------

dialog:
L0405_ho_gtx:
  INCBIN "Data/Dialog/Talk/L0405_ho.gtx"

L0405_hero_reaction_gtx:
  INCBIN "Data/Dialog/Talk/L0405_hero_reaction.gtx"

L0405_final_word_gtx:
  INCBIN "Data/Dialog/Talk/L0405_final_word.gtx"

L0405_Contents::
  DW L0405_Load
  DW L0405_Init
  DW L0405_Check
  DW L0405_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0405_Load:
        DW ((L0405_LoadFinished - L0405_Load2))  ;size
L0405_Load2:
        call    ParseMap
        ret

L0405_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0405_Map:
INCBIN "Data/Levels/L0405_garden.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0405_Init:
        DW ((L0405_InitFinished - L0405_Init2))  ;size
L0405_Init2:
        ld      a,STATE_NORMAL
        ldio    [mapState],a

        STDSETUPDIALOG

        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a

        ld      bc,classPansy
        ld      de,classActor2
        call    ChangeClass

        xor     a
        ld      [levelVars+VAR_ALARM],a

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$55]  ;palace
        cp      STATE_AFTERWEDDING
        jr      nc,.afterWedding

.beforeWedding
        ld      bc,classDandelionGuard
        ld      de,classTreeTalker
        call    ChangeClass

        jr      .done

.afterWedding
        call    ((.openGate-L0405_Init2)+levelCheckRAM)
        ld      bc,classDandelionGuard
        ld      de,classActor
        call    ChangeClass

.done
        ret

.openGate
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d113
        xor     a
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d133
        ld      [hl+],a
        ld      [hl],a
        ret

L0405_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0405_Check:
        DW ((L0405_CheckFinished - L0405_Check2))  ;size
L0405_Check2:
        call    ((.animateWater-L0405_Check2)+levelCheckRAM)
        call    ((.checkAlarm-L0405_Check2)+levelCheckRAM)
        call    ((.checkDialog-L0405_Check2)+levelCheckRAM)
        ret

.checkDialog
        ldio    a,[mapState]
        cp      STATE_TALKED
        ret     z

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        call    MakeIdle

        ld      de,((.afterDialog-L0405_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;Ho, miscreant!
        ld      de,L0405_ho_gtx
        call    ShowDialogNPC

        ;Reaction
        ld      de,L0405_hero_reaction_gtx
        call    ShowDialogHero

        ;Final word
        ld      de,L0405_final_word_gtx
        call    ShowDialogNPC

.afterDialog
        call    ClearDialog

        call    MakeNonIdle
        ld      a,STATE_TALKED
        ldio    [mapState],a

        ld      a,$ff
        call    DisableDialogBalloons

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret


.checkAlarm
        ld      a,[levelVars+VAR_ALARM]
        or      a
        ret     nz

        ;ld      a,[guardAlarm]
        ;or      a
        ;jr      nz,.soundAlarm

        ;count pansies
        ld      b,0
        ld      c,LOW_INDEX   
        call    GetNumObjects
        add     b
        ld      b,a
        ld      c,LOW_INDEX+1
        call    GetNumObjects
        add     b
        ld      b,a
        ld      c,LOW_INDEX+2
        call    GetNumObjects
        add     b
        ld      b,a
        ld      c,LOW_INDEX+3
        call    GetNumObjects
        add     b
        ld      b,a
        cp      49     ;all still here?
        ret     nc

.soundAlarm
        xor     a
        ld      [dialogBalloonClassIndex],a

        ld      a,1
        ld      [levelVars+VAR_ALARM],a

        ld      bc,classActor2
        ld      de,classPansy
        call    ChangeClass

        ld      bc,classActor
        ld      de,classDandelionGuard
        call    ChangeClass

        ld      bc,classTreeTalker
        ld      de,classDandelionGuard
        call    ChangeClass
        ret

.animateWater
        ldio    a,[updateTimer]
        swap    a
        and     %11
        ld      hl,levelVars + VAR_WATER
        add     [hl]
        ld      [bgTileMap + WATERINDEX],a
        ret

L0405_CheckFinished:
PRINTT "0405 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0405_LoadFinished - L0405_Load2)
PRINTT " / "
PRINTV (L0405_InitFinished - L0405_Init2)
PRINTT " / "
PRINTV (L0405_CheckFinished - L0405_Check2)
PRINTT "\n"

