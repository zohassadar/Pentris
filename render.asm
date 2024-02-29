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
    txs

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


fillRenderQueue:
    lda #$20
    sta oldPiece0Address
    sta oldPiece1Address
    sta oldPiece2Address
    sta oldPiece3Address
    sta oldPiece4Address
    sta newPiece0Address
    sta newPiece1Address
    sta newPiece2Address
    sta newPiece3Address
    sta newPiece4Address
    sta row0Address
    sta row1Address
    sta row2Address
    sta row3Address
    sta row4Address
    sta linesAddress
    sta scoreAddress
    sta levelAddress
    sta paletteTetrisAddress
    sta paletteBGAddress
    sta paletteSpriteAddress
    rts