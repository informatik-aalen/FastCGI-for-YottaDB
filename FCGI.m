FCGI ;; Fastcgi-Interface
    ;; Written by Winfried Bantel
    ;; Published under Gnu Public License 2018
    s version=20190405
    ;
    ; Now start all backendjobs and supervise them
    ; If a backend-job crashes it will be restarted latest after
    ;s $ZTRAP="s f=""/tmp/fastcgi-""_$J_"".log"" o f:(append) u f w $zerror,!,$zstatus,! h"
    ;s $ETRAP="d ETRAP^FCGI h"
    s $ztrap="g ETRAP^FCGI"
    ;
    s nr=0,log=+$G(^FCGI("PRM","LOG")),to=$S($G(^FCGI("PRM","LOG"))>0:^("LOG"),1:60)
    d:log log("start") s nr=0
input      ;
    i $$readrecord(.t,.id,.data)<0 d:log log("fini "_$J) q
    d:log log(t_":"_id_":"_$L(data))
    i t=1 d  g input
    . k %fcgi
    . s nr=nr+1,%fcgi("internal","FCGI_KEEP_CONN")=$A(data,3)
    . s %fcgi("internal","requestId")=id
    . d:log log("Keep-conn: "_%fcgi("internal","FCGI_KEEP_CONN"))
    e  i t=4 d  g input
    . s %fcgi("i","params")=$G(%fcgi("i","params"))_data q:$L(data)
    . s pos=1 f  q:pos>$L(%fcgi("i","params"))  do
    . . s l1=$A(%fcgi("i","params"),pos),l2=$A(%fcgi("i","params"),pos+1),ll=2
    . . i l2>127 s l2=$A(%fcgi("i","params"),pos+3)*256+$A(%fcgi("i","params"),pos+4),ll=5
    . . ; Bisher max. Länge 65 KB
    . . s t1=$E(%fcgi("i","params"),pos+ll,pos+ll+l1-1)
    . . s t2=$E(%fcgi("i","params"),pos+ll+l1,pos+ll+l1+l2-1)
    . . s %fcgi("i","header",t1)=t2
    . . s pos=pos+l1+l2+ll
    . k %fcgi("i","params")
    i t=5,$L(data)>0 d  g input
    . s %fcgi("i","stdin")=$G(%fcgi("i","stdin"))_data q
    ;
    ; Jetzt sind alle Daten da

    s %fcgi="/tmp/fcgi-fifo-"_$J o %fcgi:(newversion:stream:nowrap)
    i $G(%fcgi("i","header","HTTP_CONTENT_TYPE"))="application/x-www-form-urlencoded",$G(%fcgi("i","stdin"))'="" d HTMLVARDECODE(%fcgi("i","stdin"),"%fcgi(""i"",""_POST"")")
    i %fcgi("i","header","QUERY_STRING")'="" d HTMLVARDECODE(%fcgi("i","header","QUERY_STRING"),"%fcgi(""i"",""_GET"")")
    s %fcgi("o","header","x-ydb-nr")=nr,%fcgi("o","header","x-ydb-job")=$j,%fcgi("o","header","x-ydb-fcgiversion")=version
    ;
    ; Jetzt auf Programme verteilen
    s %fcgi("internal","entryRef")=$G(^FCGI("DOCUMENT_URI",$P(%fcgi("i","header","DOCUMENT_URI"),"/",1,3)))
    i %fcgi("internal","entryRef")'="" d
    . i $G(^FCGI("PRM","ZLINK"))=1,%fcgi("internal","entryRef")["^" zl $P(%fcgi("internal","entryRef"),"^",2)
    . n (%fcgi) u %fcgi d @%fcgi("internal","entryRef")
    e  s (%fcgi("o","header","Status"),%fcgi("o","stdout"))="404 Not Found"
    ;
OUT ; Header vervollstaendigen und ausgeben
    i $G(%fcgi("o","noout")) g OUTEND
    ;
    i $D(%fcgi("o","stdout"))=1 d  ; Eine Ausgabezeile
    . s %fcgi("o","header","Content-Length")=$L(%fcgi("o","stdout")) d HEADEROUT
    . f i=0:1 q:$E(%fcgi("o","stdout"),65535*i+1)=""  d DATAOUT($E(%fcgi("o","stdout"),65535*i+1,65535*(i+1)))

    e  i $D(%fcgi("o","stdout"))=10 d  ; Mehrere Zeilen
    . s ind="",l=0 f  s ind=$O(%fcgi("o","stdout",ind)) q:ind=""  s l=l+$L(%fcgi("o","stdout",ind))
    . s %fcgi("o","header","Content-Length")=l d HEADEROUT
    . s ind="" f  s ind=$O(%fcgi("o","stdout",ind)) q:ind=""  d
    . . f i=0:1 q:$E(%fcgi("o","stdout",ind),65535*i+1)=""  d DATAOUT($E(%fcgi("o","stdout",ind),65535*i+1,65535*(i+1)))
                                 
    e  i $G(%fcgi("o","file"))'="" d  ; File
    . s t=$P(%fcgi("o","file"),".",$L(%fcgi("o","file"),"."))
    . i t'="",$D(^FCGI("MIMETYPE",t)) s %fcgi("o","header","Content-Type")=^(t)
    . o %fcgi("o","file"):(append:seek="-1") u %fcgi("o","file") r in#1 s %fcgi("o","header","Content-Length")=$zkey c %fcgi("o","file")
    . d HEADEROUT
    . o %fcgi("o","file"):(readonly:fixed:NOWRAP)
    . f i=1:1 u %fcgi("o","file") r in#65535 q:$A(in)<0  d DATAOUT(in)
    . c %fcgi("o","file")

    e  i $G(%fcgi("o","glo"))'="" d  ; Input is a global;
    . s %fcgi("o","header","Content-Length")=$L(@%fcgi("o","glo")) d HEADEROUT,DATAOUT(@%fcgi("o","glo"))

    e  d ; %fcgi
    . c %fcgi
    . i $G(^FCGI("PRM","GZ"))=1 s %fcgi("o","header","Content-Encoding")="gzip" zsystem "gzip -f "_%fcgi s %fcgi=%fcgi_".gz"
    . o %fcgi:(fixed:append)
    . u %fcgi:(width=1:seek="-0") s %fcgi("o","header","Content-Length")=+$ZKEY
    . d HEADEROUT
    . u %fcgi:(WIDTH=65535:rewind)
    . f i=1:1 u %fcgi r in#65535 q:$A(in)<0  d DATAOUT(in)
    u 0 c %fcgi:delete
    ;
OUTEND  ;
    d DATAOUT("")
    u 0:FLUSH w $C(1,3,0,1,0,8,0,0),$C(0,0,0,0,0,0,0,0) u 0:FLUSH
    i '%fcgi("internal","FCGI_KEEP_CONN") h
    g input
                                                                
ETRAP   ;
    ;s ^dummy=$H_" "_$ZERROR_" "_$ZSTATUS
    d:log log($H_" "_$ZERROR_" "_$ZSTATUS)
    ;d DATAOUT("Content-Type: text/plain"_$C(13,10,13,10)_"EROR")
    d DATAOUT("Content-Type: text/plain"_$C(13,10,13,10)_$ZERROR_$C(13,10)_$ZSTATUS_$C(13,10))
    w $C(1,3,0,1,0,8,0,0),$C(0,0,0,0,0,0,0,0)
    h
    ;
log(txt)
    n (txt)
    s f="/tmp/fastcgi.log" o f:(append)
    u f w $h,",",txt,! u 0 c f
    q

readrecord(type,requestId,contentData)
    n (type,requestId,contentData,to)
    u 0 r *version:to e  q -1
    r *type:1 e  q -1
    r *requestIdB1:1 e  q -1
    r *requestIdB0:1 e  q -1
    r *contentLengthB1:1 e  q -1
    r *contentLengthB0:1 e  q -1
    r *paddingLength:1 e  q -1
    r *reserved:1 e  q -1
    s requestId=256*requestIdB1+requestIdB0
    s contentLength=256*contentLengthB1+contentLengthB0
    s contentData="" i contentLength r contentData#contentLength:1 e  q -1
    s paddingData="" i paddingLength r paddingData#paddingLength:1 e  q -1
    q 0

HEADEROUT   ;
    n ind,txt s (ind,txt)=""
    f  s ind=$O(%fcgi("o","header",ind)) q:ind=""  s txt=txt_ind_": "_%fcgi("o","header",ind)_$C(13,10)
    d DATAOUT(txt_$C(13,10))
    q

DATAOUT(in) ; Schreibt Satz 6: FCGI_STDOUT
    u 0 w $C(1,6,%fcgi("internal","requestId")\256,%fcgi("internal","requestId")#256,$L(in)\256,$L(in)#256,0,0),in
    q
    ;
HTMLVARDECODE(data,var)  ; Decodiert nach HTML-Variablen-Standard
    n l,i,ind,val,t,dummy
    s l=$L(data,"&") f i=1:1:l s t=$P(data,"&",i) d
    . s ind=$$CONVERT($P(t,"=")),val=$$CONVERT($P(t,"=",2))
    . i $L(ind) s dummy(ind)=val
    m @var=dummy
    q

CONVERT(t)	;
    n (t)
    s t=$TR(t,"+"," "),p=0
    f  s p=$F(t,"%",p) q:p<1  s t=$E(t,1,p-2)_$C($$HEX2DEZ($E(t,p,p+1)))_$E(t,p+2,255)
    q t

HEX2DEZ(dez)	;
    n (dez) s hex=0,dez=$TR(dez,"abcdef","ABCDEF")
    f i=1:1:$L(dez) s hex=hex*16+$s($A(dez,i)>59:$A(dez,i)-55,1:$E(dez,i))
    q hex

DOLLARH  ;
    s %fcgi("o","header","Content-Type")="text/plain"
    ;s %fcgi("o","stdout")=$H
    w $h,!
    q

SID() i $G(%fcgi("i","header","SID"))'?1.N1","1.N d  q 0
    . s %fcgi("o","header","Status")="302 Not Found",%fcgi("o","stdout")="SID ERROR"
    . s %fcgi("o","header","Location")=$G(%fcgi("i","header","DOCUMENT_URI"))_"?"_$G(%fcgi("i","header","QUERY_STRING"))
    . s %fcgi("o","header","Set-Cookie")="SID="_(+$tr($random(1000000000)_$J($random(1000000000),9)," ",0))_",1; path=/"
    . ; ToDo: Hier tracken
    s %fcgi("o","header","Set-Cookie")="SID="_$P(%fcgi("i","header","SID"),",")_","_($P(%fcgi("i","header","SID"),",",2)+1)_"; path=/"
    ; ToDo: Hier tracken!
    q 1

LOGIN(user,pass)   ; Erzwingt HTTP-Authorisierung OHNE check!
    ; Aufruf web 2.0: /LOGIN.m und user / pass für XMLHTTPREQUEST setzen
    ; Aufruf direkt: d LOGIN^FCGI(.ok) und dann ok auswerten
    n (user,pass,%fcgi)
    s up=$$BASE64DECODE($P($G(%fcgi("i","header","HTTP_AUTHORIZATION"))," ",2))
    i up'="" s user=$P(up,":"),pass=$P(up,":",2)
    i $G(user)="" d  q
    . s %fcgi("o","header","WWW-Authenticate")="Basic realm=""WB"""
    . s %fcgi("o","header","Status")="401 Unauthorized"
    s %fcgi("o","header","Content-Type")="text/plain"
    i $G(%fcgi("i","_GET","check"))>0 w $$check^FCGILOGIN(user,pass,.groups)
    q

BASE64DECODE(txt)   ;
    n (txt)
    s l=$L(txt),n=l\4,res="" f i=0:1:n-1 d
    . s c0=$$base64char2bits($E(txt,i*4+1)),c1=$$base64char2bits($E(txt,i*4+2))
    . s c2=$$base64char2bits($E(txt,i*4+3)),c3=$$base64char2bits($E(txt,i*4+4))
    . i c0>=0,c1>=0 s res=res_$C((c0*4)+(c1\16))
    . i c1>=0,c2>=0 s res=res_$C((c1#16*16)+(c2\4))
    . i c2>=0,c3>=0 s res=res_$C((c2#4*64)+(c3))
    q res
base64char2bits(c)  ;
    q:$A(c)>=$A("A")&($A(c)<=$A("Z")) $A(c)-$A("A");
    q:$A(c)>=$A("a")&($A(c)<=$A("z")) $A(c)-$A("a")+26;
    q:$A(c)>=$A("0")&($A(c)<=$A("9")) $A(c)-$A("0")+52;
    q:c="+" 62 q:c="/" 63
    q -1
record(type,data)   ; Not used
    w $C(1,type,requestIdB1,requestIdB0,$L(data)\256,$L(data)#256,0,0)_data
    q
