; L1011.asm
; Generated 04.26.2001 by mlevel
; Modified  04.26.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

STATE_DEFUSED EQU 2


;---------------------------------------------------------------------
SECTION "Level1011Section",ROMX
;---------------------------------------------------------------------

L1011_Contents::
  DW L1011_Load
  DW L1011_Init
  DW L1011_Check
  DW L1011_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1011_Load:
        DW ((L1011_LoadFinished - L1011_Load2))  ;size
L1011_Load2:
        call    ParseMap
        ret

L1011_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1011_Map:
INCBIN "Data/Levels/L1011_ssa_sw.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1011_Init:
        DW ((L1011_InitFinished - L1011_Init2))  ;size
L1011_Init2:
        ld      a,BANK(L0012_defused_gtx)
        ld      [dialogBank],a
        call    SetPressBDialog

        ldio    a,[mapState]
        cp      STATE_DEFUSED
        jr      nz,.afterRemoveBomb

        ;remove bomb
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d062
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d082
        ld      [hl+],a
        ld      [hl],a

.afterRemoveBomb
        ret

L1011_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1011_Check:
        DW ((L1011_CheckFinished - L1011_Check2))  ;size
L1011_Check2:
        call    ((.checkAtBomb-L1011_Check2)+levelCheckRAM)
        ret

.checkAtBomb
        ldio    a,[mapState]
        cp      STATE_DEFUSED
        ret     z

        ld      hl,((.checkHeroAtBomb-L1011_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroAtBomb
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.atBomb

        xor     a
        ret

.atBomb
        ld      a,STATE_DEFUSED
        ldio    [mapState],a

        call    UpdateState

        ;remove bomb
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      hl,$d062
        ld      [hl+],a
        ld      [hl],a
        ld      hl,$d082
        ld      [hl+],a
        ld      [hl],a

        ;check all defused
        ld      d,0
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$b8]
        cp      2
        jr      nz,.check2
        inc     d
.check2
        ld      a,[levelState+$b9]
        cp      2
        jr      nz,.check3
        inc     d
.check3
        ld      a,[levelState+$ba]
        cp      2
        jr      nz,.check4
        inc     d
.check4
        ld      a,[levelState+$bb]
        cp      2
        jr      nz,.checkTotal
        inc     d
.checkTotal
        ;if 3 bombs were defused before this one then that's all
        ld      a,d
        cp      3
        jr      nz,.bombsRemain

        ld      hl,L0012_alldefused_gtx
        jr      .dialog

.bombsRemain
        ld      hl,L0012_defused_gtx

.dialog
        call    MakeIdle
        ld      de,((.afterDialog-L1011_Check2)+levelCheckRAM)
        call    SetDialogSkip
        
        ld      d,h
        ld      e,l

        call    SetSpeakerFromHeroIndex
        call    ShowDialogAtBottom

.afterDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle
 
        ld      a,1
        ret

L1011_CheckFinished:
PRINT "1011 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1011_LoadFinished - L1011_Load2)
PRINT " / "
PRINT (L1011_InitFinished - L1011_Init2)
PRINT " / "
PRINT (L1011_CheckFinished - L1011_Check2)
PRINT "\n"

