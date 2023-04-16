import pathlib
import tkinter as tk
from collections import deque
from tkinter import filedialog as fd
from tkinter import ttk

import nametable_builder
import numpy as np
from PIL import Image, ImageTk

TILE_DISPLAY = 29

SCROLLBACK = 10

HELP_TEXT = """Arrow Keys:  Move around nametable
WASD: Change tile
Ctrl+Z: Undo
Ctrl+Alt+R: Restore original
"""


# Not in use yet.  Taken from:  https://www.nesdev.org/wiki/PPU_palettes
palette_rgb = [
    [84, 84, 84],
    [0, 30, 116],
    [8, 16, 144],
    [48, 0, 136],
    [68, 0, 100],
    [92, 0, 48],
    [84, 4, 0],
    [60, 24, 0],
    [32, 42, 0],
    [8, 58, 0],
    [0, 64, 0],
    [0, 60, 0],
    [0, 50, 60],
    [0, 0, 0],
    [152, 150, 152],
    [8, 76, 196],
    [48, 50, 236],
    [92, 30, 228],
    [136, 20, 176],
    [160, 20, 100],
    [152, 34, 32],
    [120, 60, 0],
    [84, 90, 0],
    [40, 114, 0],
    [8, 124, 0],
    [0, 118, 40],
    [0, 102, 120],
    [0, 0, 0],
    [236, 238, 236],
    [76, 154, 236],
    [120, 124, 236],
    [176, 98, 236],
    [228, 84, 236],
    [236, 88, 180],
    [236, 106, 100],
    [212, 136, 32],
    [160, 170, 0],
    [116, 196, 0],
    [76, 208, 32],
    [56, 204, 108],
    [56, 180, 204],
    [60, 60, 60],
    [236, 238, 236],
    [168, 204, 236],
    [188, 188, 236],
    [212, 178, 236],
    [236, 174, 236],
    [236, 174, 212],
    [236, 180, 176],
    [228, 196, 144],
    [204, 210, 120],
    [180, 222, 120],
    [168, 226, 144],
    [152, 226, 180],
    [160, 214, 228],
    [160, 162, 160],
]


