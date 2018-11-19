// SM3MASS.PRG
// Program om massas te bewaar
// Kopiereg (C) 1992 A van Rensburg
// 11:02 27 Mar,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3mass

   // Verklaar
   local getlist  := {}
   local aCdbf    := fATopen()
   local aCscr  := {}
   local nCh      := 1
   local lLoop    := .t.
   local nLoop    := 1
   local cIndg    := "      "
   local aVelde   := {}
   local cMass    := ""
   local nTota    := 0
   local nAant    := 0
   local dDatu    := ctod("  /  /  ")
   local nMass    := 0
   local cIkod    := ""
   local cTest    := ""
   local cData    := ""
   local nOude    := 0
   local nMin     := 0
   local nMaks    := 0
   local nAge     := 0
   local nDiffOld := 0
   local nDiffNew := 0
   local lKeepOld := .f.
   local cBrep := ""
   local cFeed := "1"
   private cOude  := ""

   begin sequence
      // Open dataleers
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
         fScrWbood( 24, "Datalˆers word geopen" )
      else
         fScrOpsk(,"Option "+cOption())
         fScrWbood( 24, "Data files being opened" )
      endif

      aCdbf := fATOpen(aCdbf,cDd(),"sm3weeg")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      aCdbf := fATOpen(aCdbf,cDd(),"sm3data")
      if !aCdbf[len(aCdbf),1]
         break
      endif

      // Skerm
      if cLanType() == "A"
         fBox( 3, 2, maxrow()-4, maxcol()-3, "Bewaar massas vir indeksberekeninge", cColNorm() )
         @ 5, 4 say "         Indeksgroep"
         @ 6, 4 say "      Indeksouderdom"
         @ 7, 4 say "              Geslag"
         @ 8, 4 say "     Lewendig of nie"
         @ 5, 44 say "     Diere in groep"
         @ 6, 44 say "   Diere met massas"
         @ 7, 44 say "   Gemiddelde massa"
         @ 8, 44 say "       Totale massa"
      else
         fBox( 3, 2, maxrow()-4, maxcol()-3, "Enter masses for index calculations", cColNorm() )
         @ 5, 4 say "         Index group"
         @ 6, 4 say "           Index age"
         @ 7, 4 say "                 Sex"
         @ 8, 4 say "         Live or not"
         @ 5, 44 say "   Animals in group"
         @ 6, 44 say "Animals with masses"
         @ 7, 44 say "       Average mass"
         @ 8, 44 say "         Total mass"
      endif

      @10,3 to 10,maxcol()-4

      // Vra die indeksgroep, groep of seleksiegroep
      aCscr := fASaveScr()
      nCh := fNewMenu( nCh, "SM3MASSa" )
      cOption(nCh)

      do case

         case nCh == 1
            // Indeksgroep
            // Kry die indeksgroep
            cIndg := sm3indg(4)
            fARestScr(aCscr)
            if len(trim(cIndg)) == 0
               if cLanType() == "A"
                  fScrWait(24,"Geen indeksgroep is gekies nie!")
               else
                  fScrWait(24,"No index group was selected!")
               endif
               cOption(-1)
               break
            endif

            // Vertoon indeksgroep
            setcolor( cColInve() )
            @ 5,25 say cIndg
            setcolor( cColNorm() )

            // Kyk of daar wel diere is vir die indeksgroep
            select SM3DATA
            set order to 3
            seek cIndg
            copy to (cDd()+"mass") fields ;
               idnr,;                            //Nommer van dier
               geslag,;                          //Geslag van dier
               kalfbnr,;                         //Waarskuwings
               gemspeeni,;                       //Moeder gemiddelde speenindeks
               gemspeena,;                       //Korreksiefaktor
               mamoergeb,;                       //Moeder ouderdom
               idmoer,;                          //Moeder id nommer
               gebdatum,;                        //kalf geboortedatum
               gebmassa,;                        //Kalf geboortemassa
               ind100,;                          //Indeks
               uitkrede;                         //Datum uit
               while SM3DATA->indekskode == cIndg
               set order to 1

            case nCh == 2
               // Groep
               setcolor( cColInve() )
               if cLanType() == "A"
                  @ 5,25 say "GROEP"
               else
                  @ 5,25 say "GROUP"
               endif
               setcolor( cColNorm() )
               cTest := sm3groe()
               fARestScr(aCscr)
               if len( cTest ) > 0
                  // Skep leer met name van diere om te weeg
                  fScrBood(23)
                  if cLanType() == "A"
                     fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
                  else
                     fScrBood(24,"Calves corresponding to group requirements being sorted.")
                  endif
                  copy to (cDd()+"mass") fields ;
                     idnr,;                      //Nommer van dier
                     geslag,;                    //Geslag van dier
                     kalfbnr,;                   //Waarskuwings
                     gemspeeni,;                 //Moeder gemiddelde speenindeks
                     gemspeena,;                 //Korreksiefaktor
                     mamoergeb,;                 //Moeder ouderdom
                     idmoer,;                    //Moeder id nommer
                     gebdatum,;                  //kalf geboortedatum
                     gebmassa,;                  //Kalf geboortemassa
                     ind100,;                    //Indeks
                     uitkrede;                   //Datum uit
                     for &cTest.
                  else
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
                     else
                        fScrWait(24,"No group selection requirements have been specified!")
                     endif
                     cOption(-1)
                     break
                  endif

               case nCh == 3
                  // Seleksiegroep
                  setcolor( cColInve() )
                  if cLanType() == "A"
                     @ 5,25 say "SELEKSIEGROEP"
                  else
                     @ 5,25 say "SELECTION GROUP"
                  endif
                  setcolor( cColNorm() )
                  cTest := sm3selg()
                  fARestScr(aCscr)
                  if len( cTest ) > 0
                     // Skep leer met name van diere om te weeg
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
                     else
                        fScrBood(24,"Calves qualifying with the group requirements being sorted.")
                     endif
                     copy to (cDd()+"mass") fields ;
                        idnr,;                   //Nommer van dier
                        geslag,;                 //Geslag van dier
                        kalfbnr,;                //Waarskuwings
                        gemspeeni,;              //Moeder gemiddelde speenindeks
                        gemspeena,;              //Korreksiefaktor
                        mamoergeb,;              //Moeder ouderdom
                        idmoer,;                 //Moeder id nommer
                        gebdatum,;               //kalf geboortedatum
                        gebmassa,;               //Kalf geboortemassa
                        ind100,;                 //Indeks
                        uitkrede;                //Datum uit
                        for &cTest.
                     else
                        fScrBood(23)
                        if cLanType() == "A"
                           fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
                        else
                           fScrWait(24,"No selection group requirements have been specified!")
                        endif
                        cOption(-1)
                        break
                     endif

                  otherwise
                     // Herstel
                     cOption(-1)
                     fARestScr(aCscr)
                     break

               endcase

               if cLanType() == "A"
                  fScrOpsk(1,"Opsie "+cOption())
               else
                  fScrOpsk(1,"Option "+cOption())
               endif

               // Open dataleer met massas
               ferase(cDd()+"MASS"+ordbagext())
               aCdbf := fATOpen(aCdbf,cDd(),"mass",,,,.f.)
               if !aCdbf[len(aCdbf),1]
                  cOption(-1)
                  break
               endif

               //Kyk of daar diere in die leer is
               if lastrec() == 0
                  if cLanType() == "A"
                     fScrBood(23,"Geen kalwers kon gevind word om te weeg nie!")
                  else
                     fScrBood(23,"No calves to be weighed could be found!")
                  endif
                  fScrWait(24)
                  cOption(-1)
                  break
               endif

               //Vra indeksouderdom
               aCscr := fASaveScr()
               cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

               if cBrep $ "JYjy"
                  // Breedplan format
                  nCh := fNewMenu( 1, "SM3MASSbp" )
                  cOption(nCh)
                  fARestScr(aCscr)

                  if cLanType() == "A"
                     fScrOpsk(1,"Opsie "+cOption())
                  else
                     fScrOpsk(1,"Option "+cOption())
                  endif

                  do case
                     case nCh == 1
                        cOude := "100"
                        nOude := 100
                        nMin  := 80
                        nMaks := 120
                     case nCh == 2
                        cOude := "205"
                        nOude := 200
                        nMin  := 80
                        nMaks := 300
                     case nCh == 3
                        cOude := "365"
                        nOude := 400
                        nMin  := 301
                        nMaks := 500
                     case nCh == 4
                        cOude := "540"
                        nOude := 600
                        nMin  := 501
                        nMaks := 900
                     otherwise
                        //Herstel
                        cOption(-2)
                        break
                  endcase
               else
                  // Iris format
                  nCh := fNewMenu( 1, "SM3MASSb" )
                  cOption(nCh)
                  fARestScr(aCscr)

                  if cLanType() == "A"
                     fScrOpsk(1,"Opsie "+cOption())
                  else
                     fScrOpsk(1,"Option "+cOption())
                  endif

                  do case
                     case nCh == 1
                        cOude := "100"
                        nOude := 100
                        nMin  := 60
                        nMaks := 160
                     case nCh == 2
                        cOude := "205"
                        nOude := 205
                        nMin  := 150
                        nMaks := 270
                     case nCh == 3
                        cOude := "365"
                        nOude := 365
                        nMin  := 271
                        nMaks := 450
                     case nCh == 4
                        cOude := "540"
                        nOude := 540
                        nMin  := 451
                        nMaks := 634
                     otherwise
                        //Herstel
                        cOption(-2)
                        break
                  endcase

               endif

               setcolor( cColInve() )
               if cLanType() == "A"
                  @ 6,25 say ltrim(str(nOude)) + " dae"
               else
                  @ 6,25 say ltrim(str(nOude)) + " days"
               endif
               setcolor( cColNorm() )

               //Vra geslag
               aCscr := fASaveScr()
               nCh := fNewMenu( 1, "SM3MASSc" )
               cOption(nCh)
               fARestScr(aCscr)

               if cLanType() == "A"
                  fScrOpsk(1,"Opsie "+cOption())
               else
                  fScrOpsk(1,"Option "+cOption())
               endif

               if cLanType() == "A"
                  do case
                     case nCh == 1
                        setcolor( cColInve() )
                        @ 7,25 say "Albei geslagte"
                        setcolor( cColNorm() )
                     case nCh == 2
                        setcolor( cColInve() )
                        @ 7,25 say "Vroulik"
                        setcolor( cColNorm() )
                        fScrBood(23)
                        fScrWbood(24,"Manlike diere word verwyder")
                        select MASS
                        go top
                        do while !(eof())
                           if MASS->geslag $ "1VF"
                           else
                              if rlock()
                                 delete
                                 dbUnlock()
                              endif
                           endif
                           skip
                        enddo
                        go top

                     case nCh == 3
                        setcolor( cColInve() )
                        @ 7,25 say "Manlik"
                        setcolor( cColNorm() )
                        fScrBood(23)
                        fScrWbood(24,"Vroulike diere word verwyder")
                        select MASS
                        go top
                        do while !(eof())
                           if MASS->geslag $ "2M3"
                           else
                              if rlock()
                                 delete
                                 dbUnlock()
                              endif
                           endif
                           skip
                        enddo
                        go top

                     otherwise
                        //Herstel
                        cOption(-3)
                        break
                  endcase
               else
                  do case
                     case nCh == 1
                        setcolor( cColInve() )
                        @ 7,25 say "Both sexes"
                        setcolor( cColNorm() )
                     case nCh == 2
                        setcolor( cColInve() )
                        @ 7,25 say "Female"
                        setcolor( cColNorm() )
                        fScrBood(23)
                        fScrWbood(24,"Male animals being removed")
                        select MASS
                        go top
                        do while !(eof())
                           if MASS->geslag $ "1VF"
                           else
                              if rlock()
                                 delete
                                 dbUnlock()
                              endif
                           endif
                           skip
                        enddo
                        go top

                     case nCh == 3
                        setcolor( cColInve() )
                        @ 7,25 say "Male"
                        setcolor( cColNorm() )
                        fScrBood(23)
                        fScrWbood(24,"Female animals being removed")
                        select MASS
                        go top
                        do while !(eof())
                           if MASS->geslag $ "2M3"
                           else
                              if rlock()
                                 delete
                                 dbUnlock()
                              endif
                           endif
                           skip
                        enddo
                        go top

                     otherwise
                        //Herstel
                        cOption(-3)
                        break
                  endcase
               endif

               //Vra lewendig of nie
               aCscr := fASaveScr()
               nCh := fNewMenu( 1, "SM3MASSd" )
               cOption(nCh)
               fARestScr(aCscr)

               if cLanType() == "A"
                  fScrOpsk(1,"Opsie "+cOption())
               else
                  fScrOpsk(1,"Option "+cOption())
               endif

               if cLanType() == "A"
                  do case
                     case nCh == 1
                        setcolor( cColInve() )
                        @ 8,25 say "Alle kalwers"
                        setcolor( cColNorm() )
                     case nCh == 2
                        setcolor( cColInve() )
                        @ 8,25 say "Lewendige kalwers"
                        setcolor( cColNorm() )
                        fScrBood(23)
                        fScrWbood(24,"Lewendige kalwers word uitgesoek")
                        select MASS
                        go top
                        do while !(eof())
                           if MASS->uitkrede $ cWaarisd()
                           else
                              if rlock()
                                 delete
                                 dbUnlock()
                              endif
                           endif
                           skip
                        enddo
                        go top
                     otherwise
                        //Herstel
                        cOption(-4)
                        break
                  endcase
               else
                  do case
                     case nCh == 1
                        setcolor( cColInve() )
                        @ 8,25 say "All calves"
                        setcolor( cColNorm() )
                     case nCh == 2
                        setcolor( cColInve() )
                        @ 8,25 say "Live calves"
                        setcolor( cColNorm() )
                        fScrBood(23)
                        fScrWbood(24,"Live calves being sorted")
                        select MASS
                        go top
                        do while !(eof())
                           if MASS->uitkrede $ cWaarisd()
                           else
                              if rlock()
                                 delete
                                 dbUnlock()
                              endif
                           endif
                           skip
                        enddo
                        go top
                     otherwise
                        //Herstel
                        cOption(-4)
                        break
                  endcase
               endif

               //Kyk of daar diere in die leer is
               fScrBood(23)
               if cLanType() == "A"
                  fScrWbood(24,"Massas lˆer word gekompakteer")
               else
                  fScrWbood(24,"Masses file being packed")
               endif
               select MASS
               pack
               if lastrec() == 0
                  if cLanType() == "A"
                     fScrBood(23,"Geen kalwers het oorgebly vir wie massas bewaar kan word nie!")
                  else
                     fScrBood(23,"No calves remain for which masses can be entered!")
                  endif
                  fScrWait(24)
                  cOption(-4)
                  break
               endif

               //Set relation
               set relation to MASS->idnr into SM3DATA

               // Vra of met die hand getik gaan word of gelees moet word vanaf die
               // gereelde wegingslˆer
               aCscr := fASaveScr()
               nCh := fNewMenu( 1, "SM3MASSf" )
               cOption(nCh)
               fARestScr(aCscr)

               if cLanType() == "A"
                  fScrOpsk(1,"Opsie "+cOption())
               else
                  fScrOpsk(1,"Option "+cOption())
               endif

               do case
                  case nCh == 1
                  case nCh == 2
                     lKeepOld := .t.
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWbood(24,"Massas word gelees vanaf die gereelde wegingslˆer")
                     else
                        fScrWbood(24,"Masses being read from the regular weighings file")
                     endif
                     select MASS
                     go top
                     do while !eof()

                        // Do only if age can be calculated
                        if !empty(SM3DATA->gebdatum)

                           // Locate animal in weighings file
                           select SM3WEEG
                           seek MASS->idnr
                           if !eof()
                              do while SM3WEEG->idnr == MASS->idnr

                                 // If age within boundaries
                                 nAge := SM3WEEG->weegdatum - SM3DATA->gebdatum
                                 if nAge >= nMin .and. nAge <= nMaks

                                    // Select the correct data file
                                    select SM3DATA
                                    do while !rlock()
                                    enddo

                                    if empty(SM3DATA->dat&cOude.)
                                       // There is no date stored
                                       SM3DATA->dat&cOude. := SM3WEEG->weegdatum
                                       SM3DATA->mas&cOude. := SM3WEEG->massa
                                    else
                                       // There is a mass stored
                                       // Calc the difference between age and index age to be able to
                                       // to calc the weighing date with the smallest difference
                                       nDiffOld := nOude - (SM3DATA->dat&cOude. - SM3DATA->gebdatum)
                                       if nDiffOld < 0
                                          nDiffOld := nDiffOld * -1
                                       endif
                                       nDiffNew := nOude - nAge
                                       if nDiffNew < 0
                                          nDiffNew := nDiffNew * -1
                                       endif
                                       if nDiffNew < nDiffOld
                                          SM3DATA->dat&cOude. := SM3WEEG->weegdatum
                                          SM3DATA->mas&cOude. := SM3WEEG->massa
                                       endif

                                    endif

                                 endif

                                 // Next one
                                 select SM3WEEG
                                 skip

                              enddo
                           endif
                        endif

                        // Next animal
                        select MASS
                        skip

                     enddo
                     go top

                  otherwise

                     //Herstel
                     cOption(-5)
                     break

               endcase

               //Doen die berekeninge
               select MASS
               go top
               do while !(eof())
                  if SM3DATA->mas&cOude > 0
                     nAant := nAant + 1
                     nTota := nTota + SM3DATA->mas&cOude
                  endif
                  skip
               enddo
               go top

               //Skerm
               if cLanType() == "A"
                  @12, 4 say "          Id nommer"
                  @13, 4 say "          Weegdatum"
                  @14, 4 say "              Massa"
                  @15, 4 say "    Grootmaakstatus"
                  @16, 4 say "    Byvoedingstatus"
                  @17, 4 say "  Rede onbetroubaar"
               else
                  @12, 4 say "          Id number"
                  @13, 4 say "         Weigh date"
                  @14, 4 say "               Mass"
                  @15, 4 say "     Rearing status"
                  @16, 4 say "     Feeding status"
                  @17, 4 say "  Reason unreliable"
               endif

               //Aanvanklike data
               dDatu := SM3DATA->dat&cOude.

               nLoop := 1
               do while nLoop > 0

                  // If the previous weighing date must be kept
                  if lKeepOld
                     dDatu := SM3DATA->dat&cOude.
                  endif

                  // See if this field contains the correct data
                  if SM3DATA->rearst $ "1234567"
                  else
                     select SM3DATA
                     do while !rlock()
                     enddo
                     if empty(SM3DATA->gebstat)
                        SM3DATA->rearst := "1"
                     else
                        SM3DATA->rearst := SM3DATA->gebstat
                     endif
                     select MASS
                  endif

                  // See if this feeding status contains the correct data
                  if SM3DATA->kod&cOude. $ "1  z2  z3  z4  z5  z6  z7  "
                  else
                     select SM3DATA
                     do while !rlock()
                     enddo
                     SM3DATA->kod&cOude. := cFeed
                     select MASS
                  endif

                  // See if this unreliable status contains the correct data
                  if SM3DATA->unr&cOude. $ "   z1  z2  z3  z4  z5  z6  "
                  else
                     select SM3DATA
                     do while !rlock()
                     enddo
                     SM3DATA->unr&cOude. := ""
                     select MASS
                  endif

                  //Vertoon id nommer
                  setcolor( cColInve() )
                  @12, 4+21 say MASS->idnr
                  @13, 4+21 say dDatu
                  @14, 4+21 say transform( SM3DATA->mas&cOude., "999" )
                  @15, 4+21 say SM3DATA->rearst
                  @16, 4+21 say SM3DATA->kod&cOude.
                  @17, 4+21 say SM3DATA->unr&cOude.
                  @ 5, 44+21 say transform( lastrec(), "999999" )
                  @ 6, 44+21 say transform( nAant    , "999999" )
                  if nAant > 0
                     @ 7, 44+21 say transform( nTota/nAant    , "9999.9" )
                  else
                     @ 7, 44+21 say transform( 0              , "9999.9" )
                  endif
                  @ 8, 44+21 say transform( nTota    , "999999" )
                  setcolor( cColNorm() )

                  do case

                     case nLoop = 1
                        // Weegdatum

                        // Skerm
                        if cLanType() == "A"
                           fScrBood( 23,"Tik die datum waarop die kalf geweeg is!" )
                           fScrBood( 24,"[Esc]=Menu  "+D_ENTER+"=Aanvaar en vra massa" )
                        else
                           fScrBood( 23, "Type the date on which the calf was weighed!" )
                           fScrBood( 24, "[Esc]=Menu  "+D_ENTER+"=Accept and move on to mass" )
                        endif

                        // Vra die datum
                        @13, 4+21 get dDatu
                        readexit(.t.)
                        set cursor on
                        read
                        set cursor off
                        readexit(.f.)

                        do case
                           case lastkey() == K_ESC
                              // Menu
                              nLoop := 0
                           case dDatu == ctod("  /  /  ")
                              // Datum verpligtend
                              if cLanType() == "A"
                                 fScrBood(23,"Die weegdatum is verpligtend!")
                              else
                                 fScrBood(23,"The weigh date is compulsory!")
                              endif
                              fScrWait(24)
                           case lastkey() == K_ENTER .and. dDatu <> ctod("  /  /  ")
                              // Aanvaar datum
                              nLoop := 2
                        endcase

                     case nLoop = 2

                        // Massa
                        nMass := SM3DATA->mas&cOude.

                        // Trek totale af
                        if nMass > 0
                           nAant--
                           nTota = nTota - nMass
                        endif

                        // Skerm
                        if cLanType() == "A"
                           fScrBood( 23, "Tik die kalf se " + ltrim(str(nOude)) + " dae liggaamsmassa!" )
                           fScrBood( 24, "[Esc]=Menu  "+D_ENTER+"=Aanvaar  "+D_UPARR+"=Weegdatum  "+D_DNARR+"=Indekskode" )
                        else
                           fScrBood( 23, "Type the calf's " + ltrim(str(nOude)) + " day body mass!" )
                           fScrBood( 24, "[Esc]=Menu  "+D_ENTER+"=Accept  "+D_UPARR+"=Weigh date  "+D_DNARR+"=Index code" )
                        endif

                        // Vra die massa
                        @14, 4+21 get nMass pict "999"
                        readexit(.t.)
                        set cursor on
                        read
                        set cursor off
                        readexit(.f.)

                        // Bewaar totale
                        if nMass > 0
                           nAant++
                           nTota := nTota + nMass
                        endif

                        // Bewaar inligting
                        select SM3DATA
                        if rlock()
                           SM3DATA->mas&cOude. := nMass
                           SM3DATA->dat&cOude. := dDatu
                           if nMass <= 0
                              SM3DATA->unr&cOude. := "6"
                           endif
                           dbUnlock()
                        endif

                        // Bewaar inligting in wegingsleer
                        if !empty(dDatu) .and. nMass > 0
                           select SM3WEEG
                           cData := Sm3DATA->idnr + dtos( dDatu )
                           seek cData
                           if eof()
                              append blank
                           endif
                           if rlock()
                              SM3WEEG->idnr      := SM3DATA->idnr
                              SM3WEEG->weegdatum := dDatu
                              SM3WEEG->massa     := nMass
                              dbUnlock()
                           endif
                        endif

                        select MASS

                        do case

                           case lastkey() == K_ESC
                              //Exit
                              nLoop := 0

                           case lastkey() == K_ENTER

                              // Bewaar massa

                              // If NIL mass is acceptable
                              if lKeepOld
                              else
                                 // Rede waarom 'n dier 'n nul massa het
                                 if nMass == 0 .and. SM3DATA->kod&cOude. $ "  z00z11z22z33z44z55z66z77z88z99"
                                    // tone( 300, 1 )
                                    nLoop := 3
                                    loop
                                 endif
                              endif

                              // Volgende dier
                              skip

                              // Indien einde van leer
                              if eof()
                                 if cLanType() == "A"
                                    fScrBood(23,"Hierdie was die laaste kalf van die groep!")
                                 else
                                    fScrBood(23,"This was the last calf in the group!")
                                 endif
                                 fScrWait(24)
                                 nLoop := 0
                              endif

                           case lastkey() == K_UP
                              //Weegdatum
                              nLoop := 1

                           case lastkey() == K_DOWN
                              //Indekskode
                              nLoop := 3

                           case lastkey() = K_PGUP
                              //vorige dier
                              if recno() > 1
                                 skip -1
                              endif

                        endcase

                     case nLoop = 3

                        // Rearing status

                        //Skerm
                        if cLanType() == "A"
                           fScrBood( 23, "Tik die grootmaakstatus van die kalf!" )
                           fScrBood( 24, D_ENTER+"=Aanvaar  "+D_UPARR+"=Massa  [F1]=Hulp" )
                        else
                           fScrBood( 23, "Type the rearing status of the calf!" )
                           fScrBood( 24, D_ENTER+"=Accept   "+D_UPARR+"=Mass  [F1]=Help" )
                        endif

                        //Vra
                        select SM3DATA
                        if rlock()
                           @15, 4+21 get SM3DATA->rearst pict "!"
                           readexit(.t.)
                           set cursor on
                           read
                           set cursor off
                           readexit(.f.)
                           dbUnlock()
                        endif
                        select MASS
                        if lastkey() == K_UP
                           nLoop := 2
                        else
                           nLoop := 4
                        endif

                     case nLoop = 4

                        // Feeding status

                        //Skerm
                        if cLanType() == "A"
                           fScrBood( 23, "Tik die kalf se voedingsstatus!" )
                           fScrBood( 24, D_ENTER+"=Aanvaar  "+D_UPARR+"=Massa  [F1]=Hulp" )
                        else
                           fScrBood( 23, "Type the feeding status of the calf!" )
                           fScrBood( 24, D_ENTER+"=Accept   "+D_UPARR+"=Mass  [F1]=Help" )
                        endif

                        //Vra
                        select SM3DATA
                        if rlock()
                           @16, 4+21 get SM3DATA->kod&cOude. pict "@!"
                           readexit(.t.)
                           set cursor on
                           read
                           set cursor off
                           readexit(.f.)
                           dbUnlock()
                           cFeed := SM3DATA->kod&cOude.
                        endif
                        select MASS
                        if lastkey() == K_UP
                           // Previous
                           nLoop := 3
                        else
                           // Next
                           nLoop := 5
                        endif

                     case nLoop = 5

                        // Unreliable code

                        //Skerm
                        if cLanType() == "A"
                           fScrBood( 23, "Tik die rede indien die kalf massa onrealisties is!" )
                           fScrBood( 24, D_ENTER+"=Aanvaar  "+D_UPARR+"=Massa  [F1]=Hulp" )
                        else
                           fScrBood( 23, "Type the reason why the calf weight is unreliable!" )
                           fScrBood( 24, D_ENTER+"=Accept   "+D_UPARR+"=Mass  [F1]=Help" )
                        endif

                        //Vra
                        select SM3DATA
                        if rlock()
                           @17, 4+21 get SM3DATA->unr&cOude. pict "!"
                           readexit(.t.)
                           set cursor on
                           read
                           set cursor off
                           readexit(.f.)
                           dbUnlock()
                        endif
                        select MASS
                        if lastkey() == K_UP
                           // Previous
                           nLoop := 4
                        else
                           // Mass
                           nLoop := 2
                        endif


                  endcase

               enddo

               cOption(-5)

            end

            //Herstel
            fATclose(aCdbf)
            return NIL
