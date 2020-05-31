; l0410.asm crouton outpost
; Generated 11.07.2000 by mlevel
; Modified  11.07.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"


HFENCE_INDEX EQU 72
VFENCE_INDEX EQU 76
VAR_HFENCE EQU 0
VAR_VFENCE EQU 1

;---------------------------------------------------------------------
SECTION "Level0410Section",DATA
;---------------------------------------------------------------------

L0410_Contents::
  DW L0410_Load
  DW L0410_Init
  DW L0410_Check
  DW L0410_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0410_Load:
        DW ((L0410_LoadFinished - L0410_Load2))  ;size
L0410_Load2:
        call    ParseMap
        ret

L0410_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0410_Map:
INCBIN "..\\fgbeditor\\l0410_outpost.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0410_Init:
        DW ((L0410_InitFinished - L0410_Init2))  ;size
L0410_Init2:
        ld      a,[bgTileMap+HFENCE_INDEX]
        ld      [levelVars + VAR_HFENCE],a
        ld      a,[bgTileMap+VFENCE_INDEX]
        ld      [levelVars + VAR_VFENCE],a

        ld      bc,ITEM_CODE0410
        call    RemoveClearanceIfTaken
        ret

L0410_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0410_Check:
        DW ((L0410_CheckFinished - L0410_Check2))  ;size
L0410_Check2:
        call    ((.animateFence-L0410_Check2)+levelCheckRAM)
        ret

.animateFence
        ldio    a,[updateTimer]
        rrca
        and     3
        ld      b,a
        ld      hl,bgTileMap+HFENCE_INDEX
        ld      a,[levelVars+VAR_HFENCE]
        ld      d,a
        call    ((.animateFourFrames-L0410_Check2)+levelCheckRAM)
        ld      a,[levelVars+VAR_VFENCE]
        ld      d,a
        jp      ((.animateFourFrames-L0410_Check2)+levelCheckRAM)

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

L0410_CheckFinished:
PRINTT "0410 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0410_LoadFinished - L0410_Load2)
PRINTT " / "
PRINTV (L0410_InitFinished - L0410_Init2)
PRINTT " / "
PRINTV (L0410_CheckFinished - L0410_Check2)
PRINTT "\n"

