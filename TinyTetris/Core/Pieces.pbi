;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; SetPieceCells
; Load four (x,y) cells for one rotation of one piece.
; </summary>
; <param name="type">integer</param>
; <param name="rot">integer</param>
; <param name="x0">integer</param>
; <param name="y0">integer</param>
; <param name="x1">integer</param>
; <param name="y1">integer</param>
; <param name="x2">integer</param>
; <param name="y2">integer</param>
; <param name="x3">integer</param>
; <param name="y3">integer</param>
; <returns>Returns integer.</returns>
Procedure SetPieceCells(type.i, rot.i, x0.i, y0.i, x1.i, y1.i, x2.i, y2.i, x3.i, y3.i)
  pieceX(type, rot, 0) = x0 : pieceY(type, rot, 0) = y0
  pieceX(type, rot, 1) = x1 : pieceY(type, rot, 1) = y1
  pieceX(type, rot, 2) = x2 : pieceY(type, rot, 2) = y2
  pieceX(type, rot, 3) = x3 : pieceY(type, rot, 3) = y3
EndProcedure

; <summary>
; InitPieceData
; SRS tetromino orientations (JLSTZ / I / O).
; </summary>
Procedure InitPieceData()
  ; I
  SetPieceCells(#PIECE_I, 0, 0, 1, 1, 1, 2, 1, 3, 1)
  SetPieceCells(#PIECE_I, 1, 2, 0, 2, 1, 2, 2, 2, 3)
  SetPieceCells(#PIECE_I, 2, 0, 2, 1, 2, 2, 2, 3, 2)
  SetPieceCells(#PIECE_I, 3, 1, 0, 1, 1, 1, 2, 1, 3)

  ; O
  SetPieceCells(#PIECE_O, 0, 1, 0, 2, 0, 1, 1, 2, 1)
  SetPieceCells(#PIECE_O, 1, 1, 0, 2, 0, 1, 1, 2, 1)
  SetPieceCells(#PIECE_O, 2, 1, 0, 2, 0, 1, 1, 2, 1)
  SetPieceCells(#PIECE_O, 3, 1, 0, 2, 0, 1, 1, 2, 1)

  ; T
  SetPieceCells(#PIECE_T, 0, 1, 0, 0, 1, 1, 1, 2, 1)
  SetPieceCells(#PIECE_T, 1, 1, 0, 1, 1, 2, 1, 1, 2)
  SetPieceCells(#PIECE_T, 2, 0, 1, 1, 1, 2, 1, 1, 2)
  SetPieceCells(#PIECE_T, 3, 1, 0, 0, 1, 1, 1, 1, 2)

  ; S
  SetPieceCells(#PIECE_S, 0, 1, 0, 2, 0, 0, 1, 1, 1)
  SetPieceCells(#PIECE_S, 1, 1, 0, 1, 1, 2, 1, 2, 2)
  SetPieceCells(#PIECE_S, 2, 1, 1, 2, 1, 0, 2, 1, 2)
  SetPieceCells(#PIECE_S, 3, 0, 0, 0, 1, 1, 1, 1, 2)

  ; Z
  SetPieceCells(#PIECE_Z, 0, 0, 0, 1, 0, 1, 1, 2, 1)
  SetPieceCells(#PIECE_Z, 1, 2, 0, 1, 1, 2, 1, 1, 2)
  SetPieceCells(#PIECE_Z, 2, 0, 1, 1, 1, 1, 2, 2, 2)
  SetPieceCells(#PIECE_Z, 3, 1, 0, 0, 1, 1, 1, 0, 2)

  ; J
  SetPieceCells(#PIECE_J, 0, 0, 0, 0, 1, 1, 1, 2, 1)
  SetPieceCells(#PIECE_J, 1, 1, 0, 2, 0, 1, 1, 1, 2)
  SetPieceCells(#PIECE_J, 2, 0, 1, 1, 1, 2, 1, 2, 2)
  SetPieceCells(#PIECE_J, 3, 1, 0, 1, 1, 0, 2, 1, 2)

  ; L
  SetPieceCells(#PIECE_L, 0, 2, 0, 0, 1, 1, 1, 2, 1)
  SetPieceCells(#PIECE_L, 1, 1, 0, 1, 1, 1, 2, 2, 2)
  SetPieceCells(#PIECE_L, 2, 0, 1, 1, 1, 2, 1, 0, 2)
  SetPieceCells(#PIECE_L, 3, 0, 0, 1, 0, 1, 1, 1, 2)
EndProcedure

; <summary>
; PieceColor
; </summary>
; <param name="type">integer</param>
; <returns>Returns integer.</returns>
Procedure.i PieceColor(type.i)
  Select type
    Case #PIECE_I : ProcedureReturn RGB(0, 220, 220)
    Case #PIECE_O : ProcedureReturn RGB(240, 220, 40)
    Case #PIECE_T : ProcedureReturn RGB(170, 70, 210)
    Case #PIECE_S : ProcedureReturn RGB(80, 200, 80)
    Case #PIECE_Z : ProcedureReturn RGB(220, 60, 60)
    Case #PIECE_J : ProcedureReturn RGB(60, 100, 230)
    Case #PIECE_L : ProcedureReturn RGB(240, 150, 40)
  EndSelect
  ProcedureReturn RGB(120, 120, 120)
EndProcedure

; <summary>
; NormRot
; </summary>
; <param name="rot">integer</param>
; <returns>Returns integer.</returns>
Procedure.i NormRot(rot.i)
  rot = rot % #ROT_COUNT
  If rot < 0
    rot + #ROT_COUNT
  EndIf
  ProcedureReturn rot
EndProcedure

; <summary>
; PieceCellX
; </summary>
; <param name="type">integer</param>
; <param name="rot">integer</param>
; <param name="cell">integer</param>
; <returns>Returns integer.</returns>
Procedure.i PieceCellX(type.i, rot.i, cell.i)
  If type < 0 Or type >= #PIECE_COUNT Or cell < 0 Or cell >= #CELLS_PER_PIECE
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn pieceX(type, NormRot(rot), cell)
EndProcedure

; <summary>
; PieceCellY
; </summary>
; <param name="type">integer</param>
; <param name="rot">integer</param>
; <param name="cell">integer</param>
; <returns>Returns integer.</returns>
Procedure.i PieceCellY(type.i, rot.i, cell.i)
  If type < 0 Or type >= #PIECE_COUNT Or cell < 0 Or cell >= #CELLS_PER_PIECE
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn pieceY(type, NormRot(rot), cell)
EndProcedure

; <summary>
; SetKickSrs
; SRS offsets use Y-up; convert to board Y-down via kickDY = -sy.
; </summary>
; <param name="sx">integer</param>
; <param name="sy">integer</param>
; <returns>Returns void.</returns>
Procedure SetKickSrs(sx.i, sy.i)
  kickDX = sx
  kickDY = -sy
EndProcedure

; <summary>
; FillSrsKick
; Guideline SRS wall-kick table for test index 0..4.
; </summary>
; <param name="type">integer</param>
; <param name="fromRot">integer</param>
; <param name="dir">integer</param>
; <param name="test">integer</param>
; <returns>Returns void.</returns>
Procedure FillSrsKick(type.i, fromRot.i, dir.i, test.i)
  Protected toRot.i = NormRot(fromRot + dir)

  kickDX = 0
  kickDY = 0

  If test < 0 Or test >= #SRS_KICK_TESTS
    ProcedureReturn
  EndIf

  If type = #PIECE_I
    If dir > 0
      Select fromRot
        Case 0 ; 0>>1
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(-2, 0)
            Case 2 : SetKickSrs(1, 0)
            Case 3 : SetKickSrs(-2, -1)
            Case 4 : SetKickSrs(1, 2)
          EndSelect
        Case 1 ; 1>>2
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(-1, 0)
            Case 2 : SetKickSrs(2, 0)
            Case 3 : SetKickSrs(-1, 2)
            Case 4 : SetKickSrs(2, -1)
          EndSelect
        Case 2 ; 2>>3
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(2, 0)
            Case 2 : SetKickSrs(-1, 0)
            Case 3 : SetKickSrs(2, 1)
            Case 4 : SetKickSrs(-1, -2)
          EndSelect
        Case 3 ; 3>>0
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(1, 0)
            Case 2 : SetKickSrs(-2, 0)
            Case 3 : SetKickSrs(1, -2)
            Case 4 : SetKickSrs(-2, 1)
          EndSelect
      EndSelect
    Else
      Select fromRot
        Case 0 ; 0>>3
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(-1, 0)
            Case 2 : SetKickSrs(2, 0)
            Case 3 : SetKickSrs(-1, 2)
            Case 4 : SetKickSrs(2, -1)
          EndSelect
        Case 1 ; 1>>0
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(2, 0)
            Case 2 : SetKickSrs(-1, 0)
            Case 3 : SetKickSrs(2, 1)
            Case 4 : SetKickSrs(-1, -2)
          EndSelect
        Case 2 ; 2>>1
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(1, 0)
            Case 2 : SetKickSrs(-2, 0)
            Case 3 : SetKickSrs(1, -2)
            Case 4 : SetKickSrs(-2, 1)
          EndSelect
        Case 3 ; 3>>2
          Select test
            Case 0 : SetKickSrs(0, 0)
            Case 1 : SetKickSrs(-2, 0)
            Case 2 : SetKickSrs(1, 0)
            Case 3 : SetKickSrs(-2, -1)
            Case 4 : SetKickSrs(1, 2)
          EndSelect
      EndSelect
    EndIf
    ProcedureReturn
  EndIf

  ; JLSTZ
  If dir > 0
    Select fromRot
      Case 0 ; 0>>1
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(-1, 0)
          Case 2 : SetKickSrs(-1, 1)
          Case 3 : SetKickSrs(0, -2)
          Case 4 : SetKickSrs(-1, -2)
        EndSelect
      Case 1 ; 1>>2
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(1, 0)
          Case 2 : SetKickSrs(1, -1)
          Case 3 : SetKickSrs(0, 2)
          Case 4 : SetKickSrs(1, 2)
        EndSelect
      Case 2 ; 2>>3
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(1, 0)
          Case 2 : SetKickSrs(1, 1)
          Case 3 : SetKickSrs(0, -2)
          Case 4 : SetKickSrs(1, -2)
        EndSelect
      Case 3 ; 3>>0
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(-1, 0)
          Case 2 : SetKickSrs(-1, -1)
          Case 3 : SetKickSrs(0, 2)
          Case 4 : SetKickSrs(-1, 2)
        EndSelect
    EndSelect
  Else
    Select fromRot
      Case 0 ; 0>>3
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(1, 0)
          Case 2 : SetKickSrs(1, -1)
          Case 3 : SetKickSrs(0, 2)
          Case 4 : SetKickSrs(1, 2)
        EndSelect
      Case 1 ; 1>>0
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(1, 0)
          Case 2 : SetKickSrs(1, 1)
          Case 3 : SetKickSrs(0, -2)
          Case 4 : SetKickSrs(1, -2)
        EndSelect
      Case 2 ; 2>>1
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(-1, 0)
          Case 2 : SetKickSrs(-1, -1)
          Case 3 : SetKickSrs(0, 2)
          Case 4 : SetKickSrs(-1, 2)
        EndSelect
      Case 3 ; 3>>2
        Select test
          Case 0 : SetKickSrs(0, 0)
          Case 1 : SetKickSrs(-1, 0)
          Case 2 : SetKickSrs(-1, 1)
          Case 3 : SetKickSrs(0, -2)
          Case 4 : SetKickSrs(-1, -2)
        EndSelect
    EndSelect
  EndIf

  ; silence unused warning for toRot in some compilers
  toRot = toRot
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 109
; FirstLine = 37
; Folding = --
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory