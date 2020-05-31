; l0401.asm pitch black
; Generated 09.06.2000 by mlevel
; Modified  09.06.2000 by Abe Pralle

INCLUDE "Source/defs.inc"
INCLUDE "Source/levels.inc"

;---------------------------------------------------------------------
SECTION "Level0401Section",DATA
;---------------------------------------------------------------------

L0401_Contents::
  DW L0401_Load
  DW L0401_Init
  DW L0401_Check
  DW L0401_Map

;---------------------------------------------------------------------
;  Load
;---------------------------------------------------------------------
L0401_Load:
        DW ((L0401_LoadFinished - L0401_Load2))  ;size
L0401_Load2:
        call    ParseMap
        ret

L0401_LoadFinished:
;---------------------------------------------------------------------
;  Map
;---------------------------------------------------------------------
L0401_Map:
INCBIN "..\\fgbeditor\\L0401_pitch_black.lvl"

;---------------------------------------------------------------------
;  Init
;---------------------------------------------------------------------
L0401_Init:
        DW ((L0401_InitFinished - L0401_Init2))  ;size
L0401_Init2:
				ld      hl,((.blackPalette-L0401_Init2)+levelCheckRAM)
				ld      de,gamePalette
				call    CopyPalette32
				ld      de,fadeFinalPalette
				call    CopyPalette32
				ld      de,fadeCurPalette
				call    CopyPalette32
				;call    InstallGamePalette

        ld      a,ENV_RAIN
        call    SetEnvEffect

        ret


.blackPalette
        DW      $0000, $2108, $4210, $7fff     ;Palette 0 (Grey)
        DW      $0000, $0000, $0000, $0000
        DW      $0000, $0000, $0000, $0000
        DW      $0000, $0000, $0000, $0000
        DW      $0000, $0000, $0000, $0000
        DW      $0000, $0000, $0000, $0000
        DW      $0000, $0000, $0000, $0000
        DW      $0000, $0000, $0000, $0000

L0401_InitFinished:
;---------------------------------------------------------------------
;  Check
;---------------------------------------------------------------------
L0401_Check:
        DW ((L0401_CheckFinished - L0401_Check2))  ;size
L0401_Check2:
        ld      hl,((.heroToGrey-L0401_Check2)+levelCheckRAM)
				xor     a
				call    CheckEachHero

        call    ((.lightening-L0401_Check2)+levelCheckRAM)
        ret

.heroToGrey
        or      a
				ret     z

				ld      c,a
				call    GetFGAttributes
				and     %11111000         ;palette to grey
				call    SetFGAttributes
				call    GetFirst
				ld      b,METHOD_DRAW
				call    CallMethod
				ret

.lightening
        ld      a,31
				call    GetRandomNumMask
				cp      31
				jr      nz,.playThunderSound

        ld      hl,((.lighteningPalette-L0401_Check2)+levelCheckRAM)
				ld      de,fadeCurPalette
				call    CopyPalette32
				ld      a,7
				call    GetRandomNumMask
				add     8
				call    FadeInit
				ret

.playThunderSound
        and     15
			  ret     nz

        ld      hl,((.thunderSound-L0401_Check2)+levelCheckRAM)
				call    PlaySound
        ret

.thunderSound
        DB      4,$00,$f4,$66,$80
        
.lighteningPalette
        DW      $7fff, $0000, $0000, $0000     ;Palette 0 (Grey)
        DW      $7fff, $0000, $0000, $0000
        DW      $7fff, $0000, $0000, $0000
        DW      $7fff, $0000, $0000, $0000
        DW      $7fff, $0000, $0000, $0000
        DW      $7fff, $0000, $0000, $0000
        DW      $7fff, $0000, $0000, $0000
        DW      $7fff, $0000, $0000, $0000

L0401_CheckFinished:
PRINTT "0401 Script Sizes (Load/Init/Check) (of $500):  "
PRINTV (L0401_LoadFinished - L0401_Load2)
PRINTT " / "
PRINTV (L0401_InitFinished - L0401_Init2)
PRINTT " / "
PRINTV (L0401_CheckFinished - L0401_Check2)
PRINTT "\n"

