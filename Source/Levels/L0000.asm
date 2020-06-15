;L0000.asm hive
;Abe Pralle 3.4.2000

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"

STATE_NORMAL        EQU 1
STATE_HONEYTAKEN    EQU 2

;---------------------------------------------------------------------
SECTION "LevelsSection0000",ROMX,BANK[MAP0ROM]
;---------------------------------------------------------------------

dialog:
L0000_hero_honey_gtx:
  INCBIN "Data/Dialog/Talk/L0000_hero_honey.gtx"

L0000_Contents::
  DW L0000_Load
  DW L0000_Init
  DW L0000_Check
  DW L0000_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0000_Load:
        DW ((L0000_LoadFinished - L0000_Load2))  ;size
L0000_Load2:
        call    ParseMap
        ret

L0000_LoadFinished:

L0000_Map:
INCBIN "Data/Levels/L0000_hive.lvl"

;gtx_intro:                INCBIN  "Data/Dialog/Landing/intro.gtx"
;gtx_intro2:               INCBIN  "Data/Dialog/Landing/intro2.gtx"
;gtx_finished:             INCBIN  "Data/Dialog/Landing/finished.gtx"
;gtx_finished2:            INCBIN  "Data/Dialog/Landing/finished2.gtx"

;---------------------------------------------------------------------
L0000_Init:
;---------------------------------------------------------------------
        DW ((L0000_InitFinished - L0000_Init2))  ;size
L0000_Init2:
        call    State0To1

        STDSETUPDIALOG

        ldio    a,[mapState]
        cp      STATE_HONEYTAKEN
        jr      nz,.done

        ;remove honey from map
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d146],a

.done
        ret

L0000_InitFinished:


;---------------------------------------------------------------------
L0000_Check:
;---------------------------------------------------------------------
        DW ((L0000_CheckFinished - L0000_Check) - 2)  ;size
L0000_Check2:
        ldio    a,[mapState]
        cp      STATE_HONEYTAKEN
        jr      z,.done

        xor     a
        ld      hl,((.checkFoundHoney-L0000_Check2)+levelCheckRAM)
        call    CheckEachHero
.done
        ret

.checkFoundHoney
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.foundHoney

        xor     a
        ret

.foundHoney
        ;found honey
        ld      de,((.afterDialog-L0000_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerFromHeroIndex
        ld      de,L0000_hero_honey_gtx
        call    ShowDialogAtBottom
.afterDialog
        call    ClearDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      bc,ITEM_HONEY
        call    AddInventoryItem

        ;remove honey from map
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d146],a

        ld      a,STATE_HONEYTAKEN
        ldio    [mapState],a

        ld      a,1
        ret
L0000_CheckFinished:


PRINTT "  0000 Level Check Size: "
PRINTV (L0000_CheckFinished - L0000_Check2)
PRINTT "/$500 bytes"

