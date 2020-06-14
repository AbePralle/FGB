;L1101.asm main menu
;Abe Pralle 3.4.2000

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"
INCLUDE "Source/start.inc"


INTCLK EQU $83
EXTCLK EQU $82

;JOINMAP EQU $1102
;JOINMAP EQU $1100
JOINDIR EQU EXIT_D

;JOINMAP EQU $0015
;JOINDIR EQU EXIT_W

;---------------------------------------------------------------------
SECTION "LevelsSection1101_data2",ROMX
;---------------------------------------------------------------------
bullet_sp:
  INCBIN "../fgbpix/menu/menucursor.sp"


;---------------------------------------------------------------------
SECTION "LevelsSection1101",ROMX
;---------------------------------------------------------------------

L1101_Contents::
  DW L1101_Load
  DW L1101_Init
  DW L1101_Check
  DW L1101_Map

mainmenu_bg:
  INCBIN "../fgbpix/menu/fgbmenu.bg"


;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L1101_Load:
        DW ((L1101_LoadFinished - L1101_Load2))  ;size
L1101_Load2:
        ;reset all 256 mapState entries to zero
        ld      a,LEVELSTATEBANK
        ldio    [$ff70],a
        ld      hl,levelState
        xor     a
.resetStates
        ld      [hl+],a
        cp      l
        jr      nz,.resetStates

        ;reveal river tiles on computer map
        ld      a,1
        ld      [levelState+0*16+1],a
        ld      [levelState+1*16+1],a
        ld      [levelState+2*16+1],a
        ld      [levelState+2*16+2],a
        ld      [levelState+3*16+2],a
        ld      [levelState+3*16+2],a
        ld      [levelState+4*16+2],a
        ld      [levelState+5*16+2],a
        ld      [levelState+6*16+2],a
        ld      [levelState+7*16+2],a
        ld      [levelState+8*16+2],a
        ld      [levelState+9*16+2],a
        ld      [levelState+10*16+2],a
        ld      [levelState+7*16+1],a

        ;set heroes' health to zero so that it's reset first time
        ;and puffball count to zero
        xor     a
        ld      [hero0_health],a
        ld      [hero1_health],a
        ld      [hero0_puffCount],a
        ld      [hero1_puffCount],a

        ld      a,BANK(mainmenu_bg)
        ld      hl,mainmenu_bg
        call    LoadCinemaBG

        ld      a,BANK(bullet_sp)
        ld      hl,bullet_sp
        call    LoadCinemaSprite

        ld      hl,(bullet_y + (levelCheckRAM-L1101_Load2))
        xor     a
        ld      [hl+],a    ;bullet_y
        ld      [hl+],a    ;cur_choice
        ld      a,1
        ld      [hl+],a    ;hasSavedGame
        xor     a
        ld      [hl+],a    ;hasLinkMaster


        ld      a,[amLinkMaster]
        bit     7,a
        jr      nz,.afterTerminateLink

.sendTerminate
        ld      a,LTERMINATE
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.sendTerminate

        ld      a,$ff
        ld      [amLinkMaster],a

.afterTerminateLink
        ;setup attempt to link as slave
        ld      a,$aa
        ldio    [$ff01],a  ;exchange data
        ld      a,EXTCLK 
        ldio    [$ff02],a  ;ready for xchg, use remote clock  

        ;ld      d,4
        ;call    ScrollSpritesRight
        call    (.drawMenu + (levelCheckRAM-L1101_Load2))
        call    RedrawMap

        ld      a,16
        call    SetupFadeFromStandard
        call    WaitFade


.mainloop
        call    UpdateObjects
        call    (.drawMenu + (levelCheckRAM-L1101_Load2))
        call    RedrawMap

        ld      a,[amLinkMaster]
        cp      $ff       ;do I care about attempting link as a slave?
        jr      nz,.afterUpdateLinkStatus

        ldio    a,[$ff02]
        and     $80
        jr      nz,.afterUpdateLinkStatus   ;no change

        ld      a,[$ff01]   ;got something useful?
        cp      $55
        jr      z,.become_slave

.resetLinkAttempt
        ld      a,$aa
        ldio    [$ff01],a
        ld      a,EXTCLK
        ldio    [$ff02],a
        jr      .afterUpdateLinkStatus         ;no change

