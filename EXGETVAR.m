EXGETVAR   ; 
    w "<html><head></head><body>"
    i $G(%fcgi("i","_GET","name"))="" d
    . w "You did't enter a name"
    e  w "Hello ",%fcgi("i","_GET","name"),"!"
    w "<form method=""GET"">",!
    w "<input type=""text"" name=""name"">",!
    w "<input type=""submit"" value=""Submit"">",!
    w "</form></body></html>"
