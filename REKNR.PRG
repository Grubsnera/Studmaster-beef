//REKNR.PRG
//Program om rekenaarnommers te verander na id nommers
//11-01-93 12:04pm
//Nico Meyer van Lichtenburg

//Verklaar
local nOmsk := 1

clear screen

dbusearea(.t.,,"reknr")
index on reknr to reknr
set index to reknr


//Skerm
dbusearea(.t.,,"c:\sm3\sm3data")
@ 2, 5 say "Hooflˆer"
@ 3, 5 say "--------"
@ 5, 5 say "Aantal rekords " + ltrim(str(lastrec()))
//Loop
do while !eof()
   //Skerm
   @ 7, 5 say "Huidige rekord " + ltrim(str(recno()))
   @ 9, 5 say "    Omgeskakel " + ltrim(str(nOmsk))
   //Data file
   select REKNR
   //Id nommer
   seek left(SM3DATA->idnr,10)
   if found()
      SM3DATA->idnr := REKNR->idnr
      nOmsk++
   endif
   //Vaarnommer
   seek left(SM3DATA->idvaar,10)
   if found()
      SM3DATA->idvaar := REKNR->idnr
   endif
   //Moernommer
   seek left(SM3DATA->idmoer,10)
   if found()
      SM3DATA->idmoer := REKNR->idnr
   endif
   select SM3DATA
   skip
enddo
dbclosearea()

//Skerm
dbusearea(.t.,,"c:\sm3\sm3dekk")
nOmsk := 1
@ 2, 5 say "Deklˆer"
@ 3, 5 say "-------"
@ 5, 5 say "Aantal rekords " + ltrim(str(lastrec()))
//Loop
do while !eof()
   //Skerm
   @ 7, 5 say "Huidige rekord " + ltrim(str(recno()))
   @ 9, 5 say "    Omgeskakel " + ltrim(str(nOmsk))
   //Data file
   select REKNR
   //Id nommer
   seek left(SM3DEKK->idnr,10)
   if found()
      SM3DEKK->idnr := REKNR->idnr
   endif
   //Vaarnommer
   seek left(SM3DEKK->idvaar,10)
   if found()
      SM3DEKK->idvaar := REKNR->idnr
   endif
   //Moernommer
   seek left(SM3DEKK->idmoer,10)
   if found()
      SM3DEKK->idmoer := REKNR->idnr
      nOmsk++
   endif
   select SM3DEKK
   skip
enddo
dbcloseall()

quit
