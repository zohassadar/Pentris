        .setcpu "6502"
; see https://github.com/CelestialAmber/TetrisNESDisasm/blob/master/main.asm for comments related to memory

.include "pentris-ram.asm"

PPUCTRL         := $2000
PPUMASK         := $2001
PPUSTATUS       := $2002
OAMADDR         := $2003
OAMDATA         := $2004
PPUSCROLL       := $2005
PPUADDR         := $2006
PPUDATA         := $2007
SQ1_VOL         := $4000
SQ1_SWEEP       := $4001
SQ1_LO          := $4002
SQ1_HI          := $4003
SQ2_VOL         := $4004
SQ2_SWEEP       := $4005
SQ2_LO          := $4006
SQ2_HI          := $4007
TRI_LINEAR      := $4008
TRI_LO          := $400A
TRI_HI          := $400B
NOISE_VOL       := $400C
NOISE_LO        := $400E
NOISE_HI        := $400F
DMC_FREQ        := $4010
DMC_RAW         := $4011
DMC_START       := $4012                        ; start << 6 + $C000
DMC_LEN         := $4013                        ; len << 4 + 1
OAMDMA          := $4014
SND_CHN         := $4015
JOY1            := $4016
JOY2_APUFC      := $4017                        ; read: bits 0-4 joy data lines (bit 0 being normal controller), bits 6-7 are FC inhibit and mode

MMC1_Control    := $9FFF
MMC1_CHR0       := $BFFF
MMC1_CHR1       := $DFFF
MMC1_PRG        := $FFFF

LFFFF           := $FFFF ; used in music tables

CNROM_BANK0 := $00
CNROM_BANK1 := $01
CNROM_BANK2 := $02

CNROM_BG0 := $00
CNROM_BG1 := $10
CNROM_SPRITE0 := $00
CNROM_SPRITE1 := $08


BUTTON_DOWN := $4
BUTTON_UP := $8
BUTTON_RIGHT := $1
BUTTON_LEFT := $2
BUTTON_B := $40
BUTTON_A := $80
BUTTON_SELECT := $20
BUTTON_START := $10
ALMOST_ANY := BUTTON_DOWN+BUTTON_UP+BUTTON_LEFT+BUTTON_RIGHT+BUTTON_A+BUTTON_B

; contains macros to lda & cmp the hidden piece ID
.include "orientation/hidden_piece_id.asm"


.segment        "PRG_chunk1": absolute

; incremented to reset MMC1 reg
initRam:
        ldx #$00
        jmp initRamContinued

nmi:
        pha
        txa
        pha
        tya
        pha
        jsr render
        lda #$02
        sta OAMDMA
        lda #$00
        sta PPUSCROLL
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        lda #$00
        sta oamStagingLength
        dec sleepCounter
        lda sleepCounter
        cmp #$FF
        bne @jumpOverIncrement
        inc sleepCounter
@jumpOverIncrement:
        lda frameCounter
        clc
        adc #$01
        sta frameCounter
        lda #$00
        adc frameCounter+1
        sta frameCounter+1
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudoAndAlsoBSeed

        lda #$01
        sta verticalBlankingInterval
        jsr pollControllerButtons
.ifdef DEBUG
        lda newlyPressedButtons_player1
        cmp #BUTTON_UP
        bne @ret
        ldy nextPiece
        lda tetriminoTypeFromOrientation,y
        clc
        adc #$01
        cmp #$12
        bne @noReset
        lda #$00
@noReset:
        tay
        lda spawnTable,y
        sta nextPiece
@ret:
.endif
        pla
        tay
        pla
        tax
        pla
irq:
        rti

render:
        lda renderMode
        cmp #$03
        beq skip_switch_s_plus_2a
        jsr switch_s_plus_2a
        .addr   render_mode_legal_and_title_screens
        .addr   render_mode_menu_screens
        .addr   render_mode_congratulations_screen
        .byte   $00,$00
        .addr   render_mode_ending_animation
        .addr   render_mode_pause
skip_switch_s_plus_2a:
.include "render.asm"
initRamContinued:
        ldy #$06
        sty tmp2
        ldy #$00
        sty tmp1
        lda #$00
@zeroOutPages:
        sta (tmp1),y
        dey
        bne @zeroOutPages
        dec tmp2
        bpl @zeroOutPages
        lda initMagic
        cmp #$12
        bne @initHighScoreTable
        lda initMagic+1
        cmp #$34
        bne @initHighScoreTable
        lda initMagic+2
        cmp #$56
        bne @initHighScoreTable
        lda initMagic+3
        cmp #$78
        bne @initHighScoreTable
        lda initMagic+4
        cmp #$9A
        bne @initHighScoreTable
        jmp @continueWarmBootInit

        ldx #$00
; Only run on cold boot
@initHighScoreTable:
        lda defaultHighScoresTable,x
        cmp #$FF
        beq @continueColdBootInit
        sta highScoreNames,x
        inx
        jmp @initHighScoreTable

@continueColdBootInit:
        lda #$12
        sta initMagic
        lda #$34
        sta initMagic+1
        lda #$56
        sta initMagic+2
        lda #$78
        sta initMagic+3
        lda #$9A
        sta initMagic+4
@continueWarmBootInit:
; default das values
        lda #$10
        sta anydasDASValue
        lda #$06
        sta anydasARRValue

        ldx #$89
        stx rng_seed
        dex
        stx rng_seed+1
        ldy #$00
        sty ppuScrollX
        sty PPUSCROLL
        ldy #$00
        sty ppuScrollY
        sty PPUSCROLL
        lda #$90
        sta currentPpuCtrl
        sta PPUCTRL
        lda #$06
        sta PPUMASK
        jsr LE006
        jsr updateAudio2
        jsr stageRenderQueue
        ; lda     #$C0
        ; sta     stack
        ; lda     #$80
        ; sta     stack+1
        ; lda     #$35
        ; sta     stack+3
        ; lda     #$AC
        ; sta     stack+4
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$20
        jsr LAA82
        lda #$24
        jsr LAA82
        lda #$28
        jsr LAA82
        lda #$2C
        jsr LAA82
        lda #$EF
        ldx #$04
        ldy #$05
        jsr memset_page
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$0E
        sta unused_0E
        lda #$00
        sta gameModeState
        sta gameMode
        sta frameCounter+1
@mainLoop:
        jsr branchOnGameMode
        cmp gameModeState
        bne @checkForDemoDataExhaustion
        jsr updateAudioWaitForNmiAndResetOamStaging
@checkForDemoDataExhaustion:
        lda gameMode
        cmp #$05
        bne @continue
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable
        bne @continue
        lda #>demoButtonsTable
        sta demoButtonsAddr+1
        lda #$00
        sta frameCounter+1
        lda #$01
        sta gameMode
@continue:
        jmp @mainLoop

gameMode_playAndEndingHighScore_jmp:
        jsr gameMode_playAndEndingHighScore
        rts

branchOnGameMode:
        lda gameMode
        jsr switch_s_plus_2a
        .addr   gameMode_legalScreen
        .addr   gameMode_titleScreen
        .addr   gameMode_gameTypeMenu
        .addr   gameMode_levelMenu
        .addr   gameMode_playAndEndingHighScore_jmp
        .addr   gameMode_playAndEndingHighScore_jmp
        .addr   gameMode_startDemo
gameModeState_updatePlayer1:
        jsr makePlayer1Active
        jsr branchOnPlayStatePlayer1
        jsr stageSpriteForCurrentPiece
        jsr savePlayer1State
        jsr stageSpriteForNextPiece
        inc gameModeState
        rts

gameModeState_updatePlayer2:
@ret:
        inc gameModeState
        rts

gameMode_playAndEndingHighScore:
        lda gameModeState
        jsr switch_s_plus_2a
        .addr   gameModeState_initGameBackground
        .addr   gameModeState_initGameState
        .addr   gameModeState_updateCountersAndNonPlayerState
        .addr   gameModeState_handleGameOver
        .addr   gameModeState_updatePlayer1
        .addr   gameModeState_updatePlayer2
        .addr   gameModeState_checkForResetKeyCombo
        .addr   gameModeState_startButtonHandling
        .addr   gameModeState_vblankThenRunState2
branchOnPlayStatePlayer1:
        lda playState
        jsr switch_s_plus_2a
        .addr   playState_unassignOrientationId
        .addr   playState_playerControlsActiveTetrimino
        .addr   playState_lockTetrimino
        .addr   playState_checkForCompletedRows
        .addr   playState_noop
        .addr   playState_updateLinesAndStatistics
        .addr   playState_bTypeGoalCheck
        .addr   playState_receiveGarbage
        .addr   playState_spawnNextTetrimino
        .addr   playState_noop
        .addr   playState_updateGameOverCurtain
        .addr   playState_incrementPlayState
playState_playerControlsActiveTetrimino:
        jsr shift_tetrimino
        jsr rotate_tetrimino
        jsr drop_tetrimino
        rts


gameMode_legalScreen:
        jsr updateAudio2
        lda #$00
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   legal_screen_palette
        lda #$20 ; offset
        jsr copyRleNametableToPpu
        .addr   legal_screen_nametable
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        ldx #$02
        ldy #$02
        jsr memset_page
        lda #$FF
        jsr sleep_for_a_vblanks
        lda #$FF
        sta generalCounter
@waitForStartButton:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        beq @continueToNextScreen
        jsr updateAudioWaitForNmiAndResetOamStaging
        dec generalCounter
        bne @waitForStartButton
@continueToNextScreen:
        inc gameMode
        rts

gameMode_titleScreen:
        jsr updateAudio2
        lda #$00
        sta renderMode
        sta $D0
        sta displayNextPiece
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr bulkCopyToPpu
        .addr   title_screen_nametable
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        ldx #$02
        ldy #$02
        jsr memset_page
        lda #$00
        sta frameCounter+1
@waitForStartButton:
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        beq @startButtonPressed
        lda frameCounter+1
        cmp #$05
        ; uncomment to restore demo
        ; beq     @timeout
        jmp @waitForStartButton

; Show menu screens
@startButtonPressed:
        lda #$02
        sta soundEffectSlot1Init
        inc gameMode
        rts

; Start demo
@timeout:
        ; uncomment to restore demo
        ; lda     #$02
        ; sta     soundEffectSlot1Init
        ; lda     #$06
        ; sta     gameMode
        rts

render_mode_legal_and_title_screens:
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
render_mode_pause:
        lda #$00
        sta ppuScrollX
        sta PPUSCROLL
        sta ppuScrollY
        sta PPUSCROLL
        rts
        lda #$00
        sta gameType
        lda #$04
        lda gameMode
        rts

gameMode_gameTypeMenu:
.ifndef CNROM
        inc initRam
        lda #$13
        jsr setMMC1Control
.endif
        lda #$01
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda currentPpuCtrl
        and #$FD
        sta currentPpuCtrl
        jsr bulkCopyToPpu
        .addr   menu_palette
        lda #$20
        jsr copyRleNametableToPpu
        .addr   game_type_menu_nametable
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
.endif
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
L830B:
        lda #$FF
        ldx #$02
        ldy #$02
        jsr memset_page
        lda newlyPressedButtons_player1
        cmp #BUTTON_RIGHT
        bne @rightNotPressed
        lda #$01
        sta gameType
        lda #$01
        sta soundEffectSlot1Init
        jmp @leftNotPressed

@rightNotPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_LEFT
        bne @leftNotPressed
        lda #$00
        sta gameType
        lda #$01
        sta soundEffectSlot1Init
@leftNotPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_DOWN
        bne @downNotPressed
        lda #$01
        sta soundEffectSlot1Init
        lda musicType
        cmp #$03
        beq @upNotPressed
        inc musicType
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
@downNotPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_UP
        bne @upNotPressed
        lda #$01
        sta soundEffectSlot1Init
        lda musicType
        beq @upNotPressed
        dec musicType
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
@upNotPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne @startNotPressed
        lda #$02
        sta soundEffectSlot1Init
        inc gameMode
        rts

@startNotPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_B
        bne @bNotPressed
        lda #$02
        sta soundEffectSlot1Init
        lda #$00
        sta frameCounter+1
        dec gameMode
        rts

@bNotPressed:
        ldy #$00
        lda gameType
        asl a
        sta generalCounter
        asl a
        adc generalCounter
        asl a
        asl a
        asl a
        asl a
        clc
        adc #$3F
        sta spriteXOffset
        lda #$3F
        sta spriteYOffset
        lda #$01
        sta spriteIndexInOamContentLookup
        lda frameCounter
        and #$03
        bne @flickerCursorPair1
        lda #$02
        sta spriteIndexInOamContentLookup
@flickerCursorPair1:
        jsr loadSpriteIntoOamStaging
        lda musicType
        asl a
        asl a
        asl a
        asl a
        clc
        adc #$8F
        sta spriteYOffset
        lda #$53
        sta spriteIndexInOamContentLookup
        lda #$67
        sta spriteXOffset
        lda frameCounter
        and #$03
        bne @flickerCursorPair2
        lda #$02
        sta spriteIndexInOamContentLookup
@flickerCursorPair2:
        jsr loadSpriteIntoOamStaging
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp L830B
checkForShuffle:
        lda newlyPressedButtons_player1
        and #BUTTON_SELECT
        beq @selectNotPressed

        lda rng_seed
        sta sps_seed
        lda rng_seed+1
        sta sps_seed+1
        lda frameCounter
        eor rng_seed+1
        sta sps_seed+2
@selectNotPressed:
        rts

menuLimits:
        .byte   $40,$40,$02,$02,$02,$04,$07

getSeedInput:
        sec
        sbc #$01
        lsr
        tax
        lda #$01
        bcs @noShift
        asl
        asl
        asl
        asl
@noShift:
        sta tmp1
        lda #BUTTON_UP
        jsr menuThrottle
        bne @upPressed
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @upDownNotPressed
        jsr playBeep
        lda sps_seed,x
        sec
        sbc tmp1
        sta sps_seed,x
        ldy tmp1
        cpy #$01
        bne @noReset
        and #$0F
        cmp #$0F
        beq @add16

        jmp @noReset
@add16:
        lda sps_seed,x
        clc
        adc #$10
        sta sps_seed,x
@noReset:
        jmp @upDownNotPressed

@upPressed:
        jsr playBeep
        lda sps_seed,x
        clc
        adc tmp1
        sta sps_seed,x
        ldy tmp1
        cpy #$01
        bne @upDownNotPressed
        and #$0F
        bne @upDownNotPressed
        lda sps_seed,x
        sec
        sbc #$10
        sta sps_seed,x

@upDownNotPressed:
        jsr checkForShuffle
        lda seedPosition
        asl
        asl
        asl
        adc #$90
        sta oamStaging+3
        lda #$C7
        sta oamStaging
        lda #$63
        sta oamStaging+1
        jmp flashAndChooseHole

getMenuInput:
        ldx menuMode
        cpx #$09
        beq @leftRightNotPressed
        lda #BUTTON_RIGHT
        jsr menuThrottle
        bne @rightPressed

        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @leftRightNotPressed
        jsr playBeep
        dec menuOffset-2,x
        bpl @leftRightNotPressed
        jsr noBeep
        inc menuOffset-2,x
        beq @leftRightNotPressed

@rightPressed:
        jsr playBeep
        inc menuOffset-2,x
        lda menuOffset-2,x
        cmp menuLimits-2,x
        bne @leftRightNotPressed
        jsr noBeep
        dec menuOffset-2,x

@leftRightNotPressed:
        lda seedPosition
        beq @noSeedInput
        jmp getSeedInput
@noSeedInput:
        lda #BUTTON_UP
        jsr menuThrottle
        beq @upNotPressed
        jsr playBeep
        dec menuMode
        jmp @moveSpriteAndGo

@upNotPressed:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @downNotPressed
        inc menuMode
        jsr playBeep
        lda menuMode
        cmp #$0A
        bne @moveSpriteAndGo
        jsr noBeep
        dec menuMode
@downNotPressed:
        lda newlyPressedButtons_player1
        and #BUTTON_START+BUTTON_A
        beq @startOrANotPressed
        lda menuMode
        cmp #$09
        bne @startOrANotPressed
        lda sps_seed+1
        bne @bloop
        jsr isSeedValid
        beq @noBloop
@bloop:
        lda #$02
        sta soundEffectSlot1Init
@noBloop:
        lda #$00
        sta sps_seed
        sta sps_seed+1
        sta sps_seed+2
@startOrANotPressed:
        lda menuMode
        cmp #$08
        bne @moveSpriteAndGo
        jsr checkForShuffle
@moveSpriteAndGo:
        lda menuMode
        asl
        asl
        asl
        adc #$7F
        sta oamStaging
        lda #$28
        sta oamStaging+3
flashAndChooseHole:
        jsr flashNewMenuCursor
        jsr isSeedValid
        jmp checkBPressed

flashNewMenuCursor:
        lda frameCounter
        and #$03
        bne @skipSkippingShowingToggleCursor
        ; hide every 4th frame
        lda #$FF
        sta oamStaging
@skipSkippingShowingToggleCursor:
        rts


gameMode_levelMenu:
.ifndef CNROM
        inc initRam
        lda #$13
        jsr setMMC1Control
.endif
        jsr updateAudio2
        lda #$01
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   menu_palette
        lda #$20
        jsr copyRleNametableToPpu
        .addr   level_menu_nametable
        lda #$28
        jsr copyRleNametableToPpu
        .addr   level_menu_nametable
        jsr bulkCopyToPpu
        .addr   menu_options_nametable
        jsr bulkCopyToPpu
        .addr   show_scores_nametable_patch

    ; make menu arrow yellow
        lda #$3F
        sta PPUADDR
        lda #$1D
        sta PPUADDR
        lda #$27
        sta PPUDATA

        lda gameType
        bne @skipTypeBHeightDisplay
        jsr bulkCopyToPpu
        .addr   height_menu_nametablepalette_patch

@skipTypeBHeightDisplay:
        jsr showHighScores
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta PPUSCROLL
        lda #$00
        sta PPUSCROLL
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$00
        sta originalY
        sta dropSpeed
@forceStartLevelToRange:
        lda startLevel
        cmp #$0A
        bcc gameMode_levelMenu_processPlayer1Navigation
        sec
        sbc #$0A
        sta startLevel
        jmp @forceStartLevelToRange

toggleMenuScreen:
        lda menuScreen
        eor #$02
        sta menuScreen
        ;lda     #$16
        ;sta     currentPpuMask
        ;sta     PPUMASK
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda currentPpuCtrl
        and #$FD
        ora menuScreen
        sta currentPpuCtrl
        sta PPUCTRL
        lda #$02
        sta soundEffectSlot1Init
        jmp showSelectionLevel

gameMode_levelMenu_processPlayer1Navigation:
        ; stage sprite no matter
        ldx oamStagingLength
        lda #$7F
        sta oamStaging
        lda #$27
        sta oamStaging+1
        lda #$03
        sta oamStaging+2
        lda #$40
        sta oamStaging+3
        lda #$04
        ; assumes that oamStagingLength is 0
        ; this is unsafe maybe, if sprites are ever staged before this
        sta oamStagingLength

        lda menuMode
        bne @newMenu

        ; use outline of arrow when not in new menu
        lda #$5B
        sta oamStaging+1

        jmp originalMenu
@newMenu:
        jsr flashNewMenuCursor


        jsr showSelectionLevel

        lda menuMode
        cmp #$01
        beq @checkForUpAndDown
        jmp getMenuInput
@checkForUpAndDown:
        lda newlyPressedButtons_player1
        and #BUTTON_START+BUTTON_A
        beq @checkUpPressed
        jsr toggleMenuScreen
@checkUpPressed:
        lda #BUTTON_UP
        jsr menuThrottle
        beq @upNotPressed
        dec menuMode
        jsr playBeep
@upNotPressed:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @downNotPressed
        lda menuScreen
        beq @downNotPressed
        inc menuMode
        jsr playBeep
@downNotPressed:
        jmp checkBPressed

noBeep:
        lda #$00
        beq storeBeep
playBeep:
        lda #$01
storeBeep:
        sta soundEffectSlot1Init
        rts


originalMenu:
        lda originalY
        sta selectingLevelOrHeight
        lda newlyPressedButtons_player1
        sta newlyPressedButtons
        jsr gameMode_levelMenu_handleLevelHeightNavigation
        lda selectingLevelOrHeight
        sta originalY
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne checkBPressed
        lda heldButtons_player1
        cmp #BUTTON_A|BUTTON_START
        bne startAndANotPressed
        lda startLevel
        clc
        adc #$0A
        sta startLevel
startAndANotPressed:
        lda #$00
        sta gameModeState
        lda #$02
        sta soundEffectSlot1Init
        inc gameMode
        rts

checkBPressed:
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq chooseRandomHole_player1
        lda #$00
        sta menuMode
        sta seedPosition
        sta menuScreen
        lda #$02
        sta soundEffectSlot1Init
        dec gameMode
        rts

chooseRandomHole_player1:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl chooseRandomHole_player1
        ;sta     garbageHole
@chooseRandomHole_player2:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl @chooseRandomHole_player2
        ;sta     unused_0E
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp gameMode_levelMenu_processPlayer1Navigation

; Starts by checking if right pressed
gameMode_levelMenu_handleLevelHeightNavigation:
        lda newlyPressedButtons
        cmp #BUTTON_RIGHT
        bne @checkLeftPressed
        lda #$01
        sta soundEffectSlot1Init
        lda selectingLevelOrHeight
        bne @rightPressedForHeightSelection
        lda startLevel
        cmp #$09
        beq @checkLeftPressed
        inc startLevel
        jmp @checkLeftPressed

@rightPressedForHeightSelection:
        lda startHeight
        cmp #$05
        beq @checkLeftPressed
        inc startHeight
@checkLeftPressed:
        lda newlyPressedButtons
        cmp #BUTTON_LEFT
        bne @checkDownPressed
        lda #$01
        sta soundEffectSlot1Init
        lda selectingLevelOrHeight
        bne @leftPressedForHeightSelection
        lda startLevel
        beq @checkDownPressed
        dec startLevel
        jmp @checkDownPressed

@leftPressedForHeightSelection:
        lda startHeight
        beq @checkDownPressed
        dec startHeight
@checkDownPressed:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @checkUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda selectingLevelOrHeight
        bne @downPressedForHeightSelection
        lda startLevel
        cmp #$05
        bpl @menuToggle
        clc
        adc #$05
        sta startLevel
        jmp @checkUpPressed

@downPressedForHeightSelection:
        lda startHeight
        cmp #$03
        bpl @menuToggle
        inc startHeight
        inc startHeight
        inc startHeight
        bne @checkUpPressed
@menuToggle:
        inc menuMode
@checkUpPressed:
        lda newlyPressedButtons
        cmp #BUTTON_UP
        bne @checkAPressed
        lda #$01
        sta soundEffectSlot1Init
        lda selectingLevelOrHeight
        bne @upPressedForHeightSelection
        lda startLevel
        cmp #$05
        bmi @checkAPressed
        sec
        sbc #$05
        sta startLevel
        jmp @checkAPressed

@upPressedForHeightSelection:
        lda startHeight
        cmp #$03
        bmi @checkAPressed
        dec startHeight
        dec startHeight
        dec startHeight
@checkAPressed:
        lda gameType
        beq showSelection
        lda newlyPressedButtons
        cmp #BUTTON_A
        bne showSelection
        lda #$01
        sta soundEffectSlot1Init
        lda selectingLevelOrHeight
        eor #$01
        sta selectingLevelOrHeight
showSelection:
        lda selectingLevelOrHeight
        bne showSelectionLevel
        lda frameCounter
        and #$03
        beq skipShowingSelectionLevel
showSelectionLevel:
        ldx startLevel
        lda levelToSpriteYOffset,x
        sta spriteYOffset
        lda #$00
        sta spriteIndexInOamContentLookup
        ldx startLevel
        lda levelToSpriteXOffset,x
        sta spriteXOffset
        jsr loadSpriteIntoOamStaging
skipShowingSelectionLevel:
        lda gameType
        beq @ret
        lda selectingLevelOrHeight
        beq @showSelectionHeight
        lda menuMode
        bne @showSelectionHeight
        lda frameCounter
        and #$03
        beq @ret
@showSelectionHeight:
        ldx startHeight
        lda heightToPpuHighAddr,x
        sta spriteYOffset
        lda #$00
        sta spriteIndexInOamContentLookup
        ldx startHeight
        lda heightToPpuLowAddr,x
        sta spriteXOffset
        jsr loadSpriteIntoOamStaging
@ret:
        rts

levelToSpriteYOffset:
        .byte   $53,$53,$53,$53,$53,$63,$63,$63
        .byte   $63,$63
levelToSpriteXOffset:
        .byte   $34,$44,$54,$64,$74,$34,$44,$54
        .byte   $64,$74
heightToPpuHighAddr:
        .byte   $53,$53,$53,$63,$63,$63
heightToPpuLowAddr:
        .byte   $9C,$AC,$BC,$9C,$AC,$BC
musicSelectionTable:
        .byte   $03,$04,$05,$FF,$06,$07,$08,$FF

isSeedValid:
        lda #$01
        sta validSeed
        lda sps_seed
        bne @valid
        lda sps_seed+1
        cmp #$2
        bcs @valid
        dec validSeed
@valid:
        rts

render_mode_menu_screens:
; begin inefficient menu render

; draw the easy ones first
        lda gameMode
        cmp #$04
        bne @draw
        jmp @dontDraw
@draw:
        lda #$2A
        sta PPUADDR
        lda #$57
        sta PPUADDR
        lda anydasDASValue
        jsr twoDigsToPPU

        lda #$2A
        sta PPUADDR
        lda #$77
        sta PPUADDR
        lda anydasARRValue
        jsr twoDigsToPPU

        lda #$2A
        sta PPUADDR
        lda #$96
        sta PPUADDR
        lda anydasARECharge
        beq @areOff
        jsr writeOn
        bne @tetriminos
@areOff:
        jsr writeOff
@tetriminos:

        lda #$2A
        sta PPUADDR
        lda #$B6
        sta PPUADDR
        lda tetriminoMode
        beq @tetriminoOff
        jsr writeOn
        bne @sxtokl
@tetriminoOff:
        jsr writeOff
@sxtokl:

        lda #$2A
        sta PPUADDR
        lda #$D6
        sta PPUADDR
        lda sxtokl
        beq @sxtoklOff
        jsr writeOn
        bne @marathon
@sxtoklOff:
        jsr writeOff
@marathon:
        lda #$2A
        sta PPUADDR
        lda #$F6
        sta PPUADDR
        lda marathon
        beq @marathonOff
        ldy #$FF
        sty PPUDATA
        sty PPUDATA
        sta PPUDATA
        bne @seed
@marathonOff:
        jsr writeOff

@seed:
        lda #$2B
        sta PPUADDR
        lda #$13
        sta PPUADDR
        lda sps_seed
        jsr twoDigsToPPU
        lda sps_seed+1
        jsr twoDigsToPPU
        lda sps_seed+2
        jsr twoDigsToPPU

        lda #$2B
        sta PPUADDR
        lda #$0C
        sta PPUADDR
        lda validSeed
        beq @invalidSeed
        jsr writeOnWithoutSpace
        lda #$FF
        sta PPUDATA
        bne @dontDraw
