;---------------------------------------------------------------------
; music.asm
; 8.20.00 by Abe Pralle
;---------------------------------------------------------------------

INCLUDE "Source/defs.inc"

;Routines
;--------------
; InitMusic
; PlayMusic

SECTION "MusicHome",ROM0
;---------------------------------------------------------------------
; Routine:      IsCurMusic
; Arguments:    a  - bank of gbm data
;               hl - address of compiled gbm music
; Alters:       af
; Returns:      a  - 1 if same music is playing, 0 if not
;               zflag - or a
; Description:  Initializes a new piece of music *unless* it is
;               already playing in which case it leaves it alone.
;---------------------------------------------------------------------
IsCurMusic::
        push    bc
        ld      b,a
        ld      a,[musicBank]
        cp      b
        jr      nz,.different
        ld      a,[musicAddress]
        cp      l
        jr      nz,.different
        ld      a,[musicAddress+1]
        cp      h
        jr      nz,.different

.same
        pop     bc
        ld      a,1
        or      a
        ret

.different
        pop     bc
        xor     a
        ret

;---------------------------------------------------------------------
; Routine:      InitMusic
; Arguments:    a  - bank of gbm data
;               hl - address of compiled gbm music
; Alters:       af
; Description:  Initializes a new piece of music *unless* it is
;               already playing in which case it leaves it alone.
;---------------------------------------------------------------------
InitMusic::
        push    bc
        push    de
        push    hl

        push    af
        ld      b,a
        ld      a,[musicBank]
        cp      b
        jr      nz,.newMusic
        ld      a,[musicAddress]
        cp      l
        jr      nz,.newMusic
        ld      a,[musicAddress+1]
        cp      h
        jr      nz,.newMusic
        pop     af
        jp      .done     ;currently playing this one

.newMusic
        pop     af
        di
        ld      [musicBank],a
        xor     a
        ld      [musicEnabled],a
        ei

        ld      a,l
        ld      [musicAddress],a
        ld      a,h
        ld      [musicAddress+1],a

        PUSHROM
        ld      a,[musicBank]
        call    SetActiveROM

        ;parse header
        inc     hl         ;skip version
        ld      a,[hl+]    ;notes per second
        ld      [musicNoteCountdownInit],a
        ld      [musicNoteCountdown],a
        ld      de,6
        add     hl,de

        ld      bc,musicTrack1Pos
        call    .getTrackOffset
        ld      bc,musicTrack2Pos
        call    .getTrackOffset
        ld      bc,musicTrack3Pos
        call    .getTrackOffset
        ld      bc,musicTrack4Pos
        call    .getTrackOffset

        ld      a,BANK(instrumentDefaults)
        call    SetActiveROM

        ld      c,33
        ld      de,musicInstrument1
        ld      hl,instrumentDefaults
.copyDefaultInstruments
        ld      a,[hl+]
        ld      [de],a
        inc     de
        dec     c
        jr      nz,.copyDefaultInstruments

        ;actually set default instruments
        ld      hl,musicInstrument1
        ld      de,$ff10
        ld      bc,4
        xor     a
        call    MemCopy
        ld      hl,musicInstrument2
        ld      de,$ff16
        ld      bc,3
        call    MemCopy
        ld      hl,musicInstrument3
        ld      de,$ff31
        call    MemCopy
        ld      hl,musicInstrument4
        ld      de,$ff20
        call    MemCopy

        ;disable sound
        xor     a
        ldio    [$ff26],a

        ldio    [$ff12],a    ;zero envelope all instruments
        ldio    [$ff17],a
        ldio    [$ff1c],a
        ldio    [$ff21],a
        ;ldio    [$ff14],a    ;turn off instruments
        ;ldio    [$ff19],a
        ;ldio    [$ff1e],a
        ;ldio    [$ff23],a

        ;enable sound
        ld      a,$80
        ldio    [$ff26],a   ;master
        ld      a,$ff
        ldio    [$ff24],a   ;volume
        ldio    [$ff25],a   ;sound output terminals

        ;ld      a,[musicInstrument1]
        ;ldio    [$ff10],a
        ;ld      a,[musicInstrument1+1]
        ;ldio    [$ff11],a
        ;ld      a,[musicInstrument2]
        ;ldio    [$ff16],a
        ;ld      a,[musicInstrument2]
        ;ldio    [$ff16],a

        ;setup waveform data
        ld      de,$ff30
        ld      hl,musicWaveform
        ld      bc,16
        call    MemCopy
        xor     a

        POPROM

        ;initialize music stacks
        ld      a,32
        ld      hl,musicStackL1
        ld      [hl+],a
        ld      a,64
        ld      [hl+],a
        ld      a,96
        ld      [hl+],a
        ld      a,128
        ld      [hl+],a

