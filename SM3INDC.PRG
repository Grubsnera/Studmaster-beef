//SM3INDC.PRG
//Program om indekse te bereken
//Kopiereg (C) 1995 A van Rensburg
//03-27-95 02:39pm

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3indc

   //Verklaar
   local cGetList := {}
   local aCscr    := {}
   local cCurDbf  := ""
   local cSm3Data := ""
   local nCh      := 1
   local cIndg    := "      "
   local aVelde   := {}
   local cMass    := ""
   local cManl    := ""
   local cVrou    := ""
   local cKorr    := ""
   local nForm    := 4
   local lLoop    := .t.
   local cData    := ""
   local cVeld    := ""
   local nData    := 0
   local cTest    := ""
   local cDummy   := ""
   local cIkode   := "  "
   local nBoxc    := 0
   local cBrep := ""

   //Verklaar veranderlikes vir berekening van moederouderdom
   local nJ       := 0
   local nM       := 0
   local nMj      := 0
   local nMm      := 0
   local nMd      := 0
   local nKj      := 0
   local nKm      := 0
   local nKd      := 0
   local nPaan1   := 0
   local nPtot1   := 0
   local nPave1   := 0
   local nGaan1   := 0
   local nGtot1   := 0
   local nGave1   := 0
   local nGreg1   := 0
   local nPaan2   := 0
   local nPtot2   := 0
   local nPave2   := 0
   local nGaan2   := 0
   local nGtot2   := 0
   local nGave2   := 0
   local nGreg2   := 0
   local nKSAan1  := 0
   local nKSTot1  := 0
   local nKSAvg1  := 0
   local nKSAan2  := 0
   local nKSTot2  := 0
   local nKSAvg2  := 0
   local nSSAan1  := 0
   local nSSTot1  := 0
   local nSSAvg1  := 0
   local nSSAan2  := 0
   local nSSTot2  := 0
   local nSSAvg2  := 0
   local nTell    := 0
   local nIndv    := 0
   local nVort    := 0
   local nVori    := 0

   private cOude    := ""

   cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

   //Skerm

   // Vra die indekskode
   // if cLanType() == "A"
   //    fScrOpsk(,"Opsie "+cOption())
   //    nBoxc := fBoxCent(11,"Indekskode? xx",3)
   //    fScrBood(maxrow()-1,"[Esc]=Menu  [Enter]=Almal")
   //    fScrBood(maxrow(),"Vir watter indekskode moet berekeninge gedoen word? Laat oop indien almal!")
   //    @12,nBoxc say "Indekskode?" get cIkode
   // else
   //    fScrOpsk(,"Option "+cOption())
   //    nBoxc := fBoxCent(11,"Index code? xx",3)
   //    fScrBood(maxrow()-1,"[Esc]=Menu  [Enter]=All")
   //    fScrBood(maxrow(),"For which index code must calculations be done? Leave open if for all!")
   //    @12,nBoxc say "Index code?" get cIkode pict "99"
   // endif
   // set cursor on
   // read
   // set cursor off
   // if lastkey() == K_ESC
   //    return NIL
   // endif

   //Open dataleers
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
      fScrWbood( 24, "Datalˆers word geopen" )
   else

      fScrOpsk(,"Option "+cOption())
      fScrWbood( 24, "Data files being opened" )
   endif

   cSm3Data := fTOpen( cDd(), "sm3data", , "dbf", , .f. )
   if left( cSm3Data, 1 ) == "f"
      return NIL
   endif

   //Vra watter diere geweeg gaan word
   // Vertoon hulpskerm
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
   endif

   nCh := fNewMenu( nCh, "SM3INDCa" )
   cOption(nCh)
   aCscr := fASaveScr()

   do case

      case nCh == 1
         //Kry die indeksgroep
         cIndg := sm3indg(4)
         if len(trim(cIndg)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen indeksgroep is gekies nie!")
            else
               fScrWait(24,"No index group was selected!")
            endif

            cOption(-1)
            return NIL

         endif

         //Kyk of daar wel diere is vir die indeksgroep
         select SM3DATA
         set order to 3
         seek cIndg
         copy to (cDd()+"mass") fields ;
            idnr,;                               //Nommer van dier
            geslag,;                             //Geslag van dier
            kalfbnr,;                            //Waarskuwings
            gemspeeni,;                          //Moeder gemiddelde speenindeks
            gemspeena,;                          //Korreksiefaktor
            mamoergeb,;                          //Moeder ouderdom
            idmoer,;                             //Moeder id nommer
            gebdatum,;                           //kalf geboortedatum
            gebmassa,;                           //Kalf geboortemassa
            ind100,;                             //Indeks
            uitkdatum,;                          //Datum uit kudde
            compos;                              //Sal gebruik word om Moeder speen massa van vorige kalf tydelik te stoor
            while SM3DATA->indekskode == cIndg
            set order to 1

         case nCh == 2
            //Groep
            cTest := sm3groe()
            if len( cTest ) > 0
               //Skep leer met name van diere om te weeg
               fScrBood(23)
               if cLanType() == "A"
                  fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
               else
                  fScrBood(24,"Calves qualifying with the group requirements being sorted.")
               endif
               copy to (cDd()+"mass") fields ;
                  idnr,;                         //Nommer van dier
                  geslag,;                       //Geslag van dier
                  kalfbnr,;                      //Waarskuwings
                  gemspeeni,;                    //Moeder gemiddelde speenindeks
                  gemspeena,;                    //Korreksiefaktor
                  mamoergeb,;                    //Moeder ouderdom
                  idmoer,;                       //Moeder id nommer
                  gebdatum,;                     //kalf geboortedatum
                  gebmassa,;                     //Kalf geboortemassa
                  ind100,;                       //Indeks
                  uitkdatum,;                    //Datum uit kudde
                  compos;                        //Sal gebruik word om Moeder speen massa van vorige kalf tydelik te stoor
                  for &(cTest)
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
               cTest := sm3selg()
               if len( cTest ) > 0
                  //Skep leer met name van diere om te weeg
                  fScrBood(23)
                  if cLanType() == "A"
                     fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
                  else
                     fScrBood(24,"Calves qualifying with the group requirements being sorted.")
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
                     uitkdatum,;                 //Datum uit
                     compos;                     //Sal gebruik word om Moeder speen massa van vorige kalf tydelik te stoor
                     for &(cTest)
                  else
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWait(24,"Geen seleksiegroep seleksie-vereistes is gespesifiseer nie!")
                     else
                        fScrWait(24,"No selection group selection requirements have been specified!")
                     endif

                     cOption(-1)
                     return NIL
                  endif

               otherwise
                  //Herstel
                  fTClose( cSm3Data )
                  cOption(-1)
                  return NIL
            endcase

            fARestScr(aCscr)

            if cLanType() == "A"
               fScrOpsk(1,"Opsie "+cOption())
            else
               fScrOpsk(1,"Option "+cOption())
            endif

            //Open dataleer met massas
            ferase(cDd()+"mass"+cIndeExt())
            cMass := fTOpen( cDd(), "mass", , "dbf", , .f. )
            if left( cMass, 1 ) == "f"
               fTClose( cSm3Data )
               cOption(-1)
               return NIL
            endif

            //Kyk of daar diere in die leer is
            if lastrec() == 0
               if cLanType() == "A"
                  fScrBood(23,"Geen kalwers kon gevind word vir indeksberekeninge nie!")
               else
                  fScrBood(23,"No calves could be found for index calculation!")
               endif
               fScrWait(24)
               fTClose( cMass )
               fTClose( cSm3Data )
               cOption(-1)
               return NIL
            endif
            go top

            //Vra indeksouderdom
            // Vertoon hulpskerm
            if cLanType() == "A"
               fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
            else
               fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
            endif
            if cBrep $ "JYjy"
               nCh := fNewMenu( 1, "SM3INDCbp" )
            else
               nCh := fNewMenu( 1, "SM3INDCb" )
            endif
            cOption(nCh)

            if cLanType() == "A"
               fScrOpsk(1,"Opsie "+cOption())
            else
               fScrOpsk(1,"Option "+cOption())
            endif

            do case
               case nCh == 1
                  cOude := "100"
               case nCh == 2
                  cOude := "205"
               case nCh == 3
                  cOude := "365"
               case nCh == 4
                  cOude := "540"
               otherwise
                  //Herstel
                  fTClose( cMass )
                  fTClose( cSm3Data )
                  cOption(-2)
                  return NIL
            endcase

            //Vra watter formule
            // Vertoon hulpskerm
            if cLanType() == "A"
               fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
            else
               fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
            endif

            nForm := fNewMenu( nForm, "SM3INDCc" )

            if nForm == 0
               //Herstel
               fTClose( cMass )
               fTClose( cSm3Data )
               cOption(-2)
               return NIL
            endif

            cOption(nForm)

            if cLanType() == "A"
               fScrOpsk(1,"Opsie "+cOption())
            else
               fScrOpsk(1,"Option "+cOption())
            endif

/***************************************************************************/
            //Bereken die moederouderdom vir korreksiefaktore

            //Open die korreksiefaktore leer
            cCurDbf := fTOpen()
            cKorr := fTOpen( , "sm3rass", , "tdb", "sm3rass", .f. )
            if left( cKorr, 1 ) == "f"
               fTClose( cMass )
               fTClose( cSm3Data )
               cOption(-3)
               return NIL
            endif
            //Vind die regte ras
            locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
            if eof()
               go top
            endif

            //Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Moederouderdom korreksiefaktore word bereken")
            else
               fScrWbood(24,"Dam age correction factors being calculated")
            endif

            select MASS
            go top
            do while !( eof() )

               //Waarskuwings
               //M = MOEDER
               //W = Weegdatum

               //Maak velde skoon
               MASS->kalfbnr   := space(8)       //Waarskuwing
               MASS->gemspeeni := 0              //Moeder gem speenindeks
               MASS->gemspeena := 0              //Korreksiefaktor
               MASS->mamoergeb := 0              //Moederouderdom
               MASS->ind100    := 0
               MASS->compos    := 0              //Vorige kalf moer speen massa

               //Nommer
               cData := MASS->idmoer

               //Soek die moeder
               if len(trim(cData)) == 0

                  //Moeder onbekend - Het gladnie nommer
                  if "A" $ MASS->kalfbnr
                  else
                     MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "A", 1, 1 )
                  endif

               else

                  //Moeder bekend
                  select SM3DATA
                  seek cData
                  if eof()

                     //Moeder onbekend - nie in hoofleer
                     if "A" $ MASS->kalfbnr
                     else
                        MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "A", 1, 1 )
                     endif

                  else

                     //Bewaar data
                     MASS->gemspeeni := SM3DATA->gemspeeni

                     if MASS->gebdatum == ctod("  /  /  ")

                        //Geboortedatum van kalf ontbreek
                        if "C" $ MASS->kalfbnr
                        else
                           MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "C", 1, 1 )
                        endif

                     elseif SM3DATA->gebdatum == ctod("  /  /  ")

                        //Geboortedatums ontbreek van moeder
                        if "B" $ MASS->kalfbnr
                        else
                           MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "B", 1, 1 )
                        endif

                     else

                        //Bereken ouderdom
                        nJ=0
                        nM=0
                        nMj=year(SM3DATA->gebdatum)
                        nMm=month(SM3DATA->gebdatum)
                        nMd=day(SM3DATA->gebdatum)
                        nKj=year(MASS->gebdatum)
                        nKm=month(MASS->gebdatum)
                        nKd=day(MASS->gebdatum)

                        if nKj > nMj
                           nJ=nKj-nMj
                        endi

                        if nMm >= nKm
                           nJ--
                           nM=12-nMm+nKm
                        else
                           nM=nKm-nMm
                        endi

                        if nMd > nKd
                           nM--
                        endi

                        if (12*nJ)+nM <= 999 .and. (12*nJ)+nM >= 0
                           MASS->mamoergeb := (12*nJ)+nM
                        else
                           MASS->mamoergeb := 0
                        endif

                        //Bereken korreksiefaktor

                        //Kyk watter korreksiefaktor moet gebruik word
                        if MASS->geslag $ "M23"
                           cVeld := "SM3RASS->A" + cOude + "M"
                        else
                           cVeld := "SM3RASS->A" + cOude + "V"
                        endif

                        //Watter ouderdom
                        do case
                           case MASS->mamoergeb >= 1   .and. MASS->mamoergeb <=  27
                              cVeld := cVeld + "1"
                           case MASS->mamoergeb >= 28  .and. MASS->mamoergeb <=  33
                              cVeld := cVeld + "2"
                           case MASS->mamoergeb >= 34  .and. MASS->mamoergeb <=  39
                              cVeld := cVeld + "3"
                           case MASS->mamoergeb >= 40  .and. MASS->mamoergeb <=  45
                              cVeld := cVeld + "4"
                           case MASS->mamoergeb >= 46  .and. MASS->mamoergeb <=  51
                              cVeld := cVeld + "5"
                           case MASS->mamoergeb >= 52  .and. MASS->mamoergeb <=  57
                              cVeld := cVeld + "6"
                           case MASS->mamoergeb >= 58  .and. MASS->mamoergeb <= 117
                              cVeld := cVeld + "7"
                           case MASS->mamoergeb >= 118 .and. MASS->mamoergeb <= 999
                              cVeld := cVeld + "8"
                        endcase

                        //Bewaar korreksiefaktor
                        if len( cVeld ) == 15 .and. nForm == 3
                           MASS->gemspeena := &cVeld.
                        endif

                     endif

                  endif
                  select MASS
               endif

               //Toets of geboortemassa korrek is
               if MASS->gebmassa <= 0
                  if MASS->geslag $ "M23"
                     MASS->gebmassa := SM3RASS->gebma3
                  else
                     MASS->gebmassa := SM3RASS->gebma2
                  endif
               endif

               select MASS
               skip

            enddo
            go top

            //Sluit raskode leer
            select SM3RASS
            fTClose( cKorr )
            fTClose( cCurDbf )

