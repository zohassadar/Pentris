from __future__ import annotations

import re
from dataclasses import dataclass


class InvalidPiece(Exception):
    ...


class OrientationBase:
    index_map = {
        0: 254,
        1: 255,
        2: 0,
        3: 1,
        4: 2,
    }


@dataclass
class HiddenOrientation(OrientationBase):
    length: int
    name = "Hidden"
    is_hidden = True

    def groups(self):
        results = []
        for i in range(self.length):
            results.append((2, [(2, True)]))
        return results


@dataclass(frozen=True, eq=True)
class Orientation(OrientationBase):
    orientation: str
    name: str
    spawn: bool = False
    next_offset_x: int = 0
    next_offset_y: int = 0
    spawn_offset_y: int = 0
    is_hidden = False

    def groups(self):
        results = []
        args = [iter(self.orientation)] * 5
        for y, row in enumerate(zip(*args)):
            results.append(
                (
                    y,
                    [
                        (x, True) if tile == "X" else (x, False)
                        for x, tile in enumerate(row)
                    ],
                )
            )
        return results


@dataclass
class Piece:
    name: str
    tile_index: int
    orientations: list[Orientation | HiddenOrientation]
    hidden: bool = False


@dataclass
class OrientationTable:
    pieces: list[Piece]


def output_bytes(row: list[int]):
    return "    .byte  " + ",".join(f"${i:02x}" for i in row)


def validate_table(table: OrientationTable):
    for piece in table.pieces:
        if piece.hidden:
            continue
        orientations_length = len(piece.orientations)
        if orientations_length > 5:
            raise InvalidPiece(
                f"Piece cannot have more than 5 orientations.  {piece.name} has {orientations_length}"
            )

        spawn_lengths = len([o for o in piece.orientations if o.spawn])
        if spawn_lengths > 1:
            raise InvalidPiece(
                f"Piece can only have 1 spawn orientation.  {piece.name} has {spawn_lengths}"
            )
        if not spawn_lengths:
            raise InvalidPiece(
                f"Piece must have 1 orientation.  {piece.name} has {spawn_lengths}"
            )

        for orientation in piece.orientations:
            orientation_length = len(orientation.orientation)
            if orientation_length > 25:
                raise InvalidPiece(
                    f"Orientation length must be exactly 25 characters.  {orientation.name} has {orientation_length}"
                )

            characters = re.findall(r"[^\.X]", orientation.orientation)
            if characters:
                raise InvalidPiece(
                    f"Orientation must only consist of 'X' or 'x'.  {orientation.name} contains: {''.join(characters)}"
                )

            squares_chars_len = len([c for c in orientation.orientation if c == "X"])
            if squares_chars_len != 5:
                raise InvalidPiece(
                    f"Orientation must contain 5 squares.  {orientation.name} has {squares_chars_len}"
                )
