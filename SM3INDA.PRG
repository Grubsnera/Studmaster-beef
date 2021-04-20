//SM3INDA.PRG
//Program om amptelike indeksverslag te druk
//Kopiereg (C) 1993 A van Rensburg
//10:22 15 Apr,1993

// 02-01-16 15:16 Added Breedplan export format. Function fDiskBrep

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3inda

   //Verklaar
   local cMasf := cDd()+"mass.dbf"
   local cData := ""
   local cMass := ""
   local cIngr := ""
   local nCh   := 1
   local cIndg := space(6)
   local aVeld := {}
   local aCscr := {}
   local nBoxc := 0
   local getlist := {}
   local cBrep := ""
   local nGrpc := 0

   private cTest := ""
   private cByvk := " "
   private cByvm := " "
   private cByvg := "  "
   private cFase := ""
   private cOude := ""
   private cTesy := space(4)
   private cTesn := space(2)
   private cRear := "1"
   private cFeed := "1"
   private dFirs := ctod("")
   private dLast := ctod("")

   begin sequence

      cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")

      //Skerm
      //Open dataleers
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
         fScrWbood(24,"Datalˆers word geopen")
      else
         fScrOpsk(,"Option "+cOption())
         fScrWbood(24,"Data files being opened")
      endif

      cData := fTOpen(cDd(),"sm3data")
      if left(cData,1) == "f"
         break
      endif

      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood(23,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". Druk [Esc] vir die Submenu.")
      else
         fScrBood(23,"Choose with "+D_DNARR+D_UPARR+" tests and press "+D_ENTER+". Press [Esc] for the Sub menu.")
      endif
      nCh := fNewMenu(nCh,"SM3INDAa")
      cOption(nCh)
      aCscr := fASaveScr()

      //Die keuses
      nGrpc := nCh
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
               break
            endif

            //Kyk of daar wel diere is vir die indeksgroep
            select SM3DATA
            set order to 3
            seek cIndg
            copy to (cMasf) fields ;
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
               uitkrede while SM3DATA->indekskode == cIndg
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
               copy to (cMasf) fields ;
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
                  uitkrede for &cTest.
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
            //Seleksiegroep
            cTest := sm3selg()
            if len( cTest ) > 0
               //Skep leer met name van diere om te weeg
               fScrBood(23)
               if cLanType() == "A"
                  fScrBood(24,"Kalwers wat voldoen aan die groepvereistes word uitgesoek.")
               else
                  fScrBood(24,"Calves qualifying for the group requirements being sorted.")
               endif
               copy to (cMasf) fields ;
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
                  uitkrede for &cTest.
            else
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,"Geen seleksiegroep seleksie-vereistes is gespesifiseer nie!")
               else
                  fScrWait(24,"No selection group selection requirements have been specified!")
               endif

               cOption(-1)
               break
            endif

         otherwise
            //Herstel
            fTClose( cData )
            cOption(-1)
            break
      endcase

      fARestScr(aCscr)

      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      else
         fScrOpsk(1,"Option "+cOption())
      endif

      //Open dataleer met massas
      cIngr := fTOpen(cDd(),"sm3indg")
      if left(cIngr,1) == "f"
         fTClose(cData)
         cOption(-1)
         break
      endif
      ferase(cDd()+"MASS"+ordbagext())
      cMass := fTOpen(cDd(),"mass")
      if left(cMass,1) == "f"
         fTClose(cData)
         fTClose(cIngr)
         cOption(-1)
         break
      endif

      //Kyk of daar diere in die leer is
      if lastrec() == 0
         if cLanType() == "A"
            fScrBood(23,"Geen kalwers kon gevind word vir die amptelike indeksverslag nie!")
         else
            fScrBood(23,"No calves could be found for the official index report!")
         endif
         fScrWait(24)
         fTClose(cMass)
         fTClose(cIngr)
         fTClose(cData)
         cOption(-1)
         break
      endif
      go top

      //Vra indeksouderdom
      // Vertoon hulpskerm
      if cLanType() == "A"
         fScrBood(23,"Kies met "+D_DNARR+D_UPARR+" toetse en druk "+D_ENTER+". Druk [Esc] vir die Submenu.")
      else
         fScrBood(23,"Choose with "+D_DNARR+D_UPARR+" tests and press "+D_ENTER+". Press [Esc] for the Sub menu.")
      endif
      if cBrep $ "JYjy"
         nCh := fNewMenu( 1, "SM3INDAbp" )
      else
         nCh := fNewMenu( 1, "SM3INDAb" )
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
            cFase := "A11"
         case nCh == 2
            cOude := "205"
            cFase := "A21"
         case nCh == 3
            cOude := "365"
            cFase := "B11"
         case nCh == 4
            cOude := "540"
            cFase := "B21"
         otherwise
            //Herstel
            fTClose(cMass)
            fTClose(cIngr)
            fTClose(cData)
            cOption(-2)
            break
      endcase

      //Velde om te vertoon
      asize( aVeld, 0 )
      aadd( aVeld, { "sm3data", "idnr" })
      aadd( aVeld, { "sm3data", "reknr" })
      aadd( aVeld, { "sm3data", "geslag" })
      aadd( aVeld, { "sm3data", "mas"+cOude })
      aadd( aVeld, { "sm3data", "mamoergeb" })
      aadd( aVeld, { "sm3data", "mamoerspe" })
      aadd( aVeld, { "sm3data", "dat"+cOude })
      aadd( aVeld, { "sm3data", "kod"+cOude })
      aadd( aVeld, { "sm3data", "unr"+cOude })
      aadd( aVeld, { "sm3data", "gebdatum" })
      aadd( aVeld, { "sm3data", "gebmassa" })

      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      // Autofill testyear and testno from index group
      if nGrpc = 1
         select SM3INDG
         seek cIndg
         cTesy := SM3INDG->testye
         cTesn := SM3INDG->testno
      endif

      //Vra die byvoeding vrae ens
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  [F1]=Hulp")
         fSCrBood(24,"Beantwoord vrae oor die toetsgroep!")
         nBoxc := fBoxCent(9,space(20),7,"Standaardvrae")
         @10,nBoxc say "      Toetsjaar" get cTesy pict "9999"
         @11,nBoxc say "    Toetsnommer" get cTesn pict "99"
         @12,nBoxc say "Grootmaakstatus" get cRear pict "9" valid(cRear$"1234567")
         @13,nBoxc say " Voedingsstatus" get cFeed pict "9" valid(cFeed$"123456")
      else
         fScrBood(23,"[Esc]=Menu  [F1]=Help")
         fSCrBood(24,"Please answer questions about the test group!")
         nBoxc := fBoxCent(9,space(20),7,"Standard questions")
         @10,nBoxc say "     Test year" get cTesy pict "9999"
         @11,nBoxc say "   Test number" get cTesn pict "99"
         @12,nBoxc say "Rearing status" get cRear pict "9" valid(cRear$"1234567")
         @13,nBoxc say "Feeding status" get cFeed pict "9" valid(cFeed$"123456")
      endif
      set cursor on
      read
      set cursor off
      if lastkey() == K_ENTER
      else
         fTClose(cMass)
         fTClose(cIngr)
         fTClose(cData)
         cOption(-2)
         break
      endif
      if empty(cTesy) .or. empty(cTesn)
         fTClose(cMass)
         fTClose(cIngr)
         fTClose(cData)
         cOption(-2)
         break
      endif
      if val(cTesy) >= 1960 .and. val(cTesy) < 2099
      else
         fTClose(cMass)
         fTClose(cIngr)
         fTClose(cData)
         cOption(-2)
         break
      endif
      if val(cTesn) > 0 .and. val(cTesn) < 100
      else
         fTClose(cMass)
         fTClose(cIngr)
         fTClose(cData)
         cOption(-2)
         break
      endif

      // Correct test number
      if val(cTesn) > 0 .and. val(cTesn) < 10
         cTesn := padl(alltrim(cTesn),2,"0")
      endif

      // Store this data in the index group file
      if nGrpc = 1
         // Index group was chosen
         select SM3INDG
         seek cIndg
         if found()
            do while !rlock()
            enddo
            SM3INDG->testye := cTesy
            Sm3INDG->testno := cTesn
         endif
      else
         // Other group or selection group were chosen
         select SM3INDG
         seek cTesy+cTesn
         if eof()
            dbappend()
         else
            do while !rlock()
            enddo
         endif
         SM3INDG->kode := cTesy+cTesn
         if cLanType() == "A"
            SM3INDG->besk := "Amptelike verslag"
         else
            SM3INDG->besk := "Official report"
         endif
         SM3INDG->testye := cTesy
         SM3INDG->testno := cTesn
      endif

      if cLanType() == "A"
         fScrOpsk( ,"Opsie "+cOption())
      else
         fScrOpsk( ,"Option "+cOption())
      endif

      //Databasis
      select MASS
      go top

      //Kry die ma se geboortedatum
      do while !eof()

         // Sluit
         do while !rlock()
         enddo

         MASS->gebdatum := ctod("")

         select SM3DATA
         seek MASS->idnr
         if nGrpc = 1
            // Do nothing
         else
            // Store as index group
            do while !rlock()
            enddo
            SM3DATA->indekskode := cTesy+cTesn
         endif

         // Get the youngest and oldest birth date
         if empty(dFirs)
            dFirs := SM3DATA->gebdatum
         endif
         if SM3DATA->gebdatum < dFirs
            dFirs := SM3DATA->gebdatum
         endif
         if SM3DATA->gebdatum > dLast
            dLast := SM3DATA->gebdatum
         endif

         // Allocate rear status codes

         // See if this field contains the correct data
         if SM3DATA->rearst $ "1234567"
         else
            select SM3DATA
            do while !rlock()
            enddo
            SM3DATA->rearst := cRear
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

         //seek MASS->idmoer
         //select MASS
         //MASS->gebdatum := SM3DATA->gebdatum

         //Volgende
         select MASS
         skip

      enddo
      select MASS
      go top

      // Display message if index group are too wide
      if cBrep $ "JYjy"
      else
         if dLast - dFirs > 100
            if cLanType() == "A"
               nBoxc := fBoxCent(9,space(50),8,"GEBOORTE OUDERDOMSBEPERKING!!!")
               @10, nBoxc say "Oudste dier gebore op " + dtoc(dFirs)
               @11, nBoxc say "Jongste dier gebore op " +dtoc(dLast)
               @12, nBoxc say "Ouderdomsverskil is " + alltrim(str(dLast-dFirs)) + " dae."
               @13, nBoxc say ""
               @14, nBoxc say "Ouderdomsverskil meer as die toelaatbare 100 dae."
               @15, nBoxc say "Indeksgroep sal herverdeel moet word."
            else
               nBoxc := fBoxCent(9,space(50),8,"BIRTH AGE RESTRICTION!!!")
               @10, nBoxc say "Oldest animal born on " + dtoc(dFirs)
               @11, nBoxc say "Youngest animal born on " +dtoc(dLast)
               @12, nBoxc say "Age difference is " + alltrim(str(dLast-dFirs)) + " days."
               @13, nBoxc say ""
               @14, nBoxc say "Age difference more than accetable 100 days."
               @15, nBoxc say "Please re-group animals until within boundaries."
            endif
            fScrWait(maxrow())
            fTClose(cMass)
            fTClose(cIngr)
            fTClose(cData)
            cOption(-2)
            break
         endif
      endif

      select MASS
      go top
      set relation to MASS->IDNR into SM3DATA

      //Vertoon die diere
      fVertoon( aVeld, cIndg )

      //Maak geboortedatum reg
      select MASS
      go top
      do while !eof()
         do while !rlock()
            MASS->gebdatum := SM3DATA->gebdatum
         enddo
         skip
      enddo

      //Herstel
      set relation to
      fTClose(cMass)
      fTClose(cIngr)
      fTClose(cData)
      cOption(-2)

   end

