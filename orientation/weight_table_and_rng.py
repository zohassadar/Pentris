


import sys
from pprint import pprint
from orientations import table, weight_table
from orientation_base import output_bytes, validate_table
import random

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
for repeat,id in indexed_weights:
    for _ in range(repeat):
        weight_list.append(id)

# this is shitty and will be replaced
random.shuffle(weight_list)


try:
    file = open(output, "w+") if output else sys.stdout
    print( "pieceDistributionTable:", file=file)
    for i in range(0,256,8):
        print("    .byte  " + ",".join(f"${j:02x}" for j in weight_list[i:i+8]), file=file)
    print("", file=file)
finally:
    if output:
        file.close()
