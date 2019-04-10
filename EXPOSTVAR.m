EXPOSTVAR   ;
    w "<html><head></head><body>"
    i $G(%fcgi("i","_POST","name"))="" d
    . w "You did't enter a name"
    e  w "Hello ",%fcgi("i","_POST","name"),"!"
    w "<form method=""POST"">",!
    w "<input type=""text"" name=""name"">",!
    w "<input type=""submit"" value=""Submit"">",!
    w "</form></body></html>"
