import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)


next_x_offsets = []
next_y_offsets = []
next_spawn_offsets = []
for piece in table.pieces:
    if piece.hidden:
        continue
    next_x_offset = []
    next_y_offset = []
    next_spawn_offset = []
    for orientation in piece.orientations:
        next_x_offset.append(orientation.next_offset_x)
        next_y_offset.append(orientation.next_offset_y)
        next_spawn_offset.append(orientation.spawn_offset_y)
    next_x_offsets.append(next_x_offset)
    next_y_offsets.append(next_y_offset)
    next_spawn_offsets.append(next_spawn_offset)


try:
    file = open(output, "w+") if output else sys.stdout
    print(f"nextOffsetX:", file=file)
    for next_x_offset in next_x_offsets:
        print(output_bytes(next_x_offset), file=file)
    print("", file=file)
    print(f"nextOffsetY:", file=file)
    for next_y_offset in next_y_offsets:
        print(output_bytes(next_y_offset), file=file)
    print(f"spawnOffsets:", file=file)
    for next_spawn_offset in next_spawn_offsets:
        print(output_bytes(next_spawn_offset), file=file)
finally:
    if output:
        file.close()
