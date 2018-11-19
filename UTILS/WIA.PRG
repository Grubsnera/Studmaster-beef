//WIA.PRG
//Program om stoetmeester bees waar is dier kodes te verander
//11-08-94 02:21pm
local cWaar

//Omgewing
set date brit
set conf off
clear screen

@ 1, 0 say "Where-is-animal codes"
@ 2, 0 say "====================="

//Open dbf
use stdwaar
cWaar := stdwaar->velded
close all
use sm3data

//Loop
do while !eof()

   @ 4, 2 say "Record # " + ltrim(str(recno()))

   do case

      case SM3DATA->uitkrede $ cWaar
         SM3DATA->uitkrede := "  "
      otherwise

   endcase

   skip

enddo

dbcloseall()

return NIL
