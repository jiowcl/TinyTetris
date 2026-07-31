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
    fallDist(y) = 0
  Next

  clearCount = 0
  pendingLines = 0
  pendingTSpin = #TSPIN_NONE
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
  gameState = #STATE_PLAYING
  resultFxAt = 0
  lineClearAt = 0
  lineFallAt = 0
  spawnWaitAt = 0
  lockFxAt = 0
  lockFxCount = 0
  dropTrailAt = 0
  levelFxAt = 0
  lockResets = 0
  backToBack = #False
  comboCount = 0
  lastAction = #ACTION_NONE
  lastKickIndex = 0
  clearMsg = ""
  clearMsgAt = 0
  ClearParticleFx()
  ResetLock()

  InitBag()
  FillNextQueue()
  SpawnPiece()
  gravityAt = ElapsedMilliseconds()
  UpdateStatus()
  StartBgm()
EndProcedure

; <summary>
; RestartGame
; </summary>
Procedure RestartGame()
  StopBgm()
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
    PauseBgm()
    SetGadgetText(#BTN_PAUSE, "Resume")
    UpdateStatus()
    DrawBoard()
  ElseIf gameState = #STATE_PAUSED
    gameState = #STATE_PLAYING
    gravityAt = ElapsedMilliseconds()
    ResetLock()
    ResumeBgm()
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

  InputTick()
  MusicTick()

  Select gameState
    Case #STATE_LINECLEAR
      If now - lineClearAt >= #LINECLEAR_MS
        PrepareLineFall()
        DrawBoard()
      EndIf

    Case #STATE_LINEFALL
      If now - lineFallAt >= #LINEFALL_MS
        ApplyLineClear()
        StartSpawnWait(#True)
        DrawBoard()
      EndIf

    Case #STATE_SPAWNWAIT
      If now >= spawnWaitAt
        SpawnPiece()
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
