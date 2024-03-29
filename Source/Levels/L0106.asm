;L0106.asm
;Abe Pralle 3.4.2000

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

STATE_TALKED EQU 2

;---------------------------------------------------------------------
SECTION "LevelsSection0106",ROMX
;---------------------------------------------------------------------

dialog:
L0106_heysonny_gtx:
  INCBIN "Data/Dialog/Talk/L0106_heysonny.gtx"

L0106_hero_seethem_gtx:
  INCBIN "Data/Dialog/Talk/L0106_hero_seethem.gtx"

L0106_sure_gtx:
  INCBIN "Data/Dialog/Talk/L0106_sure.gtx"

L0106_headnorth_gtx:
  INCBIN "Data/Dialog/Talk/L0106_headnorth.gtx"

L0106_Contents::
  DW L0106_Load
  DW L0106_Init
  DW L0106_Check
  DW L0106_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0106_Load:
        DW ((L0106_LoadFinished - L0106_Load2))  ;size
L0106_Load2:
        call    ParseMap
        ret

L0106_LoadFinished:

L0106_Map:
INCBIN "Data/Levels/L0106_path.lvl"

;gtx_intro:                INCBIN  "Data/Dialog/Landing/intro.gtx"
;gtx_intro2:               INCBIN  "Data/Dialog/Landing/intro2.gtx"
;gtx_finished:             INCBIN  "Data/Dialog/Landing/finished.gtx"
;gtx_finished2:            INCBIN  "Data/Dialog/Landing/finished2.gtx"

;---------------------------------------------------------------------
L0106_Init:
;---------------------------------------------------------------------
        DW ((L0106_InitFinished - L0106_Init2))  ;size
L0106_Init2:
        STDSETUPDIALOG

        ;reset state if bridge not crossed yet
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$5c]    ;triling grove
        or      a
        jr      nz,.afterReset
        ld      a,1
        ldio    [mapState],a
.afterReset

        ld      a,ENV_RAIN
        call    SetEnvEffect
        ret

L0106_InitFinished:


;---------------------------------------------------------------------
L0106_Check:
;---------------------------------------------------------------------
        DW ((L0106_CheckFinished - L0106_Check) - 2)  ;size
L0106_Check2:
        call    ((.checkHermitDialog-L0106_Check2)+levelCheckRAM)
        ret

.checkHermitDialog
        ldio    a,[mapState]
        cp      STATE_TALKED
        jr      c,.dialogOkay

        ld      a,1
        call    DisableDialogBalloons
        ret

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        call    MakeIdle

        ld      de,((.afterDialog-L0106_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex

        ;Hey Sonny
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,L0106_heysonny_gtx
        call    ShowDialogAtTop
        call    ClearDialog

        ;Seen 'em?
        ld      a,[dialogNPC_heroIndex]
        ld      c,a
        call    SetSpeakerFromHeroIndex
        ld      de,L0106_hero_seethem_gtx
        call    ShowDialogAtBottom
        call    ClearDialog

        ;Sure
        ld      a,[dialogNPC_speakerIndex]
        ld      c,a
        ld      de,L0106_sure_gtx
        call    ShowDialogAtTop

        ;Head north
        ld      de,L0106_headnorth_gtx
        call    ShowDialogAtTop

.afterDialog
        call    ClearDialog

        call    MakeNonIdle
        ld      a,STATE_TALKED
        ldio    [mapState],a

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret

L0106_CheckFinished:


PRINT "  0106 Level Check Size: "
PRINT (L0106_CheckFinished - L0106_Check2)
PRINT "/$500 bytes"

