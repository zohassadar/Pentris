from orientation_base import Orientation, Piece, OrientationTable, HiddenOrientation

f1_up = Orientation(
    ("....."
     "..XX."
     ".XX.."
     "..X.."
     "....."),
    name="F1Up",
)  # fmt: skip

f1_right = Orientation(
    ("....."
     "..X.."
     ".XXX."
     "...X."
     "....."),
    name="F1Right",
)  # fmt: skip

f1_down = Orientation(
    ("....."
     "..X.."
     "..XX."
     ".XX.."
     "....."),
    name="F1Down",
    spawn=True,
)  # fmt: skip

f1_left = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "..X.."
     "....."),
    name="F1Left",
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
    name="F2Up",
)  # fmt: skip

f2_right = Orientation(
    ("....."
     "...X."
     ".XXX."
     "..X.."
     "....."),
    name="F2Right",
)  # fmt: skip

f2_down = Orientation(
    ("....."
     "..X.."
     ".XX.."
     "..XX."
     "....."),
    name="F2Down",
    spawn=True,
)  # fmt: skip

f2_left = Orientation(
    ("....."
     "..X.."
     ".XXX."
     ".X..."
     "....."),
    name="F2Left",
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
    name="JRight",
)  # fmt: skip


j_down = Orientation(
    ("....."
     ".X..."
     ".XXXX"
     "....."
     "....."),
    name="JDown",
    spawn=True,
)  # fmt: skip

j_left = Orientation(
    ("....."
     "..XX."
     "..X.."
     "..X.."
     "..X.."),
    name="JLeft",
)  # fmt: skip

j_up = Orientation(
    ("....."
     "....."
     "XXXX."
     "...X."
     "....."),
    name="JUp",
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
    name="LRight",
)  # fmt: skip


l_down = Orientation(
    ("....."
     "....."
     ".XXXX"
     ".X..."
     "....."),
    name="LDown",
    spawn=True,
)  # fmt: skip

l_left = Orientation(
    ("....."
     ".XX.."
     "..X.."
     "..X.."
     "..X.."),
    name="LLeft",
)  # fmt: skip

l_up = Orientation(
    ("....."
     "...X."
     "XXXX."
     "....."
     "....."),
    name="LUp",
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
    name="XSolo",
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
    name="SHorizontal",
    spawn=True,
)  # fmt: skip

s_vertical = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "...X."
     "....."),
    name="SVertical",
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
    name="ZHorizontal",
    spawn=True,
)  # fmt: skip

z_vertical = Orientation(
    ("....."
     "...X."
     ".XXX."
     ".X..."
     "....."),
    name="ZVertical",
)  # fmt: skip

z = Piece(
    name="Z",
    tile_index=0x7B,
    orientations=[
        z_horizontal,
        z_vertical,
    ],
)


p1_up = Orientation(
    ("....."
     "..X.."
     "..XX."
     "..XX."
     "....."),
    name="P1Up",
)  # fmt: skip

p1_right = Orientation(
    ("....."
     "....."
     ".XXX."
     ".XX."
     "....."),
    name="P1Right",
)  # fmt: skip

p1_down = Orientation(
    ("....."
     ".XX.."
     ".XX.."
     "..X.."
     "....."),
    name="P1Down",
    spawn=True,
)  # fmt: skip

p1_left = Orientation(
    ("....."
     "..XX."
     ".XXX."
     "....."
     "....."),
    name="P1Left",
)  # fmt: skip

p1 = Piece(
    name="P1",
    tile_index=0x7C,
    orientations=[
        p1_up,
        p1_right,
        p1_down,
        p1_left,
    ],
)

p2_up = Orientation(
    ("....."
     "..X.."
     ".XX.."
     ".XX.."
     "....."),
    name="P2Up",
)  # fmt: skip

p2_right = Orientation(
    ("....."
     ".XX.."
     ".XXX."
     "...."
     "....."),
    name="P2Right",
)  # fmt: skip

p2_down = Orientation(
    ("....."
     "..XX."
     "..XX."
     "..X.."
     "....."),
    name="P2Down",
    spawn=True,
)  # fmt: skip

p2_left = Orientation(
    ("....."
     "....."
     ".XXX."
     "..XX."
     "....."),
    name="P2Left",
)  # fmt: skip

p2 = Piece(
    name="P2",
    tile_index=0x7D,
    orientations=[
        p2_up,
        p2_right,
        p2_down,
        p2_left,
    ],
)


n1_up = Orientation(
    ("..X.."
     "..X.."
     ".XX.."
     ".X..."
     "....."),
    name="N1Up",
)  # fmt: skip

n1_right = Orientation(
    ("....."
     ".XX.."
     "..XXX"
     "...."
     "....."),
    name="N1Right",
)  # fmt: skip

n1_down = Orientation(
    ("....."
     "...X."
     "..XX."
     "..X.."
     "..X.."),
    name="N1Down",
    spawn=True,
)  # fmt: skip

n1_left = Orientation(
    ("....."
     "....."
     "XXX.."
     "..XX."
     "....."),
    name="N1Left",
)  # fmt: skip

n1 = Piece(
    name="N1",
    tile_index=0x7B,
    orientations=[
        n1_up,
        n1_right,
        n1_down,
        n1_left,
    ],
)

n2_up = Orientation(
    ("..X.."
     "..X.."
     "..XX."
     "...X."
     "....."),
    name="N2Up",
)  # fmt: skip

n2_right = Orientation(
    ("....."
     "....."
     "..XXX"
     ".XX.."
     "....."),
    name="N2Right",
)  # fmt: skip

n2_down = Orientation(
    ("....."
     ".X..."
     ".XX.."
     "..X.."
     "..X.."),
    name="N2Down",
    spawn=True,
)  # fmt: skip

