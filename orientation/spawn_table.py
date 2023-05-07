import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)

output_row = []
i = 0
for piece in table.pieces:
    if piece.hidden:
        continue
    for orientation in piece.orientations:
        if orientation.spawn:
            output_row.append(i)
        i += 1


try:
    file = open(output, "w+") if output else sys.stdout
    print(output_bytes(output_row), file=file)
    print("", file=file)
finally:
    if output:
        file.close()
