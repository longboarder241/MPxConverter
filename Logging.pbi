
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

Procedure.i Log_AddHeader(File.s, ProgramName.s)
  
  Log.i = CreateFile(#PB_Any, File)
  If IsFile(Log)
    WriteStringN(Log, "*** " + ProgramName.s + " ***")
    WriteStringN(Log, "")
    FlushFileBuffers(Log)
    CloseFile(Log)
    ProcedureReturn 1
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure.i Log_AddFooter(File.s)

  Leng = FileSize(File)
  Log = OpenFile(#PB_Any, file.s)
  If IsFile(Log) And Leng >= 0
    FileSeek(Log, Leng)
    WriteStringN(Log, "")
    WriteStringN(Log, "*** Session ended ***")
    FlushFileBuffers(Log)
    CloseFile(Log)
    ProcedureReturn 1
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure.i Log_Write(File.s, Entry.s)
  
  Log.i = OpenFile(#PB_Any, File.s)
  If IsFile(Log)
    FileSeek(Log, Lof(Log))
    If Entry.s = ""
      WriteStringN(Log, "")
    Else
      WriteStringN(Log, FormatDate("%dd/%mm/%yy", Date()) + " " + FormatDate("%hh:%ii:%ss", Date()) + " -> " + Entry)
    EndIf
    FlushFileBuffers(Log)
    CloseFile(Log)
    ProcedureReturn 1
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure

Procedure.i Log_ClearLog(File.s)
  
  If FileSize(File) <> -1 And FileSize(File) <> -2
    ProcedureReturn DeleteFile(File)
  Else
    ProcedureReturn -1
  EndIf
  
EndProcedure



; IDE Options = PureBasic 4.30 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 20
; Folding = w
; EnableThread
; EnableXP
; UseMainFile = N-DET.pb
; Executable = OAMLog.dll
; CPU = 1
; SubSystem = UserLibThreadSafe
; CompileSourceDirectory
; EnableCompileCount = 0
; IncludeVersionInfo
; VersionField0 = 1,0,0,0
; VersionField1 = 1,0,0,0
; VersionField2 = Orangeworks.dk
; VersionField3 = Orangeworks AntiMalware
; VersionField4 = 1,0,0,0
; VersionField5 = 1,0,0,0
; VersionField6 = Orangeworks AntiMalware Log Helper
; VersionField7 = Orangeworks AntiMalware
; VersionField8 = OAHeur.dll
; VersionField9 = (c) 2006 Trutia Alexandru & Daniel Middelhede
; VersionField10 = All mentioned trademarks are be owned by their respective owners.
; VersionField11 = BETA 1
; VersionField13 = support@orangeworks.dk
; VersionField14 = http://orangeworks.dk
; VersionField16 = VFT_DLL