/**************************************************************************/
            //Kry die vorige jaar se moer speen massa
            DBSELECTAREA("SM3DATA")
            ORDSETFOCUS(4)
            DBSELECTAREA("MASS")
            DBGOTOP()

            DO WHILE ! EOF()
               DBSELECTAREA("SM3DATA")

               IF DBSEEK(MASS->idmoer)
                  DO WHILE SM3DATA->idmoer == MASS->idmoer
                     IF SM3DATA->idnr == MASS->idnr
                        EXIT
                     ENDIF
                     MASS->compos := SM3DATA->mamoerspe
                     DBSKIP()
                  ENDDO
               ENDIF

               DBSELECTAREA("MASS")
               DBSKIP()
            ENDDO

            DBSELECTAREA("SM3DATA")
            ORDSETFOCUS(1)

/**************************************************************************/
            //Bereken die gdo ens van elke kalf

            //Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Ouderdom en GDO word bereken")
            else
               fScrWbood(24,"Age and ADA being calculated")
            endif

            //Set relation to hoofleer
            select MASS
            set relation to MASS->IDNR into SM3DATA

            // Verwyder ongewenste diere
            if !empty(cIkode)

               // Skerm
               fScrBood(23)
               if cLanType() == "A"
                  fScrWbood(24,"Ongewenste diere word verwyder")
               else
                  fScrWbood(24,"Unwanted animals being removed")
               endif

               select MASS
               go top

               do while !eof()
                  if SM3DATA->kod&cOude == cIkode
                     // Hou
                  else
                     // Delete
                     delete
                  endif
                  select MASS
                  skip
               enddo

               pack
               go top

               // Kyk of daar diere in die leer is
               if lastrec() == 0
                  if cLanType() == "A"
                     fScrBood(23,"Geen kalwers kon gevind word vir indeksberekeninge nie!")
                  else
                     fScrBood(23,"No calves could be found for index calculation!")
                  endif
                  fScrWait(24)
                  fTClose( cMass )
                  fTClose( cSm3Data )
                  cOption(-1)
                  return NIL
               endif

            endif

            // Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Ouderdom en GDO word bereken")
            else
               fScrWbood(24,"Age and ADA being calculated")
            endif

            select MASS
            go top

            do while !( eof() )

               //Waarskuwings
               //O = Ouderdom
               //G = Massa ontbreek
               //K = Ander inligting ontbreek

               //Maak velde skoon
               cDummy := SM3DATA->idnr           // This is to update the record pointer
               // sometimes it seems to be out of sinc. ????
               DO WHILE ! SM3DATA->(RLOCK())
               ENDDO
               SM3DATA->gma&cOude := 0
               SM3DATA->oud&cOude := 0
               SM3DATA->aan&cOude := 0
               SM3DATA->gdo&cOude := 0
               SM3DATA->ind&cOude := 0
               SM3DATA->ple&cOude := 0
               if cOude ='205'
                  SM3DATA->gebmasv   := 0
                  SM3DATA->mpresind  := 0
                  SM3DATA->spnspnind := 0
                  SM3DATA->klfspnind := 0
               endif

               //Bereken ouderdom in dae
               if SM3DATA->gebdatum == ctod("  /  /  ")
                  //Geboortedatum van kalf ontbreek
                  if "C" $ MASS->kalfbnr
                  else
                     MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "C", 1, 1 )
                  endif
                  select MASS
                  skip
                  loop
               elseif SM3DATA->dat&cOude. == ctod("  /  /  ")
                  //Kalf se weegdatum ontbreek
                  if "D" $ MASS->kalfbnr
                  else
                     MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "D", 1, 1 )
                  endif
                  select MASS
                  skip
                  loop
               elseif SM3DATA->dat&cOude. < SM3DATA->gebdatum
                  //Geboortedatum na weegdatum
                  if "E" $ MASS->kalfbnr
                  else
                     MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "E", 1, 1 )
                  endif
                  select MASS
                  skip
                  loop
               elseif SM3DATA->dat&cOude. - SM3DATA->gebdatum > 999
                  //Dier te oud om te bereken
                  if "F" $ MASS->kalfbnr
                  else
                     MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "F", 1, 1 )
                  endif
                  select MASS
                  skip
                  loop
               else
                  SM3DATA->oud&cOude := SM3DATA->dat&cOude - SM3DATA->gebdatum
               endif

               //Kyk of kalf buite weegdatumgrense val
               do case
                  case cOude ='100'
                     if SM3DATA->oud&cOude < 60 .or. SM3DATA->oud&cOude > 160
                        MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "G", 1, 1 )
                     endi
                  case cOude ='205'
                     if SM3DATA->oud&cOude < 150 .or. SM3DATA->oud&cOude > 270
                        MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "G", 1, 1 )
                     endi
                  case cOude ='365'
                     if SM3DATA->oud&cOude < 271 .or. SM3DATA->oud&cOude > 450
                        MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "G", 1, 1 )
                     endi
                  case cOude ='540'
                     if SM3DATA->oud&cOude < 451 .or. SM3DATA->oud&cOude > 634
                        MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "G", 1, 1 )
                     endi
               endc

               //Moeder geboortemassa verhouding word bereken
               if cOude == "205" .and. MASS->gebmassa > 0 .and. SM3DATA->mamoergeb > 0
                  nData := 0
                  nData := round((MASS->gebmassa/SM3DATA->mamoergeb)*100,1)
                  if nData >= 0.1 .and. nData <= 99.9
                     SM3DATA->gebmasv := nData
                  endif
               endi

               //Toets vir massa
               if SM3DATA->mas&cOude. <= 0
                  //Kalf se massa ontbreek
                  if "H" $ MASS->kalfbnr
                  else
                     MASS->kalfbnr := strtran( MASS->kalfbnr, " ", "H", 1, 1 )
                  endif
                  select MASS
                  skip
                  loop
               endif

               //Bereken gekorrigeerde massa
               if nForm == 1
                  SM3DATA->gma&cOude. := SM3DATA->mas&cOude.
                  if SM3DATA->oud&cOude. > 0
                     nData := 0
                     nData := int(((SM3DATA->mas&cOude. - MASS->gebmassa)*1000)/SM3DATA->oud&cOude.)
                     if nData >= 1 .and. nData <= 9999
                        SM3DATA->gdo&cOude. := nData
                     endif
                  endif
               else
                  if SM3DATA->oud&cOude. > 0
                     nData := 0
                     nData := int(((SM3DATA->mas&cOude. - MASS->gebmassa)*1000)/SM3DATA->oud&cOude.)
                     if nData >= 1 .and. nData <= 9999
                        SM3DATA->gdo&cOude. := nData
                        nData := round(((Sm3DATA->gdo&cOude. * val(cOude))/1000)+MASS->gebmassa+MASS->gemspeena,0)
                        if nData >= 1 .and. nData <= 999
                           SM3DATA->gma&cOude. := nData
                           Sm3DATA->gdo&cOude. := 0
                           nData := round(((Sm3DATA->gma&cOude. - MASS->gebmassa)*1000)/val(cOude),0)
                           if nData >= 1 .and. nData <= 9999
                              SM3DATA->gdo&cOude. := nData
                           endif
                        endif
                     endif
                  endif
               endif

               //Bereken moeder doeltreffendheidsindeks
               do case
                  case cOude == "205" .and. SM3DATA->gma205 - MASS->gemspeena > 0 .and. Sm3DATA->mamoergeb > 0
                     nData := 0
                     nData := round(((SM3DATA->gma205 - MASS->gemspeena)/(SM3DATA->mamoergeb**.75))*100 ,0)
                     if nData >= 1 .and. nData <= 999
                        SM3DATA->mpresind := nData
                     endif
                  case cOude == "205" .and. SM3DATA->gma205 - MASS->gemspeena > 0 .and. Sm3DATA->mamoerspe > 0
                     nData := 0
                     nData := round(((SM3DATA->gma205 - MASS->gemspeena)/(SM3DATA->mamoerspe**.75))*100 ,0)
                     if nData >= 1 .and. nData <= 999
                        SM3DATA->mpresind := nData
                     endif
                     // otherwise 01-02-28 09:57
                     // SM3DATA->mpresind := 0
               endc

               //Bereken moeder speen-speen indeks
               if cOude == "205" .and. SM3DATA->mamoerspe > 0 .and. MASS->compos > 0 .and. SM3DATA->mas205 > 0
                  nData := 0
                  nData := round((((SM3DATA->mamoerspe - MASS->compos) + SM3DATA->mas205) / ;
                     (MASS->compos**.75))*100 ,0)

                  if nData >= -999 .and. nData <= 9999
                     SM3DATA->spnspnind := nData
                  endif
               endif

               //Bereken moeder kalf-speen indeks
               if cOude == "205" .and. SM3DATA->mamoerspe > 0 .and. SM3DATA->mamoergeb > 0 .and. ;
                     SM3DATA->gma205 > 0 .and. SM3DATA->gebmassa > 0
                  nData := 0
                  nData := round((((SM3DATA->mamoerspe - SM3DATA->mamoergeb) + ;
                     (SM3DATA->gma205 - MASS->gemspeena - SM3DATA->gebmassa)) / ;
                     (SM3DATA->mamoergeb**.75))*100 ,0)

                  if nData >= -999 .and. nData <= 9999 // Verander op 09-28-98 02:11pm
                     SM3DATA->klfspnind := nData
                  endif
               endif

               //Bereken Speenmassaverhouding
               if cOude == "205" .and. SM3DATA->mas205 > 0 .and. SM3DATA->mamoerspe > 0
                  nData := round((SM3DATA->mas205 / SM3DATA->mamoerspe)*100,1)
                  if nData > 0 .and. nData <= 99.9
                     SM3DATA->spnmasvhd := nData
                  endif
               endif

               //Bereken totale en gemiddeldes
               if MASS->geslag $ "M23"
                  if SM3DATA->mpresind > 0
                     nPaan2++
                     nPtot2 := nPtot2 + Sm3DATA->mpresind
                  endif
                  if SM3DATA->gdo&cOude. > 0
                     nGaan2++
                     nGtot2 := nGtot2 + SM3DATA->gdo&cOude.
                  endif
                  if SM3DATA->klfspnind <> 0     // Verander op 09-28-98 02:14pm
                     nKSAan2++
                     nKSTot2 += Sm3DATA->klfspnind
                  endif
                  if SM3DATA->spnspnind <> 0
                     nSSAan2++
                     nSSTot2 += Sm3DATA->spnspnind
                  endif
               else
                  if SM3DATA->mpresind > 0
                     nPaan1++
                     nPtot1 := nPtot1 + Sm3DATA->mpresind
                  endif
                  if SM3DATA->gdo&cOude. > 0
                     nGaan1++
                     nGtot1 := nGtot1 + SM3DATA->gdo&cOude.
                  endif
                  if SM3DATA->klfspnind <> 0     // Verander op 09-28-98 02:15pm
                     nKSAan1++
                     nKSTot1 += Sm3DATA->klfspnind
                  endif
                  if SM3DATA->spnspnind <> 0
                     nSSAan1++
                     nSSTot1 += Sm3DATA->spnspnind
                  endif
               endif

               select MASS
               skip

            enddo

            //Bereken gemiddeldes
            if nPaan1 > 0
               nPave1 := round( nPtot1 / nPaan1, 0 )
            endif
            if nPaan2 > 0
               nPave2 := round( nPtot2 / nPaan2, 0 )
            endif
            if nGaan1 > 0
               nGave1 := round( nGtot1 / nGaan1, 0 )
            endif
            if nGaan2 > 0
               nGave2 := round( nGtot2 / nGaan2, 0 )
            endif
            if nKSAan1 > 0
               nKSAvg1 := round( nKSTot1 / nKSAan1, 0 )
            endif
            if nKSAan2 > 0
               nKSAvg2 := round( nKSTot2 / nKSAan2, 0 )
            endif
            if nSSAan1 > 0
               nSSAvg1 := round( nSSTot1 / nSSAan1, 0 )
            endif
            if nSSAan2 > 0
               nSSAvg2 := round( nSSTot2 / nSSAan2, 0 )
            endif

            //Bereken regressiefaktor vir vroulike diere
            if nGaan1 >= 2 .and. nGaan1 <= 9
               if     nGaan1 == 2
                  nGreg1 := .4
               elseif nGaan1 == 3
                  nGreg1 := .5
               elseif nGaan1 == 4
                  nGreg1 := .6
               elseif nGaan1 == 5
                  nGreg1 := .7
               elseif nGaan1 == 6
                  nGreg1 := .8
               elseif nGaan1 == 7
                  nGreg1 := .8
               elseif nGaan1 == 8
                  nGreg1 := .9
               elseif nGaan1 == 9
                  nGreg1 := .9
               endif
            endif

            //Bereken regressiefaktor vir manlike diere
            if nGaan2 >= 2 .and. nGaan2 <= 9
               if     nGaan2 == 2
                  nGreg2 := .4
               elseif nGaan2 == 3
                  nGreg2 := .5
               elseif nGaan2 == 4
                  nGreg2 := .6
               elseif nGaan2 == 5
                  nGreg2 := .7
               elseif nGaan2 == 6
                  nGreg2 := .8
               elseif nGaan2 == 7
                  nGreg2 := .8
               elseif nGaan2 == 8
                  nGreg2 := .9
               elseif nGaan2 == 9
                  nGreg2 := .9
               endif
            endif

