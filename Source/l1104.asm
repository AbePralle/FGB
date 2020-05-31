; l1104.asm To Space Station Apocalypse
; Generated 04.22.2001 by mlevel
; Modified  04.22.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

VAR_TAKEOFFPOS EQU 0

;---------------------------------------------------------------------
SECTION "Level1104Gfx1",DATA
;---------------------------------------------------------------------
appx_takeoff_bg:
  INCBIN "..\\fgbpix\\ending\\appx_takeoff.bg"

station_tactical_bg::
  INCBIN "..\\fgbpix\\ending\\station_tactical.bg"

;---------------------------------------------------------------------
SECTION "Level1104Gfx2",DATA
;---------------------------------------------------------------------
small_station_approach_bg:
  INCBIN "..\\fgbpix\\ending\\small_station_approach.bg"

big_station_approach_bg:
  INCBIN "..\\fgbpix\\ending\\big_station_approach.bg"

;---------------------------------------------------------------------
SECTION "Level1104Gfx3",DATA
;---------------------------------------------------------------------
appx_takeoff_sprites_sp:
  INCBIN "..\\fgbpix\\ending\\appx_takeoff_sprites.sp"

station_tactical_sprites_sp:
  INCBIN "..\\fgbpix\\ending\\station_tactical_sprites.sp"

small_station_sprites_sp:
  INCBIN "..\\fgbpix\\ending\\small_station_sprites.sp"

big_station_sprites_sp:
  INCBIN "..\\fgbpix\\ending\\big_station_sprites.sp"


;---------------------------------------------------------------------
SECTION "Level1104Section",DATA
;---------------------------------------------------------------------

dialog:
l1104_whereisgyro_gtx:
  INCBIN "gtx\\apocalypse\\l1104_whereisgyro.gtx"

l1104_station_gtx:
  INCBIN "gtx\\apocalypse\\l1104_station.gtx"

l1104_apocalypse_gtx:
  INCBIN "gtx\\apocalypse\\l1104_apocalypse.gtx"

l1104_letsgo_gtx:
  INCBIN "gtx\\apocalypse\\l1104_letsgo.gtx"


L1104_Contents::
  DW L1104_Load
  DW L1104_Init
  DW L1104_Check
  DW L1104_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1104_Load:
        DW ((L1104_LoadFinished - L1104_Load2))  ;size
