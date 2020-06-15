; L1012.asm library
; Generated 04.10.2001 by mlevel
; Modified  04.10.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

STATE_NORMAL    EQU 1
STATE_READBOOK  EQU 2

;---------------------------------------------------------------------
SECTION "Level1012Section",ROMX
;---------------------------------------------------------------------

dialog:
L1012_hero_readbook_gtx:
  INCBIN "Data/Dialog/Talk/L1012_hero_readbook.gtx"

L1012_Contents::
  DW L1012_Load
  DW L1012_Init
  DW L1012_Check
  DW L1012_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1012_Load:
        DW ((L1012_LoadFinished - L1012_Load2))  ;size
L1012_Load2:
        call    ParseMap
        ret

L1012_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1012_Map:
INCBIN "Data/Levels/L1012_library.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1012_Init:
        DW ((L1012_InitFinished - L1012_Init2))  ;size
L1012_Init2:
        STDSETUPDIALOG
        ret

L1012_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1012_Check:
        DW ((L1012_CheckFinished - L1012_Check2))  ;size
L1012_Check2:
        call    ((.checkAtBook-L1012_Check2)+levelCheckRAM)
        ret

.checkAtBook
        ldio    a,[mapState]
        cp      STATE_READBOOK
        ret     z

        ld      hl,((.checkHeroAtBook-L1012_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroAtBook
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.atBook

        xor     a
        ret

.atBook
        call    MakeIdle
        ld      de,((.afterDialog-L1012_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,L1012_hero_readbook_gtx
        call    ShowDialogAtBottom

.afterDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle
        ld      a,STATE_READBOOK
        ldio    [mapState],a
 
        ld      a,1
        ret
        

L1012_CheckFinished:
PRINTT "1012 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1012_LoadFinished - L1012_Load2)
PRINTT " / "
PRINTV (L1012_InitFinished - L1012_Init2)
PRINTT " / "
PRINTV (L1012_CheckFinished - L1012_Check2)
PRINTT "\n"

