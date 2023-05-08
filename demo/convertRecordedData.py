import re

data = open("demo_data.txt").read()
moves = re.findall(r"\w+", data)

for i in range(0, len(moves), 8):
    move_row = [f"${moves[i+j]}" for j in range(8)]
    print("        .byte   " + ",".join(move_row))
