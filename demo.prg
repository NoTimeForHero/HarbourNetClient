/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez
 */

#include "minigui.ch"

MEMVAR OClient
MEMVAR hInstance
MEMVAR ForceClose

#define ACTION_ADD_USER "ADD_USER"
#define ACTION_LIST_USERS "LIST_USERS"
#define ACTION_NOT_FOUND "404_NOT_FOUND"
#define ACTION_LONG_TIME "LONG_TIME"
#define ACTION_TIMEOUT "TIMEOUT"
#define ACTION_ERROR "ERROR"

#define CLRF CHR(10) + CHR(13)

PROCEDURE Demo1()

	PUBLIC OClient := NIL
	PUBLIC ForceClose := .F.
	PUBLIC hInstance

	SET FONT TO 'Segoe UI', 14

	DEFINE WINDOW Win_1		;
		CLIENTAREA 800, 400	;
		TITLE 'HttpClientDemo'	;
		WINDOWTYPE MAIN         ;
		ON INIT OnInit() ;
		ON RELEASE OnRelease() ;

		@ 10,10 BUTTON BUTTON_1 ;
			CAPTION "List Users" ;
			ACTION MakeHttpRequest(ACTION_LIST_USERS) ;
			WIDTH 200 ;
			HEIGHT 60

		@ 10,220 BUTTON BUTTON_2 ;
			CAPTION "Add User" ;
			ACTION MakeHttpRequest(ACTION_ADD_USER) ;
			WIDTH 200 ;
			HEIGHT 60		

		@ 80,10 BUTTON BUTTON_3 ;
			CAPTION "Slow Request" ;
			ACTION MakeHttpRequest(ACTION_LONG_TIME) ;
			WIDTH 160 ;
			HEIGHT 40		
		
		@ 80,180 BUTTON BUTTON_4 ;
			CAPTION "Timeout" ;
			ACTION MakeHttpRequest(ACTION_TIMEOUT) ;
			WIDTH 160 ;
			HEIGHT 40					

		@ 80,350 BUTTON BUTTON_5 ;
			CAPTION "404 Not Found" ;
			ACTION MakeHttpRequest(ACTION_NOT_FOUND) ;
			WIDTH 160 ;
			HEIGHT 40			
		
		@ 80,520 BUTTON BUTTON_6 ;
			CAPTION "C# Error" ;
			ACTION MakeHttpRequest(ACTION_ERROR) ;
			WIDTH 160 ;
			HEIGHT 40				
		
		@ 140,10 BUTTON BUTTON_7 ;
			CAPTION "Get Image Info" ;
			ACTION MakeHttpRequest(ACTION_ERROR) ;
			WIDTH 240 ;
			HEIGHT 60					

		@ 320,10 BUTTON BUTTON_99 ;
			CAPTION "ForceClose" ;
			ACTION { || ForceClose := .T., ReleaseAllWindows() } ;
			WIDTH 200 ;
			HEIGHT 60

		DEFINE TIMER oTimerBlink
        	INTERVAL 1000
        	ACTION   { || OClient:DoHttpEvents() }
    	END TIMER

	END WINDOW

	Win_1.Center

	//Win_1.Activate
RETURN

STATIC FUNCTION OnInit()
  LOCAL cPath, hOptions
  hInstance := ThisWindow.Handle

  // hOptions := { "ClientTTL" => 10, "KeepAliveInterval" => 5, "Timeout" => 2}
  hOptions := { "Arguments" => "--hwnd=%HANDLE% --ttl=%TTL% --debug" }
  cPath := GetStartUpFolder() + "\NetClient\bin\Debug\NetClient.exe"

  OClient := HttpClient():New(hInstance, cPath, hOptions)
  ThisWindow.Title := ThisWindow.Title + " - " + ALLTRIM(STR(hInstance))
RETURN NIL