/***************************************************************************/
            //Bereken die indekse van elke kalf

            //Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Indekse word bereken")
            else
               fScrWbood(24,"Indices being calculated")
            endif

            select MASS
            go top

            do while !( eof() )

               if SM3DATA->gdo&cOude <= 0
                  skip
                  loop
               endif

               cDummy := SM3DATA->idnr           // This is to update the record pointer
               // sometimes it seems to be out of sinc. ????
               DO WHILE ! SM3DATA->(RLOCK())
               ENDDO

               if MASS->geslag $ "M23"

                  //Bewaar aantal diere in groep
                  SM3DATA->aan&cOude := nGaan2

                  //Bereken indeks
                  if nGave2 > 0
                     nData := round( ( SM3DATA->gdo&cOude. / nGave2 ) * 100, 0 )
                     if nData >= 1 .and. nData <= 999
                        SM3DATA->ind&cOude. := nData
                        MASS->ind100        := SM3DATA->ind&cOude.
                     endif
                  endif

                  //Bereken moeder prestasie-indeks
                  if cOude == "205" .and. nPave2 > 0 .and. SM3DATA->mpresind > 0
                     nData := round( ( SM3DATA->mpresind / nPave2 ) * 100, 0 )
                     if nData >= 1 .and. nData <= 999
                        SM3DATA->mpresind := nData
                     endif
                  endif

                  //Bereken moeder speen-speen-indeks
                  if cOude == "205" .and. nSSAvg2 > 0 // .and. SM3DATA->spnspnind > 0
                     nData := round( ( SM3DATA->spnspnind / nSSAvg2 ) * 100, 0 )
                     if nData >= -999 .and. nData <= 9999
                        SM3DATA->spnspnind := nData
                     endif
                  endif

                  //Bereken moeder kalf-speen-indeks
                  if cOude == "205" .and. nKSAvg2 > 0 // .and. SM3DATA->klfspnind > 0
                     nData := round( ( SM3DATA->klfspnind / nKSAvg2 ) * 100, 0 )
                     if nData >= -999 .and. nData <= 9999
                        SM3DATA->klfspnind := nData
                     endif
                  endif

                  //Indien regressie
                  // 05-07-13 12:17 Verwyder
                  //if nGreg2 > 0 .and. nForm > 1
                  //   SM3DATA->ind&cOude. := round((100+(nGreg2*(SM3DATA->ind&cOude-100))),0)
                  //   MASS->ind100        := SM3DATA->ind&cOude.
                  //endif

               else

                  //Bewaar aantal diere in groep
                  SM3DATA->aan&cOude := nGaan1

                  //Bereken indeks
                  if nGave1 > 0
                     nData := round( ( SM3DATA->gdo&cOude. / nGave1 ) * 100, 0 )
                     if nData >= 1 .and. nData <= 999
                        SM3DATA->ind&cOude. := nData
                        MASS->ind100        := SM3DATA->ind&cOude.
                     endif
                  endif

                  //Bereken moeder prestasie-indeks
                  if cOude == "205" .and. nPave1 > 0 .and. SM3DATA->mpresind > 0
                     nData := round( ( SM3DATA->mpresind / nPave1 ) * 100, 0 )
                     if nData >= 1 .and. nData <= 999
                        SM3DATA->mpresind := nData
                     endif
                  endif

                  //Bereken moeder speen-speen-indeks
                  if cOude == "205" .and. nSSAvg1 > 0 //.and. SM3DATA->spnspnind > 0
                     nData := round( ( SM3DATA->spnspnind / nSSAvg1 ) * 100, 0 )
                     if nData >= -999 .and. nData <= 9999
                        SM3DATA->spnspnind := nData
                     endif
                  endif

                  //Bereken moeder kalf-speen-indeks
                  if cOude == "205" .and. nKSAvg1 > 0 // .and. SM3DATA->klfspnind > 0
                     nData := round( ( SM3DATA->klfspnind / nKSAvg1 ) * 100, 0 )
                     if nData >= -99 .and. nData <= 999
                        SM3DATA->klfspnind := nData
                     endif
                  endif

                  //Indien regressie
                  // 05-07-13 12:18 Verwyder
                  //if nGreg1 > 0 .and. nForm > 1
                  //   SM3DATA->ind&cOude. := round((100+(nGreg1*(SM3DATA->ind&cOude-100))),0)
                  //   MASS->ind100        := SM3DATA->ind&cOude.
                  //endif

               endif

               select MASS
               skip

            enddo
            go top

            //Sorteer data om rangorde te bepaal
            //Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Rangorde word bereken")
            else
               fScrWbood(24,"Order being determined")
            endif
            index on descend( MASS->ind100 ) to (cDd()+"mass")
            set index to (cDd()+"mass")
            //Waardes
            nTell=1
            nIndv=999
            nVort=0
            nVori=0
            go top
            do while !( eof() )
               //Manlik
               if MASS->ind100 <= 0
                  skip
                  loop
               endif

               cDummy := SM3DATA->idnr           // This is to update the record pointer
               // sometimes it seems to be out of sinc. ????
               DO WHILE ! SM3DATA->(RLOCK())
               ENDDO

               if MASS->geslag $ "M23"

                  if MASS->ind100 == nVori
                     SM3DATA->ple&cOude. := nVort
                  else
                     SM3DATA->ple&cOude. := nTell
                  endif

                  nVori := MASS->ind100
                  nVort := SM3DATA->ple&cOude.
                  nTell++

               endif
               skip
            enddo
            nTell=1
            nIndv=999
            nVort=0
            nVori=0
            go top
            do while !( eof() )
               //Vroulik
               if MASS->ind100 <= 0
                  skip
                  loop
               endif

               cDummy := SM3DATA->idnr           // This is to update the record pointer
               // sometimes it seems to be out of sinc. ????
               DO WHILE ! SM3DATA->(RLOCK())
               ENDDO

               if MASS->geslag $ "FV1"

                  if MASS->ind100 == nVori
                     SM3DATA->ple&cOude. := nVort
                  else
                     SM3DATA->ple&cOude. := nTell
                  endif

                  nVori := MASS->ind100
                  nVort := SM3DATA->ple&cOude.
                  nTell++

               endif
               skip
            enddo
            set inde to
            go top
            ferase( cDd()+"mass"+ordbagext() )

            //Manlike en vroulike diere word geskei
            //Skerm
            fScrBood(23)
            if cLanType() == "A"
               fScrWbood(24,"Manlike en Vroulike kalwers word geskei")
            else
               fScrWbood(24,"Male and Female calves being separated")
            endif
            copy file (cDd()+"sm3inde.dbf") to (cDd()+"sm3indm.dbf")
            copy file (cDd()+"sm3inde.dbf") to (cDd()+"sm3indv.dbf")

            //Open die manlike leer
            cManl := fTOpen( cDd(), "sm3indm", , "dbf", , .f. )
            if left( cManl, 1 ) == "f"
               fTClose( cMass )
               fTClose( cSm3Data )
               cOption(-3)
               return NIL
            endif

            //Open die vroulike leer
            cVrou := fTOpen( cDd(), "sm3indv", , "dbf", , .f. )
            if left( cVrou, 1 ) == "f"
               fTClose( cManl )
               fTClose( cMass )
               fTClose( cSm3Data )
               cOption(-3)
               return NIL
            endif

            select MASS
            go top
            do while !(eof())

               if MASS->geslag $ "M23"
                  select SM3INDM
                  append blank
                  SM3INDM->idnr := MASS->idnr
                  SM3INDM->waar := MASS->kalfbnr
                  SM3INDM->gems := MASS->gemspeeni
                  SM3INDM->korr := MASS->gemspeena
                  SM3INDM->inde := MASS->ind100
               else
                  select SM3INDV
                  append blank
                  SM3INDV->idnr := MASS->idnr
                  SM3INDV->waar := MASS->kalfbnr
                  SM3INDV->gems := MASS->gemspeeni
                  SM3INDV->korr := MASS->gemspeena
                  SM3INDV->inde := MASS->ind100
               endif

               //Volgende rekord
               select MASS
               skip

            enddo
            go top
            fTClose(cMass)
            fTClose(cManl)
            fTClose(cVrou)

            //Vertoon 'n menu en vra of manlik of vroulike vertoon moet word
            nCh := 1
            lLoop := .t.
            do while lLoop

               if cLanType() == "A"
                  fScrOpsk(1,"Opsie "+cOption())
                  fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ". Druk [Esc] vir die Submenu." )
               else
                  fScrOpsk(1,"Option "+cOption())
                  fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ". Press [Esc] for the Sub menu." )
               endif

               nCh := fNewMenu( nCh, "SM3INDCd" )
               cOption(nCh)

               if cLanType() == "A"
                  fScrOpsk(1,"Opsie "+cOption())
               else
                  fScrOpsk(1,"Option "+cOption())
               endif

               do case
                  case nCh == 1
                     //Vroulik
                     //Open die vroulike leer
                     ferase(cDd()+"SM3INDE"+ordbagext())
                     cVrou := fTOpen(cDd(),"sm3indv",,,"sm3inde",.f.)
                     if left(cVrou,1) == "f"
                        lLoop := .f.
                        loop
                     endif
                     if lastrec() == 0
                        if cLanType() == "A"
                           fScrBood(23,"Geen vroulike kalwers se indekse is bereken nie!")
                        else
                           fScrBood(23,"No indices calculated for female calves!")
                        endif
                        fScrWait(24)
                        cOption(-1)
                        loop
                     endif
                     set relation to SM3INDE->IDNR into SM3DATA
                     go top
                     asize( aVelde, 0 )
                     aadd( aVelde, { "sm3inde", "idnr" })
                     aadd( aVelde, { "sm3data", "geslag" })
                     aadd( aVelde, { "sm3data", "gebdatum" })
                     aadd( aVelde, { "sm3data", "dat"+cOude })
                     aadd( aVelde, { "sm3data", "oud"+cOude })
                     aadd( aVelde, { "sm3data", "mas"+cOude })
                     aadd( aVelde, { "sm3inde", "korr" })
                     aadd( aVelde, { "sm3data", "gma"+cOude })
                     aadd( aVelde, { "sm3data", "gdo"+cOude })
                     aadd( aVelde, { "sm3data", "ind"+cOude })
                     aadd( aVelde, { "sm3data", "ple"+cOude })
                     aadd( aVelde, { "sm3inde", "waar" })
                     aadd( aVelde, { "sm3data", "ind100" })
                     aadd( aVelde, { "sm3data", "ind205" })
                     aadd( aVelde, { "sm3data", "ind365" })
                     aadd( aVelde, { "sm3data", "ind540" })
                     aadd( aVelde, { "sm3data", "idvaar" })
                     aadd( aVelde, { "sm3data", "idmoer" })
                     fVertoon( aVelde, cOude, cIndg )
                     set relation to
                     fTClose(cVrou)
                  case nCh == 2
                     //Open die manlike leer
                     ferase(cDd()+"SM3INDE"+ordbagext())
                     cManl := fTOpen(cDd(),"sm3indm",,,"sm3inde",.f.)
                     if left(cManl,1) == "f"
                        lLoop := .f.
                        loop
                     endif
                     if lastrec() == 0
                        if cLanType() == "A"
                           fScrBood(23,"Geen manlike kalwers se indekse is bereken nie!")
                        else
                           fScrBood(23,"No indices calculated for male calves!")
                        endif
                        fScrWait(24)
                        cOption(-1)
                        loop
                     endif
                     set relation to SM3INDE->IDNR into SM3DATA
                     go top
                     asize( aVelde, 0 )
                     aadd( aVelde, { "sm3inde", "idnr" })
                     aadd( aVelde, { "sm3data", "geslag" })
                     aadd( aVelde, { "sm3data", "gebdatum" })
                     aadd( aVelde, { "sm3data", "dat"+cOude })
                     aadd( aVelde, { "sm3data", "oud"+cOude })
                     aadd( aVelde, { "sm3data", "mas"+cOude })
                     aadd( aVelde, { "sm3inde", "korr" })
                     aadd( aVelde, { "sm3data", "gma"+cOude })
                     aadd( aVelde, { "sm3data", "gdo"+cOude })
                     aadd( aVelde, { "sm3data", "ind"+cOude })
                     aadd( aVelde, { "sm3data", "ple"+cOude })
                     aadd( aVelde, { "sm3inde", "waar" })
                     aadd( aVelde, { "sm3data", "ind100" })
                     aadd( aVelde, { "sm3data", "ind205" })
                     aadd( aVelde, { "sm3data", "ind365" })
                     aadd( aVelde, { "sm3data", "ind540" })
                     aadd( aVelde, { "sm3data", "idvaar" })
                     aadd( aVelde, { "sm3data", "idmoer" })
                     fVertoon( aVelde, cOude, cIndg )
                     set relation to
                     fTClose(cManl)
                  otherwise
                     lLoop := .f.
               endcase

               cOption(-1)
            enddo

            //Herstel
            cOption(-3)
            fTClose( cSm3Data )

            return NIL