n2_left = Orientation(
    ("....."
     "..XX."
     "XXX.."
     "....."
     "....."),
    name="N2Left",
)  # fmt: skip

n2 = Piece(
    name="N2",
    tile_index=0x7C,
    orientations=[
        n2_up,
        n2_right,
        n2_down,
        n2_left,
    ],
)


t_up = Orientation(
    ("..X.."
     "..X.."
     ".XXX."
     "....."
     "....."),
    name="TUp",
)  # fmt: skip

t_right = Orientation(
    ("....."
     "..X.."
     "..XXX"
     "..X.."
     "....."),
    name="TRight",
)  # fmt: skip

t_down = Orientation(
    ("....."
     "....."
     ".XXX."
     "..X.."
     "..X.."),
    name="TDown",
    spawn=True,
)  # fmt: skip

t_left = Orientation(
    ("....."
     "..X.."
     "XXX.."
     "..X.."
     "....."),
    name="TLeft",
)  # fmt: skip

t = Piece(
    name="T",
    tile_index=0x7D,
    orientations=[
        t_up,
        t_right,
        t_down,
        t_left,
    ],
)

u_up = Orientation(
    ("....."
     ".X.X."
     ".XXX."
     "....."
     "....."),
    name="UUp",
)  # fmt: skip

u_right = Orientation(
    ("....."
     "..XX."
     "..X.."
     "..XX."
     "....."),
    name="URight",
)  # fmt: skip

u_down = Orientation(
    ("....."
     "....."
     ".XXX."
     ".X.X."
     "....."),
    name="UDown",
    spawn=True,
)  # fmt: skip

u_left = Orientation(
    ("....."
     ".XX.."
     "..X.."
     ".XX.."
     "....."),
    name="ULeft",
)  # fmt: skip

u = Piece(
    name="U",
    tile_index=0x7B,
    orientations=[
        u_up,
        u_right,
        u_down,
        u_left,
    ],
)


v_up = Orientation(
    ("....."
     "...X."
     "...X."
     ".XXX."
     "....."),
    name="VUp",
)  # fmt: skip

v_right = Orientation(
    ("....."
     ".X..."
     ".X..."
     ".XXX."
     "....."),
    name="VRight",
)  # fmt: skip

v_down = Orientation(
    ("....."
     ".XXX."
     ".X..."
     ".X..."
     "....."),
    name="VDown",
    spawn=True,
)  # fmt: skip

v_left = Orientation(
    ("....."
     ".XXX."
     "...X."
     "...X."
     "....."),
    name="VLeft",
)  # fmt: skip

v = Piece(
    name="V",
    tile_index=0x7C,
    orientations=[
        v_up,
        v_right,
        v_down,
        v_left,
    ],
)


w_up = Orientation(
    ("....."
     "...X."
     "..XX."
     ".XX.."
     "....."),
    name="WUp",
)  # fmt: skip

w_right = Orientation(
    ("....."
     ".X..."
     ".XX.."
     "..XX."
     "....."),
    name="WRight",
)  # fmt: skip

w_down = Orientation(
    ("....."
     "..XX."
     ".XX.."
     ".X..."
     "....."),
    name="WDown",
    spawn=True,
)  # fmt: skip

w_left = Orientation(
    ("....."
     ".XX.."
     "..XX."
     "...X."
     "....."),
    name="WLeft",
)  # fmt: skip

w = Piece(
    name="W",
    tile_index=0x7D,
    orientations=[
        w_up,
        w_right,
        w_down,
        w_left,
    ],
)


y1_right = Orientation(
    ("..X.."
     "..X.."
     ".XX.."
     "..X.."
     "....."),
    name="Y1Right",
)  # fmt: skip


y1_down = Orientation(
    ("....."
     "..X.."
     ".XXXX"
     "....."
     "....."),
    name="Y1Down",
    spawn=True,
)  # fmt: skip

y1_left = Orientation(
    ("....."
     "..X.."
     "..XX."
     "..X.."
     "..X.."),
    name="Y1Left",
)  # fmt: skip

y1_up = Orientation(
    ("....."
     "....."
     "XXXX."
     "..X.."
     "....."),
    name="Y1Up",
)  # fmt: skip

y1 = Piece(
    name="Y1",
    tile_index=0x7B,
    orientations=[
        y1_right,
        y1_down,
        y1_left,
        y1_up,
    ],
)


y2_right = Orientation(
    ("..X.."
     "..X.."
     "..XX."
     "..X.."
     "....."),
    name="Y2Right",
)  # fmt: skip


y2_down = Orientation(
    ("....."
     "....."
     ".XXXX"
     "..X.."
     "....."),
    name="Y2Down",
    spawn=True,
)  # fmt: skip

y2_left = Orientation(
    ("....."
     "..X.."
     ".XX.."
     "..X.."
     "..X.."),
    name="Y2Left",
)  # fmt: skip

y2_up = Orientation(
    ("....."
     "..X.."
     "XXXX."
     "....."
     "....."),
    name="Y2Up",
)  # fmt: skip

y2 = Piece(
    name="Y2",
    tile_index=0x7B,
    orientations=[
        y2_right,
        y2_down,
        y2_left,
        y2_up,
    ],
)


i_horizontal = Orientation(
    ("..X.."
     "..X.."
     "..X.."
     "..X.."
     "..X.."),
    name="IVertical",
)  # fmt: skip

i_vertical = Orientation(
    ("....."
     "....."
     "XXXXX"
     "....."
     "....."),
    name="IHorizontal",
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
        z,
        p1,
        p2,
        n1,
        n2,
        t,
        u,
        v,
        w,
        y1,
        y2,
        i,
        hidden,
    ]
)
