from orientation_base import Orientation, Piece, OrientationTable, HiddenOrientation

t_up = Orientation(
    ("....."
     "..X.."
     ".XXX."
     "...X."
     "....."),
    name="T Up",
)  # fmt: skip

t_right = Orientation(
    ("....."
     "..X.."
     "..XX."
     ".XX.."
     "....."),
    name="T Right",
)  # fmt: skip

t_down = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "..X.."
     "....."),
    name="T Down",
    spawn=True,
)  # fmt: skip

t_left = Orientation(
    ("....."
     "..XX."
     ".XX.."
     "..X.."
     "....."),
    name="T Left",
)  # fmt: skip

t = Piece(
    name="T",
    tile_index=0x7B,
    orientations=[
        t_up,
        t_right,
        t_down,
        t_left,
    ],
)


j_left = Orientation(
    ("....."
     ".XX.."
     "..X.."
     ".XX.."
     "....."),
    name="J Left",
)  # fmt: skip

j_up = Orientation(
    ("....."
     ".X.X."
     ".XXX."
     "....."
     "....."),
    name="J Up",
)  # fmt: skip

j_right = Orientation(
    ("....."
     "..XX."
     "..X.."
     "..XX."
     "....."),
    name="J Right",
)  # fmt: skip

j_down = Orientation(
    ("....."
     "....."
     ".XXX."
     ".X.X."
     "....."),
    name="J Down",
    spawn=True,
)  # fmt: skip

j = Piece(
    name="J",
    tile_index=0x7D,
    orientations=[
        j_left,
        j_up,
        j_right,
        j_down,
    ],
)


z_horizontal = Orientation(
    ("....."
     ".X..."
     ".XX.."
     "..XX."
     "....."),
    name="Z Horizontal",
    spawn=True,
)  # fmt: skip

z_vertical = Orientation(
    ("....."
     "...X."
     "..XX."
     ".XX.."
     "....."),
    name="Z Vertical",
)  # fmt: skip

z = Piece(
    name="Z",
    tile_index=0x7C,
    orientations=[
        z_horizontal,
        z_vertical,
    ],
)

o_solo = Orientation(
    ("....."
     "..X.."
     ".XX.."
     ".XX.."
     "....."),
    name="O Solo",
    spawn=True,
    next_offset=5,
)  # fmt: skip


o = Piece(
    name="O",
    tile_index=0x7B,
    orientations=[
        o_solo,
    ],
)


s_horizontal = Orientation(
    ("....."
     ".X..."
     "..XX."
     ".XX.."
     "....."),
    name="S Horizontal",
    spawn=True,
)  # fmt: skip

s_vertical = Orientation(
    ("....."
     "..X.."
     "..XX."
     "X..X."
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
    tile_index=0x7C,
    orientations=[
        l_right,
        l_down,
        l_left,
        l_up,
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
    tile_index=0x7B,
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
        t,
        j,
        z,
        o,
        s,
        l,
        i,
        hidden,
    ]
)
