; l1010.asm king grenade
; Generated 11.08.2000 by mlevel
; Modified  11.08.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


DICEINDEX     EQU 62
KING_INDEX    EQU 68

VAR_TALKED    EQU 0
VAR_DICELIGHT EQU 3

;---------------------------------------------------------------------
SECTION "Level1010Section",DATA
;---------------------------------------------------------------------

dialog:
l1010_amking_gtx:
  INCBIN "gtx\\talk\\l1010_amking.gtx"

l1010_cannotleave_gtx:
  INCBIN "gtx\\talk\\l1010_cannotleave.gtx"

l1010_readytogo_gtx:
  INCBIN "gtx\\talk\\l1010_readytogo.gtx"

L1010_Contents::
  DW L1010_Load
  DW L1010_Init
  DW L1010_Check
  DW L1010_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1010_Load:
        DW ((L1010_LoadFinished - L1010_Load2))  ;size
L1010_Load2:
        call    ParseMap
        ret

L1010_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1010_Map:
INCBIN "..\\fgbeditor\\l1010_kinggrenade.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1010_Init:
        DW ((L1010_InitFinished - L1010_Init2))  ;size
L1010_Init2:
        ;make gun turret friendly
        ld     bc,classTurret
        call   FindClassIndex
        ld     c,a
        call   GetFirst
        ld     a,GROUP_HERO
        call   SetGroup
        call   GetNextObject
        ld     a,GROUP_HERO
        call   SetGroup

        ld      a,[bgTileMap+DICEINDEX]  ;tile index of first light
        ld      [levelVars+VAR_DICELIGHT],a

        STDSETUPDIALOG

        ld      hl,$1100
        call    SetJoinMap
        call    SetRespawnMap

        ;already have King Grenade?
        xor     a
        ld      [levelVars+VAR_TALKED],a

        ld      a,[heroesAvailable]
        and     HERO_GRENADE_FLAG
        jr      z,.afterRemoveGrenade

        ld      a,1
        ld      [levelVars+VAR_TALKED],a

        ld      bc,classGeneric
        call    DeleteObjectsOfClass

.afterRemoveGrenade
        ret

L1010_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1010_Check:
        DW ((L1010_CheckFinished - L1010_Check2))  ;size
L1010_Check2:
        call    ((.animateDiceLights-L1010_Check2)+levelCheckRAM)
        call    ((.checkDialog-L1010_Check2)+levelCheckRAM)
        ret

.checkDialog
        ld      a,[levelVars+VAR_TALKED]
        or      a
        ret     nz

        ld      hl,((.checkHeroInZone-L1010_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroInZone
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.inZone

        xor     a
        ret

.inZone
        call    MakeIdle

        ld      de,((.afterDialog-L1010_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l1010_amking_gtx
        ld      c,KING_INDEX
        call    ShowDialogAtTop

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$cf]   ;been to generators?
        or      a
        jr      nz,.blownUp

        ld      de,l1010_cannotleave_gtx
        call    ShowDialogAtTop
        jr      .afterDialog

.blownUp
        ld      de,l1010_readytogo_gtx
        call    ShowDialogAtTop

.afterDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,1
        ld      [levelVars+VAR_TALKED],a

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$cf]   ;been to generators?
        or      a
        jr      z,.done

        ld      hl,heroesAvailable
        ld      a,[hl]
        or      HERO_GRENADE_FLAG
        ld      [hl],a

        xor     a
        call    LinkTransmitMemoryLocation

        ld      bc,classGeneric
        call    DeleteObjectsOfClass

.done
        ld      a,1
        ret

.animateDiceLights
        ;animate dice lights
        ld      a,[levelVars+VAR_DICELIGHT]
        ld      b,a

        ;slow lights
        ldio    a,[updateTimer]
        swap    a
        and     %00000011
        add     b

        ld      hl,bgTileMap+DICEINDEX
        call    ((.updateTwoLights - L1010_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L1010_Check2) + levelCheckRAM)
        ret

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L1010_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret

L1010_CheckFinished:
PRINTT "1010 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1010_LoadFinished - L1010_Load2)
PRINTT " / "
PRINTV (L1010_InitFinished - L1010_Init2)
PRINTT " / "
PRINTV (L1010_CheckFinished - L1010_Check2)
PRINTT "\n"

