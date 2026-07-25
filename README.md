# TinyTetris

A tiny Tetris game written in PureBasic, sharing the same project style as [TinyGomoku](https://github.com/jiowcl/TinyGomoku).  

![PureBasic](https://img.shields.io/badge/language-PureBasic-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

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

Buttons: **Restart**, **Pause**, **Sound**. High score and sound preference are stored in `TinyTetris.ini` next to the executable.

## Features

- 10×20 playfield (2 hidden spawn rows)
- 7 tetrominoes with simple wall kicks
- 7-bag randomizer
- Ghost piece, Hold, Next preview
- Soft / hard drop, DAS left-right repeat
- Lock delay, line-clear flash
- Nintendo-style scoring and level speed-up
- Optional WAV cues under `TinyTetris/Sound/`

## License

Copyright (c) 2026 Ji-Feng Tsai.  
Copyright (c) 効果音ラボ.  
Code released under the MIT license.  

## Donation  

If this application help you reduce time to coding, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/TW/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3RNMD6Q3B495N&source=url)

[Paypal Me](https://paypal.me/jiowcl?locale.x=zh_TW)
