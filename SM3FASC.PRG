//SM3FASC.PRG
//Program om fase d te bereken
//Kopiereg (C) 1992 A van Rensburg
//04-22-93 08:46am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3fasc

   //Verklaar
   local cRass := ""
   local nStdg := 0
   local i     := 0
   local cFasg := ""
   local cFasd := ""
   local aSend := {}
   local aRecv := {}
   local cFase := ""
   local cData := ""
   local cIdnr := ""
   local nRekn := 0
   local cIndf := cDd()+"fasd"+ordbagext()
   local cText := ""
   //Ouderdom sufers
   local nOaan := 0
   local nOtot := 0
   local nOgem := 0
   //Gdo syfers
   local nGebm := 0
   local nGdoa := 0
   local nGdot := 0
   local nGdog := 0
   //Gdt syfers
   local nGdta := 0
   local nGdtt := 0
   local nGdtg := 0
   //Kleiber verhouding
   local nKaan := 0
   local nKtot := 0
   local nKgem := 0
   //Rangorde
   local nTell := 1
   local nIndv := 999
   local nVort := 0
   local nVori := 0

   // Screen
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   //Kry die standaard geboortemassa
   cRass := fTOpen(,"sm3rass",,"tdb")
   if left(cRass,1) == "f"
      return NIL
   endif
   //Vind die regte ras
   locate for SM3RASS->raskod == substr( cTotNaam(), 149, 3 )
   if eof()
      go top
   endif
   nStdg := SM3RASS->gebma3
   fTClose(cRass)

   //Berei die fasegroep voor
   cFasg := sm3fasf()
   if len(trim(cfasg)) <= 0
      cOption(-1)
      return NIL
   endif

   // Screen
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   //Toets of data gevind is
   ferase(cDd()+"fasd"+cIndeExt())
   cFasd := fTOpen(cDd(),"fasd",,,,.f.)
   if left(cFasd,1) == "f"
      cOption(-1)
      return NIL
   endif
   if lastrec() <= 0
      fTClose(cFasd)
      if cLanType() == "A"
         fScrBood(23,"Geen diere vir Fase D berekeninge gevind nie!")
      else
         fScrBood(23,"No animals found for Phase D calculations!")
      endif
      fScrWait(24)
      cOption(-1)
      return NIL
   endif

   //Kry velde
   aadd(aSend,{"fasd","idnr"})
   aadd(aSend,{"sm3data","daeint"})
   aadd(aSend,{"sm3data","begmassa"})
   aadd(aSend,{"sm3data","einmas"})
   aadd(aSend,{"fasd","mas365"})
   aadd(aSend,{"sm3data","gdogdo"})
   aadd(aSend,{"sm3data","gdoind"})
   aadd(aSend,{"sm3data","gdtgdt"})
   aadd(aSend,{"sm3data","gdtind"})
   aadd(aSend,{"sm3data","rangor"})
   aadd(aSend,{"sm3data","kleiber"})
   aadd(aSend,{"sm3data","kleiberi"})
   aadd(aSend,{"fasd","kalfbnr"})

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open dataleers
   if cLanType() == "A"
      fScrWbood( 24, "Datalˆers word geopen" )
   else
      fScrWbood( 24, "Data files being opened" )
   endif
   cFase := fTOpen(cDd(),"sm3fase",,,,.f.)
   if left(cFase,1) == "f"
      fTClose(cFasd)
      cOption(-1)
      return NIL
   endif
   cData := fTOpen(cDd(),"sm3data",,,,.f.)
   if left(cData,1) == "f"
      fTClose(cFase)
      fTClose(cFasd)
      cOption(-1)
      return NIL
   endif
   select FASD
   go top
   set relation to FASD->IDNR into SM3DATA

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Gdo en Gdt word bereken!")
   else
      fScrBood(24,"Ada and Adg being calculated!")
   endif

   //Berekeninge
   do while !eof()

      //Maak skoon
      FASD->gemspeeni := 0
      FASD->kalfbnr := space(8)
      FASD->mas365 := 0
      FASD->gdo365 := 0
      FASD->oud540 := 0
      FASD->gma540 := 0
      FASD->ind540 := 0
      FASD->oud205 := 0
      FASD->mas205 := 0
      FASD->kleiber := 0
      SM3DATA->gdogdo := 0
      SM3DATA->gdoind := 0
      SM3DATA->gdtgdt := 0
      SM3DATA->gdtind := 0
      SM3DATA->daeint := 0
      SM3DATA->tydgen := 0
      SM3DATA->rangor := 0
      SM3DATA->kleiber := 0
      SM3DATA->kleiberi := 0

      //Kry moer se gemiddelde speenindeks
      select SM3DATA
      nRekn := recno()
      cIdnr := SM3DATA->idmoer
      seek cIdnr
      FASD->gemspeeni := SM3DATA->gemspeeni
      goto nRekn
      select FASD

      //Kyk of data bestaan
      if SM3DATA->begmassa <= 0
         FASD->kalfbnr := strtran(FASD->kalfbnr," ","A",1,1)
      endif
      if SM3DATA->begdatum == ctod("")
         FASD->kalfbnr := strtran(FASD->kalfbnr," ","B",1,1)
      endif
      if SM3DATA->einmas <= 0
         FASD->kalfbnr := strtran(FASD->kalfbnr," ","C",1,1)
      endif
      if SM3DATA->eindat == ctod("")
         FASD->kalfbnr := strtran(FASD->kalfbnr," ","D",1,1)
      endif
      if "A" $ FASD->kalfbnr .or. ;
            "B" $ FASD->kalfbnr .or. ;
            "C" $ FASD->kalfbnr .or. ;
            "D" $ FASD->kalfbnr
         skip
         loop
      endif

      //Bereken die ouderdom asook gemiddeldes
      if SM3DATA->gebdatum == ctod("")
         FASD->kalfbnr := strtran(FASD->kalfbnr," ","E",1,1)
      else
         nRekn := SM3DATA->eindat - SM3DATA->gebdatum
         if nRekn > 0 .and. nRekn <= 999
            FASD->oud540 := nRekn
            nOaan++
            nOtot += FASD->oud540
         endif
      endif

      //Bereken gdo en gekorrigeerde massa
      //Geboortemassa
      nGebm := SM3DATA->gebmassa
      if nGebm <= 0
         nGebm := nStdg                          //Standaardwaarde
      endif
      nRekn := round((((SM3DATA->einmas-nGebm)/FASD->oud540)*1000),0)
      if nRekn > 0 .and. nRekn <= 9999
         SM3DATA->gdogdo := nRekn
         nGdoa++
         nGdot += SM3DATA->gdogdo
      endif

      //Bereken dae in toets
      nRekn := SM3DATA->eindat - SM3DATA->begdatum
      if nRekn > 0 .and. nRekn <= 999
         SM3DATA->daeint := nRekn
      endif

      //Bereken dae sedert vorige weging
      nRekn := SM3DATA->eindat - SM3DATA->vordatum
      if nRekn > 0 .and. nRekn <= 999
         FASD->oud205 := nRekn
      endif

      //Bereken toename
      nRekn := SM3DATA->einmas - SM3DATA->begmassa
      if nRekn > 0 .and. nRekn <= 999
         FASD->mas365 := nRekn
      endif

      //Bereken toename sedert vorige weging
      nRekn := SM3DATA->einmas - SM3DATA->vormassa
      if nRekn > -99 .and. nRekn <= 999
         FASD->mas205 := nRekn
      endif

      //Bereken gdt
      if SM3DATA->daeint > 0
         nRekn := round(((FASD->mas365/SM3DATA->daeint)*1000),0)
         if nRekn > 0 .and. nRekn <= 9999
            SM3DATA->gdtgdt := nRekn
            nGdta++
            nGdtt += nRekn
         endif
      endif

      //Bereken gdt vanaf vorige weging
      if FASD->oud205 > 0
         //nRekn := round(((FASD->mas205/FASD->oud205)*1000),0)
         nRekn := round((FASD->mas205/FASD->oud205),3)
         if nRekn > -999.999 .and. nRekn <= 9999.999
            FASD->kleiber := nRekn
         endif
      endif

      //Volgende
      select FASD
      skip

   enddo

   //Bereken gemiddeldes
   //Ouderdom
   nOgem := 1
   if nOaan > 0
      nOgem := round(nOtot/nOaan,0)
   endif
   //Gdo
   nGdog := 1
   if nGdoa > 0
      nGdog := round(nGdot/nGdoa,0)
   endif
   //Gdt
   nGdtg := 1
   if nGdta > 0
      nGdtg := round(nGdtt/nGdta,0)
   endif

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Gdo indeks, Gdt indeks & Kleiberverhouding word bereken!")
   else
      fScrBood(24,"Ada index, Adg index & Kleiber ratio being calculated!")
   endif

   //Berekeninge
   select FASD
   go top
   do while !eof()

      //Tydgenote
      SM3DATA->tydgen := nGdta

      //Bereken Gdo indeks
      nRekn := round((SM3DATA->gdogdo/nGdog)*100,0)
      if nRekn > 0 .and. nRekn <= 999
         SM3DATA->gdoind := nRekn
      endif

      //Bereken Gdt indeks
      nRekn := round((SM3DATA->gdtgdt/nGdtg)*100,0)
      if nRekn > 0 .and. nRekn <= 999
         SM3DATA->gdtind := nRekn
         FASD->ind540 := nRekn
      endif

      //Kleiber verhouding

      //Dae verskil tussen oud en gemiddelde oud
      nRekn := nOgem - FASD->oud540
      if nRekn > -999 .and. nRekn <= 9999
         FASD->gdo365 := nRekn
      endif

      //Gekorrigeerde massa
      nRekn := SM3DATA->einmas + round( FASD->gdo365 * (SM3DATA->gdogdo/1000) ,0 )
      if nRekn > 0 .and. nRekn <= 999
         FASD->gma540 := nRekn
      else
         FASD->gma540 := 0
      endif

      //Kleiber verhouding
      nRekn := FASD->gma540 ** 0.75
      if nRekn > 0
         nRekn := round(SM3DATA->gdtgdt/nRekn,3)
         if nRekn > 0 .and. nRekn <= 9999.999
            SM3DATA->kleiber := nRekn
            nKaan++
            nKtot += SM3DATA->kleiber
         endif
      endif

      //Hoogte aanpassing
      nRekn := SM3DATA->mateskouer + round(FASD->gdo365*.45,0)
      if nRekn >= -999 .and. nRekn <= 9999
         SM3DATA->gekhoo := nRekn
      endif

      //Lengte aanpassing
      nRekn := SM3DATA->matelengte + round(FASD->gdo365*.55,0)
      if nRekn >= -999  .and. nRekn <= 9999
         SM3DATA->geklen := nRekn
      endif

      //Veldikte aanpassing
      nRekn := SM3DATA->veldikte + round(FASD->gdo365*.55,1)
      if nRekn >= -99.9 .and. nRekn <= 999.9
         SM3DATA->gekvel := nRekn
      endif

      //Skrotum aanpassing
      nRekn := SM3DATA->mateskrot + round(FASD->gdo365*.55,0)
      if nRekn >= -99 .and. nRekn <= 999
         SM3DATA->gekskr := nRekn
      endif

      //Hoogte:lengte
      if SM3DATA->mateskouer > 0
         nRekn := round(SM3DATA->matelengte/SM3DATA->mateskouer,2)
         if nRekn > 0 .and. nRekn <= 9.99
            SM3DATA->hoolen := nRekn
         endif
      endif

      //Volgende
      select FASD
      skip

   enddo

   //Kleiber gemiddeldes
   nKgem := 1
   if nKaan > 0
      nKgem := round(nKtot/nKaan,3)
   endif

   //Sorteer data om rangorde te bepaal
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Bereken Kleiber verhouding indeks en rangorde")
   else
      fScrWbood(24,"Calculate Kleiber ratio and order")
   endif
   index on descend(FASD->ind540) to (cIndf)
   set index to (cIndf)
   //Waardes
   go top
   do while !eof()

      //Bereken Kleiber indeks
      nRekn := round((SM3DATA->kleiber/nKgem)*100,0)
      if nRekn > 0 .and. nRekn <= 999
         SM3DATA->kleiberi := nRekn
      endif

      //Indeks moet bekend wees
      if FASD->ind540 <= 0
         skip
         loop
      endif

      //Rangorde
      if FASD->ind540 == nVori
         SM3DATA->rangor := nVort
      else
         SM3DATA->rangor := nTell
      endif

      //Waardes
      nVori := FASD->ind540
      nVort := SM3DATA->rangor
      nTell++

      //Bereken skermgemiddeldes
      for i := 1 to len(aRecv)
         if aRecv[i][3] == "N"
            //Kry die regte leer
            cText := aRecv[i,1]
            select select(alltrim(strtran(cText,"->")))
            if fieldget(aRecv[i,13]) <> 0
               aRecv[i][11]++
               aRecv[i][12] += fieldget(aRecv[i,13])
            endif
         endif
      next

      //Volgende
      select FASD
      skip

   enddo

   //Herstel
   select FASD
   set inde to
   go top

   //Vertoon die berekende indekse
   fVertoon(aRecv,cFasg)

   //Herstel
   fTClose(cFase)
   fTClose(cFasd)
   fTClose(cData)
   cOption(-1)

