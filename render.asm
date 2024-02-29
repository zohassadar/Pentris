.macro sendAddress
    pla
    sta PPUADDR
    pla
    sta PPUADDR
.endmacro

.macro sendData bytes
.repeat bytes
    pla
    sta PPUDATA
.endrepeat
.endmacro

dumpRenderQueue:
    tsx
    stx stackPointer
    ldx #$00
    tsx

; old piece and new piece
.repeat 10
    sendAddress
    sendData 1
.endrepeat

; rows
.repeat 5
    sendAddress
    sendData 14
.endrepeat

; score
    sendAddress
    sendData 6

; lines
    sendAddress
    sendData 3

; level
    sendAddress
    sendData 2

; palette bg tetris
    sendAddress
    sendData 1

; palette bg pieces
    sendAddress
    sendData 4

; palette bg sprites
    sendAddress
    sendData 4

    ldx stackPointer
    txs
    rts