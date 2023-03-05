#include 'minigui.ch'
#include "hbclass.ch"


#define MSG_TYPE_LEN 4
#define MSG_PREFIX "AV_HTTP"
#define CLRF CHR(10) + CHR(13)

#define MESSAGE_INITIALIZE "INIT"
#define MESSAGE_RESPONSE "RESP"
#define MESSAGE_REQUEST "REQT"

#define STATUS_CREATED 1
#define STATUS_SENDED 2
#define STATUS_COMPLETED 3

CREATE CLASS HttpClient

    PROTECTED:
    VAR nOwnerWindow  
    VAR nInstance
    VAR nTargetWindow
    VAR hSendingRequest
    VAR hOptions
    VAR lDisposed
    METHOD Log(xMessage)

    EXPORTED: 
    METHOD New(nOwnerWindow, cPath, hOptions)
    METHOD OnMessage(cPayload)
    METHOD DoHttpEvents()
    METHOD Request(hParams, xCallback)
    METHOD Release()     
    DATA STATUS_SUCESS INIT "Success" READONLY
    DATA STATUS_ERROR INIT "Error" READONLY
    DATA STATUS_TIMEOUT INIT "Timeout" READONLY

ENDCLASS


METHOD New(nOwnerWindow, cPath, hOptions) CLASS HttpClient
    LOCAL cArguments
    LOCAL hDefaults 
    LOCAL oError
    ::nOwnerWindow := nOwnerWindow
    ::hSendingRequest := HASH()
    ::lDisposed := .F.    

    hDefaults := HASH()
    hDefaults["Arguments"] := "--hwnd=%HANDLE% --ttl=%TTL%"
    hDefaults["ClientTTL"] := 60
    // hDefaults["PingInterval"] := 5
    hDefaults["Timeout"] := 2
    hDefaults["Debug"] := .T.

    IF ValType(hOptions) != 'H'
        hOptions := HASH()
    ENDIF
    hOptions := HMerge(hOptions, hDefaults)
    ::hOptions := hOptions

    ::Log("Created new instance!")
    ::Log({nOwnerWindow, cPath, hOptions})

    IF FILE(cPath) != .T.
        oError := ErrorNew()
        oError:subsystem := "HttpClient"
        oError:description = "File not found!"
        Throw(oError)        
    ENDIF

    cArguments := hOptions["Arguments"]
    cArguments := StrTran(cArguments, "%HANDLE%", ALLTRIM(STR(nOwnerWindow)))
    cArguments := StrTran(cArguments, "%TTL%", ALLTRIM(STR(hOptions["ClientTTL"])))

    ::nInstance := ShellExecuteEx( 0, "open", cPath, cArguments, , SW_SHOWNORMAL )
RETURN SELF


METHOD Log(xMessage) CLASS HttpClient
    IF ::hOptions["Debug"] != .T.
        RETURN NIL
    ENDIF
    //#ifndef _HB_DEBUG
    ? HB_DATETIME(), "[HttpClient]", HB_JsonEncode(xMessage, .F.)
    // #end
RETURN NIL


METHOD Release() CLASS HttpClient
    TerminateProcess(::nInstance)
    ::nInstance := NIL
    ::nOwnerWindow := NIL
    ::hSendingRequest := HASH()
    ::lDisposed := .T.
    ::Log("Shutdown")
RETURN SELF


METHOD Request(hParams, xCallback) CLASS HttpClient
    LOCAL nKeyLen := 8
    LOCAL cKey := "", nI, oError
    LOCAL hRecord := HASH()

    IF ::lDisposed == .T.
        oError := ErrorNew()
        oError:subsystem := "HttpClient"
        oError:description = "Access to disposed object!"
        Throw(oError)        
    ENDIF

    FOR nI := 1 TO nKeyLen
        cKey := cKey + CHR(HB_RandomInt(0,255))
    NEXT
    cKey := hb_base64Encode(cKey)
    hRecord["Query"] := hParams
    hRecord["Callback"] := xCallback
    hRecord["Status"] := STATUS_CREATED
    // Old version:
    //hRecord["ExpiresIn"] := UNIXTIME() + ::hOptions["Timeout"]    
    ::hSendingRequest[cKey] := hRecord
    ::DoHttpEvents()
