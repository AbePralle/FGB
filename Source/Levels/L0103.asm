; L0103.asm east farm
; Generated 08.27.2000 by mlevel
; Modified  08.27.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"

WATERINDEX EQU 12
VAR_WATER  EQU 0

STATE_NORMAL  EQU 1
STATE_TALKED1 EQU 2
STATE_TALKED2 EQU 3



;---------------------------------------------------------------------
SECTION "Level0103Section",ROMX
;---------------------------------------------------------------------

dialog:
L0103_shootinfast_gtx:
  INCBIN "Data/Dialog/Talk/L0103_shootinfast.gtx"

L0103_wrangling_gtx:
  INCBIN "Data/Dialog/Talk/L0103_wrangling.gtx"

L0103_bs_where_gtx:
  INCBIN "Data/Dialog/Talk/L0103_bs_where.gtx"

L0103_forest_gtx:
  INCBIN "Data/Dialog/Talk/L0103_forest.gtx"

L0103_bs_figures_gtx:
  INCBIN "Data/Dialog/Talk/L0103_bs_figures.gtx"

L0103_learn_gtx:
  INCBIN "Data/Dialog/Talk/L0103_learn.gtx"

L0103_honey_gtx:
  INCBIN "Data/Dialog/Talk/L0103_honey.gtx"

L0103_hero_honeyresponse_gtx:
  INCBIN "Data/Dialog/Talk/L0103_hero_honeyresponse.gtx"

L0103_gethoney_gtx:
  INCBIN "Data/Dialog/Talk/L0103_gethoney.gtx"

L0103_snakebitekit_gtx:
  INCBIN "Data/Dialog/Talk/L0103_snakebitekit.gtx"

L0103_seenyoubefore_gtx:
  INCBIN "Data/Dialog/Talk/L0103_seenyoubefore.gtx"


L0103_Contents::
  DW L0103_Load
  DW L0103_Init
  DW L0103_Check
  DW L0103_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0103_Load:
        DW ((L0103_LoadFinished - L0103_Load2))  ;size
L0103_Load2:
        call    ParseMap
        ret

L0103_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0103_Map:
INCBIN "Data/Levels/L0103_green.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0103_Init:
        DW ((L0103_InitFinished - L0103_Init2))  ;size
L0103_Init2:
        ld      a,[bgTileMap + WATERINDEX]
        ld      [levelVars + VAR_WATER],a

        STDSETUPDIALOG

        ld      bc,classCowboy
        ld      de,classCowboyTalker
        call    ChangeFirstClass

        ld      a,STATE_NORMAL
        ldio    [mapState],a

        ld      a,BANK(cowboy_gbm)
        ld      hl,cowboy_gbm
        call    InitMusic

        ret

L0103_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0103_Check:
        DW ((L0103_CheckFinished - L0103_Check2))  ;size
L0103_Check2:
        call    ((.animateWater-L0103_Check2)+levelCheckRAM)
        call    ((.checkDialog-L0103_Check2)+levelCheckRAM)
        ret

.checkDialog
        ldio    a,[mapState]
        cp      STATE_TALKED2
        ret     nc

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        call    MakeIdle

        ldio    a,[mapState]
        cp      STATE_TALKED1
        jr      z,.talkAboutHoney

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ld      a,HERO_BS_FLAG
        call    ClassIndexIsHeroType
        jr      z,.shortVersion

        ld      bc,ITEM_BSSHOOTFAST
        call    HasInventoryItem
        jr      nz,.shortVersion

        ld      bc,ITEM_WRANGLING
        call    HasInventoryItem
        jr      nz,.giveUpgrade

        ;About wrangling iron
        ld      de,((.afterUpgradeDialog-L0103_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      de,L0103_wrangling_gtx
        call    ShowDialogNPC

        ;Where's the wrangling iron?
        ld      de,L0103_bs_where_gtx
        call    ShowDialogHero

        ;under a bee hive
        ld      de,L0103_forest_gtx
        call    ShowDialogNPC

        ;Typical
        ld      de,L0103_bs_figures_gtx
        call    ShowDialogHero
        jr      .afterUpgradeDialog

.giveUpgrade
        ld      de,((.afterLearnDialog-L0103_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;How to shoot fast
        ld      de,L0103_learn_gtx
        call    ShowDialogNPC

.afterLearnDialog
        ld      hl,bsUpgrades
        set     UPGRADE_BSSHOOTFAST,[hl]

        ld      bc,ITEM_BSSHOOTFAST
        call    AddInventoryItem

        ld      bc,ITEM_WRANGLING
        call    RemoveInventoryItem
        jr      .afterUpgradeDialog

.shortVersion
        ld      de,((.afterUpgradeDialog-L0103_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;"Jeb is my name"
        ld      de,L0103_shootinfast_gtx
        call    ShowDialogNPC 

.afterUpgradeDialog
        call    ClearDialog
        call    ClearDialogSkipForward

        call    MakeNonIdle
        ld      a,STATE_TALKED1
        ldio    [mapState],a

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret

.talkAboutHoney
        ld      bc,ITEM_SNAKEBITEKIT
        call    HasInventoryItem
        jr      nz,.hasSnakeBiteKit

        ld      bc,ITEM_HONEY
        call    HasInventoryItem
        jr      nz,.hasHoney

        ld      de,((.afterHoneyDialog-L0103_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;I love honey
        ld      de,L0103_honey_gtx
        call    ShowDialogNPC

        ;Hero's response to honey lover
        ld      de,L0103_hero_honeyresponse_gtx
        call    ShowDialogHero

        ;Get me some honey
        ld      de,L0103_gethoney_gtx
        call    ShowDialogNPC
        jr      .afterHoneyDialog

.hasSnakeBiteKit
        ld      de,((.afterHoneyDialog-L0103_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;seen you before
        ld      de,L0103_seenyoubefore_gtx
        call    ShowDialogNPC
        jr      .afterHoneyDialog

.hasHoney
        ld      de,((.giveKit-L0103_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ;give snake bite kit
        ld      de,L0103_snakebitekit_gtx
        call    ShowDialogNPC

.giveKit
        ld      bc,ITEM_HONEY
        call    RemoveInventoryItem

        ld      bc,ITEM_SNAKEBITEKIT
        call    AddInventoryItem

.afterHoneyDialog
        call    ClearDialog
        call    ClearDialogSkipForward

        call    MakeNonIdle
        ld      a,STATE_TALKED2
        ldio    [mapState],a

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

L0103_CheckFinished:
PRINT "0103 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0103_LoadFinished - L0103_Load2)
PRINT " / "
PRINT (L0103_InitFinished - L0103_Init2)
PRINT " / "
PRINT (L0103_CheckFinished - L0103_Check2)
PRINT "\n"

