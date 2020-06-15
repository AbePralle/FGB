; L0010.asm mouse teleport room
; Generated 11.06.2000 by mlevel
; Modified  11.06.2000 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"
INCLUDE "Source/Items.inc"

BOULDER_INDEX   EQU 1
MASK_INDEX      EQU 68
MOUSE_INDEX     EQU 69
UBERMOUSE_INDEX EQU 71

VAR_CONTROLS EQU 0
VAR_CRATE       EQU 1
VAR_CRATETAKEN  EQU 2

STATE_MASKTAKEN EQU 2


;---------------------------------------------------------------------
SECTION "Level0010Section",ROMX
;---------------------------------------------------------------------

dialog:
L0010_mattermitter_gtx:
  INCBIN "Data/Dialog/Talk/L0010_mattermitter.gtx"

L0010_foundmask_gtx:
  INCBIN "Data/Dialog/Talk/L0010_foundmask.gtx"

L0010_crate_gtx:
  INCBIN "Data/Dialog/Talk/L0010_crate.gtx"

L0010_Contents::
  DW L0010_Load
  DW L0010_Init
  DW L0010_Check
  DW L0010_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0010_Load:
        DW ((L0010_LoadFinished - L0010_Load2))  ;size
L0010_Load2:
        call    ParseMap
        ret

L0010_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0010_Map:
INCBIN "Data/Levels/L0010_serpent.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0010_Init:
        DW ((L0010_InitFinished - L0010_Init2))  ;size
L0010_Init2:
        STDSETUPDIALOG
        xor     a
        ld      [levelVars+VAR_CONTROLS],a

        ;remove mask if taken
        ldio    a,[mapState]
        cp      STATE_MASKTAKEN
        jr      nz,.checkRemoveCrate

        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d168],a

.checkRemoveCrate
        xor     a
        ld      hl,levelVars+VAR_CRATETAKEN
        ld      [hl],a

        ;remove create if taken already
        ld      bc,ITEM_BAHIGHIMPACT
        call    HasInventoryItem
        jr      z,.doneRemoveCreate

        ld      a,1
        ld      [hl],a
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d1f3],a

.doneRemoveCreate

        ret

L0010_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0010_Check:
        DW ((L0010_CheckFinished - L0010_Check2))  ;size
L0010_Check2:
        call    ((.checkUberMouseOpenWall-L0010_Check2)+levelCheckRAM)
        call    ((.checkSign-L0010_Check2)+levelCheckRAM)
        ldio    a,[mapState]
        cp      STATE_MASKTAKEN
        jr      z,.checkControls

        xor     a
        ld      hl,((.checkFoundMask-L0010_Check2)+levelCheckRAM)
        call    CheckEachHero

.checkControls
        ;can't operate if ubermouse half-in
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[$d064]
        cp      UBERMOUSE_INDEX
        ret     z

        ld      a,1
        ld      hl,((.heroAtControls-L0010_Check2)+levelCheckRAM)
        call    CheckEachHero

        ld      hl,levelVars + VAR_CONTROLS
        cp      [hl]
        jp      z,((.afterResetControls-L0010_Check2)+levelCheckRAM)

        ld      [hl],a
        or      a
        jp      z,((.afterResetControls-L0010_Check2)+levelCheckRAM)

        ;activate teleport!
        ld      de,((.afterTportDialog-L0010_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerFromHeroIndex
        ld      de,L0010_mattermitter_gtx
        call    ShowDialogAtBottom
.afterTportDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,15
        call    SetupFadeFromWhite

        ld      a,1
        call    Delay

        ld      hl,$d063
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d064
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d083
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d084
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d148
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d149
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d168
        call    ((.package-L0010_Check2)+levelCheckRAM)
        ld      hl,$d169
        call    ((.package-L0010_Check2)+levelCheckRAM)

        ld      de,$d063
        ld      hl,$d148
        call    ((.exchange-L0010_Check2)+levelCheckRAM)
        ld      de,$d064
        ld      hl,$d149
        call    ((.exchange-L0010_Check2)+levelCheckRAM)
        ld      de,$d083
        ld      hl,$d168
        call    ((.exchange-L0010_Check2)+levelCheckRAM)
        ld      de,$d084
        ld      hl,$d169
        call    ((.exchange-L0010_Check2)+levelCheckRAM)

        ;unpack in reverse order
        ld      de,$d169
        ld      hl,$d084
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)
        ld      de,$d168
        ld      hl,$d083
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)
        ld      de,$d149
        ld      hl,$d064
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)
        ld      de,$d148
        ld      hl,$d063
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)

        ld      hl,$d169
        ld      de,$d084
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)
        ld      hl,$d168
        ld      de,$d083
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)
        ld      hl,$d149
        ld      de,$d064
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)
        ld      hl,$d148
        ld      de,$d063
        call    ((.unpackage-L0010_Check2)+levelCheckRAM)

