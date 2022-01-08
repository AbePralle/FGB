; L0003.asm green pastures big sheep pen
; Generated 08.26.2000 by mlevel
; Modified  08.26.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

BLUE_INDEX EQU 49

STATE_NORMAL  EQU 1
STATE_TALKED1 EQU 2
STATE_TALKED2 EQU 3


;---------------------------------------------------------------------
SECTION "Level0003Section",ROMX
;---------------------------------------------------------------------

dialog:
L0003_wolves_gtx:
  INCBIN "Data/Dialog/Talk/L0003_wolves.gtx"

L0003_shootfast_gtx:
  INCBIN "Data/Dialog/Talk/L0003_shootfast.gtx"

L0003_hero_jeb_gtx:
  INCBIN "Data/Dialog/Talk/L0003_hero_jeb.gtx"

L0003_nevermind_gtx:
  INCBIN "Data/Dialog/Talk/L0003_nevermind.gtx"

L0003_aboutjeb_gtx:
  INCBIN "Data/Dialog/Talk/L0003_aboutjeb.gtx"

L0003_Contents::
  DW L0003_Load
  DW L0003_Init
  DW L0003_Check
  DW L0003_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0003_Load:
        DW ((L0003_LoadFinished - L0003_Load2))  ;size
L0003_Load2:
        call    ParseMap
        ret

L0003_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0003_Map:
INCBIN "Data/Levels/L0003_green.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0003_Init:
        DW ((L0003_InitFinished - L0003_Init2))  ;size
L0003_Init2:
        STDSETUPDIALOG

        ld      bc,classCowboy
        ld      de,classCowboyTalker
        call    ChangeFirstClass

        ld      a,BLUE_INDEX
        ld      [dialogBalloonClassIndex],a
        ld      a,%0011
        call    DisableDialogBalloons

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ld      a,BANK(cowboy_gbm)
        ld      hl,cowboy_gbm
        call    InitMusic
        ret

L0003_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0003_Check:
        DW ((L0003_CheckFinished - L0003_Check2))  ;size
L0003_Check2:
        call    ((.checkDialog-L0003_Check2)+levelCheckRAM)
        ret

.checkDialog
        ldio    a,[mapState]
        cp      STATE_TALKED2
        jr      c,.dialogOkay

        ld      a,$ff
        call    DisableDialogBalloons
        ret

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        call    MakeIdle

        ldio    a,[mapState]
        cp      STATE_TALKED1
        jr      z,.talkAboutJeb

        ld      de,((.afterWolfDialog-L0003_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ;Warn about wolves
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,L0003_wolves_gtx
        call    ShowDialogAtTop
        call    ClearDialog

.afterWolfDialog
        call    ClearDialog
        call    ClearDialogSkipForward

        call    MakeNonIdle
        ld      a,STATE_TALKED1
        ldio    [mapState],a

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret

.talkAboutJeb
        ld      de,((.afterJebDialog-L0003_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ;Out here ya gotta shoot fast
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,L0003_shootfast_gtx
        call    ShowDialogAtTop
        call    ClearDialog

        ;Jeb?
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        ld      de,L0003_hero_jeb_gtx
        call    ShowDialogAtBottom
        call    ClearDialog

        ld      a,HERO_BS_FLAG
        call    ClassIndexIsHeroType
        jr      z,.notBS

        ;nevermind
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,L0003_aboutjeb_gtx
        call    ShowDialogAtTop
        jr      .afterJebDialog

.notBS
        ;nevermind
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,L0003_nevermind_gtx
        call    ShowDialogAtTop

.afterJebDialog
        call    ClearDialog
        call    ClearDialogSkipForward

        call    MakeNonIdle
        ld      a,STATE_TALKED2
        ldio    [mapState],a

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret

L0003_CheckFinished:
PRINT "0003 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0003_LoadFinished - L0003_Load2)
PRINT " / "
PRINT (L0003_InitFinished - L0003_Init2)
PRINT " / "
PRINT (L0003_CheckFinished - L0003_Check2)
PRINT "\n"

