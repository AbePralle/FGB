; l0011.asm House of the Seasons
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0011Section",ROMX
;---------------------------------------------------------------------

L0011_Contents::
  DW L0011_Load
  DW L0011_Init
  DW L0011_Check
  DW L0011_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0011_Load:
        DW ((L0011_LoadFinished - L0011_Load2))  ;size
L0011_Load2:
        call    ParseMap
        ret

L0011_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0011_Map:
INCBIN "Data/Levels/L0011_seasons.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
VAR_FIRE EQU 0

FIREINDEX EQU 40

L0011_Init:
        DW ((L0011_InitFinished - L0011_Init2))  ;size
L0011_Init2:
        ld      a,[bgTileMap + FIREINDEX]
        ld      [levelVars + VAR_FIRE],a

        ;map color to white for fade
        ld      hl,mapColor
        ld      a,$ff
        ld      [hl+],a
        ld      a,$7f
        ld      [hl+],a

        ;last color to $0888 for fade/hblank
        ld      a,FADEBANK
        ldio    [$ff70],a
        ld      hl,gamePalette+62
        ld      a,$88
        ld      [hl+],a
        ld      a,$08
        ld      [hl+],a

        ;new hblank
        ld      hl,SeasonsOnHBlank
        call    InstallHBlankHandler

        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic
        ret

L0011_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0011_Check:
        DW ((L0011_CheckFinished - L0011_Check2))  ;size
L0011_Check2:
        call    ((.animateFire-L0011_Check2)+levelCheckRAM)
        ret

.animateFire
        ldio    a,[updateTimer]
        rrca
        rrca
        and     %11
        ld      hl,levelVars + VAR_FIRE
        add     [hl]
        ld      [bgTileMap + FIREINDEX],a
        ret


L0011_CheckFinished:
PRINTT "0011 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0011_LoadFinished - L0011_Load2)
PRINTT " / "
PRINTV (L0011_InitFinished - L0011_Init2)
PRINTT " / "
PRINTV (L0011_CheckFinished - L0011_Check2)
PRINTT "\n"

