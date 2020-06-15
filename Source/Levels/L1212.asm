; L1212.asm Crouton Homeworld 1
; Generated 04.19.2001 by mlevel
; Modified  04.19.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

NUM_DIALOG     EQU 3

HFENCE_INDEX   EQU 18
HULK_INDEX     EQU 43
GOBLIN_INDEX   EQU 44

VAR_OVERHEARD  EQU 0

STATE_ANYTIME  EQU 0
STATE_MAKESURE EQU 1
STATE_SUCKS    EQU 2

;---------------------------------------------------------------------
SECTION "Level1212Section",ROMX
;---------------------------------------------------------------------

dialog:
L1212_anytime_gtx:
  INCBIN "Data/Dialog/Talk/L1212_anytime.gtx"

L1212_yeah_gtx:
  INCBIN "Data/Dialog/Talk/L1212_yeah.gtx"

L1212_makesure_gtx:
  INCBIN "Data/Dialog/Talk/L1212_makesure.gtx"

L1212_suckstobehim_gtx:
  INCBIN "Data/Dialog/Talk/L1212_suckstobehim.gtx"

L1212_Contents::
  DW L1212_Load
  DW L1212_Init
  DW L1212_Check
  DW L1212_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1212_Load:
        DW ((L1212_LoadFinished - L1212_Load2))  ;size
L1212_Load2:
        call    ParseMap
        ret

L1212_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1212_Map:
INCBIN "Data/Levels/L1212_crouton_hw1.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1212_Init:
        DW ((L1212_InitFinished - L1212_Init2))  ;size
L1212_Init2:
        ld      hl,$1212
        call    SetJoinMap
        call    SetRespawnMap

        call    State0To1

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic

        STDSETUPDIALOG
        
        xor     a
        ld      [levelVars+VAR_OVERHEARD],a
        ret

L1212_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1212_Check:
        DW ((L1212_CheckFinished - L1212_Check2))  ;size
L1212_Check2:
        call    ((.animateFence-L1212_Check2)+levelCheckRAM)
        call    ((.checkDialog-L1212_Check2)+levelCheckRAM)
        ret

.checkDialog
        ld      a,[levelVars+VAR_OVERHEARD]
        or      a
        ret     nz

        ld      hl,((.checkHeroInZone-L1212_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroInZone
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.inZone

        xor     a
        ret

.inZone
        ;increment dialog number
        ld      hl,mapState
        ld      a,[hl]
        push    af
        inc     a
        cp      (NUM_DIALOG+1)
        jr      c,.dialogNumOkay

        ld      a,1

.dialogNumOkay
        ld      [hl],a
        pop     af

        ld      hl,((.dialogLookup-L1212_Check2)+levelCheckRAM)
        call    Lookup16

        push    hl
        call    MakeIdle
        pop     hl
        ld      de,((.afterDialog-L1212_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      d,h
        ld      e,l
        call    SetSpeakerFromHeroIndex
        ld      c,HULK_INDEX
        call    ShowDialogAtTop

        call    ClearDialog
        ld      c,GOBLIN_INDEX
        ld      de,L1212_yeah_gtx
        call    ShowDialogAtBottom

.afterDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,1
        ld      [levelVars+VAR_OVERHEARD],a
        ret

.animateFence
        ldio    a,[updateTimer]
        rrca
        and     3
        ld      b,a
        ld      hl,bgTileMap+HFENCE_INDEX
        ld      d,HFENCE_INDEX
        call    ((.animateFourFrames-L1212_Check2)+levelCheckRAM)
        ret

.animateFourFrames
        ld      c,4

.animateFourFrames_loop
        ld      a,b
        add     c
        and     3
        add     d
        ld      [hl+],a
        dec     c
        jr      nz,.animateFourFrames_loop
        ret

.dialogLookup
  DW 0,L1212_anytime_gtx,L1212_makesure_gtx,L1212_suckstobehim_gtx

L1212_CheckFinished:
PRINTT "1212 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1212_LoadFinished - L1212_Load2)
PRINTT " / "
PRINTV (L1212_InitFinished - L1212_Init2)
PRINTT " / "
PRINTV (L1212_CheckFinished - L1212_Check2)
PRINTT "\n"

