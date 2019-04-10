EXSID   ; Generates output using %fcgi
    q:'$$SID^FCGI()  s sid=%fcgi("i","header","SID")
    w "<html><head></head><body>"
    w "Your Session-ID is ",+sid,"<br>",!
    w "Your Session-count is ",$P(sid,",",2),"<br>",!
    w "Your last visit ($H) was: ",$G(^dummy(+sid)),"<br>",!
    s h=$H w "Now $H is: ",h,"<br>",!
    s ^dummy(+sid)=h
    w "<br>Feel free to reload!"
    w "<br><a href=""javascript:location.reload()"">Reload</a>"
    w "</body></html>"
