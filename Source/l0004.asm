; l0004.asm start of green pastures
; Generated 08.24.2000 by mlevel
; Modified  08.24.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

STATE_NORMAL EQU 1
STATE_TALKED EQU 2


;---------------------------------------------------------------------
SECTION "Level0004Section",ROMX
;---------------------------------------------------------------------

dialog:
l0004_howdypilgrim_gtx:
  INCBIN "gtx\\talk\\l0004_howdypilgrim.gtx"

l0004_sure_gtx:
  INCBIN "gtx\\talk\\l0004_sure.gtx"

l0004_mindyourbusiness_gtx:
  INCBIN "gtx\\talk\\l0004_mindyourbusiness.gtx"

L0004_Contents::
  DW L0004_Load
  DW L0004_Init
  DW L0004_Check
  DW L0004_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0004_Load:
        DW ((L0004_LoadFinished - L0004_Load2))  ;size
L0004_Load2:
        call    ParseMap
        ret

L0004_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0004_Map:
INCBIN "..\\fgbeditor\\L0004_ranch.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0004_Init:
        DW ((L0004_InitFinished - L0004_Init2))  ;size
L0004_Init2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a
        call    SetPressBDialog

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ld      bc,classCowboy
        ld      de,classCowboyTalker
        call    ChangeClass

        ld      a,BANK(cowboy_gbm)
        ld      hl,cowboy_gbm
        call    InitMusic
        ret

L0004_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0004_Check:
        DW ((L0004_CheckFinished - L0004_Check2))  ;size
L0004_Check2:
        call    ((.checkDialog-L0004_Check2)+levelCheckRAM)
        ret

.checkDialog
        ldio    a,[mapState]
        cp      STATE_TALKED
        jr      c,.dialogOkay

        ld      a,%11
        call    DisableDialogBalloons
        ret

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        call    MakeIdle

        ld      de,((.afterDialog-L0004_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ;Howdy pilgrim
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,l0004_howdypilgrim_gtx
        call    ShowDialogAtTop
        call    ClearDialog

        ;Sure I'll help
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        ld      de,l0004_sure_gtx
        call    ShowDialogAtBottom
        call    ClearDialog

        ;Mind your own business
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,l0004_mindyourbusiness_gtx
        call    ShowDialogAtTop

.afterDialog
        call    ClearDialog
        call    ClearDialogSkipForward

        call    MakeNonIdle
        ld      a,STATE_TALKED
        ldio    [mapState],a

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret

L0004_CheckFinished:
PRINTT "0004 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0004_LoadFinished - L0004_Load2)
PRINTT " / "
PRINTV (L0004_InitFinished - L0004_Init2)
PRINTT " / "
PRINTV (L0004_CheckFinished - L0004_Check2)
PRINTT "\n"

