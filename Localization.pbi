
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

Global Dim LanguageData.s(0)
Global LanguageIndex.i

;-----------------------------------------------------------------------------------

Procedure.i LoadLanguageFile(File.s)
  
  If File <> "" And FileSize(File) > 0
    If OpenPreferences(File) <> 0
      PreferenceGroup("MPxConverterLanguageData")
      ;Count the entries
      If ExaminePreferenceKeys()
        While NextPreferenceKey()
          If PreferenceKeyName() <> ""
            LanguageIndex + 1
          EndIf
        Wend
        ReDim LanguageData.s(LanguageIndex)
      EndIf
      ;Now actually read the data
      If ExaminePreferenceKeys()
        While NextPreferenceKey()
          LanguageData(Index) = ReplaceString(ReadPreferenceString("l"+Str(Index),""),"<br>",#CRLF$,#PB_String_NoCase)
          Index + 1
        Wend
      EndIf
      ClosePreferences()
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  Else
    ProcedureReturn 0
  EndIf
  
EndProcedure

Procedure.s ReturnLoc(Index)
  
  If Index > LanguageIndex Or Index < 0
    ProcedureReturn ""
  EndIf
  
  ProcedureReturn LanguageData(Index)
  
EndProcedure

;-----------------------------------------------------------------------------------

; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 43
; Folding = 9
; EnableXP