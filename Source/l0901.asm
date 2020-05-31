; L0901.asm
; Generated 01.03.1980 by mlevel
; Modified  01.03.1980 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

HFENCE_INDEX EQU 35
VFENCE_INDEX EQU 39
VAR_HFENCE EQU 0
VAR_VFENCE EQU 1

;---------------------------------------------------------------------
SECTION "Level0901Section",ROMX
;---------------------------------------------------------------------

L0901_Contents::
  DW L0901_Load
  DW L0901_Init
  DW L0901_Check
  DW L0901_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0901_Load:
        DW ((L0901_LoadFinished - L0901_Load2))  ;size
L0901_Load2:
        call    ParseMap
        ret

L0901_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0901_Map:
INCBIN "Data/Levels/L0901_slavecamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0901_Init:
        DW ((L0901_InitFinished - L0901_Init2))  ;size
L0901_Init2:
        ld      a,[bgTileMap+HFENCE_INDEX]
        ld      [levelVars + VAR_HFENCE],a
        ld      a,[bgTileMap+VFENCE_INDEX]
        ld      [levelVars + VAR_VFENCE],a
        ret

L0901_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0901_Check:
        DW ((L0901_CheckFinished - L0901_Check2))  ;size
L0901_Check2:
        call    ((.animateFence-L0901_Check2)+levelCheckRAM)
        ret

.animateFence
        ldio    a,[updateTimer]
        rrca
        and     3
        ld      b,a
        ld      hl,bgTileMap+HFENCE_INDEX
        ld      a,[levelVars+VAR_HFENCE]
        ld      d,a
        call    ((.animateFourFrames-L0901_Check2)+levelCheckRAM)
        ld      a,[levelVars+VAR_VFENCE]
        ld      d,a
        jp      ((.animateFourFrames-L0901_Check2)+levelCheckRAM)

.animateFourFrames
        ld      c,4

.animateFourFrames_loop
        ld      a,b
        add     c
        and     3
        add     d
        ld      [hl+],a
        dec     c
        jr      nz,.animateFourFrames_loop
        ret

L0901_CheckFinished:
PRINTT "0901 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0901_LoadFinished - L0901_Load2)
PRINTT " / "
PRINTV (L0901_InitFinished - L0901_Init2)
PRINTT " / "
PRINTV (L0901_CheckFinished - L0901_Check2)
PRINTT "\n"

