;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; FocusCanvas
; </summary>
Procedure FocusCanvas()
  SetActiveGadget(#CANVAS)
EndProcedure

; <summary>
; InitInput
; </summary>
Procedure InitInput()
  keyLeft = 0
  keyRight = 0
  keyDown = 0
  keyLeftPrev = 0
  keyRightPrev = 0
  keyDownPrev = 0
  dasDir = 0
  dasAt = 0
  dasRepeating = #False
  softDropAt = 0
EndProcedure

; <summary>
; KeyIsDown
; Uses Win32 GetAsyncKeyState via PureBasic underscore API.
; </summary>
Procedure.b KeyIsDown(vKey.i)
  If GetAsyncKeyState_(vKey) & $8000
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

; <summary>
; HandleKeyTap
; One-shot actions on edge (press).
; </summary>
Procedure HandleKeyTap(vKey.i)
  If gameState = #STATE_GAMEOVER
    If vKey = #VK_R Or vKey = #VK_SPACE
      RestartGame()
    EndIf
    
    ProcedureReturn
  EndIf

  If vKey = #VK_P
    TogglePause()
    ProcedureReturn
  EndIf

  If vKey = #VK_R
    RestartGame()

    ProcedureReturn
  EndIf

  If gameState <> #STATE_PLAYING
    ProcedureReturn
  EndIf

  Select vKey
    Case #VK_UP, #VK_X
      If TryRotate(1)
        PlaySoundSafe(#SOUND_ROTATE)
        DrawBoard()
      EndIf
    Case #VK_Z
      If TryRotate(-1)
        PlaySoundSafe(#SOUND_ROTATE)
        DrawBoard()
      EndIf
    Case #VK_SPACE
      HardDrop()
      UpdateStatus()
      DrawBoard()
    Case #VK_C, #VK_SHIFT
      If HoldPiece()
        UpdateStatus()
        DrawBoard()
      EndIf
  EndSelect
EndProcedure

; <summary>
; InputTick
; Poll held keys + DAS for left/right, soft drop.
; </summary>
Procedure InputTick()
  Protected now.i = ElapsedMilliseconds()
  Protected leftDown.i, rightDown.i, downDown.i
  Protected upDown.i, zDown.i, xDown.i, spaceDown.i, cDown.i, shiftDown.i
  Protected pDown.i, rDown.i
  Static upPrev.i, zPrev.i, xPrev.i, spacePrev.i, cPrev.i, shiftPrev.i
  Static pPrev.i, rPrev.i

  leftDown = Bool(KeyIsDown(#VK_LEFT))
  rightDown = Bool(KeyIsDown(#VK_RIGHT))
  downDown = Bool(KeyIsDown(#VK_DOWN))
  upDown = Bool(KeyIsDown(#VK_UP))
  zDown = Bool(KeyIsDown(#VK_Z))
  xDown = Bool(KeyIsDown(#VK_X))
  spaceDown = Bool(KeyIsDown(#VK_SPACE))
  cDown = Bool(KeyIsDown(#VK_C))
  shiftDown = Bool(KeyIsDown(#VK_SHIFT))
  pDown = Bool(KeyIsDown(#VK_P))
  rDown = Bool(KeyIsDown(#VK_R))

  If upDown And upPrev = #False : HandleKeyTap(#VK_UP) : EndIf
  If xDown And xPrev = #False : HandleKeyTap(#VK_X) : EndIf
  If zDown And zPrev = #False : HandleKeyTap(#VK_Z) : EndIf
  If spaceDown And spacePrev = #False : HandleKeyTap(#VK_SPACE) : EndIf
  If cDown And cPrev = #False : HandleKeyTap(#VK_C) : EndIf
  If shiftDown And shiftPrev = #False : HandleKeyTap(#VK_SHIFT) : EndIf
  If pDown And pPrev = #False : HandleKeyTap(#VK_P) : EndIf
  If rDown And rPrev = #False : HandleKeyTap(#VK_R) : EndIf

  upPrev = upDown
  zPrev = zDown
  xPrev = xDown
  spacePrev = spaceDown
  cPrev = cDown
  shiftPrev = shiftDown
  pPrev = pDown
  rPrev = rDown

  If gameState <> #STATE_PLAYING
    keyLeftPrev = leftDown
    keyRightPrev = rightDown
    keyDownPrev = downDown
    ProcedureReturn
  EndIf

  ; Horizontal DAS
  If leftDown And rightDown = #False
    If keyLeftPrev = #False
      If TryMove(-1, 0)
        PlaySoundSafe(#SOUND_MOVE)
        DrawBoard()
      EndIf

      dasDir = -1
      dasAt = now
      dasRepeating = #False
    ElseIf dasDir = -1
      If dasRepeating = #False
        If now - dasAt >= dasDelayMs
          dasRepeating = #True
          dasAt = now

          If TryMove(-1, 0)
            DrawBoard()
          EndIf
        EndIf
      ElseIf now - dasAt >= dasRepeatMs
        dasAt = now
        If TryMove(-1, 0)
          DrawBoard()
        EndIf
      EndIf
    EndIf
  ElseIf rightDown And leftDown = #False
    If keyRightPrev = #False
      If TryMove(1, 0)
        PlaySoundSafe(#SOUND_MOVE)
        DrawBoard()
      EndIf

      dasDir = 1
      dasAt = now
      dasRepeating = #False
    ElseIf dasDir = 1
      If dasRepeating = #False
        If now - dasAt >= dasDelayMs
          dasRepeating = #True
          dasAt = now

          If TryMove(1, 0)
            DrawBoard()
          EndIf
        EndIf
      ElseIf now - dasAt >= dasRepeatMs
        dasAt = now

        If TryMove(1, 0)
          DrawBoard()
        EndIf
      EndIf
    EndIf
  Else
    dasDir = 0
    dasRepeating = #False
  EndIf

  ; Soft drop (faster ARR than sideways)
  If downDown
    If keyDownPrev = #False
      SoftDropStep()
      softDropAt = now
      UpdateStatus()
      DrawBoard()
    ElseIf now - softDropAt >= #SOFT_REPEAT_MS
      softDropAt = now
      SoftDropStep()
      UpdateStatus()
      DrawBoard()
    EndIf
  EndIf

  keyLeftPrev = leftDown
  keyRightPrev = rightDown
  keyDownPrev = downDown
EndProcedure

; <summary>
; CanvasGadgetEvent
; </summary>
Procedure CanvasGadgetEvent()
  Select EventType()
    Case #PB_EventType_LeftButtonDown, #PB_EventType_RightButtonDown
      FocusCanvas()
  EndSelect
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 49
; FirstLine = 175
; Folding = --
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory