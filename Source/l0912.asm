; l0912.asm monkey homeworld
; Generated 04.09.2001 by mlevel
; Modified  04.09.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/items.inc"

CROUTON_INDEX EQU 95
ORANGE_INDEX  EQU 98

VAR_SAWSIGN        EQU 0
VAR_TALKED         EQU 1
VAR_TALKEDTELEPORT EQU 2


;---------------------------------------------------------------------
SECTION "Level0912Section",DATA
;---------------------------------------------------------------------
dialog:
l0912_sign_gtx:
  INCBIN "gtx\\talk\\l0912_sign.gtx"

l0912_welcome_gtx:
  INCBIN "gtx\\talk\\l0912_welcome.gtx"

l0912_hero_revolt_gtx:
  INCBIN "gtx\\talk\\l0912_hero_revolt.gtx"

l0912_justit_gtx:
  INCBIN "gtx\\talk\\l0912_justit.gtx"

l0912_hero_losing_gtx:
  INCBIN "gtx\\talk\\l0912_hero_losing.gtx"

l0912_killpatsy_gtx:
  INCBIN "gtx\\talk\\l0912_killpatsy.gtx"

l0912_hero_brokenteleport_gtx:
  INCBIN "gtx\\talk\\l0912_hero_brokenteleport.gtx"

l0912_hero_startteleport_nopassword_gtx:
  INCBIN "gtx\\talk\\l0912_hero_startteleport_nopassword.gtx"

l0912_needpassword_gtx:
  INCBIN "gtx\\talk\\l0912_needpassword.gtx"

l0912_hero_startteleport_password_gtx:
  INCBIN "gtx\\talk\\l0912_hero_startteleport_password.gtx"

l0912_ba_givepassword_gtx:
  INCBIN "gtx\\talk\\l0912_ba_givepassword.gtx"

L0912_Contents::
  DW L0912_Load
  DW L0912_Init
  DW L0912_Check
  DW L0912_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0912_Load:
        DW ((L0912_LoadFinished - L0912_Load2))  ;size
L0912_Load2:
        call    ParseMap
        ret

L0912_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0912_Map:
INCBIN "..\\fgbeditor\\l0912_monkeyworld.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0912_Init:
        DW ((L0912_InitFinished - L0912_Init2))  ;size
L0912_Init2:
        ld      hl,$0912
        call    SetJoinMap
        call    SetRespawnMap

        STDSETUPDIALOG

        ld      a,BANK(jungle_gbm)
        ld      hl,jungle_gbm
        call    InitMusic

        xor     a
        ld      [levelVars+VAR_SAWSIGN],a
        ld      [levelVars+VAR_TALKED],a
        ld      [levelVars+VAR_TALKEDTELEPORT],a

        ld      bc,classGeneric
        ld      de,classTalker
        call    ChangeClass

        ld      a,ORANGE_INDEX
        ld      [dialogBalloonClassIndex],a

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$cb]   ;shot orange guy?
        cp      2
        jr      nz,.done

        ;revolt averted
        ;monkeys & croutons friends
        ld      b,GROUP_MONSTERD
        ld      c,GROUP_MONSTERA
        ld      a,1
        call    SetFOF

        ;monkeys & heroes friends
        ld      c,GROUP_HERO
        ld      a,1
        call    SetFOF

        ld      bc,classMonkey
        ld      de,classGeneric
        call    ChangeClass

        ;orange guy doesn't speak
        ld      a,1
        call    DisableDialogBalloons

.done
        ret

L0912_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0912_Check:
        DW ((L0912_CheckFinished - L0912_Check2))  ;size
L0912_Check2:
        call    ((.checkSign-L0912_Check2)+levelCheckRAM)
        call    ((.checkDialog-L0912_Check2)+levelCheckRAM)
        call    ((.checkTeleport-L0912_Check2)+levelCheckRAM)
        ret

