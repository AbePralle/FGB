; L1512.asm Crouton Homeworld 4
; Generated 04.19.2001 by mlevel
; Modified  04.19.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

VFENCE_INDEX EQU 19

VAR_BGKILLED EQU 15


;---------------------------------------------------------------------
SECTION "Level1512Section",ROMX
;---------------------------------------------------------------------

L1512_Contents::
  DW L1512_Load
  DW L1512_Init
  DW L1512_Check
  DW L1512_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1512_Load:
        DW ((L1512_LoadFinished - L1512_Load2))  ;size
L1512_Load2:
        call    ParseMap
        ret

L1512_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1512_Map:
INCBIN "Data/Levels/L1512_crouton_hw4.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1512_Init:
        DW ((L1512_InitFinished - L1512_Init2))  ;size
L1512_Init2:
        xor     a
        ld      [levelVars+VAR_BGKILLED],a
        ret

L1512_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1512_Check:
        DW ((L1512_CheckFinished - L1512_Check2))  ;size
L1512_Check2:
        call    ((.animateFence-L1512_Check2)+levelCheckRAM)
        call    ((.checkBlowGenerators-L1512_Check2)+levelCheckRAM)
        ret

.checkBlowGenerators
        ld      a,[levelVars+VAR_BGKILLED]
        or      a
        ret     z

        ld      a,[hero0_index]
        or      a
        jr      z,.checkHero1

        ;change hero 0 to actor & walk to teleport
        ld      c,a
        call    GetFirst
        ld      hl,$d0e4
        call    SetActorDestLoc
        call    GetClassMethodTable
        ld      b,h
        ld      c,l
        ld      de,classActor
        call    ChangeClass

.checkHero1
        ld      a,[hero1_index]
        or      a
        jr      z,.startExplosions

        ;change hero 1 to actor & walk to teleport
        ld      c,a
        call    GetFirst
        ld      hl,$d104
        call    SetActorDestLoc
        call    GetClassMethodTable
        ld      b,h
        ld      c,l
        ld      de,classActor
        call    ChangeClass

.startExplosions
        ld      hl,$d0cb
        call    ((.explodeGenerator-L1512_Check2)+levelCheckRAM)
        call    ((.animateDelay-L1512_Check2)+levelCheckRAM)
        ld      hl,$d0ce
        call    ((.explodeGenerator-L1512_Check2)+levelCheckRAM)
        call    ((.animateDelay-L1512_Check2)+levelCheckRAM)
        ld      hl,$d0d1
        call    ((.explodeGenerator-L1512_Check2)+levelCheckRAM)
        ld      hl,$d12e
        call    ((.explodeGenerator-L1512_Check2)+levelCheckRAM)
        call    ((.animateDelay-L1512_Check2)+levelCheckRAM)

        ld      hl,$d0d4
        call    ((.explodeGenerator-L1512_Check2)+levelCheckRAM)
        ld      hl,$d131
        call    ((.explodeGenerator-L1512_Check2)+levelCheckRAM)
        call    ((.animateDelay-L1512_Check2)+levelCheckRAM)

        ld      a,EXIT_U
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$0612
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a

        ld      a,EXIT_U
        call    YankRemotePlayer

        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.explodeGenerator
        xor     a
        ld      [bulletColor],a
        ld      bc,$0303
        ld      de,$1407
        push    hl
        call    CreateBigExplosion
        ld      hl,bigExplosionSound
        call    PlaySound
        ld      a,15
        ldio    [jiggleDuration],a
        pop     hl

        ;remove generator from map
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      d,0
        ld      a,[mapPitch]
        ld      e,a
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl],a
        add     hl,de
        ld      [hl-],a
        ld      [hl-],a
        ld      [hl],a
        add     hl,de
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl],a
        ret

.animateDelay
        ld      a,30
.animateDelayLoop
        push    af
        ld      a,1
        call    Delay
        call    ((.animateFence-L1512_Check2)+levelCheckRAM)
        pop     af
        dec     a
        jr      nz,.animateDelayLoop
        ret

.animateFence
        ldio    a,[updateTimer]
        rrca
        and     3
        ld      b,a
        ld      hl,bgTileMap+VFENCE_INDEX
        ld      d,VFENCE_INDEX
        call    ((.animateFourFrames-L1512_Check2)+levelCheckRAM)
        ret

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


L1512_CheckFinished:
PRINTT "1512 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1512_LoadFinished - L1512_Load2)
PRINTT " / "
PRINTV (L1512_InitFinished - L1512_Init2)
PRINTT " / "
PRINTV (L1512_CheckFinished - L1512_Check2)
PRINTT "\n"