return NIL

/**************************************************************************/
STATIC FUNCTION fVertoon( aVeld, cIndg )

   //Veranderlikes
   local GetList := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   local cCurScr := fCurScreen()                 //Kleure ens
   local cBrowse                                 //Browse object
   local aColumn := {}                           //Kolomme array
   local i       := 0                            //Counter
   local lMore   := .t.                          //Logical looper
   local nKey    := 0                            //Keypress
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
   local cBrep   := ""

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Waardes
   cIndg := if(cIndg==NIL,space(6),cIndg)

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrBood(24,"Screen outlay being determined")
   endif
   aOpsk := fGetField( aVeld )

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
         fBox( nTop, nLeft, nBottom, nRight, cOude+" DAE FASE A & B VERSLAG VIR DIE "+trim(cIndg)+" INDEKSGROEP" )
      else
         fBox( nTop, nLeft, nBottom, nRight, cOude+" DAY PHASE A & B INDEX REPORT FOR THE "+trim(cIndg)+" INDEX GROUP" )
      endif
   else
      if cLanType() == "A"
         fBox( nTop, nLeft, nBottom, nRight, cOude+" DAE FASE A & B INDEKSVERSLAG" )
      else
         fBox( nTop, nLeft, nBottom, nRight, cOude+" DAY PHASE A & B INDEX REPORT")
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
      if cLanType() == "A"
         fScrBood( 23, "[Esc]=Menu  [Del ]=Skrap                           " )
         fScrBood( 24, "[F1 ]=Hulp  [AltP]=Druk   [AltF]=VersendElektronies" )
      else
         fScrBood( 23, "[Esc]=Menu  [Del ]=Delete                             " )
         fScrBood( 24, "[F1 ]=Help  [AltP]=Print   [AltF]=SubmitElectronically" )
      endif

      //Vries
      //cBrowse:freeze := 1

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

      elseif nKey == K_ALT_P
         //Alt P means print report
         cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
         if nPrnLptp() < 9
            // Normal printing
            nCopy := 1                           // fCopies(2) 07-05-28 12:16
            for i := 1 to nCopy
               if cBrep $ "JYjy"
                  if !fPrintBrep(1)
                  endif
               else
                  if !fPrint(1)
                  endif
               endif
            next
         else
            // Wordpad printing
            if cBrep $ "JYjy"
               if !fPrintBrep(1)
               endif
            else
               if !fPrint(1)
               endif
            endif
         endif

         cBrowse:refreshall()

      elseif nKey == K_ALT_F

         // Alt F means create electronic notofication
         cBrep := fRasNaam(substr(cTotNaam(),149,3),"BREEDP")
         if cBrep $ "JYjy"

            // Breedplan format
            if fDiskBrep()
               cBrowse:refreshall()
            endif

         else

            // Other formats
            if cIsoCoun() == "ZWE"
               if fDiskZimb()
                  cBrowse:refreshall()
               endif
            else
               if fDiskette()
                  cBrowse:refreshall()
               endif
            endif


         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3inda",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
