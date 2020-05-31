; l1203.asm Rescue From The Tower Cinema
; Generated 03.31.2001 by mlevel
; Modified  03.31.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"


;---------------------------------------------------------------------
SECTION "Level1203Gfx1",ROMX
;---------------------------------------------------------------------
in_prison_bg:
  INCBIN "..\\fgbpix\\wedding\\in_prison.bg"

bs_driving_bg:
  INCBIN "..\\fgbpix\\wedding\\bs_driving.bg"

;---------------------------------------------------------------------
SECTION "Level1203Section",ROMX
;---------------------------------------------------------------------

dialog:
flour_heyguys_gtx:
  INCBIN "gtx\\wedding\\flour_heyguys.gtx"

bs_explain_gtx:
  INCBIN "gtx\\wedding\\bs_explain.gtx"

bs_explain2_gtx:
  INCBIN "gtx\\wedding\\bs_explain2.gtx"

captain_interrupt_gtx:
  INCBIN "gtx\\wedding\\captain_interrupt.gtx"

captain_tellyouwhat_gtx:
  INCBIN "gtx\\wedding\\captain_tellyouwhat.gtx"

captain_key_gtx:
  INCBIN "gtx\\wedding\\captain_key.gtx"

captain_dosomething_gtx:
  INCBIN "gtx\\wedding\\captain_dosomething.gtx"

captain_camp_gtx:
  INCBIN "gtx\\wedding\\captain_camp.gtx"

bs_driving_gtx:
  INCBIN "gtx\\wedding\\bs_driving.gtx"

bs_palace_gtx:
  INCBIN "gtx\\wedding\\bs_palace.gtx"


L1203_Contents::
  DW L1203_Load
  DW L1203_Init
  DW L1203_Check
  DW L1203_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1203_Load:
        DW ((L1203_LoadFinished - L1203_Load2))  ;size
L1203_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,EXIT_D
        ld      hl,$1203
        call    YankRemotePlayer

        ld      bc,ITEM_APPXKEY
        call    AddInventoryItem

        ld      a,[heroesUsed]
        ld      hl,heroesAvailable
        or      [hl]
        ld      [hl],a
        xor     a
        ld      [heroesUsed],a

        ld      a,BANK(moon_base_haiku_gbm)
        ld      hl,moon_base_haiku_gbm
        call    InitMusic

        ld      a,BANK(in_prison_bg)
        ld      hl,in_prison_bg
        call    LoadCinemaBG

        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.endCinema-L1203_Load2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.doorOpen-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,60
        call    Delay

.doorOpen
        ld      bc,$0508
        ld      de,$0201
        ld      hl,$1400
        call    CinemaBlitRect

        ld      de,((.heyGuys-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,30
        call    Delay

.heyGuys
        ld      c,0
        DIALOGBOTTOM flour_heyguys_gtx

        ld      de,((.fewMinutesLater-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,150
        call    Delay

.fewMinutesLater
        call    ((.quickToBlack-L1203_Load2)+levelCheckRAM)

        ld      a,BANK(gang_watches_front_bg)
        ld      hl,gang_watches_front_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1203_Load2)+levelCheckRAM)

        ld      de,((.bsExplain-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,90
        call    Delay

.bsExplain
        call    ((.quickToBlack-L1203_Load2)+levelCheckRAM)

        ld      a,BANK(bs_bg)
        ld      hl,bs_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1203_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM bs_explain_gtx

        ld      de,((.bsExplain2-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateBS

.bsExplain2
        call    ClearDialog

        ld      c,0
        DIALOGBOTTOM bs_explain2_gtx

        ld      de,((.captainInterrupt-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateBS

.captainInterrupt
        call    ((.quickToBlack-L1203_Load2)+levelCheckRAM)

        ld      a,BANK(flour_bg)
        ld      hl,flour_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1203_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM captain_interrupt_gtx

        ld      de,((.captainTellYouWhat-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.captainTellYouWhat
        call    ClearDialog
        ld      c,0
        DIALOGBOTTOM captain_tellyouwhat_gtx

        ld      de,((.captainKey-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.captainKey
        call    ClearDialog
        ld      c,0
        DIALOGBOTTOM captain_key_gtx

        ld      de,((.captainDoSomething-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.captainDoSomething
        call    ClearDialog
        ld      c,0
        DIALOGBOTTOM captain_dosomething_gtx

        ld      de,((.captainCamp-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.captainCamp
        call    ClearDialog
        ld      c,0
        DIALOGBOTTOM captain_camp_gtx

        ld      de,((.backAtAppx-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateFlour

.backAtAppx
        call    ((.quickToBlack-L1203_Load2)+levelCheckRAM)

        ld      a,BANK(bs_driving_bg)
        ld      hl,bs_driving_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1203_Load2)+levelCheckRAM)

        ld      de,((.bsDriving-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,90
        call    Delay

.bsDriving
        ld      bc,$1406
        ld      de,$000c
        ld      hl,$1412
        call    CinemaBlitRect

        ld      a,1
        call    Delay

        ld      c,0
        DIALOGBOTTOM bs_driving_gtx

        ld      de,((.bsPalace-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateBSDriving

.bsPalace
        call    ClearDialog

        ld      c,0
        DIALOGBOTTOM bs_palace_gtx

        ld      de,((.endCinema-L1203_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateBSDriving

.endCinema
        call    ClearDialogSkipForward

        ;call    ((.quickToBlack-L1203_Load2)+levelCheckRAM)

        ld      hl,2056  ;bs
        ld      a,l
        ld      [hero0_class],a
        ld      a,h
        ld      [hero0_class+1],a
        ld      a,HERO_BS_FLAG
        ld      [hero0_type],a

        ld      hl,2058   ;haiku
        ld      a,l
        ld      [hero1_class],a
        ld      a,h
        ld      [hero1_class+1],a
        ld      a,HERO_HAIKU_FLAG
        ld      [hero1_type],a

        ld      a,EXIT_N
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$1100
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.quickToBlack
        call    BlackoutPalette
        call    ClearDialog
        jp      ResetSprites

.quickFromBlack
        ld      a,1
        jp      SetupFadeFromBlack


L1203_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1203_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1203_Init:
        DW ((L1203_InitFinished - L1203_Init2))  ;size
L1203_Init2:
        ret

L1203_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1203_Check:
        DW ((L1203_CheckFinished - L1203_Check2))  ;size
L1203_Check2:
        ret

L1203_CheckFinished:
PRINTT "1203 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1203_LoadFinished - L1203_Load2)
PRINTT " / "
PRINTV (L1203_InitFinished - L1203_Init2)
PRINTT " / "
PRINTV (L1203_CheckFinished - L1203_Check2)
PRINTT "\n"

