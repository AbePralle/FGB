;L0105.asm rainy forest w/hive & wrangling iron
;Abe Pralle 3.4.2000

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"

HIVE_INDEX EQU 16

STATE_NORMAL        EQU 1
STATE_HIVEDESTROYED EQU 2

;---------------------------------------------------------------------
SECTION "LevelsSection0105",ROMX
;---------------------------------------------------------------------

dialog:
L0105_hero_wrangling_gtx:
  INCBIN "Data/Dialog/Talk/L0105_hero_wrangling.gtx"

L0105_Contents::
  DW L0105_Load
  DW L0105_Init
  DW L0105_Check
  DW L0105_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0105_Load:
        DW ((L0105_LoadFinished - L0105_Load2))  ;size
L0105_Load2:
        call    ParseMap
        ret

L0105_LoadFinished:

L0105_Map:
INCBIN "Data/Levels/L0105_path.lvl"

;gtx_intro:                INCBIN  "Data/Dialog/Landing/intro.gtx"
;gtx_intro2:               INCBIN  "Data/Dialog/Landing/intro2.gtx"
;gtx_finished:             INCBIN  "Data/Dialog/Landing/finished.gtx"
;gtx_finished2:            INCBIN  "Data/Dialog/Landing/finished2.gtx"

;---------------------------------------------------------------------
L0105_Init:
;---------------------------------------------------------------------
        DW ((L0105_InitFinished - L0105_Init2))  ;size
L0105_Init2:
        ld      a,ENV_RAIN
        call    SetEnvEffect

        call    State0To1

        STDSETUPDIALOG
        ret

L0105_InitFinished:


;---------------------------------------------------------------------
L0105_Check:
;---------------------------------------------------------------------
        DW ((L0105_CheckFinished - L0105_Check) - 2)  ;size
L0105_Check2:
        ldio    a,[mapState]
        cp      STATE_HIVEDESTROYED
        jr      z,.done

        ;watch for hive being destroyed
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$dccb
        ld      a,[hl]
        cp      HIVE_INDEX
        jr      z,.done     ;hive still there

        ;hive destroyed
        ld      de,((.afterDialog-L0105_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerToFirstHero
        ld      de,L0105_hero_wrangling_gtx
        call    ShowDialogAtBottom
.afterDialog
        call    ClearDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      bc,ITEM_WRANGLING
        call    AddInventoryItem

        ld      a,STATE_HIVEDESTROYED
        ldio    [mapState],a

.done
        ret
L0105_CheckFinished:


PRINT "  0105 Level Check Size: "
PRINT (L0105_CheckFinished - L0105_Check2)
PRINT "/$500 bytes"

