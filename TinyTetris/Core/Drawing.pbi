;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; EaseOutQuad100
; </summary>
Procedure.i EaseOutQuad100(t.i)
  Protected u.i

  If t <= 0 : ProcedureReturn 0 : EndIf
  If t >= 100 : ProcedureReturn 100 : EndIf

  u = 100 - t
  ProcedureReturn 100 - (u * u) / 100
EndProcedure

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
Procedure DrawMiniPiece(type.i, ox.i, oy.i, size.i)
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
    
    DrawCell(offX + cx * size, offY + cy * size, size - 1, PieceColor(type), 255)
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
; DrawBoardContent
; </summary>
Procedure DrawBoardContent()
  Protected x.i, y.i
  Protected sx.i, sy.i
  Protected fw.i, fh.i
  Protected gy.i
  Protected flash.i
  Protected sideX.i
  Protected mini.i
  Protected resultText.s
  Protected resultProg.i, resultElapsed.i
  Protected resultAlpha.i, resultRise.i
  Protected font.i
  Protected label.s

  CalculateLayout()

  ; Atmosphere background
  Box(0, 0, canvasW, canvasH, RGB(18, 24, 36))
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(34, 52, 78))
  FrontColor(RGB(12, 16, 28))
  LinearGradient(0, 0, 0, canvasH)
  Box(0, 0, canvasW, canvasH)
  DrawingMode(#PB_2DDrawing_Default)

  fw = #FIELD_W * cellSize
  fh = #FIELD_VISIBLE_H * cellSize

  ; Playfield well
  DrawingMode(#PB_2DDrawing_AlphaBlend)
  Box(fieldLeft - 3, fieldTop - 3, fw + 6, fh + 6, RGBA(8, 12, 20, 255))
  Box(fieldLeft, fieldTop, fw, fh, RGBA(28, 36, 52, 255))
  DrawingMode(#PB_2DDrawing_Default)

  ; Grid
  FrontColor(RGB(45, 58, 78))

  For x = 0 To #FIELD_W
    LineXY(fieldLeft + x * cellSize, fieldTop, fieldLeft + x * cellSize, fieldTop + fh)
  Next
  For y = 0 To #FIELD_VISIBLE_H
    LineXY(fieldLeft, fieldTop + y * cellSize, fieldLeft + fw, fieldTop + y * cellSize)
  Next

  ; Locked blocks
  flash = #False

  If gameState = #STATE_LINECLEAR
    If ((ElapsedMilliseconds() - lineClearAt) / 60) % 2 = 0
      flash = #True
    EndIf
  EndIf

  For y = #FIELD_HIDDEN To #FIELD_H - 1
    For x = 0 To #FIELD_W - 1
      If field(x, y) <> #PIECE_NONE
        sx = CellToScreenX(x)
        sy = CellToScreenY(y)

        If clearRow(y) And flash
          DrawCell(sx, sy, cellSize - 1, RGB(255, 255, 255), 230)
        Else
          DrawCell(sx, sy, cellSize - 1, PieceColor(field(x, y)), 255)
        EndIf
      EndIf
    Next
  Next

  ; Ghost + current
  If gameState = #STATE_PLAYING Or gameState = #STATE_PAUSED
    If curType >= 0
      gy = GhostDropY()

      If gy <> curY
        DrawPieceAt(curType, curRot, curX, gy, 70)
      EndIf
      
      DrawPieceAt(curType, curRot, curX, curY, 255)
    EndIf
  EndIf

  ; HOLD panel
  DrawPanelBox(10, fieldTop, 56, 80, "HOLD")
  mini = 10
  If holdType >= 0
    DrawMiniPiece(holdType, 14, fieldTop + 28, mini)
  EndIf

  ; NEXT panel
  sideX = fieldLeft + fw + 12
  DrawPanelBox(sideX, fieldTop, 86, 90, "NEXT")
  If nextType >= 0
    DrawMiniPiece(nextType, sideX + 10, fieldTop + 30, 12)
  EndIf

  ; Stats
  DrawPanelBox(sideX, fieldTop + 100, 86, 150, "STATS")
  DrawingMode(#PB_2DDrawing_Transparent)
  
  If panelFont
    DrawingFont(FontID(panelFont))
  EndIf
  
  FrontColor(RGB(220, 230, 245))
  DrawText(sideX + 8, fieldTop + 128, "SCORE")
  FrontColor(RGB(255, 220, 120))
  DrawText(sideX + 8, fieldTop + 148, Str(score))
  FrontColor(RGB(220, 230, 245))
  DrawText(sideX + 8, fieldTop + 172, "LEVEL")
  FrontColor(RGB(120, 220, 255))
  DrawText(sideX + 8, fieldTop + 192, Str(level + 1))
  FrontColor(RGB(220, 230, 245))
  DrawText(sideX + 8, fieldTop + 216, "LINES")
  FrontColor(RGB(160, 255, 180))
  DrawText(sideX + 8, fieldTop + 236, Str(lines))

  DrawPanelBox(sideX, fieldTop + 260, 86, 70, "BEST")
  FrontColor(RGB(255, 200, 140))
  DrawText(sideX + 8, fieldTop + 290, Str(highScore))
  DrawingMode(#PB_2DDrawing_Default)

  ; Pause / Game Over overlays
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
  If gameState = #STATE_LINECLEAR
    ProcedureReturn #True
  EndIf

  If gameState = #STATE_GAMEOVER And resultFxAt > 0
    If (ElapsedMilliseconds() - resultFxAt) < #FX_RESULT_MS
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

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 305
; FirstLine = 307
; Folding = --
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory