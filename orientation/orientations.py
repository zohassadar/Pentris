from orientation_base import Orientation, Piece, OrientationTable, HiddenOrientation

i1_u = Orientation(
    ("....."
     "....."
     "..X.."
     "....."
     "....."),
    spawn=True,
    next_offset_y=4,
    # spawn_offset_y=1,
    name="I1Up",
)  # fmt: skip

i1 = Piece(
    name="I1",
    tile_index=0x7C,
    stats_addr=0x2B35,
    orientations=[
        i1_u,
    ],
)

i2_up = Orientation(
    ("....."
     "....."
     "....."
     ".XX.."
     "....."),
    spawn=True,
    next_offset_y=252,
    next_offset_x=4,
    spawn_offset_y=255,
    name="I2Up",
)  # fmt: skip

i2_right = Orientation(
    ("....."
     "....."
     "..X.."
     "..X.."
     "....."),
    name="I2Right",
)  # fmt: skip

i2_down = Orientation(
    ("....."
     "....."
     ".XX.."
     "....."
     "....."),
    name="I2Down",
)  # fmt: skip

i2_left = Orientation(
    ("....."
     "....."
     ".X..."
     ".X..."
     "....."),
    name="I2Left",
)  # fmt: skip

i2 = Piece(
    name="I2",
    tile_index=0x7B,
    stats_addr=0x2B2B,
    orientations=[
        i2_up,
        i2_left,
        i2_down,
        i2_right,
    ],
)


v3_up = Orientation(
    ("....."
     "....."
     ".XX.."
     "..X.."
     "....."),
    name="V3Up",
)  # fmt: skip

v3_right = Orientation(
    ("....."
     "....."
     "..X.."
     ".XX.."
     "....."),
    name="V3Right",
)  # fmt: skip

v3_down = Orientation(
    ("....."
     "....."
     ".X..."
     ".XX.."
     "....."),
    name="V3Down",
)  # fmt: skip

v3_left = Orientation(
    ("....."
     "....."
     ".XX.."
     ".X..."
     "....."),
    spawn=True,
    next_offset_x=4,
    name="V3Left",
)  # fmt: skip

v3 = Piece(
    name="V3",
    tile_index=0x7D,
    stats_addr=0x2AF0,
    orientations=[
        v3_up,
        v3_right,
        v3_down,
        v3_left,
    ],
)


i3h = Orientation(
    ("....."
     "....."
     ".XXX."
     "....."
     "....."),
    spawn=True,
    next_offset_y=4,
    # spawn_offset_y=1,
    name="I3Horizontal",
)  # fmt: skip

i3v = Orientation(
    ("....."
     "..X.."
     "..X.."
     "..X.."
     "....."),
    name="I3Vertical",
)  # fmt: skip

i3 = Piece(
    name="I3",
    tile_index=0x7C,
    stats_addr=0x2AF8,
    orientations=[
        i3h,
        i3v,
    ],
)


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
    spawn=True,
    next_offset_y=4,
    spawn_offset_y=1,
)  # fmt: skip

f1_down = Orientation(
    ("....."
     "..X.."
     "..XX."
     ".XX.."
     "....."),
    name="F1Down",
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
    tile_index=0x7D,
    stats_addr=0x29B0, #2A10,
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
)  # fmt: skip

f2_left = Orientation(
    ("....."
     "..X.."
     ".XXX."
     ".X..."
     "....."),
    name="F2Left",
    spawn=True,
    next_offset_y=4,
    spawn_offset_y=1,
)  # fmt: skip

f2 = Piece(
    name="F2",
    tile_index=0x7C,
    stats_addr=0x29B8, #2A18,
    orientations=[
        f2_up,
        f2_right,
        f2_down,
        f2_left,
    ],
)


j_left = Orientation(
    ("..X.."
     "..X.."
     "..X.."
     ".XX.."
     "....."),
    name="JLeft",
)  # fmt: skip


j_up = Orientation(
    ("....."
     "X...."
     "XXXX."
     "....."
     "....."),
    name="JUp",
)  # fmt: skip

