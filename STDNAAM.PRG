//STDNAAM.PRG
//Program om naam en adres te verander
//Kopiereg (c) 1991 A van Rensburg
//22:51 08 Sep,1991

FUNCTION stdnaam

   local nHandle := 0
   local lNaam   := .t.
   local nBoxCoor := 0
   local getlist := {}
   local cOpsk := ""

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   if "0000" $ cReeNomm() .or. len(trim(cReeNomm())) <= 0
      lNaam := .f.
      if cLanType() == "A"
         fScrBood(23,"Naam kan nie in die demonstrasieprogram verander word nie!")
         fScrWait(24)
      else
         fScrBood(23,"Name cannot be changed in the demonstration program!")
         fScrWait(24)
      endif
   endif

   if lNaam
      // Open leer
      use (cDd()+"STDWAAR") new

      // Skerm
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      // Standard South African code
      if empty(STDWAAR->isocou)
         STDWAAR->isocou := "ZAF"
      endif

      // Fill breedplan code
      cOpsk := fRasNaam(substr(cTotNaam(),149,3),"BREEDS")
      //if !empty(cOpsk)
      STDWAAR->herdno := cOpsk
      //endif

      // Vra die gebruikernaam
      if cLanType() == "A"
         fScrBood( 24, "Tik u Geregistreerde Adres asook PrestasieToetsskema besonderhede." )
         nBoxCoor := fBoxCent( 6, "KuddeKenmerkletter 1234567890123456789012345678901234567890", 13, "GEREGISTREERDE ADRES" )
      else
         fScrBood( 24, "Type your Registered Address also Performance Testing Scheme details." )
         nBoxCoor := fBoxCent( 6, "Herd Designation letter 1234567890123456789012345678901234567890", 13, "REGISTERED ADDRESS" )
      endif
      setcolor(cColNorm())
      if cLanType() == "A"
         @  7, nBoxCoor say "              Naam" get STDWAAR->genaam
         @  8, nBoxCoor say "        Adreslyn 1" get STDWAAR->adres1
         @  9, nBoxCoor say "        Adreslyn 2" get STDWAAR->adres2
         @ 10, nBoxCoor say "        Adreslyn 3" get STDWAAR->adres3
         @ 11, nBoxCoor say "           Poskode" get STDWAAR->poskod pict "9999"
         @ 12, nBoxCoor say "      ISO Landkode" get STDWAAR->isocou pict "@!"
         @ 13, nBoxCoor say "KuddeKenmerkletter" get STDWAAR->kudkkl pict "@!"
         @ 14, nBoxCoor say "  KuddeVoorvoegsel" get STDWAAR->kudvvo pict "@!"
         @ 15, nBoxCoor say "         Lidnommer" get STDWAAR->prelid pict "@9"
         @ 16, nBoxCoor say " Breedplan raskode" get STDWAAR->herdno pict "@!"
         @ 17, nBoxCoor say "    StreeksKantoor" get STDWAAR->streek pict "@!"
      else
         @  7, nBoxCoor say "              Name" get STDWAAR->genaam
         @  8, nBoxCoor say "    Address line 1" get STDWAAR->adres1
         @  9, nBoxCoor say "    Address line 2" get STDWAAR->adres2
         @ 10, nBoxCoor say "    Address line 3" get STDWAAR->adres3
         @ 11, nBoxCoor say "       Postal code" get STDWAAR->poskod pict "9999"
         @ 12, nBoxCoor say "  ISO Country code" get STDWAAR->isocou pict "@!"
         @ 13, nBoxCoor say "  Herd Designation" get STDWAAR->kudkkl pict "@!"
         @ 14, nBoxCoor say "       Herd Prefix" get STDWAAR->kudvvo pict "@!"
         @ 15, nBoxCoor say "     Member Number" get STDWAAR->prelid pict "@9"
         @ 16, nBoxCoor say "BreedplanBreedCode" get STDWAAR->herdno pict "@!"
         @ 17, nBoxCoor say "   Regional Office" get STDWAAR->streek pict "@!"
      endif
      set cursor on
      read
      set curs off

      //Bewaar die waardes
      cGebNaam(STDWAAR->genaam)
      cTotNaam(;
         STDWAAR->adres1 + ;                     //   1,40
         STDWAAR->adres2 + ;                     //  41,40
         STDWAAR->adres3 + ;                     //  81,40
         STDWAAR->poskod + ;                     // 121,4
         STDWAAR->kudkkl + ;                     // 125,4
         STDWAAR->kudvvo + ;                     // 129,20
         STDWAAR->raskod + ;                     // 149,3
         STDWAAR->prelid + ;                     // 152,10
         STDWAAR->streek + ;                     // 162,30
         STDWAAR->herdno + ;                     // 192,10
         STDWAAR->isocou)                        // 202,3

      // Country
      cIsoCoun(STDWAAR->isocou)

      // Stoor die breedplan society code
      // Update the breeds file with breedplan breed code
      sm3rasb(substr(cTotNaam(),149,3),"BREEDS",substr(cTotNaam(),192,10))
      if !empty(substr(cTotNaam(),192,10))
         sm3rasb(substr(cTotNaam(),149,3),"BREEDP","Y")
      else
         sm3rasb(substr(cTotNaam(),149,3),"BREEDP","")
      endif

   endif

return NIL
