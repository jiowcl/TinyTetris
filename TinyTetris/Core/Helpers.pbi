;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; MinI
; </summary>
Procedure.i MinI(a.i, b.i)
  If a < b
    ProcedureReturn a
  EndIf

  ProcedureReturn b
EndProcedure

; <summary>
; MaxI
; </summary>
Procedure.i MaxI(a.i, b.i)
  If a > b
    ProcedureReturn a
  EndIf

  ProcedureReturn b
EndProcedure

; <summary>
; ClampI
; </summary>
Procedure.i ClampI(v.i, lo.i, hi.i)
  If v < lo
    ProcedureReturn lo
  EndIf

  If v > hi
    ProcedureReturn hi
  EndIf

  ProcedureReturn v
EndProcedure

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
; EaseInQuad100
; </summary>
Procedure.i EaseInQuad100(t.i)
  If t <= 0 : ProcedureReturn 0 : EndIf
  If t >= 100 : ProcedureReturn 100 : EndIf

  ProcedureReturn (t * t) / 100
EndProcedure

; <summary>
; PlaySoundSafe
; </summary>
Procedure PlaySoundSafe(soundId.i)
  If soundEnabled = #False
    ProcedureReturn
  EndIf

  If IsSound(soundId) <> 0
    PlaySound(soundId)
  EndIf
EndProcedure

; <summary>
; UpdateStatus
; </summary>
Procedure UpdateStatus()
  Select gameState
    Case #STATE_PLAYING
      SetGadgetText(#LBL_STATUS, "Playing — Level " + Str(level + 1))
    Case #STATE_PAUSED
      SetGadgetText(#LBL_STATUS, "Paused")
    Case #STATE_LINECLEAR
      If clearCount >= 4
        SetGadgetText(#LBL_STATUS, "Tetris!")
      Else
        SetGadgetText(#LBL_STATUS, "Line Clear ×" + Str(clearCount))
      EndIf
    Case #STATE_LINEFALL
      SetGadgetText(#LBL_STATUS, "Stack Drop")
    Case #STATE_SPAWNWAIT
      SetGadgetText(#LBL_STATUS, "Playing — Level " + Str(level + 1))
    Case #STATE_GAMEOVER
      SetGadgetText(#LBL_STATUS, "Game Over — Score " + Str(score))
  EndSelect
EndProcedure

; <summary>
; LoadUIFont
; </summary>
Procedure LoadUIFont()
  uiFont = LoadFont(#PB_Any, "Microsoft JhengHei UI", 12, #PB_Font_HighQuality)

  If uiFont = 0
    uiFont = LoadFont(#PB_Any, "Microsoft JhengHei", 12, #PB_Font_HighQuality)
  EndIf

  If uiFont = 0
    uiFont = LoadFont(#PB_Any, "Segoe UI", 12, #PB_Font_HighQuality)
  EndIf

  If uiFont
    SetGadgetFont(#BTN_RESTART, FontID(uiFont))
    SetGadgetFont(#BTN_PAUSE, FontID(uiFont))
    SetGadgetFont(#CHK_SOUND, FontID(uiFont))
    SetGadgetFont(#CHK_MUSIC, FontID(uiFont))
    SetGadgetFont(#LBL_VERSION, FontID(uiFont))
    SetGadgetFont(#LBL_HELP, FontID(uiFont))
  EndIf

  statusFont = LoadFont(#PB_Any, "Microsoft JhengHei UI", 14, #PB_Font_HighQuality | #PB_Font_Bold)

  If statusFont = 0
    statusFont = LoadFont(#PB_Any, "Microsoft JhengHei", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf

  If statusFont = 0
    statusFont = LoadFont(#PB_Any, "Segoe UI", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf

  If statusFont
    SetGadgetFont(#LBL_STATUS, FontID(statusFont))
  EndIf

  panelFont = LoadFont(#PB_Any, "Consolas", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  
  If panelFont = 0
    panelFont = LoadFont(#PB_Any, "Cascadia Mono", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf

  If panelFont = 0
    panelFont = LoadFont(#PB_Any, "Courier New", 14, #PB_Font_HighQuality | #PB_Font_Bold)
  EndIf
EndProcedure

; <summary>
; PrefsFilePath
; </summary>
Procedure.s PrefsFilePath()
  ProcedureReturn GetPathPart(ProgramFilename()) + #PREF_FILENAME
EndProcedure

; <summary>
; LoadPrefs
; </summary>
Procedure LoadPrefs()
  If OpenPreferences(PrefsFilePath()) = 0
    ProcedureReturn
  EndIf

  PreferenceGroup("Audio")
  soundEnabled = ReadPreferenceInteger("Enabled", 1)
  musicEnabled = ReadPreferenceInteger("MusicEnabled", 1)
  musicVolume = ReadPreferenceInteger("MusicVolume", #MUSIC_VOLUME_DEFAULT)

  PreferenceGroup("Score")
  highScore = ReadPreferenceInteger("HighScore", 0)

  PreferenceGroup("Input")
  dasDelayMs = ReadPreferenceInteger("DasDelay", #DAS_DELAY_DEFAULT)
  dasRepeatMs = ReadPreferenceInteger("DasRepeat", #DAS_REPEAT_DEFAULT)

  ClosePreferences()

  If soundEnabled <> 0
    soundEnabled = #True
  Else
    soundEnabled = #False
  EndIf

  If musicEnabled <> 0
    musicEnabled = #True
  Else
    musicEnabled = #False
  EndIf

  If highScore < 0
    highScore = 0
  EndIf

  musicVolume = ClampI(musicVolume, 0, 100)
  dasDelayMs = ClampI(dasDelayMs, 80, 400)
  dasRepeatMs = ClampI(dasRepeatMs, 16, 120)
EndProcedure

; <summary>
; ApplyPrefsToUi
; </summary>
Procedure ApplyPrefsToUi()
  SetGadgetState(#CHK_SOUND, soundEnabled)
  SyncMusicUi()
EndProcedure

; <summary>
; SavePrefs
; </summary>
Procedure SavePrefs()
  If IsGadget(#CHK_SOUND)
    soundEnabled = GetGadgetState(#CHK_SOUND)
  EndIf

  If IsGadget(#CHK_MUSIC) And musicLoaded
    musicEnabled = GetGadgetState(#CHK_MUSIC)
  EndIf

  If soundEnabled <> 0
    soundEnabled = #True
  Else
    soundEnabled = #False
  EndIf

  If musicEnabled <> 0
    musicEnabled = #True
  Else
    musicEnabled = #False
  EndIf

  musicVolume = ClampI(musicVolume, 0, 100)
  dasDelayMs = ClampI(dasDelayMs, 80, 400)
  dasRepeatMs = ClampI(dasRepeatMs, 16, 120)

  If CreatePreferences(PrefsFilePath()) = 0
    ProcedureReturn
  EndIf

  PreferenceGroup("Audio")
  WritePreferenceInteger("Enabled", soundEnabled)
  WritePreferenceInteger("MusicEnabled", musicEnabled)
  WritePreferenceInteger("MusicVolume", musicVolume)

  PreferenceGroup("Score")
  WritePreferenceInteger("HighScore", highScore)

  PreferenceGroup("Input")
  WritePreferenceInteger("DasDelay", dasDelayMs)
  WritePreferenceInteger("DasRepeat", dasRepeatMs)

  ClosePreferences()
EndProcedure