@invalidSeed:
        jsr writeOff
@dontDraw:
        lda currentPpuCtrl
        and #$FE
        sta currentPpuCtrl
        sta PPUCTRL
        lda #$00
        sta ppuScrollX
        sta PPUSCROLL
        sta ppuScrollY
        sta PPUSCROLL
        rts

writeOff:
        lda #$18
        sta PPUDATA
        lda #$F
        sta PPUDATA
        sta PPUDATA
        rts

writeOn:
        lda #$FF
        sta PPUDATA
writeOnWithoutSpace:
        lda #$18
        sta PPUDATA
        lda #$17
        sta PPUDATA
        rts

hideTetriminoStatsPatch:
        .byte  $2B,$23,$01,$FD ; lower left corner
        .byte  $2B,$3C,$01,$FF ; lower right corner
        .byte  $2B,$04,$58,$F7 ; inner black stripe
        .byte  $2B,$24,$58,$FE ; border stripe
        .byte  $2B,$40,$40,$F7 ; 2 black stripes
        .byte  $2B,$80,$60,$F7 ; 1 black stripes
        .byte  $2B,$F1,$46,$FF ; attributes
        .byte  $FF

patchSeedIfValid:
        lda validSeed
        beq @noSeed
        lda #$23
        sta PPUADDR
        lda #$57
        sta PPUADDR
        lda sps_seed
        jsr twoDigsToPPU
        lda sps_seed+1
        jsr twoDigsToPPU
        lda sps_seed+2
        jsr twoDigsToPPU
@noSeed:
        rts

gameModeState_initGameBackground:
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda currentPpuCtrl
        and #$FC
        sta currentPpuCtrl
        lda #$00
        sta menuScreen    ; reset
        sta newPiece0Address
        sta newPiece1Address
        sta newPiece2Address
        sta newPiece3Address
        sta newPiece4Address
.ifdef CNROM
        lda #CNROM_BANK1
        ldy #CNROM_BG1
        ldx #CNROM_SPRITE1
        jsr changeCHRBank
.else
        lda #$03
        jsr changeCHRBank0
        lda #$03
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   game_palette
        lda #$28
        jsr copyRleNametableToPpu
        .addr   stats_nametable
        lda #$20
        jsr copyRleNametableToPpu
        .addr   game_nametable

        lda tetriminoMode
        bne @tetriminoMode
        jsr bulkCopyToPpu
        .addr   hideTetriminoStatsPatch
@tetriminoMode:
        lda #$23
        sta PPUADDR
        lda #$57
        sta PPUADDR
        lda gameType
        bne @typeB
        lda #$0A
        sta PPUDATA
        jsr patchSeedIfValid
        lda #$20
        sta PPUADDR
        lda #$97
        sta PPUADDR
        lda highScoreScoresA
        jsr twoDigsToPPU
        lda highScoreScoresA+1
        jsr twoDigsToPPU
        lda highScoreScoresA+2
        jsr twoDigsToPPU
        jmp gameModeState_initGameBackground_finish

@typeB:
        lda #$0B
        sta PPUDATA
        jsr patchSeedIfValid
        lda #$20
        sta PPUADDR
        lda #$97
        sta PPUADDR
        lda highScoreScoresB
        jsr twoDigsToPPU
        lda highScoreScoresB+1
        jsr twoDigsToPPU
        lda highScoreScoresB+2
        jsr twoDigsToPPU
        jmp @endOfPpuPatching  ; Disable patch for now!
        ldx #$00
@nextPpuAddress:
        lda game_typeb_nametable_patch,x
        inx
        sta PPUADDR
        lda game_typeb_nametable_patch,x
        inx
        sta PPUADDR
@nextPpuData:
        lda game_typeb_nametable_patch,x
        inx
        cmp #$FE
        beq @nextPpuAddress
        cmp #$FD
        beq @endOfPpuPatching
        sta PPUDATA
        jmp @nextPpuData

@endOfPpuPatching:
        lda #$22
        sta PPUADDR
        lda #$DA
        sta PPUADDR
        lda #$24
        sta PPUDATA
        lda startHeight
        and #$0F
        sta PPUDATA
        jmp gameModeState_initGameBackground_finish

gameModeState_initGameBackground_finish:
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$01
        sta playState
        lda startLevel
        ldy marathon
        cpy #$03  ; 3 starts at level 0
        bne @noStartAtZero
        ldy gameType
        bne @noStartAtZero
        lda #$00
@noStartAtZero:
        sta levelNumber
        inc gameModeState
        rts

game_typeb_nametable_patch:
        .byte   $22,$F7,$38,$39,$39,$39,$39,$39,$39,$3A,$FE
        .byte   $23,$17,$3B,$11,$0E,$12,$10,$11,$1D,$3C,$FE
        .byte   $23,$37,$3B,$FF,$FF,$FF,$FF,$FF,$FF,$3C,$FE
        .byte   $23,$57,$3D,$3E,$3E,$3E,$3E,$3E,$3E,$3F,$FD


gameModeState_initGameState:
        lda #$EF
        ldx #$04
        ldy #$05
        jsr memset_page
        jsr setupRngBytes
        jsr stageSpawnAreaTiles
        lda #$00
        ldx #$4B
; statsByType
@initStatsByType:
        sta $0300,x
        dex
        bpl @initStatsByType
        lda #$04
        sta renderedPlayfield
        lda #$07
        sta tetriminoX
        lda #$00
        sta completedLines
        sta statsPiecesTotal
        sta statsPiecesTotal+1

        lda #$0A    ; starting on row 10 compensates for glitchy behavior
                        ; I *think* because the first time around is the only
                        ; time the full board is loaded (the rest only 4 at a time)
                        ; 40 new tiles worth of time was added to the process
                        ; This work around causes only the bottom part of the
                        ; board to be redrawn
        sta vramRow
        lda #$00
        sta fallTimer
        sta pendingGarbage
        sta pendingGarbageInactivePlayer
        sta score
        sta score+1
        sta score+2
.ifdef DEBUG
        lda #$7C
        sta score
        sta score+1
        sta score+2
        ldy #$9a
@plantBlocks:
        sta leftPlayfield,y
        sta rightPlayfield,y
        dey
        cpy #$76
        bne @plantBlocks
        lda #$EF
        sta $047d
        sta $0484
        sta $048b
        sta $0492
        sta $0499
        lda #$09
        sta lines
        lda #$00
        sta lines+1
.else
        sta lines
        sta lines+1
.endif


.ifdef TOPROWSETUP
        lda #$7C
        sta $0400
        sta $0401
        sta $0402
        sta $0403
        sta $0404
        sta $040C

        sta $0503
        sta $0504
        sta $0505
        sta $0506


        lda #$00
        sta vramRow
.endif


        sta twoPlayerPieceDelayCounter
        sta lineClearStatsByType
        sta lineClearStatsByType+1
        sta lineClearStatsByType+2
        sta lineClearStatsByType+3
        sta lineClearStatsByType+4
        sta allegro
        sta demo_heldButtons
        sta demo_repeats
        sta demoIndex
        sta demoButtonsAddr
        sta spawnID
        lda #>demoButtonsTable
        sta demoButtonsAddr+1
        lda #$03
        sta renderMode
        lda #$A0
        sta autorepeatY
        jsr initializeSPS
        jsr chooseNextTetrimino
.ifdef DEBUG
        lda #$3e
.endif
.ifdef TOPROWSETUP
        lda #$3e
.endif
        sta currentPiece
        jsr incrementPieceStat
        ldx currentPiece
        lda #$00
        clc
        adc spawnOffsets,x
        sta tetriminoY
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        jsr chooseNextTetrimino
        sta nextPiece
        sta twoPlayerPieceDelayPiece
        lda gameType
        beq @skipTypeBInit
        lda #$25
        sta lines
@skipTypeBInit:
        lda #$47
        sta outOfDateRenderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$04
@setupSingleField:
        sta playfieldAddr+1
        jsr initPlayfieldIfTypeB
        ; jsr     updateAudioWaitForNmiAndResetOamStaging
        inc playfieldAddr+1
        lda playfieldAddr+1
        cmp #$06
        bne @setupSingleField
        dec playfieldAddr+1
        dec playfieldAddr+1
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        inc gameModeState
        rts

; Copies $60 to $40
makePlayer1Active:
        lda newlyPressedButtons_player1
        sta newlyPressedButtons
        lda heldButtons_player1
        sta heldButtons
        rts

; Copies $80 to $40
makePlayer2Active:
        lda #$02
        sta activePlayer
        lda newlyPressedButtons_player2
        sta newlyPressedButtons
        lda heldButtons_player2
        sta heldButtons
        rts

; Copies $40 to $60
savePlayer1State:
@ret:
        rts

; Copies $40 to $80
savePlayer2State:
        rts

initPlayfieldIfTypeB:
        lda gameType
        bne initPlayfieldForTypeB
        jmp endTypeBInit

initPlayfieldForTypeB:
        lda #$0C
        sta generalCounter  ; decrements

typeBRows:
        lda generalCounter
        beq initCopyPlayfieldToPlayer2
        lda #$16
        sec
        sbc generalCounter
        sta generalCounter2  ; row (22 - generalCounter)
        lda #$00
        sta vramRow
        lda #$06
        sta generalCounter3 ; column

typeBGarbageInRow:
        ldx bSeedSource  ; previously #rng_seed
        ldy #$02
        jsr generateNextPseudoAndAlsoCopy
        lda bseedCopy ; previously rng_seed
        and #$07
        tay
        lda rngTable,y
        sta generalCounter4 ; random square or blank
        ldx generalCounter2
        lda multBy7Table,x
        clc
        adc generalCounter3
        tay
        lda generalCounter4
        sta (playfieldAddr),y
        lda generalCounter3
        beq typeBGuaranteeBlank
        dec generalCounter3
        jmp typeBGarbageInRow

typeBGuaranteeBlank:
        ldx bSeedSource  ; previously #rng_seed
        ldy #$02
        jsr generateNextPseudoAndAlsoCopy
        lda bseedCopy ; previously rng_seed
        and #$07
        cmp #$07
        bpl typeBGuaranteeBlank

        sta generalCounter5 ; blanked column
        ldx generalCounter2
        lda multBy7Table,x
        clc
        adc generalCounter5
        tay
        lda #$EF
        sta (playfieldAddr),y
        ; jsr     updateAudioWaitForNmiAndResetOamStaging  ; This doesn't work here in doublewide mode
        dec generalCounter
        bne typeBRows

initCopyPlayfieldToPlayer2:

; Player1 Blank Lines
        ldx startHeight
        lda typeBBlankInitCountByHeightTable,x
        clc
        adc #$0E  ; Add 2 rows
        tay
        lda #$EF

typeBBlankInitPlayer1:
        sta (playfieldAddr),y
        dey
        cpy #$FF
        bne typeBBlankInitPlayer1

endTypeBInit:
        rts

typeBBlankInitCountByHeightTable:
        ; >>> "$" + ",$".join(f'{int(c,16)//10*7:02x}'.upper()
        ;for c in "$C8,$AA,$96,$78,$64,$50".replace("$","").split(","))
        .byte   $8C,$77,$69,$54,$46,$38
rngTable:
        .byte   $EF,$7B,$EF,$7C,$7D,$7D,$EF
        .byte   $EF
gameModeState_updateCountersAndNonPlayerState:
        lda pauseScreen
.ifdef CNROM
        beq @gameMode
@statsMode:
        lda #CNROM_BANK2
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        beq @changeChrBank
@gameMode:
        lda #CNROM_BANK1
        ldy #CNROM_BG1
        ldx #CNROM_SPRITE1
@changeChrBank:
        jsr changeCHRBank
.else
        lsr
        clc
        adc #$03
        sta generalCounter
        jsr changeCHRBank0
        lda generalCounter
        jsr changeCHRBank1
.endif
        lda #$00
        sta oamStagingLength
        inc fallTimer
        lda twoPlayerPieceDelayCounter
        beq @checkSelectButtonPressed
        inc twoPlayerPieceDelayCounter
@checkSelectButtonPressed:
        lda newlyPressedButtons_player1
        and #BUTTON_SELECT
        beq @ret
.ifndef DEBUG
        lda displayNextPiece
        eor #$01
        sta displayNextPiece
.endif
@ret:
        inc gameModeState
        rts

rotate_tetrimino:
        lda currentPiece
        sta originalY
        clc
        lda currentPiece
        tax
        lda newlyPressedButtons
        and #BUTTON_A
        cmp #BUTTON_A
        bne @aNotPressed
        lda rotationTableNext,x
        sta currentPiece
        jsr isPositionValid
        bne @restoreOrientationID
        lda #$05
        sta soundEffectSlot1Init
        jmp @ret

@aNotPressed:
        lda newlyPressedButtons
        and #BUTTON_B
        cmp #BUTTON_B
        bne @ret
        lda rotationTablePrevious,x
        sta currentPiece
        jsr isPositionValid
        bne @restoreOrientationID
        lda #$05
        sta soundEffectSlot1Init
        jmp @ret

@restoreOrientationID:
        lda originalY
        sta currentPiece
@ret:


        rts

.include "orientation/rotation_table.asm"

drop_tetrimino:
        lda autorepeatY
        bpl @notBeginningOfGame
        lda newlyPressedButtons
        and #BUTTON_DOWN
        beq @incrementAutorepeatY
        lda #$00
        sta autorepeatY
@notBeginningOfGame:
        bne @autorepeating
@playing:
        lda heldButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        bne @lookupDropSpeed
        lda newlyPressedButtons
        and #BUTTON_UP|BUTTON_DOWN|BUTTON_LEFT|BUTTON_RIGHT
        cmp #BUTTON_DOWN
        bne @lookupDropSpeed
        lda #$01
        sta autorepeatY
        jmp @lookupDropSpeed

@autorepeating:
        lda heldButtons
        and #BUTTON_UP|BUTTON_DOWN|BUTTON_LEFT|BUTTON_RIGHT
        cmp #BUTTON_DOWN
        beq @downPressed
        lda #$00
        sta autorepeatY
        sta holdDownPoints
        jmp @lookupDropSpeed

@downPressed:
        inc autorepeatY
        lda autorepeatY
        cmp #$03
        bcc @lookupDropSpeed
        lda #$01
        sta autorepeatY
        inc holdDownPoints
@drop:
        lda #$00
        sta fallTimer
        lda tetriminoY
        sta originalY
.ifdef DEBUG
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq @dontLower
.endif
        inc tetriminoY
.ifdef DEBUG
@dontLower:
.endif
        jsr isPositionValid
        beq @ret
        lda originalY
        sta tetriminoY
        lda #$02
        sta playState
        jsr updatePlayfield
@ret:
        rts

@lookupDropSpeed:
        lda #$01
        ldx marathon
        beq @notMarathon
        ldx startLevel ; use startLevel no matter what when marathon (1,2,3)
        jmp @tableLookup
@notMarathon:
        ldx levelNumber
@tableLookup:
        cpx #$1D
        bcs @noTableLookup
        lda framesPerDropTable,x
@noTableLookup:
        sta dropSpeed
        lda fallTimer
        cmp dropSpeed
        bpl @drop
        jmp @ret

@incrementAutorepeatY:
        inc autorepeatY
        jmp @ret

framesPerDropTable:
        .byte   $30,$2B,$26,$21,$1C,$17,$12,$0D
        .byte   $08,$06,$05,$05,$05,$04,$04,$04
        .byte   $03,$03,$03,$02,$02,$02,$02,$02
        .byte   $02,$02,$02,$02,$02,$01
unreferenced_framesPerDropTable:
        .byte   $01,$01
shift_tetrimino:
        lda tetriminoX
        sta originalY
        lda heldButtons
        and #BUTTON_DOWN
        bne shift_ret
        lda newlyPressedButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        bne resetAutorepeatX
        lda heldButtons
        and #BUTTON_LEFT|BUTTON_RIGHT
        beq shift_ret
;.ifdef ANYDAS
        dec autorepeatX
        lda autorepeatX
        cmp #$01
        bpl shift_ret
        lda anydasARRValue
        sta autorepeatX
        jmp checkFor0Arr
resetAutorepeatX:
        lda anydasDASValue
;.else ; original das code
;        inc     autorepeatX
;        lda     autorepeatX
;        cmp     #$10
;        bmi     shift_ret
;        lda     #$0A
;        sta     autorepeatX
;        jmp     @buttonHeldDown
;
;@resetAutorepeatX:
;        lda     #$00
;.endif
        sta autorepeatX
buttonHeldDown:
        lda heldButtons
        and #BUTTON_RIGHT
        beq notPressingRight
        inc tetriminoX
        jsr isPositionValid
        bne restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp shift_ret

notPressingRight:
        lda heldButtons
        and #BUTTON_LEFT
        beq shift_ret
        dec tetriminoX
        jsr isPositionValid
        bne restoreX
        lda #$03
        sta soundEffectSlot1Init
        jmp shift_ret

restoreX:
        lda originalY
        sta tetriminoX
;.ifdef ANYDAS
        lda #$01
;.else ; original das code
;        lda     #$10
;.endif
        sta autorepeatX
shift_ret:
        rts


stageSpriteForNextPiece:
        lda pauseScreen
        beq @continue
        rts
@continue:
        lda displayNextPiece
        bne @ret
        lda #$CC
        ldx nextPiece
        clc
        adc nextOffsetX,x
        sta generalCounter3
        lda #$72
        clc
        adc nextOffsetY,x
        sta generalCounter4
        txa
        lda nextPiece
        jsr setOrientationTable
        ldy #$00 ; y contains index into orientation table
        ldx oamStagingLength
        lda #$05
        sta generalCounter2 ; iterate through all five minos
@stageMino:
        lda (currentOrientationY),y
        asl a
        asl a
        asl a
        clc
        adc generalCounter4
        sta oamStaging,x ; stage y coordinate of mino
        inx
        lda currentTile
        sta oamStaging,x ; stage block type of mino
        inx
        lda #$02
        sta oamStaging,x ; stage palette/front priority
        inx
        lda (currentOrientationX),y
        asl a
        asl a
        asl a
        clc
        adc generalCounter3
        sta oamStaging,x ; stage actual x coordinate
@finishLoop:
        inx
        iny
        dec generalCounter2
        bne @stageMino
        txa
        sta oamStagingLength
@ret:
        rts

.include "orientation/orientation_to_next_offset.asm"

unreferenced_data2:
loadSpriteIntoOamStaging:
        clc
        lda spriteIndexInOamContentLookup
        rol a
        tax
        lda oamContentLookup,x
        sta generalCounter
        inx
        lda oamContentLookup,x
        sta generalCounter2
        ldx oamStagingLength
        ldy #$00
@whileNotFF:
        lda (generalCounter),y
        cmp #$FF
        beq @ret
        clc
        adc spriteYOffset
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        clc
        adc spriteXOffset
        sta oamStaging,x
        inx
        iny
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
        jmp @whileNotFF

@ret:
        rts

oamContentLookup:
        .addr   sprite00LevelSelectCursor
        .addr   sprite01GameTypeCursor
        .addr   sprite02Blank
        .addr   sprite03PausePalette6
        .addr   sprite05PausePalette4
        .addr   sprite05PausePalette4
        .addr   sprite06TPiece
        .addr   sprite07SPiece
        .addr   sprite08ZPiece
        .addr   sprite09JPiece
        .addr   sprite0ALPiece
        .addr   sprite0BOPiece
        .addr   sprite0CIPiece
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite0FTPieceOffset
        .addr   sprite10SPieceOffset
        .addr   sprite11ZPieceOffset
        .addr   sprite12JPieceOffset
        .addr   sprite13LPieceOffset
        .addr   sprite14OPieceOffset
        .addr   sprite15IPieceOffset
        .addr   sprite16KidIcarus1
        .addr   sprite17KidIcarus2
        .addr   sprite18Link1
        .addr   sprite19Link2
        .addr   sprite1ASamus1
        .addr   sprite1BSamus2
        .addr   sprite1CDonkeyKong_armsClosed
        .addr   sprite1DDonkeyKong1
        .addr   sprite1EDonkeyKong2
        .addr   sprite1FBowser1
        .addr   sprite20Bowser2
        .addr   sprite21PrincessPeach1
        .addr   sprite22PrincessPeach2
        .addr   sprite23CathedralRocketJet1
        .addr   sprite24CathedralRocketJet2
        .addr   sprite25CloudLarge
        .addr   sprite26CloudSmall
        .addr   sprite27Mario1
        .addr   sprite28Mario2
        .addr   sprite29Luigi1
        .addr   sprite2ALuigi2
        .addr   sprite2CDragonfly1
        .addr   sprite2CDragonfly1
        .addr   sprite2DDragonfly2
        .addr   sprite2EDove1
        .addr   sprite2FDove2
        .addr   sprite30Airplane1
        .addr   sprite31Airplane2
        .addr   sprite32Ufo1
        .addr   sprite33Ufo2
        .addr   sprite34Pterosaur1
        .addr   sprite35Pterosaur2
        .addr   sprite36Blimp1
        .addr   sprite37Blimp2
        .addr   sprite38Dragon1
        .addr   sprite39Dragon2
        .addr   sprite3ABuran1
        .addr   sprite3BBuran2
        .addr   sprite3CHelicopter1
        .addr   sprite3DHelicopter2
        .addr   sprite3ESmallRocket
        .addr   sprite3FSmallRocketJet1
        .addr   sprite40SmallRocketJet2
        .addr   sprite41MediumRocket
        .addr   sprite42MediumRocketJet1
        .addr   sprite43MediumRocketJet2
        .addr   sprite44LargeRocket
        .addr   sprite45LargeRocketJet1
        .addr   sprite46LargeRocketJet2
        .addr   sprite47BuranRocket
        .addr   sprite48BuranRocketJet1
        .addr   sprite49BuranRocketJet2
        .addr   sprite4ACathedralRocket
        .addr   sprite4BOstrich1
        .addr   sprite4COstrich2
        .addr   sprite4DCathedralEasternDome
        .addr   sprite4ECathedralNorthernDome
        .addr   sprite4FCathedralCentralDome
        .addr   sprite50CathedralWesternDome
        .addr   sprite51CathedralDomeRocketJet1
        .addr   sprite52CathedralDomeRocketJet2
        .addr   sprite53MusicTypeCursor
        .addr   sprite54Penguin1
        .addr   sprite55Penguin2
        .addr   isPositionValid
        .addr   isPositionValid
        .addr   isPositionValid
        .addr   isPositionValid
; Sprites are sets of 4 bytes in the OAM format, terminated by FF. byte0=y, byte1=tile, byte2=attrs, byte3=x
sprite00LevelSelectCursor:
        .byte   $00,$FC,$20,$00
        .byte   $00,$FC,$20,$08
        .byte   $08,$FC,$20,$00
        .byte   $08,$FC,$20,$08
        .byte   $FF
sprite01GameTypeCursor:
        .byte   $00,$27,$00,$00
        .byte   $00,$27,$40,$3A
        .byte   $FF
; Used as a sort of NOOP for cursors
sprite02Blank:
        .byte   $00,$FF,$00,$00,$FF
sprite03PausePalette6:
        .byte   $00,$19,$02,$00
        .byte   $00,$0A,$02,$08
        .byte   $00,$1E,$02,$10
        .byte   $00,$1C,$02,$18
        .byte   $00,$0E,$02,$20
        .byte   $FF
sprite05PausePalette4:
        .byte   $00,$19,$00,$00
        .byte   $00,$0A,$00,$08
        .byte   $00,$1E,$00,$10
        .byte   $00,$1C,$00,$18
        .byte   $00,$0E,$00,$20
        .byte   $FF
sprite06TPiece:
sprite07SPiece:
sprite08ZPiece:
sprite09JPiece:
sprite0ALPiece:
sprite0BOPiece:
sprite0CIPiece:
sprite0EHighScoreNameCursor:
        .byte   $00,$FC,$21,$00,$FF
; Unused, but referenced from unreferenced_orientationToSpriteTable
sprite0FTPieceOffset:
sprite10SPieceOffset:
sprite11ZPieceOffset:
sprite12JPieceOffset:
sprite13LPieceOffset:
sprite14OPieceOffset:
sprite15IPieceOffset:
        .byte   $08,$7B,$02,$F8
        .byte   $08,$7B,$02,$00
        .byte   $08,$7B,$02,$08
        .byte   $08,$7B,$02,$10
        .byte   $FF
sprite16KidIcarus1:
        .byte   $F0,$95,$01,$10
        .byte   $F8,$A3,$01,$00
        .byte   $F8,$A4,$01,$08
        .byte   $F8,$A5,$01,$10
        .byte   $FF
sprite17KidIcarus2:
        .byte   $F8,$83,$01,$00
        .byte   $F8,$84,$01,$08
        .byte   $F8,$85,$01,$10
        .byte   $FF
sprite18Link1:
        .byte   $F0,$90,$00,$00
        .byte   $F8,$A0,$00,$00
        .byte   $FF
sprite19Link2:
        .byte   $F0,$C4,$00,$00
        .byte   $F8,$D4,$00,$00
        .byte   $FF
sprite1ASamus1:
        .byte   $E8,$28,$00,$08
        .byte   $E8,$2A,$00,$10
        .byte   $F0,$C8,$03,$10
        .byte   $F8,$D6,$03,$00
        .byte   $F8,$D7,$03,$08
        .byte   $F8,$D8,$03,$10
        .byte   $FF
sprite1BSamus2:
        .byte   $E8,$28,$00,$08
        .byte   $E8,$2A,$00,$10
        .byte   $F0,$B9,$03,$10
        .byte   $F8,$F6,$03,$00
        .byte   $F8,$F7,$03,$08
        .byte   $F8,$F8,$03,$10
        .byte   $FF
; Unused. Strange there isn't an unused arms open as well
sprite1CDonkeyKong_armsClosed:
        .byte   $E8,$C9,$02,$00
        .byte   $E8,$CB,$02,$10
        .byte   $F0,$D9,$02,$00
        .byte   $F0,$DB,$02,$10
        .byte   $F8,$E9,$02,$00
        .byte   $F8,$EB,$02,$10
        .byte   $FF
sprite1DDonkeyKong1:
        .byte   $E8,$46,$02,$F8
        .byte   $E8,$47,$02,$00
        .byte   $E8,$CB,$02,$10
        .byte   $F0,$56,$02,$F8
        .byte   $F0,$57,$02,$00
        .byte   $F0,$DB,$02,$10
        .byte   $F8,$87,$02,$00
        .byte   $F8,$EB,$02,$10
        .byte   $FF
sprite1EDonkeyKong2:
        .byte   $E8,$C9,$02,$00
        .byte   $E8,$66,$02,$10
        .byte   $E8,$67,$02,$18
        .byte   $F0,$D9,$02,$00
        .byte   $F0,$76,$02,$10
        .byte   $F0,$77,$02,$18
        .byte   $F8,$E9,$02,$00
        .byte   $F8,$86,$02,$10
        .byte   $FF
