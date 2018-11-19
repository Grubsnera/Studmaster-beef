//JEZ.PRG
//Program to remove JEZ animals from data set

//Declare
local nCoun := 1

//Omgewing
set date brit
set talk off
clear screen

//Open database
use c:\sm3\sm3data
@5,5 say "Remove JEZ data"
@6,5 say "---------------"
@8,5 say "    Records in file " + ltrim(str(lastrec()))

//The loop
do while !eof()

   if "JEZ" $ SM3DATA->idnr
      @9,5 say "    Records deleted " + ltrim(str(nCoun))
      delete
      nCoun++
   endif

   skip

enddo

dbcloseall()
quit