.checkTeleport
        ld      a,[levelVars+VAR_TALKEDTELEPORT]
        or      a
        ret     nz

        ld      hl,((.checkHeroAtTeleport-L0912_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroAtTeleport
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      2
        jr      z,.atTeleport

        xor     a
        ret

.atTeleport
        ld      a,1
        ld      [levelVars+VAR_TALKEDTELEPORT],a
        call    MakeIdle

        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      a,[levelState+$cb]   ;shot orange guy?
        cp      2
        jp      nz,((.brokenTeleport-L0912_Check2)+levelCheckRAM)

        ;fixed teleport.  Separate for BA
        ld      a,HERO_BA_FLAG
        call    ClassIndexIsHeroType
        jr      nz,.baTeleport

        ;has password?
        ld      a,[levelState+$ca]   ;read book in monkey library?
        cp      2
        jr      z,.hasPassword

        ;push    bc
        ;ld      bc,ITEM_MONKEYPASSWD
        ;call    HasInventoryItem
        ;pop     bc
        ;jr      nz,.hasPassword

        ;no password
        ld      de,((.afterNoPasswordDialog-L0912_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l0912_hero_startteleport_nopassword_gtx
        call    ShowDialogAtBottom
        call    ClearDialog

        push    bc
        ld      c,CROUTON_INDEX
        ld      de,l0912_needpassword_gtx
        call    ShowDialogAtTop
        pop     bc

.afterNoPasswordDialog
        call    ClearDialogSkipForward
        call    MakeNonIdle

        ld      a,1
        ret

.hasPassword
        ld      de,((.afterHasPasswordDialog-L0912_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l0912_hero_startteleport_password_gtx
        call    ShowDialogAtBottom

.afterHasPasswordDialog
        jr      .activateTeleport

.baTeleport
        ld      de,((.afterBATeleportDialog-L0912_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l0912_hero_startteleport_nopassword_gtx
        call    ShowDialogAtBottom

        push    bc
        ld      c,CROUTON_INDEX
        ld      de,l0912_needpassword_gtx
        call    ShowDialogAtBottom
        pop     bc

        call    SetSpeakerFromHeroIndex
        ld      de,l0912_ba_givepassword_gtx
        call    ShowDialogAtBottom
.afterBATeleportDialog

.activateTeleport
        call    ClearDialog
        call    MakeNonIdle

        ;ld      a,15
        ;call    SetupFadeFromWhite

        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      hl,$1212
				ld      a,l
        ld      [curLevelIndex],a
				ld      a,h
        ld      [curLevelIndex+1],a

				ld      a,1
				ld      [timeToChangeLevel],a

        ld      a,1
        ret

.brokenTeleport
        ld      de,((.afterTeleportDialog-L0912_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l0912_hero_brokenteleport_gtx
        call    ShowDialogAtBottom

.afterTeleportDialog
        call    ClearDialog
        call    MakeNonIdle

        ld      a,1
        ret

.checkSign
        ld      a,[levelVars+VAR_SAWSIGN]
        or      a
        ret     nz

        ld      hl,((.checkHeroAtSign-L0912_Check2)+levelCheckRAM)
        xor     a
        call    CheckEachHero
        ret

.checkHeroAtSign
        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      3
        jr      z,.atSign

        xor     a
        ret

.atSign
        ld      a,1
        ld      [levelVars+VAR_SAWSIGN],a
        call    MakeIdle

        ld      de,((.afterSignDialog-L0912_Check2)+levelCheckRAM)
        call    SetDialogSkip

        call    SetSpeakerFromHeroIndex
        ld      de,l0912_sign_gtx
        call    ShowDialogAtBottom

.afterSignDialog
        call    ClearDialog
        call    MakeNonIdle

        ld      a,1
        ret

.checkDialog
        ld      hl,levelVars+VAR_TALKED
        ld      a,[hl]
        or      a
        ret     nz

.dialogOkay
        ld      a,[dialogNPC_speakerIndex]
        or      a
        ret     z

        ld      [hl],1  ;talked
        call    MakeIdle

        ld      de,((.afterDialog-L0912_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      de,l0912_welcome_gtx
        call    ShowDialogNPC

        ld      de,l0912_hero_revolt_gtx
        call    ShowDialogHero

        ld      de,l0912_justit_gtx
        call    ShowDialogNPC

        ld      de,l0912_hero_losing_gtx
        call    ShowDialogHero

        ld      de,l0912_killpatsy_gtx
        call    ShowDialogNPC

.afterDialog
        call    ClearDialog

        call    MakeNonIdle

        xor     a
        ld      [dialogNPC_speakerIndex],a
        ret


L0912_CheckFinished:
PRINTT "0912 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0912_LoadFinished - L0912_Load2)
PRINTT " / "
PRINTV (L0912_InitFinished - L0912_Init2)
PRINTT " / "
PRINTV (L0912_CheckFinished - L0912_Check2)
PRINTT "\n"

