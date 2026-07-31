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
; <param name="col">integer</param>
; <returns>Returns integer.</returns>
Procedure.i CellToScreenX(col.i)
  ProcedureReturn fieldLeft + col * cellSize
EndProcedure

; <summary>
; CellToScreenY
; </summary>
; <param name="row">integer</param>
; <returns>Returns integer.</returns>
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
; FillNextQueue
; </summary>
Procedure FillNextQueue()
  Protected i.i

  For i = 0 To #NEXT_COUNT - 1
    nextQueue(i) = BagNext()
  Next
EndProcedure

; <summary>
; TakeNextPiece
; </summary>
Procedure.i TakeNextPiece()
  Protected i.i
  Protected t.i = nextQueue(0)

  For i = 0 To #NEXT_COUNT - 2
    nextQueue(i) = nextQueue(i + 1)
  Next

  nextQueue(#NEXT_COUNT - 1) = BagNext()

  ProcedureReturn t
EndProcedure

; <summary>
; CellOccupied
; </summary>
; <param name="x">integer</param>
; <param name="y">integer</param>
; <returns>Returns byte.</returns>
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
; <param name="type">integer</param>
; <param name="rot">integer</param>
; <param name="px">integer</param>
; <param name="py">integer</param>
; <returns>Returns byte.</returns>
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
; Full unlock when piece leaves the ground.
; </summary>
Procedure ResetLock()
  locking = #False
  lockAt = 0
EndProcedure

; <summary>
; OnGroundAction
; Move/rotate while grounded: refresh lock delay up to LOCK_RESET_MAX.
; </summary>
Procedure OnGroundAction()
  If TouchingGround() = #False
    ResetLock()

    ProcedureReturn
  EndIf

  locking = #True
  If lockResets < #LOCK_RESET_MAX
    lockResets + 1
    lockAt = ElapsedMilliseconds()
  EndIf
EndProcedure

; <summary>
; TouchingGround
; </summary>
Procedure.b TouchingGround()
  If curType < 0
    ProcedureReturn #False
  EndIf

  ProcedureReturn Bool(PieceFits(curType, curRot, curX, curY + 1) = #False)
EndProcedure

; <summary>
; TryMove
; </summary>
; <param name="dx">integer</param>
; <param name="dy">integer</param>
; <returns>Returns byte.</returns>
Procedure.b TryMove(dx.i, dy.i)
  If curType < 0
    ProcedureReturn #False
  EndIf

  If PieceFits(curType, curRot, curX + dx, curY + dy)
    curX + dx
    curY + dy
    lastAction = #ACTION_MOVE

    If dy = 0
      OnGroundAction()
    ElseIf TouchingGround() = #False
      ResetLock()
    EndIf

    ProcedureReturn #True
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; TryRotate
; SRS wall kicks (JLSTZ / I).
; </summary>
; <param name="dir">integer</param>
; <returns>Returns byte.</returns>
Procedure.b TryRotate(dir.i)
  Protected newRot.i
  Protected i.i
  Protected fromRot.i

  If curType < 0 Or curType = #PIECE_O
    ProcedureReturn #False
  EndIf

  If dir <> 1 And dir <> -1
    ProcedureReturn #False
  EndIf

  fromRot = curRot
  newRot = NormRot(fromRot + dir)

  For i = 0 To #SRS_KICK_TESTS - 1
    FillSrsKick(curType, fromRot, dir, i)
    If PieceFits(curType, newRot, curX + kickDX, curY + kickDY)
      curRot = newRot
      curX + kickDX
      curY + kickDY
      lastAction = #ACTION_ROTATE
      lastKickIndex = i
      OnGroundAction()
      ProcedureReturn #True
    EndIf
  Next

  ProcedureReturn #False
EndProcedure

; <summary>
; DetectTSpin
; 3-corner rule + Mini/Full; kick #5 forces Full.
; </summary>
Procedure.i DetectTSpin()
  Protected cx.i, cy.i
  Protected c00.i, c20.i, c02.i, c22.i
  Protected filled.i
  Protected frontA.i, frontB.i

  If curType <> #PIECE_T Or lastAction <> #ACTION_ROTATE
    ProcedureReturn #TSPIN_NONE
  EndIf

  cx = curX + 1
  cy = curY + 1
  c00 = Bool(CellOccupied(cx - 1, cy - 1))
  c20 = Bool(CellOccupied(cx + 1, cy - 1))
  c02 = Bool(CellOccupied(cx - 1, cy + 1))
  c22 = Bool(CellOccupied(cx + 1, cy + 1))

  filled = 0
  If c00 : filled + 1 : EndIf
  If c20 : filled + 1 : EndIf
  If c02 : filled + 1 : EndIf
  If c22 : filled + 1 : EndIf

  If filled < 3
    ProcedureReturn #TSPIN_NONE
  EndIf

  ; Kick test 5 (index 4) is always a full T-Spin.
  If lastKickIndex = 4
    ProcedureReturn #TSPIN_FULL
  EndIf

  Select curRot
    Case 0
      frontA = c00 : frontB = c20
    Case 1
      frontA = c20 : frontB = c22
    Case 2
      frontA = c02 : frontB = c22
    Default
      frontA = c00 : frontB = c02
  EndSelect

  If frontA And frontB
    ProcedureReturn #TSPIN_FULL
  EndIf

  ProcedureReturn #TSPIN_MINI
EndProcedure

; <summary>
; GravityMs
; </summary>
; <param name="level">integer</param>
; <returns>Returns integer.</returns>
Procedure.i GravityMs(level.i)
  Protected ms.i = 800 - level * 70

  If ms < 50
    ms = 50
  EndIf

  ProcedureReturn ms
EndProcedure

; <summary>
; AwardClear
; Guideline-style line / T-Spin / B2B / Combo scoring.
; </summary>
; <param name="n">integer</param>
; <param name="tspin">integer</param>
; <returns>Returns void.</returns>
Procedure AwardClear(n.i, tspin.i)
  Protected base.i = 0
  Protected difficult.i = #False
  Protected oldLevel.i = level
  Protected lvl.i = level + 1
  Protected gained.i
  Protected usedB2B.i = #False
  Protected shownCombo.i

  If tspin = #TSPIN_NONE
    Select n
      Case 1 : base = 100
      Case 2 : base = 300
      Case 3 : base = 500
      Case 4 : base = 800 : difficult = #True
    EndSelect
  ElseIf tspin = #TSPIN_MINI
    Select n
      Case 0 : base = 100
      Case 1 : base = 200 : difficult = #True
      Case 2 : base = 400 : difficult = #True
    EndSelect
  Else
    Select n
      Case 0 : base = 400
      Case 1 : base = 800 : difficult = #True
      Case 2 : base = 1200 : difficult = #True
      Case 3 : base = 1600 : difficult = #True
    EndSelect
  EndIf

  If n > 0
    If difficult And backToBack
      base = base * 3 / 2
      usedB2B = #True
    EndIf

    gained = base * lvl
    If comboCount > 0
      gained + 50 * comboCount * lvl
    EndIf
    shownCombo = comboCount

    score + gained
    lines + n
    level = lines / 10
    comboCount + 1

    If difficult
      backToBack = #True
    Else
      backToBack = #False
    EndIf
  Else
    If base > 0
      score + base * lvl
    EndIf
    comboCount = 0
    shownCombo = 0
  EndIf

  If score > highScore
    highScore = score
  EndIf

  clearMsg = ClearKindText(n, tspin)
  If usedB2B
    clearMsg = "B2B " + clearMsg
  EndIf
  If n > 0 And shownCombo > 0
    clearMsg + "  COMBO x" + Str(shownCombo)
  EndIf
  clearMsgAt = ElapsedMilliseconds()

  If level > oldLevel
    levelFxAt = ElapsedMilliseconds()
    levelFxLevel = level + 1
    PlaySoundSafe(#SOUND_LEVELUP)
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
    fallDist(y) = 0
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
; ClearParticleFx
; </summary>
Procedure ClearParticleFx()
  particleCount = 0
  particleFxAt = 0
EndProcedure

; <summary>
; SpawnClearParticles
; Burst from each cleared line.
; </summary>
Procedure SpawnClearParticles()
  Protected y.i, x.i, i.i, n.i
  Protected baseColor.i
  Protected sx.i, sy.i

  ClearParticleFx()
  CalculateLayout()

  n = 0
  particleFxAt = ElapsedMilliseconds()

  For y = 0 To #FIELD_H - 1
    If n >= #FX_PARTICLE_MAX
      Break
    EndIf

    If clearRow(y) = #False
      Continue
    EndIf

    For x = 0 To #FIELD_W - 1
      If n >= #FX_PARTICLE_MAX
        Break
      EndIf

      If field(x, y) = #PIECE_NONE
        Continue
      EndIf

      baseColor = PieceColor(field(x, y))
      sx = CellToScreenX(x) + cellSize / 2
      sy = CellToScreenY(y) + cellSize / 2

      particleX(n) = sx
      particleY(n) = sy
      particleVx(n) = Random(13) - 6
      particleVy(n) = Random(9) - 10
      particleLife(n) = 500 + Random(400)

      If Random(3) = 0
        particleColor(n) = RGB(255, 255, 255)
      Else
        particleColor(n) = baseColor
      EndIf
      n + 1
    Next
  Next

  particleCount = n
EndProcedure

; <summary>
; PrepareLineFall
; Compute how far each surviving row will drop, keep field until fall ends.
; </summary>
Procedure PrepareLineFall()
  Protected y.i, below.i

  For y = 0 To #FIELD_H - 1
    fallDist(y) = 0
  Next

  below = 0

  For y = #FIELD_H - 1 To 0 Step -1
    If clearRow(y)
      below + 1
      fallDist(y) = 0
    Else
      fallDist(y) = below
    EndIf
  Next

  SpawnClearParticles()
  lineFallAt = ElapsedMilliseconds()
  gameState = #STATE_LINEFALL
  UpdateStatus()
EndProcedure

; <summary>
; ApplyLineClear
; Compact field after fall animation.
; </summary>
Procedure ApplyLineClear()
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

    clearRow(y) = #False
    fallDist(y) = 0
  Next

  If pendingLines > 0
    AwardClear(pendingLines, pendingTSpin)
  EndIf

  clearCount = 0
  pendingLines = 0
  pendingTSpin = #TSPIN_NONE
EndProcedure

; <summary>
; StartLockFx
; </summary>
Procedure StartLockFx()
  Protected i.i, cx.i, cy.i

  lockFxCount = 0
  If curType < 0
    ProcedureReturn
  EndIf

  For i = 0 To #CELLS_PER_PIECE - 1
    cx = curX + PieceCellX(curType, curRot, i)
    cy = curY + PieceCellY(curType, curRot, i)

    lockFxX(i) = cx
    lockFxY(i) = cy
    lockFxType(i) = curType
    lockFxCount + 1
  Next

  lockFxAt = ElapsedMilliseconds()
EndProcedure

; <summary>
; StartDropTrail
; </summary>
; <param name="fromY">integer</param>
; <param name="toY">integer</param>
; <returns>Returns void.</returns>
Procedure StartDropTrail(fromY.i, toY.i)
  dropTrailAt = ElapsedMilliseconds()
  dropTrailX = curX
  dropTrailY0 = fromY
  dropTrailY1 = toY
  dropTrailType = curType
  dropTrailRot = curRot
EndProcedure

; <summary>
; StartSpawnWait
; </summary>
; <param name="afterClear">integer</param>
; <returns>Returns void.</returns>
Procedure StartSpawnWait(afterClear.i)
  gameState = #STATE_SPAWNWAIT

  If afterClear
    spawnWaitAt = ElapsedMilliseconds() + #SPAWN_DELAY_CLEAR_MS
  Else
    spawnWaitAt = ElapsedMilliseconds() + #SPAWN_DELAY_MS
  EndIf

  UpdateStatus()
EndProcedure

; <summary>
; LockPiece
; </summary>
Procedure LockPiece()
  Protected i.i, cx.i, cy.i
  Protected tspin.i

  If curType < 0
    ProcedureReturn
  EndIf

  tspin = DetectTSpin()
  StartLockFx()

  For i = 0 To #CELLS_PER_PIECE - 1
    cx = curX + PieceCellX(curType, curRot, i)
    cy = curY + PieceCellY(curType, curRot, i)

    If cx >= 0 And cx < #FIELD_W And cy >= 0 And cy < #FIELD_H
      field(cx, cy) = curType
    EndIf
  Next

  PlaySoundSafe(#SOUND_LOCK)
  ResetLock()
  lockResets = 0
  holdUsed = #False
  curType = #PIECE_NONE

  If MarkFullLines() > 0
    pendingLines = clearCount
    pendingTSpin = tspin
    gameState = #STATE_LINECLEAR
    lineClearAt = ElapsedMilliseconds()
    clearMsg = ClearKindText(clearCount, tspin)
    If backToBack And (clearCount = 4 Or tspin <> #TSPIN_NONE)
      clearMsg = "B2B " + clearMsg
    EndIf
    If comboCount > 0
      clearMsg + "  COMBO x" + Str(comboCount)
    EndIf
    clearMsgAt = ElapsedMilliseconds()

    If clearCount >= 4 Or tspin = #TSPIN_FULL
      PlaySoundSafe(#SOUND_TETRIS)
    Else
      PlaySoundSafe(#SOUND_CLEAR)
    EndIf

    UpdateStatus()
  Else
    If tspin <> #TSPIN_NONE
      AwardClear(0, tspin)
    Else
      comboCount = 0
    EndIf
    lastAction = #ACTION_NONE
    StartSpawnWait(#False)
  EndIf

  lastAction = #ACTION_NONE
EndProcedure

; <summary>
; SpawnPiece
; </summary>
Procedure SpawnPiece()
  curType = TakeNextPiece()
  curRot = 0
  curX = 3
  curY = 0
  lockResets = 0
  lastAction = #ACTION_NONE
  lastKickIndex = 0
  ResetLock()
  gravityAt = ElapsedMilliseconds()
  gameState = #STATE_PLAYING

  If PieceFits(curType, curRot, curX, curY) = #False
    FinishGame()
  Else
    UpdateStatus()
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
  lockResets = 0
  lastAction = #ACTION_NONE

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
    lastKickIndex = 0
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
  Protected fromY.i

  If curType < 0 Or gameState <> #STATE_PLAYING
    ProcedureReturn
  EndIf

  fromY = curY
  gy = GhostDropY()
  dropped = gy - curY

  If dropped > 0
    StartDropTrail(fromY, gy)
  EndIf

  curY = gy
  score + dropped * 2
  ; Keep ROTATE so T-Spin + hard-drop still counts (guideline feel).

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
  FadeOutBgm()

  If score > highScore
    highScore = score
  EndIf
  
  SavePrefs()
  UpdateStatus()
EndProcedure
