;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

Global Dim field.i(#FIELD_W - 1, #FIELD_H - 1)

Global curType.i = #PIECE_NONE
Global curRot.i = 0
Global curX.i = 0
Global curY.i = 0

Global nextType.i = #PIECE_NONE
Global holdType.i = #PIECE_NONE
Global holdUsed.i = #False

Global Dim bag.i(#PIECE_COUNT - 1)
Global bagCount.i = 0

Global score.i = 0
Global highScore.i = 0
Global level.i = 0
Global lines.i = 0

Global gameState.i = #STATE_PLAYING
Global soundEnabled.i = #True

Global gravityAt.i = 0
Global lockAt.i = 0
Global locking.i = #False
Global lineClearAt.i = 0
Global Dim clearRow.i(#FIELD_H - 1)
Global clearCount.i = 0
Global resultFxAt.i = 0

Global particleFxAt.i = 0
Global particleCount.i = 0
Global Dim particleX.i(#FX_PARTICLE_MAX - 1)
Global Dim particleY.i(#FX_PARTICLE_MAX - 1)
Global Dim particleVx.i(#FX_PARTICLE_MAX - 1)
Global Dim particleVy.i(#FX_PARTICLE_MAX - 1)
Global Dim particleLife.i(#FX_PARTICLE_MAX - 1)
Global Dim particleColor.i(#FX_PARTICLE_MAX - 1)

; Layout
Global cellSize.i
Global fieldLeft.i, fieldTop.i
Global canvasW.i = #CANVAS_DEFAULT_W
Global canvasH.i = #CANVAS_DEFAULT_H
Global boardImage.i = -1
Global boardImageW.i, boardImageH.i
Global uiFont.i
Global statusFont.i
Global panelFont.i

; Piece shape table: type, rot, cell -> x/y in 0..3 local grid
Global Dim pieceX.b(#PIECE_COUNT - 1, #ROT_COUNT - 1, #CELLS_PER_PIECE - 1)
Global Dim pieceY.b(#PIECE_COUNT - 1, #ROT_COUNT - 1, #CELLS_PER_PIECE - 1)

; Input / DAS
Global keyLeft.i, keyRight.i, keyDown.i
Global keyLeftPrev.i, keyRightPrev.i, keyDownPrev.i
Global dasDir.i = 0
Global dasAt.i = 0
Global dasRepeating.i = #False
Global softDropAt.i = 0

Global soundPath.s = "./Sound/"

LoadSound(#SOUND_MOVE, soundPath + "100.wav")
LoadSound(#SOUND_ROTATE, soundPath + "101.wav")
LoadSound(#SOUND_LOCK, soundPath + "102.wav")
LoadSound(#SOUND_CLEAR, soundPath + "103.wav")
LoadSound(#SOUND_TETRIS, soundPath + "104.wav")
LoadSound(#SOUND_HOLD, soundPath + "105.wav")
LoadSound(#SOUND_GAMEOVER, soundPath + "200.wav")
