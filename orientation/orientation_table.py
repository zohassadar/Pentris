import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)
output_xs = []
output_ys = []
output_tiles = []
for piece in table.pieces:
    for orientation in piece.orientations:
        output_x = []
        output_y = []
        output_tile = []
        for y, row in orientation.groups():
            for x, tile in row:
                y_ = orientation.index_map[y]
                x_ = orientation.index_map[x]
                if tile:
                    output_x.append(x_)
                    output_y.append(y_)
                    output_tile.append(piece.tile_index)
        output_xs.append(output_bytes(output_x))
        output_ys.append(output_bytes(output_y))
        output_tiles.append(output_bytes(output_tile))

try:
    file = open(output, "w+") if output else sys.stdout
    print("orientationTableY:", file=file)
    for line in output_ys:
        print(line, file=file)
    print("", file=file)

    print("orientationTableX:", file=file)
    for line in output_xs:
        print(line, file=file)
    print("", file=file)

    print("orientationTableTile:", file=file)
    for line in output_tiles:
        print(line, file=file)
    print("", file=file)

finally:
    if output:
        file.close()
