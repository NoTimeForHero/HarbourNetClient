#include "minigui.ch"

MEMVAR OClient2
STATIC hInstance
STATIC aCats

#define ACTION_LOAD 'LOAD'
#define ACTION_SELECTED 'SELECTED'
#define ACTION_ADD 'ADD'
#define ACTION_REMOVE "REMOVE"
 
#define CLRF CHR(10) + CHR(13)
#define WM_COPYDATA 74

#define URL_PREFIX "http://localhost:3000"

#define FO_READ 0
#define FS_SET 0
#define FS_END 2
 
 PROCEDURE Demo2()
 
     PUBLIC OClient2 := NIL
     PUBLIC hInstance
     PUBLIC aCats
 
     SET EVENTS FUNCTION TO Win2Events
     SET FONT TO 'Segoe UI', 14
 
     DEFINE WINDOW Win_2		;
         CLIENTAREA 800, 400	;
         TITLE 'HttpClientDemo2'	;
         WINDOWTYPE CHILD         ;
         ON INIT OnInit() ;
         ON RELEASE OnRelease() ;

         DEFINE LISTBOX ListBoxCats
            ROW 10
            COL 10
            WIDTH 300
            HEIGHT 380
            ONCHANGE RunRequest(ACTION_SELECTED, Win_2.ListBoxCats.Value)                     
         END LISTBOX

         @ 10, 310 IMAGE ImgCat PICTURE "" WIDTH 300 HEIGHT 300

         @ 350,320 BUTTON BUTTON_1 ;
			CAPTION "Add/Edit" ;
			ACTION RunRequest(ACTION_ADD) ;
			WIDTH 180 ;
			HEIGHT 40
         
         @ 350,510 BUTTON BUTTON_2 ;
			CAPTION "Remove" ;
			ACTION RunRequest(ACTION_REMOVE, Win_2.ListBoxCats.Value) ;
			WIDTH 180 ;
			HEIGHT 40         
 
         DEFINE TIMER oTimerBlink
             INTERVAL 1000
             ACTION   { || OClient2:DoHttpEvents() }
         END TIMER
 
     END WINDOW
 
     Win_2.Center
 RETURN
 
 STATIC FUNCTION OnInit()
   LOCAL cPath, hOptions
   hInstance := ThisWindow.Handle   
 
   // hOptions := { "ClientTTL" => 10, "KeepAliveInterval" => 5, "Timeout" => 2}
   hOptions := { "Arguments" => "--hwnd=%HANDLE% --ttl=%TTL%" }
   cPath := GetStartUpFolder() + "\NetClient\bin\Debug\NetClient.exe"

   OClient2 := HttpClient():New(hInstance, cPath, hOptions)
   ThisWindow.Title := ThisWindow.Title + " - " + ALLTRIM(STR(hInstance))
   RunRequest(ACTION_LOAD)
 RETURN NIL

 STATIC FUNCTION RunRequest(cAction, xDetails)
    LOCAL hParams := HASH()

    IF cAction == ACTION_LOAD
		hParams["Url"] = URL_PREFIX + "/cats"
		hParams["Method"] = "GET"
		OClient2:Request(hParams, @OnCatsLoaded())		
    ELSEIF cAction == ACTION_SELECTED
        IF xDetails < 1
            RETURN NIL
        ENDIF
		hParams["Url"] = URL_PREFIX + aCats[xDetails]["image"]
		hParams["Method"] = "GET"        
        hParams["BinaryResponse"] = .T.
		OClient2:Request(hParams, @OnDownloadImage())		        
    ELSEIF cAction == ACTION_REMOVE
		hParams["Url"] = URL_PREFIX + "/cats/" + ALLTRIM(STR(aCats[xDetails]["id"]))
		hParams["Method"] = "DELETE"
        OClient2:Request(hParams, @OnItemRemoved())		        
    ELSEIF cAction == ACTION_ADD
        AddFile(hParams)
        OClient2:Request(hParams, @OnFileAdded())		  
    ENDIF    
 RETURN NIL 

 STATIC FUNCTION AddFile(hParams)
    LOCAL cFile, cName
    LOCAL cStream, nFileSize, nHandle
    LOCAL cDefaultName := 'Oliver'
    IF Win_2.ListBoxCats.Value > 0
       cDefaultName := aCats[Win_2.ListBoxCats.Value]["name"]
    ENDIF
    cName := InputBox ( 'Please enter a your cat name' , 'Cat Name' , cDefaultName )
    IF LEN(cName) < 1
        RETURN NIL
    ENDIF
    cFile := GetFile({{'JPEG', '*.jpg'}, {'PNG', '*.png'}, {'All files', '*.*'}}, 'Open a cat picture', , , .T.)
    IF LEN(cFile) < 1
        RETURN NIL
    ENDIF
    nHandle := FOpen(cFile, FO_READ)
    IF FError() <> 0
        MsgStop("File open failed!")
        RETURN NIL
    ENDIF
    nFileSize := FSeek( nHandle, 0, FS_END )
    cStream := Space(nFileSize)
    FSeek(nHandle, 0, FS_SET)
    FRead(nHandle, @cStream, nFileSize)
    FClose(nHandle)    
    hParams["Url"] = URL_PREFIX + "/cats/upload?test=23"
    hParams["Query"] =  { "name" => cName }
    hParams["Method"] = "POST"
    hParams["BinaryRequest"] = .T.
    hParams["Body"] = cStream
 RETURN NIL    

 STATIC FUNCTION OnFileAdded(cStatus, cResponse, hDetails) 
    IF cStatus != OClient2:STATUS_SUCESS
		MsgDebug({cStatus, cResponse, hDetails})
		RETURN NIL
	END
    RunRequest(ACTION_LOAD)  
    IF Win_2.ListBoxCats.Value > 0
        RunRequest(ACTION_SELECTED, Win_2.ListBoxCats.Value)
    ENDIF
 RETURN NIL

 STATIC FUNCTION OnItemRemoved(cStatus, cResponse)
    IF cStatus != OClient2:STATUS_SUCESS
		MsgStop("HTTP Request failed!")
		RETURN NIL
	END
    RunRequest(ACTION_LOAD)    
    MsgInfo(cResponse)
 RETURN NIL

 STATIC FUNCTION OnDownloadImage(cStatus, cResponse)
    LOCAL cPath
    LOCAL nHandle
    IF cStatus != OClient2:STATUS_SUCESS
		MsgStop("HTTP Request failed!")
		RETURN NIL
	END
    cPath := GetCurrentFolder() + "\temp"
    IF !IsDirectory(cPath)
        MakeDir(cPath)
    ENDIF
    cPath := cPath + "\test.jpg"

    nHandle := FCreate(cPath)
    IF FError() <> 0
        MsgStop("File create failed!")
        RETURN NIL
    ENDIF
    FWrite(nHandle, cResponse, LEN(cResponse))
    FClose(nHandle)
    Win_2.ImgCat.Picture := cPath
 RETURN NIL

 STATIC FUNCTION OnCatsLoaded(cStatus, cResponse)
    LOCAL nI, xItem
	IF cStatus != OClient2:STATUS_SUCESS
		MsgStop("HTTP Request failed!")
		RETURN NIL
	END
    aCats := HB_JsonDecode(cResponse)
    Win_2.ListBoxCats.DeleteAllItems
    FOR nI := 1 TO LEN(aCats)
        xItem := aCats[nI]
        Win_2.ListBoxCats.AddItem(xItem["name"])
    NEXT
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