j_right = Orientation(
    (".XX.."
     ".X..."
     ".X..."
     ".X..."
     "....."),
    name="JRight",
)  # fmt: skip

j_down = Orientation(
    ("....."
     "XXXX."
     "...X."
     "....."
     "....."),
    name="JDown",
    spawn=True,
    next_offset_x=4,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

j = Piece(
    name="J",
    tile_index=0x7D,
    stats_addr=0x28F0,
    orientations=[
        j_left,
        j_up,
        j_right,
        j_down,
    ],
)


l_right = Orientation(
    (".X..."
     ".X..."
     ".X..."
     ".XX.."
     "....."),
    name="LRight",
)  # fmt: skip


l_down = Orientation(
    ("....."
     "XXXX."
     "X...."
     "....."
     "....."),
    name="LDown",
    spawn=True,
    spawn_offset_y=1,
    next_offset_x=4,
    next_offset_y=8,
)  # fmt: skip

l_left = Orientation(
    (".XX.."
     "..X.."
     "..X.."
     "..X.."
     "....."),
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
    tile_index=0x7C,
    stats_addr=0x28F8,
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
    next_offset_y=4,
    spawn_offset_y=1,
)  # fmt: skip


x = Piece(
    name="X",
    tile_index=0x7B,
    stats_addr=0x29A8, #2A68,
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
)  # fmt: skip

s_vertical = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "...X."
     "....."),
    name="SVertical",
    spawn=True,
    next_offset_y=4,
    spawn_offset_y=1,
)  # fmt: skip

s = Piece(
    name="S",
    tile_index=0x7D,
    stats_addr=0x29F0, #2A70,
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
)  # fmt: skip

z_vertical = Orientation(
    ("....."
     "...X."
     ".XXX."
     ".X..."
     "....."),
    name="ZVertical",
    spawn=True,
    next_offset_y=4,
    spawn_offset_y=1,
)  # fmt: skip

z = Piece(
    name="Z",
    tile_index=0x7C,
    stats_addr=0x29F8, #2A78,
    orientations=[
        z_horizontal,
        z_vertical,
    ],
)


q_up = Orientation(
    ("....."
     ".X..."
     ".XX.."
     ".XX.."
     "....."),
    name="QUp",
)  # fmt: skip

