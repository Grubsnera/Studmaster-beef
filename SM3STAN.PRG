//SM3STAN.PRG
//Program om standaardwaardes te bewaar
//Kopiereg (c) 1991 A van Rensburg
// 7:08am Jan 11,1992

FUNCTION sm3stan

   //Verklaar
   local aSend := {}
   local aRecv := {}
   local nBoxCoor := 0
   local getlist := {}

   //Opskrif
   if cLanType() == "A"
        fScrOpsk( , "Opsie "+cOption())
   else
        fScrOpsk( , "Option "+cOption())
   endif

   //Kry die velde
   if cLanType() == "A"
      fScrWbood( 24, "Veldbesonderhede word gelees" )
   else
      fScrWbood( 24, "Field information is being read" )
   endif
   asize( aSend, 0 )
   aadd( aSend, { "sm3data", "kalfstat" })
   aadd( aSend, { "sm3data", "kalfgem" })
   aadd( aSend, { "sm3data", "nagebo" })
   aadd( aSend, { "sm3data", "ident" })
   aadd( aSend, { "sm3data", "subafd" })
   aadd( aSend, { "sm3data", "tipies" })
   aadd( aSend, { "sm3data", "type" })
   aadd( aSend, { "sm3data", "compos" })
   aadd( aSend, { "sm3data", "eyepig" })
   aRecv := fGetField( aSend )

   // Open leer
   use (cDd()+"SM3RASS") new

   //Vind die regte ras
   locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
   if eof()
      go top
   endif

   // Vra die gebruikernaam
   if cLanType() == "A"
      fScrBood( 24, "Tik die standaardwaardes vir " + trim( SM3RASS->rasnaa ) + "." )
      nBoxCoor := fBoxCent( 7, space(25),12, "STANDAARDWAARDES" )
   else
      fScrBood( 24, "Type the default values for " + trim( SM3RASS->rasnaa ) + "." )
      nBoxCoor := fBoxCent( 7, space(25),12, "DEFAULT VALUES" )
   endif
   setcolor(cColNorm())
   @  8, nBoxCoor say aRecv[1,6] get SM3RASS->kalfst pict aRecv[1,10]
   @  9, nBoxCoor say aRecv[2,6] get SM3RASS->kalfge pict aRecv[2,10]
   @ 10, nBoxCoor say aRecv[3,6] get SM3RASS->nagebo pict aRecv[3,10]
   @ 11, nBoxCoor say aRecv[4,6] get SM3RASS->identi pict aRecv[4,10]
   @ 12, nBoxCoor say aRecv[5,6] get SM3RASS->subafd pict aRecv[5,10]
   @ 13, nBoxCoor say aRecv[6,6] get SM3RASS->tipies pict aRecv[6,10]
   @ 14, nBoxCoor say aRecv[7,6] get SM3RASS->type pict aRecv[7,10]
   if cLanType() == "A"
      @ 15, nBoxCoor say padl("ID SkeidingsKarakter",20) get SM3RASS->breekk valid( SM3RASS->breekk $ "-/" )
   else
      @ 15, nBoxCoor say padl("ID separation character",20) get SM3RASS->breekk valid( SM3RASS->breekk $ "-/" )
   endif
   @ 16, nBoxCoor say aRecv[8,6] get SM3RASS->askcom pict "!" valid( SM3RASS->askcom $ "JYN " )
   @ 17, nBoxCoor say aRecv[9,6] get SM3RASS->eyepig pict aRecv[9,10]
   set cursor on
   read
   set curs off

   use

return NIL
