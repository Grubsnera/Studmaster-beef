//SM3SELR.PRG
//Program om nuwe ras te kies
//Kopiereg (c) 1991 A van Rensburg
// 6:28am Jan 11,1992

FUNCTION sm3selr

   // Open leer
   use (cDd()+"STDWAAR") new

   //Skerm
   if cLanType() == "A"
      fScrOpsk( , "Opsie "+cOption())
   else
      fScrOpsk( , "Option "+cOption())
   endif

   //Vra die ras
   STDWAAR->raskod := sm3rask( STDWAAR->raskod )

   //Bewaar die publieke veranderlikes
   cTotNaam(;
      STDWAAR->adres1 + ;
      STDWAAR->adres2 + ;
      STDWAAR->adres3 + ;
      STDWAAR->poskod + ;
      STDWAAR->kudkkl + ;
      STDWAAR->kudvvo + ;
      STDWAAR->raskod + ;
      STDWAAR->prelid + ;
      STDWAAR->streek + ;
      STDWAAR->herdno + ;
      STDWAAR->isocou)                           // 202,3

return NIL

