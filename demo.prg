/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez
 */

#include "minigui.ch"

MEMVAR OClient
MEMVAR ForceClose

#define ACTION_ADD_USER "ADD_USER"
#define ACTION_LIST_USERS "LIST_USERS"
#define ACTION_NOT_FOUND "404_NOT_FOUND"
#define ACTION_TIMEOUT "TIMEOUT"

PROCEDURE Main

	PUBLIC OClient := NIL
	PUBLIC ForceClose := .F.

	SET EVENTS FUNCTION TO MyEvents
	SET FONT TO 'Segoe UI', 14

	DEFINE WINDOW Win_1		;
		CLIENTAREA 800, 400	;
		TITLE 'HttpClientDemo'	;
		WINDOWTYPE MAIN         ;
		ON INIT OnInit( App.Handle ) ;
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
			CAPTION "Timeout" ;
			ACTION MakeHttpRequest(ACTION_TIMEOUT) ;
			WIDTH 200 ;
			HEIGHT 60				

		@ 80,220 BUTTON BUTTON_4 ;
			CAPTION "404 Not Found" ;
			ACTION MakeHttpRequest(ACTION_NOT_FOUND) ;
			WIDTH 200 ;
			HEIGHT 60					

		@ 320,10 BUTTON BUTTON_5 ;
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

	Win_1.Activate
RETURN

FUNCTION OnInit(nHandle)
  LOCAL cPath, hOptions
  LOCAL cHandle := ALLTRIM(STR(nHandle))
  LOCAL cSelfHandle := ALLTRIM(STR(ThisWindow.Handle))

  hOptions := { "ClientTTL" => 10, "KeepAliveInterval" => 5}
  cPath := GetStartUpFolder() + "\NetClient\bin\Debug\NetClient.exe"
  OClient := HttpClient():New(nHandle, cPath, hOptions)
RETURN NIL

FUNCTION MakeHttpRequest(cAction) 
	// LOCAL xCallback := {|cCode, hResponse| MsgInfo(HB_JsonEncode({cCode, hResponse}, .T.)) }
	LOCAL hParams := HASH()
	LOCAL hBody
	LOCAL xUser

	IF cAction == ACTION_LIST_USERS
		hParams["Url"] = "http://localhost:3000/users"
		hParams["Method"] = "GET"
		hParams["Headers"] = { "Content-Type" => "application/json"}
		OClient:Request(hParams, @OnListUsers())		
	ELSEIF cAction == ACTION_ADD_USER
		// Encoding: Windows-1251
		xUser := InputBox ( 'Please enter user info with ; delimiters:' , 'User Info' , '11;����;��������;04.20.1952' )
		IF xUser == NIL .OR. LEN(xUser) == 0
			RETURN NIL
		ENDIF
		xUser := HB_ATokens(xUser, ";")
		IF LEN(xUser) < 4
			RETURN NIL
		ENDIF 
		hBody := {"id" => xUser[1], "name" => xUser[2], "surname" => xUser[3], "birthdate" => xUser[4]}
		hParams["Url"] = "http://localhost:3000/users/add"
		hParams["Method"] = "POST"
		hParams["Headers"] = { "Content-Type" => "application/json"}		
		hParams["Body"] = hBody
		// hParams["Body"] = HB_JsonEncode(hBody, .T.)
		OClient:Request(hParams, @OnHttpAnswer())	
	ELSEIF cAction == ACTION_NOT_FOUND
		hParams["Url"] = "http://localhost:3000/not_found"
		hParams["Method"] = "GET"
		hParams["Headers"] = { "Content-Type" => "application/json"}
		OClient:Request(hParams, @OnHttpAnswer())				
	ELSEIF cAction == ACTION_TIMEOUT
		hParams["Url"] = "http://localhost:3000/timeout"
		hParams["Method"] = "GET"
		hParams["Headers"] = { "Content-Type" => "application/json"}
		OClient:Request(hParams, @OnHttpAnswer())				
	ENDIF
RETURN NIL

FUNCTION OnListUsers(cStatus, hBody) 
	LOCAL cMessage
	IF cStatus != OClient:STATUS_SUCESS
		MsgStop("HTTP Request failed!")
	END
	cMessage := hBody["Response"]
	cMessage := HB_JsonDecode(cMessage)
	cMessage := HB_JsonEncode(cMessage, .T.)
	MsgInfo(cMessage)
RETURN NIL

FUNCTION OnHttpAnswer(cStatus, hBody)
	IF cStatus == OClient:STATUS_ERROR
		MsgStop(HB_JsonEncode({hBody}, .T.))
	ELSEIF cStatus == OClient:STATUS_TIMEOUT
		MsgExclamation("Timeout!")
	ELSEIF cStatus == OClient:STATUS_SUCESS
		MsgInfo(HB_JsonEncode({hBody}, .T.))
	ELSE
		MsgStop("Invalid status: " + cStatus)
	ENDIF
RETURN NIL

FUNCTION OnRelease
	IF ForceClose == .T.
		RETURN NIL
	ENDIF
	OClient:Release()
RETURN NIL

FUNCTION OnWmCopyData(cData)
   OClient:OnMessage(cData)   
RETURN NIL
