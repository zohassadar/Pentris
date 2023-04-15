import pathlib
import tkinter as tk
from collections import deque
from tkinter import filedialog as fd
from tkinter import ttk
from tkinter.messagebox import showinfo

import nametable_builder
import numpy as np
from PIL import Image, ImageTk

TILE_DISPLAY = 24

SCROLLBACK = 10


class TileHelper:
    def __init__(self):
        self.scroll = deque(maxlen=SCROLLBACK)
        self.selected_tiles = []
        self.root = tk.Tk()
        self.root.title("Tkinter Open File Dialog")
        self.root.resizable(width=True, height=True)

        self.chrmap_frame_setup()
        self.nametable_frame_setup()
        self.chrmap_button_setup()
        self.nametable_button_setup()
        self.textbox_setup()
        self.root.mainloop()

    def chrmap_button_setup(self):
        self.chrmap_button = ttk.Button(
            self.root,
            text="Open CHR Map",
            command=self.load_chrmap,
        )
        self.chrmap_button.grid(
            column=3,
            row=3,
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
            column=3,
            row=4,
            sticky=tk.NSEW,
        )

    def textbox_setup(self):
        self.text = tk.Label(
            self.root,
            width=((TILE_DISPLAY + 5) * 18) // 4,
            height=SCROLLBACK,
            bg="black",
            fg="white",
            text="",
            font=("Consolas", 10),
            anchor=tk.W,
            justify=tk.LEFT,
        )
        self.text.grid(row=18, column=1, columnspan=3)

    def print(self, message):
        self.scroll.append(message)
        self.text.config(text="\n".join(self.scroll))

    def tile_click(self, event: tk.Event):
        self.print(f"button clicked! -> {event}")
        state = event.widget.cget("state")
        self.print(f"{state=}")
        if state == "disabled":
            event.widget.configure(bg="yellow", state="normal")
        else:
            event.widget.configure(bg="green", state="disabled")
        self.selected_tiles = [
            i for i, c in self.chr_elements.items() if c.cget("state") == "normal"
        ]
        self.print(str(self.selected_tiles))

    def nametable_click(self, event: tk.Event):
        y = event.y // TILE_DISPLAY
        x = event.x // TILE_DISPLAY
        index = y * 32 + x
        self.print(f"Clicked on {index}")
        if not self.selected_tiles:
            self.print(f"Nothing is selected!")
            return
        while True:
            self.nametable_data[index] = (self.nametable_data[index] + 1) % 255
            if self.nametable_data[index] in self.selected_tiles:
                break
        self.render_nametable()

    def chrmap_frame_setup(self):
        self.chr_elements: dict[int, tk.Canvas] = {}
        self.row_indexex = {}
        self.col_indexex = {}
        self.chrmap_frame = tk.Frame(
            bg="blue",
        )
        self.chrmap_frame.grid(
            column=1,
            row=1,
            rowspan=17,
        )
        for row in range(16):
            label = tk.Label(
                self.chrmap_frame,
                text=f"{row:x}".upper(),
            )
            label.grid(
                row=0,
                column=row + 1,
            )
            self.row_indexex[row] = label

        for column in range(16):
            label = tk.Label(
                self.chrmap_frame,
                text=f"{column:x}".upper(),
            )
            label.grid(
                row=column + 1,
                column=0,
            )
            self.col_indexex[column] = label

        for y in range(16):
            for x in range(16):
                # label =
                index = (y * 16) + x
                canvas = tk.Canvas(
                    self.chrmap_frame,
                    width=TILE_DISPLAY,
                    height=TILE_DISPLAY,
                    bg="green",
                    border=1,
                    state="disabled",
                    # highlightthickness=1,
                )
                canvas.bind("<Button 1>", self.tile_click)
                canvas.grid(
                    row=y + 1,
                    column=x + 1,
                    sticky=tk.NSEW,
                )

                self.chr_elements[index] = canvas

    def nametable_frame_setup(self):
        self.nt_elements = {}
        self.nametable_canvas = tk.Canvas(
            self.root,
            width=32 * TILE_DISPLAY,
            height=30 * TILE_DISPLAY,
            bg="blue",
        )
        self.nametable_canvas.bind("<Button 1>", self.nametable_click)
        self.nametable_canvas.grid(column=2, row=1)

    def load_chrmap(self):
        self.chrmap_images = {}
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
                self.chr_elements[index].create_image(
                    TILE_DISPLAY // 2,
                    TILE_DISPLAY // 2,
                    anchor=tk.CENTER,
                    image=self.chrmap_images[index],
                )

        self.nametable_button.configure(state=tk.ACTIVE)

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
        for index, d in enumerate(self.nametable_data[:960]):
            y, x = divmod(index, 32)
            self.nametable_canvas.create_image(
                x * TILE_DISPLAY,
                y * TILE_DISPLAY,
                anchor=tk.NW,
                image=self.chrmap_images[d],
            )

        # showinfo("This is something", message=len(filename.read()))
        # image = tk.PhotoImage(data=filename.read(), format="png")
        # self.chrmap.create_image(0, 0, anchor=tk.NW, image=image)
        # self.open_nametable.configure(state=tk.ACTIVE)


TileHelper()
