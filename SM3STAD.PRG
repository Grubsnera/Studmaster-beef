//SM3STAD.PRG
//Program om dekkings standaardwaardes te bewaar
//Kopiereg (c) 1991 A van Rensburg
//15:08 21 Sep,1992


//**************************************************************************/
FUNCTION sm3stad

   //Verklaar
   local cFile := ""
   local nBoxc := 0
   local getlist := {}

   //Open dataleer
   cFile := fTOpen(cDd(),"sm3rass",,"dbf",,.f.,.f.)
   if left(cFile,1) == "f"
      return NIL
   endif

   //Opskrif
   if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
   else
        fScrOpsk( , "Option "+cOption())
   endif

   //Vind die regte ras
   locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
   if eof()
      go top
   endif

   //Vra die data
   if cLanType() == "A"
      fScrBood( 24, "Tik die dekkingswaardes vir " + trim( SM3RASS->rasnaa ) + "." )
      nBoxc := fBoxCent( 7, space(50), 9, "DEKKINGSWAARDES" )
   else
      fScrBood( 24, "Type the mating values for " + trim( SM3RASS->rasnaa ) + "." )
      nBoxc := fBoxCent( 7, space(50), 9, "MATING VALUES" )
   endif
   setcolor(cColNorm())
   if cLanType() == "A"
      @  8, nBoxc say "    Jongste dekouderdom in dae" get SM3RASS->oudeer pict "999"
      @  9, nBoxc say "   Normale sikluslengte in dae" get SM3RASS->siklus pict "999"
      @ 10, nBoxc say "   Minimum dragtigheidsperiode" get SM3RASS->mindra pict "999"
      @ 11, nBoxc say "   Normale dragtigheidsperiode" get SM3RASS->nordra pict "999"
      @ 12, nBoxc say "  Maksimum dragtigheidsperiode" get SM3RASS->makdra pict "999"
      @ 13, nBoxc say "  Rustyd in dae na laaste kalf" get SM3RASS->rustyd pict "999"
      @ 14, nBoxc say "Dae na dek dragtigheidsonderso" get SM3RASS->daedra pict "999"
   else
      @  8, nBoxc say "   Youngest mating age in days" get SM3RASS->oudeer pict "999"
      @  9, nBoxc say "   Normal cycle length in days" get SM3RASS->siklus pict "999"
      @ 10, nBoxc say "      Minimum gestation period" get SM3RASS->mindra pict "999"
      @ 11, nBoxc say "       Normal gestation period" get SM3RASS->nordra pict "999"
      @ 12, nBoxc say "      Maximum gestation period" get SM3RASS->makdra pict "999"
      @ 13, nBoxc say "Resting period after last calf" get SM3RASS->rustyd pict "999"
      @ 14, nBoxc say "Days after mating preg.diagnos" get SM3RASS->daedra pict "999"
   endif
   set cursor on
   read
   set curs off

   //Herstel
   fTClose(cFile)
return NIL

