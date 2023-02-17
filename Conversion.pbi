
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

Global StopMutex = 0, TotalVideos = 0, BigProgress.d = 0, UpdateSpeed = 0, PM_Timer = 1

;-----------------------------------------------------------------------------------
 
Procedure.s CalculateTime(StartTime, Progress.f, HS.s, HP.s, MS.s, MP.s, SS.s, SP.s, NA.s)
  
  Protected Total.f = 100
  Protected Elapsed = Date()-StartTime
  
  If Elapsed = 0
    Elapsed = 1
  EndIf
  Speed.f = Progress/Elapsed
  If Speed <> 0
    RemainingTime = Abs((Total-Progress)/Speed)
    If RemainingTime < 0
      RemainingTime = 0
    EndIf
  Else
    RemainingTime = 0
  EndIf
  If RemainingTime = 0
    ProcedureReturn NA
  EndIf
  Seconds = RemainingTime%60
  Minutes = RemainingTime%(60*60)/60
  Hours = RemainingTime%(60*60*60)/(60*60)
  If Hours <> 0
    If Hours = 1
      TimeString.s + Str(Hours) + " " + HS.s + " "
    Else
      TimeString.s + Str(Hours) + " " + HP.s + " "
    EndIf
  EndIf
  If Minutes<>0
    If Minutes = 1
      TimeString + Str(Minutes) + " " + MS + " "
    Else
      TimeString + Str(Minutes) + " " + MP + " "
    EndIf
  EndIf
  If Seconds = 1
    TimeString + Str(Seconds) + " " + SS
  Else
    TimeString + Str(Seconds) + " " + SP
  EndIf
  
  ProcedureReturn Trim(TimeString)
  
EndProcedure

;-----------------------------------------------------------------------------------
 
Procedure.f FFMpeg_ExtractTotalDuration(Text.s)
  
  Dim Result.s(10)
  
  If CreateRegularExpression(0, "[0-9]*\.?[0-9*]")
    Count.l = ExtractRegularExpression(0, Text, Result())
    TotalSeconds.f = ValF(Result(2)) + (ValF(Result(1))*60) + (ValF(Result(0))*3600)
    FreeRegularExpression(0)
  EndIf
  
  ReDim Result.s(0)
  
  ProcedureReturn TotalSeconds
  
EndProcedure

Procedure.f FFMpeg_ExtractDuration(Text.s)
  
  Dim Result.s(10)
  
  If CreateRegularExpression(1, "[0-9]*\.?[0-9*]")
    Count = ExtractRegularExpression(1, Text, Result())
    TotalSeconds.f = ValF(Result(4))
    FreeRegularExpression(1)
  EndIf
  
  ReDim Result.s(0)
  
  ProcedureReturn TotalSeconds
  
EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i HandleEvents(FFMpegH,Item)
  
  ;{ Init
  FileStartTime = Date()
  Select PSettings\InterfaceUpdateSpeed
    Case 0
      UpdateSpeed = 1000
    Case 1
      UpdateSpeed = 1500
    Case 2
      UpdateSpeed = 2000
  EndSelect 
  ;}
  
  While ProgramRunning(FFMpegH)
    
    ;{ Handle the timer
    If PM_TimeOut = 1
      PM_Timer = 1
      PM_StartTime = ElapsedMilliseconds()/UpdateSpeed
    EndIf
    PM_TimeOut = PM_Timer <> -1 Or 0
    ;}
    
    ;{ Read stderr
    Error.s = ReadProgramError(FFMpegH)
    If Error <> ""
      _dbg("FFMpeg stdout: " + Error)
      If FindString(LCase(Error), "duration:", 0) And FindString(LCase(Error), "start:", 0) And FindString(LCase(Error), "bitrate:", 0)
        TotalDuration.f = FFMpeg_ExtractTotalDuration(Error)
      ElseIf FindString(LCase(Error), "frame=", 0) And FindString(LCase(Error), "fps=", 0) And FindString(LCase(Error), "size=", 0) And FindString(LCase(Error), "time=", 0) And FindString(LCase(Error), "bitrate=", 0)
        CurrentDuration.f = FFMpeg_ExtractDuration(Error)
      EndIf
    EndIf
    ;}
    
    ;{ Events
    Event = WaitWindowEvent(PM_TimeOut)
    EventType = EventType()
    
    If Event <> 0
      Select Event
        
        Case #PB_Event_SizeWindow ;{
          GUI_ResizeEvent(#MainWindow)
          ;}
        
        Case #PB_Event_CloseWindow ;{
          Ask = MessageRequester(ReturnLoc(108), ReturnLoc(121), #PB_MessageRequester_YesNo)
          If Ask = #PB_MessageRequester_Yes
            KillProgram(FFMpegH)
            CloseProgram(FFMpegH)
            End
          EndIf
          ;}
        
        Case #PB_Event_Menu ;{
          Select EventMenu()
            Case 9,57
             Ask = MessageRequester(ReturnLoc(122), ReturnLoc(123), #PB_MessageRequester_YesNo)
             If Ask = #PB_MessageRequester_Yes
               KillProgram(FFMpegH)
               CloseProgram(FFMpegH)
               SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(124), 4)
               SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
               StopMutex = 0
               ProcedureReturn 0
             EndIf
          EndSelect
          ;}
        
      EndSelect
    EndIf
    ;}
    
    ;{ When timer expires
    If ElapsedMilliseconds()/UpdateSpeed <> PM_Sec
      PM_Sec = ElapsedMilliseconds()/UpdateSpeed
      If ElapsedMilliseconds()/UpdateSpeed-PM_StartTime = PM_Timer
        If TotalDuration > 0 And CurrentDuration > 0
          SmallProgress.d = (CurrentDuration+1)*100/(TotalDuration+1)/(TotalVideos)
          FileProgress.f = (CurrentDuration/TotalDuration)*100
          SetWindowTitle(#MainWindow, ReturnLoc(135) + " " + StrF(BigProgress + SmallProgress, 2) + "%")
          SetGadgetState(#MainWindow_G1, FileProgress)
          SetGadgetState(#MainWindow_G2, BigProgress + SmallProgress)
          SetGadgetItemText(#MainWindow_G0, Item, StrF(FileProgress, 2) + "%", 4)
          SetGadgetItemText(#MainWindow_G0, Item, CalculateTime(FileStartTime, FileProgress, ReturnLoc(136), ReturnLoc(137), ReturnLoc(138), ReturnLoc(139), ReturnLoc(140), ReturnLoc(141), ReturnLoc(134)), 5)
        EndIf
      EndIf
    EndIf
    ;}
    
  Wend
  
  ;{ Return
  ExitCode = ProgramExitCode(FFMpegH)
  _dbg("FFMpeg exit code: "+Str(ExitCode))
  If ExitCode = 0
    ProcedureReturn 1
  Else
    ProcedureReturn 2
  EndIf
  ;}

EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i ConvertActions(Item, Input.s, Output.s, Resolution.s, FPS.s, VidQual, Aspect)

  ;{ Log
  _dbg("---------------------------------------------")
  _dbg("Item no. " + Str(Item + 1))
  _dbg("Input file: " + Input)
  _dbg("Output file: " + Output)
  _dbg("Resolution: " + Resolution)
  _dbg("FPS: " + FPS)
  _dbg("Video quality: " + Str(VidQual))
  _dbg("Aspect ratio: " + Str(Aspect))
  _dbg("---------------------------------------------")
  ;}

  ;{ Build command line
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If Right(Output, 1) <> "\"
      Output + "\"
    EndIf
  CompilerElse
    If Right(Output, 1) <> "/"
      Output + "/"
    EndIf
  CompilerEndIf
  InputFile.s = Chr(34) + Input + Chr(34)
  OutputFile.s = Chr(34) + OutPut + ReplaceString(GetFilePart(InputFile), GetExtensionPart(GetFilePart(InputFile)), "amv") + Chr(34)
  If FileSize(OutPut + ReplaceString(GetFilePart(InputFile), GetExtensionPart(GetFilePart(InputFile)), "avi")) <> -1
    _dbg("Input file already exists")
    Select PSettings\OutputExistsAction
      Case 0
        Ask = MessageRequester(ReturnLoc(112),ReturnLoc(125)+#CRLF$+#CRLF$+OutputFile+#CRLF$+#CRLF$+ReturnLoc(126),#PB_MessageRequester_YesNo)
        If Ask = #PB_MessageRequester_No
          SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(127), 4)
          SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
          _dbg("Skipping file")
          ProcedureReturn 1
        Else
          _dbg("Replacing file")
        EndIf
      Case 1
        SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(127), 4)
        SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
        _dbg("Skipping file (auto)")
        ProcedureReturn 1
      Case 2
        _dbg("Replacing file (auto)")
        ;Do nothing
    EndSelect
  EndIf
  Select VidQual
    Case 0
      VideoQuality.s = "-qmin " + Trim(StringField(QualActionsHi, 1, "|")) + " -qmax " + Trim(StringField(QualActionsHi, 2, "|"))
    Case 1
      VideoQuality.s = "-qmin " + Trim(StringField(QualActionsMed, 1, "|")) + " -qmax " + Trim(StringField(QualActionsMed, 2, "|"))
    Case 2
      VideoQuality.s = "-qmin " + Trim(StringField(QualActionsLow, 1, "|")) + " -qmax " + Trim(StringField(QualActionsLow, 2, "|"))
  EndSelect
  Select Aspect
    Case 0
      AspectRatio.s = ""
    Case 1
      AspectRatio.s = " -aspect 4:3 "
    Case 2
      AspectRatio.s = " -aspect 16:9 "
  EndSelect
  CommandLine.s = " -i " + InputFile + " -y -vcodec amv " + VideoQuality + " -s " + Trim(Resolution) + " -r " + Trim(FPS) + " -ac 1 -ar 22050 " + AspectRatio + OutputFile + " " + Verbosity
  _dbg("*** Command line: " + CommandLine)
  ;}
  
  ;{ Run FFMpeg
  FFMpegH = RunProgram(FFMPEG, CommandLine, "", #PB_Program_Error | #PB_Program_Open | #PB_Program_Hide)
  _dbg("FFMpegH: " + Str(FFMpegH))
  If IsProgram(FFMpegH) <> 0
    Status = HandleEvents(FFMpegH,Item)
    If Status = 0
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(124), 4)
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
    ElseIf Status = 1 
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(128), 4)
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
    ElseIf Status = 2
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(129), 4)
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
    EndIf
  Else
    MessageRequester(ReturnLoc(0), ReturnLoc(130)):End
  EndIf
  If IsProgram(FFMpegH) <> 0
    KillProgram(FFMpegH)
    CloseProgram(FFMpegH)
  EndIf
  ;}
  
  ;{ Return
  _dbg(#PB_Compiler_Procedure + " retn()")
  ProcedureReturn 1
  ;}

EndProcedure

Procedure.i ConvertSunplus(Item, Input.s, Output.s, Resolution.s, FPS.s, VidQual, AudQual, Aspect)

  ;{ Log
  _dbg("---------------------------------------------")
  _dbg("Item no. " + Str(Item + 1))
  _dbg("Input file: " + Input)
  _dbg("Output file: " + Output)
  _dbg("Resolution: " + Resolution)
  _dbg("FPS: " + FPS)
  _dbg("Video quality: " + Str(VidQual))
  _dbg("Aspect ratio: " + Str(Aspect))
  _dbg("---------------------------------------------")
  ;}

  ;{ Build command line
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If Right(Output, 1) <> "\"
      Output + "\"
    EndIf
  CompilerElse
    If Right(Output, 1) <> "/"
      Output + "/"
    EndIf
  CompilerEndIf
  InputFile.s = Chr(34) + Input + Chr(34)
  OutputFile.s = Chr(34) + OutPut + ReplaceString(GetFilePart(InputFile), GetExtensionPart(GetFilePart(InputFile)), "avi") + Chr(34)
  If FileSize(OutPut + ReplaceString(GetFilePart(InputFile), GetExtensionPart(GetFilePart(InputFile)), "avi")) <> -1
    _dbg("Input file already exists")
    Select PSettings\OutputExistsAction
      Case 0
        Ask = MessageRequester(ReturnLoc(112),ReturnLoc(125)+#CRLF$+#CRLF$+OutputFile+#CRLF$+#CRLF$+ReturnLoc(126),#PB_MessageRequester_YesNo)
        If Ask = #PB_MessageRequester_No
          SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(127), 4)
          SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
          _dbg("Skipping file")
          ProcedureReturn 1
        Else
          _dbg("Replacing file")
        EndIf
      Case 1
        SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(127), 4)
        SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
        _dbg("Skipping file (auto)")
        ProcedureReturn 1
      Case 2
        _dbg("Replacing file (auto)")
        ;Do nothing
    EndSelect
  EndIf
  Select VidQual
    Case 0
      VideoQuality.s = "-b " + QualSunplusHi + "k"
    Case 1
      VideoQuality.s = "-b " + QualSunplusMed + "k"
    Case 2
      VideoQuality.s = "-b " + QualSunplusLow + "k"
  EndSelect
  Select AudQual
    Case 0
      AudioQuality.s = "-ab 96k"
    Case 1
      AudioQuality.s = "-ab 64k"
    Case 2
      AudioQuality.s = "-ab 40k"
  EndSelect
  Select Aspect
    Case 0
      AspectRatio.s = ""
    Case 1
      AspectRatio.s = " -aspect 4:3 "
    Case 2
      AspectRatio.s = " -aspect 16:9 "
  EndSelect
  CommandLine.s = " -i " + InputFile + " -y -vcodec libxvid " + VideoQuality + " -s " + Trim(Resolution) + " -r " + Trim(FPS) + " -acodec libmp3lame " + AudioQuality + " -ac 2 -ar 44100 " + AspectRatio + OutputFile + " " + Verbosity
  _dbg("*** Command line: " + CommandLine)
  ;}
  
  ;{ Run FFMpeg
  FFMpegH = RunProgram(FFMPEG, CommandLine, "", #PB_Program_Error | #PB_Program_Open | #PB_Program_Hide)
  _dbg("FFMpegH: " + Str(FFMpegH))
  If IsProgram(FFMpegH) <> 0
    Status = HandleEvents(FFMpegH,Item)
    If Status = 0
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(124), 4)
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
    ElseIf Status = 1 
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(128), 4)
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
    ElseIf Status = 2
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(129), 4)
      SetGadgetItemText(#MainWindow_G0, Item, ReturnLoc(134), 5)
    EndIf
  Else
    MessageRequester(ReturnLoc(0), ReturnLoc(130)):End
  EndIf
  If IsProgram(FFMpegH) <> 0
    KillProgram(FFMpegH)
    CloseProgram(FFMpegH)
  EndIf
  ;}
  
  ;{ Return
  _dbg(#PB_Compiler_Procedure + " retn()")
  ProcedureReturn 1
  ;}
  
EndProcedure

;-----------------------------------------------------------------------------------

Procedure.i StartConversion()
  
  ;{ Variables
  _dbg("(!) Starting conversion...")
  TotalVideos = ListSize(Vid())
  BigProgress = 0
  StopMutex = 1
  ;}
  
  ;{ Check items
  If TotalVideos = 0
    MessageRequester(ReturnLoc(59),ReturnLoc(131))
    ProcedureReturn 0
  EndIf
  ;}

  ;{ Disable controls
  For DisableToolbar = 50 To 61
    If DisableToolbar = 57
      Mode = 0
    Else
      Mode = 1
    EndIf
    DisableToolBarButton(0,DisableToolbar,Mode)
  Next
  For DisableMenu = 0 To 13
    If DisableMenu = 9
      Mode = 0
    Else
      Mode = 1
    EndIf
    DisableMenuItem(0,DisableMenu,Mode)
  Next
  ;}
  
  ;{ Convert videos
  ForEach Vid()
    For Test = 0 To CountGadgetItems(#MainWindow_G0)-1
      If Vid()\ID = GetGadgetItemData(#MainWindow_G0,Test)
        Item = Test
        Break
      EndIf
    Next
    If StopMutex = 0
      Break
    EndIf
    BigProgress = DoneItems*100/(TotalVideos)
    Select Vid()\PlayerType
      Case 0 
        _dbg("Conversion type is Actions...")
        ConvertActions(Item, Vid()\Input, Vid()\OutputPath, Vid()\Resolution, Vid()\FPS, Vid()\VidQual, Vid()\AspectRatio)
      Case 1
        _dbg("Conversion type is Sunplus...")
        ConvertSunplus(Item, Vid()\Input, Vid()\OutputPath, Vid()\Resolution, Vid()\FPS, Vid()\VidQual, Vid()\AudQual, Vid()\AspectRatio)
    EndSelect
    If PSettings\ClearItems = 1
      _dbg("PSettings\ClearItems = 1, removing item: "+Str(Test))
      DeleteElement(Vid())
      RemoveGadgetItem(#MainWindow_G0,Test)
    EndIf
    StatusBarText(0, 0, ReplaceString(ReplaceString(ReturnLoc(67),"$totalvid$",Str(ListSize(VId())),#PB_String_NoCase),"$convertedvid$",Str(DoneItems+1),#PB_String_NoCase))
    DoneItems + 1
  Next
  _dbg("(!) Conversion finished...")
  ;}

  ;{ Enable controls
  For DisableToolbar = 50 To 61
    If DisableToolbar = 57
      Mode = 1
    Else
      Mode = 0
    EndIf
    DisableToolBarButton(0,DisableToolbar,Mode)
  Next
  For DisableMenu = 0 To 13
    If DisableMenu = 9
      Mode = 1
    Else
      Mode = 0
    EndIf
    DisableMenuItem(0,DisableMenu,Mode)
  Next
  ;}
  
  ;{ Reset controls
  SetWindowTitle(#MainWindow, ReturnLoc(135)+" 100%")
  SetGadgetState(#MainWindow_G1, 0)
  SetGadgetState(#MainWindow_G2, 0)
  ;}
  
  ;{ Notify user
  MessageRequester(ReturnLoc(132), ReturnLoc(133))
  ;}
  
  ;{ Clean up and return
  _dbg("Entering main event loop...")
  StopMutex = 0
  ProcedureReturn 1
  ;}
  
EndProcedure

;-----------------------------------------------------------------------------------











; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 105
; FirstLine = 20
; Folding = AAAAA9
; EnableXP