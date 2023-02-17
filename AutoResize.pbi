
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

Structure GUI_ResizeGadget
  WindowID.i
  GadgetID.i
  UpSize.i
  DownSize.i
  LeftSize.i
  RightSize.i
  LockUp.i
  LockDown.i
  LockLeft.i
  LockRight.i
EndStructure

Global GUI_ResizeIndex.i = -1
Global Dim GUI_ResizeArray.GUI_ResizeGadget(0)

Procedure.i GUI_ResizeAddGadget(WindowID.i, GadgetID.i, LockUp.i, LockDown.i, LockLeft.i, LockRight.i, GadgetX.i, GadgetY.i, GadgetWidth.i, GadgetHeight.i)
  
  ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ; Procedure purpose: add a gadget to the resizing list
  ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  Protected WindowWidth.i, WindowHeight.i
  
  If GUI_ResizeIndex.i = -1
    GUI_ResizeIndex.i = 0
  EndIf
  
  ReDim GUI_ResizeArray.GUI_ResizeGadget(GUI_ResizeIndex)
  
  WindowWidth.i = WindowWidth(WindowID)
  WindowHeight.i = WindowHeight(WindowID)
  
  With GUI_ResizeArray(GUI_ResizeIndex)
    
    \WindowID.i = WindowID
    \GadgetID.i = GadgetID
    \LockUp.i = LockUp
    \LockDown.i = LockDown
    \LockLeft.i = LockLeft
    \LockRight.i = LockRight
    
    If LockUp = 0
      \UpSize.i = WindowHeight-GadgetY
    EndIf
    
    If LockDown = 0
      \DownSize.i = WindowHeight-GadgetY-GadgetHeight
    EndIf
    
    If LockLeft = 0
      \LeftSize.i = WindowWidth-GadgetX
    EndIf
    
    If LockRight = 0
      \RightSize.i = WindowWidth-GadgetX-GadgetWidth
    EndIf
    
  EndWith
  
  Protected Result = GUI_ResizeIndex
  
  GUI_ResizeIndex + 1
  
  ProcedureReturn Result
  
EndProcedure

Procedure.i GUI_ResizeEvent(WindowID.i)
  
  ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ; Procedure purpose: resize all the gadgets
  ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  Protected WindowWidth.i, WindowHeight.i, GadgetX.i, GadgetY.i, GadgetWidth.i, GadgetHeight.i, BeginResizing.i
  
  If GUI_ResizeIndex = -1
    
    ProcedureReturn -1
    
  Else
    
    For BeginResizing = 0 To GUI_ResizeIndex-1
      
      With GUI_ResizeArray(BeginResizing)
        
        If \WindowID = WindowID And IsWindow(\WindowID) ;Is this our window?
          
          WindowWidth.i = WindowWidth(\WindowID)
          WindowHeight.i = WindowHeight(\WindowID)
          GadgetX.i = GadgetX(\GadgetID)
          GadgetY.i = GadgetY(\GadgetID)
          GadgetWidth.i = #PB_Ignore
          GadgetHeight.i = #PB_Ignore
          
          If \LockUp = 0
            GadgetY = WindowHeight-\UpSize
          EndIf
          
          If \LockDown = 0
            GadgetHeight = WindowHeight-GadgetY-\DownSize
          EndIf
          
          If \LockLeft = 0
            GadgetX = WindowWidth-\LeftSize
          EndIf
          
          If \LockRight = 0
            GadgetWidth = WindowWidth-GadgetX-\RightSize
          EndIf
          
          If IsGadget(\GadgetID) ;A little checking to be sure we don't resize an inexistent gadget
            ResizeGadget(\GadgetID, GadgetX, GadgetY, GadgetWidth, GadgetHeight)
          EndIf
          
        EndIf
        
      EndWith
      
    Next
    
  EndIf
  
EndProcedure


; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 43
; FirstLine = 2
; Folding = 9
; EnableXP