return NIL

//**************************************************************************/
STATIC FUNCTION fVertoon(aRecv,cFasg)

   //Funksie om fase d berekeninge te vertoon

   //Verklaar
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local nTopp := 3
   local nLeft := 2
   local nBott := 21
   local nRigh := 76
   local nScrl := 0
   local oCols := NIL
   local aCalc := {}
   local lSort := .f.
   local cSort := cDd()+"fasd"+ordbagext()
   local nCopy := 0

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Waardes
   cFasg := if(cFasg==NIL,space(6),cFasg)

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 76, 76, nLeft+nScrl )

   //Teken die box
   if len(cFasg) == 6
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, "FASE D BEREKENINGE VIR DIE "+trim(cFasg)+" FASEGROEP" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "PHASE D CALCULATIONS FOR THE "+trim(cFasg)+" PHASE GROUP" )
      endif
   else
      if cLanType() == "A"
         fBox( nTopp, nLeft, nBott, nRigh, "FASE D BEREKENINGE" )
      else
         fBox( nTopp, nLeft, nBott, nRigh, "PHASE D CALCULATIONS")
      endif
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTopp+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"
   bBrow:footsep := "Í"

   //Plaas kolomme oor na die browse object en gemiddeldes
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
      //Gemiddeldes
      oCols := bBrow:getcolumn(i)
      if aRecv[i][11] <> 0
         oCols:footing := str(  aRecv[i][12]/aRecv[i][11] ,aRecv[i][4], aRecv[i][5] )
      else
         oCols:footing := ""
         if i == 1
            if cLanType() == "A"
               oCols:footing := left(ltrim(str(lastrec()))+" Dier/e",aRecv[i][4])
            else
               oCols:footing := left(ltrim(str(lastrec()))+" Animal/s",aRecv[i][4])
            endif
         endif
      endif
      bBrow:setcolumn(i,oCols)
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
      bBrow:freeze := 1

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         // Esc means leave
         lMore := .f.

      elseif nKeyp == K_DEL
         //Alt D means delete animal from list
         if fDelete(cFasg)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_W
         //Alt W means display waarskuwings
         fWarning(fieldget(3))

      elseif nKeyp == K_ALT_V
         //Alt V means display vaar gemiddeldes
         if len(aCalc) > 0
         else
            aCalc := fVaarCalc()
            bBrow:refreshall()
         endif
         fVaarDisp(aCalc)

      elseif nKeyp == K_ALT_P
         //Alt P means print a record
         nCopy := 1 // fCopies(1) 07-05-28 12:15
         for i := 1 to nCopy
            if len(aCalc) > 0
               if !fPrint(cFasg,aCalc)
                  exit
               endif
            else
               aCalc := fVaarCalc()
               if !fPrint(cFasg,aCalc)
                  exit
               endif
            endif
         next
         bBrow:refreshall()

      elseif nKeyp == K_ALT_S
         //Alt S means sort
         fSort()
         bBrow:refreshall()

      elseif nKeyp == K_F1
         //Hulp
         do help with "sm3fasc",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
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
         aadd(aWarn,padr("Beginmassa onbekend",35))
      else
         aadd(aWarn,padr("Starting mass unknown",35))
      endif
   endif
   if "B" $ cWarn
      if cLanType() == "A"
         aadd(aWarn,padr("Begindatum onbekend",35))
      else
         aadd(aWarn,padr("Starting date unknown",35))
      endif
   endif
   if "C" $ cWarn
      if cLanType() == "A"
         aadd(aWarn,padr("Eindmassa onbekend",35))
      else
         aadd(aWarn,padr("Final mass unknown",35))
      endif
   endif
   if "D" $ cWarn
      if cLanType() == "A"
         aadd(aWarn,padr("Eindweegdatum onbekend",35))
      else
         aadd(aWarn,padr("Final weigh date unknown",35))
      endif
   endif
   if "E" $ cWarn
      if cLanType() == "A"
         aadd(aWarn,padr("Kalf geboortedatum onbekend",35))
      else
         aadd(aWarn,padr("Calf date of birth unknown",35))
      endif
   endif

   //Vertoon
   if len(aWarn) > 0
      if cLanType() == "A"
         fbox(9,23,15,62,"Waarskuwings",cColMenu())
      else
         fbox(9,23,15,62,"Warnings",cColMenu())
      endif
      setcolor(cColMenu())
      achoice(10,25,14,60,aWarn)
      setcolor(cColNorm())
   endif

   //Herstel
   restscreen(0,0,24,79,cCscr)

