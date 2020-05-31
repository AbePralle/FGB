;leveL0203.asm
;Abe Pralle 3.4.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "LevelsSection0203",ROMX
;---------------------------------------------------------------------

L0203_Contents::
  DW L0203_Load
  DW L0203_Init
  DW L0203_Check
  DW L0203_Map

;---------------------------------------------------------------------
;  landing
;---------------------------------------------------------------------
L0203_Load:
        DW ((L0203_LoadFinished - L0203_Load2))  ;size
L0203_Load2:
        call    ParseMap
        ret

L0203_LoadFinished:

L0203_Map:
INCBIN "Data/Levels/L0203_path.lvl"

;gtx_intro:                INCBIN  "Data/Dialog/Landing/intro.gtx"
;gtx_intro2:               INCBIN  "Data/Dialog/Landing/intro2.gtx"
;gtx_finished:             INCBIN  "Data/Dialog/Landing/finished.gtx"
;gtx_finished2:            INCBIN  "Data/Dialog/Landing/finished2.gtx"

;---------------------------------------------------------------------
L0203_Init:
;---------------------------------------------------------------------
        DW ((L0203_InitFinished - L0203_Init2))  ;size
L0203_Init2:

        ret

L0203_InitFinished:


;---------------------------------------------------------------------
L0203_Check:
;---------------------------------------------------------------------
        DW ((L0203_CheckFinished - L0203_Check) - 2)  ;size
L0203_Check2:
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
        ld      hl,(.lastZone +  (levelCheckRAM-L0203_Check2))
        cp      [hl]
        jr      z,.afterChangePalette

        ;note new zone
        ld      [(.lastZone +  (levelCheckRAM-L0203_Check2))],a

        ld      a,FADEBANK
        ld      [$ff70],a

        ;copy standard palette to fadeFinalPalette, dividing colors by two
        ld      hl,(.stdPaletteData +  (levelCheckRAM-L0203_Check2))
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

        ;restore red
        ld      de,fadeFinalPalette + 10
        ld      hl,(.stdPaletteData +  (levelCheckRAM-L0203_Check2))+10
        ld      c,6
.restoreLoop
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.restoreLoop

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
L0203_CheckFinished:


PRINTT "  0203 Level Check Size: "
PRINTV (L0203_CheckFinished - L0203_Check2)
PRINTT "/$500 bytes"