sprite1FBowser1:
        .byte   $F8,$E1,$00,$08
        .byte   $F8,$E2,$00,$10
        .byte   $00,$F1,$00,$08
        .byte   $00,$C5,$00,$10
        .byte   $00,$D5,$00,$18
        .byte   $FF
sprite20Bowser2:
        .byte   $F8,$E4,$00,$08
        .byte   $F8,$E5,$00,$10
        .byte   $00,$F4,$00,$08
        .byte   $00,$F5,$00,$10
        .byte   $00,$F3,$00,$18
        .byte   $FF
sprite21PrincessPeach1:
        .byte   $00,$63,$01,$00
        .byte   $00,$64,$01,$08
        .byte   $FF
sprite22PrincessPeach2:
        .byte   $00,$73,$01,$00
        .byte   $00,$74,$01,$08
        .byte   $FF
sprite23CathedralRocketJet1:
        .byte   $08,$A8,$23,$18
        .byte   $08,$A9,$23,$20
        .byte   $FF
sprite24CathedralRocketJet2:
        .byte   $08,$AA,$23,$10
        .byte   $08,$AB,$23,$18
        .byte   $08,$AC,$23,$20
        .byte   $08,$AD,$23,$28
        .byte   $10,$BA,$23,$10
        .byte   $10,$BB,$23,$18
        .byte   $10,$BC,$23,$20
        .byte   $10,$BD,$23,$28
        .byte   $FF
; Seems unused
sprite25CloudLarge:
        .byte   $00,$60,$21,$00
        .byte   $00,$61,$21,$08
        .byte   $00,$62,$21,$10
        .byte   $08,$70,$21,$00
        .byte   $08,$71,$21,$08
        .byte   $08,$72,$21,$10
        .byte   $FF
; Seems unused. Broken? Seems $81 should be $81
sprite26CloudSmall:
        .byte   $00,$80,$21,$00
        .byte   $00,$81,$21,$08
        .byte   $FF
sprite27Mario1:
        .byte   $F0,$30,$03,$00
        .byte   $F0,$31,$03,$08
        .byte   $F0,$32,$03,$10
        .byte   $F8,$40,$03,$00
        .byte   $F8,$41,$03,$08
        .byte   $F8,$42,$03,$10
        .byte   $00,$50,$03,$00
        .byte   $00,$51,$03,$08
        .byte   $00,$52,$03,$10
        .byte   $FF
sprite28Mario2:
        .byte   $F8,$23,$03,$00
        .byte   $F8,$24,$03,$08
        .byte   $F8,$25,$03,$10
        .byte   $00,$33,$03,$00
        .byte   $00,$34,$03,$08
        .byte   $00,$35,$03,$10
        .byte   $FF
sprite29Luigi1:
        .byte   $F0,$30,$00,$00
        .byte   $F0,$31,$00,$08
        .byte   $F0,$32,$00,$10
        .byte   $F8,$29,$00,$00
        .byte   $F8,$41,$00,$08
        .byte   $F8,$2B,$00,$10
        .byte   $00,$2C,$00,$00
        .byte   $00,$2D,$00,$08
        .byte   $00,$2E,$00,$10
        .byte   $FF
sprite2ALuigi2:
        .byte   $F0,$32,$40,$00
        .byte   $F0,$31,$40,$08
        .byte   $F0,$30,$40,$10
        .byte   $F8,$2B,$40,$00
        .byte   $F8,$41,$40,$08
        .byte   $F8,$29,$40,$10
        .byte   $00,$2E,$40,$00
        .byte   $00,$2D,$40,$08
        .byte   $00,$2C,$40,$10
        .byte   $FF
sprite2CDragonfly1:
        .byte   $00,$20,$23,$00
        .byte   $FF
sprite2DDragonfly2:
        .byte   $00,$21,$23,$00
        .byte   $FF
sprite2EDove1:
        .byte   $F8,$22,$21,$00
        .byte   $F8,$23,$21,$08
        .byte   $00,$32,$21,$00
        .byte   $00,$33,$21,$08
        .byte   $FF
sprite2FDove2:
        .byte   $F8,$24,$21,$00
        .byte   $F8,$25,$21,$08
        .byte   $00,$34,$21,$00
        .byte   $00,$35,$21,$08
        .byte   $FF
; Unused
sprite30Airplane1:
        .byte   $F8,$26,$21,$F0
        .byte   $F8,$27,$21,$F8
        .byte   $00,$36,$21,$F0
        .byte   $00,$37,$21,$F8
        .byte   $FF
; Unused
sprite31Airplane2:
        .byte   $F8,$28,$21,$F0
        .byte   $F8,$27,$21,$F8
        .byte   $00,$29,$21,$F0
        .byte   $00,$37,$21,$F8
        .byte   $FF
sprite32Ufo1:
        .byte   $F8,$46,$21,$F0
        .byte   $F8,$47,$21,$F8
        .byte   $00,$56,$21,$F0
        .byte   $00,$57,$21,$F8
        .byte   $FF
sprite33Ufo2:
        .byte   $F8,$46,$21,$F0
        .byte   $F8,$47,$21,$F8
        .byte   $00,$66,$21,$F0
        .byte   $00,$67,$21,$F8
        .byte   $FF
sprite34Pterosaur1:
        .byte   $F8,$43,$22,$00
        .byte   $F8,$44,$22,$08
        .byte   $F8,$45,$22,$10
        .byte   $00,$53,$22,$00
        .byte   $00,$54,$22,$08
        .byte   $00,$55,$22,$10
        .byte   $FF
sprite35Pterosaur2:
        .byte   $F8,$63,$22,$00
        .byte   $F8,$64,$22,$08
        .byte   $F8,$65,$22,$10
        .byte   $00,$73,$22,$00
        .byte   $00,$74,$22,$08
        .byte   $00,$75,$22,$10
        .byte   $FF
sprite36Blimp1:
        .byte   $F8,$40,$21,$E8
        .byte   $F8,$41,$21,$F0
        .byte   $F8,$42,$21,$F8
        .byte   $00,$50,$21,$E8
        .byte   $00,$51,$21,$F0
        .byte   $00,$52,$21,$F8
        .byte   $FF
sprite37Blimp2:
        .byte   $F8,$40,$21,$E8
        .byte   $F8,$41,$21,$F0
        .byte   $F8,$42,$21,$F8
        .byte   $00,$50,$21,$E8
        .byte   $00,$30,$21,$F0
        .byte   $00,$52,$21,$F8
        .byte   $FF
sprite38Dragon1:
        .byte   $F8,$90,$23,$08
        .byte   $F8,$A2,$23,$10
        .byte   $00,$91,$23,$F0
        .byte   $00,$92,$23,$F8
        .byte   $00,$B0,$23,$00
        .byte   $00,$A0,$23,$08
        .byte   $00,$B2,$23,$10
        .byte   $00,$B3,$23,$18
        .byte   $08,$C0,$23,$00
        .byte   $08,$C1,$23,$08
        .byte   $FF
sprite39Dragon2:
        .byte   $F8,$A1,$23,$08
        .byte   $F8,$A2,$23,$10
        .byte   $00,$91,$23,$F0
        .byte   $00,$92,$23,$F8
        .byte   $00,$B0,$23,$00
        .byte   $00,$B1,$23,$08
        .byte   $00,$B2,$23,$10
        .byte   $00,$B3,$23,$18
        .byte   $08,$C0,$23,$00
        .byte   $08,$C1,$23,$08
        .byte   $FF
sprite3ABuran1:
        .byte   $F8,$D3,$21,$F0
        .byte   $00,$E1,$21,$E0
        .byte   $00,$E2,$21,$E8
        .byte   $00,$E3,$21,$F0
        .byte   $08,$F0,$21,$D8
        .byte   $08,$F1,$21,$E0
        .byte   $08,$F2,$21,$E8
        .byte   $08,$F3,$21,$F0
        .byte   $08,$D1,$21,$F8
        .byte   $08,$D2,$21,$00
        .byte   $FF
sprite3BBuran2:
        .byte   $F8,$D3,$21,$F0
        .byte   $00,$E1,$21,$E0
        .byte   $00,$E2,$21,$E8
        .byte   $00,$E3,$21,$F0
        .byte   $08,$F0,$21,$D8
        .byte   $08,$F1,$21,$E0
        .byte   $08,$F2,$21,$E8
        .byte   $08,$F3,$21,$F0
        .byte   $08,$D0,$21,$F8
        .byte   $FF
; Unused
sprite3CHelicopter1:
        .byte   $F8,$83,$23,$E8
        .byte   $F8,$84,$23,$F0
        .byte   $F8,$85,$23,$F8
        .byte   $00,$93,$23,$E8
        .byte   $00,$94,$23,$F0
        .byte   $FF
; Unused
sprite3DHelicopter2:
        .byte   $F8,$A3,$23,$E8
        .byte   $F8,$A4,$23,$F0
        .byte   $F8,$A5,$23,$F8
        .byte   $00,$93,$23,$E8
        .byte   $00,$94,$23,$F0
        .byte   $FF
sprite3ESmallRocket:
        .byte   $00,$A6,$23,$00
        .byte   $FF
sprite3FSmallRocketJet1:
        .byte   $08,$A7,$23,$00
        .byte   $FF
sprite40SmallRocketJet2:
        .byte   $08,$F4,$23,$00
        .byte   $FF
sprite41MediumRocket:
        .byte   $F8,$B4,$21,$00
        .byte   $00,$C4,$21,$00
        .byte   $FF
sprite42MediumRocketJet1:
        .byte   $08,$D4,$23,$00
        .byte   $FF
sprite43MediumRocketJet2:
        .byte   $08,$E4,$23,$00
        .byte   $FF
sprite44LargeRocket:
        .byte   $E8,$B5,$23,$00
        .byte   $E8,$B6,$23,$08
        .byte   $F0,$C5,$23,$00
        .byte   $F0,$C6,$23,$08
        .byte   $F8,$D5,$23,$00
        .byte   $F8,$D6,$23,$08
        .byte   $00,$E5,$23,$00
        .byte   $00,$E6,$23,$08
        .byte   $FF
sprite45LargeRocketJet1:
        .byte   $08,$F5,$23,$00
        .byte   $08,$F6,$23,$08
        .byte   $FF
sprite46LargeRocketJet2:
        .byte   $08,$B7,$23,$00
        .byte   $08,$B8,$23,$08
        .byte   $FF
sprite47BuranRocket:
        .byte   $D0,$C2,$21,$08
        .byte   $D0,$C3,$21,$10
        .byte   $D8,$CB,$21,$08
        .byte   $D8,$EB,$21,$10
        .byte   $E0,$DB,$21,$08
        .byte   $E0,$FB,$21,$10
        .byte   $E8,$C7,$21,$00
        .byte   $E8,$C8,$21,$08
        .byte   $E8,$C9,$21,$10
        .byte   $E8,$CA,$21,$18
        .byte   $F0,$D7,$21,$00
        .byte   $F0,$D8,$21,$08
        .byte   $F0,$D9,$21,$10
        .byte   $F0,$DA,$21,$18
        .byte   $F8,$E7,$21,$00
        .byte   $F8,$E8,$21,$08
        .byte   $F8,$E9,$21,$10
        .byte   $F8,$EA,$21,$18
        .byte   $00,$F7,$21,$00
        .byte   $00,$F8,$21,$08
        .byte   $00,$F9,$21,$10
        .byte   $00,$FA,$21,$18
        .byte   $FF
sprite48BuranRocketJet1:
        .byte   $08,$2A,$23,$08
        .byte   $08,$2B,$23,$10
        .byte   $FF
sprite49BuranRocketJet2:
        .byte   $08,$2C,$23,$08
        .byte   $08,$2D,$23,$10
        .byte   $10,$2E,$23,$08
        .byte   $10,$2F,$23,$10
        .byte   $FF
sprite4ACathedralRocket:
        .byte   $C8,$38,$23,$20
        .byte   $D0,$39,$23,$08
        .byte   $D0,$3B,$23,$18
        .byte   $D0,$3C,$23,$20
        .byte   $D0,$3E,$23,$30
        ; .byte   $D0,$3F,$23,$38
        .byte   $D8,$48,$23,$00
        .byte   $D8,$49,$23,$08
        .byte   $D8,$4A,$23,$10
        .byte   $D8,$4B,$23,$18
        .byte   $D8,$4C,$23,$20
        .byte   $D8,$4D,$23,$28
        .byte   $D8,$4E,$20,$30
        .byte   $D8,$4F,$20,$38
        .byte   $E0,$58,$23,$00
        .byte   $E0,$59,$23,$08
        .byte   $E0,$5A,$23,$10
        .byte   $E0,$5B,$23,$18
        .byte   $E0,$5C,$23,$20
        .byte   $E0,$5D,$23,$28
        .byte   $E0,$5E,$20,$30
        .byte   $E0,$5F,$20,$38
        .byte   $E8,$68,$23,$00
        .byte   $E8,$69,$23,$08
        .byte   $E8,$6A,$23,$10
        .byte   $E8,$6B,$23,$18
        .byte   $E8,$6C,$23,$20
        .byte   $E8,$6D,$23,$28
        .byte   $E8,$6E,$23,$30
        .byte   $E8,$6F,$23,$38
        .byte   $F0,$78,$23,$00
        .byte   $F0,$79,$23,$08
        .byte   $F0,$7A,$23,$10
        .byte   $F0,$7B,$23,$18
        .byte   $F0,$7C,$23,$20
        .byte   $F0,$7D,$23,$28
        .byte   $F0,$7E,$23,$30
        .byte   $F0,$7F,$23,$38
        .byte   $F8,$88,$20,$00
        .byte   $F8,$89,$20,$08
        .byte   $F8,$8A,$20,$10
        .byte   $F8,$8B,$20,$18
        .byte   $F8,$8C,$20,$20
        .byte   $F8,$8D,$20,$28
        .byte   $F8,$8E,$20,$30
        .byte   $F8,$8F,$20,$38
        .byte   $00,$98,$20,$00
        .byte   $00,$99,$20,$08
        .byte   $00,$9A,$20,$10
        .byte   $00,$9B,$20,$18
        .byte   $00,$9C,$20,$20
        .byte   $00,$9D,$20,$28
        .byte   $00,$9E,$20,$30
        .byte   $00,$9F,$20,$38
        .byte   $FF
sprite4BOstrich1:
        .byte   $E0,$91,$21,$08
        .byte   $E0,$92,$21,$10
        .byte   $E8,$A0,$21,$00
        .byte   $E8,$A1,$21,$08
        .byte   $E8,$A2,$21,$10
        .byte   $F0,$B0,$21,$00
        .byte   $F0,$B1,$21,$08
        .byte   $F0,$B2,$21,$10
        .byte   $F8,$C0,$21,$00
        .byte   $F8,$C1,$21,$08
        .byte   $F8,$C2,$21,$10
        .byte   $00,$D0,$21,$00
        .byte   $00,$D2,$21,$10
        .byte   $FF
sprite4COstrich2:
        .byte   $E0,$C4,$21,$08
        .byte   $E0,$C5,$21,$10
        .byte   $E8,$D3,$21,$00
        .byte   $E8,$D4,$21,$08
        .byte   $E8,$D5,$21,$10
        .byte   $F0,$E3,$21,$00
        .byte   $F0,$E4,$21,$08
        .byte   $F0,$E5,$21,$10
        .byte   $F8,$F3,$21,$00
        .byte   $F8,$F4,$21,$08
        .byte   $F8,$F5,$21,$10
        .byte   $00,$B3,$21,$00
        .byte   $00,$B4,$21,$08
        .byte   $FF
; Saint Basil's is shown from the NNW. https://en.wikipedia.org/wiki/File:Sant_Vasily_cathedral_in_Moscow.JPG Use https://www.moscow-driver.com/photos/moscow_sightseeing/st_basil_cathedral/model_and_plan_of_cathedral_chapels to determine names of chapels
sprite4DCathedralEasternDome:
        .byte   $F0,$39,$22,$04
        .byte   $F8,$AA,$22,$00
        .byte   $F8,$AB,$22,$08
        .byte   $00,$BA,$22,$00
        .byte   $00,$BB,$22,$08
        .byte   $FF
sprite4ECathedralNorthernDome:
        .byte   $F0,$3A,$23,$04
        .byte   $F8,$AC,$23,$00
        .byte   $F8,$AD,$23,$08
        .byte   $00,$BC,$23,$00
        .byte   $00,$BD,$23,$08
        .byte   $FF
sprite4FCathedralCentralDome:
        .byte   $F0,$38,$23,$08
        .byte   $F8,$49,$23,$00
        .byte   $F8,$4A,$23,$08
        .byte   $00,$3B,$23,$00
        .byte   $00,$3C,$23,$08
        .byte   $FF
sprite50CathedralWesternDome:
        .byte   $F8,$4E,$20,$00
        .byte   $F8,$4F,$20,$08
        .byte   $00,$5E,$20,$00
        .byte   $00,$5F,$20,$08
        .byte   $FF
sprite51CathedralDomeRocketJet1:
        .byte   $08,$5B,$23,$04
        .byte   $FF
sprite52CathedralDomeRocketJet2:
        .byte   $08,$48,$23,$04
        .byte   $10,$58,$23,$04
        .byte   $FF
sprite53MusicTypeCursor:
        .byte   $00,$27,$00,$00
        .byte   $00,$27,$40,$4A
        .byte   $FF
sprite54Penguin1:
        .byte   $E8,$A9,$21,$00
        .byte   $E8,$AA,$21,$08
        .byte   $F0,$B8,$21,$F8
        .byte   $F0,$B9,$21,$00
        .byte   $F0,$BA,$21,$08
        .byte   $F8,$C9,$21,$00
        .byte   $F8,$CA,$21,$08
        .byte   $F8,$CB,$21,$10
        .byte   $00,$D9,$21,$00
        .byte   $00,$DA,$21,$08
        .byte   $FF
sprite55Penguin2:
        .byte   $E8,$AD,$21,$00
        .byte   $E8,$AE,$21,$08
        .byte   $F0,$BC,$21,$F8
        .byte   $F0,$BD,$21,$00
        .byte   $F0,$BE,$21,$08
        .byte   $F8,$CD,$21,$00
        .byte   $F8,$CE,$21,$08
        .byte   $F8,$CF,$21,$10
        .byte   $00,$DD,$21,$00
        .byte   $00,$DE,$21,$08
        .byte   $FF

effectiveTetriminoXTable:
        .byte   $00,$01,$02,$03,$04,$05,$06
        .byte   $00,$01,$02,$03,$04,$05,$06

tetriminoXPlayfieldTable:
        .byte   $04,$04,$04,$04,$04,$04,$04
        .byte   $05,$05,$05,$05,$05,$05,$05

isPositionValid:
        lda currentPiece
        jsr setOrientationTable
        lda #$00
        sta generalCounter5
        lda #$05
        sta generalCounter3
; Checks one square within the tetrimino
@checkSquare:
        lda generalCounter5
        tay
        lda (currentOrientationY),y   ; Y offset
        clc
        adc tetriminoY
        sta generalCounter
        clc
        adc #$02
        cmp #$18
        bcs @invalid
        lda generalCounter
        asl a
        asl a
        asl a
        sec
        sbc generalCounter
        sta generalCounter4
        lda tetriminoX
        clc
        adc (currentOrientationX),y     ; X offset
; Check if column is valid before getting normalized
        cmp #$0E
        bcs @invalid
        tay
        lda tetriminoXPlayfieldTable,y
        sta playfieldAddr+1
        lda effectiveTetriminoXTable,y
        lda generalCounter4
        clc
        adc effectiveTetriminoXTable,y
        tay
        lda (playfieldAddr),y
        ; Changed from a cmp.  $EF is always negative.  $7[BCD] is not.
        bpl @invalid
        inc generalCounter5
        dec generalCounter3
        bne @checkSquare
        lda #$00
        sta generalCounter
        rts


@invalid:
        lda #$FF
        sta generalCounter
        rts

renderTetrisFlashAndSound:
        lda #$3F
        sta PPUADDR
        lda #$0E
        sta PPUADDR
        ldx #$00
        lda completedLines
        cmp #$05
        bne @setPaletteColor
        lda frameCounter
        and #$03
        bne @setPaletteColor
        ldx #$30
        lda frameCounter
        and #$07
        bne @setPaletteColor
        lda #$09
        sta soundEffectSlot1Init
@setPaletteColor:
; .ifdef CNROM
        lda currentPpuCtrl
        sta PPUCTRL
; .endif
        stx PPUDATA
        ldy #$00
        sty ppuScrollX
        sty PPUSCROLL
        ldy #$00
        sty ppuScrollY
        sty PPUSCROLL
        rts

.include "orientation/piece_to_stats_addresses.asm"
levelDisplayTable:
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $08,$09,$10,$11,$12,$13,$14,$15
        .byte   $16,$17,$18,$19,$20,$21,$22,$23
        .byte   $24,$25,$26,$27,$28,$29
multBy7Table:
        .byte   $00,$07,$0e,$15,$1c,$23,$2a,$31
        .byte   $38,$3f,$46,$4d,$54,$5b,$62,$69
        .byte   $70,$77,$7e,$85,$8c,$93
; addresses
vramPlayfieldRows:
        .word   $20C6,$20E6,$2106,$2126
        .word   $2146,$2166,$2186,$21A6
        .word   $21C6,$21E6,$2206,$2226
        .word   $2246,$2266,$2286,$22A6
        .word   $22C6,$22E6,$2306,$2326
        .word   $2346,$2366
twoDigsToPPU:
        sta generalCounter
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        sta PPUDATA
        lda generalCounter
        and #$0F
        sta PPUDATA
        rts

copyPlayfieldRowToVRAM:
        ldx vramRow
        cpx #$16
        bpl @ret
        lda multBy7Table,x
        tay
        txa
        asl a
        tax
        ; inx
        lda vramPlayfieldRows,x
        pha
        lda vramPlayfieldRows+1,x
        pha
        ldx currentVramRender
        pla
        sta stack,x
        inx
        pla
        sta stack,x
        inx
        ; sta     PPUADDR
        ; dex
;         lda     playfieldAddr+1
;         cmp     #$05
;         beq     @rightPlayfield
;         jmp     @leftPlayfield
; @rightPlayfield:
;         lda     vramPlayfieldRows,x
;         clc
;         adc     #$07
;         sta     PPUADDR
;         jmp     @copyRow

; @leftPlayfield:
        ; lda     vramPlayfieldRows,x
        ; sta     PPUADDR
; @copyRow:
        lda #$07
        sta generalCounter
@copyByte:
        lda leftPlayfield,y
        sta stack,x
        lda rightPlayfield,y
        sta stack+7,x
        iny
        inx
        dec generalCounter
        bne @copyByte

        inc vramRow
        lda vramRow
        cmp #$16
        bmi @ret
        lda #$20
        sta vramRow
@ret:
        rts

.ifndef AEPPOZ
updateLineClearingAnimation:
.endif
        lda frameCounter
        and #$03
        bne @ret
        lda #$00
        sta generalCounter3
@whileCounter3LessThan5:
        ldx generalCounter3
        lda completedRow,x
        beq @nextRow
        asl a
        tay
        lda vramPlayfieldRows,y
        sta generalCounter
        iny
        lda vramPlayfieldRows,y
        sta generalCounter2
        sta PPUADDR
        ldx rowY
        lda leftColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda #$FF
        sta PPUDATA
        lda generalCounter2
        sta PPUADDR
        ldx rowY
        lda rightColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda #$FF
        sta PPUDATA
@nextRow:
        inc generalCounter3
        lda generalCounter3
        cmp #$05
        bne @whileCounter3LessThan5
        inc rowY
        lda rowY
        cmp #$07
        bmi @ret
.ifdef AEPPOZ
updateLineClearingAnimation:
.endif
        inc playState
@ret:
        jmp renderTetrisFlashAndSound

leftColumns:
        .byte   $06,$05,$04,$03,$02,$01,$00
rightColumns:
        .byte   $07,$08,$09,$0A,$0B,$0C,$0D
; Set Background palette 2 and Sprite palette 2
updatePaletteForLevel:
        lda levelNumber
@mod10:
        cmp #$0A
        bmi @copyPalettes
        sec
        sbc #$0A
        jmp @mod10

@copyPalettes:
        asl a
        asl a
        tax
;         lda     #$00
;         sta     generalCounter
; @copyPalette:
;         lda     #$3F
;         sta     PPUADDR
;         lda     #$08
;         clc
;         adc     generalCounter
;         sta     PPUADDR
        lda colorTable,x
        sta paletteBGData
        sta paletteSpriteData
        lda colorTable+1,x
        sta paletteBGData+1
        sta paletteSpriteData+1
        lda colorTable+1+1,x
        sta paletteBGData+2
        sta paletteSpriteData+2
        lda colorTable+1+1+1,x
        sta paletteBGData+3
        sta paletteSpriteData+3
        rts
; 4 bytes per level (bg, fg, c3, c4)
colorTable:
; borrowed from https://github.com/kirjavascript/TetrisGYM/blob/ca3000722e52777b2309dcd16273082da5a1b7f2/src/nmi/render_mode_play_and_demo.asm#L353
        .dbyt   $0F30,$2112,$0F30,$291A,$0F30,$2414,$0F30,$2A12
        .dbyt   $0F30,$2B15,$0F30,$222B,$0F30,$0016,$0F30,$0513
        .dbyt   $0F30,$1612,$0F30,$2716,$60E6,$69A5,$69C9,$1430
        .dbyt   $04A9,$2085,$69E6,$89A5,$89C9,$1430,$04A9,$2085
        .dbyt   $8960,$A549,$C920,$3056,$A5BE,$C901,$F020,$A5A4
        .dbyt   $C900,$D00E,$E6A4,$A5B7,$85A5,$20EB,$9885,$A64C
        .dbyt   $EA98,$A5A5,$C5B7,$D036,$A5A4,$C91C,$D030,$A900
        .dbyt   $85A4,$8545,$8541,$A901,$8548,$A905,$8540,$A6BF
        .dbyt   $BD56,$9985,$4220,$6999,$A5BE,$C901,$F007,$A5A6
        .dbyt   $85BF,$4CE6,$9820,$EB98,$85BF,$A900,$854E,$60A5
        .dbyt   $C0C9,$05D0,$12A6,$D3E6,$D3BD,$00DF,$4A4A,$4A4A
        .dbyt   $2907,$AABD,$4E99,$6020,$0799,$60E6,$1AA5,$1718
        .dbyt   $651A,$2907,$C907,$F008,$AABD,$4E99,$C519,$D01C
        .dbyt   $A217,$A002,$2047,$ABA5,$1729,$0718,$6519,$C907
        .dbyt   $9006,$38E9,$074C,$2A99,$AABD,$4E99,$8519,$6000
        .dbyt   $0000,$0001,$0101,$0102,$0203,$0404,$0505,$0505

; This increment and clamping is performed in copyPlayfieldRowToVRAM instead of here
noop_disabledVramRowIncr:
        rts
        inc vramRow
        lda vramRow
        cmp #$14
        bmi @player2
        lda #$20
        sta vramRow
@player2:
@ret:
        rts

