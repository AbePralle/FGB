; L1103.asm wedding / gyro pops from tree
; Generated 08.03.2000 by mlevel
; Modified  08.03.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;from L0505
VAR_HERO EQU 11



;---------------------------------------------------------------------
SECTION "Level1103Gfx1",ROMX
;---------------------------------------------------------------------
gyro_tree_bg:
  INCBIN "Data/Cinema/Wedding/gyro_tree.bg"

gyro_costume_sp:
  INCBIN "Data/Cinema/Wedding/gyro_costume.sp"

gang_watches_wedding_bg:
  INCBIN "Data/Cinema/Wedding/gang_watches_wedding.bg"

;---------------------------------------------------------------------
SECTION "Level1103Gfx2",ROMX
;---------------------------------------------------------------------
preacher_bg:
  INCBIN "Data/Cinema/Wedding/preacher.bg"

wedding_panoramic_bg:
  INCBIN "Data/Cinema/Wedding/wedding_panoramic.bg"

flour_at_wedding_bg:
  INCBIN "Data/Cinema/Wedding/flour_at_wedding.bg"

;---------------------------------------------------------------------
SECTION "Level1103Gfx3",ROMX
;---------------------------------------------------------------------
flower_at_wedding_bg:
  INCBIN "Data/Cinema/Wedding/flower_at_wedding.bg"

gang_watches_front_bg::
  INCBIN "Data/Cinema/Wedding/gang_watches_front.bg"

gyro_big_bg:
  INCBIN "Data/Cinema/Wedding/gyro_big.bg"

;---------------------------------------------------------------------
SECTION "Level1103Dialog",ROMX
;---------------------------------------------------------------------

dialog:
preacher_blah_gtx:
  INCBIN "Data/Dialog/Wedding/preacher_blah.gtx"

preacher_reasons_gtx:
  INCBIN "Data/Dialog/Wedding/preacher_reasons.gtx"

hero_reasons_gtx:
  INCBIN "Data/Dialog/Wedding/hero_reasons.gtx"

captain_thanks_gtx:
  INCBIN "Data/Dialog/Wedding/captain_thanks.gtx"

captain_cake_gtx:
  INCBIN "Data/Dialog/Wedding/captain_cake.gtx"

lady_byallmeans_gtx:
  INCBIN "Data/Dialog/Wedding/lady_byallmeans.gtx"

lady_radio_gtx:
  INCBIN "Data/Dialog/Wedding/lady_radio.gtx"

preacher_takebegonia_gtx:
  INCBIN "Data/Dialog/Wedding/preacher_takebegonia.gtx"

gyro_bs_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_bs.gtx"

preacher_takesack_gtx:
  INCBIN "Data/Dialog/Wedding/preacher_takesack.gtx"

gyro_ba_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_ba.gtx"

preacher_pronounce_gtx:
  INCBIN "Data/Dialog/Wedding/preacher_pronounce.gtx"

gyro_haiku_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_haiku.gtx"

preacher_married_gtx:
  INCBIN "Data/Dialog/Wedding/preacher_married.gtx"

gyro_notsofast_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_notsofast.gtx"

captain_why_gtx:
  INCBIN "Data/Dialog/Wedding/captain_why.gtx"

gyro_reveals_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_reveals.gtx"

captain_thankyou_gtx:
  INCBIN "Data/Dialog/Wedding/captain_thankyou.gtx"

gyro_notyummy_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_notyummy.gtx"

gyro_recall_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_recall.gtx"

gyro_surrender_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_surrender.gtx"

gyro_difficult_gtx:
  INCBIN "Data/Dialog/Wedding/gyro_difficult.gtx"

captain_okay_gtx:
  INCBIN "Data/Dialog/Wedding/captain_okay.gtx"

lady_dontbesilly_gtx:
  INCBIN "Data/Dialog/Wedding/lady_dontbesilly.gtx"


;---------------------------------------------------------------------
SECTION "Level1103Section",ROMX
;---------------------------------------------------------------------

L1103_Contents::
  DW L1103_Load
  DW L1103_Init
  DW L1103_Check
  DW L1103_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1103_Load:
        DW ((L1103_LoadFinished - L1103_Load2))  ;size
