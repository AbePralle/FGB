; l0113.asm ship blows up battleground BA
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

CRATERINDEX EQU 30

;---------------------------------------------------------------------
SECTION "Level0113Section",DATA
;---------------------------------------------------------------------

L0113_Contents::
  DW L0113_Load
  DW L0113_Init
  DW L0113_Check
  DW L0113_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0113_Load:
        DW ((L0113_LoadFinished - L0113_Load2))  ;size
L0113_Load2:
        call    ParseMap

        ;load in tiles used for sprite ship
        ;bg tiles 1454-1457 to Bank 0 100-189
        ldio    a,[curROMBank]
        push    af
        ld      a,BANK(BGTiles1024)
        call    SetActiveROM

        xor     a         ;bank 0
        ld      c,4       ;number of tiles to copy
        ld      de,$8000+1600
        ld      hl,BGTiles1024 + 430*16
        call    VMemCopy
        pop     af
        call    SetActiveROM
        ret

L0113_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0113_Map:
INCBIN "..\\fgbeditor\\l0113_intro_ba2.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
STATE_CREATE_BOMBER    EQU 0
STATE_BOMBER_RUN       EQU 1
STATE_EXPLOSION_STAGE1 EQU 2
STATE_EXPLOSION_STAGE2 EQU 3
STATE_EXPLOSION_STAGE3 EQU 4
STATE_NORMAL           EQU 5

VAR_DELAY   EQU 0
VAR_METASPRITE EQU 1   ;1-5

L0113_Init:
        DW ((L0113_InitFinished - L0113_Init2))  ;size
L0113_Init2:
        ld      bc,((GROUP_MONSTERB<<8) | GROUP_HERO)
        ld      a,1    ;make soldiers friends with hero
        call    SetFOF

        ldio    a,[mapState]
        cp      STATE_NORMAL
        call    z,((.removeShip-L0113_Init2) + levelCheckRAM)

        ret

.removeShip
        ;remove crouton ship from map
        ld      hl,$d1cf
        ld      c,4
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)
        ld      c,6
        ld      hl,$d20e
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)
        ld      hl,$d24e
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)
        ld      hl,$d28e
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)
        ld      hl,$d2ce
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)
        ld      hl,$d30e
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)
        ld      hl,$d34e
        call    ((.removeRow-L0113_Init2) + levelCheckRAM)

        ;add crater to map
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d20f
        ld      a,CRATERINDEX
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ld      [hl+],a
        inc     a
        ld      [hl+],a

        ld      hl,$d24f
        ld      a,CRATERINDEX+3
        ld      [hl+],a
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      a,CRATERINDEX+5
        ld      [hl+],a

        ld      hl,$d28f
        ld      a,CRATERINDEX+6
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ld      [hl+],a
        inc     a
        ld      [hl+],a

        ret

.removeRow
        push    bc

        ld      a,MAPBANK
        ldio    [$ff70],a

        xor     a
.removeRowLoop
        ld      [hl+],a
        dec     c
        jr      nz,.removeRowLoop
        
        pop     bc
        ret

L0113_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0113_Check:
        DW ((L0113_CheckFinished - L0113_Check2))  ;size
L0113_Check2:

        ldio    a,[mapState]
        cp      STATE_NORMAL
        jr      nz,.checkCreateBomber

        ret

.checkCreateBomber
        cp      STATE_CREATE_BOMBER
        jr      nz,.checkBomberRun

        ;create bomber
        ld      a,128
        ld      [metaSprite_x],a
        ld      a,220
        ld      [metaSprite_y],a
        ld      bc,$0202
        ld      d,100
        ld      e,5
        ld      hl,levelVars+VAR_METASPRITE
        call    CreateMetaSprite
        ld      a,STATE_BOMBER_RUN
        ldio    [mapState],a
        ret

.checkBomberRun
        cp      STATE_BOMBER_RUN
        jr      nz,.checkExplosionStage1

        ld      bc,$00fc
        ld      hl,levelVars+VAR_METASPRITE
        call    ScrollMetaSprite

        ;get top sprite y coord
        ld      h,((spriteOAMBuffer>>8) & $ff)
        ld      a,[levelVars+VAR_METASPRITE+1]
        ld      l,a
        ld      a,[hl]

        ;play sound effect?
        cp      144
        jr      nz,.afterPlayShipSound

        ld      hl,((shipSound-L0113_Check2) + levelCheckRAM)
        call    PlaySound

        ret

.afterPlayShipSound
        ;reached bombing position?
        cp      44
        jr      nz,.afterCheckBombPosition

        ;first explosion from bomb
        ld      a,5
        ld      [bulletColor],a
        ld      bc,$0405
        ld      de,$0a01
        ld      hl,$d1ce
        call    CreateBigExplosion
        ld      a,20
        ld      b,8
        call    SetupFadeFromSaturated
        ld      hl,((bigExplosionSound-L0113_Check2) + levelCheckRAM)
        call    PlaySound
        ld      a,10
        ldio    [jiggleDuration],a
        ret

