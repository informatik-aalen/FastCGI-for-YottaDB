EXOUTPUT5   ; Generate output using array
    s %fcgi("o","stdout",1)="<html>"
    s %fcgi("o","stdout",2)="<head></head>"
    s %fcgi("o","stdout",3)="<body>"_$H_"</body>"
    s %fcgi("o","stdout",4)="</html>"