L1103_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,BANK(wedding_panoramic_bg)
        ld      hl,wedding_panoramic_bg
        call    LoadCinemaBG

        ld      a,EXIT_D
        ld      hl,$1103
        call    YankRemotePlayer

        ;set state of 0505 in case I was yanked from elsewhere
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,2       ;STATE_AFTERWEDDING
        ld      [levelState+$55],a

        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a

        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.endCinema-L1103_Load2)+levelCheckRAM)
        call    SetDialogSkip
        ld      de,((.preacher_blah-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward


        ld      a,BANK(wedding_panoramic_bg)

        ld      a,80
        call    Delay

.preacher_blah
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)

        ld      a,BANK(preacher_bg)
        ld      hl,preacher_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      de,((.preacher_reasons-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM preacher_blah_gtx

        ld      d,3
        LONGCALLNOARGS AnimatePreacher

.preacher_reasons
        ld      c,0
        DIALOGBOTTOM preacher_reasons_gtx

        ld      de,((.hero_reasons-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimatePreacher

.hero_reasons
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog
        ld      de,((.captainThanks-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      a,[levelVars+VAR_HERO]
        ld      [dialogSpeakerIndex],a
        cp      HERO_BS_FLAG
        jr      z,.hero_bs

        cp      HERO_HAIKU_FLAG
        jr      z,.hero_haiku

.hero_ba
        ld      a,BANK(ba_bg)
        ld      hl,ba_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM hero_reasons_gtx
        ld      d,4
        LONGCALLNOARGS    AnimateBA
        jr      .captainThanks

.hero_bs
        ld      a,BANK(bs_bg)
        ld      hl,bs_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM hero_reasons_gtx
        ld      d,4
        LONGCALLNOARGS    AnimateBS
        jr      .captainThanks

.hero_haiku
        ld      a,BANK(haiku_bg)
        ld      hl,haiku_bg
        call    LoadCinemaBG
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM hero_reasons_gtx
        LONGCALLNOARGS    AnimateHaiku

.captainThanks
        call    ((.loadCaptain-L1103_Load2)+levelCheckRAM)

        ld      de,((.captainCake-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_thanks_gtx
        ld      d,4
        LONGCALLNOARGS AnimateCaptainAtWedding

.captainCake
        ld      c,0
        DIALOGBOTTOM   captain_cake_gtx
        ld      de,((.lady_byallmeans-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateCaptainAtWedding

.lady_byallmeans
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog

        ld      a,BANK(flower_at_wedding_bg)
        ld      hl,flower_at_wedding_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM lady_byallmeans_gtx

        ld      de,((.lady_radio-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateLadyAtWedding

.lady_radio
        ld      c,0
        DIALOGBOTTOM lady_radio_gtx
        ld      de,((.minutesLater-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      d,4
        LONGCALLNOARGS AnimateLadyAtWedding

.minutesLater
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog

        ld      a,BANK(gang_watches_front_bg)
        ld      hl,gang_watches_front_bg
        call    LoadCinemaBG

        ld      de,((.preacherTakeBegonia-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      a,90
        call    Delay

.preacherTakeBegonia
        ld      hl,$0704
        call    ((.loadGang-L1103_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM preacher_takebegonia_gtx

        ld      de,((.gyro_bs-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,150
        call    Delay

.gyro_bs
        call    ((.gyroPopOut-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM gyro_bs_gtx

        ld      de,((.takeCaptain-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,11
        call    ((.animateGyroSprite-L1103_Load2)+levelCheckRAM)

.takeCaptain
        ld      hl,$1400
        call    ((.loadGang-L1103_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM preacher_takesack_gtx

        ld      de,((.gyro_ba-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,150
        call    Delay

.gyro_ba
        call    ((.gyroPopOut-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM gyro_ba_gtx

        ld      de,((.pronounce-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,11
        call    ((.animateGyroSprite-L1103_Load2)+levelCheckRAM)

.pronounce
        ld      hl,$1406
        call    ((.loadGang-L1103_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM preacher_pronounce_gtx

        ld      de,((.gyro_haiku-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,150
        call    Delay

.gyro_haiku
        call    ((.gyroPopOut-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM gyro_haiku_gtx

        ld      de,((.married-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,11
        call    ((.animateGyroSprite-L1103_Load2)+levelCheckRAM)

.married
        ld      hl,$140c
        call    ((.loadGang-L1103_Load2)+levelCheckRAM)
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM preacher_married_gtx

        ld      de,((.notSoFast-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,150
        call    Delay

.notSoFast
        call    ((.setupGyroSpritesInOpen-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM gyro_notsofast_gtx

        ld      de,((.captainWhyNot-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,5
        call    ((.animateGyroSprite-L1103_Load2)+levelCheckRAM)

.captainWhyNot
        call    ((.loadCaptain-L1103_Load2)+levelCheckRAM)

        ld      de,((.because-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_why_gtx
        ld      d,2
        LONGCALLNOARGS AnimateCaptainAtWedding

.because
        call    ((.setupGyroSpritesInOpen-L1103_Load2)+levelCheckRAM)
        ld      a,30
        call    Delay

        call    ((.shedCostume-L1103_Load2)+levelCheckRAM)
        ld      c,0
        DIALOGBOTTOM gyro_reveals_gtx

        ld      de,((.captainThankYou-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,11
        call    ((.animateGyroSprite-L1103_Load2)+levelCheckRAM)

.captainThankYou
        call    ((.loadCaptain-L1103_Load2)+levelCheckRAM)

        ld      de,((.notYummy-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_thankyou_gtx
        ld      d,3
        LONGCALLNOARGS AnimateCaptainAtWedding

.notYummy
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog

        ld      a,BANK(gyro_big_bg)
        ld      hl,gyro_big_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM gyro_notyummy_gtx

        ld      de,((.recall-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateGyroAtWedding

.recall
        ld      c,0
        DIALOGBOTTOM gyro_recall_gtx

        ld      de,((.surrender-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateGyroAtWedding

.surrender
        ld      c,0
        DIALOGBOTTOM gyro_surrender_gtx

        ld      de,((.difficult-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateGyroAtWedding

.difficult
        ld      c,0
        DIALOGBOTTOM gyro_difficult_gtx

        ld      de,((.captainOkay-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateGyroAtWedding

.captainOkay
        call    ((.loadCaptain-L1103_Load2)+levelCheckRAM)

        ld      de,((.ladyDontBeSilly-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_okay_gtx
        ld      d,3
        LONGCALLNOARGS AnimateCaptainAtWedding

.ladyDontBeSilly
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog

        ld      a,BANK(flower_at_wedding_bg)
        ld      hl,flower_at_wedding_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      c,0
        DIALOGBOTTOM lady_dontbesilly_gtx

        ld      de,((.endCinema-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      d,4
        LONGCALLNOARGS AnimateLadyAtWedding

.endCinema

        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)

        ld      hl,2400  ;captain flour
        ld      a,l
        ld      [hero0_class],a
        ld      a,h
        ld      [hero0_class+1],a
        ld      a,HERO_FLOUR_FLAG
        ld      [hero0_type],a

        ld      hl,2398   ;haiku
        ld      a,l
        ld      [hero1_class],a
        ld      a,h
        ld      [hero1_class+1],a
        ld      a,HERO_FLOWER_FLAG
        ld      [hero1_type],a

        ld      a,EXIT_S
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$0604
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.shedCostume
        ld      b,30
.shedCostumeLoop
        ;move sprites 12-29 3 pixels right and 1 down
        ld      c,18
        ld      de,3
        ld      hl,spriteOAMBuffer+12*4
.shedCostumeSpriteLoop
        inc     [hl]
        inc     hl
        inc     [hl]
        inc     [hl]
        inc     [hl]
        add     hl,de
        dec     c
        jr      nz,.shedCostumeSpriteLoop

        ld      a,1
        call    Delay
        dec     b
        jr      nz,.shedCostumeLoop
        ret

.loadCaptain
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog
        call    ResetSprites

        ld      a,BANK(flour_at_wedding_bg)
        ld      hl,flour_at_wedding_bg
        call    LoadCinemaBG

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)
        ret

.setupGyroSpritesInOpen
        call    ((.prepGyroSprites-L1103_Load2)+levelCheckRAM)
        ld      d,$4c
        call    ScrollSpritesRight
        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)
        ret

.animateGyroSprite
        ;ld      c,11
.animateGyroSpriteLoop
        ld      b,8
        call    ((.shiftSpritePatterns-L1103_Load2)+levelCheckRAM)
        ld      a,5
        call    Delay
        ld      b,-8
        call    ((.shiftSpritePatterns-L1103_Load2)+levelCheckRAM)
        ld      a,5
        call    Delay
        dec     c
        jr      nz,.animateGyroSpriteLoop

        ld      a,50
        call    Delay
        ret
        
.shiftSpritePatterns
        push    bc
        ld      hl,spriteOAMBuffer+4*4+2
        ld      de,4
        ld      c,4
.shiftSpriteLoop
        ld      a,[hl]
        add     b
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.shiftSpriteLoop
        pop     bc
        ret

.loadGang
        push    hl
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ClearDialog
        call    ResetSprites

        ld      a,BANK(gang_watches_wedding_bg)
        ld      hl,gang_watches_wedding_bg
        call    LoadCinemaBG
        pop     hl

        ld      bc,$0d06
        ld      de,$0704
        call    CinemaBlitRect
        ret

.gyroPopOut
        call    ((.prepGyroSprites-L1103_Load2)+levelCheckRAM)

        call    ((.quickFromBlack-L1103_Load2)+levelCheckRAM)

        ld      de,((.poppedOut-L1103_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,30
        call    Delay

        ld      c,48
.popOutLoop
        ld      d,1
        call    ScrollSpritesRight
        ld      a,2
        call    Delay
        dec     c
        jr      nz,.popOutLoop

.poppedOut
        ld      de,0
        call    SetDialogForward

        ld      a,[spriteOAMBuffer+1]   ;1st sprite xpos should be $4c
        cpl
        add     $4d
        ld      d,a
        call    ScrollSpritesRight

        ret

.prepGyroSprites
        call    ((.quickToBlack-L1103_Load2)+levelCheckRAM)
        call    ResetSprites
        ld      a,BANK(gyro_tree_bg)
        ld      hl,gyro_tree_bg
        call    LoadCinemaBG

        ld      a,BANK(gyro_costume_sp)
        ld      hl,gyro_costume_sp
        call    LoadCinemaSprite

        ;kill sprites 8-11  (alternate mouth)
        ld      hl,spriteOAMBuffer + 4 * 8
        xor     a
        ld      de,3
        ld      c,4
.kill8to11
        ld      [hl+],a  ;sprite 8 y pos to zero
        add     hl,de
        dec     c
        jr      nz,.kill8to11

        ;move sprites 12-29 40 pixels up and 8 pixels left
        ld      c,18
.scootCostume
        ld      a,[hl]
        sub     40
        ld      [hl+],a
        ld      a,[hl]
        sub     8
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.scootCostume

        ld      d,20
        call    ScrollSpritesRight
        ld      d,40
        call    ScrollSpritesDown

        ;set the priority of all sprites to appear behind BG
        ld      hl,spriteOAMBuffer + 3
        ld      de,3
        ld      c,40
.setPriorityLoop
        ld      a,[hl]
        or      %10000000
        ld      [hl+],a
        add     hl,de
        dec     c
        jr      nz,.setPriorityLoop

        ret


.quickToBlack
        call    BlackoutPalette
        call    ClearDialog
        jp      ResetSprites

.quickFromBlack
        ld      a,1
        jp      SetupFadeFromBlack

L1103_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1103_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1103_Init:
        DW ((L1103_InitFinished - L1103_Init2))  ;size
L1103_Init2:
        ret

L1103_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1103_Check:
        DW ((L1103_CheckFinished - L1103_Check2))  ;size
L1103_Check2:
        ret

L1103_CheckFinished:
PRINTT "1103 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1103_LoadFinished - L1103_Load2)
PRINTT " / "
PRINTV (L1103_InitFinished - L1103_Init2)
PRINTT " / "
PRINTV (L1103_CheckFinished - L1103_Check2)
PRINTT "\n"

