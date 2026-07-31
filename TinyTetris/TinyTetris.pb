;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

EnableExplicit

CompilerIf #PB_Compiler_Unicode = 0
  CompilerError "Enable Unicode in Compiler menu, and save this file as UTF-8 with BOM."
CompilerEndIf

If InitSound() = 0
  MessageRequester("Error", "Sound System is not Available", 0)
  End
EndIf

RandomSeed(ElapsedMilliseconds())

IncludeFile "./Core/Enums.pbi"
IncludeFile "./Core/Globals.pbi"
IncludeFile "./Core/Helpers.pbi"
IncludeFile "./Core/Music.pbi"
IncludeFile "./Core/Pieces.pbi"
IncludeFile "./Core/Board.pbi"
IncludeFile "./Core/Drawing.pbi"
IncludeFile "./Core/Game.pbi"
IncludeFile "./Core/Input.pbi"
IncludeFile "./Core/Settings.pbi"

; Ui
If OpenWindow(#WIN_MAIN, #PB_Ignore, #PB_Ignore, 450, 680, "TinyTetris " + #APP_VERSION$ + " by Jiowcl", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
  CanvasGadget(#CANVAS, 15, 15, canvasW, canvasH)

  ButtonGadget(#BTN_RESTART, 15, 545, 130, 35, "Restart")
  ButtonGadget(#BTN_PAUSE, 155, 545, 130, 35, "Pause")
  ButtonGadget(#BTN_SETTINGS, 295, 545, 140, 35, "Settings")

  CheckBoxGadget(#CHK_SOUND, 15, 588, 80, 24, "Sound")
  SetGadgetState(#CHK_SOUND, #True)
  CheckBoxGadget(#CHK_MUSIC, 100, 588, 80, 24, "Music")
  SetGadgetState(#CHK_MUSIC, #True)
  TextGadget(#LBL_VERSION, 300, 590, 135, 20, "v" + #APP_VERSION$, #PB_Text_Right)

  TextGadget(#LBL_HELP, 15, 618, 420, 20, "Left/Right move  Up/X rotate  Z CCW  Down soft  Space hard  C hold  P pause")
  TextGadget(#LBL_STATUS, 15, 642, 420, 24, "", #PB_Text_Center)

  LoadUIFont()
  LoadPrefs()
  InitBgm()
  ApplyPrefsToUi()
  SyncCanvasSize()
  BindGadgetEvent(#CANVAS, @CanvasGadgetEvent())

  InitPieceData()
  InitInput()
  InitGame()
  DrawBoard()
  FocusCanvas()

  Repeat
    GameTick()
    EffectsTick()

    Select WaitWindowEvent(10)
      Case #PB_Event_CloseWindow
        If EventWindow() = #WIN_SETTINGS
          CloseSettingsPanel()
        Else
          Break
        EndIf

      Case #PB_Event_Gadget
        If EventWindow() = #WIN_SETTINGS
          Select EventGadget()
            Case #TRK_DAS, #TRK_ARR, #TRK_MUSIC_VOL
              ApplySettingsFromPanel()
            Case #BTN_SETTINGS_OK
              CloseSettingsPanel()
          EndSelect
        Else
          Select EventGadget()
            Case #BTN_RESTART
              RestartGame()

            Case #BTN_PAUSE
              TogglePause()

            Case #BTN_SETTINGS
              OpenSettingsPanel()

            Case #CHK_SOUND
              soundEnabled = GetGadgetState(#CHK_SOUND)
              SavePrefs()
              FocusCanvas()

            Case #CHK_MUSIC
              If musicLoaded
                musicEnabled = GetGadgetState(#CHK_MUSIC)
                SavePrefs()
                If musicEnabled
                  If gameState = #STATE_PAUSED
                    StartBgm()
                    PauseBgm()
                  ElseIf gameState <> #STATE_GAMEOVER
                    StartBgm()
                  EndIf
                Else
                  StopBgm()
                EndIf
              EndIf
              FocusCanvas()
          EndSelect
        EndIf
    EndSelect
  ForEver

  CloseSettingsPanel()
  SavePrefs()
  FreeBgm()

  If boardImage <> -1
    FreeImage(boardImage)
  EndIf

  If uiFont
    FreeFont(uiFont)
  EndIf

  If statusFont
    FreeFont(statusFont)
  EndIf

  If panelFont
    FreeFont(panelFont)
  EndIf

  CloseWindow(#WIN_MAIN)
EndIf
