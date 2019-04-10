EXAUTHBASIC    ;
    s up=$G(%fcgi("i","header","HTTP_AUTHORIZATION"))
    s up=$$BASE64DECODE^FCGI($P(up," ",2))
    i up'="W:B" d  q  ; User must be W, password B
    . s %fcgi("o","header","status")="401 Unauthorized"
    . s %fcgi("o","header","WWW-Authenticate")="Basic realm=""ydb"""
    . w "<html><head><head><body>401 Unauthorized</body></html>"

    w "<html><head><head><body>This is secret</body></html>"
    q
