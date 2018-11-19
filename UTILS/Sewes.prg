// SEWES.PRG
// Program om stoetmeester bees waar is dier kodes te verander
// en diere met die naam "A" in kudde te sit
// 03-09-00 12:17pm
local cWaar

//Omgewing
set date brit
set conf off
clear screen

@ 1, 0 say "Waar-is-dier kodes"
@ 2, 0 say "=================="

//Open dbf
use stdwaar
cWaar := stdwaar->velded
close all
use sm3data

//Loop
do while !eof()

   @ 4, 2 say "Rekord # " + ltrim(str(recno()))

   do case

      case SM3DATA->uitkrede $ cWaar
         SM3DATA->uitkrede := "  "
      otherwise

   endcase

   do case

      case alltrim(SM3DATA->naamvd) == "A"
         SM3DATA->uitkrede := "IK"
      otherwise

   endcase

   skip

enddo

dbcloseall()

return NIL
