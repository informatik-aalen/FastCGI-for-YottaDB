EXSTDIN   ;
    ; > curl ip-address:port/ydb/EXPOSTVAR -d "Hallo Welt!"
    ; > curl ip-address:port/ydb/EXPOSTVAR -d @file.txt
    ; Or a Browser-form with method post:
    ; <form action="/ydb/EXPOSTVAR" method="POST">...</form>
    w "<html><head></head><body>Your Post-Data is<pre>"
    w $G(%fcgi("i","stdin"))
    w "</pre></body></html>",!
