; L0411.asm top of tower
; Generated 10.20.2000 by mlevel
; Modified  10.20.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

FIRST_HOLE EQU 32

;---------------------------------------------------------------------
SECTION "Level0411Section",ROMX
;---------------------------------------------------------------------

L0411_Contents::
  DW L0411_Load
  DW L0411_Init
  DW L0411_Check
  DW L0411_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0411_Load:
        DW ((L0411_LoadFinished - L0411_Load2))  ;size
L0411_Load2:
        call    ParseMap

        ;alter yellow palette to purple w/black
        ld      a,FADEBANK
        ld      bc,6
        ld      de,gamePalette + 5*8 + 2
        ld      hl,((.purpleBlackPalette-L0411_Load2)+levelCheckRAM)
        call    MemCopy

        ret

.purpleBlackPalette
        DW      $4008,$5192,$0000

L0411_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0411_Map:
INCBIN "Data/Levels/L0411_tower.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0411_Init:
        DW ((L0411_InitFinished - L0411_Init2))  ;size
L0411_Init2:
        ;already rescued guys?
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$3c]    ;rescue from tower cinema state
        or      a
        jr      z,.done

        ;rescued already
        ld      bc,classActor
        call    DeleteObjectsOfClass

        ;disable up exit
        ld      de,$4040
        ld      hl,mapExitLinks+EXIT_U*2
        ld      [hl],e
        inc     hl
        ld      [hl],d
.done
        ret

L0411_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0411_Check:
        DW ((L0411_CheckFinished - L0411_Check2))  ;size
L0411_Check2:
        call    ((.checkFalling-L0411_Check2)+levelCheckRAM)
        ret

.checkFalling
        ld      a,[timeToChangeLevel]
        or      a
        ret     z

        ld      a,[exitTileIndex]
        cp      FIRST_HOLE
        ret     c

        ld      hl,((.fallSound-L0411_Check2)+levelCheckRAM)
        call    PlaySound
        ld      a,15
        call    Delay
        ret

.fallSound
        DB      1,$7e,$80,$f5,$00,$86

L0411_CheckFinished:
PRINTT "0411 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0411_LoadFinished - L0411_Load2)
PRINTT " / "
PRINTV (L0411_InitFinished - L0411_Init2)
PRINTT " / "
PRINTV (L0411_CheckFinished - L0411_Check2)
PRINTT "\n"

