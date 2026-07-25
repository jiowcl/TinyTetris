;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; DrawCell
; Beveled block with rim highlight.
; </summary>
Procedure DrawCell(sx.i, sy.i, size.i, color.i, alpha.i)
  Protected r.i = Red(color)
  Protected g.i = Green(color)
  Protected b.i = Blue(color)
  Protected inset.i
  Protected light.i, dark.i

  If size < 4
    ProcedureReturn
  EndIf

  If alpha < 1
    alpha = 1
  ElseIf alpha > 255
    alpha = 255
  EndIf

  inset = MaxI(1, size / 8)
  light = RGB(MinI(255, r + 55), MinI(255, g + 55), MinI(255, b + 55))
  dark = RGB(MaxI(0, r - 55), MaxI(0, g - 55), MaxI(0, b - 55))

  DrawingMode(#PB_2DDrawing_AlphaBlend)
  Box(sx, sy, size, size, RGBA(r, g, b, alpha))
  Box(sx, sy, size, inset, RGBA(Red(light), Green(light), Blue(light), alpha))
  Box(sx, sy, inset, size, RGBA(Red(light), Green(light), Blue(light), alpha))
  Box(sx, sy + size - inset, size, inset, RGBA(Red(dark), Green(dark), Blue(dark), alpha))
  Box(sx + size - inset, sy, inset, size, RGBA(Red(dark), Green(dark), Blue(dark), alpha))
  DrawingMode(#PB_2DDrawing_Default)
EndProcedure

; <summary>
; DrawPieceAt
; </summary>
Procedure DrawPieceAt(type.i, rot.i, px.i, py.i, alpha.i)
  Protected i.i, cx.i, cy.i, sx.i, sy.i
  Protected color.i

  If type < 0
    ProcedureReturn
  EndIf

  color = PieceColor(type)
  For i = 0 To #CELLS_PER_PIECE - 1
    cx = px + PieceCellX(type, rot, i)
    cy = py + PieceCellY(type, rot, i)
    If cy < #FIELD_HIDDEN
      Continue
    EndIf

    If cx < 0 Or cx >= #FIELD_W Or cy >= #FIELD_H
      Continue
    EndIf

    sx = CellToScreenX(cx)
    sy = CellToScreenY(cy)
    DrawCell(sx, sy, cellSize - 1, color, alpha)
  Next
EndProcedure

; <summary>
; DrawMiniPiece
; </summary>
Procedure DrawMiniPiece(type.i, ox.i, oy.i, size.i, alpha.i)
  Protected i.i, cx.i, cy.i
  Protected minX.i = 3, minY.i = 3, maxX.i = 0, maxY.i = 0
  Protected offX.i, offY.i

  If type < 0
    ProcedureReturn
  EndIf

  For i = 0 To #CELLS_PER_PIECE - 1
    cx = PieceCellX(type, 0, i)
    cy = PieceCellY(type, 0, i)

    If cx < minX : minX = cx : EndIf
    If cy < minY : minY = cy : EndIf
    If cx > maxX : maxX = cx : EndIf
    If cy > maxY : maxY = cy : EndIf
  Next

  offX = ox + (4 * size - (maxX - minX + 1) * size) / 2 - minX * size
  offY = oy + (3 * size - (maxY - minY + 1) * size) / 2 - minY * size

  For i = 0 To #CELLS_PER_PIECE - 1
    cx = PieceCellX(type, 0, i)
    cy = PieceCellY(type, 0, i)

    DrawCell(offX + cx * size, offY + cy * size, size - 1, PieceColor(type), alpha)
  Next
EndProcedure

; <summary>
; DrawPanelBox
; </summary>
Procedure DrawPanelBox(x.i, y.i, w.i, h.i, title.s)
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  Box(x, y, w, h, RGBA(20, 28, 40, 220))
  DrawingMode(#PB_2DDrawing_Outlined)
  Box(x, y, w, h, RGB(70, 90, 120))
  DrawingMode(#PB_2DDrawing_Transparent)

  If panelFont
    DrawingFont(FontID(panelFont))
  EndIf

  FrontColor(RGB(180, 200, 230))
  DrawText(x + 8, y + 6, title)
  DrawingMode(#PB_2DDrawing_Default)
EndProcedure

; <summary>
; DrawDropTrail
; </summary>
Procedure DrawDropTrail()
  Protected elapsed.i
  Protected prog.i, alpha.i
  Protected y.i, i.i, cx.i, cy.i
  Protected sx.i, sy.i

  If dropTrailAt = 0 Or dropTrailType < 0
    ProcedureReturn
  EndIf

  elapsed = ElapsedMilliseconds() - dropTrailAt

  If elapsed >= #FX_DROP_TRAIL_MS
    dropTrailAt = 0
    ProcedureReturn
  EndIf

  prog = elapsed * 100 / #FX_DROP_TRAIL_MS
  alpha = 140 - prog * 140 / 100

  If alpha < 1
    ProcedureReturn
  EndIf

  For y = dropTrailY0 To dropTrailY1
    For i = 0 To #CELLS_PER_PIECE - 1
      cx = dropTrailX + PieceCellX(dropTrailType, dropTrailRot, i)
      cy = y + PieceCellY(dropTrailType, dropTrailRot, i)

      If cy < #FIELD_HIDDEN Or cy >= #FIELD_H
        Continue
      EndIf

      If cx < 0 Or cx >= #FIELD_W
        Continue
      EndIf

      sx = CellToScreenX(cx)
      sy = CellToScreenY(cy)

      DrawCell(sx, sy, cellSize - 1, PieceColor(dropTrailType), alpha)
    Next
  Next
EndProcedure

; <summary>
; DrawLockFx
; </summary>
Procedure DrawLockFx()
  Protected elapsed.i
  Protected prog.i, alpha.i
  Protected i.i, sx.i, sy.i

  If lockFxAt = 0 Or lockFxCount <= 0
    ProcedureReturn
  EndIf

  elapsed = ElapsedMilliseconds() - lockFxAt
  If elapsed >= #FX_LOCK_MS
    lockFxAt = 0
    lockFxCount = 0

    ProcedureReturn
  EndIf

  prog = EaseOutQuad100(elapsed * 100 / #FX_LOCK_MS)
  alpha = 220 - prog * 220 / 100

  For i = 0 To lockFxCount - 1
    If lockFxY(i) < #FIELD_HIDDEN
      Continue
    EndIf

    sx = CellToScreenX(lockFxX(i))
    sy = CellToScreenY(lockFxY(i))

    DrawCell(sx, sy, cellSize - 1, RGB(255, 255, 255), alpha)
  Next
EndProcedure

; <summary>
; DrawParticles
; </summary>
Procedure DrawParticles()
  Protected i.i
  Protected age.i, now.i
  Protected sx.i, sy.i, r.i
  Protected alpha.i
  Protected cr.i, cg.i, cb.i

  If particleCount <= 0 Or particleFxAt = 0
    ProcedureReturn
  EndIf

  now = ElapsedMilliseconds()

  If now - particleFxAt > #FX_PARTICLE_MS
    ClearParticleFx()
    ProcedureReturn
  EndIf

  DrawingMode(#PB_2DDrawing_AlphaBlend)
  For i = 0 To particleCount - 1
    age = now - particleFxAt

    If age >= particleLife(i)
      Continue
    EndIf

    sx = particleX(i) + particleVx(i) * age / 16
    sy = particleY(i) + particleVy(i) * age / 16 + (age * age) / 8000
    alpha = 255 - age * 255 / particleLife(i)

    If alpha < 1
      Continue
    EndIf

    r = MaxI(2, 5 - age / 220)
    cr = Red(particleColor(i))
    cg = Green(particleColor(i))
    cb = Blue(particleColor(i))
    Circle(sx, sy, r + 1, RGBA(cr, cg, cb, alpha / 3))
    Circle(sx, sy, r, RGBA(cr, cg, cb, alpha))
  Next
  DrawingMode(#PB_2DDrawing_Default)
EndProcedure

; <summary>
; DrawLevelFx
; </summary>
Procedure DrawLevelFx()
  Protected elapsed.i
  Protected prog.i, alpha.i, rise.i
  Protected label.s
  Protected fw.i, fh.i

  If levelFxAt = 0
    ProcedureReturn
  EndIf

  elapsed = ElapsedMilliseconds() - levelFxAt

  If elapsed >= #FX_LEVEL_MS
    levelFxAt = 0
    ProcedureReturn
  EndIf

  prog = EaseOutQuad100(MinI(100, elapsed * 100 / 280))

  If elapsed > #FX_LEVEL_MS - 200
    alpha = 255 - (elapsed - (#FX_LEVEL_MS - 200)) * 255 / 200
  Else
    alpha = prog * 255 / 100
  EndIf

  rise = (100 - prog) * 14 / 100

  fw = #FIELD_W * cellSize
  fh = #FIELD_VISIBLE_H * cellSize
  label = "LEVEL " + Str(levelFxLevel)

  DrawingMode(#PB_2DDrawing_Transparent)

  If panelFont
    DrawingFont(FontID(panelFont))
  EndIf

  DrawingMode(#PB_2DDrawing_AlphaBlend)
  FrontColor(RGBA(0, 0, 0, alpha * 140 / 255))
  DrawText(fieldLeft + (fw - TextWidth(label)) / 2 + 2, fieldTop + fh / 3 + rise + 2, label)
  FrontColor(RGBA(120, 230, 255, alpha))
  DrawText(fieldLeft + (fw - TextWidth(label)) / 2, fieldTop + fh / 3 + rise, label)
  DrawingMode(#PB_2DDrawing_Default)
EndProcedure

; <summary>
; FallProgressPct
; </summary>
Procedure.i FallProgressPct()
  Protected elapsed.i

  If gameState <> #STATE_LINEFALL Or lineFallAt = 0
    ProcedureReturn 100
  EndIf

  elapsed = ElapsedMilliseconds() - lineFallAt

  If elapsed >= #LINEFALL_MS
    ProcedureReturn 100
  EndIf

  If elapsed <= 0
    ProcedureReturn 0
  EndIf

  ProcedureReturn EaseInQuad100(elapsed * 100 / #LINEFALL_MS)
EndProcedure

; <summary>
; DrawBoardContent
; </summary>
Procedure DrawBoardContent()
  Protected x.i, y.i, i.i
  Protected sx.i, sy.i
  Protected fw.i, fh.i
  Protected gy.i
  Protected flash.i
  Protected sideX.i
  Protected nextH.i
  Protected resultText.s
  Protected resultProg.i, resultElapsed.i
  Protected resultAlpha.i, resultRise.i
  Protected font.i
  Protected label.s
  Protected fallPct.i
  Protected holdAlpha.i
  Protected clipTop.i, clipBottom.i

  CalculateLayout()
  fallPct = FallProgressPct()

  Box(0, 0, canvasW, canvasH, RGB(18, 24, 36))
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(34, 52, 78))
  FrontColor(RGB(12, 16, 28))
  LinearGradient(0, 0, 0, canvasH)
  Box(0, 0, canvasW, canvasH)
  DrawingMode(#PB_2DDrawing_Default)

  fw = #FIELD_W * cellSize
  fh = #FIELD_VISIBLE_H * cellSize
  clipTop = fieldTop
  clipBottom = fieldTop + fh

  DrawingMode(#PB_2DDrawing_AlphaBlend)
  Box(fieldLeft - 3, fieldTop - 3, fw + 6, fh + 6, RGBA(8, 12, 20, 255))
  Box(fieldLeft, fieldTop, fw, fh, RGBA(28, 36, 52, 255))
  DrawingMode(#PB_2DDrawing_Default)

  FrontColor(RGB(45, 58, 78))

  For x = 0 To #FIELD_W
    LineXY(fieldLeft + x * cellSize, fieldTop, fieldLeft + x * cellSize, fieldTop + fh)
  Next

  For y = 0 To #FIELD_VISIBLE_H
    LineXY(fieldLeft, fieldTop + y * cellSize, fieldLeft + fw, fieldTop + y * cellSize)
  Next

  ; Locked blocks (+ fall offset during LINEFALL)
  flash = #False

  If gameState = #STATE_LINECLEAR
    If ((ElapsedMilliseconds() - lineClearAt) / 55) % 2 = 0
      flash = #True
    EndIf
  EndIf

  For y = #FIELD_HIDDEN To #FIELD_H - 1
    If gameState = #STATE_LINEFALL And clearRow(y)
      Continue
    EndIf

    For x = 0 To #FIELD_W - 1
      If field(x, y) = #PIECE_NONE
        Continue
      EndIf

      sx = CellToScreenX(x)
      sy = CellToScreenY(y)

      If gameState = #STATE_LINEFALL And fallDist(y) > 0
        sy + fallDist(y) * cellSize * fallPct / 100
      EndIf

      If sy + cellSize < clipTop Or sy > clipBottom
        Continue
      EndIf

      If clearRow(y) And flash And gameState = #STATE_LINECLEAR
        DrawCell(sx, sy, cellSize - 1, RGB(255, 255, 255), 240)
      ElseIf clearRow(y) And gameState = #STATE_LINECLEAR
        DrawCell(sx, sy, cellSize - 1, PieceColor(field(x, y)), 120)
      Else
        DrawCell(sx, sy, cellSize - 1, PieceColor(field(x, y)), 255)
      EndIf
    Next
  Next

  DrawDropTrail()
  DrawLockFx()

  ; Ghost + current
  If gameState = #STATE_PLAYING Or gameState = #STATE_PAUSED
    If curType >= 0
      gy = GhostDropY()

      If gy <> curY
        DrawPieceAt(curType, curRot, curX, gy, 65)
      EndIf
      DrawPieceAt(curType, curRot, curX, curY, 255)

      ; Lock-delay pulse when grounded
      If locking And TouchingGround()
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        Box(fieldLeft, fieldTop + fh - 3, fw, 3, RGBA(255, 200, 80, 80 + ((ElapsedMilliseconds() / 80) % 2) * 70))
        DrawingMode(#PB_2DDrawing_Default)
      EndIf
    EndIf
  EndIf

  DrawParticles()

  ; HOLD
  DrawPanelBox(10, fieldTop, 56, 80, "HOLD")
  If holdType >= 0
    If holdUsed
      holdAlpha = 90
    Else
      holdAlpha = 255
    EndIf

    DrawMiniPiece(holdType, 14, fieldTop + 28, 10, holdAlpha)
  EndIf

  ; NEXT queue (3)
  sideX = fieldLeft + fw + 12
  nextH = 24 + #NEXT_COUNT * 52
  DrawPanelBox(sideX, fieldTop, 86, nextH, "NEXT")

  For i = 0 To #NEXT_COUNT - 1
    If nextQueue(i) >= 0
      DrawMiniPiece(nextQueue(i), sideX + 12, fieldTop + 26 + i * 52, 11, 255 - i * 40)
    EndIf
  Next

  ; Stats
  DrawPanelBox(sideX, fieldTop + nextH + 8, 86, 140, "STATS")
  DrawingMode(#PB_2DDrawing_Transparent)

  If panelFont
    DrawingFont(FontID(panelFont))
  EndIf

  FrontColor(RGB(220, 230, 245))
  DrawText(sideX + 8, fieldTop + nextH + 34, "SCORE")
  FrontColor(RGB(255, 220, 120))
  DrawText(sideX + 8, fieldTop + nextH + 54, Str(score))
  FrontColor(RGB(220, 230, 245))
  DrawText(sideX + 8, fieldTop + nextH + 78, "LEVEL")
  FrontColor(RGB(120, 220, 255))
  DrawText(sideX + 8, fieldTop + nextH + 98, Str(level + 1))
  FrontColor(RGB(220, 230, 245))
  DrawText(sideX + 8, fieldTop + nextH + 122, "LINES")
  FrontColor(RGB(160, 255, 180))
  DrawText(sideX + 8, fieldTop + nextH + 142, Str(lines))

  DrawPanelBox(sideX, fieldTop + nextH + 156, 86, 60, "BEST")
  FrontColor(RGB(255, 200, 140))
  DrawText(sideX + 8, fieldTop + nextH + 186, Str(highScore))
  DrawingMode(#PB_2DDrawing_Default)

  DrawLevelFx()

  If gameState = #STATE_PAUSED
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    Box(fieldLeft, fieldTop, fw, fh, RGBA(0, 0, 0, 140))
    DrawingMode(#PB_2DDrawing_Transparent)
    label = "PAUSED"

    If panelFont
      DrawingFont(FontID(panelFont))
    EndIf

    FrontColor(RGB(255, 255, 255))
    DrawText(fieldLeft + (fw - TextWidth(label)) / 2, fieldTop + fh / 2 - 10, label)
    DrawingMode(#PB_2DDrawing_Default)
  EndIf

  If gameState = #STATE_GAMEOVER
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    Box(fieldLeft, fieldTop, fw, fh, RGBA(0, 0, 0, 150))
    DrawingMode(#PB_2DDrawing_Default)

    resultText = "GAME OVER"
    resultProg = 100

    If resultFxAt > 0
      resultElapsed = ElapsedMilliseconds() - resultFxAt

      If resultElapsed < #FX_RESULT_MS
        resultProg = EaseOutQuad100(resultElapsed * 100 / #FX_RESULT_MS)
      EndIf
    EndIf

    resultAlpha = resultProg * 255 / 100
    resultRise = (100 - resultProg) * 12 / 100

    font = LoadFont(#PB_Any, "Microsoft JhengHei UI", MaxI(18, cellSize), #PB_Font_HighQuality | #PB_Font_Bold)
    
    If font = 0
      font = LoadFont(#PB_Any, "Segoe UI", MaxI(18, cellSize), #PB_Font_HighQuality | #PB_Font_Bold)
    EndIf

    If font
      DrawingFont(FontID(font))
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      FrontColor(RGBA(0, 0, 0, resultAlpha * 140 / 255))
      DrawText(fieldLeft + (fw - TextWidth(resultText)) / 2 + 2, fieldTop + fh / 2 - 24 + resultRise + 2, resultText)
      FrontColor(RGBA(255, 90, 90, resultAlpha))
      DrawText(fieldLeft + (fw - TextWidth(resultText)) / 2, fieldTop + fh / 2 - 24 + resultRise, resultText)

      label = "Score " + Str(score)
      FrontColor(RGBA(255, 230, 160, resultAlpha))
      DrawText(fieldLeft + (fw - TextWidth(label)) / 2, fieldTop + fh / 2 + 8 + resultRise, label)
      DrawingMode(#PB_2DDrawing_Default)
      FreeFont(font)
    EndIf
  EndIf
EndProcedure

; <summary>
; DrawBoard
; </summary>
Procedure DrawBoard()
  EnsureBoardImage()

  If StartDrawing(ImageOutput(boardImage))
    DrawBoardContent()
    StopDrawing()
  EndIf

  If StartDrawing(CanvasOutput(#CANVAS))
    DrawImage(ImageID(boardImage), 0, 0)
    StopDrawing()
  EndIf
EndProcedure

; <summary>
; EffectsActive
; </summary>
Procedure.b EffectsActive()
  Protected now.i = ElapsedMilliseconds()

  If gameState = #STATE_LINECLEAR Or gameState = #STATE_LINEFALL
    ProcedureReturn #True
  EndIf

  If particleFxAt > 0 And particleCount > 0 And (now - particleFxAt) < #FX_PARTICLE_MS
    ProcedureReturn #True
  EndIf

  If lockFxAt > 0 And (now - lockFxAt) < #FX_LOCK_MS
    ProcedureReturn #True
  EndIf

  If dropTrailAt > 0 And (now - dropTrailAt) < #FX_DROP_TRAIL_MS
    ProcedureReturn #True
  EndIf

  If levelFxAt > 0 And (now - levelFxAt) < #FX_LEVEL_MS
    ProcedureReturn #True
  EndIf

  If locking And gameState = #STATE_PLAYING
    ProcedureReturn #True
  EndIf

  If gameState = #STATE_GAMEOVER And resultFxAt > 0
    If (now - resultFxAt) < #FX_RESULT_MS
      ProcedureReturn #True
    EndIf
  EndIf

  ProcedureReturn #False
EndProcedure

; <summary>
; EffectsTick
; </summary>
Procedure EffectsTick()
  If EffectsActive()
    DrawBoard()
  EndIf
EndProcedure
