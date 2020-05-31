;level1201.asm
;Abe Pralle 6.13.2000

;called when the level the guest is going to is the same as the one
;the host is on

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "LevelsSection1201",ROMX,BANK[MAP0ROM]
;---------------------------------------------------------------------

L1201_Contents::
  DW L1201_Load
  DW L1201_Init
  DW L1201_Check
  DW L1201_Map

waiting_to_join_bg:
  INCBIN "..\\fgbpix\\menu\\waiting_to_join.bg"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1201_Load:
        DW ((L1201_LoadFinished - L1201_Load2))  ;size
L1201_Load2:
        ld      a,1
        call    SetupFadeToWhite
        call    WaitFade

        ld      a,BANK(waiting_to_join_bg)
        ld      hl,waiting_to_join_bg
        call    LoadCinemaBG

        ld      a,16
        call    SetupFadeFromStandard
        call    WaitFade

        ld      a,30
        call    Delay

        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,$02
        ld      [curLevelIndex+1],a
        ld      a,$05
        ld      [curLevelIndex],a

        ld      a,1
        ld      [timeToChangeLevel],a

        ret


L1201_LoadFinished:
;some local vars

L1201_Map:
;---------------------------------------------------------------------
L1201_Init:
;---------------------------------------------------------------------
        DW ((L1201_InitFinished - L1201_Init2))  ;size
L1201_Init2:

        ret

L1201_InitFinished:


;---------------------------------------------------------------------
L1201_Check:
;---------------------------------------------------------------------
        DW ((L1201_CheckFinished - L1201_Check) - 2)  ;size
L1201_Check2:
        ret
L1201_CheckFinished:


PRINTT "  1201 Level Check Size: "
PRINTV (L1201_CheckFinished - L1201_Check2)
PRINTT "/$500 bytes"

