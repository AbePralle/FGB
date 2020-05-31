; l1301.asm map view
; Generated 02.22.2001 by mlevel
; Modified  02.22.2001 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

VAR_MAPI EQU 0
VAR_MAPJ EQU 1


;---------------------------------------------------------------------
SECTION "Level1301Section",DATA
;---------------------------------------------------------------------

fgbmap_bg:
  INCBIN "..\\fgbpix\\appomattox\\fgbmap_big.bg"

L1301_Contents::
  DW L1301_Load
  DW L1301_Init
  DW L1301_Check
  DW L1301_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1301_Load:
        DW ((L1301_LoadFinished - L1301_Load2))  ;size
L1301_Load2:
        ld      a,BANK(fgbmap_bg)
        ld      hl,fgbmap_bg
        call    LoadCinemaBG

        ld      a,[appomattoxMapIndex]
        cp      $b7
        jp      z,((.onSpaceStation-L1301_Load2)+levelCheckRAM)

        ;ld      a,LEVELSTATEBANK
        ;ldio    [$ff70],a
        ;ld      a,[levelState+$2e]    ;off moon yet?
        ;or      a
        ;jp      z,((.onMoon-L1301_Load2)+levelCheckRAM)

        ;clear unvisited zones
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      hl,$d000
        ld      b,0
.outer  ld      c,0
.inner  ld      a,b    ;a = b*16 + c
        swap    a
        or      c
        ld      d,((levelState>>8)&$ff)
        ld      e,a
        ld      a,[de]
        or      a
        jr      nz,.continue

        ld      a,TILESHADOWBANK
        ldio    [$ff70],a
        push    hl
        ld      de,61
        xor     a
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        add     hl,de
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        add     hl,de
        ld      [hl+],a
        ld      [hl+],a
        ld      [hl+],a
        pop     hl
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a

.continue
        inc     hl
        inc     hl
        inc     hl
        inc     c
        ld      a,c
        cp      11
        jr      nz,.inner
        ld      de,64*3-33
        add     hl,de
        inc     b
        ld      a,b
        cp      11
        jr      nz,.outer

.findMapIndex
        ;figure out map index
        ld      a,[appomattoxMapIndex]
        cp      $c7
        jr      nz,.notFarmLanding
        ld      a,$31
.notFarmLanding
        ld      b,a
        and     %1111
        ld      c,a   ;*3
        rlca
        add     c
        ld      [levelVars+VAR_MAPI],a
        ld      [camera_i],a
        ld      c,a
        cp      9
        jr      c,.afterSub9
        ld      c,9
.afterSub9
        sub     c
        ld      [mapLeft],a
        ld      a,b
        swap    a
        and     %1111
        ld      c,a   ;*3
        rlca
        add     c
        ld      [levelVars+VAR_MAPJ],a
        ld      [camera_j],a
        ld      c,a
        cp      8
        jr      c,.afterSub8
        ld      c,8
.afterSub8
        sub     c
        ld      [mapTop],a

        ;constrain horizontal
        ld      a,[levelVars+VAR_MAPI]
        cp      23
        jr      c,.hokay
        ld      a,22 
        ld      [levelVars+VAR_MAPI],a
        ld      a,13
        ld      [mapLeft],a
.hokay

        ;constrain vertical
        ld      a,[levelVars+VAR_MAPJ]
        cp      24
        jr      c,.vokay
        ld      a,23 
        ld      [levelVars+VAR_MAPJ],a
        ld      a,15
        ld      [mapTop],a
.vokay

        ld      a,15
        call    SetupFadeFromStandard

.loop
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        ld      b,a

        ld      a,[levelVars+VAR_MAPI]
        ld      [camera_i],a
        ld      a,[levelVars+VAR_MAPJ]
        ld      [camera_j],a
.checkLeft
        xor     a
        bit     JOY_LEFT_BIT,b
        jr      z,.checkUp
        ld      [camera_i],a
.checkUp
        bit     JOY_UP_BIT,b
        jr      z,.checkRight
        ld      [camera_j],a
.checkRight
        ld      a,22
        bit     JOY_RIGHT_BIT,b
        jr      z,.checkDown
        ld      [camera_i],a
.checkDown
        bit     JOY_DOWN_BIT,b
        jr      z,.checkExit
        ld      a,23
        ld      [camera_j],a

.checkExit
        ld      a,b
        and     (JOY_A | JOY_B | JOY_START)
        jr      z,.loop

.exit
        ld      a,15
        call    SetupFadeToStandard
        call    WaitFade

        LDHL_CURHERODATA HERODATA_ENTERDIR
        ld      a,EXIT_W
        ld      [hl],a
        ld      hl,$1300
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,1
        ld      [timeToChangeLevel],a
        ret

.onSpaceStation
        ld      a,BANK(station_tactical_bg)
        ld      hl,station_tactical_bg
        call    LoadCinemaBG
        jr      .loadAlternate

.onMoon
        ld      a,BANK(moontact_bg)
        ld      hl,moontact_bg
        call    LoadCinemaBG

.loadAlternate
        ld      a,15
        call    SetupFadeFromStandard

.waitExit
        ld      a,1
        call    Delay
        ld      a,[myJoy]
        and     (JOY_A | JOY_B | JOY_START)
        jr      z,.waitExit
        jr      .exit

L1301_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L1301_Map:

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L1301_Init:
        DW ((L1301_InitFinished - L1301_Init2))  ;size
L1301_Init2:
        ret

L1301_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L1301_Check:
        DW ((L1301_CheckFinished - L1301_Check2))  ;size
L1301_Check2:
        ret

L1301_CheckFinished:
PRINTT "1301 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1301_LoadFinished - L1301_Load2)
PRINTT " / "
PRINTV (L1301_InitFinished - L1301_Init2)
PRINTT " / "
PRINTV (L1301_CheckFinished - L1301_Check2)
PRINTT "\n"

