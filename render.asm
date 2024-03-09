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
    ldx #$FF
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



tmpYOffset := generalCounter
tmpXOffset := generalCounter2
tmpTile := generalCounter3
counter := generalCounter5


stageSpriteForCurrentPiece:
        lda     currentPiece
        cmp     #$3f
        beq     @ret
        jsr     setOrientationTable
        lda     #$00
        sta     counter ; iterate through all five minos
        tay
@pieceLoop:
        lda     (currentOrientationY),y 
        sta     tmpYOffset               ; Y offset 
        lda     (currentOrientationX),y
        sta     tmpXOffset              ; X offset
        lda     (currentOrientationTile),y
        sta     tmpTile              ; Tile

        tya
        pha             ; store Y 

        lda     counter
        asl
        clc
        adc     counter
        tay                       ; counter multiplied by 3 (addr, addr, data)


        lda     tmpYOffset
        clc
        adc     tetriminoY
        asl
        tax                                             ; y + offset to get row

        lda     vramPlayfieldRows,x
        clc
        adc     tmpXOffset
        clc
        adc     tetriminoX
        sta     newPiece0Address+1,y
        lda     vramPlayfieldRows+1,x
        sta     newPiece0Address,y
        lda     tmpTile
        sta     newPiece0Address+2,y

        pla
        tay

        iny

        inc     counter
        lda     counter
        cmp     #$05
        bne     @pieceLoop

@ret:   rts


; drawBlankPiece:
;         ldy     #$05
;         ldx     #$00
; blankPieceLoop:
;         lda    #$20
;         sta    currentPieceStaging,x
;         lda    #$68
;         sta    currentPieceStaging+1,x
;         lda    #$FF
;         sta    currentPieceStaging+2,x
;         inx
;         inx
;         inx
;         dey
;         bne     blankPieceLoop
;         rts