/**************************************************************************/
            STATIC FUNCTION fVertoon( aVelde, cOude, cIndg )

               //Veranderlikes
               local GetList := {}
               local cCurSke := savescreen( 0, 0, 24, 79 ) //Skerm
               local cCurScr := fCurScreen()     //Kleure ens
               local cBrowse                     //Browse object
               local aColumn := {}               //Kolomme array
               local i       := 0                //Counter
               local lMore   := .t.              //Logical looper
               local nKey    := 0                //Keypress
               local nTop    := 3
               local nLeft   := 2
               local nBottom := 21
               local nRight  := 76
               local aOpsk   := {}
               local nScrLen := 0
               local oCols   := NIL
               local aCalc   := {}
               local lSort   := .f.
               local cSort   := cDd()+"sm3inde"+ordbagext()
               local nCopy   := 0

               PRIVATE cData := ""               //Column data fields for tbrowse
               PRIVATE cHead := ""               //Heading of tbrowse

               //Waardes
               cIndg := if(cIndg==NIL,space(6),cIndg)

               //Skerm
               fScrBood(23,"")
               if cLanType() == "A"
                  fScrBood(24,"Skermuitleg word bepaal")
               else
                  fScrBood(24,"Screen outlay being determined")
               endif
               aOpsk := fGetField( aVelde )

               //Skerm
               fScrBood(23,"")
               if cLanType() == "A"
                  fScrBood(24,"Gemiddeldes word bereken")
               else
                  fScrBood(24,"Averages being calculated")
               endif
               do while !( eof() )

                  for i = 1 to len( aOpsk )
                     if aOpsk[i][3] == "N"
                        cData := aOpsk[i,1] + aOpsk[i,2]
                        if &cData > 0
                           aOpsk[i][11]++
                           aOpsk[i][12] += &cData
                        endif
                     endif
                  next

                  skip
               enddo
               go top

               //Kry die totale lengte van die velde om die breedte van die venster te bepaal
               for i = 1 to len( aOpsk )

                  //Lengte
                  nScrLen := nScrLen + aOpsk[i,4] + 1

                  //Kolomme
                  cData := aOpsk[i,1] + aOpsk[i,2]
                  cHead := aOpsk[i,7] + ";" + aOpsk[i,8] + ";" + aOpsk[i,9]
                  aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

               next

               //Bepaal regterkantste lyn
               nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

               //Teken die box
               if len(trim(cIndg)) > 0
                  if cLanType() == "A"
                     fBox( nTop, nLeft, nBottom, nRight, cOude+" DAE INDEKSBEREKENINGE VIR DIE "+trim(cIndg)+" INDEKSGROEP" )
                  else
                     fBox( nTop, nLeft, nBottom, nRight, cOude+" DAY INDEX CALCULATIONS FOR THE "+trim(cIndg)+" INDEX GROUP" )
                  endif
               else
                  if cLanType() == "A"
                     fBox( nTop, nLeft, nBottom, nRight, cOude+" DAE INDEKSBEREKENINGE" )
                  else
                     fBox( nTop, nLeft, nBottom, nRight, cOude+" DAY INDEX CALCULATIONS")
                  endif
               endif
               setcolor( cColNorm() )

               //Bou die tBrowse
               cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
               cBrowse:headsep := "Í"
               cBrowse:colsep := "³"
               cBrowse:footsep := "Í"

               //Plaas kolomme oor na die browse object en gemiddeldes
               for i = 1 to len( aColumn )
                  cBrowse:addColumn( aColumn[i] )

                  oCols := cBrowse:getcolumn(i)
                  if aOpsk[i][11] > 0
                     oCols:footing := str(  aOpsk[i][12]/aOpsk[i][11] ,aOpsk[i][4], aOpsk[i][5] )
                  else
                     oCols:footing := ""
                     if i == 1
                        if cLanType() == "A"
                           oCols:footing := left(ltrim(str(lastrec()))+" Dier/e",aOpsk[i][4])
                        else
                           oCols:footing := left(ltrim(str(lastrec()))+" Animal/s",aOpsk[i][4])
                        endif
                     endif
                  endif
                  cBrowse:setcolumn(i,oCols)
               next

               // Main loop
               lMore := .T.
               do while lMore

                  //Skerm
                  if lSort
                     if cLanType() == "A"
                        fScrBood( 23, "[Esc]=Menu   [Alt P]=Druk          [Alt S]=Sorteer op id nommer" )
                        fScrBood( 24, "[Del]=Skrap  [Alt W]=Waarskuwings  [Alt V]=Vaargemiddeldes     " )
                     else
                        fScrBood( 23, "[Esc]=Menu    [Alt P]=Print     [Alt S]=Sort on id number" )
                        fScrBood( 24, "[Del]=Delete  [Alt W]=Warnings  [Alt V]=Sire averages    " )
                     endif

                  else
                     if cLanType() == "A"
                        fScrBood( 23, "[Esc]=Menu   [Alt P]=Druk          [Alt S]=Sorteer op indeks" )
                        fScrBood( 24, "[Del]=Skrap  [Alt W]=Waarskuwings  [Alt V]=Vaargemiddeldes  " )
                     else
                        fScrBood( 23, "[Esc]=Menu    [Alt P]=Print     [Alt S]=Sort on index" )
                        fScrBood( 24, "[Del]=Delete  [Alt W]=Warnings  [Alt V]=Sire averages" )
                     endif

                  endif

                  //Vries
                  cBrowse:freeze := 1

                  // Stabilize the display until it's stable or a key is pressed
                  nKey := 0
                  do while nKey == 0 .and. .not. cBrowse:stable
                     cBrowse:stabilize()
                     nKey := InKey()
                  enddo

                  if cBrowse:stable
                     // Make sure that the current record is showing
                     // up-to-date data in case we are on a network.
                     cBrowse:refreshCurrent()
                     ForceStable(cBrowse)
                     // Everything's done -- just wait for a key
                     nKey := InKey(0)
                  endif

                  if nKey == K_ESC
                     // Esc means leave
                     lMore := .f.

                  elseif nKey == K_DEL
                     //Alt D means delete animal from list
                     if fDelete(cIndg)
                        cBrowse:refreshall()
                     endif

                  elseif nKey == K_ALT_W
                     //Alt W means display waarskuwings
                     fWarning(fieldget(2))

                  elseif nKey == K_ALT_V
                     //Alt V means display vaar gemiddeldes
                     if len(aCalc) > 0
                     else
                        aCalc := fVaarCalc(cOude)
                        cBrowse:refreshall()
                     endif
                     fVaarDisp(aCalc,cOude)

                  elseif nKey == K_ALT_P
                     //Alt P means print a record
                     nCopy := 1 // fCopies(1) 07-05-28 12:16
                     for i := 1 to nCopy
                        if len(aCalc) > 0
                           if !fPrint(cIndg,cOude,aCalc)
                              exit
                           endif
                        else
                           aCalc := fVaarCalc(cOude)
                           if !fPrint(cIndg,cOude,aCalc)
                              exit
                           endif
                        endif
                     next
                     cBrowse:refreshall()

                  elseif nKey == K_ALT_S
                     //Alt S means sort
                     if lSort
                        lSort := .f.
                        set index to
                        ferase(cDd()+"SM3INDE"+ordbagext())
                     else
                        lSort := .t.
                        index on descend(str(SM3INDE->inde)) to (cSort)
                        set index to (cSort)
                     endif
                     go top
                     cBrowse:refreshall()

                  elseif nKey == K_F1
                     //Hulp
                     do help with "sm3indc",1,"oorsig"

                  else
                     // Apply the key to the browse
                     ApplyKey(cBrowse, nKey)

                  endif

               enddo

               //Herstel
               fSetScreen( cCurScr )
               restscreen( 0, 0, 24, 79, cCurSke )

               return NIL