playState_spawnNextTetrimino:
        lda vramRow
        cmp #$20
        bmi @ret
@spawnPiece:
        lda #$00
        sta twoPlayerPieceDelayCounter
        sta fallTimer
        ldx nextPiece
        clc
        adc spawnOffsets,x
        sta tetriminoY
        lda #$01
        sta playState
        lda #$07
        sta tetriminoX
        ldx nextPiece
        lda spawnOrientationFromOrientation,x
        sta currentPiece
        jsr incrementStatsAndSetAutorepeatX
        jsr chooseNextTetrimino
        sta nextPiece
@resetDownHold:
        lda #$00
        sta autorepeatY
@ret:
        rts

.include "orientation/weight_table_and_rng.asm"

initializeSPS:
        ; y reg contains b seed's rng pointer
        ; LLLLLLLL LLLLLLLS CCCCSSSS
        ; L = lsfr
        ; S = spawnCount
        ; C = starting shuffle count
        ldy #rng_seed
        lda validSeed
        beq @ret
        ldy #bseed
        lda sps_seed
        sta set_seed
        sta bseed
        lda sps_seed+1
        sta set_seed+1
        sta bseed+1

        lsr    ; store unused lsfr bit to combine with lower nybble of sps_seed+2
        lda #$00
        rol
        rol
        rol
        rol
        rol
        sta generalCounter
        lda sps_seed+2
        and #$0F
        ora generalCounter
        sta spawnCount

        lda sps_seed+2
        lsr
        lsr
        lsr
        lsr
        bne @no16
        lda #$10
@no16:
        clc
        adc #$02
        sta sps_shuffles ; 3 - 18
@ret:
        sty bSeedSource
        rts

shuffleSPS:
        lda rng_seed
        sta currentRngByte
        lda validSeed
        beq @ret
        lda sps_shuffles
        sta generalCounter
@loop:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        dec generalCounter
        bne @loop
        lda set_seed
        sta currentRngByte

; varying number of shuffles
        inc sps_shuffles
        lda sps_shuffles
        cmp #$13
        bne @ret
        lda #$03
        sta sps_shuffles
@ret:
        rts

rngInitYMacro

setupRngBytes:
        ; to be called from initGameState
        ldx tetriminoMode
        lda rngInitYValues,x
        sta rngInitialY
        txa
        asl
        tax
        lda weightTables,x
        sta currentWeightTable
        lda weightTables+1,x
        sta currentWeightTable+1
        rts

chooseNextTetrimino:
        lda gameMode
        cmp #$05
        bne pickRandomTetrimino
        ldx demoIndex
        inc demoIndex
        lda demoTetriminoTypeTable,x
        tax
        lda spawnTable,x
        rts

pickRandomTetrimino:
        jsr shuffleSPS
        ldy rngInitialY
        inc spawnCount
        lda currentRngByte
        clc
        adc spawnCount
@nextPiece:
        cmp (currentWeightTable),y
        bcs @foundPiece
        dey
        bmi @foundPiece
        jmp @nextPiece
@foundPiece:
        iny
        lda spawnTable,y
        sta spawnID
        rts

weightTables:
    .addr  weightTable
    .addr  weightTableTetriminos

weightTablesMacro

; ORIENTATION
tetriminoTypeFromOrientation:
.include "orientation/type_from_orientation.asm"

; ORIENTATION
spawnTable:
.include "orientation/spawn_table.asm"
        .byte   $02
; ORIENTATION
spawnOrientationFromOrientation:
.include "orientation/spawn_from_orientation.asm"
incrementPieceStat:
        tax
        lda tetriminoTypeFromOrientation,x
        asl a
        tax
        lda statsByType,x
        clc
        adc #$01
        sta generalCounter
        and #$0F
        cmp #$0A
        bmi L9996
        lda generalCounter
        clc
        adc #$06
        sta generalCounter
        cmp #$A0
        bcc L9996
        clc
        adc #$60
        sta generalCounter
        lda statsByType+1,x
        clc
        adc #$01
        sta statsByType+1,x
L9996:
        lda generalCounter
        sta statsByType,x

        lda statsPiecesTotal
        clc
        adc #$01
        sta generalCounter
        and #$0F
        cmp #$0A
        bmi L9996A
        lda generalCounter
        clc
        adc #$06
        sta generalCounter
        cmp #$A0
        bcc L9996A
        clc
        adc #$60
        sta generalCounter
        lda statsPiecesTotal+1
        clc
        adc #$01
        sta statsPiecesTotal+1
L9996A:
        lda generalCounter
        sta statsPiecesTotal

        lda outOfDateRenderFlags
        ora #$40
        sta outOfDateRenderFlags
        rts

playState_lockTetrimino:
.ifdef DEBUG
        lda heldButtons_player1
        and #BUTTON_A|BUTTON_B
        cmp #BUTTON_A|BUTTON_B
        beq @forceGameOver
.endif
        jsr isPositionValid
        beq @notGameOver
@forceGameOver:
        lda #$02
        sta soundEffectSlot0Init
        lda #$0A
        sta playState
        lda #$F0
        sta curtainRow
        jsr updateAudio2
        rts

@notGameOver:
        lda vramRow
        cmp #$20
        bmi @ret
        lda tetriminoY
        asl a
        asl a
        asl a
        sec
        sbc tetriminoY
        clc
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        jsr setOrientationTable
        lda #$00
        sta generalCounter5
        lda #$05
        sta generalCounter3
; Copies a single square of the tetrimino to the playfield
@lockSquare:
        lda generalCounter5
        tay
        lda currentTile
        sta generalCounter2
        lda tetriminoY
        clc
        adc (currentOrientationY),y         ; Y offset
        sta generalCounter
        asl a
        asl a
        asl a
        sec
        sbc generalCounter
        sta generalCounter
        lda tetriminoX
        clc
        adc (currentOrientationX),y
        tay
        lda tetriminoXPlayfieldTable,y
        sta playfieldAddr+1
        lda effectiveTetriminoXTable,y
        clc
        adc generalCounter
        tay
        lda generalCounter2
        sta (playfieldAddr),y                            ; this moves x to the next tile
        inc generalCounter5
        dec generalCounter3
        bne @lockSquare
        lda #$00
        sta lineIndex
        jsr updatePlayfield
        jsr updateMusicSpeed
        inc playState
@ret:
        rts

playState_updateGameOverCurtain:
        lda newlyPressedButtons_player1
        and #BUTTON_START
        beq @startNotPressed
        lda levelNumber
        sta endLevel        ; used to display on high score table

        lda marathon        ; no ending for marathon
        bne @exitGame

        lda tetriminoMode   ; no ending for tetriminos
        bne @exitGame

        lda validSeed       ; no ending for seeded mode
        bne @exitGame

        lda score+2
        cmp #$50            ; rocket screen for normal games over 500k
        bcc @exitGame
        jsr endingAnimation_maybe
@exitGame:
        lda pauseScreen
        beq @noToggle
        lda currentPpuCtrl
        and #$FD
        sta currentPpuCtrl

@noToggle:
        lda #$00
        sta playState
        sta pauseScreen
        sta newlyPressedButtons_player1
        rts

@startNotPressed:
        lda newlyPressedButtons_player1
        and #ALMOST_ANY
        beq @almostAnyButtonNotPressed
        jsr togglePauseScreen
        jsr updateAudioAndWaitForNmi
        lda #$1E
        sta currentPpuMask
        sta PPUMASK
@almostAnyButtonNotPressed:
@ret:
        rts



playState_updateGameOverCurtainOld:
        lda curtainRow
        cmp #$16
        beq @curtainFinished
        lda frameCounter
        and #$03
        bne @ret
        ldx curtainRow
        bmi @incrementCurtainRow
        lda multBy7Table,x
        tay
        lda #$00
        sta generalCounter3
        ldaHiddenPiece
        sta currentPiece
@drawCurtainRow:
        lda #$4F
        sta leftPlayfield,y
        sta rightPlayfield,y
        iny
        inc generalCounter3
        lda generalCounter3
        cmp #$07
        bne @drawCurtainRow
        lda curtainRow
        sta vramRow
@incrementCurtainRow:
        inc curtainRow
        lda curtainRow
        cmp #$14
        bne @ret
@ret:
        rts

@curtainFinished:
        lda score+2
        cmp #$03
        bcc @checkForStartButton
        lda #$80
        jsr sleep_for_a_vblanks
        jsr endingAnimation_maybe
        jmp @exitGame

@checkForStartButton:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne @ret2
@exitGame:
        lda #$00
        sta playState
        sta newlyPressedButtons_player1
@ret2:
        rts

playState_checkForCompletedRows:
        lda vramRow
        cmp #$20
        bpl @updatePlayfieldComplete
        jmp @ret

@updatePlayfieldComplete:
        lda tetriminoY
        sec
        sbc #$02
        bpl @yInRange
        lda #$00
@yInRange:
        clc
        adc lineIndex
        sta generalCounter2
        asl a
        asl a
        asl a
        sec
        sbc generalCounter2
        sta generalCounter
        tay
        ldx #$07
@checkIfRowComplete:
        lda leftPlayfield,y
        cmp #$EF
.ifdef AEPPOZ
        bne @AEPPOZSkip
.else
        beq @rowNotComplete
.endif
        lda rightPlayfield,y
        cmp #$EF
.ifdef AEPPOZ
        bne @AEPPOZSkip
.else
        beq @rowNotComplete
.endif
        iny
        dex
        bne @checkIfRowComplete
@AEPPOZSkip:
        lda #$0A
        sta soundEffectSlot1Init
        inc completedLines
        ldx lineIndex
        lda generalCounter2
        sta completedRow,x
        ldy generalCounter
        dey
@movePlayfieldDownOneRow:
        cpy #$F9
        bcs @skipOverflow
        lda leftPlayfield,y
        sta leftPlayfield+7,y
        lda rightPlayfield,y
        sta rightPlayfield+7,y
@skipOverflow:
        dey
        cpy #$FF
        bne @movePlayfieldDownOneRow
        lda #$EF
        ldy #$00
@clearRowTopRow:
        sta leftPlayfield,y
        sta rightPlayfield,y
        iny
        cpy #$07
        bne @clearRowTopRow
        ldaHiddenPiece
        sta currentPiece
        jmp @incrementLineIndex

@rowNotComplete:
        ldx lineIndex
        lda #$00
        sta completedRow,x
@incrementLineIndex:
        inc lineIndex
        lda lineIndex
        cmp #$01
        beq @updatePlayfieldComplete  ; do first two rows at once so check totals 4 instead of 5
        cmp #$05
        bmi @ret
        ldy completedLines
        lda garbageLines,y
        clc
        adc pendingGarbageInactivePlayer
        sta pendingGarbageInactivePlayer
        lda #$00
        sta vramRow
        sta rowY
        lda completedLines
        cmp #$05
        bne @skipTetrisSoundEffect
        lda #$04
        sta soundEffectSlot1Init
@skipTetrisSoundEffect:
        inc playState
        lda completedLines
        bne @ret
        inc playState
        lda #$07
        sta soundEffectSlot1Init
@ret:
        rts

playState_receiveGarbage:
        ldaHiddenPiece
        sta currentPiece
@ret:
        inc playState
@delay:
        rts

garbageLines:
        .byte   $00,$00,$01,$02,$04
playState_updateLinesAndStatistics:
        jsr updateMusicSpeed
        lda completedLines
        bne @linesCleared
        jmp addHoldDownPoints

@linesCleared:
        tax
        dex
        lda lineClearStatsByType,x
        clc
        adc #$01
        sta lineClearStatsByType,x
        and #$0F
        cmp #$0A
        bmi @noCarry
        lda lineClearStatsByType,x
        clc
        adc #$06
        sta lineClearStatsByType,x
@noCarry:
        lda outOfDateRenderFlags
        ora #$01
        sta outOfDateRenderFlags
        lda gameType
        beq @gameTypeA
        lda completedLines
        sta generalCounter
        lda lines
        sec
        sbc generalCounter
        sta lines
        bpl @checkForBorrow
        lda #$00
        sta lines
        jmp addHoldDownPoints

@checkForBorrow:
        and #$0F
        cmp #$0A
        bmi addHoldDownPoints
        lda lines
        sec
        sbc #$06
        sta lines
        jmp addHoldDownPoints

@gameTypeA:
        ldx completedLines
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi L9BC7
        lda lines
        clc
        adc #$06
        sta lines
        and #$F0
        cmp #$A0
        bcc L9BC7
        lda lines
        and #$0F
        sta lines
        inc lines+1
L9BC7:
        lda lines
        and #$0F
        bne @lineLoop
        lda marathon
        cmp #$01
        beq @lineLoop  ; marathon 1 never transitions
        lda sxtokl
        bne @nextLevel
        lda lines+1
        sta generalCounter2
        lda lines
        sta generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lda levelNumber
        cmp generalCounter
        bpl @lineLoop
@nextLevel:
        inc levelNumber
        lda #$06
        sta soundEffectSlot1Init
        lda outOfDateRenderFlags
        ora #$02
        sta outOfDateRenderFlags
@lineLoop:
        dex
        bne incrementLines
addHoldDownPoints:
        lda holdDownPoints
        cmp #$02
        bmi addLineClearPoints
        clc
        dec score
        adc score
        sta score
        and #$0F
        cmp #$0A
        bcc L9C18
        lda score
        clc
        adc #$06
        sta score
L9C18:
        lda score
        and #$F0
        cmp #$A0
        bcc L9C27
        clc
        adc #$60
        sta score
        inc score+1
L9C27:
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
addLineClearPoints:
        lda #$00
        sta holdDownPoints
        lda marathon  ; use startLevel no matter what when marathon (1,2,3)
        beq @notMarathon
        lda startLevel
        jmp @marathon
@notMarathon:
        lda levelNumber
@marathon:
        sta generalCounter
        inc generalCounter
L9C37:
        lda completedLines
        asl a
        tax
        lda pointsTable,x
        clc
        adc score
        sta score
        cmp #$A0
        bcc L9C4E
        clc
        adc #$60
        sta score
        inc score+1
L9C4E:
        inx
        lda pointsTable,x
        clc
        adc score+1
        sta score+1
        and #$0F
        cmp #$0A
        bcc L9C64
        lda score+1
        clc
        adc #$06
        sta score+1
L9C64:
        lda score+1
        and #$F0
        cmp #$A0
        bcc L9C75
        lda score+1
        clc
        adc #$60
        sta score+1
        inc score+2
L9C75:
        lda score+2
        and #$0F
        cmp #$0A
        bcc L9C84
        lda score+2
        clc
        adc #$06
        sta score+2
L9C84:
        lda score+2
        ; and     #$F0
        ; cmp     #$A0
        ; bcc     L9C94
        ; lda     #$99
        ; sta     score
        ; sta     score+1
        ; sta     score+2
L9C94:
        dec generalCounter
        bne L9C37
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
        lda #$00
        sta completedLines
        inc playState
        rts

pointsTable:
        .word   $0000,$0040,$0100,$0300
        .word   $1200,$2400
updatePlayfield:
        ldx tetriminoY
        dex
        dex
        txa
        bpl @rowInRange
        lda #$00
@rowInRange:
        cmp vramRow
        bpl @ret
        sta vramRow
@ret:
        rts

gameModeState_handleGameOver:
.ifdef AEPPOZ
        lda newlyPressedButtons_player1
        and #BUTTON_SELECT
        beq @continue
        lda #$0A ; playState_checkStartGameOver
        sta playState
        jmp @ret
@continue:
.endif
        lda #$05
        sta generalCounter2
        lda playState
        cmp #$00
        beq @gameOver
        jmp @ret
@gameOver:
        lda #$03
        sta renderMode
        jsr handleHighScoreIfNecessary
@resetGameState:
        lda #$01
        sta playState
        lda #$EF
        ldx #$04
        ldy #$05
        jsr memset_page
        lda #$00
        sta vramRow
        lda #$01
        sta playState
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$03
        sta gameMode
        rts

@ret:
        inc gameModeState
        ; If a 4 is left in the accumulator then the game waits for NMI, blanking out the sprites and causing the
        ; next box to flicker during a line clear
        ; the comments in this link explain a lot
        ; https://github.com/kirjavascript/TetrisGYM/blob/master/src/gamemodestate/branch.asm
        lda #$01
        rts

updateMusicSpeed:
        ldx #$05
        lda multBy7Table,x
        tay
        ldx #$07
@checkForBlockInRow:
        lda leftPlayfield,y
        cmp #$EF
        bne @foundBlockInRow
        lda rightPlayfield,y
        cmp #$EF
        bne @foundBlockInRow
        iny
        dex
        bne @checkForBlockInRow
        lda allegro
        beq @ret
        lda #$00
        sta allegro
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        jmp @ret

@foundBlockInRow:
        lda allegro
        bne @ret
        lda #$FF
        sta allegro
        lda musicType
        clc
        adc #$04
        tax
        lda musicSelectionTable,x
        jsr setMusicTrack
@ret:
        rts

pollControllerButtons:
        lda gameMode
        cmp #$05
        beq @demoGameMode
        jsr pollController
        rts

@demoGameMode:
        lda $D0
        cmp #$FF
        beq @recording
        jsr pollController
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        beq @startButtonPressed
        lda demo_repeats
        beq @finishedMove
        dec demo_repeats
        jmp @moveInProgress

@finishedMove:
        ldx #$00
        lda (demoButtonsAddr,x)
        sta generalCounter
        jsr demoButtonsTable_indexIncr
        lda demo_heldButtons
        eor generalCounter
        and generalCounter
        sta newlyPressedButtons_player1
        lda generalCounter
        sta demo_heldButtons
        ldx #$00
        lda (demoButtonsAddr,x)
        sta demo_repeats
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable
        beq @ret
        jmp @holdButtons

@moveInProgress:
        lda #$00
        sta newlyPressedButtons_player1
@holdButtons:
        lda demo_heldButtons
        sta heldButtons_player1
@ret:
        rts

@startButtonPressed:
        lda #>demoButtonsTable
        sta demoButtonsAddr+1
        lda #$00
        sta frameCounter+1
        lda #$01
        sta gameMode
        rts

@recording:
        jsr pollController
        lda gameMode
        cmp #$05
        bne @ret2
        lda $D0
        cmp #$FF
        bne @ret2
        lda heldButtons_player1
        cmp demo_heldButtons
        beq @buttonsNotChanged
        ldx #$00
        lda demo_heldButtons
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demo_repeats
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable
        beq @ret2
        lda heldButtons_player1
        sta demo_heldButtons
        lda #$00
        sta demo_repeats
        rts

@buttonsNotChanged:
        inc demo_repeats
        rts

@ret2:
        rts

demoButtonsTable_indexIncr:
        lda demoButtonsAddr
        clc
        adc #$01
        sta demoButtonsAddr
        lda #$00
        adc demoButtonsAddr+1
        sta demoButtonsAddr+1
        rts

gameMode_startDemo:
        lda #$00
        sta gameType
        sta startLevel
        sta gameModeState
        sta playState
        lda #$05
        sta gameMode
        jmp gameMode_playAndEndingHighScore_jmp

; canon is adjustMusicSpeed
setMusicTrack:
        sta musicTrack
        lda gameMode
        cmp #$05
        bne @ret
        lda #$FF
        sta musicTrack
@ret:
        rts

; A+B+Select+Start
gameModeState_checkForResetKeyCombo:
        lda heldButtons_player1
        cmp #BUTTON_A|BUTTON_B|BUTTON_SELECT|BUTTON_START
        beq @reset
        inc gameModeState
        rts

@reset:
        jsr resetPauseScreenThenUpdateAudio2
        lda #$00
        sta gameMode
        rts

; It looks like the jsr _must_ do nothing, otherwise reg a != gameModeState in mainLoop and there would not be any waiting on vsync
gameModeState_vblankThenRunState2:
        lda #$02
        sta gameModeState
        jsr noop_disabledVramRowIncr
        rts

playState_unassignOrientationId:
        ldaHiddenPiece
        sta currentPiece
        rts

        inc gameModeState
        rts

playState_incrementPlayState:
        inc playState
playState_noop:
        rts

endingAnimation_maybe:
        lda levelNumber
        sta endLevel
        lda #$02
        sta spriteIndexInOamContentLookup
        lda #$04
        sta renderMode
        lda gameType
        bne L9E49
        jmp LA926

L9E49:
        ldx levelNumber
        lda levelDisplayTable,x
        and #$0F
        sta levelNumber
        lda #$00
        sta $DE
        sta $DD
        sta $DC
        lda levelNumber
        asl a
        asl a
        asl a
        asl a
        sta generalCounter4
        lda startHeight
        asl a
        asl a
        asl a
        asl a
        sta generalCounter5
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda levelNumber
        cmp #$09
        bne L9E88
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG1
        ldx #CNROM_SPRITE1
        jsr changeCHRBank
.else
        lda #$01
        jsr changeCHRBank0
        lda #$01
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   type_b_lvl9_ending_nametable
        jmp L9EA4
L9E88:
.ifdef CNROM
        ldx #CNROM_SPRITE1
.else
        ldx #$03
.endif
        lda levelNumber
        cmp #$02
        beq L9E96
        cmp #$06
        beq L9E96
.ifdef CNROM
        ldx #CNROM_SPRITE0
.else
        ldx #$02
.endif

L9E96:
.ifdef CNROM
        lda #CNROM_BANK1
        ldy #CNROM_BG0
        jsr changeCHRBank
.else
        txa
        jsr changeCHRBank0
        lda #$02
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   type_b_ending_nametable
L9EA4:
        jsr bulkCopyToPpu
        .addr   ending_palette
        jsr ending_initTypeBVars
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$04
        sta renderMode
        lda #$0A
        jsr setMusicTrack
        lda #$80
        jsr render_endingUnskippable
        lda score
        sta $DC
        lda score+1
        sta $DD
        lda score+2
        sta $DE
        lda #$02
        sta soundEffectSlot1Init
        lda #$00
        sta score
        sta score+1
        sta score+2
        lda #$40
        jsr render_endingUnskippable
        lda generalCounter4
        beq L9F12
L9EE8:
        dec generalCounter4
        lda generalCounter4
        and #$0F
        cmp #$0F
        bne L9EFA
        lda generalCounter4
        and #$F0
        ora #$09
        sta generalCounter4
L9EFA:
        lda generalCounter4
        jsr L9F62
        lda #$01
        sta soundEffectSlot1Init
        lda #$02
        jsr render_endingUnskippable
        lda generalCounter4
        bne L9EE8
        lda #$40
        jsr render_endingUnskippable
L9F12:
        lda generalCounter5
        beq L9F45
L9F16:
        dec generalCounter5
        lda generalCounter5
        and #$0F
        cmp #$0F
        bne L9F28
        lda generalCounter5
        and #$F0
        ora #$09
        sta generalCounter5
L9F28:
        lda generalCounter5
        jsr L9F62
        lda #$01
        sta soundEffectSlot1Init
        lda #$02
        jsr render_endingUnskippable
        lda generalCounter5
        bne L9F16
        lda #$02
        sta soundEffectSlot1Init
        lda #$40
        jsr render_endingUnskippable
L9F45:
        jsr render_ending
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne L9F45
        lda $DC
        sta score
        lda $DD
        sta score+1
        lda $DE
        sta score+2
        rts

L9F62:
        lda #$01
        clc
        adc $DD
        sta $DD
        and #$0F
        cmp #$0A
        bcc L9F76
        lda $DD
        clc
        adc #$06
        sta $DD
L9F76:
        and #$F0
        cmp #$A0
        bcc L9F85
        lda $DD
        clc
        adc #$60
        sta $DD
        inc $DE
L9F85:
        lda $DE
        and #$0F
        cmp #$0A
        bcc L9F94
        lda $DE
        clc
        adc #$06
        sta $DE
L9F94:
        rts

render_mode_ending_animation:
        lda #$20
        sta PPUADDR
        lda #$8E
        sta PPUADDR
        lda score+2
        jsr twoDigsToPPU
        lda score+1
        jsr twoDigsToPPU
        lda score
        jsr twoDigsToPPU
        lda gameType
        beq L9FE9
        lda #$20
        sta PPUADDR
        lda #$B0
        sta PPUADDR
        lda generalCounter4
        jsr twoDigsToPPU
        lda #$20
        sta PPUADDR
        lda #$D0
        sta PPUADDR
        lda generalCounter5
        jsr twoDigsToPPU
        lda #$21
        sta PPUADDR
        lda #$2E
        sta PPUADDR
        lda $DE
        jsr twoDigsToPPU
        lda $DD
        jsr twoDigsToPPU
        lda $DC
        jsr twoDigsToPPU
L9FE9:
        ldy #$00
        sty PPUSCROLL
        sty PPUSCROLL
        rts

showHighScores:
;        jsr     bulkCopyToPpu      ;not using @-label due to MMC1_Control in PAL
;        .addr   high_scores_nametable
        lda #$00
        sta generalCounter2
        lda gameType
        beq @copyEntry
        lda #$04
        sta generalCounter2
@copyEntry:
        lda generalCounter2
        and #$03
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda generalCounter2
        and #$03
        asl a
        tax
        inx
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda generalCounter2
        asl a
        sta generalCounter
        asl a
        clc
        adc generalCounter
        tay
        ldx #$06
@copyChar:
        lda highScoreNames,y
        sty generalCounter
        tay
        lda highScoreCharToTile,y
        ldy generalCounter
        sta PPUDATA
        iny
        dex
        bne @copyChar
        lda #$FF
        sta PPUDATA
        lda generalCounter2
        sta generalCounter
        asl a
        clc
        adc generalCounter
        tay
        lda highScoreScoresA,y
        jsr twoDigsToPPU
        iny
        lda highScoreScoresA,y
        jsr twoDigsToPPU
        iny
        lda highScoreScoresA,y
        jsr twoDigsToPPU
        lda #$FF
        sta PPUDATA
        ldy generalCounter2
        lda highScoreLevels,y
        tax
        lda byteToBcdTable,x
        jsr twoDigsToPPU
        inc generalCounter2
        lda generalCounter2
        cmp #$03
        beq showHighScores_ret
        cmp #$07
        beq showHighScores_ret
        jmp @copyEntry

showHighScores_ret:
        rts

highScorePpuAddrTable:
        .dbyt   $2289,$22C9,$2309
highScoreCharToTile:
        .byte   $24,$0A,$0B,$0C,$0D,$0E,$0F,$10
        .byte   $11,$12,$13,$14,$15,$16,$17,$18
        .byte   $19,$1A,$1B,$1C,$1D,$1E,$1F,$20
        .byte   $21,$22,$23,$00,$01,$02,$03,$04
        .byte   $05,$06,$07,$08,$09,$25,$4F,$5E
        .byte   $5F,$6E,$6F,$FF
unreferenced_data7:
        .byte   $00,$00,$00,$00
; maxes out at 49
byteToBcdTable:
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $08,$09,$10,$11,$12,$13,$14,$15
        .byte   $16,$17,$18,$19,$20,$21,$22,$23
        .byte   $24,$25,$26,$27,$28,$29,$30,$31
        .byte   $32,$33,$34,$35,$36,$37,$38,$39
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $48,$49
; Adjusts high score table and handles data entry, if necessary
handleHighScoreIfNecessary:
        lda #$00
        sta highScoreEntryRawPos
        lda gameType
        beq @compareWithPos
        lda #$04
        sta highScoreEntryRawPos