.done
        ld      a,%11111
        ldio    [musicEnabled],a

        pop     hl
        pop     de
        pop     bc
        ret

.getTrackOffset
        ld      a,[hl+]
        ld      e,a
        ld      a,[hl+]
        ld      d,a
        push    hl
        add     hl,de
        ld      a,l
        ld      [bc],a
        inc     bc
        ld      a,h
        ld      [bc],a
        pop     hl
        ret

;---------------------------------------------------------------------
; Routine:      StopMusic
; Arguments:    None.
; Alters:       af
; Description:  Halts the music
;---------------------------------------------------------------------
StopMusic::
        xor     a
        ldio    [musicEnabled],a
        ret

;---------------------------------------------------------------------
; Routine:      PlayMusic
; Arguments:    None.
; Alters:       af
; Description:  Plays the next note for each voice.  Should only be
;               called after [musicNoteCountdown] has reached zero
;               (being decremented 60 times per second).
;---------------------------------------------------------------------
PlayMusic::
        push    bc
        push    de
        push    hl

        ;save the current RAM bank in use
        ldio    a,[$ff70]
        push    af

        ld      a,MUSICBANK
        ldio    [$ff70],a

        PUSHROM
        ld      hl,musicBank
        ld      a,[hl+] 
        call    SetActiveROM
        ld      a,[hl+]          ;countdown init
        ld      [hl+],a          ;reset cur countdown

        ;decrement sound effect override counters
        push    hl
        xor     a
        ld      hl,musicOverride1
        cp      [hl]
        jr      z,.skipOverride1
        dec     [hl]
.skipOverride1
        inc     hl
        cp      [hl]
        jr      z,.skipOverride4
        dec     [hl]
.skipOverride4
        pop     hl

        ld      a,[musicStackL1]
        ld      [curTrackStackL],a
        call    .playTrack
        ld      a,[curTrackStackL]
        ld      [musicStackL1],a

.playTrack2
        ld      a,[musicStackL2]
        ld      [curTrackStackL],a
        call    .playTrack
        ld      a,[curTrackStackL]
        ld      [musicStackL2],a

.playTrack3
        ld      a,[musicStackL3]
        ld      [curTrackStackL],a
        call    .playTrack
        ld      a,[curTrackStackL]
        ld      [musicStackL3],a

.playTrack4
        ld      a,[musicStackL4]
        ld      [curTrackStackL],a
        call    .playTrack
        ld      a,[curTrackStackL]
        ld      [musicStackL4],a

.afterPlayTrack4
        POPROM

        ;restore RAM bank
        pop     af
        ldio    [$ff70],a

        pop     hl
        pop     de
        pop     bc
        ret

.playTrack
        ;hl - address of pc for current track
        push    hl
        ld      a,[hl+]   ;set the pc
        ld      e,a
        ld      a,[hl+]
        ld      d,a
;ld a,d
;cp $ff
;jr nz,.okay
;ld b,b
;.okay
        call    ExecuteByteCode
        pop     hl

        ;save new pc for this track
        ld      a,e
        ld      [hl+],a
        ld      a,d
        ld      [hl+],a
        ret

ExecuteByteCode:
        ld      a,[de]    ;get a bytecode
        inc     de
        or      a         ;nop?
        ret     z

        ld      b,a
        and     $f0
        jr      nz,.check1xTo8x

        ld      a,b
        bit     3,a
        jr      nz,.check08To0f

        cp      2
        jp      z,.return
        cp      4
        jp      z,.note1
        cp      5
        jp      z,.note2
        cp      6
        jp      z,.note3
        cp      7
        jp      z,.note4
.error02To07 jr .error02To07