//**************************************************************************/
               STATIC FUNCTION fWarning(cWarn)

                  //Funksie om waarskuwings te vertoon

                  //Verklaar
                  local cCscr := savescreen(0,0,24,79)
                  local aWarn := {}

                  //Moet verklaar wees
                  if cWarn == NIL
                     return NIL
                  endif

                  //Moet waardes he
                  if len(trim(cWarn)) <= 0
                     return NIL
                  endif

                  //Bou array
                  if "A" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Moeder onbekend",35))
                     else
                        aadd(aWarn,padr("Dam unknown",35))
                     endif
                  endif
                  if "B" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Moeder geboortedatum onbekend",35))
                     else
                        aadd(aWarn,padr("Dam date of birth unknown",35))
                     endif
                  endif
                  if "C" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Kalf geboortedatum onbekend",35))
                     else
                        aadd(aWarn,padr("Calf date of birth unknown",35))
                     endif
                  endif
                  if "D" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Kalf weegdatum onbekend",35))
                     else
                        aadd(aWarn,padr("Calf weighing date unknown",35))
                     endif
                  endif
                  if "E" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Kalf weegdatum voor geboortedatum",35))
                     else
                        aadd(aWarn,padr("Calf weighing date before date of birth",35))
                     endif
                  endif
                  if "F" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Kalf te oud",35))
                     else
                        aadd(aWarn,padr("Calf too old",35))
                     endif
                  endif
                  if "G" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Kalf val buite weegdatumgrense",35))
                     else
                        aadd(aWarn,padr("Calf outside weighing date boundaries",35))
                     endif
                  endif
                  if "H" $ cWarn
                     if cLanType() == "A"
                        aadd(aWarn,padr("Kalfmassa ontbreek",35))
                     else
                        aadd(aWarn,padr("Calf mass unknown",35))
                     endif
                  endif

                  //Vertoon
                  if len(aWarn) > 0
                     if cLanType() == "A"
                        fbox(7,23,17,62,"Waarskuwings",cColMenu())
                     else
                        fbox(7,23,17,62,"Warnings",cColMenu())
                     endif
                     setcolor(cColMenu())
                     achoice(8,25,16,60,aWarn)
                     setcolor(cColNorm())
                  endif

                  //Herstel
                  restscreen(0,0,24,79,cCscr)

                  return NIL