return NIL

//*************************************************************************/
STATIC FUNCTION fDelete(cFasg)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lRetu := .f.
   local cBood := ""

   //Skerm
   fScrBood(23,FASD->idnr)
   if cLanType() == "A"
      cBood := "Moet bogenoemde dier uit die fasegroep geskrap word?"
   else
      cBood := "Should above-mentioned animal be deleted from the phase group?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
      //Fasegroep uit
      if SM3DATA->fasekode == cFasg
         select SM3DATA
         SM3DATA->fasekode := "      "
         select FASD
      endif
      //Verwyder dier uit lys
      delete
      skip
      if eof()
         go top
      endif
      lRetu := .t.
   endif

return lRetu

//**************************************************************************/
STATIC FUNCTION fSort()

   //Funksie om diere te sorteer

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local aSort := {}
   local nBoxc := 0
   local cIndf := cDd()+"fasd"+ordbagext()

   //Bou array
   if cLanType() == "A"
      aadd(aSort,padr("A - Id nommer",25))
      aadd(aSort,padr("B - Gdo indeks",25))
      aadd(aSort,padr("C - Gdt indeks",25))
      aadd(aSort,padr("D - Kleiber indeks",25))
   else
      aadd(aSort,padr("A - Id number",25))
      aadd(aSort,padr("B - Ada index",25))
      aadd(aSort,padr("C - Adg index",25))
      aadd(aSort,padr("D - Kleiber index",25))
   endif

   //Vertoon
   if cLanType() == "A"
      nBoxc := fBoxCent(10,space(20),4,"Sorteer",cColMenu())
   else
      nBoxc := fBoxCent(10,space(20),4,"Sort",cColMenu())
   endif
   setcolor(cColMenu())
   nBoxc := achoice(10,nBoxc,13,nBoxc+20,aSort)
   setcolor(cColNorm())

   //Die keuses
   do case
      case nBoxc == 1
         //id nommer
         set index to
      case nBoxc == 2
         //Gdo indeks
         select FASD
         set index to
         go top
         do while !eof()
            FASD->ind540 := SM3DATA->gdoind
            skip
         enddo
         go top
         index on descend(FASD->ind540) to (cIndf)
         set index to (cIndf)
         go top
      case nBoxc == 3
         //Gdt indeks
         select FASD
         set index to
         go top
         do while !eof()
            FASD->ind540 := SM3DATA->gdtind
            skip
         enddo
         go top
         index on descend(FASD->ind540) to (cIndf)
         set index to (cIndf)
         go top
      case nBoxc == 4
         //Kleiber indeks
         select FASD
         set index to
         go top
         do while !eof()
            FASD->ind540 := SM3DATA->kleiberi
            skip
         enddo
         go top
         index on str(FASD->ind540) to (cIndf) descend
         set index to (cIndf)
         go top
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)