.afterResetControls
        ret

.checkSign
        ld      a,1
        ld      hl,((.heroAtSign-L0010_Check2)+levelCheckRAM)
        call    CheckEachHero

        ld      hl,levelVars + VAR_CRATE
        cp      [hl]
        ret     z

        ld      [hl],a
        or      a
        ret     z

        ld      a,[levelVars+VAR_CRATETAKEN]
        or      a
        ret     nz

        ld      de,((.afterSignDialog-L0010_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerFromHeroIndex
        ld      de,L0010_crate_gtx
        call    ShowDialogAtBottom
.afterSignDialog
        call    ClearDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ;remove create if BA
        ld      a,HERO_BA_FLAG
        call    ClassIndexIsHeroType
        ret     z

        ld      a,1
        ld      [levelVars+VAR_CRATETAKEN],a
        ld      a,MAPBANK
        ldio    [$ff70],a
        xor     a
        ld      [$d1f3],a
        ld      bc,ITEM_BAHIGHIMPACT
        call    AddInventoryItem
        ld      hl,baUpgrades
        set     UPGRADE_BAHIGHIMPACT,[hl]

        ret

.heroAtSign
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      5
        jp      z,((.returnTrue-L0010_Check2)+levelCheckRAM)

        ;return false
        xor     a
        ret


.checkUberMouseOpenWall
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[$d10d]
        cp      UBERMOUSE_INDEX
        ret     nz

        ld      a,[$d10f]
        cp      BOULDER_INDEX
        ret     nz

        xor     a
        ld      [$d10f],a
        ld      [$d12f],a

        ld      a,15
        ldio    [jiggleDuration],a
        ld      hl,bombSound
        call    PlaySound
        ret

.package
        ;pick up object at [hl], remove it from map, place index back
        ;at [hl]
        ld      a,MAPBANK
        ldio    [$ff70],a
        ldio    a,[firstMonster]
        ld      b,a
        ld      a,[hl]
        cp      b
        ret     c       ;is a BG tile

        push    hl
        push    hl
        call    EnsureTileIsHead
        ld      c,a
        push    hl
        pop     de
        call    FindObject
        call    SetObjWidthHeight
        call    GetFacing
        push    bc
        ld      c,a
        call    RemoveFromMap
        pop     bc
        pop     hl
        call    SetCurLocation
        ;turn off split bit
        call    GetFacing
        res     2,a
        call    SetFacing
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,c
        pop     hl
        ld      [hl],a
        ret

.unpackage
        ;hl - location object is at
        ;de - object's previous location
        ld      a,MAPBANK
        ldio    [$ff70],a
        ldio    a,[firstMonster]
        ld      b,a
        ld      a,[hl]
        cp      b
        ret     c       ;is a BG tile

        push    hl
        ld      c,a
        call    FindObject
        pop     hl
        call    SetCurLocation

        ld      b,METHOD_DRAW
        call    CallMethod
        ret

.exchange
        ;exchange obj/items at [hl] with [de]
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        ld      b,a
        ld      a,[de]
        ld      [hl],a
        ld      a,b
        ld      [de],a
        ret

.heroAtControls
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.returnTrue

.returnFalse
        xor     a
        ret

.returnTrue
        ld      a,1
        ret

.checkFoundMask
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      4
        jr      z,.checkZone4
        cp      3
        jr      nz,.returnFalse   ;not near mask at all

.checkZone3
        ld      hl,$d083
        jr      .checkHLForMask

.checkZone4
        ld      hl,$d168
.checkHLForMask
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      a,[hl]
        cp      MASK_INDEX
        jr      nz,.returnFalse   ;mask not here

.foundMask
        ;remove mask from map
        ld      [hl],0

        ld      de,((.afterDialog-L0010_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    MakeIdle

        call    SetSpeakerFromHeroIndex
        ld      de,L0010_foundmask_gtx
        call    ShowDialogAtBottom
.afterDialog
        call    ClearDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      bc,ITEM_SPOREMASK
        call    AddInventoryItem

        ld      a,STATE_MASKTAKEN
        ldio    [mapState],a

        ld      a,1
        ret

L0010_CheckFinished:
PRINTT "0010 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0010_LoadFinished - L0010_Load2)
PRINTT " / "
PRINTV (L0010_InitFinished - L0010_Init2)
PRINTT " / "
PRINTV (L0010_CheckFinished - L0010_Check2)
PRINTT "\n"

