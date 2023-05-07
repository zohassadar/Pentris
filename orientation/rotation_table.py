import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)

piece_indexes = {}
i = 0
for piece in table.pieces:
    if piece.hidden:
        continue
    for orientation in piece.orientations:
        piece_indexes[orientation] = i
        i += 1


output_rows = []
for piece in table.pieces:
    if piece.hidden:
        continue
    orientation_length = len(piece.orientations)
    output_row = []
    for i, orientation in enumerate(piece.orientations):
        if not i:
            previous = piece.orientations[-1]
        else:
            previous = piece.orientations[i - 1]
        if i == orientation_length - 1:
            next_ = piece.orientations[0]
        else:
            next_ = piece.orientations[i + 1]
        output_row.append(piece_indexes[previous])
        output_row.append(piece_indexes[next_])
    output_rows.append(output_row)


try:
    file = open(output, "w+") if output else sys.stdout
    for output_row in output_rows:
        print(output_bytes(output_row), file=file)
    print("", file=file)
finally:
    if output:
        file.close()
