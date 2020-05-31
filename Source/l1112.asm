; l1112.asm duke's disco
; Generated 04.10.2001 by mlevel
; Modified  04.10.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

DISCOBALL_INDEX      EQU 29
REDDANCER_INDEX      EQU 45
BLUEDANCER_INDEX     EQU 47
REDDANCER_2X1_INDEX  EQU 49
BLUEDANCER_2X1_INDEX EQU 53
REDDANCER_1X2_INDEX  EQU 57
BLUEDANCER_1X2_INDEX EQU 61

REDOBJ_INDEX         EQU 65
BLUEOBJ_INDEX        EQU 66
ORANGEOBJ_INDEX      EQU 67

VAR_LIGHTFRAME       EQU  0
VAR_BGKILLED         EQU  15

STATE_NORMAL         EQU  1
STATE_AVERTED        EQU  2


;---------------------------------------------------------------------
SECTION "Level1112Gfx1",DATA
;---------------------------------------------------------------------
success_bg:
  INCBIN "..\\fgbpix\\disco\\success.bg"

party_over_bg:
  INCBIN "..\\fgbpix\\disco\\party_over.bg"

;---------------------------------------------------------------------
SECTION "Level1112Section",DATA
;---------------------------------------------------------------------

L1112_Contents::
  DW L1112_Load
  DW L1112_Init
  DW L1112_Check
  DW L1112_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1112_Load:
        DW ((L1112_LoadFinished - L1112_Load2))  ;size
L1112_Load2:
        call    ParseMap
        ret

L1112_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1112_Map:
INCBIN "..\\fgbeditor\\l1112_disco.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1112_Init:
        DW ((L1112_InitFinished - L1112_Init2))  ;size
L1112_Init2:
        ;change palette 7's BG color to black
        ld      a,FADEBANK
        ldio    [$ff70],a
        ld      hl,gamePalette+8*7
        xor     a
        ld      [hl+],a
        ld      [hl+],a

        xor     a 
        ld      [levelVars+VAR_LIGHTFRAME],a
        ld      [levelVars+VAR_BGKILLED],a

        ld      a,ENV_DISCO
        ld      [envEffectType],a

        call    State0To1
        ret

L1112_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1112_Check:
        DW ((L1112_CheckFinished - L1112_Check2))  ;size
L1112_Check2:
        call    ((.animateBG-L1112_Check2)+levelCheckRAM)
        call    ((.checkPartyOver-L1112_Check2)+levelCheckRAM)
        ret

.checkPartyOver
        ld      c,REDOBJ_INDEX
        call    GetNumObjects
        cp      8
        jr      nz,.partyOver

        ld      c,BLUEOBJ_INDEX
        call    GetNumObjects
        cp      12
        jr      nz,.partyOver

        ld      a,[levelVars+VAR_BGKILLED]
        or      a
        jr      nz,.partyOver

        ld      c,ORANGEOBJ_INDEX
        call    GetNumObjects
        or      a
        ret     nz

        ;success
        ld      a,STATE_AVERTED
        ldio    [mapState],a

        ;we leave on a cinema so need to update state manually
        call    UpdateState

        ;yank player even if he's on the homeworld already
        ld      a,(EXIT_W | 8)
        ld      hl,$0912
        call    YankRemotePlayer

        ld      a,30
        call    Delay

        ld      a,15
        call    SetupFadeToBlack
        call    WaitFade
        call    ResetSprites

        ld      a,BANK(success_bg)
        ld      hl,success_bg
        call    LoadCinemaBG
        jr      .exitDisco

.partyOver
        ld      a,30
        call    Delay

        ld      a,15
        call    SetupFadeToBlack
        call    WaitFade
        call    ResetSprites

        ld      a,BANK(party_over_bg)
        ld      hl,party_over_bg
        call    LoadCinemaBG

.exitDisco
        xor     a
        ld      [envEffectType],a

        ld      a,15
        call    SetupFadeFromBlack
        call    WaitFade

        ld      c,90
