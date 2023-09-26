import sys
from pprint import pprint
from orientations import table
from orientation_base import output_bytes, validate_table

output = __file__.replace(".py", ".asm")
if len(sys.argv) > 1:
    output = False


validate_table(table)

stats_addresses = [piece.stats_addr for piece in table.pieces if not piece.hidden]

try:
    file = open(output, "w+") if output else sys.stdout
    print ("pieceToPpuStatAddr:", file=file)
    print (f"    .dbyt    {','.join(f'${sa:04x}' for sa in stats_addresses)}", file=file)
    print("", file=file)
finally:
    if output:
        file.close()
