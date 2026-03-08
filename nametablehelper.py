from PIL import Image

TILE = 8
WIDTH = 32
HEIGHT = 30

characters = (
    "0123456789ABCDEF"
    "GHIJKLMNOPQRSTUV"
    "WXYZ-,'╥┌━┐┇╏└╍┘"
    "ghijklmn╔╧╗╣╠╚╤╝"
    "wxyz╭▭╮╢╟╰▱╯├╪┤/"
    "┉=!@[]^Ë`{|}~¹()"
    "¼½¾¿ÀÁÂÃÄÅÆÇÈÉ‟."
    "ÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛ"
    "ÜÝÞßàáâãäåæçèéêë"
    "ìíîïðñòóôõö÷øùúû"
    "üýþÿЉЊЋЌЍЎЏАБВГД"
    "ЕЖЗИЙКЛМНОПРСТУФ"
    "ХЦЧШЩЪЫЬЭЮЯабвгд"
    "εζηθικλμνξοπρςστ"
    "υφχψωϊϋόύώϏϐϑϒϓϔ"
    "ϕϖϗϘϙ©ϛ┬ϝϞϟϠϡͰͱ_"
)

def get_tile(img, tx, ty):
    return img.crop((
        tx*TILE,
        ty*TILE,
        (tx+1)*TILE,
        (ty+1)*TILE
    ))

def build_tileset(img):
    tiles = []
    w = img.width // TILE
    h = img.height // TILE

    for y in range(h):
        for x in range(w):
            tiles.append(get_tile(img, x, y))

    return tiles

def find_tile(tile, tiles):
    data = list(tile.getdata())

    for i, t in enumerate(tiles):
        if data == list(t.getdata()):
            return i

    raise Exception("Tile not found in tileset")

tileset = Image.open("tileset.png")
layout = Image.open("nametablegoal.png")

tiles = build_tileset(tileset)

rows = []

for y in range(HEIGHT):
    row = ""

    for x in range(WIDTH):
        tile = get_tile(layout, x, y)
        idx = find_tile(tile, tiles)

        row += characters[idx]

    rows.append(row)

print("\nnametable = [")

for r in rows:
    print(f'"{r}",')

print("]")