@compareWithPos:
        lda highScoreEntryRawPos
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tay
        lda highScoreScoresA,y
        cmp score+2
        beq @checkHundredsByte
        bcs @tooSmall
        bcc adjustHighScores
@checkHundredsByte:
        iny
        lda highScoreScoresA,y
        cmp score+1
        beq @checkOnesByte
        bcs @tooSmall
        bcc adjustHighScores
; This breaks ties by prefering the new score
@checkOnesByte:
        iny
        lda highScoreScoresA,y
        cmp score
        beq adjustHighScores
        bcc adjustHighScores
@tooSmall:
        inc highScoreEntryRawPos
        lda highScoreEntryRawPos
        cmp #$03
        beq @ret
        cmp #$07
        beq @ret
        jmp @compareWithPos

@ret:
        rts

adjustHighScores:
        lda highScoreEntryRawPos
        and #$03
        cmp #$02
        bpl @doneMovingOldScores
        lda #$06
        jsr copyHighScoreNameToNextIndex
        lda #$03
        jsr copyHighScoreScoreToNextIndex
        lda #$01
        jsr copyHighScoreLevelToNextIndex
        lda highScoreEntryRawPos
        and #$03
        bne @doneMovingOldScores
        lda #$00
        jsr copyHighScoreNameToNextIndex
        lda #$00
        jsr copyHighScoreScoreToNextIndex
        lda #$00
        jsr copyHighScoreLevelToNextIndex
@doneMovingOldScores:
        ldx highScoreEntryRawPos
        lda highScoreIndexToHighScoreNamesOffset,x
        tax
        ldy #$06
        lda #$00
@clearNameLetter:
        sta highScoreNames,x
        inx
        dey
        bne @clearNameLetter
        ldx highScoreEntryRawPos
        lda highScoreIndexToHighScoreScoresOffset,x
        tax
        lda score+2
        sta highScoreScoresA,x
        inx
        lda score+1
        sta highScoreScoresA,x
        inx
        lda score
        sta highScoreScoresA,x

; store starting level in marathon mode
        lda startLevel
        ldx marathon
        bne @storeStartLevel
        lda endLevel
@storeStartLevel:
        ldx highScoreEntryRawPos
        sta highScoreLevels,x
        jmp highScoreEntryScreen

; reg a: start byte to copy
copyHighScoreNameToNextIndex:
        sta generalCounter
        lda gameType
        beq @offsetAdjustedForGameType
        lda #$18
        clc
        adc generalCounter
        sta generalCounter
@offsetAdjustedForGameType:
        lda #$05
        sta generalCounter2
@copyLetter:
        lda generalCounter
        clc
        adc generalCounter2
        tax
        lda highScoreNames,x
        sta generalCounter3
        txa
        clc
        adc #$06
        tax
        lda generalCounter3
        sta highScoreNames,x
        dec generalCounter2
        lda generalCounter2
        cmp #$FF
        bne @copyLetter
        rts

; reg a: start byte to copy
copyHighScoreScoreToNextIndex:
        tax
        lda gameType
        beq @xAdjustedForGameType
        txa
        clc
        adc #$0C
        tax
@xAdjustedForGameType:
        lda highScoreScoresA,x
        sta highScoreScoresA+3,x
        inx
        lda highScoreScoresA,x
        sta highScoreScoresA+3,x
        inx
        lda highScoreScoresA,x
        sta highScoreScoresA+3,x
        rts

; reg a: start byte to copy
copyHighScoreLevelToNextIndex:
        tax
        lda gameType
        beq @xAdjustedForGameType
        txa
        clc
        adc #$04
        tax
@xAdjustedForGameType:
        lda highScoreLevels,x
        sta highScoreLevels+1,x
        rts

highScoreIndexToHighScoreNamesOffset:
        .byte   $00,$06,$0C,$12,$18,$1E,$24,$2A
highScoreIndexToHighScoreScoresOffset:
        .byte   $00,$03,$06,$09,$0C,$0F,$12,$15
highScoreEntryScreen:
.ifndef CNROM
        inc initRam
        lda #$13
        jsr setMMC1Control
.endif
        lda #$09
        jsr setMusicTrack
        lda #$02
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr bulkCopyToPpu
        .addr   enter_high_score_nametable
        lda #$20
        sta PPUADDR
        lda #$6D
        sta PPUADDR
        lda #$0A
        clc
        adc gameType
        sta PPUDATA
        jsr showHighScores
        lda #$02
        sta renderMode
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda highScoreEntryRawPos
        asl a
        sta generalCounter
        asl a
        clc
        adc generalCounter
        sta highScoreEntryNameOffsetForRow
        lda #$00
        sta highScoreEntryNameOffsetForLetter
        sta oamStaging
        lda highScoreEntryRawPos
        and #$03
        tax
        lda highScorePosToY,x
        sta spriteYOffset
@renderFrame:
        lda #$00
        sta oamStaging
        ldx highScoreEntryNameOffsetForLetter
        lda highScoreNamePosToX,x
        sta spriteXOffset
        lda #$0E
        sta spriteIndexInOamContentLookup
        lda frameCounter
        and #$03
        bne @flickerStateSelected_checkForStartPressed
        lda #$02
        sta spriteIndexInOamContentLookup
@flickerStateSelected_checkForStartPressed:
        jsr loadSpriteIntoOamStaging
        lda newlyPressedButtons_player1
        and #BUTTON_START
        beq @checkForAOrRightPressed
        lda #$02
        sta soundEffectSlot1Init
        jmp @ret

@checkForAOrRightPressed:
        lda newlyPressedButtons_player1
        and #BUTTON_RIGHT|BUTTON_A
        beq @checkForBOrLeftPressed
        lda #$01
        sta soundEffectSlot1Init
        inc highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        cmp #$06
        bmi @checkForBOrLeftPressed
        lda #$00
        sta highScoreEntryNameOffsetForLetter
@checkForBOrLeftPressed:
        lda newlyPressedButtons_player1
        and #BUTTON_LEFT|BUTTON_B
        beq @checkForDownPressed
        lda #$01
        sta soundEffectSlot1Init
        dec highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        bpl @checkForDownPressed
        lda #$05
        sta highScoreEntryNameOffsetForLetter
@checkForDownPressed:
        lda heldButtons_player1
        and #BUTTON_DOWN
        beq @checkForUpPressed
        lda frameCounter
        and #$07
        bne @checkForUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highScoreNames,x
        sta generalCounter
        dec generalCounter
        lda generalCounter
        bpl @letterDoesNotUnderflow
        clc
        adc #$2C
        sta generalCounter
@letterDoesNotUnderflow:
        lda generalCounter
        sta highScoreNames,x
@checkForUpPressed:
        lda heldButtons_player1
        and #BUTTON_UP
        beq @waitForVBlank
        lda frameCounter
        and #$07
        bne @waitForVBlank
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highScoreNames,x
        sta generalCounter
        inc generalCounter
        lda generalCounter
        cmp #$2C
        bmi @letterDoesNotOverflow
        sec
        sbc #$2C
        sta generalCounter
@letterDoesNotOverflow:
        lda generalCounter
        sta highScoreNames,x
@waitForVBlank:
        lda highScoreEntryNameOffsetForRow
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highScoreNames,x
        sta highScoreEntryCurrentLetter
        lda #$80
        sta outOfDateRenderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @renderFrame

@ret:
        jsr updateAudioWaitForNmiAndResetOamStaging
        rts

highScorePosToY:
        .byte   $9F,$AF,$BF
highScoreNamePosToX:
        .byte   $48,$50,$58,$60,$68,$70
render_mode_congratulations_screen:
        lda outOfDateRenderFlags
        and #$80
        beq @ret
        lda highScoreEntryRawPos
        and #$03
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        lda highScoreEntryRawPos
        and #$03
        asl a
        tax
        inx
        lda highScorePpuAddrTable,x
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        sta PPUADDR
        ldx highScoreEntryCurrentLetter
        lda highScoreCharToTile,x
        sta PPUDATA
        lda #$00
        sta ppuScrollX
        sta PPUSCROLL
        sta ppuScrollY
        sta PPUSCROLL
        sta outOfDateRenderFlags
@ret:
        rts

; Handles pausing and exiting demo
gameModeState_startButtonHandling:
        lda gameMode
        cmp #$05
        bne @checkIfInGame
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne @checkIfInGame
        lda #$01
        sta gameMode
        jmp @ret

@checkIfInGame:
        lda renderMode
        cmp #$03
        beq @dontReturn
        inc gameModeState
        rts

@dontReturn:
        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne @startPressed
        jmp @ret

; Do nothing if curtain is being lowered
@startPressed:
        lda playState
        cmp #$0A
        bne @pause
        jmp @ret

@pause:
        lda #$05
        sta musicStagingNoiseHi
        lda #$05
        sta renderMode
        jsr updateAudioAndWaitForNmi
        ; lda     #$16
        ; sta     PPUMASK
        ; lda     #$FF
        ldx #$02
        ldy #$02
        jsr memset_page
@pauseLoop:
        lda pauseScreen
        bne @skipSprites
        lda #$58
        sta spriteXOffset
        lda #$4b
        sta spriteYOffset
        lda #$05
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        jsr stageSpriteForCurrentPiece
        jsr stageSpriteForNextPiece
@skipSprites:
        lda newlyPressedButtons_player1
        and #ALMOST_ANY
        beq @almostAnyNotPressed
        jsr togglePauseScreen
        jmp @pauseLoop

@almostAnyNotPressed:
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        beq @resume
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$1E
        sta PPUMASK
        jmp @pauseLoop

@resume:
        lda pauseScreen
        beq @noToggle
        jsr togglePauseScreen
@noToggle:
.ifndef CNROM
        lda #$03
        jsr changeCHRBank0
.else
        lda #CNROM_BANK1
        ldy #CNROM_BG1
        ldx #CNROM_SPRITE1
        jsr changeCHRBank
.endif
        lda #$1E
        sta PPUMASK
        lda #$00
        sta pauseScreen
        sta musicStagingNoiseHi
        sta vramRow
        lda #$03
        sta renderMode
@ret:
        inc gameModeState
        rts

togglePauseScreen:
        lda pauseScreen
        eor #$02
        sta pauseScreen
        lda #$16
        sta currentPpuMask
        sta PPUMASK
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda currentPpuCtrl
        and #$FD
        ora pauseScreen
        sta currentPpuCtrl
        sta PPUCTRL
        lda pauseScreen
.ifndef CNROM
        lsr
        clc
        adc #$03
        sta generalCounter
        jsr changeCHRBank0
        lda generalCounter
        jmp changeCHRBank1
.else
        beq @gameMode
@statsMode:
        lda #CNROM_BANK2
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jmp changeCHRBank
@gameMode:
        lda #CNROM_BANK1
        ldy #CNROM_BG1
        ldx #CNROM_SPRITE1
        jmp changeCHRBank
.endif



playState_bTypeGoalCheck:
        lda gameType
        beq @ret
.ifndef EASYB
        lda lines
        bne @ret
.endif
        jmp @success
@ret:
        inc playState
        rts

@success:
        lda #$02
        jsr setMusicTrack
        ldy #$3A
        ldx #$00
@copySuccessGraphicLeftRow1:
        lda typebSuccessGraphicLeftRow1,x
        cmp #$80
        beq @startRow2
        sta leftPlayfield,y
        inx
        iny
        jmp @copySuccessGraphicLeftRow1
@startRow2:
        ldy #$41
        ldx #$00
@copySuccessGraphicLeftRow2:
        lda typebSuccessGraphicLeftRow2,x
        cmp #$80
        beq @startLeftRow3
        sta leftPlayfield,y
        inx
        iny
        jmp @copySuccessGraphicLeftRow2
@startLeftRow3:
        ldy #$48
        ldx #$00

@copySuccessGraphicLeftRow3:
        lda typebSuccessGraphicLeftRow3,x
        cmp #$80
        beq @startright
        sta leftPlayfield,y
        inx
        iny
        jmp @copySuccessGraphicLeftRow3

@startright:
        ldy #$38
        ldx #$00
@copySuccessGraphicRightRow1:
        lda typebSuccessGraphicRightRow1,x
        cmp #$80
        beq @startLeftRow2
        sta rightPlayfield,y
        inx
        iny
        jmp @copySuccessGraphicRightRow1
@startLeftRow2:
        ldy #$3F
        ldx #$00
@copySuccessGraphicRightRow2:
        lda typebSuccessGraphicRightRow2,x
        cmp #$80
        beq @startRightRow3
        sta rightPlayfield,y
        inx
        iny
        jmp @copySuccessGraphicRightRow2
@startRightRow3:
        ldy #$46
        ldx #$00
@copySuccessGraphicRightRow3:
        lda typebSuccessGraphicRightRow3,x
        cmp #$80
        beq @graphicCopied
        sta rightPlayfield,y
        inx
        iny
        jmp @copySuccessGraphicRightRow3



@graphicCopied:
        lda #$00
        sta vramRow
        jsr sleep_for_14_vblanks
        lda #$00
        sta renderMode
        lda #$80
        jsr sleep_for_a_vblanks
        jsr endingAnimation_maybe
        lda #$00
        sta playState
        inc gameModeState
        rts

typebSuccessGraphicLeftRow1:
        .byte   $38,$39,$39,$39,$39
        .byte   $80
typebSuccessGraphicLeftRow2:
        .byte   $3B,$1C,$1E,$0C,$0C
        .byte   $80
typebSuccessGraphicLeftRow3:
        .byte   $3D,$3E,$3E,$3E,$3E
        .byte   $80
typebSuccessGraphicRightRow1:
        .byte   $39,$39,$39,$39,$3A
        .byte   $80
typebSuccessGraphicRightRow2:
        .byte   $0E,$1C,$1C,$28,$3C
        .byte   $80
typebSuccessGraphicRightRow3:
        .byte   $3E,$3E,$3E,$3E,$3F
        .byte   $80


sleep_for_14_vblanks:
        lda #$14
        sta sleepCounter
@loop:
        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne @break
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda sleepCounter
        bne @loop
@break:
        rts

sleep_for_a_vblanks:
        sta sleepCounter
@loop:
        lda newlyPressedButtons_player1
        and #BUTTON_START
        bne @break
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda sleepCounter
        bne @loop
@break:
        rts

ending_initTypeBVars:
        lda #$00
        sta ending
        sta ending_customVars
        sta ending_typeBCathedralFrameDelayCounter
        lda #$02
        sta spriteIndexInOamContentLookup
        lda levelNumber
        cmp #$09
        bne @notLevel9
        lda startHeight
        clc
        adc #$01
        sta ending
        jsr ending_typeBConcertPatchToPpuForHeight
        lda #$00
        sta ending
        sta ending_customVars+2
        lda LA73D
        sta ending_customVars+3
        lda LA73E
        sta ending_customVars+4
        lda LA73F
        sta ending_customVars+5
        lda LA740
        sta ending_customVars+6
        rts

@notLevel9:
        ldx levelNumber
        lda LA767,x
        sta ending_customVars+2
        sta ending_customVars+3
        sta ending_customVars+4
        sta ending_customVars+5
        sta ending_customVars+6
        ldx levelNumber
        lda LA75D,x
        sta ending_customVars+1
        rts

ending_typeBConcertPatchToPpuForHeight:
        lda ending
        jsr switch_s_plus_2a
        .addr   @heightUnused
        .addr   @height0
        .addr   @height1
        .addr   @height2
        .addr   @height3
        .addr   @height4
        .addr   @height5
@heightUnused:
        lda #$A8
        sta patchToPpuAddr+1
        lda #$22
        sta patchToPpuAddr
        jsr patchToPpu
@height0:
        lda #>ending_patchToPpu_typeBConcertHeight0
        sta patchToPpuAddr+1
        lda #<ending_patchToPpu_typeBConcertHeight0
        sta patchToPpuAddr
        jsr patchToPpu
@height1:
        lda #>ending_patchToPpu_typeBConcertHeight1
        sta patchToPpuAddr+1
        lda #<ending_patchToPpu_typeBConcertHeight1
        sta patchToPpuAddr
        jsr patchToPpu
@height2:
        lda #>ending_patchToPpu_typeBConcertHeight2
        sta patchToPpuAddr+1
        lda #<ending_patchToPpu_typeBConcertHeight2
        sta patchToPpuAddr
        jsr patchToPpu
@height3:
        lda #>ending_patchToPpu_typeBConcertHeight3
        sta patchToPpuAddr+1
        lda #<ending_patchToPpu_typeBConcertHeight3
        sta patchToPpuAddr
        jsr patchToPpu
@height4:
        lda #>ending_patchToPpu_typeBConcertHeight4
        sta patchToPpuAddr+1
        lda #<ending_patchToPpu_typeBConcertHeight4
        sta patchToPpuAddr
        jsr patchToPpu
@height5:
        rts

patchToPpu:
        ldy #$00
@patchAddr:
        lda (patchToPpuAddr),y
        sta PPUADDR
        iny
        lda (patchToPpuAddr),y
        sta PPUADDR
        iny
@patchValue:
        lda (patchToPpuAddr),y
        iny
        cmp #$FE
        beq @patchAddr
        cmp #$FD
        beq @ret
        sta PPUDATA
        jmp @patchValue

@ret:
        rts

render_ending:
        lda gameType
        bne ending_typeB
        jmp ending_typeA

ending_typeB:
        lda levelNumber
        cmp #$09
        beq @typeBConcert
        jmp ending_typeBCathedral

@typeBConcert:
        jsr ending_typeBConcert
        rts

ending_typeBConcert:
        lda startHeight
        jsr switch_s_plus_2a
        .addr   @kidIcarus
        .addr   @link
        .addr   @samus
        .addr   @donkeyKong
        .addr   @bowser
        .addr   @marioLuigiPeach
@marioLuigiPeach:
        lda #$C8
        sta spriteXOffset
        lda #$47
        sta spriteYOffset
        lda frameCounter
        and #$08
        lsr a
        lsr a
        lsr a
        clc
        adc #$21
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        lda #$A0
        sta spriteXOffset
        lda #$27
        sta spriteIndexInOamContentLookup
        lda frameCounter
        and #$18
        lsr a
        lsr a
        lsr a
        tax
        lda marioFrameToYOffsetTable,x
        sta spriteYOffset
        cmp #$97
        beq @marioFrame1
        lda #$28
        sta spriteIndexInOamContentLookup
@marioFrame1:
        jsr loadSpriteIntoOamStaging
@luigiCalculateFrame:
        lda #$C0
        sta spriteXOffset
        lda ending
        lsr a
        lsr a
        lsr a
        cmp #$0A
        bne @luigiFrameCalculated
        lda #$00
        sta ending
        inc ending_customVars
        jmp @luigiCalculateFrame

@luigiFrameCalculated:
        tax
        lda luigiFrameToYOffsetTable,x
        sta spriteYOffset
        lda luigiFrameToSpriteTable,x
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        inc ending
@bowser:
        lda #$30
        sta spriteXOffset
        lda #$A7
        sta spriteYOffset
        lda frameCounter
        and #$10
        lsr a
        lsr a
        lsr a
        lsr a
        clc
        adc #$1F
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@donkeyKong:
        lda #$40
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        lda frameCounter
        and #$10
        lsr a
        lsr a
        lsr a
        lsr a
        clc
        adc #$1D
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@samus:
        lda #$A8
        sta spriteXOffset
        lda #$D7
        sta spriteYOffset
        lda frameCounter
        and #$10
        lsr a
        lsr a
        lsr a
        lsr a
        clc
        adc #$1A
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@link:
        lda #$C8
        sta spriteXOffset
        lda #$D7
        sta spriteYOffset
        lda frameCounter
        and #$10
        lsr a
        lsr a
        lsr a
        lsr a
        clc
        adc #$18
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@kidIcarus:
        lda #$28
        sta spriteXOffset
        lda #$77
        sta spriteYOffset
        lda frameCounter
        and #$10
        lsr a
        lsr a
        lsr a
        lsr a
        clc
        adc #$16
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        jsr LA6BC
        rts

ending_typeBCathedral:
        jsr ending_typeBCathedralSetSprite
        inc ending_typeBCathedralFrameDelayCounter
        lda #$00
        sta ending_currentSprite
@spriteLoop:
        ldx levelNumber
        lda LA767,x
        sta generalCounter
        ldx ending_currentSprite
        lda ending_customVars+1,x
        cmp generalCounter
        beq @continue
        sta spriteXOffset
        jsr ending_computeTypeBCathedralYTableIndex
        lda ending_typeBCathedralYTable,x
        sta spriteYOffset
        jsr loadSpriteIntoOamStaging
        ldx levelNumber
        lda ending_typeBCathedralFrameDelayTable,x
        cmp ending_typeBCathedralFrameDelayCounter
        bne @continue
        ldx levelNumber
        lda ending_typeBCathedralVectorTable,x
        clc
        adc spriteXOffset
        sta spriteXOffset
        ldx ending_currentSprite
        sta ending_customVars+1,x
        jsr ending_computeTypeBCathedralYTableIndex
        lda ending_typeBCathedralXTable,x
        cmp spriteXOffset
        bne @continue
        ldx levelNumber
        lda LA75D,x
        ldx ending_currentSprite
        inx
        sta ending_customVars+1,x
@continue:
        lda ending_currentSprite
        sta generalCounter
        cmp startHeight
        beq @done
        inc ending_currentSprite
        jmp @spriteLoop

@done:
        ldx levelNumber
        lda ending_typeBCathedralFrameDelayTable,x
        cmp ending_typeBCathedralFrameDelayCounter
        bne @ret
        lda #$00
        sta ending_typeBCathedralFrameDelayCounter
@ret:
        rts

ending_typeBCathedralSetSprite:
        inc ending
        ldx levelNumber
        lda ending_typeBCathedralAnimSpeed,x
        cmp ending
        bne @skipAnimSpriteChange
        lda ending_customVars
        eor #$01
        sta ending_customVars
        lda #$00
        sta ending
@skipAnimSpriteChange:
        lda ending_typeBCathedralSpriteTable,x
        clc
        adc ending_customVars
        sta spriteIndexInOamContentLookup
        rts

; levelNumber * 6 + currentEndingBSprite
ending_computeTypeBCathedralYTableIndex:
        lda levelNumber
        asl a
        sta generalCounter
        asl a
        clc
        adc generalCounter
        clc
        adc ending_currentSprite
        tax
        rts

LA6BC:
        ldx #$00
LA6BE:
        lda LA735,x
        cmp ending_customVars
        bne LA6D0
        lda ending_customVars+3,x
        beq LA6D0
        sec
        sbc #$01
        sta ending_customVars+3,x
        inc ending_customVars
LA6D0:
        inx
        cpx #$04
        bne LA6BE
        lda #$00
        sta ending_currentSprite
LA6D9:
        ldx ending_currentSprite
        lda ending_customVars+3,x
        beq LA72C
        sta generalCounter
        lda LA73D,x
        cmp generalCounter
        beq LA6F7
        lda #$03
        sta soundEffectSlot0Init
        dec generalCounter
        lda generalCounter
        cmp #$A0
        bcs LA6F7
        dec generalCounter
LA6F7:
        lda generalCounter
        sta ending_customVars+3,x
        sta spriteYOffset
        lda domeNumberToXOffsetTable,x
        sta spriteXOffset
        lda domeNumberToSpriteTable,x
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        ldx ending_currentSprite
        lda ending_customVars+3,x
        sta generalCounter
        lda LA73D,x
        cmp generalCounter
        beq LA72C
        lda LA745,x
        clc
        adc spriteXOffset
        sta spriteXOffset
        lda frameCounter
        and #$02
        lsr a
        clc
        adc #$51
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
LA72C:
        inc ending_currentSprite
        lda ending_currentSprite
        cmp #$04
        bne LA6D9
        rts

LA735:
        .byte   $05,$07,$09,$0B
domeNumberToXOffsetTable:
        .byte   $60,$90,$70,$7E
LA73D:
        .byte   $BC
LA73E:
        .byte   $B8
LA73F:
        .byte   $BC
LA740:
        .byte   $B3
domeNumberToSpriteTable:
        .byte   $4D,$50,$4E,$4F
LA745:
        .byte   $00,$00,$00,$02
; Frames before changing to next frame's sprite
ending_typeBCathedralAnimSpeed:
        .byte   $02,$04,$06,$03,$10,$03,$05,$06
        .byte   $02,$05
; Number of frames to keep sprites in same position (inverse of vector table)
ending_typeBCathedralFrameDelayTable:
        .byte   $03,$01,$01,$01,$02,$05,$01,$02
        .byte   $01,$01
LA75D:
        .byte   $02,$02,$FE,$FE,$02,$FE,$02,$02
        .byte   $FE,$02
LA767:
        .byte   $00,$00,$00,$02,$F0,$10,$F0,$F0
        .byte   $20,$F0
ending_typeBCathedralVectorTable:
        .byte   $01,$01,$FF,$FC,$01,$FF,$02,$02
        .byte   $FE,$02
ending_typeBCathedralXTable:
        .byte   $3A,$24,$0A,$4A,$3A,$FF,$22,$44
        .byte   $12,$32,$4A,$FF,$AE,$6E,$8E,$6E
        .byte   $1E,$02,$42,$42,$42,$42,$42,$02
        .byte   $22,$0A,$1A,$04,$0A,$FF,$EE,$DE
        .byte   $FC,$FC,$F6,$02,$80,$80,$80,$80
        .byte   $80,$FF,$E8,$E8,$E8,$E8,$48,$FF
        .byte   $80,$AE,$9E,$90,$80,$02,$80,$80
        .byte   $80,$80,$80,$FF
ending_typeBCathedralYTable:
        .byte   $98,$A8,$C0,$A8,$90,$B0,$B0,$B8
        .byte   $A0,$B8,$A8,$A0,$C8,$C8,$C8,$C8
        .byte   $C8,$C8,$30,$20,$40,$28,$A0,$80
        .byte   $A8,$88,$68,$A8,$48,$78,$58,$68
        .byte   $18,$48,$78,$38,$C8,$C8,$C8,$C8
        .byte   $C8,$C8,$90,$58,$70,$A8,$40,$38
        .byte   $68,$88,$78,$18,$48,$A8,$C8,$C8
        .byte   $C8,$C8,$C8,$C8
ending_typeBCathedralSpriteTable:
        .byte   $2C,$2E,$54,$32,$34,$36,$4B,$38
        .byte   $3A,$4B
render_endingUnskippable:
        sta sleepCounter
@loopUntilEnoughFrames:
        jsr render_ending
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda sleepCounter
        bne @loopUntilEnoughFrames
        rts

marioFrameToYOffsetTable:
        .byte   $97,$8F,$87,$8F
luigiFrameToYOffsetTable:
        .byte   $97,$8F,$87,$87,$8F,$97,$8F,$87
        .byte   $87,$8F
luigiFrameToSpriteTable:
        .byte   $29,$29,$29,$2A,$2A,$2A,$2A,$2A
        .byte   $29,$29
