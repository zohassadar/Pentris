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

original_sha1sum = "dea169f4d5ed79a92c661a1f798f8b2cc7381dd7"

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
¼zßìÝÝßÜÝÝíÎìÝÝß¼ÝÝß¾ÜÝÝÝß¾üßÜÝí
ÌÍ¾ÞÜzÝß¼½ÞÎÞìÝßÞìÝíÌÝÝÏ¾¾ÎÜzÝßÎ
ìÝýìßÞ¾ÜxÍÜxßÎ¾¼½Þ¾Þ¼½¼Ϙ^Îü½ÎìÏÞ
ÞìßÎìÝý_ÜÝÝÝßÞÎÌy¼îìý__ÎÜxßÎ_ÎÜ½
ìýÜýÞ_______ÜÝý_ÞÌ{Þ_________Ìßî
Þ_____________________________Ü^
¾__ЪСХЦЪЭЮЪЯ_ЪШЩЪЫЬСХЦЪабУФЕЖ_ìÏ
wß_κøεζκ_ξκο_κθικλμøεζκύώгд___Î¼
Î¾_κøυφκ_ЧκϏ_κψ_κ_όøυφκДͰ~τ___Îþ
ÞÎ_κБϕϖκωηκвЯκ__κ__БϕϖκИͰÈÚ__¾ÞÞ
ìý_κ___κϙχκςοκ__κ__Ø__κÙ¹Ͱÿ__üϘß
Þ¾_κ___κ_ϗκ_Ϗκ__κ__èé_κèÉͰÛ___Þ¾
Üî_κ___κ_ρκ_вκ__κ__øù_κøùêë__¼z^
¾Î_ϊ___ϊϐϑϊ_ςϊ__ϊ__БВГϊБВúû___Þ¾
ÎÞ____________________________¼^
Ì½___________________________Ü^¾
¾Þ______________________ï___ÜzßÎ
Î¾___________________]_Ë`_|__ÎÜî
ÎüÝ½________________ÀÁÂÃÄÅÆÇ_Þ¾Þ
Î¾ÎÎ________________ÐÑÒÓÔÕÖ×_ìxß
ÞÎÎ____PUSH_START___àáâãäåæç_ÞìÏ
¾ÎÌÝß_______________ðñòóôõö÷__Î¾
ÎÌÝ_________________ЉЊЋЌЍЎЏА_Ü^Î
ÌÝß_________________ЙКЛМНОПР__ìý
Üí__¾_________________________Þ¾
¾Î_Üϒß___©_1989__ϛ┬ϝϞϟϠ______¼Ýý
ÎÎ__Î_____________________¾__Þ¼½
ÎÞ¾___Üí____¾ÜϘ½_¾¼Ϙß¾_¾¾Üxí¾¾Ìî
ÌßÎ¾_¾¾üÝßìÝý¾ÌÍ¼ýÌÍ¾ÌÝýüÝ½ÞÎÌíÞ
ÜÝÍÌÝýüÝÝßÞÜÝxßÜ^ÜÝÝ^ÜÝÝÝßÎÜxßüß

"""

attributes = """
2222222222222222
2222222222222222
2222222222223322
2333333333333332
2111111111111122
2222222222222222
2000000000000022
2000000000000022
2000000000333322
2200000000333322
2200000000333322
2200000000333322
2220311100000022
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
        print(
            f"Unable to build nametable: {type(exc).__name__}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)
