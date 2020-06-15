; L1500.asm
; Generated 03.22.2001 by mlevel
; Modified  03.22.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level1500Section",ROMX
;---------------------------------------------------------------------

deathscreen_bg:
  INCBIN "Data/Cinema/CharSelect/deathscreen.bg"

L1500_Contents::
  DW L1500_Load
  DW L1500_Init
  DW L1500_Check
  DW L1500_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1500_Load:
        DW ((L1500_LoadFinished - L1500_Load2))  ;size
L1500_Load2:
        ;ld      a,1
        ;ld      [displayType],a
        ;xor     a
        ;ld      [scrollSprites],a

        ;fade to black
        ;ld      a,15
        ;call    SetupFadeToBlack
        ;call    WaitFade

        call    ResetSprites
        ld      a,BANK(deathscreen_bg)
        ld      hl,deathscreen_bg
        call    LoadCinemaBG

        ld      a,BANK(death_gbm)
        ld      hl,death_gbm
        call    InitMusic

        ld      a,30
        call    SetupFadeFromStandard
        ld      d,0
        call    ((.setEnvCounter-L1500_Load2)+levelCheckRAM)

.loop
        dec     c
        jr      nz,.afterChangeEnv
        dec     b
        jr      nz,.afterChangeEnv

        call    ((.setEnvCounter-L1500_Load2)+levelCheckRAM)
        ld      a,d
        add     1
        cp      6
        jr      nz,.afterResetEffectType

        xor     a

.afterResetEffectType
        ld      d,a
        cp      4
        jr      c,.validEffect

        cpl
        add     7

.validEffect
        ld      [envEffectType],a

.afterChangeEnv
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     %11110000
        jr      z,.loop

        ;ld      de,HERODATA_ENTERDIR
        ;add     hl,de
        ;ld      a,EXIT_D
        ;ld      [hl],a

        ld       a,15
        call     SetupFadeToBlack
        call     WaitFade
        call     ResetSprites

        ;----respawn at the appropriate map----
        ld      hl,curLevelIndex
        ld      a,[respawnMap]
        ld      [hl+],a
        ld      a,[respawnMap+1]
        ld      [hl+],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.setEnvCounter
        ld      bc,$02d8
        ret

L1500_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1500_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1500_Init:
        DW ((L1500_InitFinished - L1500_Init2))  ;size
L1500_Init2:
        ret

L1500_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1500_Check:
        DW ((L1500_CheckFinished - L1500_Check2))  ;size
L1500_Check2:
        ret

L1500_CheckFinished:
PRINTT "1500 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1500_LoadFinished - L1500_Load2)
PRINTT " / "
PRINTV (L1500_InitFinished - L1500_Init2)
PRINTT " / "
PRINTV (L1500_CheckFinished - L1500_Check2)
PRINTT "\n"

