LOCAL nSize, cType, cBody
LOCAL cPrefix, cType, cBody
LOCAL nMinLength := LEN(MSG_PREFIX) + MSG_TYPE_LEN    
LOCAL nOffset := 1

IF LEN(cPayload) <= nMinLength
    RETURN NIL
ENDIF

cPrefix := SUBSTR(cPayload, nOffset, LEN(MSG_PREFIX))

IF SUBSTR(cPayload, 1, LEN(MSG_PREFIX)) != MSG_PREFIX
    RETURN NIL
ENDIF

nSize := 1 + LEN(MSG_PREFIX)
cType := SUBSTR(cPayload, nSize, MSG_TYPE_LEN)

nSize := nSize + MSG_TYPE_LEN
cBody := SUBSTR(cPayload, nSize, LEN(cPayload) - nSize + 1)