.waitInputLoop
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %11110000
        jr      nz,.continueExit
        dec     c
        jr      nz,.waitInputLoop

.continueExit
        call    BlackoutPalette

        ld      a,EXIT_W
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$0912
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.animateBG
        ld      a,TILEINDEXBANK
				ld      [$ff70],a

        call    ((.animateDiscoBall-L1112_Check2)+levelCheckRAM)
        call    ((.animateDancer1-L1112_Check2)+levelCheckRAM)
        call    ((.animateDancer2-L1112_Check2)+levelCheckRAM)
        call    ((.animateDancer3-L1112_Check2)+levelCheckRAM)
        call    ((.animateDancer4-L1112_Check2)+levelCheckRAM)
        call    ((.animateDancer5-L1112_Check2)+levelCheckRAM)
        call    ((.animateDancer6-L1112_Check2)+levelCheckRAM)
        ret

.animateDiscoBall
        ldio    a,[updateTimer]
        and     %11
        ret     nz

				ld      hl,bgTileMap+DISCOBALL_INDEX
        ld      b,DISCOBALL_INDEX
        call    ((.incDiscoFrame-L1112_Check2)+levelCheckRAM)
        call    ((.incDiscoFrame-L1112_Check2)+levelCheckRAM)
        call    ((.incDiscoFrame-L1112_Check2)+levelCheckRAM)
        call    ((.incDiscoFrame-L1112_Check2)+levelCheckRAM)

        ld      hl,levelVars+VAR_LIGHTFRAME
        ld      a,[hl]
        inc     a
        and     7
        ld      [hl],a
        ret

.incDiscoFrame
				ld      a,[hl]
				sub     b
        add     4
				and     %1100
				add     b
				ld      [hl+],a
        inc     b
        ret

.animateDancer1
        ldio    a,[updateTimer]
        and     %111
        ret     nz

				ld      hl,bgTileMap+REDDANCER_INDEX
        ld      b,REDDANCER_INDEX
        call    ((.inc1-L1112_Check2)+levelCheckRAM)
        ret
.animateDancer2
        ldio    a,[updateTimer]
        inc     a
        and     %11
        ret     nz

				ld      hl,bgTileMap+BLUEDANCER_INDEX
        ld      b,BLUEDANCER_INDEX
        call    ((.inc1-L1112_Check2)+levelCheckRAM)
        ret

.animateDancer3
        ldio    a,[updateTimer]
        and     %111
        ret     nz

				ld      hl,bgTileMap+REDDANCER_2X1_INDEX
        ld      b,REDDANCER_2X1_INDEX
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        ret

.animateDancer4
        ldio    a,[updateTimer]
        inc     a
        and     %11
        ret     nz

				ld      hl,bgTileMap+BLUEDANCER_2X1_INDEX
        ld      b,BLUEDANCER_2X1_INDEX
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        ret

.animateDancer5
        ldio    a,[updateTimer]
        add     3
        and     %11
        ret     nz

				ld      hl,bgTileMap+REDDANCER_1X2_INDEX
        ld      b,REDDANCER_1X2_INDEX
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        ret

.animateDancer6
        ldio    a,[updateTimer]
        add     3
        and     %11
        ret     nz

				ld      hl,bgTileMap+BLUEDANCER_1X2_INDEX
        ld      b,BLUEDANCER_1X2_INDEX
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        call    ((.inc2-L1112_Check2)+levelCheckRAM)
        ret

.inc1
				ld      a,[hl]
				sub     b
        inc     a
				and     %1
				add     b
				ld      [hl+],a
        ret

.inc2
				ld      a,[hl]
				sub     b
        add     2
				and     %10
				add     b
				ld      [hl+],a
        inc     b
        ret

L1112_CheckFinished:
PRINTT "1112 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1112_LoadFinished - L1112_Load2)
PRINTT " / "
PRINTV (L1112_InitFinished - L1112_Init2)
PRINTT " / "
PRINTV (L1112_CheckFinished - L1112_Check2)
PRINTT "\n"

