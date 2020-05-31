; l0711.asm Space Station Apocalypse Exterior
; Generated 04.25.2001 by mlevel
; Modified  04.25.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

import classBAPlayer
import classBSPlayer
import classHaikuPlayer
import classBAPlayerSpace
import classBSPlayerSpace
import classHaikuPlayerSpace

;---------------------------------------------------------------------
SECTION "Level0711Section",ROMX
;---------------------------------------------------------------------

L0711_Contents::
  DW L0711_Load
  DW L0711_Init
  DW L0711_Check
  DW L0711_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0711_Load:
        DW ((L0711_LoadFinished - L0711_Load2))  ;size
L0711_Load2:
        ld      a,[hero0_enterLevelFacing]
        cp      EXIT_U
        jr      nz,.checkHero1

        ld      a,50
        ld      [hero0_enterLevelLocation],a
        ld      a,23
        ld      [hero0_enterLevelLocation+1],a

.checkHero1
        ld      a,[hero1_enterLevelFacing]
        cp      EXIT_U
        jr      nz,.afterChangeEnterLoc

        ld      a,50
        ld      [hero1_enterLevelLocation],a
        ld      a,23
        ld      [hero1_enterLevelLocation+1],a

.afterChangeEnterLoc
        call    ParseMap
        ret

L0711_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0711_Map:
INCBIN "Data/Levels/l0711_spacestation.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0711_Init:
        DW ((L0711_InitFinished - L0711_Init2))  ;size
L0711_Init2:
        ld      a,BANK(spaceish_gbm)
        ld      hl,spaceish_gbm
        call    InitMusic
        ret

L0711_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0711_Check:
        DW ((L0711_CheckFinished - L0711_Check2))  ;size
L0711_Check2:
        call    ((.changePlayersToSpace-L0711_Check2)+levelCheckRAM)
        ret

.changePlayersToSpace
        ld      bc,classBAPlayer
        ld      de,classBAPlayerSpace
        call    ChangeClass

        ld      bc,classBSPlayer
        ld      de,classBSPlayerSpace
        call    ChangeClass

        ld      bc,classHaikuPlayer
        ld      de,classHaikuPlayerSpace
        call    ChangeClass
        ret

L0711_CheckFinished:
PRINTT "0711 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0711_LoadFinished - L0711_Load2)
PRINTT " / "
PRINTV (L0711_InitFinished - L0711_Init2)
PRINTT " / "
PRINTV (L0711_CheckFinished - L0711_Check2)
PRINTT "\n"

