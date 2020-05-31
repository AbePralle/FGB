; l0905.asm monkey landing
; Generated 10.29.2000 by mlevel
; Modified  10.29.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

LIGHTINDEX EQU 41
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0905Section",DATA
;---------------------------------------------------------------------

L0905_Contents::
  DW L0905_Load
  DW L0905_Init
  DW L0905_Check
  DW L0905_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0905_Load:
        DW ((L0905_LoadFinished - L0905_Load2))  ;size
L0905_Load2:
        call    ParseMap
        ret

L0905_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0905_Map:
INCBIN "..\\fgbeditor\\l0905_junglelanding.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0905_Init:
        DW ((L0905_InitFinished - L0905_Init2))  ;size
L0905_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
				ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent
        ret

L0905_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0905_Check:
        DW ((L0905_CheckFinished - L0905_Check2))  ;size
L0905_Check2:
        call    ((.animateLandingLights-L0905_Check2)+levelCheckRAM)
        ret

.animateLandingLights
        ldio    a,[updateTimer]
				rrca
				rrca
				and     %11
				ld      b,a

				ld      a,[levelVars+VAR_LIGHT]
				ld      c,a
				ld      d,0

				ld      hl,bgTileMap+LIGHTINDEX
        call    ((.animateLight-L0905_Check2)+levelCheckRAM)
        call    ((.animateLight-L0905_Check2)+levelCheckRAM)
        call    ((.animateLight-L0905_Check2)+levelCheckRAM)
        call    ((.animateLight-L0905_Check2)+levelCheckRAM)
				ret

.animateLight
				ld      a,d
				add     b
				and     %11
				add     c
				ld      [hl+],a
				inc     d
				ret

L0905_CheckFinished:
PRINTT "0905 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0905_LoadFinished - L0905_Load2)
PRINTT " / "
PRINTV (L0905_InitFinished - L0905_Init2)
PRINTT " / "
PRINTV (L0905_CheckFinished - L0905_Check2)
PRINTT "\n"