return NIL

//***************************************************************************/
STATIC FUNCTION fVaarCalc()

   //Funksie om vaargemiddeldes te bereken

   //Verklaar
   local cCscr := savescreen(23,0,24,79)
   local nElem := 0
   local aCalc := {}
   local aVaar := {}

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Vaargemiddeldes word bereken")
   else
      fScrWbood(24,"Sire averages being calculated")
   endif

   //Databasis
   select FASD
   go top

   //Die loop
   do while !eof()

      nElem := ascan(aVaar,SM3DATA->idvaar)
      if nElem > 0
      else
         aadd(aVaar,SM3DATA->idvaar)
         aadd(aCalc,{SM3DATA->idvaar,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
         // 1 = id nommer
         // 2 = aantal
         // 3 = massa toename aantal
         // 4 = massa toename totaal
         // 5 = gdogdo aantal
         // 6 = gdogdo totaal
         // 7 = gdoind aantal
         // 8 = gdoind totaal
         // 9 = gdtgdt aantal
         //10 = gdtgdt totaal
         //11 = gdtind aantal
         //12 = gdtind totaal
         //13 = klever aantal
         //14 = klever totaal
         //15 = kleind aantal
         //16 = kleind totaal
         nElem := len(aCalc)
      endif
      aCalc[nElem][2]++
      if FASD->mas365 > 0
         aCalc[nElem][ 3]++
         aCalc[nElem][ 4] += FASD->mas365
      endif
      if SM3DATA->gdogdo > 0
         aCalc[nElem][ 5]++
         aCalc[nElem][ 6] += SM3DATA->gdogdo
      endif
      if SM3DATA->gdoind > 0
         aCalc[nElem][ 7]++
         aCalc[nElem][ 8] += SM3DATA->gdoind
      endif
      if SM3DATA->gdtgdt > 0
         aCalc[nElem][ 9]++
         aCalc[nElem][10] += SM3DATA->gdtgdt
      endif
      if SM3DATA->gdtind > 0
         aCalc[nElem][11]++
         aCalc[nElem][12] += SM3DATA->gdtind
      endif
      if SM3DATA->kleiber > 0
         aCalc[nElem][13]++
         aCalc[nElem][14] += SM3DATA->kleiber
      endif
      if SM3DATA->kleiberi > 0
         aCalc[nElem][15]++
         aCalc[nElem][16] += SM3DATA->kleiberi
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
STATIC FUNCTION fVaarDisp(aCalc)

   //Funksie om vaders te vertoon

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local i     := 0
   local aVaar := {}
   local nBoxc := 0
   local nLeng := 0

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
   nLeng := len(aVaar[1])
   if cLanType() == "A"
      nBoxc := fBoxCent(5,space(nLeng),14,"Vaargemiddeldes",cColMenu())
   else
      nBoxc := fBoxCent(5,space(nLeng),14,"Sire averages",cColMenu())
   endif
   setcolor(cColMenu())
   achoice(5,nBoxc,19,nBoxc+nLeng,aVaar,,,4)
   setcolor(cColNorm())

   //Herstel
   restscreen(0,0,24,79,cCscr)

return NIL

//**************************************************************************/
STATIC FUNCTION fVaar(aCalc)

   //Funksie om array te bou met vaargemiddeldes

   //Verklaar
   local aVaar := {}
   local nMass := 0
   local nGdoo := 0
   local nGdoi := 0
   local nGdtt := 0
   local nGdti := 0
   local nKlee := 0
   local nKlei := 0
   local nI    := 0

   if cLanType() == "A"
      aadd(aVaar,"             Aan Mas      Gdo      Gdt Kleiber  Kle")
      aadd(aVaar,"Vaar Id      kal toe Gdo  ind Gdt  ind verhoud  ind")
      aadd(aVaar,"------------ --- --- ---- --- ---- --- -------- ---")
   else
      aadd(aVaar,"             No. Mas      Ada      Adg Kleiber  Kle")
      aadd(aVaar,"Sire Id      cal gai Ada  ind Adg  ind ratio    ind")
      aadd(aVaar,"------------ --- --- ---- --- ---- --- -------- ---")
   endif
   for nI = 1 to len(aCalc)

      //Bereken gemiddeldes
      if aCalc[ni][3] > 0
         nMass := round(aCalc[nI][4]/aCalc[nI][3],0)
      else
         nMass := 0
      endif
      if aCalc[ni][5] > 0
         nGdoo := round(aCalc[nI][6]/aCalc[nI][5],0)
      else
         nGdoo := 0
      endif
      if aCalc[ni][7] > 0
         nGdoi := round(aCalc[nI][8]/aCalc[nI][7],0)
      else
         nGdoi := 0
      endif
      if aCalc[ni][9] > 0
         nGdtt := round(aCalc[nI][10]/aCalc[nI][9],0)
      else
         nGdtt := 0
      endif
      if aCalc[ni][11] > 0
         nGdti := round(aCalc[nI][12]/aCalc[nI][11],0)
      else
         nGdti := 0
      endif
      if aCalc[ni][13] > 0
         nKlee := round(aCalc[nI][14]/aCalc[nI][13],3)
      else
         nKlee := 0
      endif
      if aCalc[ni][15] > 0
         nKlei := round(aCalc[nI][16]/aCalc[nI][15],0)
      else
         nKlei := 0
      endif

      //Bou die array
      aadd(aVaar,aCalc[ni][1]+" "+;
         str(aCalc[ni][2],3,0)+" "+;
         str(nMass,3,0)+" "+;
         str(nGdoo,4,0)+" "+;
         str(nGdoi,3,0)+" "+;
         str(nGdtt,4,0)+" "+;
         str(nGdti,3,0)+" "+;
         str(nKlee,8,3)+" "+;
         str(nKlei,3,0))
   next

return aVaar

/*************************************************************************/
STATIC FUNCTION fPrint(cFasg,aCalc,aRecv)

   //Verklaar
   local lRetu := .t.
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local cText := ""
   local aVaar := {}
   local lWarn := .f.
   local cHdl1 := ""
   local cHdl2 := ""
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
   select FASD
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"fasd","idnr"})
      aadd(aSend,{"sm3data","generasie"})
      aadd(aSend,{"sm3data","gebdatum"})
      aadd(aSend,{"sm3data","idvaar"})
      aadd(aSend,{"sm3data","idmoer"})
      aadd(aSend,{"fasd","gemspeeni"})
      aadd(aSend,{"sm3data","ind205"})
      aadd(aSend,{"sm3data","begmassa"})
      aadd(aSend,{"sm3data","einmas"})
      aadd(aSend,{"fasd","mas365"})
      aadd(aSend,{"sm3data","gdogdo"})
      aadd(aSend,{"sm3data","gdoind"})
      aadd(aSend,{"sm3data","gdtgdt"})
      aadd(aSend,{"sm3data","gdtind"})
      aadd(aSend,{"sm3data","rangor"})
      aadd(aSend,{"sm3data","tydgen"})
      aadd(aSend,{"sm3data","kleiber"})
      aadd(aSend,{"sm3data","kleiberi"})
      aadd(aSend,{"sm3data","vormassa"})
      aadd(aSend,{"fasd","mas205"})
      aadd(aSend,{"fasd","kleiber"})

      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Bepaal die drukwydte
   nWidt := 0
   for nI = 1 to len(aRecv)
      nWidt += aRecv[nI,4]+1
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
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      // Condense
      cPcod := cPrnCond()
      nWidt := nPrnCwid()
      nTopl := nPrnLine()
      if nPrnLptp() < 8
         nPrnl := nPrnPrnl()
         nPagl := nPrnLeng()
      else
         nPrnl := nPrcPrnl()
         nPagl := nPrcLeng()
      endif
   endif

   nMidc := nWidt - 29

   //Bou array met vaargemiddeldes
   aVaar := fVaar(aCalc)

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Fase D verslag word gedruk!  [Esc]=Stop drukker.")
      if len(cFasg) == 6
         cHdl1 := upper("Fase D indeksverslag van die fasegroep "+trim(cFasg)+".")
      else
         cHdl1 := upper("Fase D indeksverslag.")
      endif
      cHdl2 := "Begindatum: "+dtoc(SM3DATA->begdatum)+" Laaste weegdatum: "+dtoc(SM3DATA->eindat)+" Dae in toets: "+alltrim(str(SM3DATA->daeint))
   else
      fScrbood(24,"Phase D report being printed!  [Esc]=Stop printer.")
      if len(cFasg) == 6
         cHdl1 := upper("Phase D index report for the index group "+trim(cFasg)+".")
      else
         cHdl1 := upper("Phase D index report.")
      endif
      cHdl2 := "Starting date: "+dtoc(SM3DATA->begdatum)+" Final weigh date: "+dtoc(SM3DATA->eindat)+" Days in test: "+str(SM3DATA->daeint)
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
            @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
            @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
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
            @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
            @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
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
      if len(trim(FASD->kalfbnr)) > 0
         lWarn := .t.
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
               if fieldget(aRecv[nI,13]) <> 0
                  aRecv[nI,11]++
                  aRecv[nI,12] += fieldget(aRecv[nI,13])
               endif
               if upper(aRecv[nI,2]) == "GDOGDO"
                  cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + "-"
               elseif upper(aRecv[nI,2]) == "GDTGDT"
                  cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + "-"
               else
                  cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
               endif
            case aRecv[nI][3] == "D"
               //Date
               cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI][4])+" "
         endcase
         select FASD
      next
      @prow()+1,1 say padr(cData, nWidt)

      //Skerm
      // fPrnOff()
      // if nTota > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Voltooi"
      //    else
      //       @ 23, 30 say fPercent(nReko/nTota)+"% Completed"
      //    endif
      //    setcolor( cColNorm() )
      //    nReko++
      // endif
      // fPrnOn()

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
                  if aRecv[nI,11] <> 0
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
            if prow()+len(aVaar)+3 > nPrnl
               //Druk op volgende bladsy
               @prow()+1,  1 say repl( "=",  nWidt )
               @prow()+1,  1 say cAppName()
               fPrnEjec()
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
                  @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
                  @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
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
                  @prow()  ,nWidt-len(cHdl1)+1 say cHdl1
                  @prow()+1,nWidt-len(cHdl2)+1 say cHdl2
               endif
               @prow()+1,  1 say repl( "=",  nWidt )
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
            if lWarn
               if cLanType() == "A"
                  @prow()+1,  1 say padr("-Waarskuwings"+repl("-", nWidt),nWidt)
                  @prow()+1,  1 say "A-Beginmassa onbekend  C-Eindmassa onbekend      E-Geboortedatum onbekend"
                  @prow()+1,  1 say "B-Begindatum onbekend  D-Eindweegdatum onbekend  H-Kalfmassa ontbreek    "
               else
                  @prow()+1,  1 say padr("-Warnings"+repl("-", nWidt),nWidt)
                  @prow()+1,  1 say "A-Starting mass unknown   C-Final mass unknown        E-Birth date unknown"
                  @prow()+1,  1 say "B-Starting date unknown   D-Final weigh date unknown  H-Calf mass unknown "
               endif
            endif
         endif

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
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