.become_slave
        ;We transferred a byte!  I just became somebody's bitch.
        xor     a
        ld      [amLinkMaster],a  ;I'm a slave
        ld      a,1
        ld      [(hasLinkMaster + (levelCheckRAM-L1101_Load2))],a
        ld      a,2  ;force bullet to "join game"
        ld      [(cur_choice + (levelCheckRAM-L1101_Load2))],a

        ;disabled load game
        xor     a
        ld      [(hasSavedGame + (levelCheckRAM-L1101_Load2))],a

        ;kill some time
        ld      a,$80
.killTime
        push    af
        pop     af
        dec     a
        jr      nz,.killTime

.afterUpdateLinkStatus
        ld      hl,(cur_choice + (levelCheckRAM-L1101_Load2))
        ld      a,[myJoy]
        and     JOY_DOWN
        jr      z,.checkJoyUp

        ld      a,[hl]
        or      a
        jr      nz,.checkDownWasLoad

.checkDownWasNewGame
        ;down, cursor was on "new game"
        inc     [hl]
        ld      a,[(hasSavedGame + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.downWasLoad
        jr      .checkJoyDone

.checkDownWasLoad
        cp      1
        jr      nz,.checkDownWasJoin

.downWasLoad
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      nz,.downOkayToJoin

        ld      [hl],0      ;set bullet to new game
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.checkJoyDone
        jr      .checkDownWasNewGame

.downOkayToJoin
        inc     [hl]
        jr      .checkJoyDone

.checkDownWasJoin
        xor     a
        ld      [hl],a
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.checkJoyDone
        jr      .checkDownWasNewGame

.checkJoyUp
        ld      a,[myJoy]
        and     JOY_UP
        jr      z,.checkJoyButtons

        ld      a,[hl]
        or      a
        jr      nz,.checkUpWasLoad

        ld      [hl],2
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.upWasJoin

.checkUpWasLoad
        cp      1
        jr      nz,.upWasJoin
        jr      .upWasLoad

.upWasNewGame
        jr      .checkJoyDone

.upWasLoad
        dec     [hl]         ;set to new game
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.checkJoyDone
        ld      [hl],2
        jr      .checkJoyDone

.upWasJoin
        dec     [hl]
        ld      a,[(hasSavedGame + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.upWasLoad

.checkJoyDone
        call    (.drawMenu + (levelCheckRAM-L1101_Load2))
        ld      a,JOY_DOWN | JOY_UP
        push    hl
        ld      hl,myJoy
        call    WaitInputZero
        pop     hl

.checkJoyButtons
        ld      a,[myJoy]
        and     %11110000
        jr      nz,.haveButtons
        jp      (.mainloop + (levelCheckRAM-L1101_Load2))

.haveButtons
        ;if starting a new game w/no link, make me the master
        ld      a,[amLinkMaster]
        cp      $ff
        jr      nz,.afterMakeMaster
        or      a
        jr      z,.afterMakeMaster
        ld      a,$fe     ;no link/master
        ld      [amLinkMaster],a

.afterMakeMaster
        ld      a,%11111111
        push    hl
        ld      hl,myJoy
        call    WaitInputZero
        pop     hl
        ld      a,16
        call    SetupFadeToStandard
        call    WaitFade

        ld      a,[(cur_choice + (levelCheckRAM-L1101_Load2))]
        cp      2
        jp      z,((.joinGame-L1101_Load2)+levelCheckRAM)

        cp      1
        jr      z,.loadGame

        ;begin a new game
        LONGCALLNOARGS RandomizeFlightCodes

        ;save game 
        ;call    ((.saveGame-L1101_Load2)+levelCheckRAM)

        ld      hl,MENUTOMAP
        jp      ((.setNextLevel-L1101_Load2)+levelCheckRAM)

.loadGame
        ld      a,$0a       ;enable save ram access
        ld      [0],a

        ;if number of flight codes is zero, must not be a saved game here
        ld      a,[$a000+9+16+256]
        or      a
        jr      z,.afterLoadGame

        ld      hl,$a000    ;start of ram area $a000-$bfff
        ld      de,gameState
        ld      bc,9
        xor     a
        call    ((.loadData-L1101_Load2)+levelCheckRAM)

        ld      de,inventory
        ld      bc,16
        xor     a
        call    ((.loadData-L1101_Load2)+levelCheckRAM)

        ld      de,levelState
        ld      bc,256
        ld      a,LEVELSTATEBANK
        call    ((.loadData-L1101_Load2)+levelCheckRAM)

        ld      de,flightCode
        ld      bc,256
        ld      a,FLIGHTCODEBANK
        call    ((.loadData-L1101_Load2)+levelCheckRAM)

.afterLoadGame
        xor     a
        ld      [heroesUsed],a

        xor     a
        ld      [0],a       ;disable save ram to prevent false writes on powerdown

        ld      a,LEVELSTATEBANK  ;analyze level states to see if we're somewhere special
        ldio    [$ff70],a
        ld      hl,$1100            ;level # of char select
        ld      a,[levelState+$2f]  ;distress
        or      a
        ;after distress cinema, start at char select
        jp      nz,((.setNextLevel-L1101_Load2)+levelCheckRAM)

        ld      hl,$1102            ;intro missions
        jp      ((.setNextLevel-L1101_Load2)+levelCheckRAM)

.loadData
        ;copies "bc" # of bytes from [hl] to [de] in bank "a"
        ldio    [$ff70],a
.loadLoop
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     bc
        xor     a
        cp      b
        jr      nz,.loadLoop
        cp      c
        jr      nz,.loadLoop
        ret

.saveGame
        ld      a,$0a       ;enable save ram access
        ld      [0],a

        ld      hl,$a000    ;start of save area $a000-$bfff
        ld      de,gameState
        ld      bc,9
        xor     a
        call    ((.saveData-L1101_Load2)+levelCheckRAM)

        ld      de,inventory
        ld      bc,16
        xor     a
        call    ((.saveData-L1101_Load2)+levelCheckRAM)

        ld      de,levelState
        ld      bc,256
        ld      a,LEVELSTATEBANK
        call    ((.saveData-L1101_Load2)+levelCheckRAM)

        ld      de,flightCode
        ld      bc,256
        ld      a,FLIGHTCODEBANK
        call    ((.saveData-L1101_Load2)+levelCheckRAM)

        xor     a
        ld      [0],a       ;disable save ram to prevent false writes on powerdown
        ret

.saveData
        ;copies "bc" # of bytes from [de] to [hl] in bank "a"
        ldio    [$ff70],a
.saveLoop
        ld      a,[de]
        inc     de
        ld      [hl+],a
        dec     bc
        xor     a
        cp      b
        jr      nz,.saveLoop
        cp      c
        jr      nz,.saveLoop
        ret



.joinGame
;----LINK TEST BEGIN--------------------------------------------------
IF 0
        ld      a,LLINKTEST
        call    ExchangeByte
        ld      a,1
        ld      bc,$1000
        ld      hl,$d000
        di

        ld      a,4
.transfer32k
        push    af
        ld      a,1
        call    ReceiveData

        ld      a,1
        call    TransmitData
        pop     af
        dec     a
        jr      nz,.transfer32k

;di
;.infi5   jr      .infi5
rst $00
ENDC

;----LINK TEST END----------------------------------------------------
        ;get the current game state
        ld      a,LGETGAMESTATE
        call    ExchangeByte
        call    CheckSimultaneousLCC
        jr      nz,.joinGame

        ld      hl,.bailOutAddress
        xor     a
        call    SetLinkBailOutAddress

        ld      hl,gameState
        ld      bc,5
        xor     a
        call    ReceiveData

        ld      hl,levelState
        ld      bc,256
        ld      a,LEVELSTATEBANK
        call    ReceiveData

        ;inventory
        ld      hl,inventory
        ld      bc,16
        xor     a
        call    ReceiveData

        ;flight codes
        ld      hl,flightCode
        ld      bc,256
        ld      a,FLIGHTCODEBANK
        call    ReceiveData

        ld      hl,hero0_data
        ld      bc,HERODATASIZE*2
        xor     a
        call    ReceiveData

        ld      a,(hero1_data & $ff)
        ld      [curHeroAddressL],a

        ld      a,[appomattoxMapIndex]
        call    ReceiveByte

        ;get map to join
        call    ReceiveByte
        ld      [joinMap],a
        ld      l,a
        call    ReceiveByte
        ld      [joinMap+1],a
        ld      h,a

.setNextLevel
        ld      a,h
        ld      [curLevelIndex+1],a
        ld      a,l
        ld      [curLevelIndex],a
        ld      a,JOINDIR
        ld      [hero0_enterLevelFacing],a
        ld      [hero1_enterLevelFacing],a

        ld      a,1
        ld      [timeToChangeLevel],a

        ret

.bailOutAddress
        rst     $00

.drawMenu
        push    bc
        push    de
        push    hl

        xor     a
        ldio    [backBufferReady],a 

        ld      hl,(bullet_y + (levelCheckRAM-L1101_Load2))
        ld      a,[hl+]          ;bullet_y
        ld      d,a
        call    ScrollSpritesUp  ;reset bullet to top of screen

        ;scroll the bullet down to the correct position
        ld      hl,(cur_choice + (levelCheckRAM-L1101_Load2))
        ld      a,[hl-]          ;get cur choice
        ld      b,a              ;a = a * 3
        rlca
        add     b
        add     4                ;topmost is four tiles down
        rlca                     ;times 8 pixels per tile
        rlca
        rlca
        ld      [hl+],a          ;save new bullet_y
        ld      d,a
        call    ScrollSpritesDown

        ;-----draw 'New Game' text------------------------------------
        ld      a,[(cur_choice + (levelCheckRAM-L1101_Load2))]
        ld      hl,$1400       ;origin tile 20,0
        or      a
        jr      z,.highlightNewGame

        ;check for disabled
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      z,.newGameHighlightDone

        ;disable
        ld      l,6
        jr      .newGameHighlightDone

.highlightNewGame
        ;highlighted
        ld      l,3            ;origin 20,3

.newGameHighlightDone
        ld      de,$0405       ;dest tile 3,5
        ld      bc,$0d03       ;dest w,h 13x3
        call    CinemaBlitRect

        ;-----draw 'Load Game' text-----------------------------------
        ld      hl,$1409       ;origin tile 20,9
        ld      a,[(cur_choice + (levelCheckRAM-L1101_Load2))]
        cp      1
        jr      nz,.checkLoadDisabled

        ;highlighted
        ld      l,12           ;origin 20,12
        jr      .loadGameHighlightDone

.checkLoadDisabled
        ld      a,[(hasSavedGame + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      nz,.loadGameHighlightDone

        ;disabled
        ld      l,15           ;origin 20,15

.loadGameHighlightDone
        ld      de,$0408       ;dest tile 4,8
        ld      bc,$0d03       ;dest w,h 13x3
        call    CinemaBlitRect

        ;-----draw 'Join Game' text-----------------------------------
        ld      hl,$2100       ;origin tile 33,0
        ld      a,[(cur_choice + (levelCheckRAM-L1101_Load2))]
        cp      2
        jr      nz,.checkJoinDisabled

        ;highlighted
        ld      l,3            ;origin 33,3
        jr      .joinGameHighlightDone

.checkJoinDisabled
        ld      a,[(hasLinkMaster + (levelCheckRAM-L1101_Load2))]
        or      a
        jr      nz,.joinGameHighlightDone

        ;disabled
        ld      l,6            ;origin 33,6

.joinGameHighlightDone
        ld      de,$040b       ;dest tile 4,11
        ld      bc,$0d03       ;dest w,h 13x3
        call    CinemaBlitRect

        pop     hl
        pop     de
        pop     bc
        ret

L1101_LoadFinished:

;some local vars
bullet_y:        DS 1
cur_choice:      DS 1
hasSavedGame:    DS 1
hasLinkMaster:   DS 1

L1101_Map:
;---------------------------------------------------------------------
L1101_Init:
;---------------------------------------------------------------------
        DW ((L1101_InitFinished - L1101_Init2))  ;size
L1101_Init2:

        ret

L1101_InitFinished:


;---------------------------------------------------------------------
L1101_Check:
;---------------------------------------------------------------------
        DW ((L1101_CheckFinished - L1101_Check) - 2)  ;size
L1101_Check2:
        ret
L1101_CheckFinished:


PRINTT "  1101 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L1101_LoadFinished - L1101_Load2)
PRINTT " / "
PRINTV (L1101_InitFinished - L1101_Init2)
PRINTT " / "
PRINTV (L1101_CheckFinished - L1101_Check2)
PRINTT "\n"

