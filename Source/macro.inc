;PADNOCARRY:	MACRO
            ;;if low byte of addr is > max addr for space required
            ;;add pad bytes to bring low byte to 0
            ;IF ((\1 & $ff) > ((-\2) & $ff))
              ;DS ((-\1) & $ff)
            ;ENDC
;ENDM

SETDIALOGSKIP:  MACRO
        ld       de,\1
        call     SetDialogSkip
ENDM

PREPLONGCALL:  MACRO
        ld      hl,\1
        push    hl              ;push return addr
				ldio    a,[curROMBank]  ;push current ROM bank
				push    af
ENDM

LONGCALL: MACRO
        add     sp,-4           ;leave a blank spot
				push    af              ;save parameter af
				push    de              ;save parameter de
				ld      a,BANK(\1)
				ld      de,\1
				jp      LongCall
ENDM

LONGCALLNOARGS: MACRO
				ld      a,BANK(\1)
				ld      hl,\1
				call    LongCallNoArgs
ENDM

DEBUGTITLE: MACRO
IF DEBUG
  DB \1
ENDC
ENDM

GTX: MACRO
  DB $ff,0,0,1,1,STRLEN(\1)
COUNTER SET 1
REPT STRLEN(\1)
  DB ((STRSUB(\1,COUNTER,1)+145) & $ff)
COUNTER SET COUNTER+1
ENDR
ENDM

GTXSTRING: MACRO
  DB 0,STRLEN(\1)
COUNTER SET 1
REPT STRLEN(\1)
  DB ((STRSUB(\1,COUNTER,1)+145) & $ff)
COUNTER SET COUNTER+1
ENDR
ENDM

GTXSTRINGC: MACRO
  DB ((20-STRLEN(\1))/2),STRLEN(\1)
COUNTER SET 1
REPT STRLEN(\1)
  DB ((STRSUB(\1,COUNTER,1)+145) & $ff)
COUNTER SET COUNTER+1
ENDR
ENDM

ITEMSTRING: MACRO
  DB 0,STRLEN(\2)+2,\1,0
COUNTER SET 1
REPT STRLEN(\2)
  DB ((STRSUB(\2,COUNTER,1)+145) & $ff)
COUNTER SET COUNTER+1
ENDR
ENDM


LDHL_CURHERODATA: MACRO
        ld      h,((hero0_data>>8) & $ff)
				ld      a,[curHeroAddressL]
				add     \1
				ld      l,a
ENDM

PUSHROM: MACRO
        ld      a,[curROMBank]
				push    af
ENDM

POPROM: MACRO
        pop     af
				call    SetActiveROM
ENDM

VECTORTOSTATE: MACRO
        ld      hl,\1
				call    LCheckGetVectorToState
				jp      hl
ENDM

DIALOGTOP: MACRO
        ld      de,\1
				call    ShowDialogAtTopNoWait
ENDM

DIALOGBOTTOM: MACRO
        ld      de,\1
				call    ShowDialogAtBottomNoWait

ENDM

WAITDIALOG: MACRO
        ld      hl,((\1 << 8) | STATE_WAIT_DIALOG)
				call    StdWaitDialog
ENDM

WAITDIALOGNOCLEAR: MACRO
        ld      hl,((\1 << 8) | STATE_WAIT_DIALOG)
				call    StdWaitDialogNoClear
ENDM

STDWAITDIALOG: MACRO
				call    CheckDialogContinue
				or      a
				ret     z

        call    RestoreIdle
				ld      hl,mapState+1
				ld      a,[hl-]
				ld      [hl],a
ENDM

COLOR: MACRO
        DW      (((\3>>3)<<10) | ((\2>>3)<<5) | (\1>>3))
ENDM

LOAD16HLXX: MACRO
        ld      a,[hl+]
        ld      \2,a
        ld      a,[hl+]
        ld      \1,a
ENDM

SAVE16HLXX: MACRO
        ld      a,\2
        ld      [hl+],a
        ld      a,\1
        ld      [hl+],a
ENDM

STDSETUPDIALOG: MACRO
        ld      a,BANK(dialog)
        ld      [dialogBank],a
        call    SetPressBDialog
ENDM

