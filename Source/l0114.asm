; l0114.asm haiku in moonbase tunnel
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0114Section",DATA
;---------------------------------------------------------------------

L0114_Contents::
  DW L0114_Load
  DW L0114_Init
  DW L0114_Check
  DW L0114_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0114_Load:
        DW ((L0114_LoadFinished - L0114_Load2))  ;size
L0114_Load2:
        call    ParseMap
        ret

L0114_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0114_Map:
INCBIN "..\\fgbeditor\\l0114_intro_haiku2.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
VAR_PREVZONE EQU 0
VAR_LIGHT    EQU 1

LIGHTINDEX  EQU 41

L0114_Init:
        DW ((L0114_InitFinished - L0114_Init2))  ;size
L0114_Init2:
        ld      a,BANK(moon_base_haiku_gbm)
				ld      hl,moon_base_haiku_gbm
				call    InitMusic

        ;set default game palette to be bright green
        ld      hl,((.greenBright-L0114_Init2)+levelCheckRAM)
				ld      de,gamePalette
				call    CopyPalette32
				ld      de,gamePalette+64
				call    CopyPalette32
				ld      de,fadeCurPalette+64
				call    CopyPalette32
				ld      de,fadeFinalPalette+64
				call    CopyPalette32

				xor     a
				ld      [levelVars + VAR_PREVZONE],a

        ld      a,[bgTileMap+LIGHTINDEX]  ;tile index of first light
				ld      [levelVars+VAR_LIGHT],a
        ret

.greenBright
DW      $0000, $1104, $2208, $3fef
DW      $0000, $0005, $000f, $3fef
DW      $0000, $2800, $3e00, $3fef
DW      $0000, $0140, $03e0, $3fef
DW      $0000, $2004, $2989, $3fef
DW      $0000, $01c6, $03ef, $3fef
DW      $0000, $00c8, $05ef, $3fef
DW      $0000, $2009, $3d8e, $3fef

L0114_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0114_Check:
        DW ((L0114_CheckFinished - L0114_Check2))  ;size
L0114_Check2:
        ;animate dice lights
				ld      a,[levelVars+VAR_LIGHT]
				ld      b,a

				;slow red lights
				ldio    a,[updateTimer]
				swap    a
				and     %00000011
				add     b
				ld      hl,bgTileMap+LIGHTINDEX
				ld      [hl+],a
				sub     b
				inc     a
				and     %00000011
				add     b
				ld      [hl+],a

        ;get my hero zone
				ld      a,[levelVars + VAR_PREVZONE]
				ld      b,a
				ld      h,((hero0_data>>8) & $ff)
				ld      a,[curHeroAddressL]
				add     HERODATA_INDEX
				ld      l,a
				ld      c,[hl]
				call    GetFirst    ;sets up de
				call    GetCurZone

				;get random number before branching
				push    af
				ld      a,%111
				call    GetRandomNumMask
				ld      h,a
				pop     af

				cp      4
				jr      nc,.darkZone

.lightZone
        ;1/8 chance of resetting to brighter palette
				xor     a
				ld      [levelVars + VAR_PREVZONE],a

				ld      a,h           ;the random number
				or      a
				jr      nz,.sameZone

        ld      hl,((.greenDark-L0114_Check2)+levelCheckRAM)
				ld      de,fadeFinalPalette
				call    CopyPalette32
				ld      hl,gamePalette
				ld      de,fadeCurPalette
				call    CopyPalette32
				ld      a,32
				ld      [fadeRange],a

        ld      a,16
				call    FadeInit
				jr      .sameZone

.darkZone
				cp      b   ;in a different zone than last time?
				jr      z,.sameZone

				ld      [levelVars + VAR_PREVZONE],a ;yep
				;set palette to be black except for red color
        ld      hl,((.greenBlack-L0114_Check2)+levelCheckRAM)
				ld      de,fadeFinalPalette
				call    CopyPalette32
				ld      a,32
				ld      [fadeRange],a
        ld      a,40
				call    FadeInit

.sameZone

        ret

.greenDark
DW      $0000, $0882, $1104, $1de7
DW      $0000, $0005, $000f, $1de7  ;red stays
DW      $0000, $1400, $1d00, $1de7
DW      $0000, $00a0, $01e0, $1de7
DW      $0000, $1002, $14c4, $1de7
DW      $0000, $00e3, $01e7, $1de7
DW      $0000, $0064, $00e7, $1de7
DW      $0000, $1004, $1cc7, $1de7

.greenBlack
DW      $0000, $0060+$40, $0060+$40, $0060+$40
DW      $0000, $0005+$40, $000f+$40, $0060+$40 ;red stays
DW      $0000, $0060+$40, $0060+$40, $0060+$40
DW      $0000, $0060+$40, $0060+$40, $0060+$40
DW      $0000, $0060+$40, $0060+$40, $0060+$40
DW      $0000, $0060+$40, $0060+$40, $0060+$40
DW      $0000, $0060+$40, $0060+$40, $0060+$40
DW      $0000, $0060+$40, $00a0+$40, $0060+$40

L0114_CheckFinished:
PRINTT "0114 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0114_LoadFinished - L0114_Load2)
PRINTT " / "
PRINTV (L0114_InitFinished - L0114_Init2)
PRINTT " / "
PRINTV (L0114_CheckFinished - L0114_Check2)
PRINTT "\n"

