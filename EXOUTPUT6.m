EXOUTPUT6 ; Direct Output

    ; Step 1: optional
    s %fcgi("o","header","Content-Type")="text/plain"

    ; Step 2: mandatory
    d HEADEROUT^FCGI

    ; Step 3: optional
    f i=1:1:5 d DATAOUT^FCGI("Line "_i_$C(10,13)) h 1

    ; Step 4: mandatory
    s %fcgi("o","noout")=1

    q