return NIL

//*************************************************************************/
STATIC FUNCTION fDelete(cIndg)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lRetu := .f.
   local cBood := ""

   //Skerm
   fScrBood(23,MASS->idnr)
   if cLanType() == "A"
      cBood := "Moet bogenoemde dier uit die lys geskrap word?"
   else
      cBood := "Should above-mentioned animal be deleted from the list?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
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

/******************************************************************************/
STATIC FUNCTION fPrint(nSex)

   // Declare
   local lRetu := .t.
   local lLoop := .t.
   local nBlad := 1
   local cIcar := ""
   local cData := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrbood(24,"Fase A & B verslag word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(24,"Phase A & B report being printed!  [Esc]=Stop printer.")
      endif

      // Get the iso breed code
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Choose the database
      select MASS
      go top

      // Set full date
      set cent on

      // Set the printer on
      fPrnOn()

      // The print loop
      do while lLoop

         // Headings
         if prow() == 0

            fPrnCod( cPrnNorm() )

            if cLanType() == "A"
               cText := "NASIONALE VLEISBEES VEEVERBETERINGSSKEMA"
               @prow()+nPrnLine(),(nPrnWidt()/2)-len(cText)/2 say cText
               cText := "DIERTOETS WEEGLYS"
               @prow()+1,(nPrnWidt()/2)-len(cText)/2 say cText
               @prow()+1,     1 say upper( cGebNaam() )
               @prow()  , nPrnWidt()-31 say "            Verslag: "+cOption()
               @prow()+1,     1 say upper(substr(cTotNaam(),1,40))
               @prow()  , nPrnWidt()-31 say "              Datum: " + dtoc( dAppDate() )
               @prow()+1,     1 say upper(substr(cTotNaam(),41,40))
               @prow()  , nPrnWidt()-31 say "             Bladsy: " + ltrim( str( nBlad, 8 ) )
               @prow()+1,     1 say upper(substr(cTotNaam(),81,40))
               @prow()+1,     1 say upper(substr(cTotNaam(),121,4))
               cText := "LNR KANTOOR: "+upper(trim(substr(cTotNaam(),162,30)))
               @prow()  ,(nPrnWidt()/2)-len(cText)/2 say cText
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1,     1 say "      Keeper: " + padl(alltrim(substr(cTotNaam(),152,10)),7,"0")+cIcar
               @prow()  ,    29 say "Toetskode: " + cFase + "-"
               @prow()  ,pcol() say cIcar + "-"
               @prow()  ,pcol() say cTesy + "-"
               @prow()  ,pcol() say cTesn
               @prow()+1,     1 say "  Begindatum: " + dtoc(dFirs)
               @prow()  ,    29 say "Einddatum: " + dtoc(dLast)
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1, 1 say "                                                      Groepkode"
               @prow()+1, 1 say "                                                      --------- Moe"
               @prow()+1, 1 say "                                       Moe            G Gro Voe voe"
               @prow()+1, 1 say "ID Nommer    RegNr      GebDatum   Mas mas WeegDatum  e sta sta sta Onb"
               @prow()+1, 1 say "------------ ---------- ---------- --- --- ---------- - --- --- --- ---"
            else
               cText := "NATIONAL BEEF CATTLE IMPROVEMENT SCHEME"
               @prow()+nPrnLine(),(nPrnWidt()/2)-len(cText)/2 say cText
               cText := "ANIMAL TEST WEIGH LIST"
               @prow()+1,(nPrnWidt()/2)-len(cText)/2 say cText
               @prow()+1,     1 say upper( cGebNaam() )
               @prow()  , nPrnWidt()-31 say "             Report: "+cOption()
               @prow()+1,     1 say upper(substr(cTotNaam(),1,40))
               @prow()  , nPrnWidt()-31 say "               Date: " + dtoc( dAppDate() )
               @prow()+1,     1 say upper(substr(cTotNaam(),41,40))
               @prow()  , nPrnWidt()-31 say "               Page: " + ltrim( str( nBlad, 8 ) )
               @prow()+1,     1 say upper(substr(cTotNaam(),81,40))
               @prow()+1,     1 say upper(substr(cTotNaam(),121,4))
               cText := "ARC OFFICE: "+upper(trim(substr(cTotNaam(),162,30)))
               @prow()  ,(nPrnWidt()/2)-len(cText)/2 say cText
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1,     1 say "      Keeper: " + padl(alltrim(substr(cTotNaam(),152,10)),7,"0")+cIcar
               @prow()  ,    29 say "Test code: " + cFase + "-"
               @prow()  ,pcol() say cIcar + "-"
               @prow()  ,pcol() say cTesy + "-"
               @prow()  ,pcol() say cTesn
               @prow()+1,     1 say "  Start Date: " + dtoc(dFirs)
               @prow()  ,    29 say " End Date: " + dtoc(dLast)
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1, 1 say "                                                      GroupCode"
               @prow()+1, 1 say "                                                      --------- Dam"
               @prow()+1, 1 say "                                       Dam            S Rea Fee fee"
               @prow()+1, 1 say "ID Number    RegNo      BirthDate  Wht wht WeighDate  x sta sta sta Unr"
               @prow()+1, 1 say "------------ ---------- ---------- --- --- ---------- - --- --- --- ---"
            endif

         endif

         // Test to stop the printer
         if fPrnStop() = K_ESC
            lLoop := .f.
            lRetu := .f.
            break
         endif

         // Print animal details
         cData := fId(SM3DATA->idnr,.t.)
         //@prow()+1,       1 say padr(trim(left(cData,4)) + trim(substr(cData,5,2)) + trim(right(cData,4)),12)
         @prow()+1,       1 say cData
         @prow()  ,pcol()+1 say SM3DATA->reknr
         @prow()  ,pcol()+1 say dtoc(SM3DATA->gebdatum)
         @prow()  ,pcol()+1 say SM3DATA->mas&cOude.
         if cFase == "A21"
            @prow()  ,pcol()+1 say SM3DATA->mamoerspe
         else
            @prow()  ,pcol()+1 say "   "
         endif
         @prow()  ,pcol()+1 say dtoc(SM3DATA->dat&cOude.)
         if SM3DATA->geslag $ "1VFKC"
            @prow()  ,pcol()+1 say "F"
         else
            @prow()  ,pcol()+1 say "M"
         endif
         @prow()  ,pcol()+1 say " " + SM3DATA->rearst + " " // Rear status
         @prow()  ,pcol()+1 say " " + alltrim(SM3DATA->kod&cOude.) + " " // Feeding status
         if cFase == "A01"
            // Birth test - Print dam feeding status
            @prow()  ,pcol()+1 say "   "
         else
            // All other tests - Print nothing
            @prow()  ,pcol()+1 say "   "
         endif
         @prow()  ,pcol()+1 say " " + alltrim(SM3DATA->unr&cOude.) + " "

         @prow()+1, 1 say ""

         // Next record
         select MASS
         skip

         // Test for end of page
         if prow() >= nPrnPrnl() .or. eof()

            // Print onderste lyn
            @prow()  ,  1 say repl( "-",  nPrnWidt() )
            @prow()+1,  1 say cAppName()

            // Form feed
            fPrnEjec()

            // Next page
            nBlad++

            // Indien eof()
            if eof()
               lLoop := .f.
            endif

         endif

      enddo

      // Set data to top
      select MASS
      go top

   end

   // Set printer off
   fprnOff()

   // Set full date
   set cent off


return lRetu

/******************************************************************************/
STATIC FUNCTION fPrintBrep(nSex)

   // Declare
   local lRetu := .t.
   local lLoop := .t.
   local nBlad := 1
   local cIcar := ""
   local cData := ""

   begin sequence

      // Screen
      if cLanType() == "A"
         fScrbood(24,"Amptelike massasverslag word gedruk!  [Esc]=Stop drukker.")
      else
         fScrbood(24,"Official weights report being printed!  [Esc]=Stop printer.")
      endif

      // Get the iso breed code
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Choose the database
      select MASS
      go top

      // Set full date
      set cent on

      // Set the printer on
      fPrnOn()

      // The print loop
      do while lLoop

         // Headings
         if prow() == 0

            fPrnCod( cPrnNorm() )

            if cLanType() == "A"
               cText := fRasNaam(substr(cTotNaam(),149,3),"HEADBN")
               if empty(cText)
                  cText := fRasNaam(substr(cTotNaam(),149,3))
                  cText := "DIE " + upper(cText) + " BEESTELERSGENOOTSKAP VAN S.A."
               endif
               cText := "DIERTOETS WEEGLYS"
               @prow()+1,(nPrnWidt()/2)-len(cText)/2 say cText
               @prow()+1,     1 say upper( cGebNaam() )
               @prow()  , nPrnWidt()-31 say "            Verslag: "+cOption()
               @prow()+1,     1 say upper(substr(cTotNaam(),1,40))
               @prow()  , nPrnWidt()-31 say "              Datum: " + dtoc( dAppDate() )
               @prow()+1,     1 say upper(substr(cTotNaam(),41,40))
               @prow()  , nPrnWidt()-31 say "             Bladsy: " + ltrim( str( nBlad, 8 ) )
               @prow()+1,     1 say upper(substr(cTotNaam(),81,40))
               @prow()+1,     1 say upper(substr(cTotNaam(),121,4))
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1,     1 say "    10 Kudde: " + padl(alltrim(substr(cTotNaam(),152,10)),7,"0")
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1, 1 say "                                                  "
               @prow()+1, 1 say "                                       15         "
               @prow()+1, 1 say "01                      13         14  Sub 17  18 "
               @prow()+1, 1 say "ID Nommer    RegNr      WeegDatum  Mas Grp Hgt Skr"
               @prow()+1, 1 say "------------ ---------- ---------- --- --- --- ---"
            else
               cText := fRasNaam(substr(cTotNaam(),149,3),"HEADBN")
               if empty(cText)
                  cText := fRasNaam(substr(cTotNaam(),149,3))
                  cText := "THE " + upper(cText) + " CATTLE BREEDERS SOCIETY OF S.A."
               endif
               @prow()+nPrnLine(),(nPrnWidt()/2)-len(cText)/2 say cText
               cText := "ANIMAL TEST WEIGH LIST"
               @prow()+1,(nPrnWidt()/2)-len(cText)/2 say cText
               @prow()+1,     1 say upper( cGebNaam() )
               @prow()  , nPrnWidt()-31 say "             Report: "+cOption()
               @prow()+1,     1 say upper(substr(cTotNaam(),1,40))
               @prow()  , nPrnWidt()-31 say "               Date: " + dtoc( dAppDate() )
               @prow()+1,     1 say upper(substr(cTotNaam(),41,40))
               @prow()  , nPrnWidt()-31 say "               Page: " + ltrim( str( nBlad, 8 ) )
               @prow()+1,     1 say upper(substr(cTotNaam(),81,40))
               @prow()+1,     1 say upper(substr(cTotNaam(),121,4))
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1,     1 say "     10 Herd: " + padl(alltrim(substr(cTotNaam(),152,10)),7,"0")
               @prow()+1,     1 say repl( "-",  nPrnWidt() )
               @prow()+1, 1 say "                                                  "
               @prow()+1, 1 say "                                       15         "
               @prow()+1, 1 say "01                      13         14  Sub 17  18 "
               @prow()+1, 1 say "ID Nommer    RegNr      WeegDatum  Mas Grp Hgt Skr"
               @prow()+1, 1 say "------------ ---------- ---------- --- --- --- ---"
            endif

         endif

         // Test to stop the printer
         if fPrnStop() = K_ESC
            lLoop := .f.
            lRetu := .f.
            break
         endif

         // Print animal details
         altd()
         cData := fId(SM3DATA->idnr,.f.)
         @prow()+1,       1 say cData
         @prow()  ,pcol()+1 say SM3DATA->reknr
         @prow()  ,pcol()+1 say dtoc(SM3DATA->dat&cOude.)
         @prow()  ,pcol()+1 say SM3DATA->mas&cOude.
         if cFase == "A21"
            @prow()  ,pcol()+1 say SM3DATA->mamoerspe
         else
            @prow()  ,pcol()+1 say "   "
         endif
         @prow()  ,pcol()+1 say SM3DATA->mas&cOude.
         if SM3DATA->geslag $ "1VFKC"
            @prow()  ,pcol()+1 say "F"
         else
            @prow()  ,pcol()+1 say "M"
         endif
         @prow()  ,pcol()+1 say " " + SM3DATA->rearst + " " // Rear status
         @prow()  ,pcol()+1 say " " + alltrim(SM3DATA->kod&cOude.) + " " // Feeding status
         if cFase == "A01"
            // Birth test - Print dam feeding status
            @prow()  ,pcol()+1 say "   "
         else
            // All other tests - Print nothing
            @prow()  ,pcol()+1 say "   "
         endif
         @prow()  ,pcol()+1 say " " + alltrim(SM3DATA->unr&cOude.) + " "

         @prow()+1, 1 say ""

         // Next record
         select MASS
         skip

         // Test for end of page
         if prow() >= nPrnPrnl() .or. eof()

            // Print onderste lyn
            @prow()  ,  1 say repl( "-",  nPrnWidt() )
            @prow()+1,  1 say cAppName()

            // Form feed
            fPrnEjec()

            // Next page
            nBlad++

            // Indien eof()
            if eof()
               lLoop := .f.
            endif

         endif

      enddo

      // Set data to top
      select MASS
      go top

   end

   // Set printer off
   fprnOff()

   // Set full date
   set cent off


return lRetu



/******************************************************************************/
STATIC FUNCTION fPrintold(nSex)

   // Verklaar
   //local nTota := 0
   //local lLoop := .t.
   //local i     := 1
   //local nReko := 1
   //local cData := ""
   //local aSend := {}
   //local nBlad := 1
   //local nMidc := 0
   //local nWidt := 0
   //local nTopl := 0
   //local nPrnl := 0
   //local cCond := ""
   //local cNorm := ""
   //local lRetu := .t.
   //local cText := ""
   //local lPrin := .f.
   //local nPrnp := 0

   //Toets of drukker gereed is
   //if fPrnReady() == K_ESC
   //   return .f.
   //endif

   cNorm := cPrnNorm()
   cCond := cPrnCond()
   nWidt := nPrnWidt()
   nTopl := nPrnLine()
   nPrnl := nPrnPrnl()
   nMidc := nWidt - 29
   nPrnp := nPrnLeng()

   // Skerm
   fScrBood(23)

   // Skuif die databasis
   select MASS
   go top

   // See if any of the printable sex
   do while !eof()
      if nSex == 1
         if MASS->geslag $ "1VFKC"
            nTota++
         endif
      else
         if MASS->geslag $ "23MO"
            nTota++
         endif
      endif
      skip
   enddo
   go top
   if nTota <= 0
      return .t.
   endif

   // Skerm
   if cLanType() == "A"
      fScrbood(24,"Fase A & B verslag word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Phase A & B report being printed!  [Esc]=Stop printer.")
   endif

   fPrnOn()

   // Doen die loop
   lLoop := .t.
   do while lLoop

      // Opskrifte
      if prow() = 0
         fPrnCod( cNorm )

         if cLanType() == "A"
            cText := "NASIONALE VLEISBEES PRESTASIETOETSSKEMA"
            @prow()+nTopl,(nWidt/2)-len(cText)/2 say cText
            cText := "FASE A & B DATA"
            @prow()+1,(nWidt/2)-len(cText)/2 say cText
            @prow()+1,     1 say upper( cGebNaam() )
            @prow()  , nMidc say "            Verslag: "+cOption()
            @prow()+1,     1 say upper(substr(cTotNaam(),1,40))
            @prow()  , nMidc say "              Datum: " + dtoc( dAppDate() )
            @prow()+1,     1 say upper(substr(cTotNaam(),41,40))
            @prow()  , nMidc say "             Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say upper(substr(cTotNaam(),81,40))
            @prow()+1,     1 say upper(substr(cTotNaam(),121,4))
            cText := "STREEKSKANTOOR: "+upper(trim(substr(cTotNaam(),162,30)))
            @prow()  ,(nWidt/2)-len(cText)/2 say cText
            @prow()+1,  1 say repl( "=",  nWidt )
            fPrnCod( cCond )
            @prow()+1,1 say "           Lidnommer             Rasnommer            Fase"
            @prow()+1,1 say " 1         5                     12                   15"
            fPrnCod( cNorm )
            @prow()+1, 1 say '708'
            @prow()  , 7 say substr(cTotNaam(),152,10)
            @prow()  ,20 say substr(cTotNaam(),149,3)
            @prow()  ,32 say cFase
            if nSex == 1
               cText := "("+ltrim(str(nTota))+" vroulike diere in verslag)"
               @prow()  ,(nWidt - LEN(cText) + 1) say cText
            else
               cText := "("+ltrim(str(nTota))+" manlike diere in verslag)"
               @prow()  ,(nWidt - LEN(cText) + 1) say cText
            endif
            @prow()+1,  1 say repl( "=",  nWidt )
            fPrnCod( cCond )
            @prow()+1,1 say "                                                                Moer   Moer                               Kalf       Kalf  Moer"
            @prow()+1,1 say "                                                          Kalf  massa  massa   Moer  Weegdatum    Indeks  geboorte   geb.  geboorte"
            @prow()+1,1 say "Kode ID nommer           Rekenaarnommer      Ges   Massa  byv.  geb.   speen   byv.  JJ MM DD      kode   datum      massa datum"
            @prow()+1,1 say " 4                       17-26               27    28-30   31   32-34  35-37   38    39-44        45-46"
            fPrnCod( cNorm )
            @prow()+1,1 say repl( "=",  nWidt )
         else
            cText := "BEEF PERFORMANCE TESTING SCHEME"
            @prow()+nTopl,(nWidt/2)-len(cText)/2 say cText
            cText := "PHASE A & B DATA"
            @prow()+1,(nWidt/2)-len(cText)/2 say cText
            @prow()+1,     1 say upper( cGebNaam() )
            @prow()  , nMidc say "             Report: "+cOption()
            @prow()+1,     1 say upper(substr(cTotNaam(),1,40))
            @prow()  , nMidc say "               Date: " + dtoc( dAppDate() )
            @prow()+1,     1 say upper(substr(cTotNaam(),41,40))
            @prow()  , nMidc say "               Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,     1 say upper(substr(cTotNaam(),81,40))
            @prow()+1,     1 say upper(substr(cTotNaam(),121,4))
            cText := "REGIONAL OFFICE: "+upper(trim(substr(cTotNaam(),162,30)))
            @prow()  ,(nWidt/2)-len(cText)/2 say cText
            @prow()+1,  1 say repl( "=",  nWidt )
            fPrnCod( cCond )
            @prow()+1,1 say "           Member No.            Breed No.            Phase"
            @prow()+1,1 say " 1         5                     12                   15"
            fPrnCod( cNorm )
            @prow()+1, 1 say '708'
            @prow()  , 7 say substr(cTotNaam(),152,10)
            @prow()  ,20 say substr(cTotNaam(),149,3)
            @prow()  ,32 say cFase
            if nSex == 1
               cText := "("+ltrim(str(nTota))+" female animals in report)"
               @prow()  ,(nWidt - LEN(cText) + 1) say cText
            else
               cText := "("+ltrim(str(nTota))+" male animals in report)"
               @prow()  ,(nWidt - LEN(cText) + 1) say cText
            endif
            @prow()+1,  1 say repl( "=",  nWidt )
            fPrnCod( cCond )
            @prow()+1,1 say '                                                                Dam    Dam                                Calf       Calf  Dam'
            @prow()+1,1 say '                                                          Calf  mass   mass    Dam   Weighed      Index   date of    birth date of'
            @prow()+1,1 say 'Code ID number           Computer number     Sex   Mass   supp  birth  wean    supp  YY MM DD      code   birth      mass  birth'
            @prow()+1,1 say ' 4                       17-26               27    28-30   31   32-34  35-37   38    39-44        45-46'
            fPrnCod( cNorm )
            @prow()+1,1 say repl( "=",  nWidt )
         endif
      endif

      // Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         lRetu := .f.
         exit
      endif

      // Print only specific sex
      if nSex == 1 .and. MASS->geslag $ "1VFCK"
         lPrin := .t.
      elseif nSex == 2 .and. MASS->geslag $ "23MO"
         lPrin := .t.
      else
         lPrin := .f.
      endif

      if lPrin

         // Bewaar indekskode
         select SM3DATA
         if kod&cOude $ " 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ,10,12,13,14,15,01,02,03,04,05,06,07,08,09"
         elseif empty(cByvg)
         else
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := cByvg
         endif
         if empty(SM3DATA->kod&cOude)
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := "00"
         endif
         select MASS

         // Data
         @prow()+1, 1 say '1'

         // Id nommer
         cText := fId(SM3DATA->idnr,.t.)
         @prow()  , 3 say trim(left(cText,4)) + trim(substr(cText,5,2)) + trim(right(cText,4))
         @prow()  ,15 say SM3DATA->reknr
         @prow()  ,27 say SM3DATA->geslag
         @prow()  ,30 say SM3DATA->mas&cOude
         @prow()  ,35 say cByvk
         @prow()  ,38 say SM3DATA->mamoergeb
         @prow()  ,42 say SM3DATA->mamoerspe
         @prow()  ,47 say cByvm
         @prow()  ,50 say right(dtos(SM3DATA->dat&cOude),6)
         @prow()  ,58 say SM3DATA->kod&cOude
         @prow()  ,62 say right(dtos(SM3DATA->gebdatum),6)
         @prow()  ,69 say SM3DATA->gebmassa
         @prow()  ,72 say right(dtos(MASS->gebdatum),6)
         @prow()+1, 1 say ""

      endif

      // Volgende rekord
      skip

      // Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         // Print onderste lyn
         @prow()  ,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()

         // Form feed
         fPrnEjec()

         // fPrnOff()
         nBlad++

         // Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   // Herstel
   go top

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskette

   // Program to create diskettes with birth notification data

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local lMass := .f.
   local lRegi := .f.
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local nRout := 1
   local cNumb := ""
   local cIcar := ""
   local nMfil := 0
   local cStr := ""
   local cWrit := ""
   local nSeqn := 1
   local cSeqn := ""

   begin sequence

      // Open the data files
      aCdbf := fATopen(aCdbf,cDd(),"STDWAAR")
      if !aCdbf[len(aCdbf),1]
         break
      endif
      nSeqn := STDWAAR->elecsq + 1
      if nSeqn > 999
         nSeqn := 1
      endif
      do while !rlock()
      enddo
      STDWAAR->elecsq := nSeqn
      cSeqn := right("00"+alltrim(str(nSeqn)),3)

      // Test for zero weights and registration numbers
      select MASS
      go top
      do while !eof()

         // Test for mass
         if empty(SM3DATA->mas&cOude.)
            lMass := .t.
         endif

         // Test for registration number
         if empty(SM3DATA->reknr)
            lRegi := .t.
         endif

         // Next record
         select MASS
         skip

      enddo
      select MASS
      go top

      // Display message if empty mass
      if lMass
         if cLanType() == "A"
            nBoxc := fBoxCent(9,space(50),5,"MASSAS ONTBREEK!")
            @10, nBoxc say "Van die diere in die groep se gewigte ontbreek en"
            @11, nBoxc say "kan daarom nie elektronies versend word nie.     "
            @12, nBoxc say "Korrigeer of Skrap betrokke diere met [Del]elete."
         else
            nBoxc := fBoxCent(9,space(50),5,"MISSING WEIGHTS!")
            @10, nBoxc say "Weights for some of the animals in the group are  "
            @11, nBoxc say "missing and therefor cannot be sent electonically."
            @12, nBoxc say "Correct or [Del]elete the animals in question.    "
         endif
         fScrWait(maxrow())
         break
      endif

      // Display message if empty registration number
      if lRegi
         if cLanType() == "A"
            nBoxc := fBoxCent(9,space(60),5,"REGISTRASIENOMMERS ONTBREEK!")
            @10, nBoxc say "Van die diere in die groep se registrasienrs ontbreek en"
            @11, nBoxc say "kan daarom nie elektronies versend word nie.            "
            @12, nBoxc say "Korrigeer of Skrap betrokke diere met [Del]elete.       "
         else
            nBoxc := fBoxCent(9,space(60),5,"MISSING REGISTRATION NUMBERS!")
            @10, nBoxc say "Registration numbers for some of the animals in the group"
            @11, nBoxc say "are missing and therefor cannot be sent electonically.   "
            @12, nBoxc say "Please Correct or [Del]elete the animals in question.    "
         endif
         fScrWait(maxrow())
         break
      endif

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"P"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"P"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Prestasielˆer word voorberei")
      else
         fScrWbood(maxrow(),"Performance file being prepared")
      endif

      // Open the file
      //if file(cFile)
      //   set alternate to (cFile) additive
      //   set alternate on
      //   set console off
      //else
      //   set alternate to (cFile)
      //   set alternate on
      //   set console off
      //endif

      // Open the data file 12-08-16 13:22
      nMfil := fcreate(cFile)
      if nMfil < 0
         if cLanType() == "A"
            fScrBood(maxrow()-1)
            fScrWBood(maxrow(),"Prestasiedata epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
         else
            fScrBood(maxrow()-1)
            fScrWBood(maxrow(),"Performance data email file not created! Reason: "+alltrim(str(ferror(),5,0)))
         endif
         lRetu := .f.
         break
      endif

      // Write the data
      select MASS
      go top
      do while !eof()

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif
         set cons off
         set alternate on

         // Convert main id number
         //cData := padr(alltrim(SM3DATA->idnr),10)
         cData := padr(fid(SM3DATA->idnr,.t.),10)

         // The actual write
         /*?? padr("SM"+cVersion(),15)             // Batch number
         ?? right(dtos(date()),6)                // Employee
         ?? substr(time(),1,2)                   // Batch number
         ?? substr(time(),4,2)                   // Batch number
         ?? "WLAB"                               // Document code
         ?? padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         ?? alltrim(cIcar)                       // Breed code
         ?? cFase + cIcar + cTesy + cTesn        // Beef test code
         ?? dtosdmy(SM3DATA->dat&cOude)          // Weighing date
         ?? dtosdmy(SM3DATA->dat&cOude+1)        // Weighing date
         ?? padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         ?? alltrim(cIcar)                       // Breed code
         ?? cData                                // Farmers animal nr
         ?? padl(alltrim(SM3DATA->reknr),10,"0") // Computer number
         ?? dtosdmy(SM3DATA->gebdatum)           // Birthdate
         ?? padr(alltrim(str(SM3DATA->mas&cOude)),3) // Animal weight
         if cFase == "A21"
            ?? padl(alltrim(str(SM3DATA->mamoerspe)),4,"0") // Dam weight
         else
            ?? "0000"
         endif
         ?? dtosdmy(SM3DATA->dat&cOude)          // Weighing date
         if SM3DATA->geslag $ "1VFKC"            // Sex
            ?? "F"
         else
            ?? "M"
         endif
         ?? "0" + SM3DATA->rearst                // Rearing status
         ?? padl(alltrim(SM3DATA->kod&cOude),2,"0") // Feeding status
         if cFase == "A11" .or. cFase == "A21"
            ?? padl(alltrim(SM3DATA->kod&cOude),2,"0") // Dam feeding status
         else
            ?? space(2)
         endif
         ?? left(SM3DATA->unr&cOude,2)
         ?
         */
         // Header
         cWrit := "C"                            //1
         cWrit += substr(alltrim(cIcar),1,3)     // Breed code
         cWrit += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cWrit += "S"
         cWrit += cSeqn
         cWrit += padr("SM"+alltrim(cVersion()),10) // Version number
         //cStr += "CANC"                    // Document code
         //cStr += "C"                       // Action type


         // The actual write
         //cWrit := padr("SM"+cVersion(),15)       // Batch number
         //cWrit += right(dtos(date()),6)          // Employee
         //cWrit += substr(time(),1,2)             // Batch number
         //cWrit += substr(time(),4,2)             // Batch number
         cWrit += "WLAB"                         // Document code
         cWrit += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cWrit += alltrim(cIcar)                 // Breed code
         cWrit += cFase + cIcar + cTesy + cTesn  // Beef test code
         cWrit += dtosdmy(SM3DATA->dat&cOude)    // Weighing date
         cWrit += dtosdmy(SM3DATA->dat&cOude+1)  // Weighing date
         cWrit += padl(alltrim(substr(cTotNaam(),152,10)),7,"0") // Member number
         cWrit += alltrim(cIcar)                 // Breed code
         cWrit += cData                          // Farmers animal nr
         cWrit += padl(alltrim(SM3DATA->reknr),10,"0") // Computer number
         cWrit += dtosdmy(SM3DATA->gebdatum)     // Birthdate
         cWrit += padr(alltrim(str(SM3DATA->mas&cOude)),3) // Animal weight
         if cFase == "A21"
            cWrit += padl(alltrim(str(SM3DATA->mamoerspe)),4,"0") // Dam weight
         else
            cWrit += "0000"
         endif
         cWrit += dtosdmy(SM3DATA->dat&cOude)    // Weighing date
         if SM3DATA->geslag $ "1VFKC"            // Sex
            cWrit += "F"
         else
            cWrit += "M"
         endif
         cWrit += "0" + SM3DATA->rearst          // Rearing status
         cWrit += padl(alltrim(SM3DATA->kod&cOude),2,"0") // Feeding status
         if cFase == "A11" .or. cFase == "A21"
            cWrit += padl(alltrim(SM3DATA->kod&cOude),2,"0") // Dam feeding status
         else
            cWrit += space(2)
         endif
         cWrit += left(SM3DATA->unr&cOude,2)
         cWrit += chr(13)+Chr(10)

         // Write the data to the file
         fwrite(nMfil,cWrit)

         // Next
         select MASS
         skip

      enddo

      // Close the file
      //set console on
      //set alternate off
      //set alternate to
      fclose(nMfil)

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Prestasielˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Performance file was not created!")
         endif
      else
         //if cLanType() == "A"
         //   fScrBood(maxrow()-1,"Prestasielˆer is suksesvol geskep!")
         //else
         //   fScrBood(maxrow()-1,"Performance file was created succesfully!")
         //endif

         // Display note on the screen for removable medium
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam P"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Prestasiedatalˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name P"+cIcar+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing performance data was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Prestasiedata epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Performance data email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese PrestasiedataKennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese PrestasiedataKennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile + chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van prestasiedata vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Performance Data Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Performance Data Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic performance data notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif
      //fScrWait(maxrow())

   end
   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskZimb

   // Program to create diskettes with performance data

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local nRout := 1
   local cNumb := ""
   local cStr := ""
   local nMfil := 0
   begin sequence

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT"
      else
         cFile := cMailTar()+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Prestasielˆer word voorberei")
      else
         fScrWbood(maxrow(),"Performance file being prepared")
      endif

      // Open the file
      if file(cFile)
         set alternate to (cFile) additive
         set alternate on
         set console off
      else
         set alternate to (cFile)
         set alternate on
         set console off
      endif

      // Write the data
      select MASS
      go top
      do while !eof()

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif
         set cons off
         set alternate on

         //Bewaar indekskode
         select SM3DATA
         if kod&cOude $ " 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ,10,12,13,14,15,01,02,03,04,05,06,07,08,09"
         elseif empty(cByvg)
         else
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := cByvg
         endif
         if empty(SM3DATA->kod&cOude)
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := "00"
         endif
         select MASS

         // Convert main id number
         if sm3idfo() == "1"
            cData := fId(SM3DATA->idnr,.t.)
            cData := padr(trim(substr(cData,5,2)),2,"0") + "-" + ; // Jaartal
               padl(alltrim(str(val(right(cData,4)))),4,"0") + ; // Volgnommer
               alltrim(left(cData,4))            // Kuddekenmerk
         else
            cData := alltrim(SM3DATA->idnr)
         endif

         // The actual write
         ?? trim(cData)+","                      // Id number
         ?? trim(cFase)+","                      // Phase
         ?? trim(cFase)+","                      // Phase
         ?? alltrim(str(SM3DATA->mas&cOude))+"," // Mass
         ?? dtos(SM3DATA->dat&cOude)+","         // Weighing date
         ?? cByvk+","                            // Calf supplement
         ?? alltrim(SM3DATA->kod&cOude)+","      // Index code
         ?? ","                                  // Ranking
         ?? ","                                  // Group size
         ?? ","                                  // Corrected mass
         ?? ","                                  // Ada
         ?? ","                                  // Index
         ?? alltrim(str(SM3DATA->mamoergeb))+"," // Dam mass at birth
         ?? alltrim(str(SM3DATA->mamoerspe))+"," // Dam mass at wean
         ?? cByvm                                // Dam supplement
         ?

         // Next
         select MASS
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cFile)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Prestasielˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Performance file was not created!")
         endif
      else
         //if cLanType() == "A"
         //   fScrBood(maxrow()-1,"Prestasielˆer is suksesvol geskep!")
         //else
         //   fScrBood(maxrow()-1,"Performance file was created succesfully!")
         //endif

         // Display note on the screen
         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Prestasiedatalˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".TXT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing performance data was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Prestasiedata epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Performance data email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese Prestasiedatakennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese Prestasiedatakennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van prestasiedata vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Performance Data Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Performance Data Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic performance data notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

   end

   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu

/******************************************************************************/
STATIC FUNCTION fDiskBrep

   // Program to create diskettes with performance data for Breedplan
   // Breedplan data collection formats Version 4.1 dated 16 march 2000
   // Marcus O'Sullivan Bloemfontein Brahman December 2001

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local aCdbf := fATopen()
   local cDriv := ""
   local cFile := ""
   local cData := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local nRout := 1
   local cNumb := ""
   local cDreg := ""
   local nMfil := 0
   local cStr := ""
   begin sequence

      // Ask which route to send the data
      nRout := fNewMenu(nRout,"SM3GEBF")
      fARestScr(aCscr)
      if nRout < 1
         break
      endif

      // Get the drive
      if nRout = 1
         cDriv := stddriv()
         if empty(cDriv)
            break
         endif
         cDriv += "\"
         cFile := cDriv+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      else
         cFile := cMailTar()+"P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT"
      endif

      // Ask whether file must be deleted first
      if file(cFile)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese oordraglˆer eers geskrap word?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         else
            if fJaNee(maxrow(),"Should electronic transfer file first be deleted?",cColBott(),.t.,.t.)
               ferase(cFile)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Prestasielˆer word voorberei")
      else
         fScrWbood(maxrow(),"Performance file being prepared")
      endif

      // Open the file
      if file(cFile)

         nHdel := fopen(cFile,FO_WRITE)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Prestasielˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create performance file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

         fseek(nHdel, 0, FS_END)                 // Position record pointer at end of file

      else

         nHdel := fcreate(cFile)

         if nHdel < 0
            if cLanType() == "A"
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Prestasielˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
            else
               fScrBood(maxrow()-1)
               fScrWBood(maxrow(),"Unable to create performance file! Reason: "+alltrim(str(ferror(),5,0)))
            endif
            lRetu := .f.
            break
         endif

      endif

      // Write the data
      select MASS
      go top
      do while !eof()

         // Screen
         if cLanType() == "A"
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Voltooi"      )
         else
            fScrBood(maxrow()-1,padr(cData,12)+" "+fPercent(recno(),lastrec())+"% Completed"      )
         endif

         // Test if there is data
         if SM3DATA->mas&cOude < 1 .or. empty(SM3DATA->dat&cOude)
            // Next
            select MASS
            skip
            loop
         endif

         // Toets vir die kuddekenmerk
         if alltrim(substr(cTotNaam(),125,4)) $ SM3DATA->idnr
         else
            // Next
            select MASS
            skip
            loop
         endif

         // Bewaar indekskode
         select SM3DATA
         if kod&cOude $ " 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ,10,12,13,14,15,01,02,03,04,05,06,07,08,09"
         elseif empty(cByvg)
         else
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := cByvg
         endif
         if empty(SM3DATA->kod&cOude)
            do while !rlock()
            enddo
            SM3DATA->kod&cOude := "00"
         endif
         select MASS

         /*********************************************************************/
         // The actual write of the animal itself

         cStra := "K"                                  // Always K
         cStra += substr(cTotNaam(),152,7)             // Soc ident of herd

         // Calf tattoo
         cStra += padr(fId(SM3DATA->idnr,.f.),19)      // Id number

         cStra += "K"                                  // Kilograms
         cStra += space(1)                             // Further test
         cStra += space(1)                             // Disposal code

         set cent on
         cStra +=  strtran(dtoc(SM3DATA->dat&cOude),"/","") // Weighing date
         set cent off

         cStra += padl(ltrim(str(SM3DATA->mas&cOude)),4,"0") //Mass

         if val(SM3DATA->kod&cOude) > 0
            cStra += padl(SM3DATA->kod&cOude,3,"0")    // Man group
         else
            cStra += "SMB"
         endif

         cStra += space(1)                             // Desexed
         cStra += space(4)                             // Hip height

         // Scrotum circumference
         if cOude == "365"
            if SM3DATA->skr365 > 100 .and. SM3DATA->skr365 < 500
               cStra += padl(alltrim(str(SM3DATA->skr365)),3)
            else
               cStra += space(3)                       // Scrotum circ
            endif
         elseif cOude == "540"
            if SM3DATA->skr540 > 100 .and. SM3DATA->skr540 < 500
               cStra += padl(alltrim(str(SM3DATA->skr540)),3)
            else
               cStra += space(3)                       // Scrotum circ
            endif
         else
            cStra += space(3)                          // Scrotum circ
         endif

         cStra += space(2)                             // Serving capacity
         cStra += space(2)                             // Number of serves

         // Analysis indicator
         if val(cOude) < 300
            cStra += " "
         endif

         // Fill up
         cStra += space(128)

         cStra += chr(13) + chr(10)
         nLen := fwrite(nHdel,cStra)

         if nLen != len(cStra)
            fScrWBood(maxrow(),"File Write Error (Record A): "+ALLTRIM(STR(FERROR(),5,0)))
            break
         endif

         /*********************************************************************/
         // The actual write of the animals dam in case of wean
         if cOude == "205"

            // Only at wean

            if SM3DATA->mamoerspe > 0

               // Moederouderdom by speen

               cStrb := "K"                            // Always K
               cStrb += substr(cTotNaam(),152,7)       // Soc ident of herd

               // Dam tattoo
               cStra += padr(fId(SM3DATA->idmoer,.f.),19) // Id number

               cStra += "K"                            // Kilograms
               cStra += space(1)                       // Further test
               cStra += space(1)                       // Disposal code

               set cent on
               cStra +=  strtran(dtoc(SM3DATA->dat&cOude),"/","") // Weighing date
               set cent off

               cStra += padl(ltrim(str(SM3DATA->mamoerspe)),4,"0") //Mass
               cStra += space(3)                       // Man group
               cStra += space(1)                       // Desexed
               cStra += space(4)                       // Hip height
               cStra += space(3)                       // Scrotum circ
               cStra += space(2)                       // Serving capacity
               cStra += space(2)                       // Number of serves

               // Analysis indicator
               cStra += "M"

               // Fill up
               cStra += space(128)

               cStra += chr(13) + chr(10)
               nLen := fwrite(nHdel,cStra)

               if nLen != len(cStra)
                  fScrWBood(maxrow(),"File Write Error (Record A): "+ALLTRIM(STR(FERROR(),5,0)))
                  break
               endif

            endif

         endif

         // Next
         select MASS
         skip

      enddo

      // Close the file
      fclose(nHdel)

      // Test if file was created
      if !file(cFile)

         if cLanType() == "A"
            fScrBood(maxrow()-1,"Prestasielˆer is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"Performance file was not created!")
         endif

      else

         if nRout = 1

            if cLanType() == "A"
               nBoxc := fBoxCent( 10, space(50), 7,"Elektroniese lˆer" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "'n Lˆer met die naam P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT is op 'n"
               @12, nBoxc say "disket in disketaandrywer "+upper(left(cFile,1))+": geskryf!"
               @13, nBoxc say "Pos asseblief hierdie disket behoorlik verpak aan "
               @14, nBoxc say "die betrokke Registrerende Owerheid."
               fScrBood(maxrow()-1,"Prestasiedatalˆer is suksesvol geskep!")
            else
               nBoxc := fBoxCent( 10, space(50), 7,"Electronic file" )
               // Disk
               //             "         0         0         0         0         0"
               @11, nBoxc say "A file with the name P"+substr(cTotNaam(),149,3)+alltrim(substr(cTotNaam(),125,4))+".DAT was created on a"
               @12, nBoxc say "diskette in disk drive "+upper(left(cFile,1))+":!"
               @13, nBoxc say "Package this diskette properly and post to the"
               @14, nBoxc say "the relative Registering Authority."
               fScrBood(maxrow()-1,"File containing performance data was succesfully created!")
            endif
            fScrWait(maxrow())

         else

            // Create email message file

            nMfil := fcreate("MailFile.txt")
            if nMfil < 0
               if cLanType() == "A"
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Prestasiedata epos lˆer nie geskep! Rede: "+alltrim(str(ferror(),5,0)))
               else
                  fScrBood(maxrow()-1)
                  fScrWBood(maxrow(),"Performance data email file not created! Reason: "+alltrim(str(ferror(),5,0)))
               endif
               lRetu := .f.
               break
            endif

            // Build file contents

            if cLanType() == "A"

               cStr := "StoetMeester Elektroniese PrestasiedataKennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese PrestasiedataKennisgewing" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Elektroniese aantekening van prestasiedata vir:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Ras: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Naam: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Lidnommer: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Kuddekenmerk: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorvoegsel: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Voorberei deur " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            else

               cStr := "StudMaster Electronic Performance Data Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cMailAdd() + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic Performance Data Notification" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := cFile +chr(13) + Chr(10)
               fwrite(nMfil,cStr)
               cStr := "Electronic performance data notification for:" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Breed: " + fRasNaam(substr(cTotNaam(),149,3)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Name: " + alltrim(cGebNaam()) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Member Number: " + alltrim(substr(cTotNaam(),152,10)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Herd Designation: " + alltrim(substr(cTotNaam(),125,4)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prefix: " + alltrim(substr(cTotNaam(),129,20)) + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "" + chr(13) + chr(10)
               fwrite(nMfil,cStr)
               cStr := "Prepared by " + cAppName() + chr(13) + chr(10)
               fwrite(nMfil,cStr)

            endif

            fclose(nMfil)
            swpruncmd("mailfile.exe mailfile.txt",300)

         endif

      endif

      //fScrWait(maxrow())

   end
   // Reset
   fATclose(aCdbf)
   fARestScr(aCscr)

return lRetu
