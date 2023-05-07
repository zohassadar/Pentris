import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)
output_lines = []
for piece in table.pieces:
    for orientation in piece.orientations:
        output_row = []
        for y, row in orientation.groups():
            for x, tile in row:
                y_ = orientation.index_map[y]
                x_ = orientation.index_map[x]
                if tile:
                    output_row.extend((y_, piece.tile_index, x_))
        output_lines.append(output_bytes(output_row))

try:
    file = open(output, "w+") if output else sys.stdout
    for line in output_lines:
        print(line, file=file)
    print("", file=file)
finally:
    if output:
        file.close()
