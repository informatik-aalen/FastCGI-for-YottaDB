EXSETHEADER   ; Generates output using %fcgi
    s %fcgi("o","header","Content-Type")="application/json"
    s %fcgi("o","header","X-greeting")="Hello from YottaDB!"
    s %fcgi("o","header","X-HOROLOG")=$H
    w "{""$H"":"""_$H_""",""$J"":"""_$J_"""}"
