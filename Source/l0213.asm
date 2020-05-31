; l0213.asm storming moonbase obliteration
; Generated 07.09.2000 by mlevel
; Modified  07.31.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"


;---------------------------------------------------------------------
SECTION "Level0213Section",ROMX
;---------------------------------------------------------------------

L0213_Contents::
  DW L0213_Load
  DW L0213_Init
  DW L0213_Check
  DW L0213_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0213_Load:
        DW ((L0213_LoadFinished - L0213_Load2))  ;size
L0213_Load2:
        call    ParseMap
        ret

L0213_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0213_Map:
INCBIN "Data/Levels/l0213_intro_ba3.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
VAR_LIGHT  EQU 0
VAR_STATIC  EQU 1
VAR_FACEON  EQU 2

MONITORINDEX EQU 36
LIGHTINDEX   EQU 40
FACEINDEX    EQU 44
STATICINDEX  EQU 48


L0213_Init:
        DW ((L0213_InitFinished - L0213_Init2))  ;size
L0213_Init2:
        ld      a,[bgTileMap+LIGHTINDEX]  ;tile index of first light
        ld      [levelVars+VAR_LIGHT],a
        ld      a,[bgTileMap+STATICINDEX]  ;tile index of monitor
        ld      [levelVars+VAR_STATIC],a
        xor     a
        ld      [levelVars+VAR_FACEON],a

        ;have general gyro face west
        ld      bc,classGeneralGyro
        call    FindClassIndex
        ld      c,a
        call    GetFirst
        ld      a,DIR_WEST
        call    SetFacing
        ld      b,METHOD_DRAW
        call    CallMethod

        ld      bc,classGeneralGyro
        ld      de,classDoNothing
        call    ChangeClass
        ret

L0213_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0213_Check:
        DW ((L0213_CheckFinished - L0213_Check2))  ;size
L0213_Check2:
        ;animate dice lights
        ld      a,[levelVars+VAR_LIGHT]
        ld      b,a

        ;slow lights
        ldio    a,[updateTimer]
        swap    a
        and     %00000011
        add     b

        ld      hl,bgTileMap+LIGHTINDEX
        call    ((.updateTwoLights - L0213_Check2) + levelCheckRAM)

        ;fast lights
        ldio    a,[updateTimer]
        swap    a
        rlca
        and     %00000011
        add     b
        call    ((.updateTwoLights - L0213_Check2) + levelCheckRAM)

        ;animate static
        ld      a,[levelVars+VAR_STATIC]
        ld      b,a
        ldio    a,[updateTimer]
        rrca
        and     %00000010
        add     b
        ld      hl,bgTileMap+STATICINDEX
        ld      [hl+],a
        inc     a
        ld      [hl+],a

        ;----cycle monitor displays-----------------------------------
        ld      a,MAPBANK
        ldio    [$ff70],a

        ;pick a random location
        ld      a,22
        call    GetRandomNumZeroToN

        ;ld      a,31
        ;call    GetRandomNumMask
        ;cp      23
        ;jr      nc,.afterScreen

        sla     a
        ld      d,0
        ld      e,a
        ld      hl,((.monitorLocations-L0213_Check2)+levelCheckRAM)
        add     de
        ld      a,[hl+]
        ld      h,[hl]
        ld      l,a

        ;is this static?
        ld      a,[hl]
        cp      STATICINDEX
        jr      z,.staticToFace

        ;is this the face?
        ld      a,[hl]
        cp      FACEINDEX
        jr      z,.turnOffFace

        ;is the face on elsewhere?
        ld      a,[levelVars+VAR_FACEON]
        or      a
        jr      nz,.afterScreen    ;face is on; skip

        ;turn this to static to become the face
        ld      a,1
        ld      [levelVars+VAR_FACEON],a
        ld      a,STATICINDEX
        jr      .pickedScreen

.turnOffFace
        xor     a
        ld      [levelVars+VAR_FACEON],a
        ld      a,MONITORINDEX   ;monitor
        jr      .pickedScreen

.staticToFace
        ld      a,FACEINDEX      ;face
.pickedScreen
        ld      [hl+],a
        inc     a
        ld      [hl+],a
        inc     a
        cp      STATICINDEX+2
        jr      nz,.afterStaticCheck
        sub     2
.afterStaticCheck
        ld      de,30     ;map pitch
        add     hl,de
        ld      [hl+],a
        inc     a
        ld      [hl+],a

.afterScreen
        ;----Check to see if confronting General Gyro-----------------
        ld      hl,hero0_data
        call    ((.checkConfrontGyro - L0213_Check2) + levelCheckRAM)
        ld      hl,hero1_data
        call    ((.checkConfrontGyro - L0213_Check2) + levelCheckRAM)
        ret

.updateTwoLights
        ld      [hl+],a
        call    ((.incCount4 - L0213_Check2) + levelCheckRAM)
        ld      [hl+],a
        ret

.incCount4
        sub     b
        inc     a
        and     %00000011
        add     b
        ret

.checkConfrontGyro
        inc     hl
        ld      a,[hl-]
        or      a    ;look at the hero class index I've been given
        ret     z    ;not present if zero

        ld      c,a        ;save class index
        ld      a,[hl]     ;get my joy index
        ld      [dialogJoyIndex],a       ;save that in case I talk

        ld      de,HERODATA_TYPE
        add     hl,de
        ld      a,[hl]                   ;get my type
        ld      [dialogSpeakerIndex],a   ;save that for talking too

        ;get my object then my zone
        call    GetFirst
        call    GetCurZone

        cp      9       ;in same zone as Gyro?
        ret     nz      ;all for naught

        ld      hl,$1302    ;next level
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        call    YankRemotePlayer
        ld      a,1
        ld      [timeToChangeLevel],a
        ret


.monitorLocations
DW $d021,$d033,$d056,$d058,$d05a,$d05c   ;6
DW $d262,$d264,$d266                     ;3
DW $d2d2,$d312,$d352,$d392               ;4
DW $d255,$d295,$d2d5,$d315,$d355,$d395   ;6
DW $d25c,$d29c,$d2dc,$d31c               ;4   23

L0213_CheckFinished:

PRINTT "0213 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0213_LoadFinished - L0213_Load2)
PRINTT " / "
PRINTV (L0213_InitFinished - L0213_Init2)
PRINTT " / "
PRINTV (L0213_CheckFinished - L0213_Check2)
PRINTT "\n"

