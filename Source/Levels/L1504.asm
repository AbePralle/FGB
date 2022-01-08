; L1504.asm kidnap
; Generated 03.09.2001 by mlevel
; Modified  03.09.2001 by Abe Pralle

INCLUDE "Source/Defs.inc"
INCLUDE "Source/Levels.inc"

LIGHTINDEX     EQU 49
LADY_INDEX     EQU 60
CAPTAIN_INDEX  EQU 61

VAR_LIGHT  EQU 0

STATE_WAITFOREXIT EQU 2
STATE_FIRSTEXITED EQU 3
STATE_BOTHEXITED  EQU 4





;---------------------------------------------------------------------
SECTION "Level1504Gfx1",ROMX
;---------------------------------------------------------------------
at_gunpoint_bg:
  INCBIN "Data/Cinema/Distress/at_gunpoint.bg"

at_gunpoint_sprites_sp:
  INCBIN "Data/Cinema/Distress/at_gunpoint_sprites.sp"

;---------------------------------------------------------------------
SECTION "Level1504Section",ROMX
;---------------------------------------------------------------------

L1504_Contents::
  DW L1504_Load
  DW L1504_Init
  DW L1504_Check
  DW L1504_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1504_Load:
        DW ((L1504_LoadFinished - L1504_Load2))  ;size
L1504_Load2:
        call    State0To1
        cp      1
        jr      z,.cinema

        ;map
        jp      ParseMap

.cinema
        ld      a,1
        ld      [displayType],a
        xor     a
        ld      [scrollSprites],a
        ld      a,BANK(captain_okay_gtx)
        ld      [dialogBank],a

        call    LoadFont

        ;call    StopMusic
        ld      a,BANK(lady_flower_gbm)
        ld      hl,lady_flower_gbm
        call    InitMusic

;----Points gun at flour----------------------------------------------
        ld      a,BANK(at_gunpoint_bg)
        ld      hl,at_gunpoint_bg
        call    LoadCinemaBG

        ld      a,BANK(at_gunpoint_sprites_sp)
        ld      hl,at_gunpoint_sprites_sp
        call    LoadCinemaSprite

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      de,((.okay-L1504_Load2)+levelCheckRAM)
        call    SetDialogForward
        ld      de,((.endCinema-L1504_Load2)+levelCheckRAM)
        call    SetDialogSkip


        ld      c,80
.scrollGun
        ld      d,1
        call    ScrollSpritesRight
        ld      a,1
        call    Delay
        dec     c
        jr      nz,.scrollGun

        ld      a,60
        call    Delay

