"""
https://github.com/shiromino/shiromino/blob/master/src/random.cc
"""
import random
import sys

# This is based off of the weight defined in the code referenced above
weight_table = {
    "I": (17,25),
    "J": (2,16),
    "L": (3,16),
    "X": (4,3),
    "S": (5,9),
    "Z": (6,9),
    "N": (9,18),
    "G": (10,18),
    "U": (12,16),
    "T": (11,11),
    "F1": (0,5),
    "F2": (1,5),
    "P": (7,27),
    "Q": (8,27),
    "W": (14,10),
    "Y1": (15,16),
    "Y2": (16,16),
    "V": (13,9),
}

validation = sum(repeats for id,repeats in weight_table.values())
if validation != 256:
    sys.exit(f"Piece ID repeats must add up to 256")

weight_list = []
for name, (id, repeat) in weight_table.items():
    for _ in range(repeat):
        weight_list.append(id)

random.shuffle(weight_list)

for i in range(0,256,8):
    print("    .byte  " + ",".join(f"${j:02x}" for j in weight_list[i:i+8]))

sys.exit()



# The following code is what was used to make the above table

import re
from pprint import pprint
from math import ceil, floor

weights = """#define QRS_I_WEIGHT 1.2
#define QRS_J_WEIGHT 0.8
#define QRS_L_WEIGHT 0.8
#define QRS_X_WEIGHT 0.18
#define QRS_S_WEIGHT 0.4
#define QRS_Z_WEIGHT 0.4
#define QRS_N_WEIGHT 0.9
#define QRS_G_WEIGHT 0.9
#define QRS_U_WEIGHT 0.8
#define QRS_T_WEIGHT 0.55
#define QRS_Fa_WEIGHT 0.26
#define QRS_Fb_WEIGHT 0.26
#define QRS_P_WEIGHT 1.3
#define QRS_Q_WEIGHT 1.3
#define QRS_W_WEIGHT 0.45
#define QRS_Ya_WEIGHT 0.75
#define QRS_Yb_WEIGHT 0.75
#define QRS_V_WEIGHT 0.4"""


names = re.findall(r"_([a-z]+)_", weights, re.I)


flt_strs = re.findall(r"\d\.\d+", weights)
flts = [float(f) for f in flt_strs]
total = sum(flts)
multiplier = 256 / total


floors = [floor(f * multiplier) for f in flts]
print(f"{floors=}")
print(f"{sum(floors)=}")

labeled = dict(zip(names, floors))

print(labeled)


