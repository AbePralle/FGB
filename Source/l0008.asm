; L0008.asm
; Generated 09.04.2000 by mlevel
; Modified  09.04.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"

STATE_NORMAL        EQU 1
STATE_SPRAYTAKEN    EQU 2

;---------------------------------------------------------------------
SECTION "Level0008Section",ROMX
;---------------------------------------------------------------------

dialog:
L0008_findspray_gtx:
  INCBIN "Data/Dialog/talk/L0008_findspray.gtx"

L0008_Contents::
  DW L0008_Load
  DW L0008_Init
  DW L0008_Check
  DW L0008_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0008_Load:
        DW ((L0008_LoadFinished - L0008_Load2))  ;size
L0008_Load2:
        call    ParseMap
        ret

L0008_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0008_Map:
INCBIN "Data/Levels/L0008_forest.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0008_Init:
        DW ((L0008_InitFinished - L0008_Init2))  ;size
L0008_Init2:
        call    State0To1

        STDSETUPDIALOG

        ldio    a,[mapState]
        cp      STATE_SPRAYTAKEN
        jr      nz,.done

        ;remove spray from map
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d32d],a

.done
        ret

L0008_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0008_Check:
        DW ((L0008_CheckFinished - L0008_Check2))  ;size
L0008_Check2:
        ldio    a,[mapState]
        cp      STATE_SPRAYTAKEN
        jr      z,.done

        xor     a
        ld      hl,((.checkFoundSpray-L0008_Check2)+levelCheckRAM)
        call    CheckEachHero
.done
        ret

.checkFoundSpray
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.foundSpray

        xor     a
        ret

.foundSpray
        ;found spray
        ld      de,((.afterDialog-L0008_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerFromHeroIndex
        ld      de,L0008_findspray_gtx
        call    ShowDialogAtBottom
.afterDialog
        call    ClearDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      bc,ITEM_BUGSPRAY
        call    AddInventoryItem

        ;remove spray from map
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d32d],a

        ld      a,STATE_SPRAYTAKEN
        ldio    [mapState],a

        ld      a,1
        ret

L0008_CheckFinished:
PRINTT "0008 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0008_LoadFinished - L0008_Load2)
PRINTT " / "
PRINTV (L0008_InitFinished - L0008_Init2)
PRINTT " / "
PRINTV (L0008_CheckFinished - L0008_Check2)
PRINTT "\n"