.check08To0f
        cp      8
        jp      z,.hold1 
        cp      9
        jp      z,.hold2
        cp      $0a
        jp      z,.hold3
        cp      $0b
        jp      z,.hold4
        cp      $0c
        jp      z,.instr1
        cp      $0d
        jp      z,.instr2
        cp      $0e
        jp      z,.instr3
        cp      $0f
        jp      z,.instr4
.error08To0f jr .error08To0f

.check1xTo8x
        cp      $10
        jp      z,.setDec
        cp      $20
        jp      z,.setReg
        cp      $30
        jp      z,.decReg
        cp      $40
        jp      z,.cmpDec
        cp      $50
        jp      z,.cmpReg
        cp      $60
        jp      z,.jump
        cp      $70
        jp      z,.call
        cp      $80
        jp      z,.repeat
.error1xTo8x jr .error1xTo8x

.return
        ;pop return address off the current stack & execute another
        ;command
        ld      h,((musicStack>>8)&$ff)
        ld      a,[curTrackStackL]
        ld      l,a
        ld      a,[hl+]
        ld      e,a
        ld      a,[hl+]
        ld      d,a
        ld      a,l
        ld      [curTrackStackL],a
        jp      ExecuteByteCode

.hold1
        ld      a,[de]
        inc     de
        ld      [musicInstrument1+2],a
        jr      .note1

.hold2  ld      a,[de]
        inc     de
        ld      [musicInstrument2+1],a
        jr      .note2

.hold3  ld      a,[de]
        inc     de
        ld      [musicInstrument3],a
        jr      .note3

.hold4  ld      a,[de]
        inc     de
        ld      [musicInstrument4+1],a
        jr      .note4

.note1
        ld      hl,musicInstrument1+3
        call    .noteCommon
.repeat1
        ldio    a,[musicEnabled]
        and     %00001
        ret     z
        ld      hl,musicInstrument1
        jp      PlaySoundChannel1

.note2
        ld      hl,musicInstrument2+2
        call    .noteCommon
.repeat2
        ldio    a,[musicEnabled]
        and     %00010
        ret     z
        ld      hl,musicInstrument2
        jp      PlaySoundChannel2

.note3
        ld      hl,musicInstrument3+2
        call    .noteCommon
.repeat3
        ldio    a,[musicEnabled]
        and     %00100
        ret     z
        ld      hl,musicInstrument3
        jp      PlaySoundChannel3

.note4
        ld      hl,musicInstrument4
        call    .noteCommon
        call    .noteCommon
.repeat4
        ldio    a,[musicEnabled]
        and     %01000
        ret     z
        ld      hl,musicInstrument4
        jp      PlaySoundChannel4

.noteCommon
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ret

.instr1
        ld      hl,musicInstrument1
        ld      c,3
        jp     .instrCommon

.instr2
        ld      hl,musicInstrument2
        ld      c,2
        jp     .instrCommon

.instr3
        ld      hl,musicInstrument3
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      a,[de]
        inc     de
        ld      [hl+],a
        ld      hl,musicWaveform
        ld      c,16
        jp     .instrCommon

.instr4
        ld      hl,musicInstrument4
        ld      c,4
        jp     .instrCommon

.instrCommon
        ld      a,[de]
        inc     de
        ld      [hl+],a
        dec     c
        jr      nz,.instrCommon
        jp      ExecuteByteCode

.setDec
ld b,b
        ld      a,b
        call    .setHLToReg
        ld      a,[de]
        inc     de
        ld      [hl],a
        jp      ExecuteByteCode

.setReg
ld b,b
        ld      a,[de]
        inc     de
        call    .setHLToReg
        ld      c,[hl]
        ld      a,b
        call    .setHLToReg
        ld      [hl],a
        jp      ExecuteByteCode

.decReg
        ;ld      a,b
        ;call    .setHLToReg
        ;dec     [hl]
        ;TODO
        jp      ExecuteByteCode

.cmpDec
        ld      b,a     ;which register?
        and     $f
        add     (musicRegisters & $ff)
        ld      l,a
        ld      h,((musicRegisters>>8) & $ff)
        ld      a,[de]
        cp      [hl]
        call    nz,.nonZeroResult
        call    z,.zeroResult