; Used by patchToPpu. Address followed by bytes to write. $FE to start next address. $FD to end
ending_patchToPpu_typeBConcertHeightUnused:
        .byte   $21,$A5,$FF,$FF,$FF,$FE,$21,$C5
        .byte   $FF,$FF,$FF,$FE,$21,$E5,$FF,$FF
        .byte   $FF,$FD
ending_patchToPpu_typeBConcertHeight0:
        .byte   $23,$1A,$FF,$FE,$23,$39,$FF,$FF
        .byte   $FF,$FE,$23,$59,$FF,$FF,$FF,$FE
        .byte   $23,$79,$FF,$FF,$FF,$FD
ending_patchToPpu_typeBConcertHeight1:
        .byte   $23,$15,$FF,$FF,$FF,$FE,$23,$35
        .byte   $FF,$FF,$FF,$FE,$23,$55,$FF,$FF
        .byte   $FF,$FE,$23,$75,$FF,$FF,$FF,$FD
ending_patchToPpu_typeBConcertHeight2:
        .byte   $21,$88,$FF,$FF,$FF,$FE,$21,$A8
        .byte   $FF,$FF,$FF,$FE,$21,$C8,$FF,$FF
        .byte   $FF,$FE,$21,$E8,$FF,$FF,$FF,$FD
ending_patchToPpu_typeBConcertHeight3:
        .byte   $22,$46,$FF,$FF,$FF,$FF,$FE,$22
        .byte   $66,$FF,$FF,$FF,$FF,$FE,$22,$86
        .byte   $FF,$FF,$FF,$FF,$FE,$22,$A6,$FF
        .byte   $FF,$FF,$FF,$FD
ending_patchToPpu_typeBConcertHeight4:
        .byte   $20,$F9,$FF,$FF,$FF,$FE,$21,$19
        .byte   $FF,$FF,$FF,$FE,$21,$39,$FF,$FF
        .byte   $FF,$FD
unreferenced_patchToPpu0:
        .byte   $23,$35,$FF,$FF,$FF,$FE,$23,$55
        .byte   $FF,$FF,$FF,$FE,$23,$75,$FF,$FF
        .byte   $FF,$FD
unreferenced_patchToPpu1:
        .byte   $23,$39,$FF,$FF,$FF,$FE,$23,$59
        .byte   $FF,$FF,$FF,$FE,$23,$79,$FF,$FF
        .byte   $FF,$FD
ending_patchToPpu_typeAOver120k:
        .byte   $22,$58,$FF,$FE,$22,$75,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FE,$22,$94,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
        .byte   $22,$B4,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FE,$22,$D4,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FE,$22,$F4
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FE,$23,$14,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FE,$23,$34,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FE,$22
        .byte   $CA,$46,$47,$FE,$22,$EA,$56,$57
        .byte   $FD
unreferenced_data6:
        .byte   $FC
LA926:
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.ifdef CNROM
        lda #CNROM_BANK1
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        lda #$02
        jsr changeCHRBank0
        lda #$02
        jsr changeCHRBank1
.endif
        jsr bulkCopyToPpu
        .addr   type_a_ending_nametable
        jsr bulkCopyToPpu
        .addr   ending_palette
        jsr LA96E
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda #$04
        sta renderMode
        lda #$0A
        jsr setMusicTrack
        lda #$80
        jsr render_endingUnskippable
LA95D:
        jsr render_ending
        jsr updateAudioWaitForNmiAndResetOamStaging
        lda ending_customVars
        bne LA95D
        lda newlyPressedButtons_player1
        cmp #BUTTON_START
        bne LA95D
        rts

LA96E:
        lda #$00
        sta ending
        lda score+2
        cmp #$05
        bcc ending_selected
        lda #$01
        sta ending
        lda score+2
        cmp #$07
        bcc ending_selected
        lda #$02
        sta ending
        lda score+2
        cmp #$10
        bcc ending_selected
        lda #$03
        sta ending
        lda score+2
        cmp #$12
        bcc ending_selected
        lda #$04
        sta ending
        lda #>ending_patchToPpu_typeAOver120k
        sta patchToPpuAddr+1
        lda #<ending_patchToPpu_typeAOver120k
        sta patchToPpuAddr
        jsr patchToPpu
ending_selected:
        ldx ending
        lda LAA2A,x
        sta ending_customVars
        lda #$00
        sta ending_customVars+1
        rts

ending_typeA:
        lda ending_customVars
        cmp #$00
        beq LAA10
        sta spriteYOffset
        lda #$58
        ldx ending
        lda rocketToXOffsetTable,x
        sta spriteXOffset
        lda rocketToSpriteTable,x
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        lda ending
        asl a
        sta generalCounter
        lda frameCounter
        and #$02
        lsr a
        clc
        adc generalCounter
        tax
        lda rocketToJetSpriteTable,x
        sta spriteIndexInOamContentLookup
        ldx ending
        lda rocketToJetXOffsetTable,x
        clc
        adc spriteXOffset
        sta spriteXOffset
        jsr loadSpriteIntoOamStaging
        lda ending_customVars+1
        cmp #$F0
        bne LAA0E
        lda ending_customVars
        cmp #$B0
        bcc LA9FC
        lda frameCounter
        and #$01
        bne LAA0B
LA9FC:
        lda #$03
        sta soundEffectSlot0Init
        dec ending_customVars
        lda ending_customVars
        cmp #$80
        bcs LAA0B
        dec ending_customVars
LAA0B:
        jmp LAA10

LAA0E:
        inc ending_customVars+1
LAA10:
        rts

rocketToSpriteTable:
        .byte   $3E,$41,$44,$47,$4A
rocketToJetSpriteTable:
        .byte   $3F,$40,$42,$43,$45,$46,$48,$49
        .byte   $23,$24
rocketToJetXOffsetTable:
        .byte   $00,$00,$00,$00,$00
rocketToXOffsetTable:
        .byte   $54,$54,$50,$48,$A0
LAA2A:
        .byte   $BF,$BF,$BF,$BF,$C7
; canon is waitForVerticalBlankingInterval
updateAudioWaitForNmiAndResetOamStaging:
        jsr stage_playfield_render
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        lda #$FF
        ldx #$02
        ldy #$02
        jsr memset_page
        rts

updateAudioAndWaitForNmi:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        rts

updateAudioWaitForNmiAndDisablePpuRendering:
        jsr updateAudioAndWaitForNmi
        lda currentPpuMask
        and #$E1
_updatePpuMask:
        sta PPUMASK
        sta currentPpuMask
        rts

updateAudioWaitForNmiAndEnablePpuRendering:
        jsr updateAudioAndWaitForNmi
        jsr copyCurrentScrollAndCtrlToPPU
        lda currentPpuMask
        ora #$1E
        bne _updatePpuMask
waitForVBlankAndEnableNmi:
        lda PPUSTATUS
        and #$80
        bne waitForVBlankAndEnableNmi
        lda currentPpuCtrl
        ora #$80
        bne _updatePpuCtrl
disableNmi:
        lda currentPpuCtrl
        and #$7F
_updatePpuCtrl:
        sta PPUCTRL
        sta currentPpuCtrl
        rts

LAA82:
        ldx #$FF
        ldy #$00
        jsr memset_ppu_page_and_more
        rts

copyCurrentScrollAndCtrlToPPU:
        lda #$00
        sta PPUSCROLL
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        rts

bulkCopyToPpu:
        jsr copyAddrAtReturnAddressToTmp_incrReturnAddrBy2
        jmp copyToPpu

LAA9E:
        pha
        sta PPUADDR
        iny
        lda (tmp1),y
        sta PPUADDR
        iny
        lda (tmp1),y
        asl a
        pha
        lda currentPpuCtrl
        ora #$04
        bcs LAAB5
        and #$FB
LAAB5:
        sta PPUCTRL
        sta currentPpuCtrl
        pla
        asl a
        php
        bcc LAAC2
        ora #$02
        iny
LAAC2:
        plp
        clc
        bne LAAC7
        sec
LAAC7:
        ror a
        lsr a
        tax
LAACA:
        bcs LAACD
        iny
LAACD:
        lda (tmp1),y
        sta PPUDATA
        dex
        bne LAACA
        pla
        cmp #$3F
        bne LAAE6
        sta PPUADDR
        stx PPUADDR
        stx PPUADDR
        stx PPUADDR
LAAE6:
        sec
        tya
        adc tmp1
        sta tmp1
        lda #$00
        adc tmp2
        sta tmp2
; Address to read from stored in tmp1/2
copyToPpu:
        ldx PPUSTATUS
        ldy #$00
        lda (tmp1),y
        bpl LAAFC
        rts

LAAFC:
        cmp #$60
        bne LAB0A
        pla
        sta tmp2
        pla
        sta tmp1
        ldy #$02
        bne LAAE6
LAB0A:
        cmp #$4C
        bne LAA9E
        lda tmp1
        pha
        lda tmp2
        pha
        iny
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        bcs copyToPpu
copyAddrAtReturnAddressToTmp_incrReturnAddrBy2:
        tsx
        lda stack+3,x
        sta tmpBulkCopyToPpuReturnAddr
        lda stack+4,x
        sta tmpBulkCopyToPpuReturnAddr+1
        ldy #$01
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp1
        iny
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp2
        clc
        lda #$02
        adc tmpBulkCopyToPpuReturnAddr
        sta stack+3,x
        lda #$00
        adc tmpBulkCopyToPpuReturnAddr+1
        sta stack+4,x
        rts

;reg x: zeropage addr of seed; reg y: size of seed
generateNextPseudorandomNumber:
        lda tmp1,x
        and #$02
        sta tmp1
        lda tmp2,x
        and #$02
        eor tmp1
        clc
        beq @updateNextByteInSeed
        sec
@updateNextByteInSeed:
        ror tmp1,x
        inx
        dey
        bne @updateNextByteInSeed
        rts

pollController_actualRead:
        ldx joy1Location
        inx
        stx JOY1
        dex
        stx JOY1
        ldx #$08
@readNextBit:
        lda JOY1
        lsr a
        rol newlyPressedButtons_player1
        lsr a
        rol tmp1
        lda JOY2_APUFC
        lsr a
        rol newlyPressedButtons_player2
        lsr a
        rol tmp2
        dex
        bne @readNextBit
        rts

addExpansionPortInputAsControllerInput:
        lda tmp1
        ora newlyPressedButtons_player1
        sta newlyPressedButtons_player1
        lda tmp2
        ora newlyPressedButtons_player2
        sta newlyPressedButtons_player2
        rts

        jsr pollController_actualRead
        beq diffOldAndNewButtons
pollController:
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        sta generalCounter2
        lda newlyPressedButtons_player2
        sta generalCounter3
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        and generalCounter2
        sta newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        and generalCounter3
        sta newlyPressedButtons_player2
diffOldAndNewButtons:
        ldx #$01
@diffForPlayer:
        lda newlyPressedButtons_player1,x
        tay
        eor heldButtons_player1,x
        and newlyPressedButtons_player1,x
        sta newlyPressedButtons_player1,x
        sty heldButtons_player1,x
        dex
        bpl @diffForPlayer
        rts

unreferenced_func1:
        jsr pollController_actualRead
LABD1:
        ldy newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        pha
        jsr pollController_actualRead
        pla
        cmp newlyPressedButtons_player2
        bne LABD1
        cpy newlyPressedButtons_player1
        bne LABD1
        beq diffOldAndNewButtons
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
LABEA:
        ldy newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        pha
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        pla
        cmp newlyPressedButtons_player2
        bne LABEA
        cpy newlyPressedButtons_player1
        bne LABEA
        beq diffOldAndNewButtons
        jsr pollController_actualRead
        lda tmp1
        sta heldButtons_player1
        lda tmp2
        sta heldButtons_player2
        ldx #$03
LAC0D:
        lda newlyPressedButtons_player1,x
        tay
        eor $F1,x
        and newlyPressedButtons_player1,x
        sta newlyPressedButtons_player1,x
        sty $F1,x
        dex
        bpl LAC0D
        rts

memset_ppu_page_and_more:
        sta tmp1
        stx tmp2
        sty tmp3
        lda PPUSTATUS
        lda currentPpuCtrl
        and #$FB
        sta PPUCTRL
        sta currentPpuCtrl
        lda tmp1
        sta PPUADDR
        ldy #$00
        sty PPUADDR
        ldx #$04
        cmp #$20
        bcs LAC40
        ldx tmp3
LAC40:
        ldy #$00
        lda tmp2
LAC44:
        sta PPUDATA
        dey
        bne LAC44
        dex
        bne LAC44
        ldy tmp3
        lda tmp1
        cmp #$20
        bcc LAC67
        adc #$02
        sta PPUADDR
        lda #$C0
        sta PPUADDR
        ldx #$40
LAC61:
        sty PPUDATA
        dex
        bne LAC61
LAC67:
        ldx tmp2
        rts

; reg a: value; reg x: start page; reg y: end page (inclusive)
memset_page:
        pha
        txa
        sty tmp2
        clc
        sbc tmp2
        tax
        pla
        ldy #$00
        sty tmp1
@setByte:
        sta (tmp1),y
        dey
        bne @setByte
        dec tmp2
        inx
        bne @setByte
        rts

switch_s_plus_2a:
        asl a
        tay
        iny
        pla
        sta tmp1
        pla
        sta tmp2
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        jmp (tmp1)


.include "rle.asm"


.ifdef CNROM
changeCHRBank:
        pha
        lda #$00
        sta generalCounter
        txa
        ora generalCounter
        sta generalCounter
        tya
        ora generalCounter
        sta generalCounter
        lda currentPpuCtrl
        and #$E7
        ora generalCounter
        sta currentPpuCtrl
        sta PPUCTRL
        pla
        tax
        sta chrBankTable,x
        rts
chrBankTable:
        .byte   $00,$01,$02
.else
setMMC1Control:
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        rts

changeCHRBank0:
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        rts

changeCHRBank1:
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        rts

changePRGBank:
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        rts
.endif

game_palette:
        .byte   $3F,$00
        .byte   $20               ; Universal
        .byte   $0F,$30,$12,$16   ; Backgrounds
        .byte   $0F,$20,$12,$18
        .byte   $0F,$2C,$16,$29
        .byte   $0F,$3C,$00,$30

        .byte   $0F,$35,$15,$22  ; Sprites
        .byte   $0F,$35,$29,$26
        .byte   $0F,$2C,$16,$29
        .byte   $0F,$3C,$00,$30
        .byte   $FF

legal_screen_palette:
        .byte   $3F,$00
        .byte   $10               ; Universal
        .byte   $0F,$27,$2A,$2B   ; Backgrounds
        .byte   $0F,$3C,$2A,$22
        .byte   $0F,$27,$2C,$29
        .byte   $0F,$30,$3A,$15
        .byte   $FF
menu_palette:
        .byte   $3F,$00
        .byte    $14              ; Universal
        .byte    $0F,$30,$38,$00  ; Backgrounds
        .byte    $0F,$30,$16,$00
        .byte    $0F,$30,$21,$00
        .byte    $0F,$16,$2A,$28
        .byte    $0F,$30,$29,$27  ; Sprite
        .byte    $FF

ending_palette:
        .byte    $3F,$00
        .byte    $20              ; Universal
        .byte    $12,$0F,$29,$37  ; Backgrounds
        .byte    $12,$0F,$30,$27
        .byte    $12,$0F,$17,$27
        .byte    $12,$0F,$15,$37

        .byte    $12,$0F,$29,$37  ; Sprites
        .byte    $12,$0F,$30,$27
        .byte    $12,$0F,$17,$27
        .byte    $12,$0F,$15,$37
        .byte    $FF


.include "charmap.asm"
        ;are the following zeros unused entries for each high score table?
defaultHighScoresTable:
        .byte  "HOWARD" ;$08,$0F,$17,$01,$12,$04
        .byte  "OTASAN" ;$0F,$14,$01,$13,$01,$0E
        .byte  "LANCE " ;$0C,$01,$0E,$03,$05,$2B
        .byte  $00,$00,$00,$00,$00,$00 ;unused fourth name
        .byte  "ALEX  " ;$01,$0C,$05,$18,$2B,$2B
        .byte  "TONY  " ;$14,$0F,$0E,$19,$2B,$2B
        .byte  "NINTEN" ;$0E,$09,$0E,$14,$05,$0E
        .byte   $00,$00,$00,$00,$00,$00 ;unused fourth name
        ;High Scores are stored in BCD
        .byte   $01,$00,$00 ;Game A 1st Entry Score, 10000
        .byte   $00,$75,$00 ;Game A 2nd Entry Score, 7500
        .byte   $00,$50,$00 ;Game A 3rd Entry Score, 5000
        .byte   $00,$00,$00 ;unused fourth score
        .byte   $00,$20,$00 ;Game B 1st Entry Score, 2000
        .byte   $00,$10,$00 ;Game B 2nd Entry Score, 1000
        .byte   $00,$05,$00 ;Game B 3rd Entry Score, 500
        .byte   $00,$00,$00 ;unused fourth score
        .byte   $09 ;Game A 1st Entry Level
        .byte   $05 ;Game A 2nd Entry Level
        .byte   $00 ;Game A 3nd Entry Level
        .byte   $00 ;unused fourth level
        .byte   $09 ;Game B 1st Entry Level
        .byte   $05 ;Game B 2nd Entry Level
        .byte   $00 ;Game B 3rd Entry Level
        .byte   $00 ;unused fourth level
        .byte   $FF

;.segment        "legal_screen_nametable": absolute

legal_screen_nametable:
        .incbin "gfx/nametables/legal_screen_nametable.bin"
title_screen_nametable:
        .incbin "gfx/nametables/title_screen_nametable.bin"
game_type_menu_nametable:
        .incbin "gfx/nametables/game_type_menu_nametable.bin"
level_menu_nametable:
        .incbin "gfx/nametables/level_menu_nametable.bin"
game_nametable:
        .incbin "gfx/nametables/game_nametable.bin"
stats_nametable:
        .incbin "gfx/nametables/stats_nametable.bin"
enter_high_score_nametable:
        .incbin "gfx/nametables/enter_high_score_nametable.bin"

; actually custom menu nametable
menu_options_nametable:
        .incbin "gfx/nametables/menu_options_nametable.bin"

show_scores_nametable_patch:
        .byte $2A,$0F,$06
        .byte $1C,$0C,$18,$1B,$0E,$1C ; SCORES
        .byte $FF
type_b_lvl9_ending_nametable:
        .incbin "gfx/nametables/type_b_lvl9_ending_nametable.bin"
type_b_ending_nametable:
        .incbin "gfx/nametables/type_b_ending_nametable.bin"
type_a_ending_nametable:
        .incbin "gfx/nametables/type_a_ending_nametable.bin"


.include "orientation/orientation_table.asm"

; Anydas code by HydrantDude
incrementStatsAndSetAutorepeatX:
        jsr incrementPieceStat
        lda anydasARECharge
        cmp #$01
        bne @ret
        sta autorepeatX
@ret:
        rts

; End of "PRG_chunk1" segment
.code


.segment        "PRG_chunk2": absolute

.include "data/demo_data.asm"

; canon is updateAudio
updateAudio_jmp:
        jmp updateAudio

; canon is updateAudio
updateAudio2:
        jmp soundEffectSlot2_makesNoSound

LE006:
        jmp LE1D8

; Referenced via updateSoundEffectSlotShared
soundEffectSlot0Init_table:
        .addr   soundEffectSlot0_makesNoSound
        .addr   soundEffectSlot0_gameOverCurtainInit
        .addr   soundEffectSlot0_endingRocketInit
soundEffectSlot0Playing_table:
        .addr   advanceSoundEffectSlot0WithoutUpdate
        .addr   updateSoundEffectSlot0_apu
        .addr   advanceSoundEffectSlot0WithoutUpdate
soundEffectSlot1Init_table:
        .addr   soundEffectSlot1_menuOptionSelectInit
        .addr   soundEffectSlot1_menuScreenSelectInit
        .addr   soundEffectSlot1_shiftTetriminoInit
        .addr   soundEffectSlot1_tetrisAchievedInit
        .addr   soundEffectSlot1_rotateTetriminoInit
        .addr   soundEffectSlot1_levelUpInit
        .addr   soundEffectSlot1_lockTetriminoInit
        .addr   soundEffectSlot1_chirpChirpInit
        .addr   soundEffectSlot1_lineClearingInit
        .addr   soundEffectSlot1_lineCompletedInit
soundEffectSlot1Playing_table:
        .addr   soundEffectSlot1_menuOptionSelectPlaying
        .addr   soundEffectSlot1_menuScreenSelectPlaying
        .addr   soundEffectSlot1Playing_advance
        .addr   soundEffectSlot1_tetrisAchievedPlaying
        .addr   soundEffectSlot1_rotateTetriminoPlaying
        .addr   soundEffectSlot1_levelUpPlaying
        .addr   soundEffectSlot1Playing_advance
        .addr   soundEffectSlot1_chirpChirpPlaying
        .addr   soundEffectSlot1_lineClearingPlaying
        .addr   soundEffectSlot1_lineCompletedPlaying
soundEffectSlot3Init_table:
        .addr   soundEffectSlot3_fallingAlien
        .addr   soundEffectSlot3_donk
soundEffectSlot3Playing_table:
        .addr   updateSoundEffectSlot3_apu
        .addr   soundEffectSlot3Playing_advance
; Referenced by unused slot 4 as well
soundEffectSlot2Init_table:
        .addr   soundEffectSlot2_makesNoSound
        .addr   soundEffectSlot2_lowBuzz
        .addr   soundEffectSlot2_mediumBuzz
; input y: $E100+y source addr
copyToSq1Channel:
        lda #$00
        beq copyToApuChannel
copyToTriChannel:
        lda #$08
        bne copyToApuChannel
copyToNoiseChannel:
        lda #$0C
        bne copyToApuChannel
copyToSq2Channel:
        lda #$04
; input a: $4000+a APU addr; input y: $E100+y source; copies 4 bytes
copyToApuChannel:
        sta AUDIOTMP1
        lda #$40
        sta AUDIOTMP2
        sty AUDIOTMP3
        lda #>soundEffectSlot0_gameOverCurtainInitData
        sta AUDIOTMP4
        ldy #$00
@copyByte:
        lda (AUDIOTMP3),y
        sta (AUDIOTMP1),y
        iny
        tya
        cmp #$04
        bne @copyByte
        rts

; input a: index-1 into table at $E000+AUDIOTMP1; output AUDIOTMP3/4: address; $EF set to a
computeSoundEffMethod:
        sta currentAudioSlot
        pha
        ldy #>soundEffectSlot0Init_table
        sty AUDIOTMP2
        ldy #$00
@whileYNot2TimesA:
        dec currentAudioSlot
        beq @copyAddr
        iny
        iny
        tya
        cmp #$22
        bne @whileYNot2TimesA
        lda #$91
        sta AUDIOTMP3
        lda #>soundEffectSlot0Init_table
        sta AUDIOTMP4
@ret:
        pla
        sta currentAudioSlot
        rts

@copyAddr:
        lda (AUDIOTMP1),y
        sta AUDIOTMP3
        iny
        lda (AUDIOTMP1),y
        sta AUDIOTMP4
        jmp @ret

unreferenced_soundRng:
        lda $EB
        and #$02
        sta $06FF
        lda $EC
        and #$02
        eor $06FF
        clc
        beq @insertRandomBit
        sec
@insertRandomBit:
        ror $EB
        ror $EC
        rts

; Z=0 when returned means disabled
advanceAudioSlotFrame:
        ldx currentSoundEffectSlot
        inc soundEffectSlot0FrameCounter,x
        lda soundEffectSlot0FrameCounter,x
        cmp soundEffectSlot0FrameCount,x
        bne @ret
        lda #$00
        sta soundEffectSlot0FrameCounter,x
@ret:
        rts

; removing this messes up the piece shifting sound
unreferenced_data3:
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$7F,$0F,$C0

; Referenced by initSoundEffectShared
soundEffectSlot0_gameOverCurtainInitData:
        .byte   $1F,$7F,$0F,$C0
soundEffectSlot0_endingRocketInitData:
        .byte   $08,$7F,$0E,$C0
; Referenced at LE20F
music_pause_sq1_even:
        .byte   $9D,$7F,$7A,$28
; Referenced at LE20F
music_pause_sq1_odd:
        .byte   $9D,$7F,$40,$28
soundEffectSlot1_rotateTetriminoInitData:
        .byte   $9E,$7F,$C0,$28
soundEffectSlot1Playing_rotateTetriminoStage3:
        .byte   $B2,$7F,$C0,$08
soundEffectSlot1_levelUpInitData:
        .byte   $DE,$7F,$A8,$18
soundEffectSlot1_lockTetriminoInitData:
        .byte   $9F,$84,$FF,$0B
soundEffectSlot1_menuOptionSelectInitData:
        .byte   $DB,$7F,$40,$28
soundEffectSlot1Playing_menuOptionSelectStage2:
        .byte   $D2,$7F,$40,$28
soundEffectSlot1_menuScreenSelectInitData:
        .byte   $D9,$7F,$84,$28
soundEffectSlot1_tetrisAchievedInitData:
        .byte   $9E,$9D,$C0,$08
soundEffectSlot1_lineCompletedInitData:
        .byte   $9C,$9A,$A0,$09
soundEffectSlot1_lineClearingInitData:
        .byte   $9E,$7F,$69,$08
soundEffectSlot1_chirpChirpInitData:
        .byte   $96,$7F,$36,$20
soundEffectSlot1Playing_chirpChirpStage2:
        .byte   $82,$7F,$30,$F8
soundEffectSlot1_shiftTetriminoInitData:
        .byte   $98,$7F,$80,$38
soundEffectSlot3_fallingAlienInitData:
        .byte   $30,$7F,$70,$08
soundEffectSlot3_donkInitData:
        .byte   $03,$7F,$3D,$18
soundEffectSlot1_chirpChirpSq1Vol_table:
        .byte   $14,$93,$94,$D3
; See getSoundEffectNoiseNibble
noiselo_table:
        .byte   $7A,$DE,$FF,$EF,$FD,$DF,$FE,$EF
        .byte   $EF,$FD,$EF,$FE,$DF,$FF,$EE,$EE
        .byte   $FF,$EF,$FF,$FF,$FF,$EF,$EF,$FF
        .byte   $FD,$DF,$DF,$EF,$FE,$DF,$EF,$FF
; Similar to noiselo_table. Nibble set to NOISE_VOL bits 0-3 with bit 4 set to 1
noisevol_table:
        .byte   $BF,$FF,$EE,$EF,$EF,$EF,$DF,$FB
        .byte   $BB,$AA,$AA,$99,$98,$87,$76,$66
        .byte   $55,$44,$44,$44,$44,$43,$33,$33
        .byte   $22,$22,$22,$22,$21,$11,$11,$11
