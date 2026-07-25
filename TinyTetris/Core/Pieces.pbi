;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; SetPieceCells
; Load four (x,y) cells for one rotation of one piece.
; </summary>
Procedure SetPieceCells(type.i, rot.i, x0.i, y0.i, x1.i, y1.i, x2.i, y2.i, x3.i, y3.i)
  pieceX(type, rot, 0) = x0 : pieceY(type, rot, 0) = y0
  pieceX(type, rot, 1) = x1 : pieceY(type, rot, 1) = y1
  pieceX(type, rot, 2) = x2 : pieceY(type, rot, 2) = y2
  pieceX(type, rot, 3) = x3 : pieceY(type, rot, 3) = y3
EndProcedure

; <summary>
; InitPieceData
; Classic tetromino orientations (JLSTZ / I / O style).
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
Procedure.i PieceCellX(type.i, rot.i, cell.i)
  If type < 0 Or type >= #PIECE_COUNT Or cell < 0 Or cell >= #CELLS_PER_PIECE
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn pieceX(type, NormRot(rot), cell)
EndProcedure

; <summary>
; PieceCellY
; </summary>
Procedure.i PieceCellY(type.i, rot.i, cell.i)
  If type < 0 Or type >= #PIECE_COUNT Or cell < 0 Or cell >= #CELLS_PER_PIECE
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn pieceY(type, NormRot(rot), cell)
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