EXANGULARJS   ; A very very simple REST-Interface
    s %fcgi("o","header","Content-Type")="application/json"
    s id=+$P(%fcgi("i","header","DOCUMENT_URI"),"/",4)
    i id<=0 w "{""ERROR"":1}" q

    i %fcgi("i","header","REQUEST_METHOD")="PUT" d
    . s ^EXANGULARJS(id)=%fcgi("i","stdin")
    . w "{""ERROR"":0,""ERRTXT"":""OK"",""ID-WRITTEN"":"""_id_"""}"
    e  d
    . w $S($D(^EXANGULARJS(id)):^(id),1:"{}")
