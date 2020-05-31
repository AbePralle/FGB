; l0214.asm skippy's prison
; Generated 07.09.2000 by mlevel
; Modified  07.09.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level0214Section",ROMX
;---------------------------------------------------------------------

L0214_Contents::
  DW L0214_Load
  DW L0214_Init
  DW L0214_Check
  DW L0214_Map

dialog:
haiku_enterPrison_gtx:
  INCBIN "gtx\\intro_haiku\\haiku_enterPrison.gtx"

skippy_clues_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_clues.gtx"

skippy_letsGo_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_letsGo.gtx"

skippy_holdOn_gtx:
  INCBIN "gtx\\intro_haiku\\skippy_holdOn.gtx"

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0214_Load:
        DW ((L0214_LoadFinished - L0214_Load2))  ;size
L0214_Load2:
        call    ParseMap
        ret

L0214_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0214_Map:
INCBIN "..\\fgbeditor\\l0214_intro_haiku3.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
STATE_INITIALDRAW EQU 0
STATE_ENTER       EQU 1
STATE_CLUES       EQU 2
STATE_ALARMOFF    EQU 3
STATE_DIALOG_WAIT EQU   4
STATE_WAIT_DIALOG EQU   4
STATE_NEXTLEVEL   EQU 5
STATE_LEAVE       EQU 6
STATE_NORMAL      EQU 7

VAR_LIGHT   EQU 0
VAR_FLASHER EQU 1
VAR_PRISONOPEN EQU 2

LIGHTINDEX    EQU 37
FLASHERINDEX  EQU 42
GUARDINDEX    EQU 48
GOBLININDEX   EQU 49
SKIPPYINDEX   EQU 50

L0214_Init:
        DW ((L0214_InitFinished - L0214_Init2))  ;size
L0214_Init2:
        call    SetPressBDialog
        ld      a,BANK(dialog)
        ld      [dialogBank],a

        ld      a,[bgTileMap+LIGHTINDEX]  ;tile index of first light
        ld      [levelVars+VAR_LIGHT],a

        ld      a,[bgTileMap+FLASHERINDEX]  ;tile index of first light
        ld      [levelVars+VAR_FLASHER],a

        ld      bc,classCroutonDoctor
        ld      de,classGuard
        call    ChangeClass

        ;dest dest to unreachable so Skippy will pace around
        ld      c,SKIPPYINDEX
        call    GetFirst
        ld      hl,$d1ef
        call    SetActorDestLoc

        xor     a
        ld      [guardAlarm],a
        ldio    [mapState],a
        ld      [levelVars + VAR_PRISONOPEN],a

        ret

L0214_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0214_Check:
        DW ((L0214_CheckFinished - L0214_Check2))  ;size
L0214_Check2:
        call    ((.animateLights - L0214_Check2) + levelCheckRAM)
        call    ((.moveGuards - L0214_Check2) + levelCheckRAM)
        call    ((.checkOpenPrison - L0214_Check2) + levelCheckRAM)

        ldio    a,[mapState]
        cp      STATE_NORMAL
        jr      nz,.checkInitialDraw

        call    ((.checkNearSkippy - L0214_Check2) + levelCheckRAM)
        call    ((.addGoblins - L0214_Check2) + levelCheckRAM)

        ret

.checkInitialDraw
        cp      STATE_INITIALDRAW
        jr      nz,.checkAlarmOff

        ld      a,STATE_ENTER
        ldio    [mapState],a
        ret

.checkAlarmOff
        cp      STATE_ALARMOFF
        jr      nz,.checkDialogWait

        call    ((.checkNearSkippy - L0214_Check2) + levelCheckRAM)
        ;fade the palette if alarm just tripped
        ld      a,[guardAlarm]
        or      a
        ret     z

        ld      a,BANK(alarm_gbm)
        ld      hl,alarm_gbm
        call    InitMusic

        ld      hl,gamePalette
        ld      de,fadeCurPalette
        call    CopyPalette64
        ld      hl,((.darkRedPalette - L0214_Check2) + levelCheckRAM)
        ld      de,fadeFinalPalette
        call    CopyPalette32
        ld      de,fadeFinalPalette+64
        call    CopyPalette32
        ld      a,16
        call    FadeInit
        ld      de,gamePalette
        call    CopyPalette32
        ld      de,gamePalette+64
        call    CopyPalette32

        ;remove door
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d023
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      hl,$d242
        ld      [hl+],a
        ld      [hl+],a

        ld      a,STATE_NORMAL
        ;ldio    [mapState+1],a
        ;ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a

        ret

