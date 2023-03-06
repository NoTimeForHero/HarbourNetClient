#include "minigui.ch"

MEMVAR OClient2
MEMVAR hInstance

#define ACTION_UPLOAD "ADD_USER"
#define ACTION_REFRESH "LIST_USERS"
 
#define CLRF CHR(10) + CHR(13)
#define WM_COPYDATA 74
 
 PROCEDURE Demo2()
 
     PUBLIC OClient2 := NIL
     PUBLIC hInstance
 
     SET EVENTS FUNCTION TO Win2Events
     SET FONT TO 'Segoe UI', 14
 
     DEFINE WINDOW Win_2		;
         CLIENTAREA 800, 400	;
         TITLE 'HttpClientDemo2'	;
         WINDOWTYPE CHILD         ;
         ON INIT OnInit() ;
         ON RELEASE OnRelease() ;
 
        //  DEFINE TIMER oTimerBlink
        //      INTERVAL 1000
        //      ACTION   { || OClient2:DoHttpEvents() }
        //  END TIMER
 
     END WINDOW
 
     Win_2.Center
 RETURN
 
 STATIC FUNCTION OnInit()
   LOCAL cPath, hOptions
   hInstance := ThisWindow.Handle   
 
   // hOptions := { "ClientTTL" => 10, "KeepAliveInterval" => 5, "Timeout" => 2}
   hOptions := { "Arguments" => "--hwnd=%HANDLE% --ttl=%TTL% --debug" }
   cPath := GetStartUpFolder() + "\NetClient\bin\Debug\NetClient.exe"

   OClient2 := HttpClient():New(hInstance, cPath, hOptions)
   ThisWindow.Title := ThisWindow.Title + " - " + ALLTRIM(STR(hInstance))
 RETURN NIL
 
 STATIC FUNCTION OnRelease
     OClient2:Release()
 RETURN NIL
 
 FUNCTION Win2_OnWmCopyData(nHandle, cData)
    IF nHandle != hInstance
        RETURN NIL
    ENDIF
    OClient2:OnMessage(cData)   
 RETURN NIL