; L0606.asm moores landing
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

LIGHTINDEX EQU 57
VAR_LIGHT EQU 0

;---------------------------------------------------------------------
SECTION "Level0606Section",ROMX
;---------------------------------------------------------------------

L0606_Contents::
  DW L0606_Load
  DW L0606_Init
  DW L0606_Check
  DW L0606_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0606_Load:
        DW ((L0606_LoadFinished - L0606_Load2))  ;size
L0606_Load2:
        call    ParseMap
        ret

L0606_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0606_Map:
INCBIN "Data/Levels/L0606_mooreslanding.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0606_Init:
        DW ((L0606_InitFinished - L0606_Init2))  ;size
L0606_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a
        LONGCALLNOARGS AddAppomattoxIfPresent
        ret

L0606_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0606_Check:
        DW ((L0606_CheckFinished - L0606_Check2))  ;size
L0606_Check2:
        call    ((.animateLandingLights-L0606_Check2)+levelCheckRAM)
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
        call    ((.animateLight-L0606_Check2)+levelCheckRAM)
        call    ((.animateLight-L0606_Check2)+levelCheckRAM)
        call    ((.animateLight-L0606_Check2)+levelCheckRAM)
        call    ((.animateLight-L0606_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret

L0606_CheckFinished:
PRINT "0606 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0606_LoadFinished - L0606_Load2)
PRINT " / "
PRINT (L0606_InitFinished - L0606_Init2)
PRINT " / "
PRINT (L0606_CheckFinished - L0606_Check2)
PRINT "\n"

