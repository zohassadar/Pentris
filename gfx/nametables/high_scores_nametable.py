import pathlib
import sys

import nametable_builder

"""
This script has been generated by nametable_builder.py.  It's intended to rebuild the nametable
into a .bin

Unless modified, it will reproduce the original.
"""

file = pathlib.Path(__file__)
output = file.parent / file.name.replace(".py", ".bin")

original_sha1sum = "9e386b6724ca10a43ae649ac06c66538f4d7e245"

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
ìÏÞ╣________________________╠ÌÝý
ÎÜí╣___DAS_____________00___╠¾ÜÝ
ÌßÎ╣___ARR_____________00___╠ÌÝí
¾¾Î╣___ARE_CHARGE_____OFF___╠Ü½Þ
ÎÎÞ╣___MARATHON_______OFF___╠¾wß
ÎÌ½╣___SXTOKL_________OFF___╠ÎÞ¾
ÌßÞ╣___TETRIMINOS_____OFF___╠Ì½Î
¼Ý½╣___SEED________000000___╠¾ÞÎ
Ì¾Þ╣___RESET_SEED___________╠ÎÜ^"""

attributes = """
"""

lengths = [32, 32, 32, 32, 32, 32, 32, 32, 32, 32]  # fmt: skip

starting_addresses = [(42, 32), (42, 64), (42, 96), (42, 128), (42, 160), (42, 192), (42, 224),
 (43, 0), (43, 32),]  # fmt: skip


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
        )
    except Exception as exc:
        print(
            f"Unable to build nametable: {type(exc).__name__}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)
