//TUDOR.PRG
//Program om stoetmeester bees waar is dier kodes te verander
//02-02-94 06:06am

//Omgewing
set date brit
set conf off
clear screen

@ 1, 0 say "Where-is-animal codes"
@ 2, 0 say "====================="

//Open dbf
use c:\sm3\sm3data

//Loop
do while !eof()

   @ 4, 2 say "Record # " + ltrim(str(recno()))

   do case

      case SM3DATA->uitkrede $ " 1 "
         SM3DATA->uitkrede := "01"
      case SM3DATA->uitkrede $ " 2 "
         SM3DATA->uitkrede := "02"
      case SM3DATA->uitkrede $ " 3 "
         SM3DATA->uitkrede := "03"
      case SM3DATA->uitkrede $ " 4 "
         SM3DATA->uitkrede := "04"
      case SM3DATA->uitkrede $ " 5 "
         SM3DATA->uitkrede := "05"
      case SM3DATA->uitkrede $ " 6 "
         SM3DATA->uitkrede := "06"
      case SM3DATA->uitkrede $ " 7 "
         SM3DATA->uitkrede := "07"
      case SM3DATA->uitkrede $ " 8 "
         SM3DATA->uitkrede := "08"
      case SM3DATA->uitkrede $ " 9 "
         SM3DATA->uitkrede := "09"

   endcase

   skip

enddo

dbcloseall()

return NIL
