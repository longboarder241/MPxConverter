
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

Procedure ErrorHandler()
  
  If CreateFile(0, "ErrorReport.log")
    WriteStringN(0, "------------------------------------")
    WriteStringN(0, "Bytessence Bytessence MPxConverter Error Log")
    WriteStringN(0, "------------------------------------")
    Date$ = FormatDate("%yyyy/%mm/%dd", Date())
    Time$ = FormatDate("%hh:%ii:%ss", Date())
    WriteStringN(0, "Generated on " + Date$ + " at " + Time$)
    WriteStringN(0, "")
    WriteStringN(0, "Error description: " + ErrorMessage())
    WriteStringN(0, "Module name: " + ErrorFile())
    WriteStringN(0, "Line: " + Str(ErrorLine()))
    WriteStringN(0, "EOF()")
    CloseFile(0)
  EndIf
  MessageRequester("Error", "Bytessence MPxConverter has stopped running due to an error. An error log ('ErrorReport.log') was created in the program's directory, describing the problem. You can send this report via email to 'support@bytessence.com' and we will try to fix the problem in the shortest time. Thank you for your understanding.", #MB_ICONSTOP)
  End
  
EndProcedure

OnErrorCall(@ErrorHandler())


; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 20
; Folding = +