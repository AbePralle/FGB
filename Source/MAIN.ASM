;***************************************************************************
;*
;* MAIN.ASM - Standard ROM-image header
;*
;* All fields left to zero since RGBFix does a nice job of filling them in
;* in for us...
;*
;***************************************************************************

        ;INCLUDE        "irq.inc"
        ;INCLUDE        "utility.inc"
        ;INCLUDE        "hardware.inc"

        SECTION        "Startup",ROM0[0]

RST_00:        jp        Main8Mhz
        DS        5
RST_08:        jp        Main
        DS        5
RST_10:        jp        Main
        DS        5
RST_18:        jp        Main
        DS        5
RST_20:        jp        Main
        DS        5
RST_28:        jp        Main
        DS        5
RST_30:        jp        Main
        DS        5
RST_38:        jp        Main
        DS        5

        jp        OnVBlank
        DS        5

        ;jp        OnHBlank
        jp        hblankVector
        DS        5

        ;jp        irq_Timer
        ;DS        5
        reti
        DS  7

        ;jp        irq_Serial
        ;DS        5
        reti
        DS  7

        ;jp        irq_HiLo
        ;DS        5
        reti
        DS  7

        DS        $100-$68

        nop
        jp        Main

        DB        $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
        DB        $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
        DB        $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

                ;0123456789ABCDEF
        DB        "FGB            ",$c0
        DB        0,0,0        ;SuperGameboy
        DB        $1b          ;CARTTYPE
                        ;--------
                        ;0 - ROM ONLY
                        ;1 - ROM+MBC1
                        ;2 - ROM+MBC1+RAM
                        ;3 - ROM+MBC1+RAM+BATTERY
                        ;5 - ROM+MBC2
                        ;6 - ROM+MBC2+BATTERY
                        ;$19 - ROM + MBC5
                        ;$19 - ROM + MBC5 + RAM + battery

        DB        0        ;ROMSIZE
                        ;-------
                        ;0 - 256 kBit ( 32 kByte,  2 banks)
                        ;1 - 512 kBit ( 64 kByte,  4 banks)
                        ;2 -   1 MBit (128 kByte,  8 banks)
                        ;3 -   2 MBit (256 kByte, 16 banks)
                        ;3 -   4 MBit (512 kByte, 32 banks)

        DB        0        ;RAMSIZE
                        ;-------
                        ;0 - NONE
                        ;1 -  16 kBit ( 2 kByte, 1 bank )
                        ;2 -  64 kBit ( 8 kByte, 1 bank )
                        ;3 - 256 kBit (32 kByte, 4 banks)

        DW        $0000        ;Manufacturer

        DB        0        ;Version
        DB        0        ;Complement check
        DW        0        ;Checksum

; --
; -- Initialize the Gameboy
; --

Main::
        ;@ $150
        ; disable interrupts
        di

        ;kick CPU to 8 MHZ
        ld      a,$30
        ld      [$ff00],a
        ld      a,1
        ld      [$ff4d],a
        stop

Main8Mhz:
        ; we want a stack
        di
        ld        hl,StackTop
        ld        sp,hl

        ; no interrupts to begin with
        xor     a
        ldio    [$ff0f],a                 ;interrupt flags
        ldio    [$ffff],a                 ;interrupt control
        ei                                ;enable interrupts

        jp      UserMain     ;in home memory

;---------------------------------------------------------------------
SECTION "HomeTableSection",ROM0[$170]
;---------------------------------------------------------------------
;$170
encodeControlByteTable::
  DB %01000000       ;buttons 0000   of (start,select,b,a)
  DB %00010000       ;buttons 0001   if b or a or none then -> 00ba
  DB %00100000       ;buttons 0010   else -> 01te  (t=start, e=select)
  DB %00110000       ;buttons 0011
  DB %01010000       ;buttons 0100   if final result=0 set it to be
  DB %00010000       ;buttons 0101   %01000000 (same diff) to avoid
  DB %00100000       ;buttons 0110   sending the byte $00 which takes
  DB %00110000       ;buttons 0111   two cycles instead of 1
  DB %01100000       ;buttons 1000
  DB %00010000       ;buttons 1001
  DB %00100000       ;buttons 1010
  DB %00110000       ;buttons 1011
  DB %01110000       ;buttons 1100
  DB %00010000       ;buttons 1101
  DB %00100000       ;buttons 1110
  DB %00110000       ;buttons 1111

;$180
decodeControlByteTable::
  DB %00000000       ;coded 0000
  DB %00010000       ;coded 0001
  DB %00100000       ;coded 0010
  DB %00110000       ;coded 0011
  DB %00000000       ;coded 0100
  DB %01000000       ;coded 0101
  DB %10000000       ;coded 0110
  DB %11000000       ;coded 0111
  DB %00000000       ;coded 1000 N/A
  DB %00000000       ;coded 1001 N/A
  DB %00000000       ;coded 1010 N/A
  DB %00000000       ;coded 1011 N/A
  DB %00000000       ;coded 1100 N/A
  DB %00000000       ;coded 1101 N/A
  DB %00000000       ;coded 1110 N/A
  DB %00000000       ;coded 1111 N/A

;$190

; --
; -- Variables
; --

        SECTION        "StartupVars",WRAM0[$CF00]

Stack:        DS        $100
StackTop:
