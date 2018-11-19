//WID.PRG
//Program om stoetmeester bees waar is dier kodes te verander
//11-08-94 02:21pm

//Omgewing
set date brit
set conf off
clear screen

@ 1, 0 say "Waar-is-dier kodes"
@ 2, 0 say "=================="

//Open dbf
use sm3data

//Loop
do while !eof()

   @ 4, 2 say "Rekord # " + ltrim(str(recno()))

   do case

      case SM3DATA->uitkrede == "IK"
         SM3DATA->uitkrede := "  "
      otherwise

   endcase

   skip

enddo

dbcloseall()

return NIL
