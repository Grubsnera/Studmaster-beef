//SM3OPSK.PRG
//Program om opskrifte te bewaar
//Kopiereg (c) 1993 A van Rensburg
//11-12-93 04:50pm

/****************************************************************************/
FUNCTION sm3opsk

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
      go bottom
      skip
   endif

   //Vra die data
   if cLanType() == "A"
      fScrBood( 24, "Tik die amptelike verslae-opskrifte vir " + trim( SM3RASS->rasnaa ) + "." )
      nBoxc := fBoxCent( 9, space(52), 7, "OPSKRIFTE" )
   else
      fScrBood( 24, "Type the official report headings for " + trim( SM3RASS->rasnaa ) + "." )
      nBoxc := fBoxCent( 9, space(52), 7, "HEADINGS" )
   endif
   setcolor(cColNorm())
   if cLanType() == "A"
      @ 10, nBoxc say "Geboortekennisgewings" get SM3RASS->headbn pict "@S30"
      @ 11, nBoxc say "             Dekbrief" get SM3RASS->headcl pict "@S30"
      @ 12, nBoxc say "         Inspeksielys" get SM3RASS->headil pict "@S30"
      @ 13, nBoxc say "          Oordragvorm" get SM3RASS->headtl pict "@S30"
      @ 14, nBoxc say "        Skrappingslys" get SM3RASS->headdl pict "@S30"
   else
      @ 10, nBoxc say "Birth notification" get SM3RASS->headbn pict "@S30"
      @ 11, nBoxc say "   Covering letter" get SM3RASS->headcl pict "@S30"
      @ 12, nBoxc say "   Inspection list" get SM3RASS->headil pict "@S30"
      @ 13, nBoxc say "     Transfer form" get SM3RASS->headtl pict "@S30"
      @ 14, nBoxc say "      Culling list" get SM3RASS->headdl pict "@S30"
   endif
   set cursor on
   read
   set curs off

   //Herstel
   fTClose(cFile)
return NIL

