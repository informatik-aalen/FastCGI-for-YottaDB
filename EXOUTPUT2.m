EXOUTPUT2   ; Generates output using global
    s ^dummy="<html><head></head><body>"_$H_"</body></html>"
    s %fcgi("o","glo")="^dummy"