.okay
        call    ((.showGunForSure-L1504_Load2)+levelCheckRAM)
        ld      de,((.endCinema-L1504_Load2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM captain_okay_gtx

        ld      d,2
        LONGCALLNOARGS AnimateCaptainGunpoint

.endCinema
        call    ClearDialog
        call    ResetSprites
        ld      a,15
        call    SetupFadeToStandard

        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,EXIT_D
        ld      [hl],a
        ld      a,2
        ldio    [mapState],a
        dec     a
        ld      [timeToChangeLevel],a

        ret

.showGunForSure
        ld      hl,spriteOAMBuffer + 1
        ld      a,[hl]    ;negative of first sprite x pos + 8
        cpl
        add     9
        ld      d,a
        call    ScrollSpritesRight   ;is amount to scroll sprites

        ret

L1504_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1504_Map:
  INCBIN "Data/Levels/L1504_landing.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1504_Init:
        DW ((L1504_InitFinished - L1504_Init2))  ;size
L1504_Init2:
        ld      a,0
        ld      hl,((.heroInvisible - L1504_Init2) + levelCheckRAM)
        call    CheckEachHero

        ld      a,1
        ld      [heroesIdle],a

        ld      a,[bgTileMap+LIGHTINDEX]
        ld      [levelVars+VAR_LIGHT],a

        ld      c,CAPTAIN_INDEX
        call    GetFirst
        ld      hl,$d04A
        call    SetActorDestLoc

        ld      c,LADY_INDEX
        call    GetFirst
        ld      hl,$d04A
        call    SetActorDestLoc

        ld      a,16
        ld      [mapLeft],a
        ld      a,$11
        ldio    [scrollSpeed],a

        ret

.heroInvisible
        or      a
        ret     z
        ld      c,a
        call    GetFirst
        call    GetFacing
        ld      c,a
        call    RemoveFromMap
        ret

L1504_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1504_Check:
        DW ((L1504_CheckFinished - L1504_Check2))  ;size
L1504_Check2:
        call    ((.animateLandingLights-L1504_Check2)+levelCheckRAM)

        ldio    a,[mapState]
        cp      STATE_BOTHEXITED
        jr      z,.bothExited

        ld      c,CAPTAIN_INDEX
        call    ((.checkActorExit-L1504_Check2)+levelCheckRAM)

        ld      c,LADY_INDEX
        call    ((.checkActorExit-L1504_Check2)+levelCheckRAM)
        ret

.bothExited
        ld      de,((.downramp-L1504_Check2)+levelCheckRAM)
        call    SetDialogForward
        ld      de,((.endCinema-L1504_Check2)+levelCheckRAM)
        call    SetDialogSkip

        ld      c,60
.delayAfterExitGate
        ld      a,1
        call    Delay
        push    bc
        call    ((.animateLandingLights-L1504_Check2)+levelCheckRAM)
        pop     bc
        dec     c
        jr      nz,.delayAfterExitGate


.downramp
        call    ResetSprites
        call    BlackoutPalette

        ld      a,BANK(downramp_bg)
        ld      hl,downramp_bg
        call    LoadCinemaBG

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      de,((.ba_awhile-L1504_Check2)+levelCheckRAM)
        call    SetDialogForward

        ld      a,90
        call    Delay

.ba_awhile
        call    BlackoutPalette

        ld      a,BANK(ba_bg)
        ld      hl,ba_bg
        call    LoadCinemaBG

        ld      a,1
        call    SetupFadeFromBlack
        call    WaitFade

        ld      de,((.endCinema-L1504_Check2)+levelCheckRAM)
        call    SetDialogForward

        ld      c,0
        DIALOGBOTTOM ba_goneawhile_gtx

        ld      d,3
        LONGCALLNOARGS AnimateBA

        ;ld      a,15
        ;call    SetupFadeToStandard
        ;call    WaitFade

.endCinema
        call    ClearDialogSkipForward
        ;ld      a,15
        ;call    SetupFadeToBlack
        ;call    WaitFade

        ld      hl,$1100
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.checkActorExit
        call    GetFirst
        or      a
        ret     z       ;already exited

        call    GetCurLocation
        call    ConvertLocHLToXY

        ld      a,l     ;y coord
        cp      1
        ret     nz       ;not at gate exit

        ld      b,METHOD_DIE
        call    CallMethod

        ld      hl,disappearSound
        call    PlaySound

        ld      hl,mapState    ;at exit, mapState++
        inc     [hl]
        ld      a,[hl]
        cp      STATE_BOTHEXITED
        ret     nz

        ;close the gate
        ld      bc,$0202    ;blit the closed gate
        ld      de,$0901
        ld      hl,$2409
        call    BlitMap

        ld      a,5
        call    Delay
        ld      hl,closeGateSound
        call    PlaySound
        ret


.animateLandingLights
        ldio    a,[updateTimer]
        rrca
        rrca
        and     %11
        ld      b,a

        ld      a,[levelVars+VAR_LIGHT]
        ld      c,a
        ld      d,0

        ld      hl,bgTileMap+LIGHTINDEX
        call    ((.animateLight-L1504_Check2)+levelCheckRAM)
        call    ((.animateLight-L1504_Check2)+levelCheckRAM)
        call    ((.animateLight-L1504_Check2)+levelCheckRAM)
        call    ((.animateLight-L1504_Check2)+levelCheckRAM)
        ret

.animateLight
        ld      a,d
        add     b
        and     %11
        add     c
        ld      [hl+],a
        inc     d
        ret


L1504_CheckFinished:
PRINT "1504 Script Sizes (Load/Init/Check) (of $500):  "
PRINT (L1504_LoadFinished - L1504_Load2)
PRINT " / "
PRINT (L1504_InitFinished - L1504_Init2)
PRINT " / "
PRINT (L1504_CheckFinished - L1504_Check2)
PRINT "\n"

