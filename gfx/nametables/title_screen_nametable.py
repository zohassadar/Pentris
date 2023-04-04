
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

original_sha1sum = "34408abffcd827fef3500a27c83c4dcce323dfc5"

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
ßìßìÝß¾ÎÜÝíÞìßÌÍ¾Üxß¼½¾¾Üí¾üßÜÝí
Üý¾ÞÜÝýÞ¼½ÞÜýìÏìýÜÝíÌÍÎwßÎÎÜÝÝßÞ
ÜÝýÜzßìßÌÍÜÝíÎ¾Þ¾¼½Þ¾ÜýÞ¾Þüß_¼½¾
ìÝß¾ÞÜý_ÜÝÝßÞÞÎÜyÌÍìý__Üxß___ÌÍw
Þ¾Üxß________Üý_Þ__Þ__________¾Þ
ìý____________________________üí
Þ__ШЩЪЫЬЪЭЮЯШЩЪЫЬЪСХЦЪ_абУФЕЖ_¾Þ
ìÏ_θικλμκ_ξοθικλμκøεζκ_ύώгд___Î¾
Î__ψ_κ_όκ_ЧϏψ_κ_όκøυφκ_ДͰ~τ___ÎÎ
Þ____κ__κωη___κ__κБϕϖκ_ИͰÈÚ__¾ÞÎ
ìÝß__κ__κϙχ___κ__κØ__κ_Ù¹Ͱÿ__üíÞ
Þ¾___κ__κ_ϗв__κ__κèé_κ_èÉͰÛ___Þ¾
Üzß__κ__κ_ρς__κ__κøù_κ_øùêë___¾w
ßÞ___ϊ__ϊϐϑϒ__ϊ__ϊБВГϊ_БВúû___ÎÞ
¼½____________________________üß
ÌÍ___________________________ÜÝí
ìÏ______________________ï___ÜzßÞ
Î¾___________________]^Ë`{|__ÞÜí
Þüí_________________ÀÁÂÃÄÅÆÇ__¾Î
Ý¾Þ_________________ÐÑÒÓÔÕÖ×_ìýÞ
¾wß____PUSH_START___àáâãäåæç_ÞìÏ
ÎÞ__________________ðñòóôõö÷__ÎÜ
üß__________________ЉЊЋЌЍЎЏА__Þ¾
ÝÝß_________________ЙКЛМНОПР__ìý
½¾____________________________Þ¾
ÍÎ_Üzß___©_1989__ϛ┬ϝϞϟϠ______ÜÝý
íÎ__Þ_____________________¾___¼½
ÞÞ¾___Üí____¾ÜÝí_ìÏìß¾_¾¾ÜyìÝßÌÍ
¼½wß_¾¾üßÜzßÎÜíÞ¾ÎÜýÜyìýüíÞÞ¾ÜíÜ
ÌÍÞÜÝýüÝß¾ÞÜý¾ÎÜyÞìÝßÞÞ¼½Þ¾Üxßüß

"""

attributes = """
2222222222222222
2222222222222222
2222222222222222
2333333333333332
2111111111111122
2222222222222222
2200000000000022
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
            f"Unable to build nametable: {type(exc).__name}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)

