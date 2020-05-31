; l1304.asm
; Generated 05.08.2001 by mlevel
; Modified  05.08.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level1304Gfx",DATA
;---------------------------------------------------------------------
backinside_bg:
  INCBIN "..\\fgbpix\\charselect\\backinside.bg"

;---------------------------------------------------------------------
SECTION "Level1304Section",DATA
;---------------------------------------------------------------------

L1304_Contents::
  DW L1304_Load
  DW L1304_Init
  DW L1304_Check
  DW L1304_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1304_Load:
        DW ((L1304_LoadFinished - L1304_Load2))  ;size
L1304_Load2:
        ld      a,BANK(backinside_bg)
        ld      hl,backinside_bg
        call    LoadCinemaBG

        ld      a,15
        call    SetupFadeFromStandard
        call    WaitFade

        ld      de,((.returnToShip-L1304_Load2)+levelCheckRAM)
        call    SetDialogForward
        call    SetDialogSkip

        ld      a,150
        call    Delay

.returnToShip
        call    ClearDialogSkipForward

        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,EXIT_D
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

L1304_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1304_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1304_Init:
        DW ((L1304_InitFinished - L1304_Init2))  ;size
L1304_Init2:
        ret

L1304_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1304_Check:
        DW ((L1304_CheckFinished - L1304_Check2))  ;size
L1304_Check2:
        ret

L1304_CheckFinished:
PRINTT "1304 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1304_LoadFinished - L1304_Load2)
PRINTT " / "
PRINTV (L1304_InitFinished - L1304_Init2)
PRINTT " / "
PRINTV (L1304_CheckFinished - L1304_Check2)
PRINTT "\n"

