; l0311.asm
; Generated 10.20.2000 by mlevel
; Modified  10.20.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

FIRST_HOLE EQU 25

;---------------------------------------------------------------------
SECTION "Level0311Section",ROMX
;---------------------------------------------------------------------

L0311_Contents::
  DW L0311_Load
  DW L0311_Init
  DW L0311_Check
  DW L0311_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0311_Load:
        DW ((L0311_LoadFinished - L0311_Load2))  ;size
L0311_Load2:
        call    ParseMap

        ;alter yellow palette to purple w/black
        ld      a,FADEBANK
        ld      bc,6
        ld      de,gamePalette + 5*8 + 2
        ld      hl,((.purpleBlackPalette-L0311_Load2)+levelCheckRAM)
        call    MemCopy
        ret

.purpleBlackPalette
        DW      $4008,$5192,$0000

L0311_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0311_Map:
INCBIN "..\\fgbeditor\\l0311_tower.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0311_Init:
        DW ((L0311_InitFinished - L0311_Init2))  ;size
L0311_Init2:
        ret

L0311_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0311_Check:
        DW ((L0311_CheckFinished - L0311_Check2))  ;size
L0311_Check2:
        call    ((.checkFalling-L0311_Check2)+levelCheckRAM)
        ret

.checkFalling
        ld      a,[timeToChangeLevel]
        or      a
        ret     z

        ld      a,[exitTileIndex]
        cp      FIRST_HOLE
        ret     c

        ld      hl,((.fallSound-L0311_Check2)+levelCheckRAM)
        call    PlaySound
        ld      a,15
        call    Delay
        ret

.fallSound
        DB      1,$7e,$80,$f5,$00,$86

L0311_CheckFinished:
PRINTT "0311 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0311_LoadFinished - L0311_Load2)
PRINTT " / "
PRINTV (L0311_InitFinished - L0311_Init2)
PRINTT " / "
PRINTV (L0311_CheckFinished - L0311_Check2)
PRINTT "\n"

