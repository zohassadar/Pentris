.zeropage
tmp1:	.res 1	; $0000
tmp2:	.res 1	; $0001
tmp3:	.res 1	; $0002
.res 2 
tmpBulkCopyToPpuReturnAddr: .res 1 ; $0005
.res 14
patchToPpuAddr: .res 1             ; $0014
.res 2
rng_seed:	.res 2	; $0017
spawnID:	.res 1	; $0019
spawnCount:	.res 1	; $001A
.res 24
verticalBlankingInterval:	.res 1	; $0033
unused_0E: .res 1 ; $0034
.res 11
tetriminoX:	.res 1	; $0040
tetriminoY:	.res 1	; $0041
currentPiece:	.res 1	; $0042
.res 1
levelNumber:	.res 1	; $0044
fallTimer:	.res 1	; $0045
autorepeatX:	.res 1	; $0046
startLevel:	.res 1	; $0047
playState:	.res 1	; $0048
vramRow:	.res 1	; $0049
.res 4
autorepeatY:	.res 1	; $004E
holdDownPoints:	.res 1	; $004F
lines:	.res 2	; $0050
rowY:	.res 1	; $0052
score:	.res 3	; $0053
completedLines:	.res 1	; $0056
lineIndex:	.res 1	; $0057
curtainRow:	.res 1	; $0058
startHeight:	.res 1	; $0059
garbageHole:	.res 1	; $005A
.res 5
completedRow:	.res 5	; $0060
currentOrientationY: .res 2 ;  $0065
currentOrientationX: .res 2 ;  $0067
currentOrientationTile: .res 2 ;  $0069
statsPatchAddress:  .res 2 ;  $006B
topRowValidityCheck: .res 1 ;  $006D
statsPiecesTotal: .res 2  ; $006E
effectiveTetriminoX:  .res 1 ; $0070
renderedVramRow:  .res 1 ; $0071
renderedPlayfield:  .res 1 ; $0072
pauseScreen: .res 1
stackPointer: .res 1
.res 43

spriteXOffset:	.res 1	; $00A0
spriteYOffset:	.res 1	; $00A1
spriteIndexInOamContentLookup:	.res 1	; $00A2
outOfDateRenderFlags: .res 1 ; $00A3
twoPlayerPieceDelayCounter: .res 1 ; $00A4
twoPlayerPieceDelayPlayer: .res 1 ; $00A5
twoPlayerPieceDelayPiece:	.res 1	; $00A6
gameModeState:	.res 1	; $00A7
generalCounter:	.res 1	; $00A8
generalCounter2:	.res 1	; $00A9
generalCounter3:	.res 1	; $00AA
generalCounter4:	.res 1	; $00AB
generalCounter5:	.res 1	; $00AC
selectingLevelOrHeight:	.res 1	; $00AD
originalY:	.res 1	; $00AE
dropSpeed:	.res 1	; $00AF
tmpCurrentPiece: .res 1 ; $00B0
frameCounter:	.res 2	; $00B1
oamStagingLength:	.res 1	; $00B3
.res 1
newlyPressedButtons:	.res 1	; $00B5
heldButtons:	.res 1	; $00B6
activePlayer:	.res 1	; $00B7
playfieldAddr:	.res 2	; $00B8
allegro: .res 1 ; $00BA
pendingGarbage:	.res 1	; $00BB
pendingGarbageInactivePlayer:	.res 1	; $00BC
renderMode:	.res 1	; $00BD
 .res 1	; $00BE
nextPiece:	.res 1	; $00BF
gameMode:	.res 1	; $00C0
gameType:	.res 1	; $00C1
musicType:	.res 1	; $00C2
sleepCounter:	.res 1	; $00C3
ending:	.res 1	; $00C4
ending_customVars:	.res 1	; $00C5
.res 6
ending_currentSprite: .res 1 ;$00CC
ending_typeBCathedralFrameDelayCounter: .res 1 ; $00CD
demo_heldButtons:	.res 1	; $00CE
demo_repeats:	.res 1	; $00CF
.res 1
demoButtonsAddr:	.res 1	; $00D1
demoButtonsTable_indexOverflowed:	.res 1	; $00D2
demoIndex:	.res 1	; $00D3
highScoreEntryNameOffsetForLetter:	.res 1	; $00D4
highScoreEntryRawPos:	.res 1	; $00D5
highScoreEntryNameOffsetForRow:	.res 1	; $00D6
highScoreEntryCurrentLetter:	.res 1	; $00D7
lineClearStatsByType:	.res 4	; $00D8

totalScore: .res 3 ; $00DC
displayNextPiece:	.res 1	; $00DF
AUDIOTMP1:	.res 1	; $00E0
AUDIOTMP2:	.res 1	; $00E1
AUDIOTMP3:	.res 1	; $00E2
AUDIOTMP4:	.res 1	; $00E3
AUDIOTMP5:	.res 1	; $00E4
.res 1
musicChanTmpAddr:	.res 2	; $00E6
.res 2
music_unused2: .res 1  ; $00EA
soundRngSeed: .res 2  ; $00EB
currentSoundEffectSlot:	.res 1	; $00ED
musicChannelOffset:	.res 1	; $00EE
currentAudioSlot:	.res 1	; $00EF
.res 1
unreferenced_buttonMirror:  .res 3  ; $00F1
.res 1
newlyPressedButtons_player1:	.res 1	; $00F5
newlyPressedButtons_player2:	.res 1	; $00F6
heldButtons_player1:	.res 1	; $00F7
heldButtons_player2: .res 1 ; $00F8
.res 2
joy1Location:	.res 1	; $00FB
ppuScrollY: .res 1 ; $00FC
ppuScrollX: .res 1 ; $00FD
currentPpuMask:	.res 1	; $00FE
currentPpuCtrl:	.res 1	; $00FF

