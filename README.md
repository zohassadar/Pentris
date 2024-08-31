# Pentris

This is NES tetris with an extra mino added.  This game includes 18 shapes each consisting of 5 blocks that must be pieced together on a 14x22 playfield, with completed rows being cleared.  It's like Tetris but with more frustration.

![Title](./assets/pentris.png)

# Release

This is released as a BPS patch file that can be applied to the USA version of tetris.nes using [Rom Patcher JS](https://www.romhacking.net/patch/) or any patching tool.

### Menu

![LevelMenu1](./assets/levelmenu1.png)

![LevelMenu2](./assets/levelmenu2.png)

### Gameplay

![AType](./assets/atype.png)

![BType](./assets/btype.png)

![Stats](./assets/stats.png)

![StatsTetriminos](./assets/stats_tetriminos.png)

### DAS
### ARR
### ARE CHARGE
### Tetriminos

![Tetriminos](./assets/tetriminos.png)

### Transition
### Marathon
### Seed

![Seed](./assets/seed.png)


# Build

### Requirements

* Python 3 along with the Pillow library.
* nodejs
* make
* gcc

### Included requirements

* [cc65](https://github.com/cc65/cc65)
* [nes-util](https://github.com/qalle2/nes-util)
* [flips](https://github.com/Alcaro/Flips)

### Compile

```
make
```

### Create patch

Place a romfile named clean.nes with an md5sum of `ec58574d96bee8c8927884ae6e7a2508` in the project directory.

```
make patch
```

### Thanks

[CelestialAmber](https://github.com/CelestialAmber/TetrisNESDisasm) Original Disassembly

[ejona86](https://github.com/ejona86) infofile from which disassembly was derived and RLE tools

[kirjavascript](https://github.com/kirjavascript/TetrisGYM) Menu & nametable tools

[HydrantDude](https://github.com/hydrantdude) Original DAS Controls code

[Kirby703](https://github.com/Kirby703) Original 0 Arr Code

[qalle2](https://github.com/qalle2) nes utils


