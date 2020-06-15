;---------------------------------------------------------------------
; Eat
;---------------------------------------------------------------------
SECTION "Section_eat_0",ROMX
eat_gbw::
  INCBIN "Data/SoundSamples/eat.gbw"
  DB $80,$00            ;terminate sample

