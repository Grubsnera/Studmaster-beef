//DONOR.PRG
//Program to remove donor cows from the mating file
//01-29-96 11:34am

FUNCTION Donor(cData)

//Omgewing
set date brit
set conf off
clear screen

// Variables
cData := iif(empty(cData),"c:\sm3\sm3dekk",cData)

@ 1, 0 say "Donor cows"
@ 2, 0 say "=========="

//Open dbf
use &(cData)

//Loop
do while !eof()

   @ 4, 2 say "Rekord # " + ltrim(str(recno()))

   do case

      case SM3DEKK->vaarkode == "4"
         // Do nothing
      otherwise
         // Remove donor
         SM3DEKK->donor = ''

   endcase

   skip

enddo

dbcloseall()

return NIL
