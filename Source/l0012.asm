; L0012.asm Command Core
; Generated 04.26.2001 by mlevel
; Modified  04.26.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;same for other ssa rooms
STATE_DEFUSED EQU 2

VAR_TALKED   EQU 0

STATIC_INDEX EQU 23
GRUNT_INDEX  EQU 28
GYRO_INDEX   EQU 29

;---------------------------------------------------------------------
SECTION "Level0012Section",ROMX
;---------------------------------------------------------------------

dialog:
L0012_bombs_gtx:
  INCBIN "Data/Dialog/apocalypse/L0012_bombs.gtx"

L0012_defused_gtx::
  INCBIN "Data/Dialog/apocalypse/L0012_defused.gtx"

L0012_alldefused_gtx::
  INCBIN "Data/Dialog/apocalypse/L0012_alldefused.gtx"

L0012_Contents::
  DW L0012_Load
  DW L0012_Init
  DW L0012_Check
  DW L0012_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0012_Load:
        DW ((L0012_LoadFinished - L0012_Load2))  ;size
L0012_Load2:
        call    ParseMap
        ret

L0012_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0012_Map:
INCBIN "Data/Levels/L0012_ssa_cmdcore.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0012_Init:
        DW ((L0012_InitFinished - L0012_Init2))  ;size
L0012_Init2:
        STDSETUPDIALOG
        xor     a
        ld      [levelVars+VAR_TALKED],a
        ret

L0012_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0012_Check:
        DW ((L0012_CheckFinished - L0012_Check2))  ;size
L0012_Check2:
        call    ((.animateStatic-L0012_Check2)+levelCheckRAM)
        call    ((.checkDialog-L0012_Check2)+levelCheckRAM)
        ret

.checkDialog
        ld      a,[levelVars+VAR_TALKED]
        or      a
        ret     nz

        ;enemies gone?
        ld      c,GRUNT_INDEX
        call    GetFirst
        or      a
        ret     nz

        ;check all defused
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$b8]
        cp      2
        jr      nz,.needDefuse
        ld      a,[levelState+$b9]
        cp      2
        jr      nz,.needDefuse
        ld      a,[levelState+$ba]
        cp      2
        jr      nz,.needDefuse
        ld      a,[levelState+$bb]
        cp      2
        jr      nz,.needDefuse

        ;all defused.
        call    MakeIdle

        ld      a,30
.delayStatic
        push    af
        ld      a,1
        call    Delay
        call    ((.animateStatic-L0012_Check2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.delayStatic

        ;Gyro appears on screen
        ld      c,GYRO_INDEX
        ld      hl,$d14a
        call    CreateInitAndDrawObject

        ld      a,30
        call    Delay

        call    MakeNonIdle
        ld      a,1
        ld      [levelVars+VAR_TALKED],a

        ;go to escape ssa cinema
        ld      a,0
        ld      hl,$1204
        call    YankRemotePlayer

        ld      hl,$1204
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.needDefuse
        ld      de,((.afterDialog-L0012_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerToFirstHero
        ld      de,L0012_bombs_gtx
        call    ShowDialogAtBottom

.afterDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,1
        ld      [levelVars+VAR_TALKED],a
        ret

.animateStatic
        ldio    a,[updateTimer]
        rrca
        and     %00000010
        add     STATIC_INDEX
        ld      hl,bgTileMap+STATIC_INDEX
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ret

L0012_CheckFinished:
PRINTT "0012 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0012_LoadFinished - L0012_Load2)
PRINTT " / "
PRINTV (L0012_InitFinished - L0012_Init2)
PRINTT " / "
PRINTV (L0012_CheckFinished - L0012_Check2)
PRINTT "\n"

