


import sys
from pprint import pprint
from orientations import table, weight_table
from orientation_base import output_bytes, validate_table
import random


assembly = """
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
        jsr     @realStart
        rts

@realStart:
        ldx     #${}
        inc     spawnCount
        lda     rng_seed
        clc
        adc     spawnCount
@nextPiece:
        cmp     weightTable,x
        bcs     @foundPiece
        dex
        bmi     @foundPiece
        jmp     @nextPiece
@foundPiece:
        inx
        lda     spawnTable,x
        sta     spawnID
        rts

"""


output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False

validate_table(table)

weights = sorted([(name, value) for name,value in weight_table.items()],key=lambda name_value: name_value[0].name)

indexed_weights = list(zip([weight[1] for weight in weights], table.indexes()))
pprint(indexed_weights)

for repeat,index in indexed_weights:
    print(repeat,index)

validation = sum(repeats for repeats,index in indexed_weights)
if validation != 256:
    sys.exit(f"Piece ID repeats must add up to 256.  This adds up to {validation}")

weight_list = []
for piece in table.pieces:
    if piece.hidden:
        continue
    weight_list.append(weight_table[piece])

table = []
current_total = 0
for weight in weight_list:
    print(weight)
    current_total+=weight
    table.append(current_total)

table.pop()



try:
    file = open(output, "w+") if output else sys.stdout
    print(assembly.format(f"{len(weight_list)-2:02x}"), file=file)
    print( "weightTable:", file=file)
    for i in range(0,len(weight_list)-1,8):
        print("    .byte  " + ",".join(f"${j:02x}" for j in table[i:i+8]), file=file)
    print("", file=file)
finally:
    if output:
        file.close()
