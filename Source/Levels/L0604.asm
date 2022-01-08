; L0604.asm outside of tower
; Generated 10.20.2000 by mlevel
; Modified  10.20.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

;---------------------------------------------------------------------
SECTION "Level0604Section",ROMX
;---------------------------------------------------------------------

L0604_Contents::
  DW L0604_Load
  DW L0604_Init
  DW L0604_Check
  DW L0604_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0604_Load:
        DW ((L0604_LoadFinished - L0604_Load2))  ;size
L0604_Load2:
        call    ParseMap
        ret

L0604_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0604_Map:
INCBIN "Data/Levels/L0604_tower.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0604_Init:
        DW ((L0604_InitFinished - L0604_Init2))  ;size
L0604_Init2:
        ld      a,BANK(main_in_game_gbm)
        ld      hl,main_in_game_gbm
        call    InitMusic

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$3c]    ;rescue from tower
        or      a
        jr      nz,.afterRescue

        ;not rescued yet
        ld      hl,$0604
        call    SetJoinMap
        call    SetRespawnMap

        ;disable south exit
        ld      de,$4040
        ld      hl,mapExitLinks+EXIT_S*2
        ld      [hl],e
        inc     hl
        ld      [hl],d

.afterRescue
        ret

L0604_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0604_Check:
        DW ((L0604_CheckFinished - L0604_Check2))  ;size
L0604_Check2:
        ret

L0604_CheckFinished:
PRINT "0604 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0604_LoadFinished - L0604_Load2)
PRINT " / "
PRINT (L0604_InitFinished - L0604_Init2)
PRINT " / "
PRINT (L0604_CheckFinished - L0604_Check2)
PRINT "\n"

