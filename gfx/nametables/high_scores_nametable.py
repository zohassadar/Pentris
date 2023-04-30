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
ìÏÞ╣_┌━━━━━━━━━━━━━━━━━━━━┐_╠ÌÝý
ÎÜí╣_┇____NAME__SCORE__LV_╏_╠¾ÜÝ
ÌßÎ╣_├╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┤_╠ÌÝí
¾¾Î╣_┇_1__________________╏_╠Ü½Þ
ÎÎÞ╣_┇____________________╏_╠¾wß
ÎÌ½╣_┇_2__________________╏_╠ÎÞ¾
ÌßÞ╣_┇____________________╏_╠Ì½Î
¼Ý½╣_┇_3__________________╏_╠¾ÞÎ
Ì¾Þ╣_└╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┘_╠ÎÜ^
Џ000000ЏЏ000000ЏЏüüüüüüЏAAAAAAAA"""

attributes = """
"""

lengths = [32, 32, 32, 32, 32, 32, 32, 32, 32, 32]  # fmt: skip

starting_addresses = [(34, 32), (34, 64), (34, 96), (34, 128), (34, 160), (34, 192), (34, 224),
 (35, 0), (35, 32), (35, 224)]  # fmt: skip


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
            f"Unable to build nametable: {type(exc).__name}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)
