import tkinter as tk
from tkinter import ttk
from tkinter import filedialog as fd

from tkinter.messagebox import showinfo
import pathlib

from PIL import Image, ImageTk

import nametable_builder
import numpy as np
import itertools

import sys


class TileHelper:
    def log_button(self, event):
        print(f"button clicked! -> {event}", file=sys.stderr)

    def chrmap_frame_setup(self):
        self.chr_elements = {}
        self.row_index = {}
        self.col_index = {}
        self.chrmap_frame = tk.Frame(bg="blue")
        self.chrmap_frame.grid(column=1, row=1, rowspan=17)
        for row in range(16):
            self.row_index[row] = tk.Label(self.chrmap_frame, text=f"{row:x}".upper())
            self.row_index[row].grid(row=0, column=row + 1)

        for column in range(16):
            label = tk.Label(
                self.chrmap_frame,
                text=f"{column:x}".upper(),
            )
            label.grid(row=column + 1, column=0)

            self.col_index[column] = label

        for y in range(16):
            for x in range(16):
                # label =
                index = (y * 16) + x
                canvas = tk.Canvas(
                    self.chrmap_frame,
                    width=32,
                    height=32,
                    bg="green"
                    # border=1,
                    # highlightthickness=0,
                )
                canvas.bind("<Button 1>", self.log_button)
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
            width=32 * 32,
            height=30 * 32,
            bg="blue",
        )
        self.nametable_canvas.grid(column=2, row=1)

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Tkinter Open File Dialog")
        self.root.resizable(width=True, height=True)

        self.chrmap_frame_setup()
        self.nametable_frame_setup()

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

        self.root.grid_columnconfigure(1, weight=1)
        self.root.grid_columnconfigure(2, weight=1)
        self.root.grid_columnconfigure(3, weight=1)
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_rowconfigure(2, weight=1)
        self.root.mainloop()

    def load_chrmap_og(self):
        filetypes = (
            ("PNG File", "*.png"),
            ("All files", "*.*"),
        )

        filename = fd.askopenfile(
            "rb",
            title="Open a file",
            initialdir=pathlib.Path.cwd() / "gfx",
            filetypes=filetypes,
        )

        self.image = tk.PhotoImage(data=filename.read(), format="png")
        self.chrmap.create_image(0, 0, anchor=tk.NW, image=self.image)
        self.nametable_button.configure(state=tk.ACTIVE)

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
                resized = tile.resize((32, 32))
                self.chrmap_images[index] = ImageTk.PhotoImage(resized)
                self.chr_elements[index].create_image(
                    0,
                    0,
                    anchor=tk.NW,
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

        for index, d in enumerate(data[:960]):
            y, x = divmod(index, 32)
            self.nametable_canvas.create_image(
                x * 32,
                y * 32,
                anchor=tk.NW,
                image=self.chrmap_images[d],
            )

        # showinfo("This is something", message=len(filename.read()))
        # image = tk.PhotoImage(data=filename.read(), format="png")
        # self.chrmap.create_image(0, 0, anchor=tk.NW, image=image)
        # self.open_nametable.configure(state=tk.ACTIVE)


TileHelper()