//***************************************************************************/
                  STATIC FUNCTION fVaarCalc(cOude)

                     //Funksie om vaargemiddeldes te bereken

                     //Verklaar
                     local cCscr := savescreen(23,0,24,79)
                     local nElem := 0
                     local aCalc := {}
                     local aVaar := {}
                     private cAgee := cOude

                     //Skerm
                     fScrBood(23)
                     if cLanType() == "A"
                        fScrWbood(24,"Vaargemiddeldes word bereken")
                     else
                        fScrWbood(24,"Sire averages being calculated")
                     endif

                     //Databasis
                     go top

                     //Die loop
                     do while !eof()

                        nElem := ascan(aVaar,SM3DATA->idvaar)
                        if nElem > 0
                           aCalc[nElem][12]++
                           if SM3DATA->mas&cAgee > 0
                              aCalc[nElem][2]++
                              aCalc[nElem][3] += SM3DATA->mas&cAgee
                           endif
                           if SM3DATA->gma&cAgee > 0
                              aCalc[nElem][4]++
                              aCalc[nElem][5] += SM3DATA->gma&cAgee
                           endif
                           if SM3DATA->gdo&cAgee > 0
                              aCalc[nElem][6]++
                              aCalc[nElem][7] += SM3DATA->gdo&cAgee
                           endif
                           if SM3DATA->ind&cAgee > 0
                              aCalc[nElem][8]++
                              aCalc[nElem][9] += SM3DATA->ind&cAgee
                           endif
                           if SM3DATA->gebmassa > 0
                              aCalc[nElem][10]++
                              aCalc[nElem][11] += SM3DATA->gebmassa
                           endif

                        else
                           aadd(aVaar,SM3DATA->idvaar)
                           aadd(aCalc,{SM3DATA->idvaar,0,0,0,0,0,0,0,0,0,0,0})
                           nElem := len(aCalc)
                           aCalc[nElem][12]++
                           if SM3DATA->mas&cAgee > 0
                              aCalc[nElem][2]++
                              aCalc[nElem][3] += SM3DATA->mas&cAgee
                           endif
                           if SM3DATA->gma&cAgee > 0
                              aCalc[nElem][4]++
                              aCalc[nElem][5] += SM3DATA->gma&cAgee
                           endif
                           if SM3DATA->gdo&cAgee > 0
                              aCalc[nElem][6]++
                              aCalc[nElem][7] += SM3DATA->gdo&cAgee
                           endif
                           if SM3DATA->ind&cAgee > 0
                              aCalc[nElem][8]++
                              aCalc[nElem][9] += SM3DATA->ind&cAgee
                           endif
                           if SM3DATA->gebmassa > 0
                              aCalc[nElem][10]++
                              aCalc[nElem][11] += SM3DATA->gebmassa
                           endif
                        endif

                        //Volgende
                        skip

                     enddo

                     //Sorteer array
                     //aCalc := aSort(aCalc)

                     //Databasis
                     go top

                     //Herstel
                     restscreen(23,0,24,79,cCscr)

                     return aCalc