.checkDialogWait
        cp      STATE_DIALOG_WAIT
        jr      nz,.checkNextLevel

        call    CheckDialogContinue
        or      a
        ret     z

        call    RestoreIdle

        ld      bc,classDoNothing
        ld      de,classCroutonGoblin
        call    ChangeClass
        ld      bc,classDoNothing2
        ld      de,classGuard
        call    ChangeClass

        ldio    a,[mapState+1]
        ldio    [mapState],a
        ret

.checkNextLevel
        cp      STATE_NEXTLEVEL
        jr      nz,.checkEnter

        ld      hl,$0314
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,EXIT_D
        call    YankRemotePlayer
        ld      a,EXIT_D
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.checkEnter
        cp      STATE_ENTER
        jr      nz,.checkClues

        ;ld      a,1
        ;ld      [heroesIdle],a
        ;call    SetSpeakerToFirstHero
        ;ld      a,BANK(haiku_enterPrison_gtx)
        ;ld      de,haiku_enterPrison_gtx
        ;call    ShowDialogAtBottomNoWait
        ;ld      a,STATE_CLUES
        ;ldio    [mapState+1],a
        ;ld      a,STATE_DIALOG_WAIT
        ;ldio    [mapState],a

        xor     a
        ld      [heroesIdle],a
        ld      [allIdle],a
        call    SetSpeakerToFirstHero
        DIALOGBOTTOM haiku_enterPrison_gtx
        WAITDIALOG   STATE_CLUES
        ret

.checkClues
        cp      STATE_CLUES
        jr      nz,.checkLeave

        xor     a
        ld      [heroesIdle],a
        ld      [allIdle],a
        ld         c,SKIPPYINDEX
        DIALOGTOP  skippy_clues_gtx
        WAITDIALOG STATE_ALARMOFF
        ret

.checkLeave
        call    ((.addGoblins - L0214_Check2) + levelCheckRAM)
        ret

;----support routines-------------------------------------------------

.addGoblins
        ;normal state
        ;add goblins
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d023
        ld      a,[hl]
        or      a
        jr      nz,.afterAddGoblin1

        ld      c,GOBLININDEX
        call    CreateInitAndDrawObject

.afterAddGoblin1
        ld      hl,$d242
        ld      a,[hl]
        or      a
        jr      nz,.afterAddGoblin2

        ld      c,GOBLININDEX
        call    CreateInitAndDrawObject

.afterAddGoblin2
        ret

.checkOpenPrison
        ld      a,[levelVars + VAR_PRISONOPEN]
        or      a
        ret     nz

        ld      a,[hero0_index]
        call    ((.checkHeroOpen - L0214_Check2) + levelCheckRAM)
        ld      a,[hero1_index]
        call    ((.checkHeroOpen - L0214_Check2) + levelCheckRAM)
        ret

.checkHeroOpen
        or      a
        ret     z

        ld      c,a
        ld      [dialogSpeakerIndex],a
        call    GetFirst
        call    GetCurLocation
        ld      a,h
        cp      $d1
        ret     nz
        ld      a,l
        cp      $ca
        ret     nz

        ;open bars
        ld      a,1
        ld      [levelVars + VAR_PRISONOPEN],a
        ld      a,MAPBANK
        ldio    [$ff70],a
        ld      hl,$d1cc
        call    ((.clearBars - L0214_Check2) + levelCheckRAM)
        ld      hl,$d1ec
        call    ((.clearBars - L0214_Check2) + levelCheckRAM)
        ld      hl,((.openBarsSound - L0214_Check2) + levelCheckRAM)
        call    PlaySound
        ld      c,SKIPPYINDEX
        call    GetFirst
        ld      hl,$d1ef
        call    SetActorDestLoc
        ret

.openBarsSound
  DB 4,$00,$f4,$4f,$80

.clearBars
        ld      c,8
        xor     a
.clearBarsLoop
        ld      [hl+],a
        dec     c
        jr      nz,.clearBarsLoop
        ret

.checkNearSkippy
        ld      a,[hero0_index]
        call    ((.checkHeroNearSkippy - L0214_Check2) + levelCheckRAM)
        ld      a,[hero1_index]
        call    ((.checkHeroNearSkippy - L0214_Check2) + levelCheckRAM)
        ret