updateSoundEffectSlot2:
        ldx #$02
        lda #<soundEffectSlot2Init_table
        ldy #<soundEffectSlot2Init_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot3:
        ldx #$03
        lda #<soundEffectSlot3Init_table
        ldy #<soundEffectSlot3Playing_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot4_unused:
        ldx #$04
        lda #<soundEffectSlot2Init_table
        ldy #<soundEffectSlot2Init_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot1:
        lda soundEffectSlot4Playing
        bne updateSoundEffectSlotShared_rts
        ldx #$01
        lda #<soundEffectSlot1Init_table
        ldy #<soundEffectSlot1Playing_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot0:
        ldx #$00
        lda #<soundEffectSlot0Init_table
        ldy #<soundEffectSlot0Playing_table
; x: sound effect slot; a: low byte addr, for $E0 high byte; y: low byte addr, for $E0 high byte, if slot unused
updateSoundEffectSlotShared:
        sta AUDIOTMP1
        stx currentSoundEffectSlot
        lda soundEffectSlot0Init,x
        beq @primaryIsEmpty
@computeAndExecute:
        jsr computeSoundEffMethod
        jmp (AUDIOTMP3)

@primaryIsEmpty:
        lda soundEffectSlot0Playing,x
        beq updateSoundEffectSlotShared_rts
        sty AUDIOTMP1
        bne @computeAndExecute
updateSoundEffectSlotShared_rts:
        rts

LE1D8:
        lda #$0F
        sta SND_CHN
        lda #$55
        sta soundRngSeed
        jsr soundEffectSlot2_makesNoSound
        rts

initAudioAndMarkInited:
        inc audioInitialized
        jsr muteAudio
        sta musicPauseSoundEffectLengthCounter ; a = 0
        rts

updateAudio_pause:
        lda audioInitialized
        beq initAudioAndMarkInited
        lda musicPauseSoundEffectLengthCounter
        cmp #$12
        beq @ret
        and #$03
        cmp #$03
        bne @incAndRet
        inc musicPauseSoundEffectCounter
        ldy #<music_pause_sq1_odd
        lda musicPauseSoundEffectCounter
        and #$01
        bne @tableChosen
        ldy #<music_pause_sq1_even
@tableChosen:
        jsr copyToSq1Channel
@incAndRet:
        inc musicPauseSoundEffectLengthCounter
@ret:
        rts

; Disables APU frame interrupt
updateAudio:
        lda #$C0
        sta JOY2_APUFC
        lda musicStagingNoiseHi
        cmp #$05
        beq updateAudio_pause
        lda #$00
        sta audioInitialized
        sta $068B
        jsr updateSoundEffectSlot2
        jsr updateSoundEffectSlot0
        jsr updateSoundEffectSlot3
        jsr updateSoundEffectSlot1
        jsr updateMusic
        lda #$00
        ldx #$06
@clearSoundEffectSlotsInit:
        sta $06EF,x
        dex
        bne @clearSoundEffectSlotsInit
        rts

soundEffectSlot2_makesNoSound:
        jsr LE253
muteAudioAndClearTriControl:
        jsr muteAudio
        lda #$00
        sta DMC_RAW
        sta musicChanControl+2
        rts

LE253:
        lda #$00
        sta musicChanInhibit
        sta musicChanInhibit+1
        sta musicChanInhibit+2
        sta musicStagingNoiseLo
        sta resetSq12ForMusic
        tay
LE265:
        lda #$00
        sta soundEffectSlot0Playing,y
        iny
        tya
        cmp #$06
        bne LE265
        rts

muteAudio:
        lda #$00
        sta DMC_RAW
        lda #$10
        sta SQ1_VOL
        sta SQ2_VOL
        sta NOISE_VOL
        lda #$00
        sta TRI_LINEAR
        rts

; inits currentSoundEffectSlot; input y: $E100+y to init APU channel (leaves alone if 0); input a: number of frames
initSoundEffectShared:
        ldx currentSoundEffectSlot
        sta soundEffectSlot0FrameCount,x
        txa
        sta $06C7,x
        tya
        beq @continue
        txa
        beq @slot0
        cmp #$01
        beq @slot1
        cmp #$02
        beq @slot2
        cmp #$03
        beq @slot3
        rts

@slot1:
        jsr copyToSq1Channel
        beq @continue
@slot2:
        jsr copyToSq2Channel
        beq @continue
@slot3:
        jsr copyToTriChannel
        beq @continue
@slot0:
        jsr copyToNoiseChannel
@continue:
        lda currentAudioSlot
        sta soundEffectSlot0Playing,x
        lda #$00
        sta soundEffectSlot0FrameCounter,x
        sta soundEffectSlot0SecondaryCounter,x
        sta soundEffectSlot0TertiaryCounter,x
        sta soundEffectSlot0Tmp,x
        sta resetSq12ForMusic
        rts

soundEffectSlot0_endingRocketInit:
        lda #$20
        ldy #<soundEffectSlot0_endingRocketInitData
        jmp initSoundEffectShared

setNoiseLo:
        sta NOISE_LO
        rts

loadNoiseLo:
        jsr getSoundEffectNoiseNibble
        jmp setNoiseLo

soundEffectSlot0_makesNoSound:
        lda #$10
        ldy #$00
        jmp initSoundEffectShared

advanceSoundEffectSlot0WithoutUpdate:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectSlot0WithoutUpdate_ret
stopSoundEffectSlot0:
        lda #$00
        sta soundEffectSlot0Playing
        lda #$10
        sta NOISE_VOL
updateSoundEffectSlot0WithoutUpdate_ret:
        rts

unreferenced_code2:
        lda #$02
        sta currentAudioSlot
soundEffectSlot0_gameOverCurtainInit:
        lda #$40
        ldy #<soundEffectSlot0_gameOverCurtainInitData
        jmp initSoundEffectShared

updateSoundEffectSlot0_apu:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectNoiseAudio
        jmp stopSoundEffectSlot0

updateSoundEffectNoiseAudio:
        ldx #<noiselo_table
        jsr loadNoiseLo
        ldx #<noisevol_table
        jsr getSoundEffectNoiseNibble
        ora #$10
        sta NOISE_VOL
        inc soundEffectSlot0SecondaryCounter
        rts

; Loads from noiselo_table(x=$54)/noisevol_table(x=$74)
getSoundEffectNoiseNibble:
        stx AUDIOTMP1
        ldy #>noiselo_table
        sty AUDIOTMP2
        ldx soundEffectSlot0SecondaryCounter
        txa
        lsr a
        tay
        lda (AUDIOTMP1),y
        sta AUDIOTMP5
        txa
        and #$01
        beq @shift4
        lda AUDIOTMP5
        and #$0F
        rts

@shift4:
        lda AUDIOTMP5
        lsr a
        lsr a
        lsr a
        lsr a
        rts

LE33B:
        lda soundEffectSlot1Playing
        cmp #$04
        beq LE34E
        cmp #$06
        beq LE34E
        cmp #$09
        beq LE34E
        cmp #$0A
        beq LE34E
LE34E:
        rts

soundEffectSlot1_chirpChirpPlaying:
        lda soundEffectSlot1TertiaryCounter
        beq @stage1
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$16
        bne soundEffectSlot1Playing_ret
        jmp soundEffectSlot1Playing_stop

@stage1:
        lda soundEffectSlot1SecondaryCounter
        and #$03
        tay
        lda soundEffectSlot1_chirpChirpSq1Vol_table,y
        sta SQ1_VOL
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$08
        bne soundEffectSlot1Playing_ret
        inc soundEffectSlot1TertiaryCounter
        ldy #<soundEffectSlot1Playing_chirpChirpStage2
        jmp copyToSq1Channel

; Unused.
soundEffectSlot1_chirpChirpInit:
        ldy #<soundEffectSlot1_chirpChirpInitData
        jmp initSoundEffectShared

soundEffectSlot1_lockTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$0F
        ldy #<soundEffectSlot1_lockTetriminoInitData
        jmp initSoundEffectShared

soundEffectSlot1_shiftTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$02
        ldy #<soundEffectSlot1_shiftTetriminoInitData
        jmp initSoundEffectShared

soundEffectSlot1Playing_advance:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1Playing_ret
soundEffectSlot1Playing_stop:
        lda #$10
        sta SQ1_VOL
        lda #$00
        sta musicChanInhibit
        sta soundEffectSlot1Playing
        inc resetSq12ForMusic
soundEffectSlot1Playing_ret:
        rts

soundEffectSlot1_menuOptionSelectPlaying_ret:
        rts

soundEffectSlot1_menuOptionSelectPlaying:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1_menuOptionSelectPlaying_ret
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$02
        bne @stage2
        jmp soundEffectSlot1Playing_stop

@stage2:
        ldy #<soundEffectSlot1Playing_menuOptionSelectStage2
        jmp copyToSq1Channel

soundEffectSlot1_menuOptionSelectInit:
        lda #$03
        ldy #<soundEffectSlot1_menuOptionSelectInitData
        bne LE417
soundEffectSlot1_rotateTetrimino_ret:
        rts

soundEffectSlot1_rotateTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1_rotateTetrimino_ret
        lda #$04
        ldy #<soundEffectSlot1_rotateTetriminoInitData
        jsr LE417
soundEffectSlot1_rotateTetriminoPlaying:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1_rotateTetrimino_ret
        lda soundEffectSlot1SecondaryCounter
        inc soundEffectSlot1SecondaryCounter
        beq @stage3
        cmp #$01
        beq @stage2
        cmp #$02
        beq @stage3
        cmp #$03
        bne soundEffectSlot1_rotateTetrimino_ret
        jmp soundEffectSlot1Playing_stop

@stage2:
        ldy #<soundEffectSlot1_rotateTetriminoInitData
        jmp copyToSq1Channel

; On first glance it appears this is used twice, but the first beq does nothing because the inc result will never be 0
@stage3:
        ldy #<soundEffectSlot1Playing_rotateTetriminoStage3
        jmp copyToSq1Channel

soundEffectSlot1_tetrisAchievedInit:
        lda #$05
        ldy #<soundEffectSlot1_tetrisAchievedInitData
        jsr LE417
        lda #$10
        bne LE437
soundEffectSlot1_tetrisAchievedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_tetrisAchievedInitData
        bne LE442
LE417:
        jmp initSoundEffectShared

soundEffectSlot1_lineCompletedInit:
        lda #$05
        ldy #<soundEffectSlot1_lineCompletedInitData
        jsr LE417
        lda #$08
        bne LE437
soundEffectSlot1_lineCompletedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_lineCompletedInitData
        bne LE442
soundEffectSlot1_lineClearingInit:
        lda #$04
        ldy #<soundEffectSlot1_lineClearingInitData
        jsr LE417
        lda #$00
LE437:
        sta soundEffectSlot1TertiaryCounter
LE43A:
        rts

soundEffectSlot1_lineClearingPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_lineClearingInitData
LE442:
        jsr copyToSq1Channel
        clc
        lda soundEffectSlot1TertiaryCounter
        adc soundEffectSlot1SecondaryCounter
        tay
        lda soundEffectSlot1_lineClearing_lo,y
        sta SQ1_LO
        ldy soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1_lineClearing_vol,y
        sta SQ1_VOL
        bne LE46F
        lda soundEffectSlot1Playing
        cmp #$04
        bne LE46C
        lda #$09
        sta currentAudioSlot
        jmp soundEffectSlot1_lineClearingInit

LE46C:
        jmp soundEffectSlot1Playing_stop

LE46F:
        inc soundEffectSlot1SecondaryCounter
LE472:
        rts

soundEffectSlot1_menuScreenSelectInit:
        lda #$03
        ldy #<soundEffectSlot1_menuScreenSelectInitData
        jsr initSoundEffectShared
        lda soundEffectSlot1_menuScreenSelectInitData+2
        sta soundEffectSlot1SecondaryCounter
        rts

soundEffectSlot1_menuScreenSelectPlaying:
        jsr advanceAudioSlotFrame
        bne LE472
        inc soundEffectSlot1TertiaryCounter
        lda soundEffectSlot1TertiaryCounter
        cmp #$04
        bne LE493
        jmp soundEffectSlot1Playing_stop

LE493:
        lda soundEffectSlot1SecondaryCounter
        lsr a
        lsr a
        lsr a
        lsr a
        sta soundEffectSlot1Tmp
        lda soundEffectSlot1SecondaryCounter
        clc
        sbc soundEffectSlot1Tmp
        sta soundEffectSlot1SecondaryCounter
        sta SQ1_LO
        lda #$28
LE4AC:
        sta SQ1_HI
LE4AF:
        rts

soundEffectSlot1_lineClearing_vol:
        .byte   $9E,$9B,$99,$96,$94,$93,$92,$91
        .byte   $00
soundEffectSlot1_lineClearing_lo:
        .byte   $46,$37,$46,$37,$46,$37,$46,$37
        .byte   $70,$80,$90,$A0,$B0,$C0,$D0,$E0
        .byte   $C0,$89,$B8,$68,$A0,$50,$90,$40
soundEffectSlot1_levelUpPlaying:
        jsr advanceAudioSlotFrame
        bne LE4AF
        ldy soundEffectSlot1SecondaryCounter
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1_levelUp_lo,y
        beq LE4E9
        sta SQ1_LO
        lda #$28
        jmp LE4AC

LE4E9:
        jmp soundEffectSlot1Playing_stop

soundEffectSlot1_levelUpInit:
        lda #$06
        ldy #<soundEffectSlot1_levelUpInitData
        jmp initSoundEffectShared

soundEffectSlot1_levelUp_lo:
        .byte   $69,$A8,$69,$A8,$8D,$53,$8D,$53
        .byte   $8D,$00,$A9,$10,$8D,$04,$40,$A9
        .byte   $00,$8D,$C9,$06,$8D,$FA,$06,$60
; Unused
soundEffectSlot2_mediumBuzz:
        .byte   $A9,$3F,$A0,$60,$A2,$0F
        bne LE51B
; Unused
soundEffectSlot2_lowBuzz:
        lda #$3F
        ldy #$60
        ldx #$0E
        bne LE51B
LE51B:
        sta DMC_LEN
        sty DMC_START
        stx DMC_FREQ
        lda #$0F
        sta SND_CHN
        lda #$00
        sta DMC_RAW
        lda #$1F
        sta SND_CHN
        rts

; Unused
soundEffectSlot3_donk:
        lda #$02
        ldy #<soundEffectSlot3_donkInitData
        jmp initSoundEffectShared

soundEffectSlot3Playing_advance:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot3Playing_ret
soundEffectSlot3Playing_stop:
        lda #$00
        sta TRI_LINEAR
        sta musicChanInhibit+2
        sta soundEffectSlot3Playing
        lda #$18
        sta TRI_HI
soundEffectSlot3Playing_ret:
        rts

updateSoundEffectSlot3_apu:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot3Playing_ret
        ldy soundEffectSlot3SecondaryCounter
        inc soundEffectSlot3SecondaryCounter
        lda trilo_table,y
        beq soundEffectSlot3Playing_stop
        sta TRI_LO
        sta soundEffectSlot3TertiaryCounter
        lda soundEffectSlot3_fallingAlienInitData+3
        sta TRI_HI
        rts

; Unused
soundEffectSlot3_fallingAlien:
        lda #$06
        ldy #<soundEffectSlot3_fallingAlienInitData
        jsr initSoundEffectShared
        lda soundEffectSlot3_fallingAlienInitData+2
        sta soundEffectSlot3TertiaryCounter
        rts

trilo_table:
        .byte   $72,$74,$77,$00
updateMusic_noSoundJmp:
        jmp soundEffectSlot2_makesNoSound

updateMusic:
        lda musicTrack
        tay
        cmp #$FF
        beq updateMusic_noSoundJmp
        cmp #$00
        beq @checkIfAlreadyPlaying
        sta currentAudioSlot
        sta musicTrack_dec
        dec musicTrack_dec
        lda #$7F
        sta musicStagingSq1Sweep
        sta musicStagingSq1Sweep+1
        jsr loadMusicTrack
@updateFrame:
        jmp updateMusicFrame

@checkIfAlreadyPlaying:
        lda currentlyPlayingMusicTrack
        bne @updateFrame
        rts

; triples of bytes, one for each MMIO
noises_table:
        .byte   $00,$10,$01,$18,$00,$01,$38,$00
        .byte   $03,$40,$00,$06,$58,$00,$0A,$38
        .byte   $02,$04,$40,$13,$05,$40,$14,$0A
        .byte   $40,$14,$08,$40,$12,$0E,$08,$16
        .byte   $0E,$28,$16,$0B,$18
; input x: channel number (0-3). Does nothing for track 1 and NOISE
updateMusicFrame_setChanLo:
        lda currentlyPlayingMusicTrack
        cmp #$01
        beq @ret
        txa
        cmp #$03
        beq @ret
        lda musicChanControl,x
        and #$E0
        beq @ret
        sta AUDIOTMP1
        lda musicChanNote,x
        cmp #$02
        beq @incAndRet
        ldy musicChannelOffset
        lda musicStagingSq1Lo,y
        sta AUDIOTMP2
        jsr updateMusicFrame_setChanLoOffset
@incAndRet:
        inc musicChanLoFrameCounter,x
@ret:
        rts

musicLoOffset_8AndC:
        lda AUDIOTMP3
        cmp #$31
        bne @lessThan31
        lda #$27
@lessThan31:
        tay
        lda loOff9To0FallTable,y
        pha
        lda musicChanNote,x
        cmp #$46
        bne LE613
        pla
        lda #$00
        beq musicLoOffset_setLoAndSaveFrameCounter
LE613:
        pla
        jmp musicLoOffset_setLoAndSaveFrameCounter

; Doesn't loop
musicLoOffset_4:
        lda AUDIOTMP3
        tay
        cmp #$10
        bcs @outOfRange
        lda loOffDescendToNeg11BounceToNeg9Table,y
        jmp musicLoOffset_setLo

@outOfRange:
        lda #$F6
        bne musicLoOffset_setLo
; Every frame is the same
musicLoOffset_minus2_6:
        lda musicChanNote,x
        cmp #$4C
        bcc @unnecessaryBranch
        lda #$FE
        bne musicLoOffset_setLo
@unnecessaryBranch:
        lda #$FE
        bne musicLoOffset_setLo
; input x: channel number (0-2). input AUDIOTMP1: musicChanControl masked by #$E0. input AUDIOTMP2: base LO
updateMusicFrame_setChanLoOffset:
        lda musicChanLoFrameCounter,x
        sta AUDIOTMP3
        lda AUDIOTMP1
        cmp #$20
        beq @2AndE
        cmp #$A0
        beq @A
        cmp #$60
        beq musicLoOffset_minus2_6
        cmp #$40
        beq musicLoOffset_4
        cmp #$80
        beq musicLoOffset_8AndC
        cmp #$C0
        beq musicLoOffset_8AndC
; Loops between 0-9
@2AndE:
        lda AUDIOTMP3
        cmp #$0A
        bne @2AndE_lessThanA
        lda #$00
@2AndE_lessThanA:
        tay
        lda loOffTrillNeg2To2Table,y
        jmp musicLoOffset_setLoAndSaveFrameCounter

; Ends by looping in 2 and E table
@A:
        lda AUDIOTMP3
        cmp #$2B
        bne @A_lessThan2B
        lda #$21
@A_lessThan2B:
        tay
        lda loOffSlowStartTrillTable,y
musicLoOffset_setLoAndSaveFrameCounter:
        pha
        tya
        sta musicChanLoFrameCounter,x
        pla
musicLoOffset_setLo:
        pha
        lda musicChanInhibit,x
        bne @ret
        pla
        clc
        adc AUDIOTMP2
        ldy musicChannelOffset
        sta SQ1_LO,y
        rts

@ret:
        pla
        rts

; Values are signed
loOff9To0FallTable:
        .byte   $09,$08,$07,$06,$05,$04,$03,$02
        .byte   $02,$01,$01,$00
; Includes next table
loOffSlowStartTrillTable:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$01
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$01,$01,$00,$00,$00,$FF,$FF
        .byte   $00
loOffTrillNeg2To2Table:
        .byte   $00,$01,$01,$02,$01,$00,$FF,$FF
        .byte   $FE,$FF
loOffDescendToNeg11BounceToNeg9Table:
        .byte   $00,$FF,$FE,$FD,$FC,$FB,$FA,$F9
        .byte   $F8,$F7,$F6,$F5,$F6,$F7,$F6,$F5
copyFFFFToDeref:
        lda #$FF
        sta musicDataChanPtrDeref,x
        bne storeDeref1AndContinue
loadMusicTrack:
        jsr muteAudioAndClearTriControl
        lda currentAudioSlot
        sta currentlyPlayingMusicTrack
        lda musicTrack_dec
        tay
        lda musicDataTableIndex,y
        tay
        ldx #$00
@copyByteToMusicData:
        lda musicDataTable,y
        sta musicDataNoteTableOffset,x
        iny
        inx
        txa
        cmp #$0A ; copies 10-byte header to musicDataNoteTableOffset
        bne @copyByteToMusicData
        lda #$01
        sta musicChanNoteDurationRemaining
        sta musicChanNoteDurationRemaining+1
        sta musicChanNoteDurationRemaining+2
        sta musicChanNoteDurationRemaining+3
        lda #$00
        sta music_unused2
        ldy #$08
@zeroFillDeref:
        sta musicDataChanPtrDeref+7,y
        dey
        bne @zeroFillDeref
        tax
derefNextAddr:
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        cmp #$FF
        beq copyFFFFToDeref
        sta musicChanTmpAddr+1
        ldy musicDataChanPtrOff
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref,x
        iny
        lda (musicChanTmpAddr),y
storeDeref1AndContinue:
        sta musicDataChanPtrDeref+1,x
        inx
        inx
        txa
        cmp #$08
        bne derefNextAddr
        rts

initSq12IfTrashedBySoundEffect:
        lda resetSq12ForMusic
        beq initSq12IfTrashedBySoundEffect_ret
        cmp #$01
        beq @setSq1
        lda #$7F
        sta SQ2_SWEEP
        lda musicStagingSq2Lo
        sta SQ2_LO
        lda musicStagingSq2Hi
        sta SQ2_HI
@setSq1:
        lda #$7F
        sta SQ1_SWEEP
        lda musicStagingSq1Lo
        sta SQ1_LO
        lda musicStagingSq1Hi
        sta SQ1_HI
        lda #$00
        sta resetSq12ForMusic
initSq12IfTrashedBySoundEffect_ret:
        rts

; input x: channel number (0-3). Does nothing for SQ1/2
updateMusicFrame_setChanVol:
        txa
        cmp #$02
        bcs initSq12IfTrashedBySoundEffect_ret
        lda musicChanControl,x
        and #$1F
        beq @ret
        sta AUDIOTMP2
        lda musicChanNote,x
        cmp #$02
        beq @muteAndAdvanceFrame
        ldy #$00
@controlMinus1Times2_storeToY:
        dec AUDIOTMP2
        beq @loadFromTable
        iny
        iny
        bne @controlMinus1Times2_storeToY
@loadFromTable:
        lda musicChanVolControlTable,y
        sta AUDIOTMP3
        lda musicChanVolControlTable+1,y
        sta AUDIOTMP4
        lda musicChanVolFrameCounter,x
        lsr a
        tay
        lda (AUDIOTMP3),y
        sta AUDIOTMP5
        cmp #$FF
        beq @constVolAtEnd
        cmp #$F0
        beq @muteAtEnd
        lda musicChanVolFrameCounter,x
        and #$01
        bne @useNibbleFromTable
        lsr AUDIOTMP5
        lsr AUDIOTMP5
        lsr AUDIOTMP5
        lsr AUDIOTMP5
@useNibbleFromTable:
        lda AUDIOTMP5
        and #$0F
        sta AUDIOTMP1
        lda musicChanVolume,x
        and #$F0
        ora AUDIOTMP1
        tay
@advanceFrameAndSetVol:
        inc musicChanVolFrameCounter,x
@setVol:
        lda musicChanInhibit,x
        bne @ret
        tya
        ldy musicChannelOffset
        sta SQ1_VOL,y
@ret:
        rts

@constVolAtEnd:
        ldy musicChanVolume,x
        bne @setVol
; Only seems valid for NOISE
@muteAtEnd:
        ldy #$10
        bne @setVol
; Only seems valid for NOISE
@muteAndAdvanceFrame:
        ldy #$10
        bne @advanceFrameAndSetVol
;
updateMusicFrame_progLoadNextScript:
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtr,x
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtr+1,x
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        sta musicChanTmpAddr+1
        txa
        lsr a
        tax
        lda #$00
        tay
        sta musicDataChanPtrOff,x
        jmp updateMusicFrame_progLoadRoutine

updateMusicFrame_progEnd:
        jsr soundEffectSlot2_makesNoSound
updateMusicFrame_ret:
        rts

updateMusicFrame_progNextRoutine:
        txa
        asl a
        tax
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        sta musicChanTmpAddr+1
        txa
        lsr a
        tax
        inc musicDataChanPtrOff,x
        inc musicDataChanPtrOff,x
        ldy musicDataChanPtrOff,x
; input musicChanTmpAddr: current channel's musicDataChanPtr. input y: offset. input x: channel number (0-3)
updateMusicFrame_progLoadRoutine:
        txa
        asl a
        tax
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref,x
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref+1,x
        cmp #$00
        beq updateMusicFrame_progEnd
        cmp #$FF
        beq updateMusicFrame_progLoadNextScript
        txa
        lsr a
        tax
        lda #$00
        sta musicDataChanInstructionOffset,x
        lda #$01
        sta musicChanNoteDurationRemaining,x
        bne updateMusicFrame_updateChannel
;
updateMusicFrame_progNextRoutine_jmp:
        jmp updateMusicFrame_progNextRoutine

updateMusicFrame:
        jsr initSq12IfTrashedBySoundEffect
        lda #$00
        tax
        sta musicChannelOffset
        beq updateMusicFrame_updateChannel
; input x: channel number * 2
updateMusicFrame_incSlotFromOffset:
        txa
        lsr a
        tax
; input x: channel number (0-3)
updateMusicFrame_incSlot:
        inx
        txa
        cmp #$04
        beq updateMusicFrame_ret
        lda musicChannelOffset
        clc
        adc #$04
        sta musicChannelOffset
; input x: channel number (0-3)
updateMusicFrame_updateChannel:
        txa
        asl a
        tax
        lda musicDataChanPtrDeref,x
        sta musicChanTmpAddr
        lda musicDataChanPtrDeref+1,x
        sta musicChanTmpAddr+1
        lda musicDataChanPtrDeref+1,x
        cmp #$FF
        beq updateMusicFrame_incSlotFromOffset
        txa
        lsr a
        tax
        dec musicChanNoteDurationRemaining,x
        bne @updateChannelFrame
        lda #$00
        sta musicChanVolFrameCounter,x
        sta musicChanLoFrameCounter,x
@processChannelInstruction:
        jsr musicGetNextInstructionByte
        beq updateMusicFrame_progNextRoutine_jmp
        cmp #$9F
        beq @setControlAndVolume
        cmp #$9E
        beq @setDurationOffset
        cmp #$9C
        beq @setNoteOffset
        tay
        cmp #$FF
        beq @endLoop
        and #$C0
        cmp #$C0
        beq @startForLoop
        jmp @noteAndMaybeDuration