.cmpReg
        ;TODO
        inc     de
        jp      ExecuteByteCode

.nonZeroResult
        ld      a,0
        ld      [musicRegisters+15],a
        ret

.zeroResult
        ld      a,1
        ld      [musicRegisters+15],a
        ret

.setHLToReg
        and     $0f
        add     (musicRegisters & $ff)
        ld      h,((musicRegisters>>8) & $ff)
        ld      l,a
        ret

.jump   
        ld      a,[de]    ;hl = offset to new address
        inc     de
        ld      l,a
        ld      a,[de]
        inc     de
        ld      h,a

        ld      a,b
        and     $7
        cp      6
        jr      z,.jumpAlways

        ;assume cc=eq
        ld      a,[musicRegisters+15]
        or      a
        jr      z,.afterJump    ;not eq

.jumpAlways
        add     hl,de
        ld      d,h
        ld      e,l
.afterJump
        jp      ExecuteByteCode

.call   ;save return address on current music stack
        ld      h,((musicStack>>8)&$ff)
        ld      a,[curTrackStackL]
        sub     2
        ld      [curTrackStackL],a
        ld      l,a
        ld      a,e
        add     2
        ld      [hl+],a
        ld      a,d
        adc     0
        ld      [hl-],a
        ld      b,6     ;cc=jump always
        jr      .jump

.repeat
        ld      a,b
        and     $0f
        jp      z,.repeat1
        cp      1
        jp      z,.repeat2
        cp      2
        jp      z,.repeat3
        cp      3
        jp      z,.repeat4
.error8x jr .error8x


;---------------------------------------------------------------------
SECTION "MusicData1",ROMX
;---------------------------------------------------------------------
instrumentDefaults:
.instrument1
DB $07,$80,$f1,$43,$85
.instrument2
DB $80,$c2,$02,$86
.instrument3
DB $cf,$20,$00,$c5
.instrument4
DB $00,$f0,$00,$c0
.waveform
DB $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd
DB $00,$00,$00,$00,$00,$00,$00,$00

alarm_gbm::
  INCBIN "Data/Music/alarm.gbm.bin"

intro_cinema_gbm::
  INCBIN "Data/Music/intro_cinema.gbm.bin"

bs_gbm::
  INCBIN "Data/Music/jazzy.gbm.bin"

lady_flower_gbm::
  INCBIN "Data/Music/lady_flower.gbm.bin"

main_in_game_gbm::
  INCBIN "Data/Music/main_in_game.gbm.bin"

haiku_gbm::
  INCBIN "Data/Music/maybe_haiku.gbm.bin"

;---------------------------------------------------------------------
SECTION "MusicData2",ROMX
;---------------------------------------------------------------------

moon_base_ba_gbm::
  INCBIN "Data/Music/moon_base_ba.gbm.bin"

moon_base_haiku_gbm::
  INCBIN "Data/Music/moon_base_haiku.gbm.bin"

;shroom_gbm::
  ;INCBIN "Data/Music/shroom.gbm.bin"

cowboy_gbm::
  INCBIN "Data/Music/cowboy.gbm.bin"

frosty_gbm::
  INCBIN "Data/Music/frosty.gbm.bin"

fgbwar_gbm::
  INCBIN "Data/Music/fgbwar.gbm.bin"

wedding_gbm::
  INCBIN "Data/Music/wedding.gbm.bin"

takeoff_gbm::
  INCBIN "Data/Music/takeoff.gbm.bin"

;---------------------------------------------------------------------
SECTION "MusicData3",ROMX
;---------------------------------------------------------------------

spaceish_gbm::
  INCBIN "Data/Music/spaceish.gbm.bin"

beehive_gbm::
  INCBIN "Data/Music/beehive.gbm.bin"

hoedown_gbm::
  INCBIN "Data/Music/hoedown.gbm.bin"

death_gbm::
  INCBIN "Data/Music/death.gbm.bin"

;---------------------------------------------------------------------
SECTION "MusicData4",ROMX
;---------------------------------------------------------------------
jungle_gbm::
  INCBIN "Data/Music/jungle.gbm.bin"

mysterious_gbm::
  INCBIN "Data/Music/mysterious.gbm.bin"

