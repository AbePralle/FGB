; l0404.asm
; Generated 08.26.2000 by mlevel
; Modified  08.26.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"


;---------------------------------------------------------------------
SECTION "Level0404Section",DATA
;---------------------------------------------------------------------

L0404_Contents::
  DW L0404_Load
  DW L0404_Init
  DW L0404_Check
  DW L0404_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0404_Load:
        DW ((L0404_LoadFinished - L0404_Load2))  ;size
L0404_Load2:
        call    ParseMap
        ret

L0404_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0404_Map:
INCBIN "..\\fgbeditor\\l0404_shroom.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
VAR_SLIMETRIGGERED EQU 0

L0404_Init:
        DW ((L0404_InitFinished - L0404_Init2))  ;size
L0404_Init2:
        ld      bc,ITEM_SPOREMASK
        call    HasInventoryItem
        jr      nz,.hasMask

        ld      hl,HOffsetOnHBlank
        call    InstallHBlankHandler
.hasMask

        ;ld      a,BANK(shroom_gbm)
        ;ld      hl,shroom_gbm
        ;call    InitMusic

        xor     a
        ld      [levelVars + VAR_SLIMETRIGGERED],a
        ret

L0404_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0404_Check:
        DW ((L0404_CheckFinished - L0404_Check2))  ;size
L0404_Check2:
        call    ((.updateWave-L0404_Check2)+levelCheckRAM)
        call    ((.checkMossTriggered469-L0404_Check2)+levelCheckRAM)
        ret

.checkMossTriggered469
        ld      a,[levelVars + VAR_SLIMETRIGGERED]
        or      a
        ret     nz

        ld      hl,((.heroInZone469-L0404_Check2)+levelCheckRAM)
        ld      a,1
        call    CheckEachHero
        or      a
        ret     z    ;hero not in zone 4, 6, or 9

        ;activate slime in any zone 15 location
        ld      [levelVars + VAR_SLIMETRIGGERED],a
        ld      hl,$d000
        ld      a,ZONEBANK
        ldio    [$ff70],a

        ld      a,[mapHeight]
.outer  push    af
        push    hl
        ld      a,[mapWidth]

.inner  push    af
        ld      a,[hl+]
        and     $0f
        cp      15
        jr      nz,.afterActivate

        dec     hl
        ld      bc,classSlime
        call    FindClassIndex
        ld      c,a
        call    CreateInitAndDrawObject
        ld      a,ZONEBANK
        ldio    [$ff70],a
        inc     hl

.afterActivate
        pop     af
        dec     a
        jr      nz,.inner

        pop     hl
        call    ConvertLocHLToXY
        inc     l
        call    ConvertXYToLocHL
        pop     af
        dec     a
        jr      nz,.outer

        ret

.heroInZone469
        or      a
        ret     z

        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      4
        jr      z,.true
        cp      6
        jr      z,.true
        cp      9
        jr      z,.true

.false  xor     a
        ret

.true   ld      a,1
        ret

.updateWave
        ld      bc,ITEM_SPOREMASK
        call    HasInventoryItem
        ret     nz

        ;fill the horizontalOffset table with values from the sine table
        ld      a,TILEINDEXBANK
        ldio    [$ff70],a
        ldio    a,[updateTimer]
        and     63
        ld      e,a
        ld      d,0
        ld      hl,((.sineTable-L0404_Check2)+levelCheckRAM)
        add     hl,de
        ld      de,horizontalOffset
        ld      c,144
.updateLoop
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.updateLoop

        ld      a,[horizontalOffset]
        ld      [lineZeroHorizontalOffset],a

        ld      hl,hblankFlag
        set     2,[hl]

        ret

.sineTable   ;eight 32-byte sine waves, values between 0 and 15
REPT 8
  DB 0, 1, 3, 4, 5, 6, 7, 7, 7, 7, 7, 6, 5, 4, 3, 1
  DB 0,$fe,$fc,$fb,$fa,$f9,$f8,$f8,$f8,$f8,$f8,$f9,$fa,$fb,$fc,$fe
ENDR


L0404_CheckFinished:
PRINTT "0404 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0404_LoadFinished - L0404_Load2)
PRINTT " / "
PRINTV (L0404_InitFinished - L0404_Init2)
PRINTT " / "
PRINTV (L0404_CheckFinished - L0404_Check2)
PRINTT "\n"

