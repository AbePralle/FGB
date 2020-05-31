; l0809.asm grenade vs goblin charge
; Generated 11.01.2000 by mlevel
; Modified  11.01.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0809Section",DATA
;---------------------------------------------------------------------

L0809_Contents::
  DW L0809_Load
  DW L0809_Init
  DW L0809_Check
  DW L0809_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0809_Load:
        DW ((L0809_LoadFinished - L0809_Load2))  ;size
L0809_Load2:
        call    ParseMap
        ret

L0809_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0809_Map:
INCBIN "..\\fgbeditor\\l0809_warzone.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0809_Init:
        DW ((L0809_InitFinished - L0809_Init2))  ;size
L0809_Init2:
        ld      a,ENV_DIRT
        call    SetEnvEffect

        ld      a,BANK(fgbwar_gbm)
        ld      hl,fgbwar_gbm
        call    InitMusic
        ret

L0809_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0809_Check:
        DW ((L0809_CheckFinished - L0809_Check2))  ;size
L0809_Check2:
        ret

L0809_CheckFinished:
PRINTT "0809 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0809_LoadFinished - L0809_Load2)
PRINTT " / "
PRINTV (L0809_InitFinished - L0809_Init2)
PRINTT " / "
PRINTV (L0809_CheckFinished - L0809_Check2)
PRINTT "\n"
