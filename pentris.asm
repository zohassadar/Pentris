;
; iNES header
;

; This iNES header is from Brad Smith (rainwarrior)
; https://github.com/bbbradsmith/NES-ca65-example

.segment "HEADER"

.ifdef CNROM
INES_MAPPER = 3 ; 0 = NROM
.else
INES_MAPPER = 1 ; 0 = NROM
.endif

INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $04 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding


.segment "CHR"
.incbin "gfx/title_menu_tileset.chr"
.incbin "gfx/typeB_ending_tileset.chr"
.incbin "gfx/typeA_ending_tileset.chr"
.incbin "gfx/game_tileset.chr"
.incbin "gfx/stats_tileset.chr"
.repeat $3000
.byte $0
.endrepeat