//**************************************************************************/
                     STATIC FUNCTION fVaarDisp(aCalc,cOude)

                        //Funksie om waarskuwings te vertoon

                        //Verklaar
                        local cCscr := savescreen(0,0,24,79)
                        local i     := 0
                        local aVaar := {}

                        //Moet verklaar wees
                        if aCalc == NIL
                           return NIL
                        endif

                        //Moet waardes he
                        if len(aCalc) <= 0
                           return NIL
                        endif

                        //Bou array
                        aVaar := fVaar(aCalc)

                        //Vertoon
                        fScrBood(23)
                        fScrBood(24,"[Esc]=Menu")
                        if cLanType() == "A"
                           fbox(5,23,20,62,"Vaargemiddeldes",cColMenu())
                        else
                           fbox(5,23,20,62,"Sire averages",cColMenu())
                        endif
                        setcolor(cColMenu())
                        achoice(6,25,19,60,aVaar,,,3)
                        setcolor(cColNorm())

                        //Herstel
                        restscreen(0,0,24,79,cCscr)

                        return NIL

/*************************************************************************/
                        STATIC FUNCTION fPrint(cIndg,cOude,aCalc,aRecv)

                           //Verklaar
                           local lRetu := .t.
                           local nTota := 0
                           local lLoop := .t.
                           local nI    := 1
                           local cData := ""
                           local aSend := {}
                           local cText := ""
                           local aVaar := {}
                           local lWaar := .f.
                           local cHdln := ""
                           local cPcod := ""
                           local nMidc := 0
                           local nWidt := 0
                           local nTopl := 0
                           local nPrnl := 0
                           local nPagl := 0
                           local nBlad := 1

                           //Toets of drukker gereed is
                           if fPrnReady() == K_ESC
                              return .f.
                           endif

                           //Skerm
                           fScrBood(23)

                           //Skuif die databasis
                           select SM3INDE
                           go top

                           //Tel aantal velde
                           nTota := lastrec()

                           //Kry die velde wat gedruk moet word
                           if aRecv == NIL
                              asize(aSend,0)
                              aadd(aSend,{"sm3inde","idnr"})
                              aadd(aSend,{"sm3data","geslag"})
                              aadd(aSend,{"sm3data","generasie"})
                              aadd(aSend,{"sm3data","gebdatum"})
                              aadd(aSend,{"sm3data","gebmassa"})
                              aadd(aSend,{"sm3data","idvaar"})
                              aadd(aSend,{"sm3data","idmoer"})
                              if cOude == "205"
                                 aadd(aSend,{"sm3inde","gems"})
                                 aadd(aSend,{"sm3data","mpresind"})
                              endif
                              aadd(aSend,{"sm3data","dat"+cOude})
                              aadd(aSend,{"sm3data","oud"+cOude})
                              aadd(aSend,{"sm3data","mas"+cOude})
                              aadd(aSend,{"sm3data","gma"+cOude})
                              aadd(aSend,{"sm3inde","korr"})
                              aadd(aSend,{"sm3data","gdo"+cOude})
                              aadd(aSend,{"sm3data","ind"+cOude})
                              aadd(aSend,{"sm3data","ple"+cOude})
                              aadd(aSend,{"sm3data","aan"+cOude})
                              aadd(aSend,{"sm3data","ind100"})
                              aadd(aSend,{"sm3data","ind205"})
                              aadd(aSend,{"sm3data","ind365"})
                              aadd(aSend,{"sm3data","ind540"})
                              aadd(aSend,{"sm3inde","waar"})

                              if cLanType() == "A"
                                 fScrwbood(24,"Veldbeskrywings word opgesoek")
                              else
                                 fScrwbood(24,"Field descriptions being sorted")
                              endif
                              aRecv := fGetField(aSend)
                           endif

                           //Bou array met vaargemiddeldes
                           aVaar := fVaar(aCalc)

                           //Bepaal die drukgrootte
                           nWidt := 0
                           for nI = 1 to len(aRecv)
                              nWidt += aRecv[nI][4]+1

                              if aRecv[nI,3] == "N"
                                 aRecv[nI,11] := 0
                                 aRecv[nI,12] := 0
                              endif
                           next

                           if nWidt <= nPrnWidt()
                              // Normal
                              cPcod := cPrnNorm()
                              nWidt := nPrnWidt()
                              nTopl := nPrnLine()
                              nPrnl := nPrnPrnl() - 2
                              nPagl := nPrnLeng()
                           else
                              // Condense
                              cPcod := cPrnCond()
                              nWidt := nPrnCwid()
                              nTopl := nPrnLine()
                              if nPrnLptp() < 8
                                 nPrnl := nPrnPrnl() - 2
                                 nPagl := nPrnLeng()
                              else
                                 nPrnl := nPrcPrnl() - 2
                                 nPagl := nPrcLeng()
                              endif
                           endif

                           nMidc := nWidt - 29

                           //Skerm
                           if cLanType() == "A"
                              fScrbood(24,"Indeksverslag word gedruk!  [Esc]=Stop drukker.")
                              if len(trim(cIndg)) > 0
                                 cHdln := upper(cOude+" Dae indeksverslag van die indeksgroep "+trim(cIndg)+".")
                              else
                                 cHdln := upper(cOude+" Dae indeksverslag.")
                              endif
                           else
                              fScrbood(24,"Index report being printed!  [Esc]=Stop printer.")
                              if len(trim(cIndg)) > 0
                                 cHdln := upper(cOude+" Day index report for the index group "+trim(cIndg)+".")
                              else
                                 cHdln := upper(cOude+" Day index report.")
                              endif
                           endif

                           //Skakel die drukker aan
                           fPrnOn()

                           //Doen die loop
                           lLoop := .t.
                           do while lLoop

                              //Opskrifte
                              if prow() = 0

                                 fPrnCod( cPcod )
                                 if cLanType() == "A"
                                    @prow()+nTopl, 1 say upper( cGebNaam() )
                                    @prow()  , nMidc say "             Verslag: " + cOption()
                                    @prow()+1,     1 say substr(cTotNaam(),  1,40)
                                    @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
                                    @prow()+1,     1 say substr(cTotNaam(), 41,40)
                                    @prow()  , nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
                                    @prow()+1,     1 say substr(cTotNaam(), 81,40)
                                    @prow()  , nMidc say "        Kuddekenmerk: " + substr(cTotNaam(),125,4)
                                    @prow()+1,     1 say substr(cTotNaam(),121, 4)
                                    @prow()  ,nWidt-len(cHdln)+1 say cHdln
                                 else
                                    @prow()+nTopl, 1 say upper( cGebNaam() )
                                    @prow()  , nMidc say "              Report: " + cOption()
                                    @prow()+1,     1 say substr(cTotNaam(),  1,40)
                                    @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
                                    @prow()+1,     1 say substr(cTotNaam(), 41,40)
                                    @prow()  , nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
                                    @prow()+1,     1 say substr(cTotNaam(), 81,40)
                                    @prow()  , nMidc say "    Herd Designation: " + substr(cTotNaam(),125,4)
                                    @prow()+1,     1 say substr(cTotNaam(),121, 4)
                                    @prow()  ,nWidt-len(cHdln)+1 say cHdln
                                 endif
                                 @prow()+1,  1 say repl( "=",  nWidt )

                                 //1e Lyn van opskrif
                                 cData := ""
                                 for nI = 1 to len( aRecv )
                                    cData := cData + padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
                                 next
                                 @prow()+1,1 say padr(cData, nWidt)

                                 //2e Lyn van opskrif
                                 cData := ""
                                 for nI = 1 to len( aRecv )
                                    cData := cData + padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
                                 next
                                 @prow()+1,1 say padr(cData, nWidt)

                                 //3e Lyn van opskrif
                                 cData := ""
                                 for nI = 1 to len( aRecv )
                                    cData := cData + padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
                                 next
                                 @prow()+1,1 say padr(cData, nWidt)

                                 //4e Lyn van opskrif
                                 cData := ""
                                 for nI = 1 to len( aRecv )
                                    cData := cData + repl("-",aRecv[nI,4]) + " "
                                 next
                                 @prow()+1,1 say padr(cData, nWidt)
                              endif

                              //Toets of drukker moet stop
                              if fPrnStop() = K_ESC
                                 lRetu := .f.
                                 lLoop := .f.
                                 loop
                              endif

                              //Kyk of daar waarskuwings is
                              if len(trim(SM3INDE->waar)) > 0
                                 lWaar := .t.
                              endif

                              //Data
                              cData := ""
                              for nI = 1 to len( aRecv )
                                 //Kies die regte leer
                                 cText := aRecv[nI][1]
                                 cText := strtran(cText,"->")
                                 cText := alltrim(cText)
                                 select select(cText)
                                 do case
                                    case aRecv[nI][3] == "C"
                                       //Character
                                       cData+= fieldget(aRecv[nI,13]) + " "
                                    case aRecv[nI][3] == "N"
                                       //Numeric
                                       if fieldget(aRecv[nI,13]) > 0
                                          aRecv[nI,11]++
                                          aRecv[nI,12] += fieldget(aRecv[nI,13])
                                       endif
                                       cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
                                    case aRecv[nI][3] == "D"
                                       //Date
                                       cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
                                    otherwise
                                       //Nie een van bogenoemde
                                       cData+= space(aRecv[nI][4])+" "
                                 endcase
                                 select SM3INDE
                              next
                              @prow()+1,1 say padr(cData, nWidt)

                              //Volgende rekord
                              skip

                              //Toets vir einde van bladsy
                              if prow() >= nPrnl .or. eof()

                                 if eof()
                                    //Druk gemiddeldes
                                    if cLanType() == "A"
                                       @prow()+1,  1 say padr("-Gemiddeldes"+repl("-", nWidt),nWidt)
                                    else
                                       @prow()+1,  1 say padr("-Averages"+repl("-", nWidt),nWidt)
                                    endif

                                    for nI := 1 to len(aRecv)
                                       if aRecv[nI,3] == "N"
                                          if aRecv[nI,11] > 0
                                             if nI == 1
                                                @prow()+1,  1 say str(aRecv[nI,12]/aRecv[nI,11],aRecv[nI,4],aRecv[nI,5])
                                             else
                                                @prow(),pcol()+1 say str(aRecv[nI,12]/aRecv[nI,11],aRecv[nI,4],aRecv[nI,5])
                                             endif
                                          else
                                             if nI == 1
                                                @prow()+1,  1 say repl(" ",aRecv[nI,4])
                                             else
                                                @prow()  ,pcol()+1 say repl(" ",aRecv[nI,4])
                                             endif
                                          endif
                                       else
                                          if nI == 1
                                             @prow()+1,  1 say repl(" ",aRecv[nI,4])
                                          else
                                             @prow()  ,pcol()+1 say repl(" ",aRecv[nI,4])
                                          endif
                                       endif
                                    next

                                    //Druk vaargemiddeldes indien einde van leer en plek op bladsy
                                    if prow()+len(aVaar)+7 > nPrnl
                                       //Print onderste lyn
                                       @prow()+1,  1 say repl( "=",  nWidt )
                                       @prow()+1,  1 say cAppName()
                                       fPrnEjec()
                                       nBlad++
                                    endif

                                    //Plek op huidige bladsy
                                    if cLanType() == "A"
                                       @prow()+1,  1 say padr("-VaarGemiddeldes"+repl("-", nWidt),nWidt)
                                    else
                                       @prow()+1,  1 say padr("-Sire Averages"+repl("-", nWidt),nWidt)
                                    endif
                                    for nI := 1 to len(aVaar)
                                       @prow()+1,  1 say aVaar[nI]
                                    next
                                    if lWaar
                                       if cLanType() == "A"
                                          @prow()+1,  1 say padr("-Waarskuwings"+repl("-", nWidt),nWidt)
                                          @prow()+1,  1 say "A-Moeder onbekend                D-Kalf weegdatum ontbreek            G-Kalf buite weegdatumgrense"
                                          @prow()+1,  1 say "B-Moeder geboortedatum onbekend  E-Kalf weegdatum voor geboortedatum  H-Kalfmassa ontbreek        "
                                          @prow()+1,  1 say "C-Kalf geboortedatum onbekend    F-Kalf te oud                                                    "
                                       else
                                          @prow()+1,  1 say padr("-Warnings"+repl("-", nWidt),nWidt)
                                          @prow()+1,  1 say "A-Dam unknown                D-Calf weigh date unknown            G-Calf outside weigh date boundaries"
                                          @prow()+1,  1 say "B-Dam birth date unknown     E-Calf weigh date before birth date  H-Calf mass unknown                 "
                                          @prow()+1,  1 say "C-Calf birth date unknown    F-Calf too old                                                           "
                                       endif
                                    endif
                                 endif

                                 //Print onderste lyn
                                 @prow()+1,  1 say repl( "=",  nWidt )
                                 @prow()+1,  1 say cAppName()
                                 fPrnEjec()
                                 nBlad++

                                 //Indien eof()
                                 if eof()
                                    lLoop := .f.
                                 endif

                              endif

                           enddo

                           fPrnOff()

                           //Herstel
                           go top

                           return lRetu

