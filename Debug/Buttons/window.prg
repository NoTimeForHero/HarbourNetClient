/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez
 */

#include "minigui.ch"

MEMVAR OClient

PROCEDURE Main

	PUBLIC OClient := NIL

//	SET EVENTS FUNCTION TO MyEvents
	SET FONT TO 'Segoe UI', 14

	DEFINE WINDOW Win_1		;
		CLIENTAREA 400, 400	;
		TITLE 'HttpClientDemo'	;
		WINDOWTYPE MAIN         ;
		//ON INIT OnInit( App.Handle ) ;
		//ON RELEASE OnRelease() ;

		@ 100,10 BUTTON BUTTON_1 ;
			CAPTION "Send HTTP request" ;
			ACTION MsgInfo("Hello world!") ;
			WIDTH 120 ;
			HEIGHT 60


		@ 200,10 BUTTON BUTTON_2 ;
			CAPTION "Send HTTP request" ;
			ACTION MsgInfo("Hello world!") ;
			WIDTH 120 ;
			HEIGHT 60		

	END WINDOW

	Win_1.Center

	Win_1.Activate
RETURN

FUNCTION OnInit(nHandle)
RETURN NIL

FUNCTION MakeTestRequest() 
	//MsgInfo("Click->MakeTestRequest")
RETURN NIL

FUNCTION OnRelease
RETURN NIL

FUNCTION OnWmCopyData(cData)
RETURN NIL
