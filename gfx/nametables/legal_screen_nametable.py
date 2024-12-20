import pathlib
import sys
import subprocess
import nametable_builder
import pathlib

"""
This script was originally generated by nametable_builder.py
Unless modified, it will reproduce the original.
"""

file = pathlib.Path(__file__)
output = file.parent / file.name.replace(".py", ".bin")

original_sha1sum = "f1218564c48f2b2e88d9b8439a9d0c7768ea5872"

characters = (
    #0123456789ABCDEF
    "0123456789ABCDEF" #0
    "GHIJKLMNOPQRSTUV" #1
    "WXYZ-,'╥┌━┐┇╏└╍┘" #2
    "ghijklmn╔╧╗╣╠╚╤╝" #3
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
    "ϕϖϗϘϙ©ϛ┬ϝϞϟϠϡͰͱ_" #F
)  # fmt: skip

table = """
________________________________
________________________________
________________________________
________________________________
________________________________
________________________________
_________TM_AND_©_1987__________
________________________________
_____V/O_ELECTRONORGTECHNICA____
________________________________
___________(‟ELORG‟)____________
________________________________
__PENTRIS_LICENSED_TO_NINTENDO__
________________________________
_______©_1989_NINTENDO__________
________________________________
______ALL_RIGHTS_RESERVED_______
________________________________
____ORIGINAL_CONCEPT,DESIGN_____
________________________________
___________AND_PROGRAM__________
________________________________
_______BY_ALEXEY_PAZHITNOV______
________________________________
________________________________
________________________________
________________________________
________________________________
________________________________
________________________________
"""

attributes = """
3333333333333333
3333333333333333
3333333333333333
3333333311133333
3300000000000003
3200000000000003
3111133333300003
3301111000000000
3333333333333333
3333333333333333
3333333333333333
3333322222222233
3333333333333333
3333333333333333
3333333333333333
0000000000000000"""


lengths = [32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32]  # fmt: skip

starting_addresses = [(32, 0), (32, 32), (32, 64), (32, 96), (32, 128), (32, 160), (32, 192),
 (32, 224), (33, 0), (33, 32), (33, 64), (33, 96), (33, 128), (33, 160),
 (33, 192), (33, 224), (34, 0), (34, 32), (34, 64), (34, 96), (34, 128),
 (34, 160), (34, 192), (34, 224), (35, 0), (35, 32), (35, 64), (35, 96),
 (35, 128), (35, 160), (35, 192), (35, 224)]  # fmt: skip


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
        )

    except Exception as exc:
        print(
            f"Unable to build nametable: {type(exc).__name__}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)
