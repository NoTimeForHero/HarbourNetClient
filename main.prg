#include "minigui.ch"


#define WM_COPYDATA 74

Function MainEventLoop ( hWnd, nMsg, wParam, lParam )
   Local nCargo, cCmd
   do case
      case nMsg == WM_COPYDATA
         cCmd := GetMessageData( lParam, @nCargo )
         Win1_OnWmCopyData(hWnd, cCmd)
         Win2_OnWmCopyData(hWnd, cCmd)
   endcase
Return Events ( hWnd, nMsg, wParam, lParam )

PROCEDURE Main

	SET EVENTS FUNCTION TO MainEventLoop    

    Demo1()
    Demo2()
    ACTIVATE WINDOW Win_1, Win_2
RETURN