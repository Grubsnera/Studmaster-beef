//SM3HAND.PRG
//Program om leer te skep vir handrekenaar
//Kopiereg (C) 1992 A van Rensburg
//09:24 01 Apr,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3hand

   //Verklaar
   nCh := 1

   //Vra of massas gestuur of gelees moet word
   // Vertoon hulpskerm
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
   endif
   nCh := fNewMenu( nCh, "SM3HAND" )

   do case
      case nCh == 1
         fStuur()
      case nCh == 2
         fOntvang()
   endcase

   //Herstel
return NIL

/****************************************************************************/
STATIC FUNCTION fStuur

   //Verklaar
   local getlist  := {}
   local cCurScr  := ""
   local cCurDbf  := ""
   local cSm3Data := ""
   local cSm3Indg := ""
   local cSm3Fasg := ""
   local sSm3Mash := ""
   local cMass    := ""
   local nCh      := 1
   local lLoop    := .t.
   local cIndg    := "      "
   local cFasg    := "      "
   local aVelde   := {}
   local cTest    := ""
   local cOude    := ""

   local cData    := ""
   local lQues    := .f.

   //Open dataleers
   if cLanType() == "A"
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrWbood( 24, "Data files being opened" )
   endif

   cSm3Data := fTOpen( cDd(), "sm3data", , "dbf", , .t. )
   if left( cSm3Data, 1 ) == "f"
      return NIL
   endif

   //Skerm
   if cLanType() == "A"
      fScrOpsk(,"BJ Handrekenaar")
   else
      fScrOpsk(,"BJ Handheld computer")
   endif

   //Vra watter diere geweeg gaan word
   // Vertoon hulpskerm
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
   endif
   nCh := fNewMenu( nCh, "SM3HANDa" )

   do case

      case nCh == 1
         //Indeksgroep
         lLoop := .t.
         do while lLoop

            //Vra die indeksgroep
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  "+D_DNARR+"=Bestaande indeksgroepe" )
               fScrBood( 24, "Watter INDEKSGROEP kalwers se massas moet bewaar word?" )
            else
               fScrBood( 23, "[Esc]=Menu  "+D_DNARR+"=Existing index groups" )
               fScrBood( 24, "Which INDEX GROUP of calves masses should be entered?" )
            endif
            @ 5,26 get cIndg pict "@!"
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            setcolor( cColInve() )
            @ 5,26 say cIndg
            setcolor( cColNorm() )

            do case
               case lastkey() == K_ESC
                  //Exit
                  //Herstel
                  fTClose( cSm3Data )
                  return NIL
               case lastkey() == K_ENTER .and. cIndg <> "      "
                  //Aanvaar groep

                  //Kyk of daar wel diere is vir die indeksgroep
                  select SM3DATA
                  set order to 3
                  seek cIndg
                  if eof()
                     if cLanType() == "A"
                        fScrBood(23,"Geen kalwers kon gevind word wat aan die indeksgroep behoort nie!")
                     else
                        fScrBood(23,"No calves belonging to the index group could be found!")
                     endif
                     fScrWait(24)
                     loop
                  endif

                  //Skep leer met name van diere om te weeg
                  fScrBood(23)
                  if cLanType() == "A"
                     fScrBood(24,"Kalwers wat behoort aan die indeksgroep word uitgesoek.")
                  else
                     fScrBood(24,"Calves belonging to the index group being sorted.")
                  endif
                  copy to (cDd()+"mass") fields idnr, geslag, uitkdatum while indekskode == cIndg

                  //Herstel data
                  set order to 1
                  go top

                  lLoop := .f.

               case lastkey() == K_DOWN
                  //Vertoon reeds bestaande indeksgroepe
                  asize( aVelde, 0 )
                  aadd( aVelde, { "sm3indg", "kode" })
                  aadd( aVelde, { "sm3indg", "besk" })
                  cIndg := sm3indg( 4, 45, 20, aVelde, cIndg )
            endcase
         enddo

      case nCh == 2
         //Fasegroep
         lLoop := .t.
         do while lLoop

            //Vra die fasegroep
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Menu  "+D_DNARR+"=Bestaande fasegroepe" )
               fScrBood( 24, "Watter FASE D GROEP bulletjies se massas moet bewaar word?" )
            else
               fScrBood( 23, "[Esc]=Menu  "+D_DNARR+"=Existing phase groups" )
               fScrBood( 24, "Which PHASE D GROUP bull masses should be entered?" )
            endif
            @ 6,26 get cFasg pict "@!"
            readexit(.t.)
            set cursor on
            read
            set cursor off
            readexit(.f.)
            setcolor( cColInve() )
            @ 6,26 say cFasg
            setcolor( cColNorm() )

            do case
               case lastkey() == K_ESC
                  //Exit
                  //Herstel
                  fTClose( cSm3Data )
                  return NIL
               case lastkey() == K_ENTER .and. cFasg <> "      "
                  //Aanvaar groep
                  //Kyk of daar wel diere is vir die indeksgroep
                  select SM3DATA
                  set order to 2
                  seek cFasg
                  if eof()
                     if cLanType() == "A"
                        fScrBood(23,"Geen kalwers kon gevind word wat aan die Fase D groep behoort nie!")
                     else
                        fScrBood(23,"No calves belonging to the Phase D group could be found!")
                     endif
                     fScrWait(24)
                     loop
                  endif

                  //Skep leer met name van diere om te weeg
                  fScrBood(23)
                  if cLanType() == "A"
                     fScrBood(24,"Kalwers wat behoort aan die Fase D groep word uitgesoek.")
                  else
                     fScrBood(24,"Calves belonging to the Phase D group being sorted.")
                  endif
                  copy to (cDd()+"mass") fields idnr, geslag, uitkdatum while fasekode == cFasg

                  //Herstel data
                  set order to 1
                  go top

                  lLoop := .f.

               case lastkey() == K_DOWN
                  //Vertoon reeds bestaande indeksgroepe
                  asize( aVelde, 0 )
                  aadd( aVelde, { "sm3fasg", "kode" })
                  aadd( aVelde, { "sm3fasg", "besk" })
                  cFasg := sm3fasg( 4, 45, 20, aVelde, cFasg )
            endcase
         enddo

      case nCh == 3
         //Groep
         setcolor( cColInve() )
         @ 7,25 say "      û"
         setcolor( cColNorm() )
         cTest := sm3groe()
         if len( cTest ) > 0
            //Skep leer met name van diere om te weeg
            fScrBood(23)
            if cLanType() == "A"
               fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
            else
               fScrBood(24,"Calves qualifying with the group requirements being sorted.")
            endif
            copy to (cDd()+"mass") fields idnr, geslag, uitkdatum for &cTest.
         else
            fScrBood(23)
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif
            return NIL
         endif

      otherwise
         //Herstel
         fTClose( cSm3Data )
         return NIL
   endcase

   //Open dataleer met massas
   cMass := fTOpen( cDd(), "mass", , "dbf", , .f. )
   if left( cMass, 1 ) == "f"
      fTClose( cSm3Data )
      return NIL
   endif

   //Kyk of daar diere in die leer is
   if lastrec() == 0
      if cLanType() == "A"
         fScrBood(23,"Geen kalwers kon gevind word vir weging nie!")
      else
         fScrBood(23,"No calves to be weighed could be found!")
      endif
      fScrWait(24)
      fTClose( cMass )
      fTClose( cSm3Data )
      return NIL
   endif

   //Vra indeksouderdom
   lLoop := .t.
   do while lLoop
      //Cursor moet op fase d staan indien fase d
      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
      endif
      nCh := fNewMenu( if(cFasg=="      ",1,6), "SM3HANDb" )
      do case
         case nCh == 1
            cOude := "1"
         case nCh == 2
            cOude := "2"
         case nCh == 3
            cOude := "3"
         case nCh == 4
            cOude := "4"
         case nCh == 5
            cOude := "5"
         case nCh == 6
            cOude := "6"
         case nCh == 7
            cOude := "0"
         otherwise
            //Herstel
            fTClose( cMass )
            fTClose( cSm3Data )
            return NIL
      endcase
      lLoop := .f.
   enddo

   //Vra geslag
   // Vertoon hulpskerm
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
   endif
   nCh := fNewMenu( if(cFasg=="      ",1,3), "SM3HANDc" )
   do case
      case nCh == 1
      case nCh == 2
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Manlike diere word verwyder")
         else
            fScrWbood(24,"Male animals being removed")
         endif
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
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Vroulike diere word verwyder")
         else
            fScrWbood(24,"Female animals being removed")
         endif
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
         fTClose( cMass )
         fTClose( cSm3Data )
         return NIL
   endcase

   //Vra lewendig of nie
   // Vertoon hulpskerm
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
   endif
   nCh := fNewMenu( 2, "SM3HANDd" )
   do case
      case nCh == 1
      case nCh == 2
         fScrBood(23)
         if cLanType() == "A"
            fScrWbood(24,"Lewendige kalwers word uitgesoek")
         else
            fScrWbood(24,"Live calves being sorted")
         endif
         select MASS
         go top
         do while !(eof())
            if MASS->uitkdatum == ctod("  /  /  ")
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
         fTClose( cMass )
         fTClose( cSm3Data )
         return NIL
   endcase

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
         fScrBood(23,"Geen kalwers het oorgebly vir wie massas geneem kan word nie!")
      else
         fScrBood(23,"No calves remain for which masses can be taken!")
      endif
      fScrWait(24)
      fTClose( cMass )
      fTClose( cSm3Data )
      return NIL
   endif

   //Set relation
   set relation to MASS->IDNR into SM3DATA

   //Open .dbf
   if cLanType() == "A"
      fScrbood(23)
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrbood(23)
      fScrWbood( 24, "Data files being opened" )
   endif
   cSm3mash := fTOpen( cDd(), "sm3mash", , "dbf", , .f. )
   if left( cSm3mash, 1 ) == "f"
      fTClose( cMass )
      fTClose( cSm3Data )
      return NIL
   endif

   //Indien daar diere in leer is, wat moet daarmee gebeur
   if lastrec() > 0
      if cLanType() == "A"
         if fJaNee( 24, "Moet bestaande diere in handrekenaarlˆer geskrap word?" )
            zap
         endif
      else
         if fJaNee( 24, "Should animals currently in handheld computer file be deleted?")
            zap
         endif
      endif
   endif

   //Indien speen, moet moedermassas ook bewaar word
   if cOude == "2"
      if cLanType() == "A"
         lQues := fJaNee( 24, "Gaan die moeders van die kalwers ook geweeg word?" )
      else
         lQues := fJaNee( 24, "Are the mothers of the calves also to be weighed?" )
      endif
   endif

   //Skerm
   fScrBood( maxrow()-1 )
   if cLanType() == "A"
      fScrWbood( maxrow(), "Kalwers word oorgedra na handrekenaar lˆer" )
   else
      fScrWbood( maxrow(), "Calves being transferred to handheld computer file")
   endif

   //Bewaar die diere
   select MASS
   do while !( eof() )

      //Moet bewaar word indien nie bestaan
      cData := MASS->idnr

      if len( trim( cData ) ) > 0
         select SM3MASH
         seek cData
         if eof()
            append blank

            do case
               case cOude == "0"
                  SM3MASH->idnr := MASS->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
               case cOude == "1"
                  SM3MASH->idnr := MASS->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->datu := SM3DATA->dat100
                  SM3MASH->mass := SM3DATA->mas100
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
               case cOude == "2"
                  SM3MASH->idnr := MASS->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->datu := SM3DATA->dat205
                  SM3MASH->mass := SM3DATA->mas205
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
               case cOude == "3"
                  SM3MASH->idnr := MASS->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->datu := SM3DATA->dat365
                  SM3MASH->mass := SM3DATA->mas365
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
               case cOude == "4"
                  SM3MASH->idnr := MASS->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->datu := SM3DATA->dat540
                  SM3MASH->mass := SM3DATA->mas540
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
               case cOude == "5"
                  SM3MASH->idnr := SM3DATA->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
               case cOude == "6"
                  SM3MASH->idnr := SM3DATA->idnr
                  SM3MASH->tipe := cOude
                  SM3MASH->gesl := SM3DATA->geslag
                  SM3MASH->gebd := SM3DATA->gebdatum
            endcase
         endif
      endif

      select MASS
      skip

   enddo
   go top

   if lQues
      //Bewaar ook die moeders van die kalwers
      //Bewaar die diere
      select MASS
      do while !( eof() )

         //Moet bewaar word indien nie bestaan
         cData := SM3DATA->idmoer

         if len( trim( cData ) ) > 0
            select SM3MASH
            seek cData
            if eof()
               append blank
               SM3MASH->idnr := SM3DATA->idmoer
               SM3MASH->tipe := "8"
               SM3MASH->datu := SM3DATA->dat205
               SM3MASH->mass := SM3DATA->mamoerspe
               SM3MASH->gesl := "1"
               SM3MASH->gebd := SM3DATA->gebdatum
            endif
         endif

         select MASS
         skip

      enddo
      go top
   endif

   //Handmassaleer
   select SM3MASH
   go top

   //Text leer
   set alternate to (cDd()+"mass.odb")
   set alternate on
   set cons off

   //Skep 'n text leer
   do while !( eof() )

      ?? alltrim( SM3MASH->idnr ) + "," + ;
         alltrim( SM3MASH->tipe ) + "," + ;
         alltrim( dtos( SM3MASH->datu ) ) + "," + ;
         alltrim( str( SM3MASH->mass ) ) + "," + ;
         alltrim( SM3MASH->gesl ) + "," + ;
         alltrim( dtos( SM3MASH->gebd ) ) + ;
         chr(13) + chr(10)

      skip

   enddo

   //Herstel
   set cons on
   set alternate off
   set alternate to
   fTClose( cSm3mash )
   fTClose( cMass )
   fTClose( cSm3Data )

   //Dra inligting oor op handrekenaar
   if file("cl.exe")
      //Organiser series 2 comms program is available
      clear screen
      if cLanType() == "A"
         @ 0, 0 say "Kies die opsie op die handrekenaar om inligting te ontvang!"
      else
         @ 0, 0 say "Choose the option to receive information on handheld computer!"
      endif
      @ 2, 0 say ""
      run cl
   else
      if cLanType() == "A"
         fScrBood(23,"Geen handrekenaar sagteware is beskikbaar nie!")
      else
         fScrBood(23,"No handheld computer software is available!")
      endif
      fScrWait(24)
   endif

   //Herstel
