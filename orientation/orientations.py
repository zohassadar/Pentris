from orientation_base import Orientation, Piece, OrientationTable, HiddenOrientation

f1_up = Orientation(
    ("....."
     "..XX."
     ".XX.."
     "..X.."
     "....."),
    name="F1 Up",
)  # fmt: skip

f1_right = Orientation(
    ("....."
     "..X.."
     ".XXX."
     "...X."
     "....."),
    name="F1 Right",
)  # fmt: skip

f1_down = Orientation(
    ("....."
     "..X.."
     "..XX."
     ".XX.."
     "....."),
    name="F1 Down",
    spawn=True,
)  # fmt: skip

f1_left = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "..X.."
     "....."),
    name="F1 Left",
)  # fmt: skip

f1 = Piece(
    name="F1",
    tile_index=0x7B,
    orientations=[
        f1_up,
        f1_right,
        f1_down,
        f1_left,
    ],
)


f2_up = Orientation(
    ("....."
     ".XX.."
     "..XX."
     "..X.."
     "....."),
    name="F2 Up",
)  # fmt: skip

f2_right = Orientation(
    ("....."
     "...X."
     ".XXX."
     "..X.."
     "....."),
    name="F2 Right",
)  # fmt: skip

f2_down = Orientation(
    ("....."
     "..X.."
     ".XX.."
     "..XX."
     "....."),
    name="F2 Down",
    spawn=True,
)  # fmt: skip

f2_left = Orientation(
    ("....."
     "..X.."
     ".XXX."
     ".X..."
     "....."),
    name="F2 Left",
)  # fmt: skip

f2 = Piece(
    name="F2",
    tile_index=0x7C,
    orientations=[
        f2_up,
        f2_right,
        f2_down,
        f2_left,
    ],
)


j_right = Orientation(
    ("..X.."
     "..X.."
     "..X.."
     ".XX.."
     "....."),
    name="J Right",
)  # fmt: skip


j_down = Orientation(
    ("....."
     ".X..."
     ".XXXX"
     "....."
     "....."),
    name="J Down",
    spawn=True,
)  # fmt: skip

j_left = Orientation(
    ("....."
     "..XX."
     "..X.."
     "..X.."
     "..X.."),
    name="J Left",
)  # fmt: skip

j_up = Orientation(
    ("....."
     "....."
     "XXXX."
     "...X."
     "....."),
    name="J Up",
)  # fmt: skip

j = Piece(
    name="J",
    tile_index=0x7D,
    orientations=[
        j_right,
        j_down,
        j_left,
        j_up,
    ],
)


l_right = Orientation(
    ("..X.."
     "..X.."
     "..X.."
     "..XX."
     "....."),
    name="L Right",
)  # fmt: skip


l_down = Orientation(
    ("....."
     "....."
     ".XXXX"
     ".X..."
     "....."),
    name="L Down",
    spawn=True,
)  # fmt: skip

l_left = Orientation(
    ("....."
     ".XX.."
     "..X.."
     "..X.."
     "..X.."),
    name="L Left",
)  # fmt: skip

l_up = Orientation(
    ("....."
     "...X."
     "XXXX."
     "....."
     "....."),
    name="L Up",
)  # fmt: skip

l = Piece(
    name="L",
    tile_index=0x7B,
    orientations=[
        l_right,
        l_down,
        l_left,
        l_up,
    ],
)


x_solo = Orientation(
    ("....."
     "..X.."
     ".XXX."
     "..X.."
     "....."),
    name="X Solo",
    spawn=True,
    next_offset=5,
)  # fmt: skip


x = Piece(
    name="X",
    tile_index=0x7C,
    orientations=[
        x_solo,
    ],
)


s_horizontal = Orientation(
    ("....."
     "..XX."
     "..X.."
     ".XX.."
     "....."),
    name="S Horizontal",
    spawn=True,
)  # fmt: skip

s_vertical = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "...X."
     "....."),
    name="S Vertical",
)  # fmt: skip

s = Piece(
    name="S",
    tile_index=0x7D,
    orientations=[
        s_horizontal,
        s_vertical,
    ],
)


z_horizontal = Orientation(
    ("....."
     ".XX.."
     "..X.."
     "..XX."
     "....."),
    name="Z Horizontal",
    spawn=True,
)  # fmt: skip

z_vertical = Orientation(
    ("....."
     "...X."
     ".XXX."
     ".X..."
     "....."),
    name="Z Vertical",
)  # fmt: skip

z = Piece(
    name="Z",
    tile_index=0x7B,
    orientations=[
        z_horizontal,
        z_vertical,
    ],
)


i_horizontal = Orientation(
    ("..X.."
     "..X.."
     "..X.."
     "..X.."
     "..X.."),
    name="I Vertical",
)  # fmt: skip

i_vertical = Orientation(
    ("....."
     "....."
     "XXXXX"
     "....."
     "....."),
    name="I Horizontal",
    spawn=True,
    next_offset=4,
)  # fmt: skip

i = Piece(
    name="I",
    tile_index=0x7C,
    orientations=[
        i_horizontal,
        i_vertical,
    ],
)


hidden_orientation = HiddenOrientation(5)


hidden = Piece(
    name="Hidden",
    tile_index=0xFF,
    orientations=[
        hidden_orientation,
    ],
    hidden=True,
)


table = OrientationTable(
    [
        f1,
        f2,
        j,
        l,
        x,
        s,
        i,
        hidden,
    ]
)
