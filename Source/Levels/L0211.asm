; L0211.asm
; Generated 10.20.2000 by mlevel
; Modified  10.20.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

FIRST_HOLE EQU 26

;---------------------------------------------------------------------
SECTION "Level0211Section",ROMX
;---------------------------------------------------------------------

L0211_Contents::
  DW L0211_Load
  DW L0211_Init
  DW L0211_Check
  DW L0211_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0211_Load:
        DW ((L0211_LoadFinished - L0211_Load2))  ;size
L0211_Load2:
        call    ParseMap

        ;alter yellow palette to purple w/black
        ld      a,FADEBANK
        ld      bc,6
        ld      de,gamePalette + 5*8 + 2
        ld      hl,((.purpleBlackPalette-L0211_Load2)+levelCheckRAM)
        call    MemCopy
        ret

.purpleBlackPalette
        DW      $4008,$5192,$0000

L0211_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0211_Map:
INCBIN "Data/Levels/L0211_tower.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0211_Init:
        DW ((L0211_InitFinished - L0211_Init2))  ;size
L0211_Init2:
        ret

L0211_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0211_Check:
        DW ((L0211_CheckFinished - L0211_Check2))  ;size
L0211_Check2:
        call    ((.checkFalling-L0211_Check2)+levelCheckRAM)
        ret

.checkFalling
        ld      a,[timeToChangeLevel]
        or      a
        ret     z

        ld      a,[exitTileIndex]
        cp      FIRST_HOLE
        ret     c

        ld      hl,((.fallSound-L0211_Check2)+levelCheckRAM)
        call    PlaySound
        ld      a,15
        call    Delay
        ret

.fallSound
        DB      1,$7e,$80,$f5,$00,$86

L0211_CheckFinished:
PRINTT "0211 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0211_LoadFinished - L0211_Load2)
PRINTT " / "
PRINTV (L0211_InitFinished - L0211_Init2)
PRINTT " / "
PRINTV (L0211_CheckFinished - L0211_Check2)
PRINTT "\n"

