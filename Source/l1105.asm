; L1105.asm Save game screen
; Generated 05.09.2001 by mlevel
; Modified  05.09.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

VAR_SELECTION EQU 0

;---------------------------------------------------------------------
SECTION "Level1105Gfx1",ROMX
;---------------------------------------------------------------------
savegame_bg:
  INCBIN "../fgbpix/Appomattox/savegame.bg"

cantsave_bg:
  INCBIN "../fgbpix/Appomattox/cantsave.bg"

;---------------------------------------------------------------------
SECTION "Level1105Gfx2",ROMX
;---------------------------------------------------------------------
cantsave_flying_bg:
  INCBIN "../fgbpix/Appomattox/cantsave_flying.bg"

;---------------------------------------------------------------------
SECTION "Level1105Section",ROMX
;---------------------------------------------------------------------

L1105_Contents::
  DW L1105_Load
  DW L1105_Init
  DW L1105_Check
  DW L1105_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1105_Load:
        DW ((L1105_LoadFinished - L1105_Load2))  ;size
L1105_Load2:
        ld      a,[amLinkMaster]
        or      a
        jp      z,((.amSlave-L1105_Load2)+levelCheckRAM)

        ld      a,[appomattoxMapIndex]
        or      a
        jp      z,((.amFlying-L1105_Load2)+levelCheckRAM)

        ld      a,BANK(savegame_bg)
        ld      hl,savegame_bg
        call    LoadCinemaBG

        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade

        xor     a
        ld      [levelVars+VAR_SELECTION],a
.waitSelection
        call    ((.blitCurSelection-L1105_Load2)+levelCheckRAM)

        ld      a,1
        call    Delay

        ld      a,[myJoy]
        bit     JOY_UP_BIT,a
        jr      z,.checkDown

        xor     a
        ld      [levelVars+VAR_SELECTION],a
        jr      .checkDone

.checkDown
        bit     JOY_DOWN_BIT,a
        jr      z,.checkDone

        ld      a,1
        ld      [levelVars+VAR_SELECTION],a

.checkDone
        ld      a,[myJoy]
        bit     JOY_A_BIT,a
        jr      z,.waitSelection

        ld      a,[levelVars+VAR_SELECTION]
        or      a
        call    z,((.saveGame-L1105_Load2)+levelCheckRAM)

        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,EXIT_S
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$1300
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.saveGame
        ld      a,$0a       ;enable save ram access
        ld      [0],a

        ld      hl,$a000    ;start of save area $a000-$bfff
        ld      de,gameState
        ld      bc,9
        xor     a
        call    ((.saveData-L1105_Load2)+levelCheckRAM)

        ld      de,inventory
        ld      bc,16
        xor     a
        call    ((.saveData-L1105_Load2)+levelCheckRAM)

        ld      de,levelState
        ld      bc,256
        ld      a,LEVELSTATEBANK
        call    ((.saveData-L1105_Load2)+levelCheckRAM)

        ld      de,flightCode
        ld      bc,256
        ld      a,FLIGHTCODEBANK
        call    ((.saveData-L1105_Load2)+levelCheckRAM)

        xor     a
        ld      [0],a       ;disable save ram to prevent false writes on powerdown

        ;blit "saved"
        ld      bc,$0a06
        ld      de,$0509
        ld      hl,$1412
        call    CinemaBlitRect
        ld      a,15
        call    Delay
        ret

.saveData
        ;copies "bc" # of bytes from [de] to [hl] in bank "a"
        ldio    [$ff70],a
.saveLoop
        ld      a,[de]
        inc     de
        ld      [hl+],a
        dec     bc
        xor     a
        cp      b
        jr      nz,.saveLoop
        cp      c
        jr      nz,.saveLoop
        ret

.blitCurSelection
        ldio    a,[updateTimer]
        and     %1000
        jr      z,.blitAppropriateCursor

        ;blit empty space
        ld      bc,$0a06
        ld      de,$0509
        ld      hl,$1400
        call    CinemaBlitRect
        ret

.blitAppropriateCursor
        ld      a,[levelVars+VAR_SELECTION]   ;selection * 6 + 6
        rlca
        ld      b,a
        rlca
        add     b
        add     6
        ld      l,a
        ld      h,$14
        ld      bc,$0a06
        ld      de,$0509
        call    CinemaBlitRect
        ret

.amFlying
        ld      a,BANK(cantsave_flying_bg)
        ld      hl,cantsave_flying_bg
        call    LoadCinemaBG
        jr      .showReason

.amSlave
        ld      a,BANK(cantsave_bg)
        ld      hl,cantsave_bg
        call    LoadCinemaBG

.showReason
        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.returnToShip-L1105_Load2)+levelCheckRAM)
        call    SetDialogForward
        call    SetDialogSkip

        ld      a,150
        call    Delay

.returnToShip
        call    ClearDialogSkipForward

        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,EXIT_S
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$1300
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

L1105_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1105_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1105_Init:
        DW ((L1105_InitFinished - L1105_Init2))  ;size
L1105_Init2:
        ret

L1105_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1105_Check:
        DW ((L1105_CheckFinished - L1105_Check2))  ;size
L1105_Check2:
        ret

L1105_CheckFinished:
PRINTT "1105 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1105_LoadFinished - L1105_Load2)
PRINTT " / "
PRINTV (L1105_InitFinished - L1105_Init2)
PRINTT " / "
PRINTV (L1105_CheckFinished - L1105_Check2)
PRINTT "\n"

