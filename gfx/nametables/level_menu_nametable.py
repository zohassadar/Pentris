
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

original_sha1sum = "ea1a97c4553ec3d43de5476fbe28a50cd7ad61ce"

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
    "ϕϖϗϘϙϚϛϜϝϞϟϠϡͰͱ_" #F
)  # fmt: skip

table = """
¼½¼½¾Þ¾ìß¾¾¾ÞÜíÜíÌÍ¾ÞÜÝÝßìß¾¾ÜÝí
ÌÍÌÍÎÜyÎìýÎüÝßüßüßÜxßìÝßÜýìýüÝßÞ
ÜÝÝßüßÞÞÞÜý╔╧╧╧╧╧╧╧╧╗ÞÜÝÝßÞÜÝí¼½
Üí¾╔╧╧╧╧╧╧╧╣_B-TYPE_╠╧╧╧╧╧╧╧╗ÞÌÍ
¾ÎÎ╣_______╚╤╤╤╤╤╤╤╤╝_______╠ìÝß
ÎÞÎ╣________________________╠ÞÜí
üßÞ╣________________________╠¼½Î
ìÝß╣____╭▭▭▭▭▭╮____╭▭▭▭▭▭▭╮_╠ÌÍÞ
ÞÜí╣____╢LEVEL╟____╢HEIGHT╟_╠ÜÝí
¼½Î╣____╰▱▱▱▱▱╯____╰▱▱▱▱▱▱╯_╠¾¾Þ
ÌÍÞ╣__┌━┉━┉━┉━┉━┐__┌━┉━┉━┐__╠Îüí
ÜÝí╣__┇0┇1┇2┇3┇4╏__┇0┇1┇2╏__╠Î¾Þ
¾¾Þ╣__├╍╪╍╪╍╪╍╪╍┤__├╍╪╍╪╍┤__╠ÞÎÜ
Îüí╣__┇5┇6┇7┇8┇9╏__┇3┇4┇5╏__╠¾üß
Î¾Þ╣__└╍=╍=╍=╍=╍┘__└╍=╍=╍┘__╠üÝß
ÞÎÜ╣________________________╠ìÝß
¾üß╣________________________╠ÞÜí
üÝß╣_┌━━━━━━━━━━━━━━━━━━━━┐_╠¼½Î
¾Üí╣_┇____NAME__SCORE__LV_╏_╠ÌÍÞ
y¾Î╣_├╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┤_╠ÜÝí
ÞÎÞ╣_┇_1__________________╏_╠¾¾Þ
Üý¾╣_┇____________________╏_╠Îüí
¼½Î╣_┇_2__________________╏_╠Î¾Þ
ÌÍÎ╣_┇____________________╏_╠ÞÎÜ
¾¾Þ╣_┇_3__________________╏_╠¾üß
ÎwÏ╣_└╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┘_╠üÝß
ÎÞ¾╣________________________╠¾¼½
Þìý╚╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╝ÎÌÍ
¾Þìß¾ÜÝíÜÝÝßìßìß¼½ìÝß¾ÜzßÜíÜíüß¾
ÎÜýÜxß¾ÞÜzßÜý¾Î¾ÌÍÞÜÝý¾Þ¼½üßüßÜx

"""

attributes = """
2222222222222222
2222222222222222
2211122222211122
2211222212222222
2211222202222222
2213333333333122
2213333333333122
2213333333333122
2200000000000022
2200000000000022
2200000000000022
2200000000000022
2200000000000022
2222222222222222
2222222222222222
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
        )
    except Exception as exc:
        print(f"Unable to build nametable: {type(exc).__name}: {exc!s}", file=sys.stderr)
        sys.exit(1)