@endLoop:
        lda musicChanProgLoopCounter,x
        beq @processChannelInstruction_jmp
        dec musicChanProgLoopCounter,x
        lda musicDataChanInstructionOffsetBackup,x
        sta musicDataChanInstructionOffset,x
        bne @processChannelInstruction_jmp
; Low 6 bits are number of times to run loop (1 == run code once)
@startForLoop:
        tya
        and #$3F
        sta musicChanProgLoopCounter,x
        dec musicChanProgLoopCounter,x
        lda musicDataChanInstructionOffset,x
        sta musicDataChanInstructionOffsetBackup,x
@processChannelInstruction_jmp:
        jmp @processChannelInstruction

@updateChannelFrame:
        jsr updateMusicFrame_setChanVol
        jsr updateMusicFrame_setChanLo
        jmp updateMusicFrame_incSlot

@playDmcAndNoise_jmp:
        jmp @playDmcAndNoise

@applyDurationForTri_jmp:
        jmp @applyDurationForTri

@setControlAndVolume:
        jsr musicGetNextInstructionByte
        sta musicChanControl,x
        jsr musicGetNextInstructionByte
        sta musicChanVolume,x
        jmp @processChannelInstruction

@unreferenced_code3:
        jsr musicGetNextInstructionByte
        jsr musicGetNextInstructionByte
        jmp @processChannelInstruction

@setDurationOffset:
        jsr musicGetNextInstructionByte
        sta musicDataDurationTableOffset
        jmp @processChannelInstruction

@setNoteOffset:
        jsr musicGetNextInstructionByte
        sta musicDataNoteTableOffset
        jmp @processChannelInstruction

; Duration, if present, is first
@noteAndMaybeDuration:
        tya
        and #$B0
        cmp #$B0
        bne @processNote
        tya
        and #$0F
        clc
        adc musicDataDurationTableOffset
        tay
        lda noteDurationTable,y
        sta musicChanNoteDuration,x
        tay
        txa
        cmp #$02
        beq @applyDurationForTri_jmp
@loadNextAsNote:
        jsr musicGetNextInstructionByte
        tay
@processNote:
        tya
        sta musicChanNote,x
        txa
        cmp #$03
        beq @playDmcAndNoise_jmp
        pha
        ldx musicChannelOffset
        lda noteToWaveTable+1,y
        beq @determineVolume
        lda musicDataNoteTableOffset
        bpl @signMagnitudeIsPositive
        and #$7F
        sta AUDIOTMP4
        tya
        clc
        sbc AUDIOTMP4 ; Subtracts an extra 1 because carry is cleared
        jmp @noteOffsetApplied

@signMagnitudeIsPositive:
        tya
        clc
        adc musicDataNoteTableOffset
@noteOffsetApplied:
        tay
        lda noteToWaveTable+1,y
        sta musicStagingSq1Lo,x
        lda noteToWaveTable,y
        ora #$08
        sta musicStagingSq1Hi,x
; Complicated way to determine if we skipped setting lo/hi, maybe because of the needed pla. If we set lo/hi (by falling through from above), then we'll go to @loadVolume. If we jmp'ed here, then we'll end up muting the volume
@determineVolume:
        tay
        pla
        tax
        tya
        bne @loadVolume
        lda #$00
        sta AUDIOTMP1
        txa
        cmp #$02
        beq @checkChanControl
        lda #$10
        sta AUDIOTMP1
        bne @checkChanControl
;
@loadVolume:
        lda musicChanVolume,x
        sta AUDIOTMP1
; If any of 5 low bits of control is non-zero, then mute
@checkChanControl:
        txa
        dec musicChanInhibit,x
        cmp musicChanInhibit,x
        beq @channelInhibited
        inc musicChanInhibit,x
        ldy musicChannelOffset
        txa
        cmp #$02
        beq @useDirectVolume
        lda musicChanControl,x
        and #$1F
        beq @useDirectVolume
        lda AUDIOTMP1
        cmp #$10
        beq @setMmio
        and #$F0
        ora #$00
        bne @setMmio
@useDirectVolume:
        lda AUDIOTMP1
@setMmio:
        sta SQ1_VOL,y
        lda musicStagingSq1Sweep,x
        sta SQ1_SWEEP,y
        lda musicStagingSq1Lo,y
        sta SQ1_LO,y
        lda musicStagingSq1Hi,y
        sta SQ1_HI,y
@copyDurationToRemaining:
        lda musicChanNoteDuration,x
        sta musicChanNoteDurationRemaining,x
        jmp updateMusicFrame_incSlot

; Never triggered
@channelInhibited:
        inc musicChanInhibit,x
        jmp @copyDurationToRemaining

; input y: duration of 60Hz frames. TRI has no volume control. The volume MMIO for TRI goes to a linear counter. While the length counter can be disabled, that doesn't appear possible for the linear counter.
@applyDurationForTri:
        lda musicChanControl+2
        and #$1F
        bne @setTriVolume
        lda musicChanControl+2
        and #$C0
        bne @highCtrlImpliesOn
@useDuration:
        tya
        bne @durationToLinearClock
@highCtrlImpliesOn:
        cmp #$C0
        beq @useDuration
        lda #$FF
        bne @setTriVolume
; Not quite clear what the -1 is for. Times 4 because the linear clock counts quarter frames
@durationToLinearClock:
        clc
        adc #$FF
        asl a
        asl a
        cmp #$3C
        bcc @setTriVolume
        lda #$3C
@setTriVolume:
        sta musicChanVolume+2
        jmp @loadNextAsNote

@playDmcAndNoise:
        tya
        pha
        jsr playDmc
        pla
        and #$3F
        tay
        jsr playNoise
        jmp @copyDurationToRemaining

; Weird that it references slot 0. Slot 3 would make most sense as NOISE channel and slot 1 would make sense if the point was to avoid noise during a sound effect. But slot 0 isn't used very often
playNoise:
        lda soundEffectSlot0Playing
        bne @ret
        lda noises_table,y
        sta NOISE_VOL
        lda noises_table+1,y
        sta NOISE_LO
        lda noises_table+2,y
        sta NOISE_HI
@ret:
        rts

playDmc:
        tya
        and #$C0
        cmp #$40
        beq @loadDmc0
        cmp #$80
        beq @loadDmc1
        rts

; dmc0
@loadDmc0:
        lda #$0E
        sta AUDIOTMP2
        lda #$07
        ldy #$00
        beq @loadIntoDmc
; dmc1
@loadDmc1:
        lda #$0E
        sta AUDIOTMP2
        lda #$0F
        ldy #$02
; Note that bit 4 in SND_CHN is 0. That disables DMC. It enables all channels but DMC
@loadIntoDmc:
        sta DMC_LEN
        sty DMC_START
        lda $06F7
        bne @ret
        lda AUDIOTMP2
        sta DMC_FREQ
        lda #$0F
        sta SND_CHN
        lda #$00
        sta DMC_RAW
        lda #$1F
        sta SND_CHN
@ret:
        rts

; input x: music channel. output a: next value
musicGetNextInstructionByte:
        ldy musicDataChanInstructionOffset,x
        inc musicDataChanInstructionOffset,x
        lda (musicChanTmpAddr),y
        rts

; Instrument envelopes, listed as a series of nibbles corresponding to volume. $FF sustains the last volume, while $F0 releases
musicChanVolControlTable:
        .addr   LEA76
        .addr   LEA82
        .addr   LEA8B
        .addr   LEA91
        .addr   LEA9A
        .addr   LEAA2
        .addr   LEAA5
        .addr   LEAA8
        .addr   LEAAC
        .addr   LEABA
        .addr   LEAC7
        .addr   LEAD4
        .addr   LEADE
        .addr   LEAE8
        .addr   LEAF2
        .addr   LEAF7
        .addr   LEAFC
        .addr   LEB01
        .addr   LEB05
        .addr   LEB0A
        .addr   LEB0D
        .addr   LEB10
LEA76:
        .byte   $46,$89,$87,$76,$66,$55,$44,$33
        .byte   $22,$21,$11,$F0
LEA82:
        .byte   $86,$55,$44,$44,$31,$11,$11,$11
        .byte   $F0
LEA8B:
        .byte   $54,$43,$33,$22,$11,$F0
LEA91:
        .byte   $23,$45,$77,$66,$55,$44,$44,$44
        .byte   $FF
LEA9A:
        .byte   $32,$22,$22,$22,$22,$22,$22,$FF
LEAA2:
        .byte   $99,$81,$FF
LEAA5:
        .byte   $58,$71,$FF
LEAA8:
        .byte   $E7,$99,$81,$FF
LEAAC:
        .byte   $A8,$66,$55,$54,$43,$43,$32,$22
        .byte   $22,$21,$11,$11,$11,$F0
LEABA:
        .byte   $97,$65,$44,$33,$33,$33,$22,$22
        .byte   $11,$11,$11,$11,$F0
LEAC7:
        .byte   $65,$44,$44,$33,$22,$22,$11,$11
        .byte   $11,$11,$11,$11,$F0
LEAD4:
        .byte   $44,$33,$22,$22,$11,$11,$11,$11
        .byte   $11,$F0
LEADE:
        .byte   $22,$22,$11,$11,$11,$11,$11,$11
        .byte   $11,$F0
LEAE8:
        .byte   $97,$65,$32,$43,$21,$11,$32,$21
        .byte   $11,$FF
LEAF2:
        .byte   $D8,$76,$54,$32,$FF
LEAF7:
        .byte   $B8,$76,$53,$21,$FF
LEAFC:
        .byte   $85,$43,$21,$11,$FF
LEB01:
        .byte   $53,$22,$11,$FF
LEB05:
        .byte   $EB,$97,$53,$21,$FF
LEB0A:
        .byte   $A9,$91,$F0
LEB0D:
        .byte   $85,$51,$F0
LEB10:
        .byte   $63,$31,$F0
; Rounds slightly differently, but can use for reference: https://web.archive.org/web/20180315161431if_/http://www.freewebs.com:80/the_bott/NotesTableNTSC.txt
noteToWaveTable:
        ; $00: A1, rest, C2, Db2
        .dbyt   $07F0,$0000,$06AE,$064E
        ; $08: D2, Eb2, E2, F2
        .dbyt   $05F3,$059E,$054D,$0501
        ; $10: Gb2, G2, Ab2, A2
        .dbyt   $04B9,$0475,$0435,$03F8
        ; $18: Bb2, B2, C3, Db3
        .dbyt   $03BF,$0389,$0357,$0327
        ; $20: D3, Eb3, E3, F3
        .dbyt   $02F9,$02CF,$02A6,$0280
        ; $28: Gb3, G3, Ab3, A3
        .dbyt   $025C,$023A,$021A,$01FC
        ; $30: Bb3, B4, C4, Db4
        .dbyt   $01DF,$01C4,$01AB,$0193
        ; $38: D4, Eb4, E4, F4
        .dbyt   $017C,$0167,$0152,$013F
        ; $40: Gb4, G4, Ab4, A4
        .dbyt   $012D,$011C,$010C,$00FD
        ; $48: Bb4, B4, C5, Db5
        .dbyt   $00EE,$00E1,$00D4,$00C8
        ; $50: D5, Eb5, E5, F5
        .dbyt   $00BD,$00B2,$00A8,$009F
        ; $58: Gb5, G5, Ab5, A5
        .dbyt   $0096,$008D,$0085,$007E
        ; $60: Bb5, B5, C6, Db6
        .dbyt   $0076,$0070,$0069,$0063
        ; $68: D6, Eb6, E6, F6
        .dbyt   $005E,$0058,$0053,$004F
        ; $70: Gb6, G6, Ab6, A6
        .dbyt   $004A,$0046,$0042,$003E
        ; $78: Bb6, B6, C7, Db7
        .dbyt   $003A,$0037,$0034,$0031
        ; $80: D7, Eb7, E7, F7
        .dbyt   $002E,$002B,$0029,$0027
        ; $88: very high, Gb7, G7, Ab7
        .dbyt   $0001,$0024,$0022,$0020
        ; $90: A7, Bb7, B7, Eb8
        .dbyt   $001E,$001C,$001A,$000A
        ; $98: Ab8, Db8
        .dbyt   $0010,$0019

; 1/16  note, 1/8 note, 1/4 note, 1/2 note, full note, 3/8 note, 3/4 note, 3/16 note
noteDurationTable:
        ; 300 bpm
        .byte   $03,$06,$0C,$18,$30,$12,$24,$09
        .byte   $08,$04,$02,$01
        ; 225 bpm
        .byte   $04,$08,$10,$20,$40,$18,$30,$0C
        .byte   $0A,$05,$02,$01
        ; 180 bpm
        .byte   $05,$0A,$14,$28,$50,$1E,$3C,$0F
        .byte   $0D,$06,$02,$01
        ; 150 bpm
        .byte   $06,$0C,$18,$30,$60,$24,$48,$12
        .byte   $10,$08,$03,$01,$04,$02,$00,$90
        ; 128 bpm
        .byte   $07,$0E,$1C,$38,$70,$2A,$54,$15
        .byte   $12,$09,$03,$01,$02
        ; 112 bpm
        .byte   $08,$10,$20,$40,$80,$30,$60,$18
        .byte   $15,$0A,$04,$01,$02,$C0
        ; 100 bpm
        .byte   $09,$12,$24,$48,$90,$36,$6C,$1B
        .byte   $18
        ; 90 bpm
        .byte   $0A,$14,$28,$50,$A0,$3C,$78,$1E
        .byte   $1A,$0D,$05,$01,$02,$17
        ; 82 bpm
        .byte   $0B,$16,$2C,$58,$B0,$42,$84,$21
        .byte   $1D,$0E,$05,$01,$02,$17
musicDataTableIndex:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A

; First byte corresponds to a key offset that applies to all notes for each channel (excluding noise probably)
; Value of %0xxxxxxx adds xxxxxxx to each index, while %1xxxxxxx subtracts (xxxxxxx+1) to each index
; so $0A shifts each note up by 5 half steps and $83 shifts each note down 2 half steps (note table entries are 2 bytes)
; Second byte controls tempo, indexing into noteDurationTable
; Each table entry is written into musicDataNoteTableOffset
musicDataTable:
        .byte   $0A,$24
        .addr   music_titleScreen_sq1Script
        .addr   music_titleScreen_sq2Script
        .addr   music_titleScreen_triScript
        .addr   music_titleScreen_noiseScript
        .byte   $83,$00
        .addr   music_bTypeGoalAchieved_sq1Script
        .addr   music_bTypeGoalAchieved_sq2Script
        .addr   music_bTypeGoalAchieved_triScript
        .addr   music_bTypeGoalAchieved_noiseScript
        .byte   $81,$24
        .addr   music_music1_sq1Script
        .addr   music_music1_sq2Script
        .addr   music_music1_triScript
        .addr   music_music1_noiseScript
        .byte   $83,$24
        .addr   music_music2_sq1Script
        .addr   music_music2_sq2Script
        .addr   music_music2_triScript
        .addr   music_music2_noiseScript
        .byte   $81,$24
        .addr   music_music3_sq1Script
        .addr   music_music3_sq2Script
        .addr   music_music3_triScript
        .addr   LFFFF
        .byte   $81,$00
        .addr   music_music1_sq1Script
        .addr   music_music1_sq2Script
        .addr   music_music1_triScript
        .addr   music_music1_noiseScript
        .byte   $83,$0C
        .addr   music_music2_sq1Script
        .addr   music_music2_sq2Script
        .addr   music_music2_triScript
        .addr   music_music2_noiseScript
        .byte   $81,$0C
        .addr   music_music3_sq1Script
        .addr   music_music3_sq2Script
        .addr   music_music3_triScript
        .addr   LFFFF
        .byte   $00,$18
        .addr   music_congratulations_sq1Script
        .addr   music_congratulations_sq2Script
        .addr   music_congratulations_triScript
        .addr   music_congratulations_noiseScript
        .byte   $8F,$24
        .addr   music_endings_sq1Script
        .addr   music_endings_sq2Script
        .addr   music_endings_triScript
        .addr   music_endings_noiseScript
music_bTypeGoalAchieved_sq1Script:
        .addr   music_bTypeGoalAchieved_sq1Routine1
        .addr   tmp1
music_bTypeGoalAchieved_sq2Script:
        .addr   music_bTypeGoalAchieved_triRoutine1
music_bTypeGoalAchieved_triScript:
        .addr   music_bTypeGoalAchieved_sq2Routine1
music_bTypeGoalAchieved_noiseScript:
        .addr   music_bTypeGoalAchieved_noiseRoutine1
.include "audio/music/music_bTypeGoalAchieved.asm"
music_titleScreen_sq1Script:
        .addr   music_titleScreen_sq1Routine1
        .addr   tmp1
music_titleScreen_sq2Script:
        .addr   music_titleScreen_sq2Routine1
music_titleScreen_triScript:
        .addr   music_titleScreen_triRoutine1
music_titleScreen_noiseScript:
        .addr   music_titleScreen_noiseRoutine1
        .addr   LFFFF
        .addr   music_titleScreen_noiseScript
.include "audio/music/music_titlescreen.asm"

; Only 256 bytes can be accessed at a time due to relative addressing, so the various routine addresses are like checkpoints in the music.
music_music1_sq1Script:
        .addr   music_music1_sq1Routine1
        .addr   music_music1_sq1Routine2
        .addr   music_music1_sq1Routine3
        .addr   LFFFF
        .addr   music_music1_sq1Script
music_music1_sq2Script:
        .addr   music_music1_sq2Routine1
        .addr   music_music1_sq2Routine2
        .addr   music_music1_sq2Routine3
        .addr   LFFFF
        .addr   music_music1_sq2Script
music_music1_triScript:
        .addr   music_music1_triRoutine1
        .addr   music_music1_triRoutine2
        .addr   music_music1_triRoutine3
        .addr   LFFFF
        .addr   music_music1_triScript
music_music1_noiseScript:
        .addr   music_music1_noiseRoutine1
        .addr   LFFFF
        .addr   music_music1_noiseScript
.include "audio/music/music1.asm"
music_music3_sq1Script:
        .addr   music_music3_sq1Routine1
music_music3_sq1ScriptLoop:
        .addr   music_music3_sq1Routine2
        .addr   LFFFF
        .addr   music_music3_sq1ScriptLoop
music_music3_sq2Script:
        .addr   music_music3_sq2Routine1
        .addr   LFFFF
        .addr   music_music3_sq2Script
music_music3_triScript:
        .addr   music_music3_triRoutine1
        .addr   LFFFF
        .addr   music_music3_triScript
; unreferenced
music_music3_noiseScript:
        .addr   music_music3_noiseRoutine1
        .addr   LFFFF
        .addr   music_music3_noiseScript
.include "audio/music/music3.asm"
music_congratulations_sq1Script:
        .addr   music_congratulations_sq1Routine1
        .addr   LFFFF
        .addr   music_congratulations_sq1Script
music_congratulations_sq2Script:
        .addr   music_congratulations_sq2Routine1
        .addr   LFFFF
        .addr   music_congratulations_sq2Script
music_congratulations_triScript:
        .addr   music_congratulations_triRoutine1
        .addr   LFFFF
        .addr   music_congratulations_triScript
music_congratulations_noiseScript:
        .addr   music_congratulations_noiseRoutine1
        .addr   LFFFF
        .addr   music_congratulations_noiseScript
.include "audio/music/music_congratulations.asm"
music_music2_sq1Script:
        .addr   music_music2_sq1Routine1
        .addr   music_music2_sq1Routine2
        .addr   music_music2_sq1Routine3
        .addr   music_music2_sq1Routine3
        .addr   music_music2_sq1Routine4
        .addr   LFFFF
        .addr   music_music2_sq1Script
music_music2_sq2Script:
        .addr   music_music2_sq2Routine1
        .addr   music_music2_sq2Routine2
        .addr   music_music2_sq2Routine3
        .addr   music_music2_sq2Routine3
        .addr   music_music2_sq2Routine4
        .addr   LFFFF
        .addr   music_music2_sq2Script
music_music2_triScript:
        .addr   music_music2_triRoutine1
        .addr   music_music2_triRoutine2
        .addr   music_music2_triRoutine3
        .addr   music_music2_triRoutine3
        .addr   music_music2_triRoutine4
        .addr   LFFFF
        .addr   music_music2_triScript
music_music2_noiseScript:
        .addr   music_music2_noiseRoutine1
        .addr   LFFFF
        .addr   music_music2_noiseScript
.include "audio/music/music2.asm"
music_endings_sq1Script:
        .addr   music_endings_sq1Routine1
        .addr   music_endings_sq1Routine2
        .addr   music_endings_sq1Routine1
        .addr   music_endings_sq1Routine3
        .addr   LFFFF
        .addr   music_endings_sq1Script
music_endings_sq2Script:
        .addr   music_endings_sq2Routine1
        .addr   music_endings_sq2Routine2
        .addr   music_endings_sq2Routine1
        .addr   music_endings_sq2Routine3
        .addr   LFFFF
        .addr   music_endings_sq2Script
music_endings_triScript:
        .addr   music_endings_triRoutine1
        .addr   music_endings_triRoutine2
        .addr   music_endings_triRoutine1
        .addr   music_endings_triRoutine3
        .addr   LFFFF
        .addr   music_endings_triScript
music_endings_noiseScript:
        .addr   music_endings_noiseRoutine1
        .addr   music_endings_noiseRoutine1
        .addr   music_endings_noiseRoutine1
        .addr   music_endings_noiseRoutine2
        .addr   LFFFF
        .addr   music_endings_noiseScript
.include "audio/music/music_endings.asm"

height_menu_nametablepalette_patch:
        .byte   $3F,$0A,$01,$16 ; palette

        .byte   $20,$6D,$01,$0A ; "A"
        .byte   $28,$6D,$01,$0A ; "A"

        .byte   $20,$F3,$48,$FF ; patch upper nt
        .byte   $21,$13,$48,$FF
        .byte   $21,$33,$48,$FF
        .byte   $21,$53,$47,$FF
        .byte   $21,$73,$47,$FF
        .byte   $21,$93,$47,$FF
        .byte   $21,$B3,$47,$FF
        .byte   $21,$D3,$47,$FF

        .byte   $28,$F3,$48,$FF ; patch lower nt
        .byte   $29,$13,$48,$FF
        .byte   $29,$33,$48,$FF
        .byte   $29,$53,$47,$FF
        .byte   $29,$73,$47,$FF
        .byte   $29,$93,$47,$FF
        .byte   $29,$B3,$47,$FF
        .byte   $29,$D3,$47,$FF

        ;.byte   $22,$33,$48,$FF ; from original game, useless
        ;.byte   $22,$53,$48,$FF
        ;.byte   $22,$73,$48,$FF
        ;.byte   $22,$93,$47,$FF
        ;.byte   $22,$B3,$47,$FF
        ;.byte   $22,$D3,$47,$FF
        ;.byte   $22,$F3,$47,$FF
        ;.byte   $23,$13,$47,$FF

        .byte   $FF
setOrientationTable:
        tax
        lda orientationTiles,x
        sta currentTile
        txa
        asl
        tax
        lda orientationTablesY,x
        sta currentOrientationY
        lda orientationTablesX,x
        sta currentOrientationX
        inx
        lda orientationTablesY,x
        sta currentOrientationY+1
        lda orientationTablesX,x
        sta currentOrientationX+1
        rts

generateNextPseudoAndAlsoBSeed:
        jsr generateNextPseudorandomNumber
        ldx #bseed
        ldy #$02
        jmp generateNextPseudorandomNumber

generateNextPseudoAndAlsoCopy:
        jsr generateNextPseudorandomNumber
        ldx bSeedSource
        lda tmp1,x
        sta bseedCopy
        rts

; 0 Arr code by Kirby703
checkFor0Arr:
        lda anydasARRValue
        beq @zeroArr
        jmp buttonHeldDown
@zeroArr:
        lda heldButtons
        and #BUTTON_RIGHT
        beq @checkLeftPressed
@shiftRight:
        inc tetriminoX
        jsr isPositionValid
        bne @shiftBackToLeft
        lda #$03
        sta soundEffectSlot1Init
        jmp @shiftRight
@checkLeftPressed:
        lda heldButtons
        and #BUTTON_LEFT
        beq @leftNotPressed
@shiftLeft:
        dec tetriminoX
        jsr isPositionValid
        bne @shiftBackToRight
        lda #$03
        sta soundEffectSlot1Init
        jmp @shiftLeft
@shiftBackToLeft:
        dec tetriminoX
        dec tetriminoX
@shiftBackToRight:
        inc tetriminoX
        lda #$01
        sta autorepeatX
@leftNotPressed:
        rts


menuThrottle:
        ; add DAS-like movement to the menu
        sta menuThrottleTmp
        lda newlyPressedButtons_player1
        cmp menuThrottleTmp
        beq menuThrottleNew
        lda heldButtons_player1
        cmp menuThrottleTmp
        bne @endThrottle
        dec menuMoveThrottle
        beq menuThrottleContinue
@endThrottle:
        lda #0
        rts

menuThrottleStart := $10
menuThrottleRepeat := $4
menuThrottleNew:
        lda #menuThrottleStart
        sta menuMoveThrottle
        rts
menuThrottleContinue:
        lda #menuThrottleRepeat
        sta menuMoveThrottle
        rts
; End of "PRG_chunk2" segment

; xxxxx12345xxxx
; xxxxxx678xxxxx
; xxxxxx9ABxxxxx

stageSpawnAreaTiles:
        lda $0405
        sta spawnRow1Data
        lda $0406
        sta spawnRow1Data+1
        lda $0500
        sta spawnRow1Data+2
        lda $0501
        sta spawnRow1Data+3
        lda $0502
        sta spawnRow1Data+4
        lda $040D
        sta spawnRow2Data
        lda $0507
        sta spawnRow2Data+1
        lda $0508
        sta spawnRow2Data+2
        lda $0414
        sta spawnRow3Data
        lda $050E
        sta spawnRow3Data+1
        lda $050F
        sta spawnRow3Data+2
        rts

resetPauseScreenThenUpdateAudio2:
    lda #$00
    sta pauseScreen
    jmp updateAudio2

.code


.segment        "unreferenced_data4": absolute

; .include "data/unreferenced_data4.asm"

; End of "unreferenced_data4" segment
.code


.segment        "PRG_chunk3": absolute

; incremented to reset MMC1 reg
reset:
        cld
        sei
        ldx #$00
        stx PPUCTRL
        stx PPUMASK
@vsyncWait1:
        lda PPUSTATUS
        bpl @vsyncWait1
@vsyncWait2:
        lda PPUSTATUS
        bpl @vsyncWait2
        dex
        txs
.ifdef CNROM
        lda #CNROM_BANK0
        ldy #CNROM_BG0
        ldx #CNROM_SPRITE0
        jsr changeCHRBank
.else
        inc reset
        lda #$13
        jsr setMMC1Control
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        lda #$00
        jsr changePRGBank
.endif
        jmp initRam

; .include "data/unreferenced_data5.asm"


; End of "PRG_chunk3" segment
.code


.segment        "VECTORS": absolute

        .addr   nmi
        .addr   reset
        .addr   irq

; End of "VECTORS" segment
.code