L1104_Load2:
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,EXIT_D
        ld      hl,$1104
        call    YankRemotePlayer

        ld      a,BANK(intro_cinema_gbm)
        ld      hl,intro_cinema_gbm
        call    InitMusic

        ld      a,$b7
        ld      [appomattoxMapIndex],a

        xor     a
        ld      [levelVars+VAR_TAKEOFFPOS],a

        ;set fg tile map for first three chars to allow characters in
        ;dialog
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ld      a,$ff
        ld      hl,$d701
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ld      hl,$dd01    ;fg attributes
        ld      [hl],2      ;red
        inc     hl
        ld      [hl],3      ;blue
        inc     hl
        ld      [hl],4      ;green

        ld      de,((.endCinema-L1104_Load2)+levelCheckRAM)
        call    SetDialogSkip

        ld      a,BANK(appx_takeoff_bg)
        ld      hl,appx_takeoff_bg
        call    LoadCinemaBG

        ld      a,BANK(appx_takeoff_sprites_sp)
        ld      hl,appx_takeoff_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        ld      de,((.bs1-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward


        ld      a,15
        call    SetupFadeFromStandard

        ld      c,3
        DIALOGBOTTOM l1104_whereisgyro_gtx

        ld      a,150
        call    Delay

.bs1
        ld      de,((.bs2-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,2
        DIALOGBOTTOM l1104_station_gtx

        ld      a,150
        call    Delay

.bs2
        call    ((.quickToBlack-L1104_Load2)+levelCheckRAM)

        ld      a,BANK(station_tactical_bg)
        ld      hl,station_tactical_bg
        call    LoadCinemaBG

        ld      a,BANK(station_tactical_sprites_sp)
        ld      hl,station_tactical_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        call    ((.quickFromBlack-L1104_Load2)+levelCheckRAM)

        ld      de,((.ba-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward


        ld      c,2
        DIALOGBOTTOM l1104_apocalypse_gtx

        ;blink station id
        ld      c,15

.blink
        ld      a,10
        call    Delay

        push    bc
        ld      b,128
        ld      c,10
        call    ((.addSpriteYPos-L1104_Load2)+levelCheckRAM)
        pop     bc

        dec     c
        jr      nz,.blink
      
.ba
        call    ((.quickToBlack-L1104_Load2)+levelCheckRAM)

        ld      a,BANK(appx_takeoff_bg)
        ld      hl,appx_takeoff_bg
        call    LoadCinemaBG

        ld      a,BANK(appx_takeoff_sprites_sp)
        ld      hl,appx_takeoff_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        ld      de,((.flyAway-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward

        call    ((.quickFromBlack-L1104_Load2)+levelCheckRAM)

        ld      c,1
        DIALOGBOTTOM l1104_letsgo_gtx

        ld      a,75 
        call    Delay

        ld      b,24
        call    ((.setAppxSpriteFrame-L1104_Load2)+levelCheckRAM)

        ld      a,75 
        call    Delay

.flyAway
        call    ClearDialog

        ld      b,24
        call    ((.setAppxSpriteFrame-L1104_Load2)+levelCheckRAM)

        ld      de,((.approachSmall-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,30
.takeOff
        push    af
        call    ((.takeOffUpdate-L1104_Load2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.takeOff

        ;retract landing gear
        ld      b,48
        call    ((.setAppxSpriteFrame-L1104_Load2)+levelCheckRAM)

        ld      a,10
.takeOff2
        push    af
        call    ((.takeOffUpdate-L1104_Load2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.takeOff2

        ld      a,35
.takeOff3
        push    af
        call    ((.takeOffUpdate-L1104_Load2)+levelCheckRAM)
        call    ((.takeOffUpdateX-L1104_Load2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.takeOff3

.approachSmall
        call    ((.quickToBlack-L1104_Load2)+levelCheckRAM)

        ld      a,BANK(small_station_approach_bg)
        ld      hl,small_station_approach_bg
        call    LoadCinemaBG

        ld      a,BANK(small_station_sprites_sp)
        ld      hl,small_station_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        call    ((.quickFromBlack-L1104_Load2)+levelCheckRAM)

        ld      de,((.approachBig-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,75
.approachSmallLoop
        push    af
        call    ((.updateSmallApproach-L1104_Load2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.approachSmallLoop

        ld      a,30
.approachSmallLoop2
        push    af
        call    ((.updateSmallApproachNoThrust-L1104_Load2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.approachSmallLoop2

.approachBig
        call    ((.quickToBlack-L1104_Load2)+levelCheckRAM)

        ld      a,BANK(big_station_approach_bg)
        ld      hl,big_station_approach_bg
        call    LoadCinemaBG

        ld      a,BANK(big_station_sprites_sp)
        ld      hl,big_station_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    Delay

        call    ((.quickFromBlack-L1104_Load2)+levelCheckRAM)

        ld      de,((.endCinema-L1104_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,20
.approachBigLoop
        push    af
        call    ((.updateBigApproach-L1104_Load2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.approachBigLoop

        ld      a,60
        call    Delay

.endCinema
        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade
        ;call    ((.quickToBlack-L1104_Load2)+levelCheckRAM)
        call    ClearDialogSkipForward

        ld      a,EXIT_U
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a
        ld      a,29
        ld      [hero0_enterLevelLocation],a
        ld      [hero1_enterLevelLocation],a
        ld      a,59
        ld      [hero0_enterLevelLocation+1],a
        ld      [hero1_enterLevelLocation+1],a

        ld      hl,$1100
        call    SetJoinMap
        call    SetRespawnMap

        ld      hl,$0711
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.updateBigApproach
        ld      a,3
        call    Delay

        ld      b,$ff
        ld      c,5
        call    ((.addSpriteYPos-L1104_Load2)+levelCheckRAM)
        ld      b,$ff
        ld      c,5
        call    ((.addSpriteXPos-L1104_Load2)+levelCheckRAM)
        ret

.updateSmallApproach
        ld      a,1
        call    Delay

        ld      b,10
        call    ((.setLittleAppxSpriteFrame-L1104_Load2)+levelCheckRAM)

        ld      a,1
        call    Delay

        ld      b,6
        call    ((.setLittleAppxSpriteFrame-L1104_Load2)+levelCheckRAM)

        ld      hl,spriteOAMBuffer+3*4+1   ;x pos
        inc     [hl]
        ld      hl,spriteOAMBuffer+4*4+1   ;x pos
        inc     [hl]
        ret

.updateSmallApproachNoThrust
        ld      a,2
        call    Delay

        ld      hl,spriteOAMBuffer+3*4+1   ;x pos
        inc     [hl]
        ld      hl,spriteOAMBuffer+4*4+1   ;x pos
        inc     [hl]
        ret

.takeOffUpdateX
        ;ld      a,[levelVars+VAR_TAKEOFFPOS]
        ;cp      128
        ;jr      c,.thrustSet
        ;xor     a
;.thrustSet
        ld      b,2
        ld      c,12
        call    ((.addSpriteXPos-L1104_Load2)+levelCheckRAM)

        ldio    a,[updateTimer]
        and     %10
        jr      z,.thrustOff

        ld      b,72
        call    ((.setAppxSpriteFrame-L1104_Load2)+levelCheckRAM)
        ret

.thrustOff
        ld      b,48
        call    ((.setAppxSpriteFrame-L1104_Load2)+levelCheckRAM)
        ret

.takeOffUpdate
        ld      a,2
        call    Delay

        ld      hl,levelVars+VAR_TAKEOFFPOS
        ld      a,[hl]
        inc     [hl]
        ;and     63
        ld      hl,((.shipSineTable-L1104_Load2)+levelCheckRAM)
        call    Lookup8
        dec     a
        ld      b,a
        ld      c,12
        call    ((.addSpriteYPos-L1104_Load2)+levelCheckRAM)
        ret

.addSpriteXPos
        ld      hl,spriteOAMBuffer+1
        jr      .addSpritePos
 
.addSpriteYPos
        ;add b to ypos of all c sprites
        ld      hl,spriteOAMBuffer
.addSpritePos 
        ld      de,4
.add128Loop
        ld      a,[hl]
        add     b
        ld      [hl],a
        add     hl,de
        dec     c
        jr      nz,.add128Loop
        ret

.setLittleAppxSpriteFrame
        ld      hl,spriteOAMBuffer+3*4+2
        ld      [hl],b
        inc     b
        inc     b
        ld      hl,spriteOAMBuffer+4*4+2
        ld      [hl],b
        ret

.setAppxSpriteFrame
        ld      hl,spriteOAMBuffer+2
        ld      de,4
        ld      c,12
.setAppxSpriteFrameLoop
        ld      [hl],b
        add     hl,de
        inc     b
        inc     b
        dec     c
        jr      nz,.setAppxSpriteFrameLoop
        ret

.quickToBlack
        call    ClearDialog
        call    ResetSprites
        ld      a,1
        call    SetupFadeToBlack
        call    WaitFade
        ret

.quickFromBlack
        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade
        ret

.shipSineTable
  ;DB $ff,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
  ;DB 0,0,1,0,0,1,0,1,0,0,1,0,0,1,0,0
  ;DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$ff
  ;DB 0,0,$ff,0,0,$ff,0,0,$ff,0,$ff,0,0,$ff,0,0
  DB  0, 0, 0, 0, 0, 0, -1, -1, -2, -2, -3
  DB  -3, -3, -3, -2, -2, -2, -1, -1
  DB  0, 0, 0, 1, 1, 1, 2, 2
  DB  2, 3, 3, 3, 3, 3, 3, 3
  DB  3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0
  DB  0, -1, -1, -2, -2, -2, -3, -3, -3, -4, -4, -4, -4, -4, -4, -4
  DB  -4, -4, -4, -4, -4, -4, -4, -4

L1104_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1104_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1104_Init:
        DW ((L1104_InitFinished - L1104_Init2))  ;size
L1104_Init2:
        ret

L1104_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1104_Check:
        DW ((L1104_CheckFinished - L1104_Check2))  ;size
L1104_Check2:
        ret

L1104_CheckFinished:
PRINTT "1104 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1104_LoadFinished - L1104_Load2)
PRINTT " / "
PRINTV (L1104_InitFinished - L1104_Init2)
PRINTT " / "
PRINTV (L1104_CheckFinished - L1104_Check2)
PRINTT "\n"