class TileHelper:
    def __init__(self):
        self.scroll = deque(maxlen=SCROLLBACK)
        self.chrmap_images = {}
        self.highlighted_images = {}
        self.nametable_data_displayed = []
        self.nametable_data_modified = []
        self.nametable_data_original = []
        self.undo_bucket = []
        self.highlighted_overlay = Image.new(
            size=(TILE_DISPLAY, TILE_DISPLAY),
            color=(255, 255, 0),
            mode="RGB",
        )
        self.nt_elements = {}
        self.current_nt_tile = 0
        self.current_chr_tile = None
        self.root = tk.Tk()
        self.root.bind("<KeyPress>", self.on_key_press)
        self.root.title("Tkinter Open File Dialog")
        self.root.resizable(width=True, height=True)
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_columnconfigure(1, weight=1)
        self.root.grid_columnconfigure(2, weight=1)
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_rowconfigure(2, weight=1)
        self.root.grid_rowconfigure(3, weight=1)
        self.chrmap_frame_setup()
        self.nametable_frame_setup()
        self.chrmap_button_setup()
        self.nametable_button_setup()
        self.textbox_setup()
        self.helpbox_setup()
        self.root.mainloop()

    def change_chr_tile(self, x: int = 0, y: int = 0):
        if self.current_chr_tile is None:
            self.print(f"change_chr_tiled called without a current_chr_tile set")
            return
        old_y, old_x = divmod(self.current_chr_tile, 16)
        x, y = old_x + x, old_y + y
        if x < 0:
            x = 15
        if x > 15:
            x = 0
        if y < 0:
            y = 15
        if y > 15:
            y = 0
        new_tile = y * 16 + x
        self.highlight_chr_tile(new_tile)
        self.nametable_data_displayed[self.current_nt_tile] = new_tile
        self.update_nt_tile()

    def change_nt_tile(self, x: int = 0, y: int = 0):
        self.commit_tile()
        old_y, old_x = divmod(self.current_nt_tile, 32)
        x, y = old_x + x, old_y + y
        if x < 0:
            x = 31
        if x > 31:
            x = 0
        if y < 0:
            y = 29
        if y > 29:
            y = 0
        self.nametable_data_displayed[
            self.current_nt_tile
        ] = self.nametable_data_modified[self.current_nt_tile]
        self.clear_nt_tile_highlight()
        self.current_nt_tile = y * 32 + x
        self.highlight_chr_tile(self.nametable_data_displayed[self.current_nt_tile])
        self.update_nt_tile()

    def undo(self):
        if not self.undo_bucket:
            self.print(f"Nothing to undo")
            return
        self.clear_nt_tile_highlight()
        old_tile, old_nt_location = self.undo_bucket.pop()
        self.current_nt_tile = old_nt_location
        self.nametable_data_displayed[
            self.current_nt_tile
        ] = self.nametable_data_modified[self.current_nt_tile] = old_tile
        self.highlight_chr_tile(self.nametable_data_displayed[self.current_nt_tile])
        self.update_nt_tile()

    def commit_tile(self):
        if (
            self.nametable_data_modified[self.current_nt_tile]
            == self.nametable_data_displayed[self.current_nt_tile]
        ):
            self.print(f"Nothing has changed.  Skipping")
            return
        old_tile = self.nametable_data_modified[self.current_nt_tile]
        old_nt_location = self.current_nt_tile
        undo = (old_tile, old_nt_location)
        self.undo_bucket.append(undo)
        self.print(
            f"Committing nametable tile #{self.current_nt_tile} to chr index #{self.current_chr_tile}. {undo=}"
        )
        self.nametable_data_modified[
            self.current_nt_tile
        ] = self.nametable_data_displayed[self.current_nt_tile]

    def on_key_press(self, event: tk.Event):
        match event.keycode, event.char:
            case (_, "w"):
                self.print("chr up")
                self.change_chr_tile(y=-1)
            case (_, "a"):
                self.print("chr left")
                self.change_chr_tile(x=-1)
            case (_, "s"):
                self.print("chr down")
                self.change_chr_tile(y=1)
            case (_, "d"):
                self.print("chr right")
                self.change_chr_tile(x=1)
            case (111, _):
                self.print("tile up")
                self.change_nt_tile(y=-1)
            case (113, _):
                self.print("tile left")
                self.change_nt_tile(x=-1)
            case (116, _):
                self.print("tile down")
                self.change_nt_tile(y=1)
            case (114, _):
                self.print("tile right")
                self.change_nt_tile(x=1)
            case (37, ""):
                pass  # Control pressed by itself
            case (52, "\x1a"):
                self.print("Undo")  # ctrl+z
                self.undo()
            case (27, "\x12"):  # ctrl + alt + r
                self.restore_original()
            case _:
                self.print(f"Something else: {event.char=} {event.keycode=}")

    def restore_original(self):
        self.print("Restoring original")
        self.nametable_data_modified = self.nametable_data_original.copy()
        self.nametable_data_displayed = self.nametable_data_original.copy()
        self.render_nametable()

    def print(self, message):
        self.scroll.extend(message.splitlines())
        self.text.config(state="normal")
        self.text.delete("1.0", tk.END)
        self.text.insert("1.0", "\n".join(self.scroll))
        self.text.config(state="disabled")

    def nametable_click(self, event: tk.Event):
        if not self.nametable_data_displayed:
            self.print(f"Nametable not loaded yet.")
            return
        y = event.y // TILE_DISPLAY
        x = event.x // TILE_DISPLAY
        index = y * 32 + x
        self.print(f"Clicked on {index}")

    def chrmap_button_setup(self):
        self.chrmap_button = ttk.Button(
            self.root,
            text="Open CHR Map",
            command=self.load_chrmap,
        )
        self.chrmap_button.grid(
            column=2,
            row=2,
            sticky=tk.NSEW,
        )

    def nametable_button_setup(self):
        self.nametable_button = ttk.Button(
            self.root,
            text="Open Nametable",
            command=self.load_nametable,
            state=tk.DISABLED,
        )
        self.nametable_button.grid(
            column=2,
            row=3,
            sticky=tk.NSEW,
        )

    def helpbox_setup(self):
        self.help = tk.Text(
            self.root,
            height=10,
            # bg="green",
            # foreground="white",
        )
        self.help.grid(
            row=0,
            column=0,
            sticky=tk.NSEW,
        )
        self.help.insert("1.0", HELP_TEXT)
        self.help.config(state="disabled")

    def textbox_setup(self):
        self.text = tk.Text(
            self.root,
            bg="green",
            foreground="white",
            height=SCROLLBACK + 1,
        )
        self.text.grid(
            row=2,
            column=0,
            columnspan=2,
            rowspan=2,
            sticky=tk.W + tk.E,
        )

    def chrmap_frame_setup(self):
        self.chrmap_frame = tk.Canvas(
            # bg="blue",
            width=TILE_DISPLAY * 16,
            height=TILE_DISPLAY * 16,
        )
        self.chrmap_frame.grid(
            column=0,
            row=1,
            sticky=tk.NSEW,
        )

    def nametable_frame_setup(self):
        self.nametable_canvas = tk.Canvas(
            self.root,
            width=32 * TILE_DISPLAY,
            height=30 * TILE_DISPLAY,
            bg="blue",
        )
        self.nametable_canvas.bind("<Button 1>", self.nametable_click)
        self.nametable_canvas.grid(
            column=1,
            row=0,
            rowspan=2,
            columnspan=2,
        )

    def load_chrmap(self):
        filetypes = (
            ("PNG File", "*.png"),
            ("All files", "*.*"),
        )

        filename = fd.askopenfilename(
            title="Open a file",
            initialdir=pathlib.Path.cwd() / "gfx",
            filetypes=filetypes,
        )
        if not filename:
            self.print(f"No filename selected!")
            return
        self.pillow_image = Image.open(filename)
        self.print(f"Opened: {self.pillow_image}")

        array = np.asarray(self.pillow_image, dtype=np.uint8)

        for y in range(16):
            for x in range(16):
                index = x | (y << 4)
                slice_y = y * 8
                slice_x = x * 8
                tile = Image.fromarray(
                    array[slice_y : slice_y + 8, slice_x : slice_x + 8]
                )
                resized = tile.resize((TILE_DISPLAY, TILE_DISPLAY))

                image = ImageTk.PhotoImage(resized)
                self.chrmap_images[index] = image
                self.print(f"{resized.mode=} {self.highlighted_overlay.mode=}")

                highlighted = Image.blend(
                    self.highlighted_overlay, resized.convert("RGB"), 0.7
                )
                highlighted_image = ImageTk.PhotoImage(highlighted)
                self.highlighted_images[index] = highlighted_image

                self.render_chr_tile(index)
        self.nametable_button.configure(state=tk.ACTIVE)

    def highlight_chr_tile(self, index: int):
        self.print(f"old: {self.current_chr_tile} new: {self.current_chr_tile}")
        if index == self.current_chr_tile:
            self.print(f"Old is same as new ({index=} {self.current_chr_tile=})")
            return
        old_chr_tile = self.current_chr_tile
        self.current_chr_tile = index
        self.render_chr_tile(self.current_chr_tile)
        if old_chr_tile is not None:
            self.render_chr_tile(old_chr_tile)

    def render_chr_tile(self, index: int):
        y, x = divmod(index, 16)
        if self.chrmap_images.get(index) is None:
            self.print(f"chrmap images not loaded yet")
            return
        if index == self.current_chr_tile:
            image = self.highlighted_images[index]
            self.print(f"Rendering highlighted tile {index}")
        else:
            self.print(f"Rendering non-highlighted tile {index}")
            image = self.chrmap_images[index]
        self.chrmap_frame.create_image(
            x * TILE_DISPLAY,
            y * TILE_DISPLAY,
            anchor=tk.NW,
            image=image,
        )

    def load_nametable(self):
        filetypes = (
            ("Binary file", ".bin .bak"),
            ("All files", "*.*"),
        )

        filename = fd.askopenfilename(
            title="Open a file",
            initialdir=pathlib.Path.cwd() / "gfx" / "nametables",
            filetypes=filetypes,
        )
        (
            start_addresses,
            lengths,
            data,
            original_sha1sum,
        ) = nametable_builder.extract_bytes_from_nametable(filename)
        if not filename:
            self.print(f"No filename selected!")
            return
        self.nametable_data_displayed = data
        self.nametable_data_modified = data.copy()
        self.nametable_data_original = data.copy()
        self.render_nametable()
        self.highlight_chr_tile(self.nametable_data_displayed[self.current_nt_tile])

    def render_nametable(self):
        if not self.chrmap_images:
            self.print("can't render.  chrmap not yet loaded")
            return
        for index in range(960):
            self.render_nt_tile(index)

    def render_nt_tile(self, index: int):
        y, x = divmod(index, 32)
        tile = self.nametable_data_displayed[index]
        if index == self.current_nt_tile:
            image = self.highlighted_images[tile]
        else:
            image = self.chrmap_images[tile]
        self.nametable_canvas.create_image(
            x * TILE_DISPLAY,
            y * TILE_DISPLAY,
            anchor=tk.NW,
            image=image,
        )

    def clear_nt_tile_highlight(self):
        y, x = divmod(self.current_nt_tile, 32)
        image = self.chrmap_images[self.nametable_data_modified[self.current_nt_tile]]
        self.nametable_canvas.create_image(
            x * TILE_DISPLAY,
            y * TILE_DISPLAY,
            anchor=tk.NW,
            image=image,
        )

    def update_nt_tile(self):
        y, x = divmod(self.current_nt_tile, 32)
        image = self.highlighted_images[self.current_chr_tile]
        self.nametable_canvas.create_image(
            x * TILE_DISPLAY,
            y * TILE_DISPLAY,
            anchor=tk.NW,
            image=image,
        )


TileHelper()
