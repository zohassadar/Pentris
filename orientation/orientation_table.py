import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)

output_x_refs = []
output_y_refs = []
output_tile_refs = []

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
        xlabel = f"orientationXFor{orientation.name}"
        ylabel = f"orientationYFor{orientation.name}"
        tilelabel = f"orientationTileFor{orientation.name}"
        output_x_refs.append(f"    .addr {xlabel}")
        output_y_refs.append(f"    .addr {ylabel}")
        #output_tile_refs.append(f"    .addr {tilelabel}")

        # allow for 4 pieces (or less?)
        while len(output_x) < 5:
            output_x.append(output_x[-1])
        while len(output_y) < 5:
            output_y.append(output_y[-1])
        while len(output_tile) < 5:
            output_tile.append(output_tile[-1])

        output_xs.append(xlabel + ":")
        output_xs.append(output_bytes(output_x))
        output_ys.append(ylabel + ":")
        output_ys.append(output_bytes(output_y))
        #output_tiles.append(tilelabel + ":")
        output_tiles.append(f"{output_bytes(output_tile[:1])} ; {tilelabel}")

try:
    file = open(output, "w+") if output else sys.stdout
    # print("orientationTableY:", file=file)
    print("orientationTablesY:", file=file)
    for line in output_y_refs:
        print(line, file=file)
    print("", file=file)

    print("orientationTablesX:", file=file)
    for line in output_x_refs:
        print(line, file=file)
    print("", file=file)

    #print("orientationTablesTile:", file=file)
    #for line in output_tile_refs:
    #    print(line, file=file)
    #print("", file=file)

    for line in output_ys:
        print(line, file=file)
    print("", file=file)

    # print("orientationTableX:", file=file)
    for line in output_xs:
        print(line, file=file)
    print("", file=file)

    print("orientationTiles:", file=file)
    for line in output_tiles:
        print(line, file=file)
    print("", file=file)

finally:
    if output:
        file.close()