.afterCheckBombPosition
        ;off top of screen?
        cp      240    ;wrapped around to bottom
        ret     nz

        ;remove bomber
        ld      hl,levelVars+VAR_METASPRITE
        call    FreeMetaSprite

        ld      a,5
        ld      [bulletColor],a
        ld      bc,$0405
        ld      de,$0601
        ld      hl,$d1ce
        call    CreateBigExplosion
        ld      a,20
        ld      b,8
        call    SetupFadeFromSaturated
        ld      hl,((bigExplosionSound-L0113_Check2) + levelCheckRAM)
        call    PlaySound
        ld      a,10
        ldio    [jiggleDuration],a

        ld      a,16
        ld      [levelVars + VAR_DELAY],a
        ld      a,STATE_EXPLOSION_STAGE1
        ldio    [mapState],a
        ret

.checkExplosionStage1
        cp      STATE_EXPLOSION_STAGE1
        jr      nz,.checkExplosionStage2

        ld      hl,levelVars+VAR_DELAY
        ld      a,[hl]
        or      a
        jr      z,.stage1explosion
        dec     [hl]
        ret

.stage1explosion
        ld      a,5
        ld      [bulletColor],a
        ld      bc,$0405
        ld      de,$0a04
        ld      hl,$d1ce
        call    CreateBigExplosion
        ld      de,$0502
        call    CreateBigExplosion
        ld      a,20
        ld      b,8
        call    SetupFadeFromSaturated
        ld      hl,((bigExplosionSound-L0113_Check2) + levelCheckRAM)
        call    PlaySound
        ld      a,10
        ldio    [jiggleDuration],a

        ld      a,30
        ld      [levelVars + VAR_DELAY],a
        ld      a,STATE_EXPLOSION_STAGE2
        ldio    [mapState],a
        ret

.checkExplosionStage2
        cp      STATE_EXPLOSION_STAGE2
        jr      nz,.checkExplosionStage3

        ld      hl,levelVars+VAR_DELAY
        ld      a,[hl]
        or      a
        jr      z,.stage2explosion
        dec     [hl]
        ret

.stage2explosion
        ld      a,5
        ld      [bulletColor],a
        ld      bc,$0405
        ld      de,$1001
        ld      hl,$d1ce
        call    CreateBigExplosion
        ld      a,20
        ld      b,8
        call    SetupFadeFromSaturated
        ld      hl,((bigExplosionSound-L0113_Check2) + levelCheckRAM)
        call    PlaySound
        ld      a,10
        ldio    [jiggleDuration],a

        ld      a,20
        ld      [levelVars + VAR_DELAY],a
        ld      a,STATE_EXPLOSION_STAGE3
        ldio    [mapState],a
        ret

.checkExplosionStage3
        cp      STATE_EXPLOSION_STAGE3
        ret     nz

        ld      hl,levelVars+VAR_DELAY
        ld      a,[hl]
        or      a
        jr      z,.stage3explosion
        dec     [hl]
        ret

.stage3explosion
        ;remove crouton ship from map
        ld      hl,$d1cf
        ld      c,4
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)
        ld      c,6
        ld      hl,$d20e
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)
        ld      hl,$d24e
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)
        ld      hl,$d28e
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)
        ld      hl,$d2ce
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)
        ld      hl,$d30e
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)
        ld      hl,$d34e
        call    ((.removeRow-L0113_Check2) + levelCheckRAM)


        ld      a,5
        ld      [bulletColor],a
        ld      bc,$0405
        ld      de,$0804
        ld      hl,$d1ce
        call    CreateBigExplosion
        ld      de,$1803
        call    CreateBigExplosion
        ld      a,30
        call    SetupFadeFromWhite
        ;ld      b,15
        ;call    SetupFadeFromSaturated
        ld      hl,((bigExplosionSound-L0113_Check2) + levelCheckRAM)
        call    PlaySound
        ld      a,15
        ldio    [jiggleDuration],a
        ld      a,1
        call    Delay

        ;add crater to map
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d20f
        ld      a,30
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ld      [hl+],a
        inc     a
        ld      [hl+],a

        ld      hl,$d24f
        ld      a,33
        ld      [hl+],a
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      a,35
        ld      [hl+],a

        ld      hl,$d28f
        ld      a,36
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        ld      [hl+],a
        inc     a
        ld      [hl+],a

        ld      a,STATE_NORMAL
        ldio    [mapState],a
        ret

.removeRow
        push    bc

        ld      a,MAPBANK
        ldio    [$ff70],a

        xor     a
.removeRowLoop
        ld      [hl+],a
        dec     c
        jr      nz,.removeRowLoop
        
        pop     bc
        ret

shipSound:
  DB 1,$1f,$80,$f5,$80,$86

bigExplosionSound:
  DB 4,$00,$f3,$81,$80

L0113_CheckFinished:
PRINTT "0113 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0113_LoadFinished - L0113_Load2)
PRINTT " / "
PRINTV (L0113_InitFinished - L0113_Init2)
PRINTT " / "
PRINTV (L0113_CheckFinished - L0113_Check2)
PRINTT "\n"

