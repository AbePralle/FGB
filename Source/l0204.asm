;level0204.asm
;Abe Pralle 3.4.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "LevelsSection0204",ROMX
;---------------------------------------------------------------------

L0204_Contents::
  DW L0204_Load
  DW L0204_Init
  DW L0204_Check
  DW L0204_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0204_Load:
        DW ((L0204_LoadFinished - L0204_Load2))  ;size
L0204_Load2:
        call    ParseMap
        ret

L0204_LoadFinished:

L0204_Map:
INCBIN "Data/Levels/l0204_path.lvl"

;gtx_intro:                INCBIN  "Data/Dialog/Landing/intro.gtx"
;gtx_intro2:               INCBIN  "Data/Dialog/Landing/intro2.gtx"
;gtx_finished:             INCBIN  "Data/Dialog/Landing/finished.gtx"
;gtx_finished2:            INCBIN  "Data/Dialog/Landing/finished2.gtx"

;---------------------------------------------------------------------
L0204_Init:
;---------------------------------------------------------------------
        DW ((L0204_InitFinished - L0204_Init2))  ;size
L0204_Init2:

        ret

L0204_InitFinished:


;---------------------------------------------------------------------
L0204_Check:
;---------------------------------------------------------------------
        DW ((L0204_CheckFinished - L0204_Check) - 2)  ;size
L0204_Check2:
        ;-----------------see what zone the hero is in------------------
        ;get hero object
        ld      a,[hero0_object]
        ld      l,a
        ld      a,[hero0_object+1]
        ld      h,a

        ;get hero's location from hero object
        ld      a,OBJBANK
        ld      [$ff70],a
        ld      e,[hl]
        inc     hl
        ld      d,[hl]

        ;see what zone he's in
        ld      a,ZONEBANK
        ld      [$ff70],a
        ld      a,[de]
        and     %1111     ;no exit info please
        ld      [mapHeroZone],a

        ;change palette if changed zones
        ld      hl,(.lastZone +  (levelCheckRAM-L0204_Check2))
        cp      [hl]
        jr      z,.afterChangePalette

        ;note new zone
        ld      [(.lastZone +  (levelCheckRAM-L0204_Check2))],a

        ld      a,FADEBANK
        ld      [$ff70],a

        ;copy standard palette to fadeFinalPalette, dividing colors by two
        ld      hl,(.stdPaletteData +  (levelCheckRAM-L0204_Check2))
        ld      de,fadeFinalPalette
        ld      c,32
.copyLoop
        push    bc

        ld      a,[mapHeroZone]
        ld      c,a

        ld      a,[hl+]   ;low byte
        ld      b,a
        ld      a,[hl+]   ;high byte

        ;rotate ab by # bits equal to the current zone number - 1
        dec     c
        jr      z,.shiftDone

.shiftLoop
        rrca
        rr      b

        ;mask ab with %00111101 11101111
        push    af
        ld      a,b
        and     %11101111
        ld      b,a
        pop     af
        and     %00111101

        dec     c
        jr      nz,.shiftLoop

.shiftDone
        ;write  ba to dest
        push    af
        ld      a,b
        ld      [de],a
        inc     de
        pop     af
        ld      [de],a
        inc     de

        pop     bc

        dec     c
        jr      nz,.copyLoop

        ld      a,60
        call    FadeInit

.afterChangePalette
        ret

.lastZone DB $ff

.stdPaletteData
        DW      $0068, $2108, $4210, $7fff     ;Palette 0 (Grey)
        DW      $0068, $000A, $001f, $7fff     ;Palette 1 (Red)
        DW      $0068, $5000, $7e00, $7fff     ;Palette 2 (Blue)
        DW      $0068, $0140, $03e0, $7fff     ;Palette 3 (Green)
        DW      $0068, $4008, $5192, $7fff     ;Palette 4 (Purple)
        DW      $0068, $01cd, $03fe, $7fff     ;Palette 5 (Yellow)
        DW      $0068, $00d1, $09ff, $7fff     ;Palette 6 (Brown)
        DW      $0068, $4412, $799c, $7fff     ;Palette 7 (Fuscia)
L0204_CheckFinished:


PRINTT "  0204 Level Check Size: "
PRINTV (L0204_CheckFinished - L0204_Check2)
PRINTT "/$500 bytes"

