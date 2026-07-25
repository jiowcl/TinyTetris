;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; ClearField
; </summary>
Procedure ClearField()
  Protected x.i, y.i

  For y = 0 To #FIELD_H - 1
    For x = 0 To #FIELD_W - 1
      field(x, y) = #PIECE_NONE
    Next
    clearRow(y) = #False
  Next

  clearCount = 0
EndProcedure

; <summary>
; InitGame
; </summary>
Procedure InitGame()
  ClearField()

  score = 0
  level = 0
  lines = 0
  holdType = #PIECE_NONE
  holdUsed = #False
  curType = #PIECE_NONE
  nextType = #PIECE_NONE
  gameState = #STATE_PLAYING
  resultFxAt = 0
  lineClearAt = 0
  particleCount = 0
  particleFxAt = 0
  ResetLock()

  InitBag()
  
  nextType = BagNext()
  SpawnPiece()
  gravityAt = ElapsedMilliseconds()
  
  UpdateStatus()
EndProcedure

; <summary>
; RestartGame
; </summary>
Procedure RestartGame()
  InitGame()
  SetGadgetText(#BTN_PAUSE, "Pause")
  DrawBoard()
  FocusCanvas()
EndProcedure

; <summary>
; TogglePause
; </summary>
Procedure TogglePause()
  If gameState = #STATE_PLAYING
    gameState = #STATE_PAUSED
    
    SetGadgetText(#BTN_PAUSE, "Resume")
    UpdateStatus()
    DrawBoard()
  ElseIf gameState = #STATE_PAUSED
    gameState = #STATE_PLAYING
    gravityAt = ElapsedMilliseconds()
    
    ResetLock()
    SetGadgetText(#BTN_PAUSE, "Pause")
    UpdateStatus()
    DrawBoard()
  EndIf

  FocusCanvas()
EndProcedure

; <summary>
; GameTick
; </summary>
Procedure GameTick()
  Protected now.i = ElapsedMilliseconds()
  Protected n.i

  ; Always poll input so Pause / Restart work outside PLAYING.
  InputTick()

  Select gameState
    Case #STATE_LINECLEAR
      If now - lineClearAt >= #LINECLEAR_MS
        n = clearCount
        ClearMarkedLines()
        AddScoreForLines(n)
        gameState = #STATE_PLAYING
        SpawnPiece()
        UpdateStatus()
        DrawBoard()
      EndIf

    Case #STATE_PLAYING
      If curType >= 0
        If TouchingGround()
          If locking = #False
            locking = #True
            lockAt = now
          ElseIf now - lockAt >= #LOCK_DELAY_MS
            LockPiece()
            UpdateStatus()
            DrawBoard()
            ProcedureReturn
          EndIf
        Else
          ResetLock()
          
          If now - gravityAt >= GravityMs(level)
            TryMove(0, 1)
            gravityAt = now
            DrawBoard()
          EndIf
        EndIf
      EndIf
  EndSelect
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 72
; FirstLine = 78
; Folding = -
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory