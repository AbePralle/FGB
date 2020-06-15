; L0313.asm ba ships quarters
; Generated 07.28.2000 by mlevel
; Modified  07.28.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0313Section",ROMX
;---------------------------------------------------------------------

L0313_Contents::
  DW L0313_Load
  DW L0313_Init
  DW L0313_Check
  DW L0313_Map

dialog:
intercom_gtx:
  INCBIN "Data/Dialog/Intro/intercom.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0313_Load:
        DW ((L0313_LoadFinished - L0313_Load2))  ;size
L0313_Load2:
        call    ParseMap
        ret

L0313_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0313_Map:
INCBIN "Data/Levels/L0313_intro_ba4.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
VAR_LIGHT   EQU 00
LIGHT_INDEX EQU 44

STATE_INITIALDRAW  EQU 1
STATE_INIT         EQU 2
STATE_NORMAL       EQU 3

L0313_Init:
        DW ((L0313_InitFinished - L0313_Init2))  ;size
L0313_Init2:
        call    State0To1

        ld      hl,$0313
        call    SetJoinMap

        ld      hl,$0313
        call    SetRespawnMap

        call    SetPressBDialog
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,STATE_INITIALDRAW
        ldio    [mapState],a

        xor     a
        ld      [musicEnabled],a

        ;ld      a,STATE_INITIALDRAW
        ;ldio    [mapState],a

        ld      a,[bgTileMap + LIGHT_INDEX]
        ld      [levelVars+VAR_LIGHT],a

        ;adjust palette 7 for text box
        ld      a,FADEBANK
        ldio    [$ff70],a
        ld      hl,gamePalette + 58
        xor     a
        ld      [hl+],a
        ld      a,$02
        ld      [hl+],a
        ld      a,$f0
        ld      [hl+],a
        ld      a,$43
        ld      [hl+],a

        ret

L0313_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0313_Check:
        DW ((L0313_CheckFinished - L0313_Check2))  ;size
L0313_Check2:
        ldio    a,[mapState]

        cp      STATE_INITIALDRAW
        jr      nz,.checkInit

        ld      a,STATE_INIT
        ldio    [mapState],a
        ret

.checkInit
        cp      STATE_INIT
        jr      nz,.checkStateNormal

        ;just loaded level
        call    GfxShowStandardTextBox
        ld      a,20
        call    Delay

        ;adjust palette 7 for text box to black
        ld      a,FADEBANK
        ldio    [$ff70],a
        ld      hl,gamePalette + 58
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        ld      a,120
        call    SetupFadeToGamePalette
        ld      de,((.afterBAQuartersText-L0313_Check2)+levelCheckRAM)
        call    SetDialogForward
        ld      de,((.afterShowAlarmText-L0313_Check2)+levelCheckRAM)
        call    SetDialogSkip
        call    WaitFade
        call    ClearDialog

.afterBAQuartersText
        ld      de,((.afterShowAlarmText-L0313_Check2)+levelCheckRAM)
        call    SetDialogForward

        call    SetSpeakerToFirstHero
        ld      a,BANK(intercom_gtx)
        ld      c,0
        ld      de,intercom_gtx
        call    ShowDialogAtTop

.afterShowAlarmText
        ld      de,0
        call    SetDialogSkip
        call    SetDialogForward
        call    ClearDialog

        ld      a,10
        call    Delay

        call    ((.alterGamePalette - L0313_Check2) + levelCheckRAM)
        ld      hl,musicEnabled
        res     3,[hl]
        ld      a,STATE_NORMAL
        ldio    [mapState],a

        call    MakeNonIdle

.checkStateNormal
        ;make the light flash
        ld      hl,levelVars+VAR_LIGHT
        ldio    a,[updateTimer]
        rrca
        rrca
        and     %11
        push    af
        add     [hl]
        ld      [bgTileMap+LIGHT_INDEX],a
        pop     af
        cp      3
        jr      nz,.afterRedFlash

        ld      a,30
        call    SetupFadeToBlack

        ld      a,[updateTimer]
        bit     4,a
        jr      z,.afterRedFlash
        ld      hl,((.klaxonSound - L0313_Check2) + levelCheckRAM)
        call    PlaySound

.afterRedFlash
        ret

.klaxonSound
        DB      4,$00,$f7,$5a,$c0

.alterGamePalette
        ;alter game palette to halve green and blue
        ld      a,FADEBANK
        ldio    [$ff70],a

        ld      hl,gamePalette+2
        ld      d,64
.halveGB
        ld      a,[hl+]
        ld      c,a
        ld      a,[hl-]
        ld      b,a
        call    GetRedComponent   ;highest component so far
        ld      e,a
        call    GetGreenComponent
        cp      e
        jr      c,.afterGreenHighestCheck
        ld      e,a
.afterGreenHighestCheck
        srl     a
        srl     a
        call    SetGreenComponent
        call    GetBlueComponent
        cp      e
        jr      c,.afterBlueHighestCheck
        ld      e,a
.afterBlueHighestCheck
        srl     a
        srl     a
        call    SetBlueComponent
        ld      a,e
        call    SetRedComponent 
        ld      a,c
        ld      [hl+],a
        ld      a,b
        ld      [hl+],a

        dec     d
        jr      nz,.halveGB

        ret

L0313_CheckFinished:
PRINTT "0313 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0313_LoadFinished - L0313_Load2)
PRINTT " / "
PRINTV (L0313_InitFinished - L0313_Init2)
PRINTT " / "
PRINTV (L0313_CheckFinished - L0313_Check2)
PRINTT "\n"

