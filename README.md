# TinyTetris

A tiny Tetris game written in PureBasic.  

![GitHub](https://img.shields.io/github/license/jiowcl/TinyTetris.svg)
![PureBasic](https://img.shields.io/badge/language-PureBasic-blue.svg)
![Category](https://img.shields.io/badge/Game-Tetris-FFD166?style=flat-square&logoColor=black)

![Screenshot](./Screenshot/Demo1.png)

## Environment

- Windows 11 above (recommend)
- PureBasic 6.40 above (recommend)

## How to Build

Open `TinyTetris/TinyTetris.pbp` in PureBasic, or compile `TinyTetris/TinyTetris.pb` to `TinyTetris/Output/TinyTetris.exe`.

Module features require PureBasic 5.20 and above. Enable Unicode and save sources as UTF-8 with BOM.

## How to Play

| Key | Action |
|-----|--------|
| Left / Right | Move |
| Up / X | Rotate clockwise |
| Z | Rotate counter-clockwise |
| Down | Soft drop |
| Space | Hard drop |
| C / Shift | Hold |
| P | Pause |
| R | Restart |

Buttons: **Restart**, **Pause**, **Settings**, **Sound**, **Music**. Preferences are stored in `TinyTetris.ini` next to the executable.

## Features

- 10×20 playfield (2 hidden spawn rows)
- 7 tetrominoes with **SRS** orientations and wall-kick tables
- 7-bag randomizer, Next queue ×3, Hold (dimmed when used)
- Ghost piece, soft / hard drop with drop trail
- Settings panel for DAS / ARR / Music volume
- Lock delay with reset limit (15), lock flash, grounded pulse
- Line-clear flash → stack fall animation → spawn delay
- Guideline-style scoring: T-Spin / Mini, Back-to-Back, Combo
- Clear particles, level-up banner, clear message overlay
- Optional WAV SFX + tracker BGM (`bgm.xm` / `.it` / `.mod` / `.wav` under `Sound/`)
- Music pause-duck and game-over fade-out; missing BGM file is skipped safely

## License

Copyright (c) 2026 Ji-Feng Tsai.  
Copyright (c) 効果音ラボ.  
Copyright (c) PANICPUMPKIN.  
Code released under the MIT license.  

Icon: [AI Icon Generator](https://perchance.org/ai-icon-generator)  

## Donation  

If this application help you reduce time to coding, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/TW/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3RNMD6Q3B495N&source=url)

[Paypal Me](https://paypal.me/jiowcl?locale.x=zh_TW)
