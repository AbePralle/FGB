; l0808.asm crouton war camp
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

HFENCE_INDEX EQU 129
VFENCE_INDEX EQU 133
VAR_HFENCE EQU 0
VAR_VFENCE EQU 1


;---------------------------------------------------------------------
SECTION "Level0808Section",ROMX
;---------------------------------------------------------------------

L0808_Contents::
  DW L0808_Load
  DW L0808_Init
  DW L0808_Check
  DW L0808_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0808_Load:
        DW ((L0808_LoadFinished - L0808_Load2))  ;size
L0808_Load2:
        call    ParseMap
        ret

L0808_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0808_Map:
INCBIN "Data/Levels/l0808_warcamp.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0808_Init:
        DW ((L0808_InitFinished - L0808_Init2))  ;size
L0808_Init2:
        ld      a,[bgTileMap+HFENCE_INDEX]
        ld      [levelVars + VAR_HFENCE],a
        ld      a,[bgTileMap+VFENCE_INDEX]
        ld      [levelVars + VAR_VFENCE],a

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic

        ret

L0808_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0808_Check:
        DW ((L0808_CheckFinished - L0808_Check2))  ;size
L0808_Check2:
        call    ((.animateFence-L0808_Check2)+levelCheckRAM)
        ret

.animateFence
        ldio    a,[updateTimer]
        rrca
        and     3
        ld      b,a
        ld      hl,bgTileMap+HFENCE_INDEX
        ld      a,[levelVars+VAR_HFENCE]
        ld      d,a
        call    ((.animateFourFrames-L0808_Check2)+levelCheckRAM)
        ld      a,[levelVars+VAR_VFENCE]
        ld      d,a
        jp      ((.animateFourFrames-L0808_Check2)+levelCheckRAM)

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

L0808_CheckFinished:
PRINTT "0808 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0808_LoadFinished - L0808_Load2)
PRINTT " / "
PRINTV (L0808_InitFinished - L0808_Init2)
PRINTT " / "
PRINTV (L0808_CheckFinished - L0808_Check2)
PRINTT "\n"

