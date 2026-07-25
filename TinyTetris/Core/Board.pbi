;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; SyncCanvasSize
; </summary>
Procedure SyncCanvasSize()
  Protected w.i = GadgetWidth(#CANVAS)
  Protected h.i = GadgetHeight(#CANVAS)

  If w > 0
    canvasW = w
  EndIf

  If h > 0
    canvasH = h
  EndIf
EndProcedure

; <summary>
; CalculateLayout
; </summary>
Procedure CalculateLayout()
  Protected fieldPixelH.i
  Protected margin.i = 12

  fieldPixelH = canvasH - margin * 2
  cellSize = fieldPixelH / #FIELD_VISIBLE_H

  If cellSize < 12
    cellSize = 12
  EndIf

  fieldLeft = margin + 70
  fieldTop = (canvasH - cellSize * #FIELD_VISIBLE_H) / 2
EndProcedure

; <summary>
; EnsureBoardImage
; </summary>
Procedure EnsureBoardImage()
  SyncCanvasSize()

  If boardImage = -1 Or canvasW <> boardImageW Or canvasH <> boardImageH
    If boardImage <> -1
      FreeImage(boardImage)
    EndIf

    boardImage = CreateImage(#PB_Any, canvasW, canvasH, 24)
    boardImageW = canvasW
    boardImageH = canvasH
  EndIf
EndProcedure

; <summary>
; CellToScreenX
; </summary>
Procedure.i CellToScreenX(col.i)
  ProcedureReturn fieldLeft + col * cellSize
EndProcedure

; <summary>
; CellToScreenY
; Visible rows only: field row #FIELD_HIDDEN.. maps to 0..
; </summary>
Procedure.i CellToScreenY(row.i)
  ProcedureReturn fieldTop + (row - #FIELD_HIDDEN) * cellSize
EndProcedure

; <summary>
; InitBag
; </summary>
Procedure InitBag()
  Protected i.i, j.i

  For i = 0 To #PIECE_COUNT - 1
    bag(i) = i
  Next

  ; Fisher-Yates
  For i = #PIECE_COUNT - 1 To 1 Step -1
    j = Random(i)
    Swap bag(i), bag(j)
  Next

  bagCount = #PIECE_COUNT
EndProcedure

; <summary>
; BagNext
; </summary>
Procedure.i BagNext()
  Protected t.i

  If bagCount <= 0
    InitBag()
  EndIf

  bagCount - 1
  t = bag(bagCount)
  ProcedureReturn t
EndProcedure

; <summary>
; CellOccupied
; </summary>
Procedure.b CellOccupied(x.i, y.i)
  If x < 0 Or x >= #FIELD_W Or y < 0 Or y >= #FIELD_H
    ProcedureReturn #True
  EndIf

  If field(x, y) <> #PIECE_NONE
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; PieceFits
; </summary>
Procedure.b PieceFits(type.i, rot.i, px.i, py.i)
  Protected i.i, cx.i, cy.i

  If type < 0
    ProcedureReturn #False
  EndIf

  For i = 0 To #CELLS_PER_PIECE - 1
    cx = px + PieceCellX(type, rot, i)
    cy = py + PieceCellY(type, rot, i)

    If CellOccupied(cx, cy)
      ProcedureReturn #False
    EndIf
  Next

  ProcedureReturn #True
EndProcedure

; <summary>
; GhostDropY
; </summary>
Procedure.i GhostDropY()
  Protected gy.i = curY

  If curType < 0
    ProcedureReturn curY
  EndIf

  While PieceFits(curType, curRot, curX, gy + 1)
    gy + 1
  Wend

  ProcedureReturn gy
EndProcedure

; <summary>
; ResetLock
; </summary>
Procedure ResetLock()
  locking = #False
  lockAt = 0
EndProcedure

; <summary>
; TouchingGround
; </summary>
Procedure.b TouchingGround()
  ProcedureReturn Bool(PieceFits(curType, curRot, curX, curY + 1) = #False)
EndProcedure

; <summary>
; TryMove
; </summary>
Procedure.b TryMove(dx.i, dy.i)
  If curType < 0
    ProcedureReturn #False
  EndIf

  If PieceFits(curType, curRot, curX + dx, curY + dy)
    curX + dx
    curY + dy
    If dy = 0
      ResetLock()
    EndIf
    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; TryRotate
; Simple wall kicks: center, L/R, up.
; </summary>
Procedure.b TryRotate(dir.i)
  Protected newRot.i
  Protected i.i
  Protected Dim kickX.i(4)
  Protected Dim kickY.i(4)

  If curType < 0 Or curType = #PIECE_O
    ProcedureReturn #False
  EndIf

  newRot = NormRot(curRot + dir)

  kickX(0) = 0 : kickY(0) = 0
  kickX(1) = -1 : kickY(1) = 0
  kickX(2) = 1 : kickY(2) = 0
  kickX(3) = 0 : kickY(3) = -1
  kickX(4) = 0 : kickY(4) = 1

  For i = 0 To 4
    If PieceFits(curType, newRot, curX + kickX(i), curY + kickY(i))
      curRot = newRot
      curX + kickX(i)
      curY + kickY(i)

      ResetLock()

      ProcedureReturn #True
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

; <summary>
; GravityMs
; </summary>
Procedure.i GravityMs(level.i)
  Protected ms.i = 800 - level * 70
  If ms < 50
    ms = 50
  EndIf

  ProcedureReturn ms
EndProcedure

; <summary>
; AddScoreForLines
; Nintendo-style line clear scoring.
; </summary>
Procedure AddScoreForLines(n.i)
  Protected base.i

  Select n
    Case 1 : base = 40
    Case 2 : base = 100
    Case 3 : base = 300
    Case 4 : base = 1200
    Default : base = 0
  EndSelect

  score + base * (level + 1)
  lines + n
  level = lines / 10

  If score > highScore
    highScore = score
  EndIf
EndProcedure

; <summary>
; MarkFullLines
; </summary>
Procedure.i MarkFullLines()
  Protected y.i, x.i
  Protected full.i

  clearCount = 0

  For y = 0 To #FIELD_H - 1
    clearRow(y) = #False
  Next

  For y = #FIELD_H - 1 To 0 Step -1
    full = #True

    For x = 0 To #FIELD_W - 1
      If field(x, y) = #PIECE_NONE
        full = #False
        Break
      EndIf
    Next

    If full
      clearRow(y) = #True
      clearCount + 1
    EndIf
  Next

  ProcedureReturn clearCount
EndProcedure

; <summary>
; ClearMarkedLines
; </summary>
Procedure ClearMarkedLines()
  Protected y.i, x.i, writeY.i
  Protected Dim tmp.i(#FIELD_W - 1, #FIELD_H - 1)

  For y = 0 To #FIELD_H - 1
    For x = 0 To #FIELD_W - 1
      tmp(x, y) = #PIECE_NONE
    Next
  Next

  writeY = #FIELD_H - 1
  For y = #FIELD_H - 1 To 0 Step -1
    If clearRow(y) = #False
      For x = 0 To #FIELD_W - 1
        tmp(x, writeY) = field(x, y)
      Next
      writeY - 1
    EndIf
  Next

  For y = 0 To #FIELD_H - 1
    For x = 0 To #FIELD_W - 1
      field(x, y) = tmp(x, y)
    Next
  Next

  clearCount = 0
EndProcedure

; <summary>
; LockPiece
; </summary>
Procedure LockPiece()
  Protected i.i, cx.i, cy.i

  If curType < 0
    ProcedureReturn
  EndIf

  For i = 0 To #CELLS_PER_PIECE - 1
    cx = curX + PieceCellX(curType, curRot, i)
    cy = curY + PieceCellY(curType, curRot, i)

    If cx >= 0 And cx < #FIELD_W And cy >= 0 And cy < #FIELD_H
      field(cx, cy) = curType
    EndIf
  Next

  PlaySoundSafe(#SOUND_LOCK)
  ResetLock()
  holdUsed = #False
  curType = #PIECE_NONE

  If MarkFullLines() > 0
    gameState = #STATE_LINECLEAR
    lineClearAt = ElapsedMilliseconds()
    
    If clearCount >= 4
      PlaySoundSafe(#SOUND_TETRIS)
    Else
      PlaySoundSafe(#SOUND_CLEAR)
    EndIf
  Else
    SpawnPiece()
  EndIf
EndProcedure

; <summary>
; SpawnPiece
; </summary>
Procedure SpawnPiece()
  curType = nextType
  nextType = BagNext()
  curRot = 0
  curX = 3
  curY = 0
  ResetLock()
  gravityAt = ElapsedMilliseconds()

  If PieceFits(curType, curRot, curX, curY) = #False
    FinishGame()
  EndIf
EndProcedure

; <summary>
; HoldPiece
; </summary>
Procedure.b HoldPiece()
  Protected hSwap.i

  If curType < 0 Or holdUsed Or gameState <> #STATE_PLAYING
    ProcedureReturn #False
  EndIf

  holdUsed = #True
  PlaySoundSafe(#SOUND_HOLD)

  If holdType = #PIECE_NONE
    holdType = curType
    curType = #PIECE_NONE
    
    SpawnPiece()
  Else
    hSwap = holdType
    holdType = curType
    curType = hSwap
    curRot = 0
    curX = 3
    curY = 0
    
    ResetLock()
    
    gravityAt = ElapsedMilliseconds()
    
    If PieceFits(curType, curRot, curX, curY) = #False
      FinishGame()
    EndIf
  EndIf

  ProcedureReturn #True
EndProcedure

; <summary>
; SoftDropStep
; </summary>
Procedure SoftDropStep()
  If curType < 0 Or gameState <> #STATE_PLAYING
    ProcedureReturn
  EndIf

  If TryMove(0, 1)
    score + 1
    
    If score > highScore
      highScore = score
    EndIf
    
    gravityAt = ElapsedMilliseconds()
  Else
    LockPiece()
  EndIf
EndProcedure

; <summary>
; HardDrop
; </summary>
Procedure HardDrop()
  Protected gy.i
  Protected dropped.i

  If curType < 0 Or gameState <> #STATE_PLAYING
    ProcedureReturn
  EndIf

  gy = GhostDropY()
  
  dropped = gy - curY
  curY = gy
  score + dropped * 2
  
  If score > highScore
    highScore = score
  EndIf
  
  LockPiece()
EndProcedure

; <summary>
; FinishGame
; </summary>
Procedure FinishGame()
  gameState = #STATE_GAMEOVER
  resultFxAt = ElapsedMilliseconds()
  curType = #PIECE_NONE
  
  PlaySoundSafe(#SOUND_GAMEOVER)
  
  If score > highScore
    highScore = score
  EndIf
  
  SavePrefs()
  UpdateStatus()
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 462
; FirstLine = 420
; Folding = -----
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory