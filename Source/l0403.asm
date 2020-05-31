; l0403.asm
; Generated 08.26.2000 by mlevel
; Modified  08.26.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"

;---------------------------------------------------------------------
SECTION "Level0403Section",ROMX
;---------------------------------------------------------------------

L0403_Contents::
  DW L0403_Load
  DW L0403_Init
  DW L0403_Check
  DW L0403_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0403_Load:
        DW ((L0403_LoadFinished - L0403_Load2))  ;size
L0403_Load2:
        call    ParseMap
        ret

L0403_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0403_Map:
INCBIN "Data/Levels/l0403_shroom.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0403_Init:
        DW ((L0403_InitFinished - L0403_Init2))  ;size
L0403_Init2:
        ld      bc,ITEM_SPOREMASK
        call    HasInventoryItem
        jr      nz,.hasMask

        ld      hl,HOffsetOnHBlank
        call    InstallHBlankHandler
.hasMask

        ;ld      a,BANK(shroom_gbm)
        ;ld      hl,shroom_gbm
        ;call    InitMusic
        ret

L0403_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0403_Check:
        DW ((L0403_CheckFinished - L0403_Check2))  ;size
L0403_Check2:
        call    ((.updateWave-L0403_Check2)+levelCheckRAM)
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
        ld      hl,((.sineTable-L0403_Check2)+levelCheckRAM)
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

.sineTable   ;sixteen 16-byte sine waves, values between 0 and 24
REPT 16
  DB 0, 3, 5, 7, 7, 7, 5, 3, 0, 253, 251, 249, 249, 249, 251, 253
ENDR

L0403_CheckFinished:
PRINTT "0403 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0403_LoadFinished - L0403_Load2)
PRINTT " / "
PRINTV (L0403_InitFinished - L0403_Init2)
PRINTT " / "
PRINTV (L0403_CheckFinished - L0403_Check2)
PRINTT "\n"

