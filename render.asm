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
        lda playState
        cmp #$4
        bne @normalDump
        jmp updateLineClearingAnimation
@normalDump:
        tsx
        stx stackPointer
        ldx #$FF
        txs

; rows
.repeat 5
        sendAddress
        sendData 14
.endrepeat

; old piece
.repeat 5
        sendAddress
        sendData 1
.endrepeat

; spawn area tiles
sendAddress
sendData 5
.repeat 2
        sendAddress
        sendData 3
.endrepeat

; new piece
.repeat 5
        sendAddress
        sendData 1
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

; stats
        sendAddress
        sendData 3

        ldx stackPointer
        txs

        lda currentPpuCtrl
        sta PPUCTRL
        ldy #$00
        sty PPUSCROLL
        sty PPUSCROLL
        rts

tmpYOffset := generalCounter
tmpXOffset := generalCounter2
tmpTile := generalCounter3
counter := generalCounter5


stageSpriteForCurrentPiece:
        ; not really a sprite
        jsr stageSpawnAreaTiles
        jsr clearOldPiece
        lda currentPiece
        cmpHiddenPiece
        beq @ret
        jsr setOrientationTable
        lda #$00
        sta counter             ; iterate through all five minos
        tay
@pieceLoop:
        lda (currentOrientationY),y
        sta tmpYOffset          ; Y offset
        lda (currentOrientationX),y
        sta tmpXOffset          ; X offset
        lda currentTile
        sta tmpTile             ; Tile

        tya
        pha                     ; store Y

        lda counter
        asl
        clc
        adc counter
        tay                     ; counter multiplied by 3 (addr, addr, data)

        lda tmpYOffset
        clc
        adc tetriminoY
        asl
        tax                     ; y + offset to get row

        ; x should only be negative if piece is hidden
        bpl @notHidden
        lda #$00
        sta newPiece0Address,y
        sta newPiece0Address+1,y
        jmp @resume
@notHidden:
        lda vramPlayfieldRows,x
        clc
        adc tmpXOffset
        clc
        adc tetriminoX
        sta newPiece0Address+1,y
        lda vramPlayfieldRows+1,x
        sta newPiece0Address,y
        lda tmpTile
        sta newPiece0Address+2,y

@resume:
        pla                     ; restore Y
        tay

        iny

        inc counter
        lda counter
        cmp #$05
        bne @pieceLoop

@ret:   rts


clearOldPiece:
        lda currentPiece
        cmpHiddenPiece
        bne @normalClear
        lda #$00
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
        rts
@normalClear:
        ldy #$0C
@blankPieceLoop:
        lda stack+95+17,y
        sta stack+80,y
        lda stack+95+17+1,y
        sta stack+80+1,y
        dey
        dey
        dey
        bpl @blankPieceLoop
        rts


stageRenderQueue:
        lda #$FF
        sta oldPiece0Data
        sta oldPiece1Data
        sta oldPiece2Data
        sta oldPiece3Data
        sta oldPiece4Data

        lda #$20
        sta linesAddress
        lda #$6F
        sta linesAddress+1

        lda #$20
        sta scoreAddress
        lda #$F7
        sta scoreAddress+1

        ; 3 rows that represent where pieces can spawn
        lda #$20
        sta spawnRow1Address
        lda #$CB
        sta spawnRow1Address+1
        lda #$20
        sta spawnRow2Address
        lda #$EC
        sta spawnRow2Address+1
        lda #$21
        sta spawnRow3Address
        lda #$0C
        sta spawnRow3Address+1

        lda #$22
        sta levelAddress
        lda #$D8
        sta levelAddress+1

        lda #$3F
        sta paletteTetrisAddress
        lda #$0E
        sta paletteTetrisAddress+1

        lda #$3F
        sta paletteBGAddress
        lda #$08
        sta paletteBGAddress+1

        lda #$3F
        sta paletteSpriteAddress
        lda #$18
        sta paletteSpriteAddress+1

        rts


stage_playfield_render:
        lda playState
        cmp #$04
        bne @normalRender
        rts

@normalRender:

        lda lines+1
        sta linesData
        lda lines
        lsr
        lsr
        lsr
        lsr
        sta linesData+1
        lda lines
        and #$0F
        sta linesData+2

        ldx levelNumber
        lda levelDisplayTable,x
        lsr
        lsr
        lsr
        lsr
        sta levelData
        lda levelDisplayTable,x
        and #$0F
        sta levelData+1

        lda score+2
        lsr
        lsr
        lsr
        lsr
        sta scoreData
        lda score+2
        and #$0F
        sta scoreData+1

        lda score+1
        lsr
        lsr
        lsr
        lsr
        sta scoreData+2
        lda score+1
        and #$0F
        sta scoreData+3


        lda score
        lsr
        lsr
        lsr
        lsr
        sta scoreData+4
        lda score
        and #$0F
        sta scoreData+5

        ldx currentPiece
        lda tetriminoTypeFromOrientation, x
        asl
        tax
        lda pieceToPpuStatAddr,x
        sta statsAddress
        lda pieceToPpuStatAddr+1,x
        sta statsAddress+1
        lda statsByType+1,x
        sta statsData
        lda statsByType,x
        lsr
        lsr
        lsr
        lsr
        sta statsData+1
        lda statsByType,x
        and #$0F
        sta statsData+2

        jsr updatePaletteForLevel

        ldx #$4F
        lda #$00
@clearRenderQueue:
        sta stack,x
        dex
        bpl @clearRenderQueue

        lda #$0
        sta currentVramRender
        jsr copyPlayfieldRowToVRAM
        lda #$10
        sta currentVramRender
        jsr copyPlayfieldRowToVRAM
        lda #$20
        sta currentVramRender
        jsr copyPlayfieldRowToVRAM
        lda #$30
        sta currentVramRender
        jsr copyPlayfieldRowToVRAM
        lda #$40
        sta currentVramRender
        jmp copyPlayfieldRowToVRAM
