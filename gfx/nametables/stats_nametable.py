import pathlib
import sys
import subprocess

import nametable_builder

"""
This script was originally generated by nametable_builder.py
Unless modified, it will reproduce the original.
"""

file = pathlib.Path(__file__)
output = file.parent / file.name.replace(".py", ".bin")

original_sha1sum = "9a041b43706f54b0dc0e8851c561f532a3289484"

characters = (
    #0123456789ABCDEF
    "0123456789ABCDEF" #0
    "GHIJKLMNOPQRSTUV" #1
    "WXYZ-,'╥┌━┐┇╏└╍┘" #2
    "ϝϞϟϠϡͰͱ┬╔╧╗╣╠╚╤╝" #3
    "wxyz╭▭╮╢╟╰▱╯├╪┤/" #4
    "┉=!@[]^Ë`{|}~¹()" #5
    "¼½¾¿ÀÁÂÃÄÅÆÇÈÉ‟." #6
    "ÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛ" #7
    "ÜÝÞßàáâãäåæçèéêë" #8
    "ìíîïðñòóôõö÷øùúû" #9
    "üýþÿЉЊЋЌЍЎЏАБВГД" #A
    "ЕЖЗИЙКЛМНОПРСТУФ" #B
    "ХЦЧШЩЪЫЬЭЮЯабвгд" #C
    "εζηθικλμνξοπρςστ" #D
    "υφχψωϊϋόύώϏϐϑϒϓϔ" #E
    "ϕϖϗϘϙ©ϛ_ghijklmn" #F
)  # fmt: skip

table = """
________________________________
________________________________
________________________________
___ghhhhhhhhhhhhhhhhhhhhhhhhi___
___j________ύώϏϐϑϒϓϔ________k___
___j________________________k___
___j________________________k___
___j____000_____000_____000_k___
___j________________________k___
___j________________________k___
___j____000_____000_____000_k___
___j________________________k___
___j________________________k___
___j____000_____000_____000_k___
___j________________________k___
___j________________________k___
___j____000_____000_____000_k___
___j________________________k___
___j________________________k___
___j____000_____000_____000_k___
___j________________________k___
___j________________________k___
___j____000_____000_____000_k___
___j________________________k___
___j__000___000___000___000_k___
___j________________________k___
___j____000___000___000_____k___
___j________________________k___
___lmmmmmmmmmmmmmmmmmmmmmmmmn___
________________________________

"""

attributes = """
3333333333333333
3333333333333333
3333333333333333
3322002200220033
3322002200220033
3322002200220033
3322002200220033
3322002200220033
3322002200220033
3322002200220033
3322002200220033
3322002200220033
3320020020020033
3302002002000033
3333333333333333
0000000000000000"""

lengths = [32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32]  # fmt: skip

starting_addresses = [(40, 0), (40, 32), (40, 64), (40, 96), (40, 128), (40, 160), (40, 192), (40, 224), (41, 0), (41, 32), (41, 64),
 (41, 96), (41, 128), (41, 160), (41, 192), (41, 224), (42, 0), (42, 32), (42, 64), (42, 96), (42, 128), (42, 160),
 (42, 192), (42, 224), (43, 0), (43, 32), (43, 64), (43, 96), (43, 128), (43, 160), (43, 192), (43, 224)]  # fmt: skip


rects = [
    (1, 6, 4, 3, 16),  # U
    (1, 9, 4, 3, 64),  # W
    (1, 12, 4, 3, 112),  # V
    (1, 15, 4, 3, 160),  # T
    (1, 18, 4, 3, 208),  # X
    (1, 22, 4, 1, 228),  # I
    (9, 6, 4, 3, 20),  # J
    (9, 9, 4, 3, 68),  # Y1
    (9, 12, 4, 3, 116),  # N1
    (9, 15, 4, 3, 164),  # F1
    (9, 18, 4, 3, 124),  # S
    (9, 21, 4, 3, 28),  # Q
    (17, 6, 4, 3, 24),  # L
    (17, 9, 4, 3, 72),  # Y2
    (17, 12, 4, 3, 120),  # N2
    (17, 15, 4, 3, 168),  # F2
    (17, 18, 4, 3, 172),  # Z
    (17, 21, 4, 3, 76),  # P
    (1, 24, 2, 1, 0xD4),  # T4
    (7, 24, 2, 1, 0xD6),  # J4
    (13, 24, 2, 1, 0xD8),  # Z4
    (19, 24, 2, 1, 0xDA),  # O4
    (3, 26, 2, 1, 0xDC),  # S4
    (9, 26, 2, 1, 0xDE),  # L4
    (15, 26, 2, 1, 0xF4),  # I4
]


if __name__ == "__main__":
    try:
        nametable_builder.build_nametable(
            output,
            table,
            attributes,
            characters,
            original_sha1sum,
            lengths,
            starting_addresses,
            rle_compress=True,
            rects=rects,
        )
    except Exception as exc:
        print(
            f"Unable to build nametable: {type(exc).__name__}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)
