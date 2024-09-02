import sys
from pprint import pprint
from orientations import table, weight_table, weight_table_tetriminos
from orientation_base import output_bytes, validate_table
import random


assembly = """
initializeSPS:
        ; LLLLLLLL LLLLLLLS CCCCSSSS
        ; L = lsfr
        ; S = spawnCount
        ; C = starting shuffle count
        ldy    #rng_seed
        lda    validSeed
        beq    @ret
        ldy    #bseed
        sta    bSeedSource
        lda    sps_seed
        sta    set_seed
        sta    bseed
        lda    sps_seed+1
        sta    set_seed+1
        sta    bseed

        lsr    ; store unused lsfr bit to combine with lower nybble of sps_seed+2
        lda    #$00
        rol
        rol
        rol
        rol
        rol
        sta    generalCounter
        lda    sps_seed+2
        and    #$0F
        ora    generalCounter
        sta    spawnCount

        lda    sps_seed+2
        lsr
        lsr
        lsr
        lsr
        bne    @no16
        lda    #$10
@no16:
        clc
        adc    #$02
        sta    sps_shuffles ; 3 - 18
@ret:
        sty    bSeedSource
        rts

shuffleSPS:
        lda     rng_seed
        sta     currentRngByte
        lda     validSeed
        beq     @ret
        lda     sps_shuffles
        sta     generalCounter
@loop:
        ldx     #set_seed
        ldy     #$02
        jsr     generateNextPseudorandomNumber
        dec     generalCounter
        bne     @loop
        lda     set_seed
        sta     currentRngByte

; varying number of shuffles
        inc     sps_shuffles
        lda     sps_shuffles
        cmp     #$13
        bne     @ret
        lda     #$03
        sta     sps_shuffles
@ret:
        rts

rngInitYValues:
    .byte ${},${}

setupRngBytes:
        ; to be called from initGameState
        ldx     tetriminoMode
        lda     rngInitYValues,x
        sta     rngInitialY
        txa
        asl
        tax
        lda     weightTables,x
        sta     currentWeightTable
        lda     weightTables+1,x
        sta     currentWeightTable+1
        rts

chooseNextTetrimino:
        lda     gameMode
        cmp     #$05
        bne     pickRandomTetrimino
        ldx     demoIndex
        inc     demoIndex
        lda     demoTetriminoTypeTable,x
        tax
        lda     spawnTable,x
        rts

pickRandomTetrimino:
        jsr     shuffleSPS
        ldy     rngInitialY
        inc     spawnCount
        lda     currentRngByte
        clc
        adc     spawnCount
@nextPiece:
        cmp     (currentWeightTable),y
        bcs     @foundPiece
        dey
        bmi     @foundPiece
        jmp     @nextPiece
@foundPiece:
        iny
        lda     spawnTable,y
        sta     spawnID
        rts
"""

pento_table_indexes = table.indexes()[:-8] + table.indexes()[-1:]
output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False

validate_table(table)

weights = sorted(
    [(name, value) for name, value in weight_table.items()],
    key=lambda name_value: name_value[0].name,
)

weights_tetriminos = sorted(
    [(name, value) for name, value in weight_table_tetriminos.items()],
    key=lambda name_value: name_value[0].name,
)

indexed_weights = list(zip([weight[1] for weight in weights], pento_table_indexes))
indexed_weights_tetriminos = list(
    zip([weight[1] for weight in weights_tetriminos], table.indexes())
)
#pprint(indexed_weights)
#pprint(indexed_weights_tetriminos)

# for repeat, index in indexed_weights:
#    print(repeat, index)

validation = sum(repeats for repeats, index in indexed_weights)
if validation != 256:
    sys.exit(f"Piece ID repeats must add up to 256.  This adds up to {validation}")

validation = sum(repeats for repeats, index in indexed_weights_tetriminos)
if validation != 256:
    sys.exit(f"Piece ID repeats for tetriminos must add up to 256.  This adds up to {validation}")

weight_list_pentos = []
for piece in table.pieces[:-8] + table.pieces[-1:]:
    if piece.hidden:
        continue
    weight_list_pentos.append(weight_table[piece])

weight_list_tetriminos = []
for piece in table.pieces:
    if piece.hidden:
        continue
    weight_list_tetriminos.append(weight_table_tetriminos[piece])

table_pentos = []
current_total_pentos = 0
for weight in weight_list_pentos:
    current_total_pentos += weight
    table_pentos.append(current_total_pentos)

table_pentos.pop()

table_tetriminos = []
current_total_tetriminos = 0
for weight in weight_list_tetriminos:
    current_total_tetriminos += weight
    table_tetriminos.append(current_total_tetriminos)

table_tetriminos.pop()

try:
    file = open(output, "w+") if output else sys.stdout
    print(
        assembly.format(
            f"{len(weight_list_pentos)-2:02x}",
            f"{len(weight_list_tetriminos)-2:02x}",
        ),
        file=file,
    )
    print("weightTables:", file=file)
    print("    .addr  weightTable",file=file)
    print("    .addr  weightTableTetriminos\n",file=file)
    print("weightTable:", file=file)
    for i in range(0, len(weight_list_pentos) - 1, 8):
        print(
            "    .byte  " + ",".join(f"${j:02x}" for j in table_pentos[i : i + 8]),
            file=file,
        )
    print("", file=file)
    print("weightTableTetriminos:", file=file)
    for i in range(0, len(weight_list_tetriminos) - 1, 8):
        print(
            "    .byte  " + ",".join(f"${j:02x}" for j in table_tetriminos[i : i + 8]),
            file=file,
        )
    print("", file=file)
finally:
    if output:
        file.close()
