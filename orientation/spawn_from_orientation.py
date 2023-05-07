import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)

spawn_orientations = []
i = 0
for piece in table.pieces:
    if piece.hidden:
        continue
    for orientation in piece.orientations:
        if orientation.spawn:
            spawn_orientations.append(i)
        i += 1


output_rows = []
for piece_id, piece in enumerate(table.pieces):
    if piece.hidden:
        continue
    output_row = []
    for orientation in piece.orientations:
        output_row.append(spawn_orientations[piece_id])
    output_rows.append(output_row)


try:
    file = open(output, "w+") if output else sys.stdout
    for output_row in output_rows:
        print(output_bytes(output_row), file=file)
    print("", file=file)
finally:
    if output:
        file.close()