.checkHeroNearSkippy
        or      a
        ret     z

        ld      c,a
        call    GetFirst
        call    GetCurZone
        cp      3
        ret     nz

        call    SetSpeakerFromHeroIndex
        ld      a,[guardAlarm]
        or      a
        jr      nz,.alarmIsOn

        ld      a,1
        ld      [heroesIdle],a
        ld      bc,classCroutonGoblin
        ld      de,classDoNothing
        call    ChangeClass
        ld      bc,classGuard
        ld      de,classDoNothing2
        call    ChangeClass
        ld      a,BANK(skippy_letsGo_gtx)
        ld      de,skippy_letsGo_gtx
        ld      c,SKIPPYINDEX
        call    ShowDialogAtTopNoWait

        ld      a,STATE_NEXTLEVEL
        ldio    [mapState+1],a
        ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a
        ret

.alarmIsOn
        ld      a,1
        ld      [heroesIdle],a
        ld      bc,classCroutonGoblin
        ld      de,classDoNothing
        call    ChangeClass
        ld      bc,classGuard
        ld      de,classDoNothing2
        call    ChangeClass
        ld      a,BANK(skippy_holdOn_gtx)
        ld      de,skippy_holdOn_gtx
        ld      c,SKIPPYINDEX
        call    ShowDialogAtTopNoWait

        ld      a,STATE_LEAVE
        ldio    [mapState+1],a
        ld      a,STATE_DIALOG_WAIT
        ldio    [mapState],a
        ret

.animateLights

        ;animate dice lights
        ld      a,[levelVars+VAR_LIGHT]
        ld      b,a

        ;slow lights
        ldio    a,[updateTimer]
        swap    a
        and     %00000011
        add     b

        ld      hl,bgTileMap+LIGHTINDEX
        call    ((.updateTwoLights - L0214_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L0214_Check2) + levelCheckRAM)

        ;flasher
        ld      a,[guardAlarm]
        or      a
        jr      z,.afterAnimateFlasher

        ld      hl,levelVars+VAR_FLASHER
        ldio    a,[updateTimer]
        rrca
        rrca
        push    af
        and     %11
        add     [hl]
        ld      [bgTileMap+FLASHERINDEX],a
        pop     af
        and     %100
        jr      z,.afterAnimateFlasher
        ld      hl,((.klaxonSound - L0214_Check2) + levelCheckRAM)
        call    PlaySound
.afterAnimateFlasher
        ret

.moveGuards
        ;----move guards----------------------------------------------
        ld      c,GUARDINDEX
        call    GetFirst
        or      a
        jr      z,.afterMoveGuards

.moveGuard
        call    IsActorAtDest
        or      a
        jr      z,.nextGuard
        call    GetCurLocation
        push    bc
        push    de
        ld      d,h   ;save location
        ld      e,l
        ld      hl,((.patrolTable-L0214_Check2)+levelCheckRAM)
        ld      c,14  ;14 chances to find cur location

.tryNextLocation
        ld      a,[hl+]
        cp      e
        jr      nz,.notTheOne
        ld      a,[hl]
        cp      d
        jr      nz,.notTheOne

        ;found it
        pop     de
        pop     bc
        inc     hl
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a
        call    SetActorDestLoc
        jr      .nextGuard

.notTheOne
        inc     hl
        inc     hl
        inc     hl
        dec     c
        jr      nz,.tryNextLocation
        pop     de
        pop     bc

.nextGuard
        call    GetNextObject
        or      a
        jr      nz,.moveGuard

.afterMoveGuards
        ret

.patrolTable
        DW      $d042,$d046
        DW      $d046,$d0a6
        DW      $d0a6,$d0a2
        DW      $d0a2,$d042

        DW      $d0eb,$d16b
        DW      $d16b,$d0eb
        
        DW      $d0f1,$d171
        DW      $d171,$d0f1

        DW      $d166,$d126
        DW      $d126,$d166

        DW      $d204,$d202
        DW      $d202,$d204

        DW      $d206,$d208
        DW      $d208,$d206
        ;14 total

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L0214_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret

.darkRedPalette
DW      $0000, $0424, $0848, $0c6f
DW      $0000, $0005, $000f, $0c6f
DW      $0000, $080a, $0c4f, $0c6f
DW      $0000, $0025, $006f, $0c6f
DW      $0000, $0808, $082a, $0c6f
DW      $0000, $0027, $006f, $0c6f
DW      $0000, $0008, $002f, $0c6f
DW      $0000, $0809, $0c2f, $0c6f


.klaxonSound
        DB      4,$00,$f7,$5a,$c0

L0214_CheckFinished:
PRINTT "0214 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0214_LoadFinished - L0214_Load2)
PRINTT " / "
PRINTV (L0214_InitFinished - L0214_Init2)
PRINTT " / "
PRINTV (L0214_CheckFinished - L0214_Check2)
PRINTT "\n"

