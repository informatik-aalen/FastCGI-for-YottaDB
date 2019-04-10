EXSSE ; SSE-Schnittstelle
    s %fcgi("o","header","Content-Type")="text/event-stream;charset=UTF-8"
    d HEADEROUT^FCGI
    f i=1:1:1000000 d
    . s txt2send=i_": "_$H
    . d DATAOUT^FCGI("data: "_txt2send_$C(13,10,13,10))
    . h 1
    s %fcgi("o","noout")=1
    q
