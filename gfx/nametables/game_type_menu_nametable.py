import pathlib
import sys
import subprocess

import nametable_builder

"""
This script has been generated by nametable_builder.py.  It's intended to rebuild the nametable
into a .bin

Unless modified, it will reproduce the original.
"""

file = pathlib.Path(__file__)
output = file.parent / file.name.replace(".py", ".bin")

original_sha1sum = "8d1605cd58884bf2d7b25cf33ca84edc1274bbff"

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
¼zÏ¾ÜÝÝíÜzÝß¼½¼½ÜÝÝÝß¾¼zß¾¼ÝÝßìÏ
¾ÎìxßìßÞ¾Þ¾ÜxÍÌxß¾¼½¼^ÌÍ¼ÍÎÜÝ½Î¾
ÎÞÞÜÝ^ÜÝxßüÝÝßÜÝÝÍÎÜÍ¼ÏÜýìÝ½¾ÎÎÎ
wß¾ghhhhhhhhhhhhi¾Ìß¾Î¼zßÞ¾ÞÎÞÞÎ
Þ¾Îj_GAME__TYPE_kwÝßÎÎÌÍÜÝîÜxßÜÍ
¼ýÎlmmmmmmmmmmmmnÞÜÝÍÞ¾ÜÝ½Þ¼ÝÝß¾
Î¾üß¾ÜzÏÜÝÝÝßÜÝÝÝßìÝßÜxÝßÌßÞ¼Ϙ½Î
ÞwÏìÍ¾Î╔╧╧╧╧╧╧╧╧╗¾Î╔╧╧╧╧╧╧╧╧╗ÌÍÎ
ÜýÜýÜyÞ╣_A-TYPE_╠ÎÞ╣_B-TYPE_╠¾ÜÍ
ìÏ¼½¾Î¾╚╤╤╤╤╤╤╤╤╝üí╚╤╤╤╤╤╤╤╤╝þÏ¾
ÎÜxÍÎÞüíÜ½ÜÝzß¼½¼½ÞìÝß¾Ü½ìÝ½Üý¾Î
ÎìÝßüÝßÌßÌÝßÞÜxÍÌyÜÍÜÝxßÎÞ¾ÞìÝ^Î
ÞÎ¾ghhhhhhhhhhhhiÞ¾Ü½Ü½ÜÍ¾Ì½ÞÜíÌ
¾ÞÎj_MUSIC_TYPE_kÜϒÏÎ¾ÎÜÝî¾ÎìÏü½
Î¼^lmmmmmmmmmmmmn¾ÞÜÍÎÌß¾ÞÎÞÎÜ½Þ
ÎÞ¾ÜÝ½ÜzÝßÜÝÝÝßÜßüÝÝßÌÝßÎÜxßÎ¾wß
ÎÜxÝßÎ¾ÞÜÝ½¾┌━━━━━━━━━━┐ÌÝß¾ÞÎÞ¾
Þ¼½Ü½ÞüÝÝßÎÎ┇__________╏ÜÝÝÍìÍÜî
¾ÌxßÎ¼ÝÝÏ¾ÞÎ┇_MUSIC@[1_╏¾Ü½¾Þ¾¾Î
Î¼Ý½ÎÞìßÜϒßÎ┇__________╏üíÎÌÝÍÎÞ
ÎÞ¾ÞÞìý¾¾Þ¾Þ┇_MUSIC@[2_╏¾ÎÎÜϘ½wß
ÎÜxÝßÞ¼îÌÝÍ¾┇__________╏ÎÞÞ¾ÌÍÞ¾
ÞÜÝÝÝßÌÍìÝßÎ┇_MUSIC@[3_╏ÌÝßÎ¾ÜÝî
¾ìß¾ÜÝ½Ü^ÜÝý┇__________╏¾ÜÝÍÌÝ½Þ
ÎÎÜϒÏ¾ÌßÜÝÝ½┇___OFF____╏ÌÝÝßÜ½Þ¾
ÎÌßÞìxßìß¾¾Þ┇__________╏¾ÜÝ½¾ÎÜy
Ìß¾¾ÞÜÝÍ¾ÎwÏ└╍╍╍╍╍╍╍╍╍╍┘ÌÝ½ÎÎÎ¾Î
ìÝÍÌÝÝß¾ÎÎÎìßìß¾ÜÝ½ìÝßìÏ¼½ÞÞÎÞÎÞ
ÞìÝßìßìÍÎÎÞÎìÍ¾ÌÝ½ÎÎ¾Üy¾ÌxßÜÍ¾Ì½
ÜÍÝÝÍÜÍÜÍÞÜÍÎÜxÝßÞÞÞÌ½ÞÌÝÝßÜÝxßÞ

"""

attributes = """
2222222222222222
2000000002222222
2000000002222222
2221111112222222
2221111112222222
2111111110000002
2000000002222222
2000000002222222
2222220000002222
2222220000002222
2222220000002222
2222220000002222
2222220000002222
2222220000002222
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
            rle_compress=True,
        )
    except Exception as exc:
        print(
            f"Unable to build nametable: {type(exc).__name__}: {exc!s}", file=sys.stderr
        )
        sys.exit(1)
