# Sound / Music assets

Optional files used by TinyTetris:

## SFX (WAV)

| File | Usage |
|------|--------|
| `100.wav` | Move |
| `101.wav` | Rotate |
| `102.wav` | Lock |
| `103.wav` | Line clear |
| `104.wav` | Tetris (4 lines) |
| `105.wav` | Hold |
| `106.wav` | Level up |
| `200.wav` | Game over |

## BGM (tracker module)

Place one of these next to the WAV files (first found wins):

| File | Format |
|------|--------|
| `bgm.xm` | FastTracker II (preferred) |
| `bgm.it` | Impulse Tracker |
| `bgm.mod` | ProTracker |
| `bgm.wav` | Waveform Audio File Format |

Played via PureBasic `LoadMusic` / `PlayMusic` (ModPlug). Keep volume moderate so SFX stay audible.

If a file is missing, the game still runs; that cue or BGM is skipped. When no BGM file is present, the **Music** checkbox is disabled.

Suggested sources: [効果音ラボ](https://soundeffect-lab.info/), [PANICPUMPKIN](https://pansound.com) for SFX; CC0 / royalty-free XM/IT modules for BGM (attribute the author in your fork if required).