STATIC FUNCTION MakeHttpRequest(cAction) 
	// LOCAL xCallback := {|cCode, hResponse| MsgInfo(HB_JsonEncode({cCode, hResponse}, .T.)) }
	LOCAL hParams := HASH()
	LOCAL hDetails
	LOCAL xUser

	IF cAction == ACTION_LIST_USERS
		hParams["Url"] = "http://localhost:3000/users"
		hParams["Method"] = "GET"
		hParams["Headers"] = { "Content-Type" => "application/json"}
		OClient:Request(hParams, @OnListUsers())		
	ELSEIF cAction == ACTION_NOT_FOUND
		hParams["Url"] = "http://localhost:3000/not_found"
		hParams["Method"] = "GET"
		OClient:Request(hParams, @OnHttpAnswer())	
	ELSEIF cAction == ACTION_TIMEOUT
		hParams["Url"] = "http://localhost:3000/timeout"
		hParams["Method"] = "GET"
		hParams["Timeout"] = 2
		OClient:Request(hParams, @OnHttpAnswer())						
	ELSEIF cAction == ACTION_LONG_TIME
		hParams["Url"] = "http://localhost:3000/timeout"
		hParams["Method"] = "GET"
		hParams["Timeout"] = 20
		OClient:Request(hParams, @OnHttpAnswer())		
	ELSEIF cAction == ACTION_ERROR
		hParams["Url"] = "2dr32asdasd"
		hParams["Method"] = "APPLE"
		hParams["Timeout"] = 20
		OClient:Request(hParams, @OnHttpAnswer())		
	ELSEIF cAction == ACTION_ADD_USER
		// Encoding: Windows-1251
		xUser := InputBox ( 'Please enter user info with ; delimiters:' , 'User Info' , '11;Петр;Кузнецов;04.20.1952' )
		IF xUser == NIL .OR. LEN(xUser) == 0
			RETURN NIL
		ENDIF
		xUser := HB_ATokens(xUser, ";")
		IF LEN(xUser) < 4
			RETURN NIL
		ENDIF 
		hDetails := {"id" => xUser[1], "name" => xUser[2], "surname" => xUser[3], "birthdate" => xUser[4]}
		hParams["Url"] = "http://localhost:3000/users/add"
		hParams["Method"] = "POST"
		// Now it set this automatically if you pass to body HASH or ARRAY
		// hParams["Headers"] = { "Content-Type" => "application/json"}		
		hParams["Body"] = hDetails
		OClient:Request(hParams, @OnHttpAnswer())			
	ENDIF
RETURN NIL

STATIC FUNCTION OnListUsers(cStatus, cBody) 
	LOCAL cMessage
	IF cStatus != OClient:STATUS_SUCESS
		MsgStop("HTTP Request failed!2")
		RETURN NIL
	END
	// WARNING! You should manually check that server responding with JSON!
	cMessage := cBody
	cMessage := HB_JsonDecode(cMessage)
	cMessage := HB_JsonEncode(cMessage, .T.)
	MsgInfo(cMessage)
RETURN NIL

STATIC FUNCTION OnHttpAnswer(cStatus, cBody, hDetails)
	LOCAL cMessage
	IF cStatus == OClient:STATUS_ERROR
		MsgStop(HB_JsonEncode({hDetails}, .T.))
	ELSEIF cStatus == OClient:STATUS_TIMEOUT
		MsgExclamation("Timeout!")
	ELSEIF cStatus == OClient:STATUS_SUCESS
		cMessage := HB_JsonEncode({hDetails, cBody}, .T.)
		IF hDetails["Success"]
			MsgInfo(cMessage)
		ELSE
			MsgExclamation(cMessage)
		ENDIF
	ELSE
		MsgStop("Invalid status: " + cStatus)
	ENDIF
RETURN NIL

STATIC FUNCTION OnRelease
	IF ForceClose == .T.
		RETURN NIL
	ENDIF
	OClient:Release()
RETURN NIL

FUNCTION Win1_OnWmCopyData(nHandle, cData)
   IF nHandle != hInstance
		RETURN NIL
   ENDIF	
   OClient:OnMessage(cData)   
RETURN NIL