//**************************************************************************/
                           STATIC FUNCTION fVaar(aCalc)

                              //Funksie om array te bou met vaargemiddeldes

                              //Verklaar
                              local aVaar := {}
                              local nMass := 0
                              local nGmas := 0
                              local nGdoo := 0
                              local nIndd := 0
                              local nGebm := 0
                              local nI    := 0

                              if cLanType() == "A"
                                 aadd(aVaar,"Vaar Id      Kal Gm Mas Gma Gdo  Ind")
                                 aadd(aVaar,"------------ --- -- --- --- ---- ---")
                              else
                                 aadd(aVaar,"Sire Id      Cal Bm Mas Bma Ada  Ind")
                                 aadd(aVaar,"------------ --- -- --- --- ---- ---")
                              endif
                              for nI = 1 to len(aCalc)

                                 //Bereken gemiddeldes
                                 if aCalc[ni][2] > 0
                                    nMass := round( aCalc[nI][3] / aCalc[nI][2] ,0 )
                                 else
                                    nMass := 0
                                 endif
                                 if aCalc[ni][4] > 0
                                    nGmas := round( aCalc[nI][5] / aCalc[nI][4] ,0 )
                                 else
                                    nGmas := 0
                                 endif
                                 if aCalc[ni][6] > 0
                                    nGdoo := round( aCalc[nI][7] / aCalc[nI][6] ,0 )
                                 else
                                    nGdoo := 0
                                 endif
                                 if aCalc[ni][8] > 0
                                    nIndd := round( aCalc[nI][9] / aCalc[nI][8] ,0 )
                                 else
                                    nIndd := 0
                                 endif
                                 if aCalc[ni][10] > 0
                                    nGebm := round( aCalc[nI][11] / aCalc[nI][10] ,0 )
                                 else
                                    nGebm := 0
                                 endif

                                 //Bou die array
                                 aadd(aVaar,aCalc[ni][1]+" "+str(aCalc[ni][10],3,0)+" "+str(nGebm,2,0)+" "+str(nMass,3,0)+" "+str(nGmas,3,0)+" "+str(nGdoo,4,0)+" "+str(nIndd,3,0))

                              next

                              return aVaar

//*************************************************************************/
                              STATIC FUNCTION fDelete(cIndg)

                                 //Funksie om enige rekord te skrap

                                 //Verklaar
                                 local lRetu := .f.
                                 local cBood := ""

                                 //Skerm
                                 fScrBood(23,SM3INDE->idnr)
                                 if cLanType() == "A"
                                    cBood := "Moet bogenoemde dier uit die indeksgroep geskrap word?"
                                 else
                                    cBood := "Should above-mentioned animal be deleted from the index group?"
                                 endif

                                 //Vra
                                 if fJaNee( 24, cBood,,.f. )
                                    //Indeksgroep uit
                                    if SM3DATA->indekskode == cIndg
                                       select SM3DATA
                                       do while !rlock()
                                       enddo
                                       SM3DATA->indekskode := "      "
                                       select SM3INDE
                                    endif
                                    //Verwyder dier uit lys
                                    do while !rlock()
                                    enddo
                                    delete
                                    skip
                                    if eof()
                                       go top
                                    endif
                                    lRetu := .t.
                                 endif

                                 return lRetu

