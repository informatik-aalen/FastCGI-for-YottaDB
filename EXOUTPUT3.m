EXOUTPUT3   ; Generates output using file / filename
    s f="/tmp/"_$j_".html" o f:newversion
    u f w "<html><head></head><body>"_$H_"</body></html>" c f
    s %fcgi("o","file")=f
