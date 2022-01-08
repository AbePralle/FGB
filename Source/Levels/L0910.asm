; L0910.asm
; Generated 11.05.2000 by mlevel
; Modified  11.05.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"


;---------------------------------------------------------------------
SECTION "Level0910Section",ROMX
;---------------------------------------------------------------------

L0910_Contents::
  DW L0910_Load
  DW L0910_Init
  DW L0910_Check
  DW L0910_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0910_Load:
        DW ((L0910_LoadFinished - L0910_Load2))  ;size
L0910_Load2:
        call    ParseMap
        ret

L0910_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0910_Map:
INCBIN "Data/Levels/L0910_warzone.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0910_Init:
        DW ((L0910_InitFinished - L0910_Init2))  ;size
L0910_Init2:
        ;make gun turrets friendly
        ld     bc,classTurret
        call   FindClassIndex
        ld     c,a
        call   GetFirst

        ld     b,5
.setNext
        call   ((.setGroup-L0910_Init2)+levelCheckRAM)
        dec    b
        jr     nz,.setNext

        ret

.setGroup
        ld     a,GROUP_HERO
        call   SetGroup
        call   GetNextObject
        ret

L0910_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0910_Check:
        DW ((L0910_CheckFinished - L0910_Check2))  ;size
L0910_Check2:
        ret

L0910_CheckFinished:
PRINT "0910 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L0910_LoadFinished - L0910_Load2)
PRINT " / "
PRINT (L0910_InitFinished - L0910_Init2)
PRINT " / "
PRINT (L0910_CheckFinished - L0910_Check2)
PRINT "\n"

