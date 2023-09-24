"""
The weights used are loosely based on the Pentomino weights from the following repository.  Original license included.

https://github.com/shiromino/shiromino/blob/master/src/random.cc

The MIT License (MIT)

Copyright © 2015-2022 The shiromino team

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
documentation files (the “Software”), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import random
import sys

# This is based off of the weight defined in the code referenced above
weight_table = {
    "I": (17,27),
    "J": (2,17),
    "L": (3,17),
    "X": (4,3),
    "S": (5,7),
    "Z": (6,7),
    "N": (9,18),
    "G": (10,18),
    "U": (12,16),
    "T": (11,12),
    "F1": (0,4),
    "F2": (1,4),
    "P": (7,27),
    "Q": (8,27),
    "W": (14,11),
    "Y1": (15,16),
    "Y2": (16,16),
    "V": (13,9),
}

validation = sum(repeats for id,repeats in weight_table.values())
if validation != 256:
    sys.exit(f"Piece ID repeats must add up to 256.  This adds up to {validation}")

weight_list = [repeat for id,repeat in sorted(weight_table.values())]

table = []
current_total = 0
for weight in weight_list:
    current_total+=weight
    table.append(current_total)

table.pop()

for i in range(0,17,8):
    print("    .byte  " + ",".join(f"${j:02x}" for j in table[i:i+8]))

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


