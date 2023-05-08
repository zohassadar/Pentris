import random

for i in range(0, 256, 8):
    random_row = [f"${random.randint(0,17):02x}" for _ in range(8)]
    print("        .byte   " + ",".join(random_row))