q_right = Orientation(
    ("....."
     ".XXX."
     ".XX.."
     "....."
     "....."),
    name="QRight",
    spawn=True,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

q_down = Orientation(
    ("....."
     "..XX."
     "..XX."
     "...X."
     "....."),
    name="QDown",
)  # fmt: skip

q_left = Orientation(
    ("....."
     "....."
     "..XX."
     ".XXX."
     "....."),
    name="QLeft",
)  # fmt: skip

q = Piece(
    name="Q",
    tile_index=0x7D,
    stats_addr=0x2A30, #2AD0,
    orientations=[
        q_up,
        q_right,
        q_down,
        q_left,
    ],
)

p_up = Orientation(
    ("....."
     "...X."
     "..XX."
     "..XX."
     "....."),
    name="PUp",
)  # fmt: skip

p_right = Orientation(
    ("....."
     "....."
     ".XX.."
     ".XXX."
     "....."),
    name="PRight",
)  # fmt: skip

p_down = Orientation(
    ("....."
     ".XX.."
     ".XX.."
     ".X..."
     "....."),
    name="PDown",
)  # fmt: skip

p_left = Orientation(
    ("....."
     ".XXX."
     "..XX."
     "....."
     "....."),
    name="PLeft",
    spawn=True,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

p = Piece(
    name="P",
    tile_index=0x7C,
    stats_addr=0x2A38, #2AD8,
    orientations=[
        p_up,
        p_right,
        p_down,
        p_left,
    ],
)


n_up = Orientation(
    ("..X.."
     "..X.."
     ".XX.."
     ".X..."
     "....."),
    name="NUp",
)  # fmt: skip

n_right = Orientation(
    ("....."
     "XX..."
     ".XXX."
     "....."
     "....."),
    name="NRight",
)  # fmt: skip

n_down = Orientation(
    ("..X.."
     ".XX.."
     ".X..."
     ".X..."
     "....."),
    name="NDown",
)  # fmt: skip

n_left = Orientation(
    ("....."
     "XXX.."
     "..XX."
     "....."
     "....."),
    name="NLeft",
    spawn=True,
    next_offset_x=4,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

n = Piece(
    name="N",
    tile_index=0x7C,
    stats_addr=0x2978, #29B8,
    orientations=[
        n_up,
        n_right,
        n_down,
        n_left,
    ],
)

g_up = Orientation(
    (".X..."
     ".X..."
     ".XX.."
     "..X.."
     "....."),
    name="GUp",
)  # fmt: skip

g_right = Orientation(
    ("....."
     ".XXX."
     "XX..."
     "....."
     "....."),
    name="GRight",
    spawn=True,
    next_offset_x=4,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

g_down = Orientation(
    (".X..."
     ".XX.."
     "..X.."
     "..X.."
     "....."),
    name="GDown",
)  # fmt: skip

g_left = Orientation(
    ("....."
     "..XX."
     "XXX.."
     "....."
     "....."),
    name="GLeft",
)  # fmt: skip

g = Piece(
    name="G",
    tile_index=0x7D,
    stats_addr=0x2970, #29B0,
    orientations=[
        g_up,
        g_right,
        g_down,
        g_left,
    ],
)


t_up = Orientation(
    ("....."
     "..X.."
     "..X.."
     ".XXX."
     "....."),
    name="TUp",
)  # fmt: skip

t_right = Orientation(
    ("....."
     ".X..."
     ".XXX."
     ".X..."
     "....."),
    name="TRight",
)  # fmt: skip

t_down = Orientation(
    ("....."
     ".XXX."
     "..X.."
     "..X.."
     "....."),
    name="TDown",
    spawn=True,
    next_offset_y=4,
    spawn_offset_y=1,
)  # fmt: skip

t_left = Orientation(
    ("....."
     "...X."
     ".XXX."
     "...X."
     "....."),
    name="TLeft",
)  # fmt: skip

t = Piece(
    name="T",
    tile_index=0x7B,
    stats_addr=0x29E8, #2A08,
    orientations=[
        t_up,
        t_right,
        t_down,
        t_left,
    ],
)

u_up = Orientation(
    ("....."
     "....."
     ".X.X."
     ".XXX."
     "....."),
    name="UUp",
)  # fmt: skip

u_right = Orientation(
    ("....."
     ".XX.."
     ".X..."
     ".XX.."
     "....."),
    name="URight",
)  # fmt: skip

u_down = Orientation(
    ("....."
     ".XXX."
     ".X.X."
     "....."
     "....."),
    spawn=True,
    next_offset_y=8,
    spawn_offset_y=1,
    name="UDown",
)  # fmt: skip

u_left = Orientation(
    ("....."
     "..XX."
     "...X."
     "..XX."
     "....."),
    name="ULeft",
)  # fmt: skip

u = Piece(
    name="U",
    tile_index=0x7B,
    stats_addr=0x28E8,
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
    next_offset_y=4,
    spawn_offset_y=1,
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
    tile_index=0x7B,
    stats_addr=0x2968, #29A8,
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
    next_offset_y=4,
    spawn_offset_y=1,
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
    tile_index=0x7B,
    stats_addr=0x2928, #0x2948,
    orientations=[
        w_up,
        w_right,
        w_down,
        w_left,
    ],
)


y1_left = Orientation(
    ("..X.."
     "..X.."
     ".XX.."
     "..X.."
     "....."),
    name="Y1Left",
)  # fmt: skip


y1_up = Orientation(
    ("....."
     ".X..."
     "XXXX."
     "....."
     "....."),
    name="Y1Up",
)  # fmt: skip

y1_right = Orientation(
    (".X..."
     ".XX.."
     ".X..."
     ".X..."
     "....."),
    name="Y1Right",
)  # fmt: skip

y1_down = Orientation(
    ("....."
     "XXXX."
     "..X.."
     "....."
     "....."),
    name="Y1Down",
    spawn=True,
    next_offset_x=4,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

y1 = Piece(
    name="Y1",
    tile_index=0x7D,
    stats_addr=0x2930, #2950,
    orientations=[
        y1_left,
        y1_up,
        y1_right,
        y1_down,
    ],
)


y2_right = Orientation(
    (".X..."
     ".X..."
     ".XX.."
     ".X..."
     "....."),
    name="Y2Right",
)  # fmt: skip


y2_down = Orientation(
    ("....."
     "XXXX."
     ".X..."
     "....."
     "....."),
    name="Y2Down",
    spawn=True,
    next_offset_x=4,
    next_offset_y=8,
    spawn_offset_y=1,
)  # fmt: skip

y2_left = Orientation(
    ("..X.."
     ".XX.."
     "..X.."
     "..X.."
     "....."),
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
    tile_index=0x7C,
    stats_addr=0x2938, #2958,
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
    next_offset_x=0,
    next_offset_y=4,
)  # fmt: skip

i = Piece(
    stats_addr=0x2A28, #2AC8,
    name="I",
    tile_index=0x7B,
    orientations=[
        i_horizontal,
        i_vertical,
    ],
)

t4_up = Orientation(
    ("....."
     "..X.."
     ".XXX."
     "....."
     "....."),
    name="T4Up",
)  # fmt: skip

t4_right = Orientation(
    ("....."
     "..X.."
     "..XX."
     "..X.."
     "....."),
    name="T4Right",
)  # fmt: skip

t4_down = Orientation(
    ("....."
     "....."
     ".XXX."
     "..X.."
     "....."),
    name="T4Down",
    spawn=True,
)  # fmt: skip

t4_left = Orientation(
    ("....."
     "..X.."
     ".XX.."
     "..X.."
     "....."),
    name="T4Left",
)  # fmt: skip

t4 = Piece(
    name="T4",
    tile_index=0x7B,
    stats_addr=0x2A68, #2B06,
    orientations=[
        t4_up,
        t4_right,
        t4_down,
        t4_left,
    ],
)


j4_left = Orientation(
    ("....."
     "..X.."
     "..X.."
     ".XX.."
     "....."),
    name="J4Left",
)  # fmt: skip


j4_up = Orientation(
    ("....."
     ".X..."
     ".XXX."
     "....."
     "....."),
    name="J4Up",
)  # fmt: skip

j4_right = Orientation(
    ("....."
     "..XX."
     "..X.."
     "..X.."
     "....."),
    name="J4Right",
)  # fmt: skip

j4_down = Orientation(
    ("....."
     "....."
     ".XXX."
     "...X."
     "....."),
    name="J4Down",
    spawn=True,
    next_offset_x=0,
)  # fmt: skip

j4 = Piece(
    name="J4",
    tile_index=0x7D,
    stats_addr=0x2A70, #2B0C,
    orientations=[
        j4_left,
        j4_up,
        j4_right,
        j4_down,
    ],
)


z4_horizontal = Orientation(
    ("....."
     "....."
     ".XX.."
     "..XX."
     "....."),
    name="Z4Horizontal",
    spawn=True,
    next_offset_y=0,
    spawn_offset_y=0,
)  # fmt: skip

z4_vertical = Orientation(
    ("....."
     "...X."
     "..XX."
     "..X.."
     "....."),
    name="Z4Vertical",
)  # fmt: skip

z4 = Piece(
    name="Z4",
    tile_index=0x7C,
    stats_addr=0x2AB8, #2B12,
    orientations=[
        z4_horizontal,
        z4_vertical,
    ],
)


o4_solo = Orientation(
    ("....."
     ".XX.."
     ".XX.."
     "....."
     "....."),
    name="04Solo",
    spawn=True,
    next_offset_y=8,
    next_offset_x=4,
    spawn_offset_y=1,
)  # fmt: skip


o4 = Piece(
    name="O4",
    tile_index=0x7B,
    stats_addr=0x2AA8, #2B18,
    orientations=[
        o4_solo,
    ],
)


s4_horizontal = Orientation(
    ("....."
     "....."
     "..XX."
     ".XX.."
     "....."),
    name="S4Horizontal",
    spawn=True,
    next_offset_y=0,
    spawn_offset_y=0,
)  # fmt: skip

s4_vertical = Orientation(
    ("....."
     "..X.."
     "..XX."
     "...X."
     "....."),
    name="S4Vertical",
)  # fmt: skip

s4 = Piece(
    name="S4",
    tile_index=0x7D,
    stats_addr=0x2AB0, #2B48,
    orientations=[
        s4_horizontal,
        s4_vertical,
    ],
)


l4_right = Orientation(
    ("....."
     "..X.."
     "..X.."
     "..XX."
     "....."),
    name="L4Right",
)  # fmt: skip

l4_down = Orientation(
    ("....."
     "....."
     ".XXX."
     ".X..."
     "....."),
    name="L4Down",
    spawn=True,
    next_offset_x=0,
)  # fmt: skip

l4_left = Orientation(
    ("....."
     ".XX.."
     "..X.."
     "..X.."
     "....."),
    name="L4Left",
)  # fmt: skip

l4_up = Orientation(
    ("....."
     "...X."
     ".XXX."
     "....."
     "....."),
    name="L4Up",
)  # fmt: skip

l4 = Piece(
    name="L4",
    tile_index=0x7C,
    stats_addr=0x2A78, #2B4E,
    orientations=[
        l4_right,
        l4_down,
        l4_left,
        l4_up,
    ],
)


i4_horizontal = Orientation(
    ("..X.."
     "..X.."
     "..X.."
     "..X.."
     "....."),
    name="I4Vertical",
)  # fmt: skip

i4_vertical = Orientation(
    ("....."
     "....."
     "XXXX."
     "....."
     "....."),
    name="I4Horizontal",
    spawn=True,
    next_offset_x=4,
    next_offset_y=4,
)  # fmt: skip

i4 = Piece(
    stats_addr=0x2AE8, #2B54,
    name="I4",
    tile_index=0x7B,
    orientations=[
        i4_horizontal,
        i4_vertical,
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


weight_table = {
    i: 27,
    j: 17,
    l: 17,
    x: 3,
    s: 7,
    z: 7,
    n: 18,
    g: 18,
    u: 16,
    t: 12,
    f1: 4,
    f2: 4,
    p: 27,
    q: 27,
    w: 11,
    y1: 16,
    y2: 16,
    v: 9,
}


weight_table_tetriminos = {
    i: 9,
    j: 9,
    l: 9,
    x: 8,
    s: 9,
    z: 9,
    n: 9,
    g: 9,
    u: 9,
    t: 9,
    f1: 9,
    f2: 9,
    p: 9,
    q: 9,
    w: 8,
    y1: 9,
    y2: 9,
    v: 9,
    t4: 9,
    j4: 9,
    z4: 8,
    o4: 9,
    s4: 8,
    l4: 9,
    i4: 9,
    i1: 9,
    i2: 9,
    v3: 8,
    i3: 9,
}


# weight_table_tetriminos = {
#     i: 50,
#     j: 1,
#     l: 1,
#     x: 1,
#     s: 1,
#     z: 1,
#     n: 1,
#     g: 1,
#     u: 1,
#     t: 1,
#     f1: 50,
#     f2: 1,
#     p: 1,
#     q: 1,
#     w: 1,
#     y1: 1,
#     y2: 1,
#     v: 50,
#     t4: 26,
#     j4: 1,
#     z4: 1,
#     o4: 1,
#     s4: 1,
#     l4: 1,
#     i4: 1,
#     i1: 1,
#     i2: 56,
#     v3: 1,
#     i3: 1,
# }


table = OrientationTable(
    [
        f1,
        f2,
        j,
        l,
        x,
        s,
        z,
        q,
        p,
        n,
        g,
        t,
        u,
        v,
        w,
        y1,
        y2,
        i,
        t4,
        j4,
        z4,
        o4,
        s4,
        l4,
        i4,
        i1,
        i2,
        v3,
        i3,
        hidden,
    ]
)
