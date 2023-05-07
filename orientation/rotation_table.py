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


previous_rows = []
next_rows = []
for piece in table.pieces:
    if piece.hidden:
        continue
    orientation_length = len(piece.orientations)
    previous_row = []
    next_row = []
    for i, orientation in enumerate(piece.orientations):
        if not i:
            previous = piece.orientations[-1]
        else:
            previous = piece.orientations[i - 1]
        if i == orientation_length - 1:
            next_ = piece.orientations[0]
        else:
            next_ = piece.orientations[i + 1]
        previous_row.append(piece_indexes[previous])
        next_row.append(piece_indexes[next_])
    previous_rows.append(previous_row)
    next_rows.append(next_row)


try:
    file = open(output, "w+") if output else sys.stdout
    print(f"rotationTablePrevious:", file=file)
    for previous_row in previous_rows:
        print(output_bytes(previous_row), file=file)
    print(f"rotationTableNext:", file=file)
    for next_row in next_rows:
        print(output_bytes(next_row), file=file)
    print("", file=file)
finally:
    if output:
        file.close()
