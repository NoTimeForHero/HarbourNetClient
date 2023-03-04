/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez
 */

#include "minigui.ch"

MEMVAR OClient

PROCEDURE Main

	PUBLIC OClient := NIL

	SET EVENTS FUNCTION TO MyEvents
	SET FONT TO 'Segoe UI', 14

	DEFINE WINDOW Win_1		;
		CLIENTAREA 400, 400	;
		TITLE 'HttpClientDemo'	;
		WINDOWTYPE MAIN         ;
		ON INIT OnInit( App.Handle ) ;
		ON RELEASE OnRelease() ;

		@ 10,10 BUTTON BUTTON_1 ;
			CAPTION "Send HTTP request" ;
			ACTION MakeTestRequest() ;
			WIDTH 200 ;
			HEIGHT 60

		DEFINE TIMER oTimerBlink
        	INTERVAL 1000
        	ACTION   { || OClient:DoHttpEvents() }
    	END TIMER

	END WINDOW

	Win_1.Center

	Win_1.Activate
RETURN

FUNCTION OnInit(nHandle)
  LOCAL cPath
  LOCAL cHandle := ALLTRIM(STR(nHandle))
  LOCAL cSelfHandle := ALLTRIM(STR(ThisWindow.Handle))
  //#InputBox('Handle: ', 'Handle', cHandle)

  cPath := GetStartUpFolder() + "\NetClient\bin\Debug\NetClient.exe"
  OClient := HttpClient():New(nHandle, cPath)
  //MakeTestRequest()
RETURN NIL

FUNCTION MakeTestRequest() 
	LOCAL xSuccess := {|xResult| MsgInfo(HB_JsonEncode(xResult, .T.)) }
	LOCAL hParams := HASH()
	hParams["Url"] = "https://jsonplaceholder.typicode.com/posts"
	hParams["Method"] = "BODY"
	hParams["Headers"] = { "Content-Type" => "application/json"}
	hParams["Body"] = '{"key": "value"}'
	MsgInfo("Click->MakeTestRequest")
	OClient:Request(hParams, xSuccess)
RETURN NIL

FUNCTION OnRelease
	OClient:Release()
RETURN NIL

FUNCTION OnWmCopyData(cData)
   // MsgInfo(cData)
   OClient:OnMessage(cData)   
RETURN NIL