.bss
stack:
oldPiece0Address: .res $2
oldPiece0Data: .res $1
oldPiece1Address: .res $2
oldPiece1Data: .res $1
oldPiece2Address: .res $2
oldPiece2Data: .res $1
oldPiece3Address: .res $2
oldPiece3Data: .res $1
oldPiece4Address: .res $2
oldPiece4Data: .res $1
newPiece0Address: .res $2
newPiece0Data: .res $1
newPiece1Address: .res $2
newPiece1Data: .res $1
newPiece2Address: .res $2
newPiece2Data: .res $1
newPiece3Address: .res $2
newPiece3Data: .res $1
newPiece4Address: .res $2
newPiece4Data: .res $1
row0Address: .res $2
row0Data: .res $E
row1Address: .res $2
row1Data: .res $E
row2Address: .res $2
row2Data: .res $E
row3Address: .res $2
row3Data: .res $E
row4Address: .res $2
row4Data: .res $E
scoreAddress: .res $2
scoreData: .res $6
linesAddress: .res $2
linesData: .res $3
levelAddress: .res $2
levelData: .res $2
paletteAddress: .res $2
paletteData: .res $20
.res $5F
oamStaging:	.res $100	; $0200
statsByType:	.res $100	; $0300
leftPlayfield:	.res $C8	; $0400
.res 56
rightPlayfield:	.res $C8	; $0500
.res 184
musicStagingSq1Lo:	.res 1	; $0680
musicStagingSq1Hi:	.res 1	; $0681
audioInitialized:	.res 1	; $0682
musicPauseSoundEffectLengthCounter: .res 1 ; $0683
musicStagingSq2Lo:	.res 1	; $0684
musicStagingSq2Hi:	.res 1	; $0685
.res 2
musicStagingTriLo:	.res 1	; $0688
musicStagingTriHi:	.res 1	; $0689
resetSq12ForMusic:	.res 1	; $068A
musicPauseSoundEffectCounter: .res 1 ; $068B
musicStagingNoiseLo:	.res 1	; $068C
musicStagingNoiseHi:	.res 1	; $068D
.res 2
musicDataNoteTableOffset:	.res 1	; $0690
musicDataDurationTableOffset:	.res 1	; $0691
musicDataChanPtr:	.res $08	; $0692
musicChanControl:	.res $03	; $069A
musicChanVolume:	.res $03	; $069D
musicDataChanPtrDeref:	.res $08	; $06A0
musicDataChanPtrOff:	.res $04	; $06A8
musicDataChanInstructionOffset:	.res $04	; $06AC
musicDataChanInstructionOffsetBackup:	.res $04	; $06B0
musicChanNoteDurationRemaining:	.res $04	; $06B4
musicChanNoteDuration:	.res $04	; $06B8
musicChanProgLoopCounter:	.res $04	; $06BC
musicStagingSq1Sweep:	.res $02	; $06C0
.res 1
musicChanNote:  .res 4  ; $06C3
.res 1
musicChanInhibit:	.res $03	; $06C8
.res 1
musicTrack_dec:	.res 1	; $06CC
musicChanVolFrameCounter:	.res $04	; $06CD
musicChanLoFrameCounter:	.res $04	; $06D1
soundEffectSlot0FrameCount:	.res 5	; $06D5
soundEffectSlot0FrameCounter:	.res 5	; $06DA
soundEffectSlot0SecondaryCounter:	.res 1	; $06DF
soundEffectSlot1SecondaryCounter:	.res 1	; $06E0
soundEffectSlot2SecondaryCounter:	.res 1	; $06E1
soundEffectSlot3SecondaryCounter:	.res 1	; $06E2
soundEffectSlot0TertiaryCounter:	.res 1	; $06E3
soundEffectSlot1TertiaryCounter:	.res 1	; $06E4
soundEffectSlot2TertiaryCounter:	.res 1	; $06E5
soundEffectSlot3TertiaryCounter:	.res 1	; $06E6
soundEffectSlot0Tmp:	.res 1	; $06E7
soundEffectSlot1Tmp:	.res 1	; $06E8
soundEffectSlot2Tmp:	.res 1	; $06E9
soundEffectSlot3Tmp:	.res 1	; $06EA
.res 5
soundEffectSlot0Init:	.res 1	; $06F0
soundEffectSlot1Init:	.res 1	; $06F1
soundEffectSlot2Init:	.res 1	; $06F2
soundEffectSlot3Init:	.res 1	; $06F3
soundEffectSlot4Init:	.res 1	; $06F4
musicTrack:	.res 1	; $06F5
.res 2
soundEffectSlot0Playing:	.res 1	; $06F8
soundEffectSlot1Playing:	.res 1	; $06F9
soundEffectSlot2Playing:	.res 1	; $06FA
soundEffectSlot3Playing:	.res 1	; $06FB
soundEffectSlot4Playing:	.res 1	; $06FC
currentlyPlayingMusicTrack:	.res 1	; $06FD
.res 1
unreferenced_soundRngTmp:  .res 1  ; $06FF
highScoreNames:	.res $30	; $0700
highScoreScoresA:	.res $C	; $0730
highScoreScoresB:	.res $C	; $073C
highScoreLevels:	.res $08	; $0748
initMagic:	.res $05	; $0750
