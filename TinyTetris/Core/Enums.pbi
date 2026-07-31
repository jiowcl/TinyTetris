;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

#APP_VERSION$     = "1.3"
#VERSION          = 1.3

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
#NEXT_COUNT       = 3
#SRS_KICK_TESTS   = 5

; Last piece action (for T-Spin)
#ACTION_NONE      = 0
#ACTION_MOVE      = 1
#ACTION_ROTATE    = 2
#ACTION_DROP      = 3

; T-Spin result
#TSPIN_NONE       = 0
#TSPIN_MINI       = 1
#TSPIN_FULL       = 2

; Game state
#STATE_PLAYING    = 0
#STATE_PAUSED     = 1
#STATE_LINECLEAR  = 2
#STATE_LINEFALL   = 3
#STATE_SPAWNWAIT  = 4
#STATE_GAMEOVER   = 5

; Window / gadgets — main
#WIN_MAIN         = 0
#CANVAS           = 1
#BTN_RESTART      = 2
#BTN_PAUSE        = 3
#BTN_SETTINGS     = 4
#CHK_SOUND        = 5
#CHK_MUSIC        = 6
#LBL_STATUS       = 7
#LBL_VERSION      = 8
#LBL_HELP         = 9

; Window / gadgets — settings
#WIN_SETTINGS     = 1
#TRK_DAS          = 20
#TRK_ARR          = 21
#TRK_MUSIC_VOL    = 22
#LBL_DAS_TITLE    = 23
#LBL_ARR_TITLE    = 24
#LBL_MVOL_TITLE   = 25
#LBL_DAS_VAL      = 26
#LBL_ARR_VAL      = 27
#LBL_MVOL_VAL     = 28
#BTN_SETTINGS_OK  = 29

; Canvas
#CANVAS_DEFAULT_W = 420
#CANVAS_DEFAULT_H = 520

; Timing (ms) — defaults; DAS can be overridden by prefs
#DAS_DELAY_DEFAULT   = 167
#DAS_REPEAT_DEFAULT  = 33
#SOFT_REPEAT_MS      = 28
#LOCK_DELAY_MS       = 500
#LOCK_RESET_MAX      = 15
#LINECLEAR_MS        = 240
#LINEFALL_MS         = 180
#SPAWN_DELAY_MS      = 120
#SPAWN_DELAY_CLEAR_MS = 160
#FX_RESULT_MS        = 480
#FX_LOCK_MS          = 140
#FX_DROP_TRAIL_MS    = 110
#FX_LEVEL_MS         = 700
#FX_CLEAR_MSG_MS     = 1000

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
#SOUND_LEVELUP    = 106
#SOUND_GAMEOVER   = 200

; Music (tracker module via ModPlug)
; From: https://pansound.com/panicpumpkin/music/hageshii.html
#MUSIC_BGM            = 0
#MUSIC_VOLUME_DEFAULT = 50
#MUSIC_PAUSE_VOLUME   = 12
#MUSIC_FADE_MS        = 700

; Effects
#FX_PARTICLE_MAX  = 48
#FX_PARTICLE_MS   = 900

; Preferences
#PREF_FILENAME    = "TinyTetris.ini"

; Function Declare
Declare.i MinI(a.i, b.i)
Declare.i MaxI(a.i, b.i)
Declare.i ClampI(v.i, lo.i, hi.i)
Declare.i EaseOutQuad100(t.i)
Declare.i EaseInQuad100(t.i)

Declare LoadUIFont()
Declare.s PrefsFilePath()
Declare LoadPrefs()
Declare ApplyPrefsToUi()
Declare SavePrefs()
Declare PlaySoundSafe(soundId.i)
Declare UpdateStatus()
Declare.s ClearKindText(n.i, tspin.i)

Declare.s ResolveAssetPath(fileName.s)
Declare.b TryLoadBgmFile(fileName.s)
Declare.b InitBgm()
Declare FreeBgm()
Declare ApplyMusicVolume(vol.i)
Declare StartBgm()
Declare StopBgm()
Declare PauseBgm()
Declare ResumeBgm()
Declare FadeOutBgm()
Declare MusicTick()
Declare SyncMusicUi()

Declare InitPieceData()
Declare.i PieceColor(type.i)
Declare.i NormRot(rot.i)
Declare.i PieceCellX(type.i, rot.i, cell.i)
Declare.i PieceCellY(type.i, rot.i, cell.i)
Declare FillSrsKick(type.i, fromRot.i, dir.i, test.i)

Declare SyncCanvasSize()
Declare CalculateLayout()
Declare EnsureBoardImage()
Declare.i CellToScreenX(col.i)
Declare.i CellToScreenY(row.i)

Declare InitBag()
Declare.i BagNext()
Declare FillNextQueue()
Declare.i TakeNextPiece()
Declare.b CellOccupied(x.i, y.i)
Declare.b PieceFits(type.i, rot.i, px.i, py.i)
Declare.i GhostDropY()
Declare ResetLock()
Declare OnGroundAction()
Declare.b TouchingGround()
Declare.b TryMove(dx.i, dy.i)
Declare.b TryRotate(dir.i)
Declare.i DetectTSpin()
Declare AwardClear(n.i, tspin.i)
Declare LockPiece()
Declare.i MarkFullLines()
Declare PrepareLineFall()
Declare ApplyLineClear()
Declare SpawnClearParticles()
Declare ClearParticleFx()
Declare StartLockFx()
Declare StartDropTrail(fromY.i, toY.i)
Declare StartSpawnWait(afterClear.i)
Declare SpawnPiece()
Declare.b HoldPiece()
Declare SoftDropStep()
Declare HardDrop()
Declare.i GravityMs(level.i)
Declare FinishGame()
Declare ClearField()

Declare DrawCell(sx.i, sy.i, size.i, color.i, alpha.i)
Declare DrawPieceAt(type.i, rot.i, px.i, py.i, alpha.i)
Declare DrawMiniPiece(type.i, ox.i, oy.i, size.i, alpha.i)
Declare.i FallProgressPct()
Declare DrawBoardContent()
Declare DrawBoard()
Declare DrawParticles()
Declare DrawDropTrail()
Declare DrawLockFx()
Declare DrawLevelFx()
Declare DrawClearMsg()
Declare.b EffectsActive()
Declare EffectsTick()

Declare InitInput()
Declare InputTick()
Declare CanvasGadgetEvent()
Declare FocusCanvas()

Declare OpenSettingsPanel()
Declare CloseSettingsPanel()
Declare SyncSettingsPanel()
Declare ApplySettingsFromPanel()
Declare SettingsPanelEvent()

Declare InitGame()
Declare RestartGame()
Declare TogglePause()
Declare GameTick()
