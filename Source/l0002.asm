; l0002.asm bee border
; Generated 08.27.2000 by mlevel
; Modified  08.27.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

WATERINDEX EQU 23
VAR_WATER  EQU 0

STATE_NORMAL EQU 1
STATE_TALKED EQU 2


;---------------------------------------------------------------------
SECTION "Level0002Section",DATA
;---------------------------------------------------------------------

dialog:
l0002_bees_gtx:
  INCBIN "gtx\\talk\\l0002_bees.gtx"

l0002_hero_spray_gtx:
  INCBIN "gtx\\talk\\l0002_hero_spray.gtx"

l0002_village_gtx:
  INCBIN "gtx\\talk\\l0002_village.gtx"

l0002_hero_no_gtx:
  INCBIN "gtx\\talk\\l0002_hero_no.gtx"

l0002_croutons_gtx:
  INCBIN "gtx\\talk\\l0002_croutons.gtx"

L0002_Contents::
  DW L0002_Load
  DW L0002_Init
  DW L0002_Check
  DW L0002_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0002_Load:
        DW ((L0002_LoadFinished - L0002_Load2))  ;size
L0002_Load2:
        call    ParseMap
        ret

L0002_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0002_Map:
INCBIN "..\\fgbeditor\\l0002_bees.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0002_Init:
        DW ((L0002_InitFinished - L0002_Init2))  ;size
L0002_Init2:
        ld      a,[bgTileMap + WATERINDEX]
				ld      [levelVars + VAR_WATER],a

        STDSETUPDIALOG

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ld      bc,classTree
        ld      de,classTreeTalker
        call    ChangeClass

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0002_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0002_Check:
        DW ((L0002_CheckFinished - L0002_Check2))  ;size
L0002_Check2:
        call    ((.animateWater-L0002_Check2)+levelCheckRAM)
        call    ((.checkDialog-L0002_Check2)+levelCheckRAM)
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

        ld      de,((.afterDialog-L0002_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;Careful; bees
        ld      de,l0002_bees_gtx
        call    ShowDialogNPC

        ;Where's the spray?
        ld      de,l0002_hero_spray_gtx
        call    ShowDialogHero

        ;Down south; seen anybody?
        ld      de,l0002_village_gtx
        call    ShowDialogNPC

        ;No
        ld      de,l0002_hero_no_gtx
        call    ShowDialogHero

        ;tell about croutons
        ld      de,l0002_croutons_gtx
        call    ShowDialogNPC

.afterDialog
        call    ClearDialog

        call    MakeNonIdle
        ld      a,STATE_TALKED
        ldio    [mapState],a

        ld      a,1
        call    DisableDialogBalloons

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret


.animateWater
        ldio    a,[updateTimer]
				swap    a
				and     %11
				ld      hl,levelVars + VAR_WATER
				add     [hl]
				ld      [bgTileMap + WATERINDEX],a
				ret

L0002_CheckFinished:
PRINTT "0002 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0002_LoadFinished - L0002_Load2)
PRINTT " / "
PRINTV (L0002_InitFinished - L0002_Init2)
PRINTT " / "
PRINTV (L0002_CheckFinished - L0002_Check2)
PRINTT "\n"

