;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; SyncSettingsPanel
; </summary>
Procedure SyncSettingsPanel()
  If IsWindow(#WIN_SETTINGS) = 0
    ProcedureReturn
  EndIf

  SetGadgetState(#TRK_DAS, dasDelayMs)
  SetGadgetState(#TRK_ARR, dasRepeatMs)
  SetGadgetState(#TRK_MUSIC_VOL, musicVolume)
  SetGadgetText(#LBL_DAS_VAL, Str(dasDelayMs) + " ms")
  SetGadgetText(#LBL_ARR_VAL, Str(dasRepeatMs) + " ms")
  SetGadgetText(#LBL_MVOL_VAL, Str(musicVolume) + " %")
EndProcedure

; <summary>
; ApplySettingsFromPanel
; </summary>
Procedure ApplySettingsFromPanel()
  If IsWindow(#WIN_SETTINGS) = 0
    ProcedureReturn
  EndIf

  dasDelayMs = ClampI(GetGadgetState(#TRK_DAS), 80, 400)
  dasRepeatMs = ClampI(GetGadgetState(#TRK_ARR), 16, 120)
  musicVolume = ClampI(GetGadgetState(#TRK_MUSIC_VOL), 0, 100)

  SetGadgetText(#LBL_DAS_VAL, Str(dasDelayMs) + " ms")
  SetGadgetText(#LBL_ARR_VAL, Str(dasRepeatMs) + " ms")
  SetGadgetText(#LBL_MVOL_VAL, Str(musicVolume) + " %")

  If musicPlaying And musicPaused = #False And musicFadeAt = 0
    ApplyMusicVolume(musicVolume)
  ElseIf musicPlaying And musicPaused
    ; keep ducked volume while paused
  EndIf

  SavePrefs()
EndProcedure

; <summary>
; CloseSettingsPanel
; </summary>
Procedure CloseSettingsPanel()
  If IsWindow(#WIN_SETTINGS)
    ApplySettingsFromPanel()
    CloseWindow(#WIN_SETTINGS)
  EndIf

  settingsOpen = #False
  FocusCanvas()
EndProcedure

; <summary>
; OpenSettingsPanel
; </summary>
Procedure OpenSettingsPanel()
  If settingsOpen And IsWindow(#WIN_SETTINGS)
    SetActiveWindow(#WIN_SETTINGS)
    
    ProcedureReturn
  EndIf

  If gameState = #STATE_PLAYING
    gameState = #STATE_PAUSED
    PauseBgm()
    SetGadgetText(#BTN_PAUSE, "Resume")
    UpdateStatus()
    DrawBoard()
  EndIf

  If OpenWindow(#WIN_SETTINGS, #PB_Ignore, #PB_Ignore, 320, 230, "Settings", #PB_Window_SystemMenu | #PB_Window_Tool | #PB_Window_WindowCentered, WindowID(#WIN_MAIN))
    TextGadget(#LBL_DAS_TITLE, 15, 18, 80, 20, "DAS")
    TrackBarGadget(#TRK_DAS, 95, 15, 140, 28, 80, 400)
    TextGadget(#LBL_DAS_VAL, 245, 18, 60, 20, "")

    TextGadget(#LBL_ARR_TITLE, 15, 58, 80, 20, "ARR")
    TrackBarGadget(#TRK_ARR, 95, 55, 140, 28, 16, 120)
    TextGadget(#LBL_ARR_VAL, 245, 58, 60, 20, "")

    TextGadget(#LBL_MVOL_TITLE, 15, 98, 80, 20, "Music")
    TrackBarGadget(#TRK_MUSIC_VOL, 95, 95, 140, 28, 0, 100)
    TextGadget(#LBL_MVOL_VAL, 245, 98, 60, 20, "")

    TextGadget(#PB_Any, 15, 140, 290, 36, "DAS = delay before auto-shift / ARR = repeat rate", #PB_Text_Center)

    ButtonGadget(#BTN_SETTINGS_OK, 100, 185, 120, 30, "OK")

    If uiFont
      SetGadgetFont(#LBL_DAS_TITLE, FontID(uiFont))
      SetGadgetFont(#LBL_ARR_TITLE, FontID(uiFont))
      SetGadgetFont(#LBL_MVOL_TITLE, FontID(uiFont))
      SetGadgetFont(#LBL_DAS_VAL, FontID(uiFont))
      SetGadgetFont(#LBL_ARR_VAL, FontID(uiFont))
      SetGadgetFont(#LBL_MVOL_VAL, FontID(uiFont))
      SetGadgetFont(#BTN_SETTINGS_OK, FontID(uiFont))
    EndIf

    SyncSettingsPanel()
    settingsOpen = #True
  EndIf
EndProcedure

; <summary>
; SettingsPanelEvent
; Handle events for the settings tool window.
; </summary>
Procedure SettingsPanelEvent()
  If settingsOpen = #False Or IsWindow(#WIN_SETTINGS) = 0
    ProcedureReturn
  EndIf

  Select EventWindow()
    Case #WIN_SETTINGS
      Select Event()
        Case #PB_Event_CloseWindow
          CloseSettingsPanel()

        Case #PB_Event_Gadget
          Select EventGadget()
            Case #TRK_DAS, #TRK_ARR, #TRK_MUSIC_VOL
              ApplySettingsFromPanel()

            Case #BTN_SETTINGS_OK
              CloseSettingsPanel()
          EndSelect
      EndSelect
  EndSelect
EndProcedure
