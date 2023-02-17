 
;>--------------------------------------------------------
;Bytessence MPxConverter
;Copyright (C) 2008-2009 Trutia Alexandru
;
;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, version 3 of the License.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;Contact: www.bytessence.com
;
;>--------------------------------------------------------

;{ Requirements
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  UsePNGImageDecoder()
CompilerEndIf
;}

;{ Enumerations
Enumeration
  #SplashWindow
  #MainWindow
  #AddWindow
  #SettingsWindow
  #AboutWindow
EndEnumeration

Enumeration 0
  #SplashWindow_G0
EndEnumeration

Enumeration 50
  #MainWindow_G0
  #MainWindow_G1
  #MainWindow_G2
EndEnumeration

Enumeration 100
  #AddWindow_G0
  #AddWindow_G1
  #AddWindow_G2
  #AddWindow_G3
  #AddWindow_G4
  #AddWindow_G5
  #AddWindow_G6
  #AddWindow_G7
  #AddWindow_G8
  #AddWindow_G9
  #AddWindow_G10
  #AddWindow_G11
  #AddWindow_G12
  #AddWindow_G13
  #AddWindow_G14
  #AddWindow_G15
  #AddWindow_G16
  #AddWindow_G17
  #AddWindow_G18
  #AddWindow_G19
  #AddWindow_G20
  #AddWindow_G21
  #AddWindow_G22
  #AddWindow_G23
EndEnumeration

Enumeration 150
  #SettingsWindow_G0
  #SettingsWindow_G1
  #SettingsWindow_G2
  #SettingsWindow_G3
  #SettingsWindow_G4
  #SettingsWindow_G5
  #SettingsWindow_G6
  #SettingsWindow_G7
  #SettingsWindow_G8
  #SettingsWindow_G9
  #SettingsWindow_G10
  #SettingsWindow_G11
  #SettingsWindow_G12
  #SettingsWindow_G13
  #SettingsWindow_G14
  #SettingsWindow_G15
EndEnumeration

Enumeration 200
  #AboutWindow_G0
  #AboutWindow_G1
  #AboutWindow_G2
  #AboutWindow_G3
EndEnumeration
;}

;{ Constants
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #SLSH = "\"
CompilerElse
  #SLSH = "/"
CompilerEndIf
;}

;{ Structures
Structure Resolution
  Type.i     ;Actions = 0, Sunplus = 1
  ResW.i
  ResH.i
EndStructure

Structure FPS
  Type.i     ;Actions = 0, Sunplus = 1
  FPSValue.i
EndStructure

Structure Video
  Input.s
  OutputPath.s
  PlayerType.i
  Resolution.s
  FPS.s
  VidQual.i
  AudQual.i
  AspectRatio.i
  Date.s
  ID.i
EndStructure

Structure LanguageFile
  Name.s
  Path.s
  Author.s
EndStructure

Structure Settings
  UseLogging.i
  LogFilePath.s
  ShowSplashScreen.i
  CurrentLanguage.s
  ProfilesFile.s
  OutputExistsAction.i
  InterfaceUpdateSpeed.i
  ClearItems.i
  MainWinX.i
  MainWinY.i
  MainWinWidth.i
  MainWinHeight.i
  MainWinState.i
  ColumnWidth0.i
  ColumnWidth1.i
  ColumnWidth2.i
  ColumnWidth3.i
  ColumnWidth4.i
  ColumnWidth5.i
EndStructure
;}