RETURN SELF

METHOD DoHttpEvents() CLASS HttpClient
    LOCAL nI, xItem, cData, cKey, aKeys
    LOCAL xTemp
    LOCAL nCurrentTime
    LOCAL xSendData
    //LOCAL cTemp

    IF ::nTargetWindow == NIL .OR. ::lDisposed == .T.
        RETURN SELF
    ENDIF

    cData := "DoHttpEvents: " + CLRF
    aKeys := HGetKeys(::hSendingRequest)
    FOR nI := 1 TO LEN(aKeys)
        cKey := aKeys[nI]
        // If key was removed by another loop
        IF !HHasKey(::hSendingRequest, cKey)
            LOOP
        ENDIF
        xItem := ::hSendingRequest[cKey]

        DO CASE
            CASE xItem["Status"] == STATUS_CREATED
                xSendData := {"Key" => cKey, "Query" => xItem["Query"]}
                xSendData := HB_JsonEncode(xSendData, .T.)
                xSendData := MSG_PREFIX + MESSAGE_REQUEST + xSendData
                SendMessageData(::nTargetWindow, xSendData)     
                xItem["ExpiresTime"] := UNIXTIME() + ::hOptions["Timeout"]                           
                xItem["Status"] := STATUS_SENDED
                ::Log({"Sending new request: ", xItem})
            CASE xItem["Status"] == STATUS_SENDED
                nCurrentTime := UNIXTIME()
                IF nCurrentTime > xItem["ExpiresTime"]
                    HDel(::hSendingRequest, cKey)                    
                    ::Log({"Request expired: ", cKey})                                        

                    xTemp := {"Message" => "No answer recieved in SendMessage in specific timeout!"}
                    Do(xItem["Callback"], ::STATUS_TIMEOUT, xTemp)
                ENDIF
            CASE xItem["Status"] == STATUS_COMPLETED
                HDel(::hSendingRequest, cKey)                
                ::Log({"Request completed: ", cKey})                
                ::Log(xItem["Response"])

                Do(xItem["Callback"], xItem["Response"]["Type"], xItem["Response"]["Data"])
        ENDCASE

        cData := cData + cKey + ": " + HB_JsonEncode(xItem) + CLRF
    NEXT
RETURN SELF

METHOD OnMessage(cPayload) CLASS HttpClient

    LOCAL cType, cBody, cKey
    LOCAL nSize
    LOCAL nMinLength := LEN(MSG_PREFIX) + MSG_TYPE_LEN

    IF ::lDisposed == .T.
        RETURN .F.
    ENDIF

    IF LEN(cPayload) <= nMinLength
        RETURN .F.
    ENDIF

    IF SUBSTR(cPayload, 1, LEN(MSG_PREFIX)) != MSG_PREFIX
        RETURN .F.
    ENDIF

    nSize := 1 + LEN(MSG_PREFIX)
    cType := SUBSTR(cPayload, nSize, MSG_TYPE_LEN)

    nSize := nSize + MSG_TYPE_LEN
    cBody := SUBSTR(cPayload, nSize, LEN(cPayload) - nSize + 1)

    do case
    case cType == MESSAGE_INITIALIZE
       ::nTargetWindow = VAL(cBody)
       ::Log("Initialized with child HWND: " + cBody)
    case cType == MESSAGE_RESPONSE
       cBody := hb_jsonDecode(cBody)
       cKey := cBody["Key"]
       IF HHasKey(::hSendingRequest, cKey)
        ::hSendingRequest[cKey]["Status"] = STATUS_COMPLETED
        ::hSendingRequest[cKey]["Response"] = cBody
       ENDIF
    endcase
    ::DoHttpEvents()    

RETURN .T.

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>
#include <shlobj.h>
#include <time.h>

HB_FUNC( TERMINATEPROCESS ) {
  hb_retni( (BOOL) TerminateProcess( (HANDLE) hb_parni(1),0) );
}

HB_FUNC( UNIXTIME ) {
    hb_retnl(time(NULL));
}

#pragma ENDDUMP
