;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

#APP_VERSION$     = "1.0"
#VERSION          = 1.0

; Playfield (2 hidden rows above for spawn)
#FIELD_W          = 10
#FIELD_H          = 22
#FIELD_VISIBLE_H  = 20
#FIELD_HIDDEN     = #FIELD_H - #FIELD_VISIBLE_H

; Pieces
#PIECE_I          = 0
#PIECE_O          = 1
#PIECE_T          = 2
#PIECE_S          = 3
#PIECE_Z          = 4
#PIECE_J          = 5
#PIECE_L          = 6
#PIECE_COUNT      = 7
#PIECE_NONE       = -1
#ROT_COUNT        = 4
#CELLS_PER_PIECE  = 4

; Game state
#STATE_PLAYING    = 0
#STATE_PAUSED     = 1
#STATE_LINECLEAR  = 2
#STATE_GAMEOVER   = 3

; Window / gadgets
#WIN_MAIN         = 0
#CANVAS           = 1
#BTN_RESTART      = 2
#BTN_PAUSE        = 3
#CHK_SOUND        = 4
#LBL_STATUS       = 5
#LBL_VERSION      = 6
#LBL_HELP         = 7

; Canvas
#CANVAS_DEFAULT_W = 420
#CANVAS_DEFAULT_H = 520

; Timing (ms)
#DAS_DELAY_MS     = 170
#DAS_REPEAT_MS    = 40
#LOCK_DELAY_MS    = 500
#LINECLEAR_MS     = 220
#FX_RESULT_MS     = 480

; Input keys (virtual-key codes)
#VK_LEFT          = $25
#VK_UP            = $26
#VK_RIGHT         = $27
#VK_DOWN          = $28
#VK_SPACE         = $20
#VK_SHIFT         = $10
#VK_Z             = $5A
#VK_X             = $58
#VK_C             = $43
#VK_P             = $50
#VK_R             = $52

; Sounds
; From: https://soundeffect-lab.info/sound/button/
#SOUND_MOVE       = 100
#SOUND_ROTATE     = 101
#SOUND_LOCK       = 102
#SOUND_CLEAR      = 103
#SOUND_TETRIS     = 104
#SOUND_HOLD       = 105
#SOUND_GAMEOVER   = 200

; Effects
#FX_PARTICLE_MAX  = 40
#FX_PARTICLE_MS   = 1000

; Preferences
#PREF_FILENAME    = "TinyTetris.ini"

; Function Declare
Declare.i MinI(a.i, b.i)
Declare.i MaxI(a.i, b.i)
Declare.i ClampI(v.i, lo.i, hi.i)

Declare LoadUIFont()
Declare.s PrefsFilePath()
Declare LoadPrefs()
Declare ApplyPrefsToUi()
Declare SavePrefs()
Declare PlaySoundSafe(soundId.i)
Declare UpdateStatus()

Declare InitPieceData()
Declare.i PieceColor(type.i)
Declare.i NormRot(rot.i)
Declare.i PieceCellX(type.i, rot.i, cell.i)
Declare.i PieceCellY(type.i, rot.i, cell.i)

Declare SyncCanvasSize()
Declare CalculateLayout()
Declare EnsureBoardImage()
Declare.i CellToScreenX(col.i)
Declare.i CellToScreenY(row.i)

Declare InitBag()
Declare.i BagNext()
Declare.b CellOccupied(x.i, y.i)
Declare.b PieceFits(type.i, rot.i, px.i, py.i)
Declare.i GhostDropY()
Declare ResetLock()
Declare.b TouchingGround()
Declare.b TryMove(dx.i, dy.i)
Declare.b TryRotate(dir.i)
Declare LockPiece()
Declare.i MarkFullLines()
Declare ClearMarkedLines()
Declare SpawnPiece()
Declare.b HoldPiece()
Declare SoftDropStep()
Declare HardDrop()
Declare.i GravityMs(level.i)
Declare AddScoreForLines(n.i)
Declare FinishGame()
Declare ClearField()

Declare DrawCell(sx.i, sy.i, size.i, color.i, alpha.i)
Declare DrawBoardContent()
Declare DrawBoard()
Declare.b EffectsActive()
Declare EffectsTick()

Declare InitInput()
Declare InputTick()
Declare CanvasGadgetEvent()
Declare FocusCanvas()

Declare InitGame()
Declare RestartGame()
Declare TogglePause()
Declare GameTick()
