import pathlib
import tkinter as tk
from collections import deque
from tkinter import filedialog as fd
from tkinter import ttk
from tkinter.messagebox import showinfo

import nametable_builder
import numpy as np
from PIL import Image, ImageTk, ImageOps, ImageColor

TILE_DISPLAY = 29

SCROLLBACK = 10

HELP_TEXT = """Arrow keys to move around or something
something else

"""


class TileHelper:
    def __init__(self):
        self.scroll = deque(maxlen=SCROLLBACK)
        self.chrmap_images = {}
        self.selected_images = {}
        self.current_images = {}
        self.selected_and_current = {}
        self.selected_overlay = Image.new(
            size=(TILE_DISPLAY, TILE_DISPLAY),
            color=(0, 0, 255),
            mode="RGB",
        )
        self.current_overlay = Image.new(
            size=(TILE_DISPLAY, TILE_DISPLAY),
            color=(255, 255, 0),
            mode="RGB",
        )
        self.selected_and_current_overlay = Image.new(
            size=(TILE_DISPLAY, TILE_DISPLAY),
            color=(0, 255, 0),
            mode="RGB",
        )
        self.nt_elements = {}
        self.selected_tiles = [False for _ in range(256)]
        self.root = tk.Tk()
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
        self.help.bind("<Key>", lambda e: "break")
        self.help.insert("1.0", HELP_TEXT)

    def textbox_setup(self):
        self.text = tk.Text(
            self.root,
            bg="green",
            foreground="white",
            height=SCROLLBACK,
        )
        self.text.grid(
            row=2,
            column=0,
            columnspan=2,
            rowspan=2,
            sticky=tk.W + tk.E,
        )
        self.text.bind("<Key>", lambda e: "break")

    def print(self, message):
        self.text.delete("1.0", tk.END)
        self.scroll.append(message)
        self.text.insert("1.0", "\n".join(self.scroll))

    def tile_click(self, event: tk.Event):
        y = event.y // TILE_DISPLAY
        x = event.x // TILE_DISPLAY
        index = y * 16 + x
        self.print(f"button clicked! -> {event}")
        self.selected_tiles[index] = not (self.selected_tiles[index])
        self.render_chr(index)

    def nametable_click(self, event: tk.Event):
        selected = [
            index for index, tile in enumerate(self.selected_tiles) if tile is not False
        ]
        y = event.y // TILE_DISPLAY
        x = event.x // TILE_DISPLAY
        index = y * 32 + x
        self.print(f"Clicked on {index}")
        if not selected:
            self.print(f"Nothing is selected!")
            return
        while True:
            next_square = self.nametable_data[index] + 1
            if next_square == 256:
                next_square = 0
            elif next_square != 255:
                next_square %= 255
            print(f"{next_square=}")
            self.nametable_data[index] = next_square
            if self.nametable_data[index] in selected:
                break
        self.print(str(selected))
        self.render_tile(index)

    def chrmap_frame_setup(self):
        self.chrmap_frame = tk.Canvas(
            bg="blue",
            width=TILE_DISPLAY * 16,
            height=TILE_DISPLAY * 16,
        )
        self.chrmap_frame.bind(
            "<Button 1>",
            self.tile_click,
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
                resized = resized.convert("RGB")

                image = ImageTk.PhotoImage(resized)
                self.chrmap_images[index] = image

                selected = Image.blend(self.selected_overlay, resized, 0.7)
                selected_image = ImageTk.PhotoImage(selected)
                self.selected_images[index] = selected_image

                self.render_chr(index)
        self.nametable_button.configure(state=tk.ACTIVE)

    def render_chr(self, index: int):
        y, x = divmod(index, 16)
        if self.selected_tiles[index]:
            image = self.selected_images[index]
        else:
            image = self.chrmap_images[index]
        self.chrmap_frame.create_image(
            x * TILE_DISPLAY,
            y * TILE_DISPLAY,
            anchor=tk.NW,
            image=image,
        )

    def load_nametable(self):
        filetypes = (
            ("Binary file", "*.bin"),
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
        self.nametable_data = data
        self.render_nametable()

    def render_nametable(self):
        if not self.chrmap_images:
            self.print("can't render.  chrmap not yet loaded")
            return
        for index in range(960):
            self.render_tile(index)

    def render_tile(self, index: int):
        tile = self.nametable_data[index]
        y, x = divmod(index, 32)
        self.nametable_canvas.create_image(
            x * TILE_DISPLAY,
            y * TILE_DISPLAY,
            anchor=tk.NW,
            image=self.chrmap_images[tile],
        )


TileHelper()
