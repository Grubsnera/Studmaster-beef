//SM3KALF.PRG
//Program om geboortekennisgewing verstekwaardes te vra
//Kopiereg (c) 1991 A van Rensburg
// 6:28am Jan 11,1992

FUNCTION sm3kalf

   // Declare
   local nBoxCoor := 0
   local getlist := {}

   // Open leer
   use (cDd()+"STDWAAR") new

   //Skerm
   if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
   else
        fScrOpsk( , "Option "+cOption())
   endif

   //Vra die kalfboeknommers
   if cLanType() == "A"
      fScrBood( 23 )
      fScrBood( 24, "Bewaar die reeks kalfboeknommers." )
      nBoxCoor := fBoxCent( 7, "                      1234", 10, "KALFBOEKNOMMER REEKS" )
   else
      fScrBood( 23 )
      fScrBood( 24, "Enter the series of calf book numbers." )
      nBoxCoor := fBoxCent( 7, "                      1234", 10, "CALF BOOK NUMBER SERIES" )
   endif
   setcolor(cColNorm())
   if cLanType() == "A"
      @  8, nBoxCoor say "Lettergedeelte        "
      @  9, nBoxCoor say "van die Kalfboeknommer" get STDWAAR->kalfbn pict "@!"
      @ 11, nBoxCoor say "Syfergedeelte van die "
      @ 12, nBoxCoor say " EERSTE Kalfboeknommer" get STDWAAR->kalfbe pict "9999"
      @ 14, nBoxCoor say "Syfergedeelte van die "
      @ 15, nBoxCoor say " LAASTE Kalfboeknommer" get STDWAAR->kalfbl pict "9999"
   else
      @  8, nBoxCoor say "Letter part of        "
      @  9, nBoxCoor say "the Calf book number  " get STDWAAR->kalfbn pict "@!"
      @ 11, nBoxCoor say "Figure part of the    "
      @ 12, nBoxCoor say "FIRST Calf book number" get STDWAAR->kalfbe pict "9999"
      @ 14, nBoxCoor say "Figure part of the    "
      @ 15, nBoxCoor say "LAST Calf book number " get STDWAAR->kalfbl pict "9999"
   endif
   set cursor on
   read
   set curs off

return NIL