return NIL

/**************************************************************************/
STATIC FUNCTION fOntvang

   //Verklaar
   cSm3Weeg := ""
   cSm3Data := ""
   cSm3Mash := ""
   cData    := ""
   nReko    := 0

   //Verwyder bestaande leer teks
   //ferase( cDd()+"mass.odb" )

   //Vra inligting vanaf handrekenaar
   //if file("cl.exe")
   //   //Organiser series 2 comms program is available
   //   clear screen
   //   @ 0, 0 say "Kies die opsie op die handrekenaar om inligting te stuur!"
   //   @ 0, 0 say "Choose the option to send information on the handheld computer!"
   //   @ 2, 0 say ""
   //   run cl
   //else
   //   fScrBood(23,"Geen handrekenaar sagteware is beskikbaar nie!")
   //   fScrWait(24)
   //   return NIL
   //endif

   //Skerm
   if cLanType() == "A"
      fScrOpsk(,"BJ Handrekenaar")
   else
      fScrOpsk(,"BJ Handheld computer")
   endif

   //Massa text leer moet nou bestaan
   if file(cDd()+"mass.odb")
   else
      if cLanType() == "A"
         fScrBood(23,"Geen massas is gelees vanaf die handrekenaar nie!")
      else
         fScrBood(23,"No masses have been read from the handheld computer!")
      endif
      fScrWait(24)
      return NIL
   endif

   //Open dataleers
   if cLanType() == "A"
      fScrWbood( 24, "Datalˆers word geopen" )
   else
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

   cSm3Mash := fTOpen( cDd(), "sm3mash", , "dbf", , .f. )
   if left( cSm3Mash, 1 ) == "f"
      fTClose( cSm3Weeg )
      fTClose( cSm3Data )
      return NIL
   endif

   //Open dataleers
   if cLanType() == "A"
      fScrWbood( 24, "Lees inligting vanaf handrekenaarlˆer" )
   else
      fScrWbood( 24, "Read information from handheld computer file" )
   endif

   //Maak leer skoon
   zap

   //Lees inligting
   append from (cDd()+"mass.odb") delimited

   //Geen data gelees
   if lastrec() > 0
   else
      if cLanType() == "A"
         fScrBood(23,"Geen massas is gelees vanaf die handrekenaar nie!")
      else
         fScrBood(23,"No masses have been read from the handheld computer!")
      endif
      fScrWait(24)
      fTClose( cSm3Weeg )
      fTClose( cSm3Data )
      fTClose( cSm3Mash )
      return NIL
   endif

   //Bewaar data
   select SM3MASH
   go top

   //Stel relation
   set relation to SM3MASH->idnr into SM3DATA

   do while !( eof() )

      //Massa moet bestaan
      if SM3MASH->mass > 0 .and. SM3MASH->datu <> ctod("  /  /  ")

         do case
            case SM3MASH->tipe == "1"
               //Bewaar indeksmassas in hoofleer
               select SM3DATA
               if !( eof() ) .and. rlock()
                  SM3DATA->dat100 := SM3MASH->datu
                  SM3DATA->mas100 := SM3MASH->mass
                  dbUnlock()
               endif
               //Bewaar massas in wegingsleer
               cData := SM3MASH->idnr + dtos( SM3MASH->datu )
               select SM3WEEG
               seek cData
               if eof()
                  append blank
               endif
               if rlock()
                  SM3WEEG->idnr      := SM3MASH->idnr
                  SM3WEEG->weegdatum := SM3MASH->datu
                  SM3WEEG->massa      := SM3MASH->mass
                  dbUnlock()
               endif

            case SM3MASH->tipe == "2"
               //Bewaar indeksmassas in hoofleer
               select SM3DATA
               if !( eof() ) .and. rlock()
                  SM3DATA->dat205 := SM3MASH->datu
                  SM3DATA->mas205 := SM3MASH->mass
                  dbUnlock()
               endif
               //Bewaar massas in wegingsleer
               cData := SM3MASH->idnr + dtos( SM3MASH->datu )
               select SM3WEEG
               seek cData
               if eof()
                  append blank
               endif
               if rlock()
                  SM3WEEG->idnr      := SM3MASH->idnr
                  SM3WEEG->weegdatum := SM3MASH->datu
                  SM3WEEG->massa      := SM3MASH->mass
                  dbUnlock()
               endif
            case SM3MASH->tipe == "3"
               //Bewaar indeksmassas in hoofleer
               select SM3DATA
               if !( eof() ) .and. rlock()
                  SM3DATA->dat365 := SM3MASH->datu
                  SM3DATA->mas365 := SM3MASH->mass
                  dbUnlock()
               endif
               //Bewaar massas in wegingsleer
               cData := SM3MASH->idnr + dtos( SM3MASH->datu )
               select SM3WEEG
               seek cData
               if eof()
                  append blank
               endif
               if rlock()
                  SM3WEEG->idnr      := SM3MASH->idnr
                  SM3WEEG->weegdatum := SM3MASH->datu
                  SM3WEEG->massa      := SM3MASH->mass
                  dbUnlock()
               endif
            case SM3MASH->tipe == "4"
               //Bewaar indeksmassas in hoofleer
               select SM3DATA
               if !( eof() ) .and. rlock()
                  SM3DATA->dat540 := SM3MASH->datu
                  SM3DATA->mas540 := SM3MASH->mass
                  dbUnlock()
               endif
               //Bewaar massas in wegingsleer
               cData := SM3MASH->idnr + dtos( SM3MASH->datu )
               select SM3WEEG
               seek cData
               if eof()
                  append blank
               endif
               if rlock()
                  SM3WEEG->idnr      := SM3MASH->idnr
                  SM3WEEG->weegdatum := SM3MASH->datu
                  SM3WEEG->massa      := SM3MASH->mass
                  dbUnlock()
               endif
            case SM3MASH->tipe == "8"
               //Moedermassas
               cData := SM3MASH->idnr
               select SM3DATA
               nReko := recno()
               set order to 4
               seek cData
               do while !(eof()) .and. SM3DATA->idmoer == cData
                  if SM3DATA->gebdatum == SM3MASH->gebd
                     cData := SM3DATA->idnr
                     exit
                  endif
                  skip
               enddo
               set order to 1
               seek cData
               if !( eof() ) .and. rlock()
                  SM3DATA->mamoerspe := SM3MASH->mass
                  dbUnlock()
               endif
               goto nReko
               //Bewaar massas in wegingsleer
               cData := SM3MASH->idnr + dtos( SM3MASH->datu )
               select SM3WEEG
               seek cData
               if eof()
                  append blank
               endif
               if rlock()
                  SM3WEEG->idnr      := SM3MASH->idnr
                  SM3WEEG->weegdatum := SM3MASH->datu
                  SM3WEEG->massa      := SM3MASH->mass
                  dbUnlock()
               endif

            otherwise
               //Bewaar slegs in wegingsleer
               //Bewaar massas in wegingsleer
               cData := SM3MASH->idnr + dtos( SM3MASH->datu )
               select SM3WEEG
               seek cData
               if eof()
                  append blank
               endif
               if rlock()
                  SM3WEEG->idnr      := SM3MASH->idnr
                  SM3WEEG->weegdatum := SM3MASH->datu
                  SM3WEEG->massa      := SM3MASH->mass
                  dbUnlock()
               endif
         endcase

      endif

      select SM3MASH
      skip

   enddo

   //Herstel
   fTClose( cSm3Weeg )
   fTClose( cSm3Mash )
   fTClose( cSm3Data )
return NIL

