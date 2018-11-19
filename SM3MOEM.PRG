// SM3MOEM.PRG
// Program om massas te bewaar
// Kopiereg (C) 1992 A van Rensburg
// 11:02 27 Mar,1992
// Updated 00-12-14 07:58 Add function to read masses from regular weighings
//  file

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3moem

   //Verklaar
   local getlist  := {}
   local aCscr    := {}
   local cCurDbf  := ""
   local cSm3Weeg := ""
   local cSm3Data := ""
   local cSm3Indg := ""
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
   local cIndf    := cDd()+"mass"+ordbagext()
   local cDamm    := ""
   private cOude  := ""

   //Skerm
   //Open dataleers
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrOpsk(,"Option "+cOption())
      fScrWbood( 24, "Data files being opened" )
   endif

   cSm3Weeg := fTOpen( cDd(), "sm3weeg", , "dbf", , .t. )
   if left( cSm3Weeg, 1 ) == "f"
      return NIL
   endif

   cSm3Data := fTOpen( cDd(), "sm3data", , "dbf", , .t. )
   if left( cSm3Data, 1 ) == "f"
      fTClose( cSm3Weeg )
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      fBox( 3, 2, maxrow()-4, maxcol()-3, "Bewaar moeder massas vir indeksberekeninge", cColNorm() )
      @ 5, 4 say "         Indeksgroep"
      @ 6, 4 say "      Indeksouderdom"
      @ 7, 4 say "              Geslag"
      @ 8, 4 say "     Lewendig of nie"
      @ 5, 44 say "     Diere in groep"
      @ 6, 44 say "   Diere met massas"
      @ 7, 44 say "   Gemiddelde massa"
      @ 8, 44 say "       Totale massa"
   else
      fBox( 3, 2, maxrow()-4, maxcol()-3, "Enter dam masses for index calculations", cColNorm() )
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

   //Vra die indeksgroep, groep of seleksiegroep
   aCscr := fASaveScr()
   nCh := fNewMenu( nCh, "SM3MOEMa" )
   cOption(nCh)

   do case
      case nCh == 1
         //Indeksgroep
         //Kry die indeksgroep
         cIndg := sm3indg(4)
         fARestScr(aCscr)

         if len(trim(cIndg)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen indeksgroep is gekies nie!")
            else
               fScrWait(24,"No index group was selected!")
            endif
            cOption(-1)
            return NIL
         endif

         //Vertoon indeksgroep
         setcolor( cColInve() )
         @ 5,25 say cIndg
         setcolor( cColNorm() )

         //Kyk of daar wel diere is vir die indeksgroep
         select SM3DATA
         set order to 3
         seek cIndg
         copy to (cDd()+"mass") fields idnr, idmoer, geslag, uitkrede while SM3DATA->indekskode == cIndg
         set order to 1

      case nCh == 2
         //Groep
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
            //Skep leer met name van diere om te weeg
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
            else
               fScrBood(24,"Calves qualifying with the group requirements being sorted.")
            endif
            copy to (cDd()+"mass") fields idnr, idmoer, geslag, uitkrede for &cTest.
         else
            fScrBood(23)
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif
            cOption(-1)
            return NIL
         endif

      case nCh == 3
         //Seleksiegroep
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
            //Skep leer met name van diere om te weeg
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
            else
               fScrBood(24,"Calves qualifying with the group requirements being sorted.")
            endif
            copy to (cDd()+"mass") fields idnr, idmoer, geslag, uitkrede for &cTest.
         else
            fScrBood(23)
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No selection group requirements have been specified!")
            endif
            cOption(-1)
            return NIL
         endif

      otherwise
         //Herstel
         fTClose( cSm3Weeg )
         fTClose( cSm3Data )
         cOption(-1)
         return NIL
   endcase

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   //Open dataleer met massas
   ferase(cIndf)
   cMass := fTOpen( cDd(), "mass", , "dbf", , .f. )
   if left( cMass, 1 ) == "f"
      fTClose( cSm3Weeg )
      fTClose( cSm3Data )
      cOption(-1)
      return NIL
   endif

   //Kyk of daar diere in die leer is
   if lastrec() == 0
      if cLanType() == "A"
         fScrBood(23,"Geen moeders kon gevind word om te weeg nie!")
      else
         fScrBood(23,"No dams found to be weighed!")
      endif
      fScrWait(24)
      fTClose( cSm3Weeg )
      fTClose( cSm3Data )
      fTClose( cMass )
      cOption(-1)
      return NIL
   endif

   //Vertoon die ouderdom
   cOude := "205"
   setcolor( cColInve() )
   if cLanType() == "A"
      @ 6,25 say cOude + " dae"
   else
      @ 6,25 say cOude + " days"
   endif
   setcolor( cColNorm() )

   //Vra die volgorde
   aCscr := fASaveScr()
   nCh := fNewMenu( 1, "SM3MOEMb" )
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
         //Indeks die leer
         index on MASS->IDMOER to (cIndf)
         set index to (cIndf)
      otherwise
         //Herstel
         fTClose( cSm3Weeg )
         fTClose( cSm3Data )
         fTClose( cMass )
         cOption(-2)
         return NIL
   endcase

   //Vra geslag
   aCscr := fASaveScr()
   nCh := fNewMenu( 1, "SM3MOEMc" )
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
            fTClose( cSm3Weeg )
            fTClose( cSm3Data )
            fTClose( cMass )
            cOption(-3)
            return NIL
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
            fTClose( cSm3Weeg )
            fTClose( cSm3Data )
            fTClose( cMass )
            cOption(-3)
            return NIL
      endcase
   endif

   //Vra lewendig of nie
   aCscr := fASaveScr()
   nCh := fNewMenu( 1, "SM3MOEMd" )
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
            fTClose( cSm3Weeg )
            fTClose( cSm3Data )
            fTClose( cMass )
            cOption(-4)
            return NIL
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
            fTClose( cSm3Weeg )
            fTClose( cSm3Data )
            fTClose( cMass )
            cOption(-4)
            return NIL
      endcase
   endif

   //Verwyder diere sonder ma's
   select MASS
   go top
   do while !(eof())
      if MASS->idmoer <> space(12)
      else
         if rlock()
            delete
            dbUnlock()
         endif
      endif
      skip
   enddo
   go top

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
         fScrBood(23,"Geen moeders het oorgebly vir wie massas bewaar kan word nie!")
      else
         fScrBood(23,"No dams remain for which masses can be entered!")
      endif
      fScrWait(24)
      fTClose( cSm3Weeg )
      fTClose( cSm3Data )
      fTClose( cMass )
      cOption(-4)
      return NIL
   endif

   //Set relation
   set relation to MASS->IDNR into SM3DATA

   // Read dam mass at wean from regular weighings
   aCscr := fASaveScr()
   nCh := fNewMenu( 1, "SM3MOEMe" )
   cOption(nCh)
   fARestScr(aCscr)

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
   else
      fScrOpsk(1,"Option "+cOption())
   endif

   do case
      case nCh == 1
         // Type masses by hand
      case nCh == 2
         // Read from regular weighings
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Moermassas word gelees vanaf die gereelde wegings lˆer")
         else
            fScrWbood(24,"Damm masses being read from regular weighings")
         endif
         select MASS
         go top
         do while !(eof())

            cDamm := MASS->idmoer

            // Seek dam in regular weighings
            select SM3WEEG
            seek cDamm
            do while !(eof()) .and. SM3WEEG->idnr == cDamm
               if SM3WEEG->weegdatum >= SM3DATA->dat205 .and. SM3WEEG->weegdatum <= SM3DATA->dat205+60
                  // Save data
                  select SM3DATA
                  if rlock()
                     SM3DATA->mamoerspe := SM3WEEG->massa
                     dbUnlock()
                  endif
                  select SM3WEEG
                  go bottom
               endif
               skip
            enddo

            // Next animal
            select MASS
            skip

         enddo
         go top

      otherwise

         //Herstel
         fTClose( cSm3Weeg )
         fTClose( cSm3Data )
         fTClose( cMass )
         cOption(-4)
         return NIL

   endcase

   // Read dam mass at birth from regular weighings
   if fJaNee(,iif(cLanType()=="A","Moet moedermassas by geboorte ook vanaf gereelde wegings gelees word?","Should dam masses at birth also be read from regular weighings?"))

      fScrBood(23)
      if cLanType() == "A"
         fScrWbood(24,"Moermassas word gelees vanaf die gereelde wegings lˆer")
      else
         fScrWbood(24,"Damm masses being read from regular weighings")
      endif
      select MASS
      go top
      do while !(eof())

         cDamm := MASS->idmoer

         // Seek dam in regular weighings
         select SM3WEEG
         seek cDamm
         do while !(eof()) .and. SM3WEEG->idnr == cDamm
            if SM3WEEG->weegdatum >= SM3DATA->gebdatum .and. SM3WEEG->weegdatum <= SM3DATA->gebdatum+60
               // Save data
               select SM3DATA
               if rlock()
                  SM3DATA->mamoergeb := SM3WEEG->massa
                  dbUnlock()
               endif
               select SM3WEEG
               go bottom
            endif
            skip
         enddo

         // Next animal
         select MASS
         skip

      enddo
      go top

   endif

   // Doen die berekeninge
   select MASS
   go top
   do while !(eof())
      if SM3DATA->mamoerspe > 0
         nAant := nAant + 1
         nTota := nTota + SM3DATA->mamoerspe
      endif
      skip
   enddo
   go top

   //Skerm
   if cLanType() == "A"
      @12, 4 say "          Id nommer"
      @14, 4 say "   Moeder Id nommer"
      @16, 4 say "              Massa"
   else
      @12, 4 say "          Id number"
      @14, 4 say "      Dam Id number"
      @16, 4 say "               Mass"
   endif

   select MASS
   go top
   do while !eof()

      //Vertoon id nommer
      setcolor( cColInve() )
      @12, 4+21 say MASS->idnr
      @14, 4+21 say MASS->idmoer
      @16, 4+21 say transform( SM3DATA->mamoerspe, "999" )
      @ 5, 44+21 say transform( lastrec(), "999999" )
      @ 6, 44+21 say transform( nAant    , "999999" )
      if nAant > 0
         @ 7, 44+21 say transform( nTota/nAant    , "9999.9" )
      else
         @ 7, 44+21 say transform( 0              , "9999.9" )
      endif
      @ 8, 44+21 say transform( nTota    , "999999" )
      setcolor( cColNorm() )

      //Vra die massa

      //Kry die bestaande massa
      nMass := SM3DATA->mamoerspe

      //Trek totale af
      if nMass > 0
         nAant--
         nTota = nTota - nMass
      endif

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "Tik die moeder se massa toe die kalf gespeen is!" )
         fScrBood( 24, "[Esc]=Menu  [PgUp]=Vorige moeder" )
      else
         fScrBood( 23, "Type the dam's mass when the calf was weaned!" )
         fScrBood( 24, "[Esc]=Menu  [PgUp]=Previous dam" )
      endif

      //Vra die massa
      @16, 4+21 get nMass pict "999"
      readexit(.t.)
      set cursor on
      read
      set cursor off
      readexit(.f.)

      //Bewaar totale
      if nMass > 0
         nAant++
         nTota := nTota + nMass
      endif

      //Bewaar inligting
      select SM3DATA
      if rlock()
         SM3DATA->mamoerspe := nMass
         dbUnlock()
      endif

      //Bewaar inligting in wegingsleer
      if SM3DATA->dat205 <> ctod("  /  /  ") .and. nMass > 0
         select SM3WEEG
         cData := MASS->idmoer + dtos( SM3DATA->dat205 )
         seek cData
         if eof()
            append blank
         endif
         if rlock()
            SM3WEEG->idnr      := MASS->idmoer
            SM3WEEG->weegdatum := SM3DATA->dat205
            SM3WEEG->massa     := nMass
            dbUnlock()
         endif
      endif

      select MASS

      do case

         case lastkey() == K_ESC
            //Exit
            go bottom
            skip

         case lastkey() == K_ENTER
            //Bewaar massa

            //Volgende dier
            skip

            //Indien einde van leer
            if eof()
               if cLanType() == "A"
                  fScrBood(23,"Hierdie was die laaste moeder van die groep!")
               else
                  fScrBood(23,"This was the last dam in the group!")
               endif
               fScrWait(24)
            endif

         case lastkey() = K_PGUP
            //vorige dier
            skip -1
            if bof()
               go top
            endif

      endcase

   enddo

   //Herstel
   fTClose( cSm3Weeg )
   fTClose( cSm3Data )
   fTClose( cMass )
   cOption(-4)

return NIL