;{ Global vars
Global StringVersion.s = "1.3"
Global QualActionsHi.s
Global QualActionsMed.s
Global QualActionsLow.s
Global QualSunplusHi.s
Global QualSunplusMed.s
Global QualSunplusLow.s
Global PSettings.Settings
Global SplashMutex = CreateMutex()
Global CurrentDir.s = GetPathPart(ProgramFilename())
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Global LogHeader.s = "MPxConverter Win v" + StringVersion
  Global FFMPEG.s = CurrentDir + "Codecs\ffmpeg.exe"
  Global Verbosity.s = "-v 1"
CompilerElse
  Global LogHeader.s = "MPxConverter Linux v" + StringVersion
  Global FFMPEG.s = CurrentDir + "Codecs/ffmpeg"
  Global Verbosity.s = "-v 5"
CompilerEndIf
If FileSize(FFMPEG) = -1 Or FileSize(FFMPEG) = 0 Or FileSize(FFMPEG) = -2
  MessageRequester("Error", "The 'ffmpeg' executable could not be found in the following directory: " + #CRLF$ + GetPathPart(FFMPEG) + "." + #CRLF$ + #CRLF$ + "On Linux, the file might exist, but it needs the 'executable' flag to be set." + #CRLF$ + "You can use CHMOD to change it's properties.") : End
EndIf
Macro _dbg(Text)
  If PSettings\UseLogging = 1
    Log_Write(PSettings\LogFilePath,Text)
  EndIf
EndMacro
;}

;{ Lists
Global NewList Resolutions.Resolution()
Global NewList FPS.FPS()
Global NewList Vid.Video()
Global NewList LanguageFiles.LanguageFile()
Global NewList IDGen.i()
;}

;{ Includes
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  XIncludeFile "ErrorHandler.pbi"
CompilerEndIf
XIncludeFile "AutoResize.pbi"
XIncludeFile "Localization.pbi"
XIncludeFile "Logging.pbi"
XIncludeFile "Conversion.pbi"
;}

;{ Images
Global Dim InterfaceImages.i(16)
InterfaceImages(0) = CatchImage(#PB_Any, ?IMG_LogoImage)
InterfaceImages(1) = CatchImage(#PB_Any, ?IMG_Save)
InterfaceImages(2) = CatchImage(#PB_Any, ?IMG_Load)
InterfaceImages(3) = CatchImage(#PB_Any, ?IMG_Add)
InterfaceImages(4) = CatchImage(#PB_Any, ?IMG_Delete)
InterfaceImages(5) = CatchImage(#PB_Any, ?IMG_Up)
InterfaceImages(6) = CatchImage(#PB_Any, ?IMG_Down)
InterfaceImages(7) = CatchImage(#PB_Any, ?IMG_Start)
InterfaceImages(8) = CatchImage(#PB_Any, ?IMG_Stop)
InterfaceImages(9) = CatchImage(#PB_Any, ?IMG_Settings)
InterfaceImages(10) = CatchImage(#PB_Any, ?IMG_Help)
InterfaceImages(11) = CatchImage(#PB_Any, ?IMG_About)
InterfaceImages(12) = CatchImage(#PB_Any, ?IMG_Exit)
InterfaceImages(13) = CatchImage(#PB_Any, ?IMG_Website)
InterfaceImages(14) = CatchImage(#PB_Any, ?IMG_Film)
InterfaceImages(15) = CatchImage(#PB_Any, ?IMG_General)
InterfaceImages(16) = CatchImage(#PB_Any, ?IMG_Language)
;}

;{ Fonts
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  LoadFont(0, "Arial", 8)
  LoadFont(1, "Arial", 9)
CompilerElse
  LoadFont(0, "Bitstream Vera", 8)
  LoadFont(1, "Bitstream Vera", 9)
CompilerEndIf
;}

;{ Initialize
SetCurrentDirectory(GetPathPart(ProgramFilename()))
ExamineDesktops()
PSettings\UseLogging = 1
PSettings\LogFilePath = "MPxConverter.log"
PSettings\ShowSplashScreen = 1
PSettings\CurrentLanguage = "Localization" + #SLSH + "English.ini"
PSettings\ProfilesFile = "Profiles" + #SLSH + "Default.ini"
PSettings\MainWinX = (DesktopWidth(0)-625)/2
PSettings\MainWinY = (DesktopHeight(0)-450)/2
PSettings\MainWinWidth = 625
PSettings\MainWinHeight = 450
PSettings\MainWinState = 0
PSettings\ColumnWidth0 = 150
PSettings\ColumnWidth1 = 150
PSettings\ColumnWidth2 = 100
PSettings\ColumnWidth3 = 120
PSettings\ColumnWidth4 = 80
PSettings\ColumnWidth5 = 150
;}

;{ Query languages
If ExamineDirectory(0, "Localization" + #SLSH, "*.ini")
  While NextDirectoryEntry(0)
    If DirectoryEntryType(0) = #PB_DirectoryEntry_File
      LangFile.s = "Localization" + #SLSH + DirectoryEntryName(0)
      If Trim(LangFile)<>""
        If OpenPreferences(LangFile)
          PreferenceGroup("MPxConverterLanguageInfo")
          Name.s = ReadPreferenceString("Name", "")
          Author.s = ReadPreferenceString("Author", "")
          ClosePreferences()
          If Name<>""
            AddElement(LanguageFiles())
            LanguageFiles()\Name = Name
            LanguageFiles()\Path = LangFile
            LanguageFiles()\Author = Author
          EndIf
        EndIf
      EndIf
    EndIf
  Wend
  FinishDirectory(0)
Else
  MessageRequester("Error", "Error querying the languages directory!") : End
EndIf
;}

;{ Create/read settings file
If FileSize("MPxConfig.ini") = -1
  If CreatePreferences("MPxConfig.ini")
    PreferenceGroup("MPxConfig")
    WritePreferenceString("LogActions", Str(PSettings\UseLogging))
    WritePreferenceString("LogFilePath", PSettings\LogFilePath)
    WritePreferenceString("Language", PSettings\CurrentLanguage)
    WritePreferenceString("Profiles", "Profiles" + #SLSH + "Default.ini")
    WritePreferenceString("OutputExistsAction", "0")
    WritePreferenceString("InterfaceUpdateSpeed", "0")
    WritePreferenceString("ClearItems", "0")
    WritePreferenceString("ShowSplashScreen", Str(PSettings\ShowSplashScreen))
    WritePreferenceString("OutDirectory", "")
    WritePreferenceString("PlayerType", "0")
    WritePreferenceString("Resolution", "0")
    WritePreferenceString("FPS", "0")
    WritePreferenceString("VideoQuality", "0")
    WritePreferenceString("AudioQuality", "0")
    WritePreferenceString("Aspect", "0")
    PreferenceGroup("MPxWindow")
    WritePreferenceString("WinX", Str(PSettings\MainWinX))
    WritePreferenceString("WinY", Str(PSettings\MainWinY))
    WritePreferenceString("WinW", Str(PSettings\MainWinWidth))
    WritePreferenceString("WinH", Str(PSettings\MainWinHeight))
    WritePreferenceString("WinState", Str(PSettings\MainWinState))
    PreferenceGroup("MPxColumns")
    WritePreferenceString("ColumnWidth0", Str(PSettings\ColumnWidth0))
    WritePreferenceString("ColumnWidth1", Str(PSettings\ColumnWidth1))
    WritePreferenceString("ColumnWidth2", Str(PSettings\ColumnWidth2))
    WritePreferenceString("ColumnWidth3", Str(PSettings\ColumnWidth3))
    WritePreferenceString("ColumnWidth4", Str(PSettings\ColumnWidth4))
    WritePreferenceString("ColumnWidth5", Str(PSettings\ColumnWidth5))
    ClosePreferences()
  EndIf
Else
  If OpenPreferences("MPxConfig.ini")
    PreferenceGroup("MPxConfig")
    PSettings\UseLogging = Val(ReadPreferenceString("LogActions", "1"))
    PSettings\LogFilePath = ReadPreferenceString("LogFilePath", "MPxConverter.log")
    PSettings\CurrentLanguage = ReadPreferenceString("Language", PSettings\CurrentLanguage)
    PSettings\ProfilesFile = ReadPreferenceString("Profiles", "Profiles" + #SLSH + "Default.ini")
    PSettings\OutputExistsAction = Val(ReadPreferenceString("OutputExistsAction", "0"))
    PSettings\InterfaceUpdateSpeed = Val(ReadPreferenceString("InterfaceUpdateSpeed", "0"))
    PSettings\ClearItems = Val(ReadPreferenceString("ClearItems", "0"))
    PSettings\ShowSplashScreen = Val(ReadPreferenceString("ShowSplashScreen", Str(PSettings\ShowSplashScreen)))
    PreferenceGroup("MPxWindow")
    PSettings\MainWinX = Val(ReadPreferenceString("WinX", Str(PSettings\MainWinX)))
    PSettings\MainWinY = Val(ReadPreferenceString("WinY", Str(PSettings\MainWinY)))
    PSettings\MainWinWidth = Val(ReadPreferenceString("WinW", Str(PSettings\MainWinWidth)))
    PSettings\MainWinHeight = Val(ReadPreferenceString("WinH", Str(PSettings\MainWinHeight)))
    PSettings\MainWinState = Val(ReadPreferenceString("WinState", Str(PSettings\MainWinState)))
    PreferenceGroup("MPxColumns")
    PSettings\ColumnWidth0 = Val(ReadPreferenceString("ColumnWidth0", Str(PSettings\ColumnWidth0)))
    PSettings\ColumnWidth1 = Val(ReadPreferenceString("ColumnWidth1", Str(PSettings\ColumnWidth1)))
    PSettings\ColumnWidth2 = Val(ReadPreferenceString("ColumnWidth2", Str(PSettings\ColumnWidth2)))
    PSettings\ColumnWidth3 = Val(ReadPreferenceString("ColumnWidth3", Str(PSettings\ColumnWidth3)))
    PSettings\ColumnWidth4 = Val(ReadPreferenceString("ColumnWidth4", Str(PSettings\ColumnWidth4)))
    PSettings\ColumnWidth5 = Val(ReadPreferenceString("ColumnWidth5", Str(PSettings\ColumnWidth5)))
    ClosePreferences()
  EndIf
EndIf
;}

;{ Load language
If LoadLanguageFile(PSettings\CurrentLanguage) = 0
  MessageRequester("Error", "Error loading localization file: " + PSettings\CurrentLanguage + ". Trying to load 'English.ini'.")
  PSettings\CurrentLanguage = "Localization" + #SLSH + "English.ini"
  If LoadLanguageFile(PSettings\CurrentLanguage) = 0
    MessageRequester("Error", "Could not load the language file from the settings. MPxConverter also tried to load the default file, 'English.ini', but it wasn't found. Please reinstall the program.") : End
  EndIf
  If OpenPreferences("MPxConfig.ini")
    PreferenceGroup("MPxConfig")
    WritePreferenceString("Language", PSettings\CurrentLanguage)
    ClosePreferences()
  EndIf
EndIf
;}

;{ Load the profiles
If OpenPreferences(PSettings\ProfilesFile)
  PreferenceGroup("ResMPxActions")
  If ExaminePreferenceKeys()
    While NextPreferenceKey()
      KeyName.s = PreferenceKeyName()
      KeyValue.s = PreferenceKeyValue()
      If KeyName<>"" And KeyValue<>""
        AddElement(Resolutions())
        Resolutions()\Type = 0
        Resolutions()\ResW = Val(StringField(KeyValue, 1, "|"))
        Resolutions()\ResH = Val(StringField(KeyValue, 2, "|"))
      EndIf
    Wend
  EndIf
  PreferenceGroup("ResMPxSunplus")
  If ExaminePreferenceKeys()
    While NextPreferenceKey()
      KeyName.s = PreferenceKeyName()
      KeyValue.s = PreferenceKeyValue()
      If KeyName<>"" And KeyValue<>""
        AddElement(Resolutions())
        Resolutions()\Type = 1
        Resolutions()\ResW = Val(StringField(KeyValue, 1, "|"))
        Resolutions()\ResH = Val(StringField(KeyValue, 2, "|"))
      EndIf
    Wend
  EndIf
  PreferenceGroup("FPSMPxActions")
  If ExaminePreferenceKeys()
    While NextPreferenceKey()
      KeyName.s = PreferenceKeyName()
      KeyValue.s = PreferenceKeyValue()
      If KeyName<>"" And KeyValue<>""
        AddElement(FPS())
        FPS()\Type = 0
        FPS()\FPSValue = Val(KeyValue)
      EndIf
    Wend
  EndIf
  PreferenceGroup("FPSMPxSunplus")
  If ExaminePreferenceKeys()
    While NextPreferenceKey()
      KeyName.s = PreferenceKeyName()
      KeyValue.s = PreferenceKeyValue()
      If KeyName<>"" And KeyValue<>""
        AddElement(FPS())
        FPS()\Type = 1
        FPS()\FPSValue = Val(KeyValue)
      EndIf
    Wend
  EndIf
  PreferenceGroup("VQualMPxActions")
  QualActionsHi = Trim(ReadPreferenceString("QA0", "3|3"))
  QualActionsMed = Trim(ReadPreferenceString("QA1", "3|4"))
  QualActionsLow = Trim(ReadPreferenceString("QA2", "3|5"))
  PreferenceGroup("VQualMPxSunplus")
  QualSunplusHi = Trim(ReadPreferenceString("QS0", "450"))
  QualSunplusMed = Trim(ReadPreferenceString("QS1", "300"))
  QualSunplusLow = Trim(ReadPreferenceString("QS2", "200"))
  ClosePreferences()
Else
  MessageRequester(ReturnLoc(0),ReturnLoc(1)) : End
EndIf
;}

;-----------------------------------------------------------------------------------

Procedure.i IDExists(ID)
  ForEach IDGen()
    If IDGen() = ID
      ProcedureReturn 1
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

Procedure.i MakeNewID()
  Protected NewID
  Repeat
    NewID = Random(99999999)
  Until IDExists(NewID) = 0
  AddElement(IDGen())
  IDGen() = NewID
  ProcedureReturn NEWID
EndProcedure

Procedure.i AddID(ID)
  If IDExists(ID) = 0
    AddElement(IDGen())
    IDGen() = ID
  EndIf
EndProcedure

Procedure.i RemoveID(ID)
  ForEach IDGen()
    If IDGen() = ID
      ProcedureReturn DeleteElement(IDGen())
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i Timer(Time.i)
  Repeat
    Delay(1000)
    Seconds + 1
  Until Time = Seconds Or TryLockMutex(SplashMutex) = 1
  ProcedureReturn 1
EndProcedure

Procedure.i RunBrowser(Address.s)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    RunProgram(Address, "", "")
  CompilerElse
    If RunProgram(Address, "", "") = 0
      BrowserList.s = "firefox,mozilla,camino,safari,opera,konqueror"
      For Try = 1 To CountString(BrowserList, ",")
        If RunProgram(StringField(BrowserList, Try, ","), Address, "")<>0
          Break
       EndIf
      Next
    EndIf
  CompilerEndIf
  ProcedureReturn 1
EndProcedure

Procedure.i RefreshColor()
  Count = CountGadgetItems(#MainWindow_G0)
  For Color = 0 To Count-1
    SetGadgetItemColor(#MainWindow_G0, Color, #PB_Gadget_BackColor, RGB(255, 255, 255))
  Next
  For Color = 0 To Count-1 Step 2
    SetGadgetItemColor(#MainWindow_G0, Color, #PB_Gadget_BackColor, RGB(237, 242, 248))
  Next
  ProcedureReturn 1
EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i SplashWindow()
  
  LockMutex(SplashMutex)
  TimerThread = CreateThread(@Timer(), 3)
  
  If OpenWindow(#SplashWindow, 278, 248, 266, 200, ReturnLoc(2), #PB_Window_ScreenCentered | #PB_Window_BorderLess)
    ImageGadget(#SplashWindow_G0, 0, 0, 266, 200, ImageID(InterfaceImages(0)))
  EndIf
  
  Repeat
    Event = WaitWindowEvent(5)
    If Event = #PB_Event_Gadget
      If EventType() = #PB_EventType_LeftClick
        Select EventGadget()
          Case #SplashWindow_G0
            Cancel = 1
        EndSelect
      EndIf
    Else
      Delay(1)
    EndIf
  Until WaitThread(TimerThread, 0) Or Cancel = 1
  If Cancel = 1
    If IsThread(TimerThread)
      UnlockMutex(SplashMutex)
      WaitThread(TimerThread,500)
    EndIf
  EndIf
  CloseWindow(#SplashWindow)
  ProcedureReturn 1
  
EndProcedure

Procedure.i AddVideoWindow(Files.s = "")
  
  DisableWindow(#MainWindow, 1)
  
  If Files <> ""
    If Right(Files,1) = "|"
      Files = Mid(Files,0,Len(Files)-1)
    EndIf
  EndIf

  If OpenWindow(#AddWindow, 305, 170, 485, 235, ReturnLoc(3), #PB_Window_SystemMenu | #PB_Window_WindowCentered | #PB_Window_TitleBar | #PB_Window_Invisible, WindowID(#MainWindow)) = 0
    MessageRequester(ReturnLoc(0),ReturnLoc(4)):End
  Else
    Frame3DGadget(#AddWindow_G0, 5, 3, 475, 83, "")
    TextGadget(#AddWindow_G1, 15, 23, 80, 15, ReturnLoc(5))
    StringGadget(#AddWindow_G2, 100, 20, 280, 20, "")
    ButtonGadget(#AddWindow_G3, 385, 17, 85, 25, ReturnLoc(6))
    TextGadget(#AddWindow_G4, 15, 56, 80, 15, ReturnLoc(7))
    StringGadget(#AddWindow_G5, 100, 53, 280, 20, "")
    ButtonGadget(#AddWindow_G6, 385, 50, 85, 25, ReturnLoc(6))
    Frame3DGadget(#AddWindow_G7, 5, 89, 475, 106, "")
    TextGadget(#AddWindow_G8, 15, 111, 80, 15, ReturnLoc(8))
    ComboBoxGadget(#AddWindow_G9, 100, 106, 140, 25)
    TextGadget(#AddWindow_G10, 250, 111, 80, 15, ReturnLoc(9))
    ComboBoxGadget(#AddWindow_G11, 330, 106, 140, 25)
    TextGadget(#AddWindow_G12, 15, 141, 80, 15, ReturnLoc(10))
    ComboBoxGadget(#AddWindow_G13, 100, 136, 140, 25)
    TextGadget(#AddWindow_G14, 250, 171, 80, 15, ReturnLoc(11))
    ComboBoxGadget(#AddWindow_G15, 330, 166, 140, 25)
    TextGadget(#AddWindow_G16, 15, 171, 80, 15, ReturnLoc(12))
    ComboBoxGadget(#AddWindow_G17, 100, 166, 140, 25)
    TextGadget(#AddWindow_G18, 250, 141, 80, 15, ReturnLoc(13))
    ComboBoxGadget(#AddWindow_G19, 330, 136, 140, 25)
    ButtonGadget(#AddWindow_G22, 255, 205, 110, 25, ReturnLoc(14))
    ButtonGadget(#AddWindow_G23, 370, 205, 110, 25, ReturnLoc(15))
  EndIf
  
  ;{ Add the options to the controls
  If OpenPreferences(CurrentDir + "MPxConfig.ini")
    PreferenceGroup("MPxConfig")
    SetGadgetText(#AddWindow_G5, ReadPreferenceString("OutDirectory", ""))
    OPlayerType = Val(ReadPreferenceString("PlayerType", "0"))
    OResolution = Val(ReadPreferenceString("Resolution", "0"))
    OFPS = Val(ReadPreferenceString("FPS", "0"))
    OVideoQuality = Val(ReadPreferenceString("VideoQuality", "0"))
    OAudioQuality = Val(ReadPreferenceString("AudioQuality", "0"))
    OAspect = Val(ReadPreferenceString("Aspect", "0"))
    ClosePreferences()
  EndIf
  AddGadgetItem(#AddWindow_G9, 0, "Actions (AMV)")
  AddGadgetItem(#AddWindow_G9, 1, "Sunplus (AVI)")
  SetGadgetState(#AddWindow_G9, OPlayerType)
  NewPlayerState = OPlayerType
  ForEach Resolutions()
    If Resolutions()\Type = OPlayerType
      AddGadgetItem(#AddWindow_G11, -1, Str(Resolutions()\ResW) + "x" + Str(Resolutions()\ResH))
    EndIf
  Next
  SetGadgetState(#AddWindow_G11, OResolution)
  ForEach FPS()
    If FPS()\Type = OPlayerType
      AddGadgetItem(#AddWindow_G13, -1, Str(FPS()\FPSValue))
    EndIf
  Next
  SetGadgetState(#AddWindow_G13, OFPS)
  AddGadgetItem(#AddWindow_G15, 0, ReturnLoc(16))
  AddGadgetItem(#AddWindow_G15, 1, ReturnLoc(17))
  AddGadgetItem(#AddWindow_G15, 2, ReturnLoc(18))
  SetGadgetState(#AddWindow_G15, OVideoQuality)
  AddGadgetItem(#AddWindow_G17, 0, ReturnLoc(16))
  AddGadgetItem(#AddWindow_G17, 1, ReturnLoc(17))
  AddGadgetItem(#AddWindow_G17, 2, ReturnLoc(18))
  SetGadgetState(#AddWindow_G17, OAudioQuality)
  AddGadgetItem(#AddWindow_G19, 0, ReturnLoc(19))
  AddGadgetItem(#AddWindow_G19, 1, "4:3")
  AddGadgetItem(#AddWindow_G19, 2, "16:9")
  SetGadgetState(#AddWindow_G19, OAspect)
  If OPlayerType = 0
    SetGadgetState(#AddWindow_G17, 0)
    DisableGadget(#AddWindow_G17, 1)
  EndIf
  If Files<>""
    SetGadgetText(#AddWindow_G2, Files)
  EndIf
  ;}

  ;{ Show the window
  HideWindow(#AddWindow,0)
  ;}

  Repeat
    Event = WaitWindowEvent()
    If Event = #PB_Event_Gadget
      Select EventGadget()

        Case #AddWindow_G3 ;{ Browse for input
          CompilerIf #PB_Compiler_OS = #PB_OS_Windows
            Pattern.s = ReturnLoc(20) + " |*.avi;*.mpg;*.mpeg;*.flv;*.mkv;*.wmv;*.mov;*.asf;*.mp4|" + ReturnLoc(21) + " (*.*)|*.*"
          CompilerElse
            Pattern.s = ReturnLoc(21) + " (*.*)|*.*"
          CompilerEndIf
          File.s = OpenFileRequester(ReturnLoc(22), "", Pattern, 0, #PB_Requester_MultiSelection)
          If File <> ""
            SelectedFiles.s = ""
            SetGadgetText(#AddWindow_G2, "")
          EndIf
          While File
            If File <> ""
              SelectedFiles.s + File + "|"
            EndIf
            File = NextSelectedFileName()
          Wend
          If Right(SelectedFiles, 1) = "|"
            SelectedFiles = Mid(SelectedFiles, 0, Len(SelectedFiles)-1)
          EndIf
          If SelectedFiles<>""
            SetGadgetText(#AddWindow_G2, SelectedFiles)
          EndIf
           ;}

        Case #AddWindow_G6 ;{ Browse for output
          OutPutPath.s = PathRequester(ReturnLoc(23), GetGadgetText(#AddWindow_G5))
          If OutPutPath<>"" And OutPutPath<>"\"
            SetGadgetText(#AddWindow_G5, OutPutPath)
          EndIf
          ;}

        Case #AddWindow_G9 ;{ Select player type
          If NewPlayerState <> GetGadgetState(#AddWindow_G9)
            ClearGadgetItems(#AddWindow_G11)
            ClearGadgetItems(#AddWindow_G13)
            Select GetGadgetState(#AddWindow_G9)
            
              Case 0 ;{ Actions
                ForEach Resolutions()
                  If Resolutions()\Type = 0
                    AddGadgetItem(#AddWindow_G11, -1, Str(Resolutions()\ResW) + "x" + Str(Resolutions()\ResH))
                  EndIf
                Next
                ForEach FPS()
                  If FPS()\Type = 0
                    AddGadgetItem(#AddWindow_G13, -1, Str(FPS()\FPSValue))
                  EndIf
                Next
                SetGadgetState(#AddWindow_G17, 0)
                DisableGadget(#AddWindow_G17, 1)
                ;}
              
              Case 1 ;{ Sunplus
                ForEach Resolutions()
                  If Resolutions()\Type = 1
                    AddGadgetItem(#AddWindow_G11, -1, Str(Resolutions()\ResW) + "x" + Str(Resolutions()\ResH))
                  EndIf
                Next
                ForEach FPS()
                  If FPS()\Type = 1
                    AddGadgetItem(#AddWindow_G13, -1, Str(FPS()\FPSValue))
                  EndIf
                Next
                SetGadgetState(#AddWindow_G17, 0)
                DisableGadget(#AddWindow_G17, 0)
                ;}
              
            EndSelect
            SetGadgetState(#AddWindow_G11, 0)
            SetGadgetState(#AddWindow_G13, 0)
            NewPlayerState = #AddWindow_G9
          EndIf
          ;}

        Case #AddWindow_G22 ;{ Quit
          Event = #PB_Event_CloseWindow
          ;}

        Case #AddWindow_G23 ;{ Add
          Input.s = GetGadgetText(#AddWindow_G2)
          OutputPath.s = GetGadgetText(#AddWindow_G5)
          TotalFiles = CountString(Input, "|") + 1
          If FileSize(OutputPath) <> -2
            CreateDirectory(OutputPath)
          EndIf
          For SplitInput = 1 To TotalFiles
            FileInput.s = StringField(Input, SplitInput, "|")
            If FileInput <> ""
              If FileSize(FileInput) > 0
                If FileSize(OutputPath) = -2
                  AddElement(Vid())
                  Vid()\Input = FileInput
                  Vid()\OutputPath = OutputPath
                  Vid()\PlayerType = GetGadgetState(#AddWindow_G9)
                  Vid()\Resolution = GetGadgetItemText(#AddWindow_G11, GetGadgetState(#AddWindow_G11))
                  Vid()\FPS = GetGadgetItemText(#AddWindow_G13, GetGadgetState(#AddWindow_G13))
                  Vid()\VidQual = GetGadgetState(#AddWindow_G15)
                  Vid()\AudQual = GetGadgetState(#AddWindow_G17)
                  Vid()\AspectRatio = GetGadgetState(#AddWindow_G19)
                  Vid()\Date = FormatDate("%mm/%dd/%yy at %hh:%ii:%ss", Date())
                  Vid()\ID = MakeNewID()
                  Select Vid()\PlayerType
                    Case 0
                      PT.s = "Actions"
                    Case 1
                      PT.s = "Sunplus"
                  EndSelect
                  Select Vid()\VidQual
                    Case 0
                      QUAL.s = ReturnLoc(24)
                    Case 1
                      QUAL.s = ReturnLoc(25)
                    Case 2
                      QUAL.s = ReturnLoc(26)
                  EndSelect
                  RES.s = Vid()\Resolution
                  FPS.s = Vid()\FPS
                  ASP.s = GetGadgetItemText(#AddWindow_G19, Vid()\AspectRatio)
                  Item = CountGadgetItems(#MainWindow_G0)
                  AddGadgetItem(#MainWindow_G0, Item, Vid()\Input + Chr(10) + Vid()\OutputPath + Chr(10) + PT + Chr(10) + Vid()\Date + Chr(10) + ReturnLoc(68) + Chr(10) + ReturnLoc(134),ImageID(InterfaceImages(14)))
                  SetGadgetItemData(#MainWindow_G0,Item,Vid()\ID)
                  RefreshColor()
                  If OpenPreferences(CurrentDir + "MPxConfig.ini")
                    PreferenceGroup("MPxConfig")
                    WritePreferenceString("OutDirectory", GetGadgetText(#AddWindow_G5))
                    WritePreferenceString("PlayerType", Str(GetGadgetState(#AddWindow_G9)))
                    WritePreferenceString("Resolution", Str(GetGadgetState(#AddWindow_G11)))
                    WritePreferenceString("FPS", Str(GetGadgetState(#AddWindow_G13)))
                    WritePreferenceString("VideoQuality", Str(GetGadgetState(#AddWindow_G15)))
                    WritePreferenceString("AudioQuality", Str(GetGadgetState(#AddWindow_G17)))
                    WritePreferenceString("Aspect", Str(GetGadgetState(#AddWindow_G19)))
                    ClosePreferences()
                  EndIf
                  SetGadgetText(#AddWindow_G2, "") 
                Else
                  MessageRequester(ReturnLoc(0),ReplaceString(ReturnLoc(27),"",FileInput,#PB_String_NoCase))
                  SetGadgetText(#AddWindow_G5, "")
                  Break
                EndIf
              Else
                MessageRequester(ReturnLoc(0),ReturnLoc(28))
                SetGadgetText(#AddWindow_G2, "")
                Break
              EndIf
            EndIf
          Next
          ;}

      EndSelect
    EndIf
  Until Event = #PB_Event_CloseWindow
  
  CloseWindow(#AddWindow)
  DisableWindow(#MainWindow, 0)
  SetActiveWindow(#MainWindow)
  ProcedureReturn 1
  
EndProcedure

Procedure.i SettingsWindow()
  
  DisableWindow(#MainWindow, 1)
  
  If OpenWindow(#SettingsWindow, 325, 205, 450, 294, ReturnLoc(29), #PB_Window_SystemMenu | #PB_Window_WindowCentered | #PB_Window_TitleBar | #PB_Window_Invisible, WindowID(#MainWindow)) = 0
    MessageRequester(ReturnLoc(0),ReturnLoc(4)):End
  Else
    ButtonGadget(#SettingsWindow_G0, 230, 265, 105, 25, ReturnLoc(14))
    ButtonGadget(#SettingsWindow_G1, 340, 265, 105, 25, ReturnLoc(30))
    PanelGadget(#SettingsWindow_G2, 5, 5, 440, 255)
    AddGadgetItem(#SettingsWindow_G2, -1, ReturnLoc(31),ImageID(InterfaceImages(15)))
    CheckBoxGadget(#SettingsWindow_G3, 8, 13, 420, 15, ReturnLoc(32))
    CheckBoxGadget(#SettingsWindow_G4, 8, 38, 420, 15, ReturnLoc(33))
    StringGadget(#SettingsWindow_G5, 8, 60, 385, 20, "")
    ButtonGadget(#SettingsWindow_G6, 403, 58, 25, 25, "...")
    TextGadget(#SettingsWindow_G7, 8, 88, 420, 15, ReturnLoc(34))
    StringGadget(#SettingsWindow_G8, 8, 110, 385, 20, "")
    ButtonGadget(#SettingsWindow_G9, 403, 108, 25, 25, "...")
    TextGadget(#SettingsWindow_G10, 8, 148, 210, 15, ReturnLoc(35))
    ComboBoxGadget(#SettingsWindow_G11, 223, 141, 205, 24)
    AddGadgetItem(#SettingsWindow_G11,0,ReturnLoc(36))
    AddGadgetItem(#SettingsWindow_G11,1,ReturnLoc(37))
    AddGadgetItem(#SettingsWindow_G11,2,ReturnLoc(38))
    TextGadget(#SettingsWindow_G12, 8, 178, 210, 15, ReturnLoc(39))
    ComboBoxGadget(#SettingsWindow_G13, 223, 171, 205, 24)
    AddGadgetItem(#SettingsWindow_G13,0,ReturnLoc(40))
    AddGadgetItem(#SettingsWindow_G13,1,ReturnLoc(41))
    AddGadgetItem(#SettingsWindow_G13,2,ReturnLoc(42))
    CheckBoxGadget(#SettingsWindow_G14, 8, 208, 420, 15, ReturnLoc(43))
    AddGadgetItem(#SettingsWindow_G2, -1, ReturnLoc(44),ImageID(InterfaceImages(16)))
    ListIconGadget(#SettingsWindow_G15, 8, 8, 420, 215, ReturnLoc(45), 245, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
    AddGadgetColumn(#SettingsWindow_G15, 1, ReturnLoc(46), 150)
    CloseGadgetList()
  EndIf

  ;{ Add all the languages there
  ForEach LanguageFiles()
    AddGadgetItem(#SettingsWindow_G15, -1, LanguageFiles()\Name + Chr(10) + LanguageFiles()\Author)
  Next
  ;}

  ;{ Select the current language in the list
  ForEach LanguageFiles()
    If LanguageFiles()\Path = PSettings\CurrentLanguage
      CurrentLanguageName.s = LanguageFiles()\Name
    EndIf
  Next
  For Sel = 0 To CountGadgetItems(#SettingsWindow_G15)-1
    If LCase(CurrentLanguageName) = LCase(GetGadgetItemText(#SettingsWindow_G15, Sel))
      SetGadgetState(#SettingsWindow_G15, Sel)
      Break
    EndIf
  Next
  ;}

  ;{ Add the rest of the settings
  If PSettings\UseLogging = 0
    SetGadgetState(#SettingsWindow_G4, 0)
    DisableGadget(#SettingsWindow_G5, 1)
    DisableGadget(#SettingsWindow_G6, 1)
  Else
    SetGadgetState(#SettingsWindow_G4, 1)
    DisableGadget(#SettingsWindow_G5, 0)
    DisableGadget(#SettingsWindow_G6, 0)
  EndIf
  SetGadgetState(#SettingsWindow_G3, PSettings\ShowSplashScreen)
  SetGadgetText(#SettingsWindow_G5, PSettings\LogFilePath)
  SetGadgetText(#SettingsWindow_G8, PSettings\ProfilesFile)
  SetGadgetState(#SettingsWindow_G11,PSettings\OutputExistsAction)
  SetGadgetState(#SettingsWindow_G13,PSettings\InterfaceUpdateSpeed)
  SetGadgetState(#SettingsWindow_G14,PSettings\ClearItems)
  ;}

  ;{ Show the window
  HideWindow(#SettingsWindow, 0)
  ;}
 
  Repeat
    Event = WaitWindowEvent()
    If Event = #PB_Event_Gadget
      Select EventGadget()

        Case #SettingsWindow_G0 ;{ Close
          Event = #PB_Event_CloseWindow
          ;}

        Case #SettingsWindow_G1 ;{ Save
          LanguageState = GetGadgetState(#SettingsWindow_G15)
          If LanguageState <> -1
            LanguageName.s = GetGadgetItemText(#SettingsWindow_G15, LanguageState)
            ForEach LanguageFiles()
              If LCase(LanguageFiles()\Name) = LCase(LanguageName)
                PSettings\CurrentLanguage = LanguageFiles()\Path
                Break
              EndIf
            Next
          Else
            MessageRequester(ReturnLoc(0), ReturnLoc(47))
          EndIf
          PSettings\UseLogging = GetGadgetState(#SettingsWindow_G4)
          PSettings\LogFilePath = GetGadgetText(#SettingsWindow_G5)
          PSettings\ShowSplashScreen = GetGadgetState(#SettingsWindow_G3)
          PSettings\ProfilesFile = GetGadgetText(#SettingsWindow_G8)
          PSettings\OutputExistsAction = GetGadgetState(#SettingsWindow_G11)
          PSettings\InterfaceUpdateSpeed = GetGadgetState(#SettingsWindow_G13)
          PSettings\ClearItems = GetGadgetState(#SettingsWindow_G14)
          If OpenPreferences(CurrentDir + "MPxConfig.ini")
            PreferenceGroup("MPxConfig")
            WritePreferenceString("LogActions", Str(PSettings\UseLogging))
            WritePreferenceString("LogFilePath", PSettings\LogFilePath)
            WritePreferenceString("Language", PSettings\CurrentLanguage)
            WritePreferenceString("ShowSplashScreen", Str(PSettings\ShowSplashScreen))
            WritePreferenceString("Profiles", PSettings\ProfilesFile)
            WritePreferenceString("OutputExistsAction", Str(PSettings\OutputExistsAction))
            WritePreferenceString("InterfaceUpdateSpeed", Str(PSettings\InterfaceUpdateSpeed))
            WritePreferenceString("ClearItems", Str(PSettings\ClearItems))
            ClosePreferences()
            MessageRequester(ReturnLoc(30), ReturnLoc(48))
            Event = #PB_Event_CloseWindow
          Else
            MessageRequester(ReturnLoc(0), ReturnLoc(49))
          EndIf
          ;}

        Case #SettingsWindow_G4 ;{ Log
          If GetGadgetState(#SettingsWindow_G4) = 0
            DisableGadget(#SettingsWindow_G5, 1)
            DisableGadget(#SettingsWindow_G6, 1)
          Else
            DisableGadget(#SettingsWindow_G5, 0)
            DisableGadget(#SettingsWindow_G6, 0)
          EndIf
          ;}

        Case #SettingsWindow_G6 ;{ Save log
          LogFile.s = SaveFileRequester(ReturnLoc(50), PSettings\LogFilePath, ReturnLoc(51) + " (*.log)|*.log|" + ReturnLoc(21) + " (*.*)|*.*", 0)
          If LogFile <> ""
            If LCase(Right(LogFile, 4)) <> ".log"
              LogFile + ".log"
            EndIf
            PSettings\LogFilePath = RemoveString(LogFile, GetPathPart(ProgramFilename()))
            SetGadgetText(#SettingsWindow_G5, PSettings\LogFilePath)
          EndIf
          ;}

        Case #SettingsWindow_G9 ;{ Open profiles
          Profiles.s = OpenFileRequester(ReturnLoc(52), "Profiles\", ReturnLoc(53) + " (*.*)|*.*", 0)
          If Profiles <> ""
            If FileSize(Profiles) > 0
              Profiles = RemoveString(Profiles, GetPathPart(ProgramFilename()))
              SetGadgetText(#SettingsWindow_G8, Profiles)
              PSettings\ProfilesFile = Profiles
            Else
              MessageRequester(ReturnLoc(0), ReturnLoc(54))
            EndIf
          EndIf
          ;}

      EndSelect
    EndIf
  Until Event = #PB_Event_CloseWindow

  CloseWindow(#SettingsWindow)
  DisableWindow(#MainWindow, 0)
  SetActiveWindow(#MainWindow)
  ProcedureReturn 1

EndProcedure

Procedure.i AboutWindow()

  ;{ Init data
  AboutLogo = CatchImage(#PB_Any, ?IMG_AboutLogo)

  #ProgName = "Bytessence MPxConverter"
  #Author = "Copyright (c) 2008-2009 Alexandru Trutia"
  
  Credits.s + "Version"+" " + StringVersion + " (Compiled: " + FormatDate("%dd/%mm/%yy", #PB_Compiler_Date) + " " + FormatDate("%hh:%ii:%ss", #PB_Compiler_Date) + ")" + #CRLF$ + #CRLF$
  Credits.s + "Icons provided by: FamFamFam <www.famfamfam.com/lab/icons/silk>" + #CRLF$
  Credits.s + "Based on AMV-Codec-Tools (FFMpeg)" + #CRLF$
  
  License.s + "This program is free software: you can redistribute it and/or modify" + #CRLF$
  License.s + "it under the terms of the GNU General Public License as published by" + #CRLF$
  License.s + "the Free Software Foundation, version 3 of the License." + #CRLF$ + #CRLF$
  License.s + "This program is distributed in the hope that it will be useful," + #CRLF$
  License.s + "but WITHOUT ANY WARRANTY; without even the implied warranty of" + #CRLF$
  License.s + "MERCHANTABILITY or FITNESS for A PARTICULAR PURPOSE.  See the" + #CRLF$
  License.s + "GNU General Public License for more details." + #CRLF$ + #CRLF$
  License.s + "You should have received a copy of the GNU General Public License" + #CRLF$
  License.s + "along with this program.  If not, see <http://www.gnu.org/licenses/>." + #CRLF$
  
  Links.s + "Links:" + #CRLF$
  Links.s + "http://www.bytessence.com" + #CRLF$
  Links.s + "http://www.mympxplayer.org" + #CRLF$
  Links.s + "http://code.google.com/p/amv-codec-tools/" + #CRLF$
  Links.s + "http://www.famfamfam.com/lab/icons/silk" + #CRLF$
  ;}

  DisableWindow(#MainWindow, 1)
  
  If OpenWindow(#AboutWindow, 292, 262, 467, 238, "About "+#ProgName, #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_WindowCentered | #PB_Window_Invisible, WindowID(#MainWindow)) = 0
    MessageRequester("Error","Error opening window!"):End
  Else
    ImageGadget(#AboutWindow_G0, 0, 0, 470, 35, ImageID(AboutLogo))
    EditorGadget(#AboutWindow_G1, 5, 45, 457, 154,#PB_Editor_ReadOnly)
    SetGadgetText(#AboutWindow_G1,#ProgName + #CRLF$ + #Author + #CRLF$ + Credits + #CRLF$ + License + #CRLF$ + Links)
    ButtonGadget(#AboutWindow_G2, 222, 207, 118, 26, ReturnLoc(55))
    ButtonGadget(#AboutWindow_G3, 344, 207, 118, 26, ReturnLoc(14))
  EndIf
  
  ;{ Show window
  HideWindow(#AboutWindow,0)
  ;}
  
  Repeat
    
    Event = WaitWindowEvent()
    Select Event
        
      Case #PB_Event_Gadget
        Select EventGadget()
        
          Case #AboutWindow_G3 ;{ Close window
            Event = #PB_Event_CloseWindow
            ;}
            
          Case #AboutWindow_G2 ;{ Run browser
            RunBrowser("http://www.bytessence.com")
            ;}
            
        EndSelect
        
    EndSelect
    
  Until Event = #PB_Event_CloseWindow
  If IsImage(AboutLogo)
    FreeImage(AboutLogo)
  EndIf
  CloseWindow(#AboutWindow)
  DisableWindow(#MainWindow,0)
  SetActiveWindow(#MainWindow)
  ProcedureReturn 1
  
EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i OpenConversionList(File.s)

  If OpenPreferences(File)
    PreferenceGroup("FileID")
    If ReadPreferenceString("FileID","") <> "Bytessence MPxConverter"
      MessageRequester(ReturnLoc(0),ReturnLoc(56))
      ClosePreferences()
      ProcedureReturn 0
    EndIf
    If ListSize(Vid()) > 0
      If MessageRequester(ReturnLoc(57), ReturnLoc(58), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
        ClearGadgetItems(#MainWindow_G0)
        ClearList(Vid())
        ClearList(IDGen())
      EndIf
    EndIf
    If ExaminePreferenceGroups()
      While NextPreferenceGroup()
        Name.s = Trim(LCase(PreferenceGroupName()))
        If Name <> "fileid" And Left(Name,4) = "item"
          AddElement(Vid())
          Vid()\Input = ReadPreferenceString("Input","")
          Vid()\OutputPath = ReadPreferenceString("OutputPath","")
          Vid()\PlayerType = Val(ReadPreferenceString("PlayerType",""))
          Vid()\Resolution = ReadPreferenceString("Resolution","")
          Vid()\FPS = ReadPreferenceString("FPS","")
          Vid()\VidQual = Val(ReadPreferenceString("VidQual",""))
          Vid()\AudQual = Val(ReadPreferenceString("AudQual",""))
          Vid()\AspectRatio = Val(ReadPreferenceString("AspectRatio",""))
          Vid()\Date = ReadPreferenceString("Date","")
          Vid()\ID = MakeNewID()
          Select Vid()\PlayerType
            Case 0
              PT.s = "Actions"
            Case 1
              PT.s = "Sunplus"
          EndSelect
          Item = CountGadgetItems(#MainWindow_G0)
          AddGadgetItem(#MainWindow_G0, Item, Vid()\Input + Chr(10) + Vid()\OutputPath + Chr(10) + PT + Chr(10) + Vid()\Date + Chr(10) + ReturnLoc(68) + Chr(10) + ReturnLoc(134),ImageID(InterfaceImages(14)))
          SetGadgetItemData(#MainWindow_G0,Item,Vid()\ID)
        EndIf
      Wend
    EndIf
    ClosePreferences()
    MessageRequester(ReturnLoc(59),ReturnLoc(60))
    ProcedureReturn 1
  Else
    MessageRequester(ReturnLoc(0),ReturnLoc(61))
    ProcedureReturn 0
  EndIf

EndProcedure

Procedure.i SaveConversionList(File.s)
  
  If ListSize(Vid()) = 0
    MessageRequester(ReturnLoc(59),ReturnLoc(62))
    ProcedureReturn 0
  EndIf
  If FileSize(File) >= 0
    If MessageRequester(ReturnLoc(112),ReturnLoc(63),#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
      ProcedureReturn 0
    EndIf
  EndIf
  
  If CreatePreferences(File)
    PreferenceGroup("FileID")
    WritePreferenceString("FileID","Bytessence MPxConverter")
    PreferenceComment("---------------")
    ForEach Vid()
      PreferenceGroup("Item"+Str(Item))
      WritePreferenceString("Input", Vid()\Input)
      WritePreferenceString("OutputPath", Vid()\OutputPath)
      WritePreferenceString("PlayerType", Str(Vid()\PlayerType))
      WritePreferenceString("Resolution", Vid()\Resolution)
      WritePreferenceString("FPS", Vid()\FPS)
      WritePreferenceString("VidQual", Str(Vid()\VidQual))
      WritePreferenceString("AudQual", Str(Vid()\AudQual))
      WritePreferenceString("AspectRatio", Str(Vid()\AspectRatio))
      WritePreferenceString("Date", Vid()\Date)
      PreferenceComment("---------------")
      Item + 1
    Next
    ClosePreferences()
    MessageRequester(ReturnLoc(59),ReturnLoc(64))
  Else
    MessageRequester(ReturnLoc(0),ReturnLoc(65))
  EndIf

EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i MoveVideoUp()
  
  If CountGadgetItems(#MainWindow_G0) >= 2
    SelectedState = GetGadgetState(#MainWindow_G0)
    If SelectedState <> -1 And SelectedState >= 1
      NewState = SelectedState-1
      Video.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 0)
      OutPath.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 1)
      PlayerType.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 2)
      Date.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 3)
      Progress.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 4)
      ETA.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 5)
      ItemData = GetGadgetItemData(#MainWindow_G0, SelectedState)
      ResetList(Vid())
      SelectElement(Vid(), SelectedState)
      *First = @Vid()
      SelectElement(Vid(), SelectedState-1)
      *Second = @Vid()
      SwapElements(Vid(), *First, *Second)
      RemoveGadgetItem(#MainWindow_G0, SelectedState)
      AddGadgetItem(#MainWindow_G0, NewState, Video + Chr(10) + OutPath + Chr(10) + PlayerType + Chr(10) + Date + Chr(10) + Progress + Chr(10) + ETA,ImageID(InterfaceImages(14)))
      SetGadgetState(#MainWindow_G0, NewState)
      SetGadgetItemData(#MainWindow_G0, NewState, ItemData)
    EndIf
  EndIf
  
  ProcedureReturn 1
  
EndProcedure

Procedure.i MoveVideoDown()
  
  If CountGadgetItems(#MainWindow_G0) >= 2
    SelectedState = GetGadgetState(#MainWindow_G0)
    If SelectedState <> -1 And SelectedState + 1 < CountGadgetItems(#MainWindow_G0)
      NewState = SelectedState + 1
      Video.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 0)
      OutPath.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 1)
      PlayerType.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 2)
      Date.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 3)
      Progress.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 4)
      ETA.s = GetGadgetItemText(#MainWindow_G0, SelectedState, 5)
      ItemData = GetGadgetItemData(#MainWindow_G0, SelectedState)
      ResetList(Vid())
      SelectElement(Vid(), SelectedState)
      *First = @Vid()
      SelectElement(Vid(), SelectedState + 1)
      *Second = @Vid()
      SwapElements(Vid(), *First, *Second)
      RemoveGadgetItem(#MainWindow_G0, SelectedState)
      AddGadgetItem(#MainWindow_G0, NewState, Video + Chr(10) + OutPath + Chr(10) + PlayerType + Chr(10) + Date + Chr(10) + Progress + Chr(10) + ETA,ImageID(InterfaceImages(14)))
      SetGadgetState(#MainWindow_G0, NewState)
      SetGadgetItemData(#MainWindow_G0, NewState, ItemData)
    EndIf
  EndIf
  
  ProcedureReturn 1
  
EndProcedure

;-----------------------------------------------------------------------------------

;{ Create log and write settings
If PSettings\UseLogging = 1
  Log_AddHeader(PSettings\LogFilePath, LogHeader)
  _dbg("----Settings----")
  _dbg("PSettings\UseLogging: "+Str(PSettings\UseLogging))
  _dbg("PSettings\LogFilePath: "+PSettings\LogFilePath)
  _dbg("PSettings\CurrentLanguage: "+PSettings\CurrentLanguage)
  _dbg("PSettings\ProfilesFile: "+PSettings\ProfilesFile)
  _dbg("PSettings\OutputExistsAction: "+Str(PSettings\OutputExistsAction))
  _dbg("PSettings\InterfaceUpdateSpeed: "+Str(PSettings\InterfaceUpdateSpeed))
  _dbg("PSettings\ClearItems: "+Str(PSettings\ClearItems))
  _dbg("PSettings\ShowSplashScreen: "+Str(PSettings\ShowSplashScreen))
  _dbg("----------------")
EndIf
;}

If OpenWindow(#MainWindow, PSettings\MainWinX, PSettings\MainWinY, 625, 450, "Bytessence MPxConverter", #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_TitleBar | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_Invisible) = 0
  MessageRequester(ReturnLoc(0),ReturnLoc(4)):End
Else

  ;{ Log
  _dbg("Opened window")
  ;}

  ;{ Font
  SetGadgetFont(#PB_Default, FontID(0))
  ;}

  ;{ Statusbar
  If CreateStatusBar(0,WindowID(#MainWindow)) = 0
    MessageRequester(ReturnLoc(0),ReturnLoc(66))
  Else
    AddStatusBarField(300)
    AddStatusBarField(1024)
    StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$","0",#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
    StatusBarText(0, 1, ReturnLoc(68))
    _dbg("Created statusbar")
  EndIf
  ;}

  ;{ Menu
  If CreateImageMenu(0,WindowID(#MainWindow)) = 0
    MessageRequester(ReturnLoc(0),ReturnLoc(69)):End
  Else
    MenuTitle(ReturnLoc(70))
    MenuItem(0, ReturnLoc(71)+Chr(9)+"Ctrl+O",ImageID(InterfaceImages(2)))
    MenuItem(1, ReturnLoc(72)+Chr(9)+"Ctrl+S",ImageID(InterfaceImages(1)))
    MenuBar()
    MenuItem(2, ReturnLoc(73)+Chr(9)+"Alt+F4",ImageID(InterfaceImages(12)))
    MenuTitle(ReturnLoc(74))
    MenuItem(3, ReturnLoc(75)+Chr(9)+"Ctrl+A",ImageID(InterfaceImages(3)))
    MenuItem(4, ReturnLoc(76)+Chr(9)+"Ctrl+R",ImageID(InterfaceImages(4)))
    MenuBar()
    MenuItem(5, ReturnLoc(77))
    MenuBar()
    MenuItem(6, ReturnLoc(78),ImageID(InterfaceImages(5)))
    MenuItem(7, ReturnLoc(79),ImageID(InterfaceImages(6)))
    MenuTitle(ReturnLoc(80))
    MenuItem(8, ReturnLoc(81),ImageID(InterfaceImages(7)))
    MenuItem(9, ReturnLoc(82),ImageID(InterfaceImages(8)))
    MenuTitle(ReturnLoc(83))
    MenuItem(10, ReturnLoc(84),ImageID(InterfaceImages(9)))
    MenuTitle(ReturnLoc(85))
    MenuItem(11, ReturnLoc(86)+Chr(9)+"F1",ImageID(InterfaceImages(10)))
    MenuBar()
    MenuItem(12, ReturnLoc(87),ImageID(InterfaceImages(13)))
    MenuItem(13, ReturnLoc(88),ImageID(InterfaceImages(11)))
    DisableMenuItem(0,9,1)
    _dbg("Created main menu")
  EndIf
  If CreatePopupImageMenu(1) = 0
    MessageRequester(ReturnLoc(0),ReturnLoc(69)):End
  Else
    MenuItem(100, ReturnLoc(93),ImageID(InterfaceImages(4)))
    MenuItem(101, ReturnLoc(78),ImageID(InterfaceImages(5)))
    MenuItem(102, ReturnLoc(79),ImageID(InterfaceImages(6)))
    _dbg("Created right click menu")
  EndIf
  ;}

  ;{ Toolbar
  If CreateToolBar(0, WindowID(#MainWindow)) = 0
    MessageRequester(ReturnLoc(0),ReturnLoc(89))
  Else
    ToolBarSeparator()
    ToolBarImageButton(50,ImageID(InterfaceImages(2)))
    ToolBarImageButton(51,ImageID(InterfaceImages(1)))
    ToolBarSeparator()
    ToolBarImageButton(52,ImageID(InterfaceImages(3)))
    ToolBarImageButton(53,ImageID(InterfaceImages(4)))
    ToolBarSeparator()
    ToolBarImageButton(54,ImageID(InterfaceImages(5)))
    ToolBarImageButton(55,ImageID(InterfaceImages(6)))
    ToolBarSeparator()
    ToolBarImageButton(56,ImageID(InterfaceImages(7)))
    ToolBarImageButton(57,ImageID(InterfaceImages(8)))
    ToolBarSeparator()
    ToolBarImageButton(58,ImageID(InterfaceImages(9)))
    ToolBarSeparator()
    ToolBarImageButton(59,ImageID(InterfaceImages(10)))
    ToolBarImageButton(60,ImageID(InterfaceImages(11)))
    ToolBarImageButton(61,ImageID(InterfaceImages(12)))
    DisableToolBarButton(0,57,1)
    _dbg("Created toolbar")
  EndIf
  ;}

  ;{ Tooltips
  ToolBarToolTip(0,50,ReturnLoc(90))
  ToolBarToolTip(0,51,ReturnLoc(91))
  ToolBarToolTip(0,52,ReturnLoc(92))
  ToolBarToolTip(0,53,ReturnLoc(93))
  ToolBarToolTip(0,54,ReturnLoc(94))
  ToolBarToolTip(0,55,ReturnLoc(95))
  ToolBarToolTip(0,56,ReturnLoc(96))
  ToolBarToolTip(0,57,ReturnLoc(97))
  ToolBarToolTip(0,58,ReturnLoc(98))
  ToolBarToolTip(0,59,ReturnLoc(99))
  ToolBarToolTip(0,60,ReturnLoc(100))
  ToolBarToolTip(0,61,ReturnLoc(101))
  ;}

  ;{ Gadgets
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ListIconGadget(#MainWindow_G0, 0, ToolBarHeight(0), 625, 320, ReturnLoc(102), PSettings\ColumnWidth0, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_GridLines)
  CompilerElse
    ListIconGadget(#MainWindow_G0, 0, 0, 625, 320, ReturnLoc(102), PSettings\ColumnWidth0, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_GridLines)
  CompilerEndIf
  AddGadgetColumn(#MainWindow_G0, 1, ReturnLoc(103), PSettings\ColumnWidth1)
  AddGadgetColumn(#MainWindow_G0, 2, ReturnLoc(104), PSettings\ColumnWidth2)
  AddGadgetColumn(#MainWindow_G0, 3, ReturnLoc(105), PSettings\ColumnWidth3)
  AddGadgetColumn(#MainWindow_G0, 4, ReturnLoc(106), PSettings\ColumnWidth4)
  AddGadgetColumn(#MainWindow_G0, 5, ReturnLoc(107), PSettings\ColumnWidth5)
  EnableGadgetDrop(#MainWindow_G0, #PB_Drop_Files, #PB_Drag_Copy)
  SetGadgetFont(#MainWindow_G0, FontID(1))
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ProgressBarGadget(#MainWindow_G1, 5, 355, 615, 18, 0, 100)
    ProgressBarGadget(#MainWindow_G2, 5, 380, 615, 18, 0, 100)
  CompilerElse
    ProgressBarGadget(#MainWindow_G1, 5, 330, 615, 18, 0, 100)
    ProgressBarGadget(#MainWindow_G2, 5, 355, 615, 18, 0, 100)
  CompilerEndIf
  EnableGadgetDrop(#MainWindow_G0, #PB_Drop_Files, #PB_Drag_Copy)
  ;}

  ;{ Keyboard shortcuts
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control | #PB_Shortcut_O, 0)
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control | #PB_Shortcut_S, 1)
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control | #PB_Shortcut_A, 3)
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Control | #PB_Shortcut_R, 4)
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Delete, 4)
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_F1, 11)
  ;}

  ;{ Resizing
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    GUI_ResizeAddGadget(#MainWindow,#MainWindow_G0,1,0,1,0,0,ToolBarHeight(0),625,320)
    GUI_ResizeAddGadget(#MainWindow,#MainWindow_G1,0,1,1,0,5,355,615,18)
    GUI_ResizeAddGadget(#MainWindow,#MainWindow_G2,0,1,1,0,5,380,615,18)
  CompilerElse
    GUI_ResizeAddGadget(#MainWindow,#MainWindow_G0,1,0,1,0,0,0,625,320)
    GUI_ResizeAddGadget(#MainWindow,#MainWindow_G1,0,1,1,0,5,330,615,18)
    GUI_ResizeAddGadget(#MainWindow,#MainWindow_G2,0,1,1,0,5,355,615,18)
  CompilerEndIf
  ;}

EndIf

;{ Show the window
If PSettings\ShowSplashScreen = 1
  Splash = SplashWindow()
  _dbg("Showing splashscreen")
Else
  Splash = 1
  _dbg("Splashscreen not shown")
EndIf
If Splash = 1
  ResizeWindow(#MainWindow,PSettings\MainWinX, PSettings\MainWinY, PSettings\MainWinWidth, PSettings\MainWinHeight)
  HideWindow(#MainWindow,0)
  If PSettings\MainWinState = 1
    SetWindowState(#MainWindow, #PB_Window_Maximize)
  EndIf
EndIf
_dbg("Entering event loop")
;}

Repeat

  Event = WaitWindowEvent()
  EventType = EventType()

  Select Event

    Case #PB_Event_CloseWindow ;{
      Ask = MessageRequester(ReturnLoc(108), ReturnLoc(109), #PB_MessageRequester_YesNo)
      If Ask = #PB_MessageRequester_Yes
        Quit = 1
      EndIf
      ;}
    
    Case #PB_Event_SizeWindow ;{
      GUI_ResizeEvent(#MainWindow)
      ;}
    
    Case #PB_Event_Menu ;{
      Select EventMenu()

        Case 0,50 ;{ Open list
          ListFile.s = OpenFileRequester(ReturnLoc(110),"","MPX (*.mpx)|*.mpx|"+ReturnLoc(21)+" (*.*)|*.*",0)
          If ListFile <> ""
            OpenConversionList(ListFile)
            StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(Vid())),#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
            RefreshColor()
          EndIf
          ;}

        Case 1,51 ;{ Save list
          ListFile.s = SaveFileRequester(ReturnLoc(111),"","MPX (*.mpx)|*.mpx|"+ReturnLoc(21)+" (*.*)|*.*",0)
          If ListFile <> ""
            If Trim(LCase(Right(ListFile,4))) <> ".mpx"
              ListFile + ".mpx"
            EndIf
            SaveConversionList(ListFile)
            StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(Vid())),#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
          EndIf
          ;}

        Case 2,61 ;{ Quit
          Ask = MessageRequester(ReturnLoc(108), ReturnLoc(109), #PB_MessageRequester_YesNo)
          If Ask = #PB_MessageRequester_Yes
            Quit = 1
          EndIf
          ;}

        Case 3,52 ;{ Add video
          AddVideoWindow()
          StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(VId())),#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
          ;}

        Case 4,53,100 ;{ Remove video
          Item = GetGadgetState(#MainWindow_G0)
          If Item <> -1
            Ask = MessageRequester(ReturnLoc(112), ReturnLoc(113), #PB_MessageRequester_YesNo)
            If Ask = #PB_MessageRequester_Yes
              ItemData = GetGadgetItemData(#MainWindow_G0,Item)
              ForEach Vid()
                If Vid()\ID = ItemData
                  RemoveID(Vid()\ID)
                  DeleteElement(Vid())
                  RemoveGadgetItem(#MainWindow_G0, Item)
                  Break
                EndIf
              Next
            EndIf
            RefreshColor()
          EndIf
          StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(VId())),#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
          ;}

        Case 5 ;{ Remove all
          If ListSize(Vid()) > 0
            Ask = MessageRequester(ReturnLoc(112), ReturnLoc(114), #PB_MessageRequester_YesNo)
            If Ask = #PB_MessageRequester_Yes
              ClearGadgetItems(#MainWindow_G0)
              ClearList(Vid())
              ClearList(IDGen())
            EndIf
          EndIf
          StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(VId())),#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
          ;}

        Case 6,54,101 ;{ Move up
          MoveVideoUp()
          RefreshColor()
        ;}

        Case 7,55,102 ;{ Move down
          MoveVideoDown()
          RefreshColor()
        ;}

        Case 8,56 ;{ Start conversion
          If ListSize(Vid()) > 0
            SetWindowTitle(#MainWindow, "Bytessence MPxConverter")
            StatusBarText(0, 1, ReturnLoc(115))
            StartConversion()
            SetWindowTitle(#MainWindow, "Bytessence MPxConverter")
            StatusBarText(0, 1, ReturnLoc(116))
          Else
            MessageRequester(ReturnLoc(59), ReturnLoc(117))
          EndIf
        ;}

        Case 10,58 ;{ Settings
          SettingsWindow()
          ;}

        Case 11,59 ;{ Help
          If FileSize(CurrentDir+"Help.html") > 0
            StatusBarText(0, 1, ReturnLoc(118))
            RunBrowser(CurrentDir+"Help.html")
          Else
            MessageRequester(ReturnLoc(59),ReturnLoc(119))
          EndIf
        ;}

        Case 12 ;{ Website
          RunBrowser("http://www.bytessence.com")
          StatusBarText(0, 1, ReturnLoc(120))
        ;}  

        Case 13,60 ;{ About
          AboutWindow()
          ;}

      EndSelect
      ;}
 
    Case #PB_Event_Gadget ;{ 
      Select EventGadget()
        
        Case #MainWindow_G0 ;{ Click on list
          If EventType = #PB_EventType_RightClick
            If GetGadgetState(#MainWindow_G0) <> -1
              DisplayPopupMenu(1,WindowID(#MainWindow))
            EndIf
          EndIf
          ;}
          
      EndSelect
      ;}
 
    Case #PB_Event_GadgetDrop ;{
      Select EventGadget()
        Case #MainWindow_G0
          FilesDrop.s = EventDropFiles()
          If FilesDrop <> ""
            AddVideoWindow(ReplaceString(FilesDrop, Chr(10), "|"))
            StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(VId())),#PB_String_NoCase),"$convertedvid$","0",#PB_String_NoCase))
          EndIf
      EndSelect ;}
 
  EndSelect

Until Quit = 1

;{ Save settings
_dbg("Saving settings")
If OpenPreferences("MPxConfig.ini")
  PreferenceGroup("MPxWindow")
  If GetWindowState(#MainWindow)<>#PB_Window_Minimize
    WritePreferenceString("WinW", Str(WindowWidth(#MainWindow)))
    WritePreferenceString("WinH", Str(WindowHeight(#MainWindow)))
    WritePreferenceString("WinX", Str(WindowX(#MainWindow)))
    WritePreferenceString("WinY", Str(WindowY(#MainWindow)))
    WritePreferenceString("WinState", Str(GetWindowState(#MainWindow)))
  EndIf
  PreferenceGroup("MPxColumns")
  WritePreferenceString("ColumnWidth0", Str(GetGadgetItemAttribute(#MainWindow_G0, 0, #PB_ListIcon_ColumnWidth, 0)))
  WritePreferenceString("ColumnWidth1", Str(GetGadgetItemAttribute(#MainWindow_G0, 0, #PB_ListIcon_ColumnWidth, 1)))
  WritePreferenceString("ColumnWidth2", Str(GetGadgetItemAttribute(#MainWindow_G0, 0, #PB_ListIcon_ColumnWidth, 2)))
  WritePreferenceString("ColumnWidth3", Str(GetGadgetItemAttribute(#MainWindow_G0, 0, #PB_ListIcon_ColumnWidth, 3)))
  WritePreferenceString("ColumnWidth4", Str(GetGadgetItemAttribute(#MainWindow_G0, 0, #PB_ListIcon_ColumnWidth, 4)))
  WritePreferenceString("ColumnWidth5", Str(GetGadgetItemAttribute(#MainWindow_G0, 0, #PB_ListIcon_ColumnWidth, 5)))
  ClosePreferences()
  _dbg("Settings saved")
EndIf
;}

;{ End
If PSettings\UseLogging = 1
  Log_AddFooter(PSettings\LogFilePath)
EndIf
End
;}

;{ Data section
CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  DataSection
    IMG_LogoImage:
    IncludeBinary "DataSection\Win\startuplogo.bmp"
    IMG_AboutLogo:
    IncludeBinary "DataSection\Win\aboutmpx.bmp"
    IMG_Save:
    IncludeBinary "DataSection\Win\save.ico"
    IMG_Load:
    IncludeBinary "DataSection\Win\load.ico"
    IMG_Add:
    IncludeBinary "DataSection\Win\add.ico"
    IMG_Delete:
    IncludeBinary "DataSection\Win\delete.ico"
    IMG_Up:
    IncludeBinary "DataSection\Win\up.ico"
    IMG_Down:
    IncludeBinary "DataSection\Win\down.ico"
    IMG_Start:
    IncludeBinary "DataSection\Win\start.ico"
    IMG_Stop:
    IncludeBinary "DataSection\Win\stop.ico"
    IMG_Settings:
    IncludeBinary "DataSection\Win\settings.ico"
    IMG_Help:
    IncludeBinary "DataSection\Win\help.ico"
    IMG_About:
    IncludeBinary "DataSection\Win\about.ico"
    IMG_Exit:
    IncludeBinary "DataSection\Win\exit.ico"
    IMG_Website:
    IncludeBinary "DataSection\Win\website.ico"
    IMG_Film:
    IncludeBinary "DataSection\Win\film.ico"
    IMG_General:
    IncludeBinary "DataSection\Win\general.ico"
    IMG_Language:
    IncludeBinary "DataSection\Win\language.ico"
  EndDataSection
CompilerEndIf
CompilerIf #PB_Compiler_OS = #PB_OS_Linux
  DataSection
    IMG_LogoImage:
    IncludeBinary "DataSection/Lin/startuplogo.png"
    IMG_AboutLogo:
    IncludeBinary "DataSection/Lin/aboutmpx.png"
    IMG_Save:
    IncludeBinary "DataSection/Lin/save.png"
    IMG_Load:
    IncludeBinary "DataSection/Lin/load.png"
    IMG_Add:
    IncludeBinary "DataSection/Lin/add.png"
    IMG_Delete:
    IncludeBinary "DataSection/Lin/delete.png"
    IMG_Up:
    IncludeBinary "DataSection/Lin/up.png"
    IMG_Down:
    IncludeBinary "DataSection/Lin/down.png"
    IMG_Start:
    IncludeBinary "DataSection/Lin/start.png"
    IMG_Stop:
    IncludeBinary "DataSection/Lin/stop.png"
    IMG_Settings:
    IncludeBinary "DataSection/Lin/settings.png"
    IMG_Help:
    IncludeBinary "DataSection/Lin/help.png"
    IMG_About:
    IncludeBinary "DataSection/Lin/about.png"
    IMG_Exit:
    IncludeBinary "DataSection/Lin/exit.png"
    IMG_Website:
    IncludeBinary "DataSection/Lin/website.png"
    IMG_Film:
    IncludeBinary "DataSection/Lin/film.png"
    IMG_General:
    IncludeBinary "DataSection/Lin/general.png"
    IMG_Language:
    IncludeBinary "DataSection/Lin/language.png"
  EndDataSection
CompilerEndIf
;}



; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 108
; FirstLine = 99
; Folding = AAAAAAAAAAAAAA+
; EnableXP
; EnableOnError
; UseIcon = DataSection\Win\MPxConverter.ico
; Executable = MPxConverter.exe
; CompileSourceDirectory
; IncludeVersionInfo
; VersionField0 = 1,0,0,0
; VersionField1 = 1,0,0,0
; VersionField2 = Bytessence
; VersionField3 = MPxConverter
; VersionField4 = 1,0,0,0
; VersionField5 = 1,0,0,0
; VersionField6 = MPxConverter AMV-Codec-Tools frontend (Win32)
; VersionField7 = MPxConverter
; VersionField8 = MPxConverter.exe
; VersionField9 = (c) 2008-2009 Trutia Alexandru
; VersionField10 = FFMpeg is a trademark of Fabrice Bellard
; VersionField13 = support@bytessence.com
; VersionField14 = http://www.bytessence.com