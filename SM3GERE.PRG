//SM3GERE.PRG
//Program om gdt verslag te druk
//Kopiereg (c) 1993 A van Rensburg
//04-29-93 09:49am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3gere

   //Veranderlikes
   local i     := 1
   local cSeek := ""
   local cEiev := ""
   local nTel  := 0
   local aSend := {}
   local aRecv := {}
   local aCscr := {}
   local nWatt := 0
   local nOrde := 0
   local lLoop := .t.
   local dDa1a := ctod("")
   local dDa1b := ctod("")
   local dDa2a := ctod("")
   local dDa2b := ctod("")
   local nBoxc := 0
   local cSm3w := ""
   local cWeeg := ""
   local cData := ""
   local cIdnr := ""
   local nBegm := 0
   local dBegd := ctod("")
   local nEinm := 0
   local dEind := ctod("")
   local nReko := 1
   local nTota := 0
   local nAant := 0
   local nSomt := 0
   local nMin  := 0
   local nData := 0
   local cHdln := ""
   local cMemf := ""
   local getlist := {}

   private cTest := ""

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
      fScrWbood(24,"Veldbeskrywings word opgesoek")
      cSeek := "GDTVER"
   else
      fScrOpsk(,"Option "+cOption())
      fScrWbood(24,"Field descriptions being sorted")
      cSeek := "ADGREP"
   endif

   cEiev := fTOpen(cDd(),"sm3eiev")
   if left(cEiev,1) == "f"
      return NIL
   endif
   seek cSeek
   //Bou die send array
   aadd(aSend,{"weeg","idnr"      })
   aadd(aSend,{"weeg","datum1"    })
   aadd(aSend,{"weeg","datum2"    })
   aadd(aSend,{"weeg","daeint"    })
   aadd(aSend,{"weeg","massa1"    })
   aadd(aSend,{"weeg","massa2"    })
   aadd(aSend,{"weeg","toenam"    })
   aadd(aSend,{"weeg","gdtgdt"    })
   aadd(aSend,{"weeg","indeks"    })
   for i = 1 to 40
      if substr(SM3EIEV->veld,nTel,10) <> space(10) .and. substr(SM3EIEV->veld,nTel+10,10) <> space(10)
         aadd(aSend,{trim(substr(SM3EIEV->veld,nTel,10)),trim(substr(SM3EIEV->veld,nTel+10,10))})
      endif
      nTel := nTel + 20
   next
   //Sluit leer
   fTClose(cEiev)
   aRecv := fGetField(aSend)

   //Vra datums
   if cLanType() == "A"
      nBoxc := fBoxCent(5,space(30),7,"WEEGDATUMS")
   else
      nBoxc := fBoxCent(5,space(30),7,"WEIGH DATES")
   endif
   lLoop := .t.
   do while lLoop
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Menu  [F1]=Hulp")
         fScrBood(24,"Tik die begin en eindweegdatums!")
         @ 6,nBoxc say "Begin weegdatum vanaf" get dDa1a
         @ 7,nBoxc say "Begin weegdatum tot  " get dDa1b
         @ 9,nBoxc say " Eind weegdatum vanaf" get dDa2a
         @10,nBoxc say " Eind weegdatum tot  " get dDa2b
      else
         fScrBood(23,"[Esc]=Menu  [F1]=Help")
         fScrBood(24,"Type the first and the last weigh dates!")
         @ 6,nBoxc say "First weigh date from" get dDa1a
         @ 7,nBoxc say "First weigh date to  " get dDa1b
         @ 9,nBoxc say " Last weigh date from" get dDa2a
         @10,nBoxc say " Last weigh date to  " get dDa2b
      endif
      set cursor on
      read
      set cursor off
      if lastkey() == K_ESC
         return NIL
      endif
      //Toetse
      if dDa1b == ctod("")
         dDa1b := dDa1a
      endif
      if dDa2b == ctod("")
         dDa2b := dDa2a
      endif
      if dDa1a == ctod("") .or. dDa2a == ctod("")
         if cLanType() == "A"
            fScrBood(23,"Begin en eindweegdatums is verpligtend!")
         else
            fScrBood(23,"First and last weigh dates are compulsory!")
         endif
         fScrWait(24)
         loop
      endif
      if dDa1a > dDa2a .or. dDa1b > dDa2a
         if cLanType() == "A"
            fScrBood(23,"Begindatums moet vroe‰r as die einddatum wees!")
         else
            fScrBood(23,"First dates should be earlier than the last date!")
         endif
         fScrWait(24)
         loop
      endif
      if dDa1b < dDa1a .or. dDa2b < dDa2a
         if cLanType() == "A"
            fScrBood(23,"Die vanaf datums moet vroe‰r as die tot datums wees!")
         else
            fScrBood(23,"The from dates should be earlier than the too dates!")
         endif
         fScrWait(24)
         loop
      endif
      lLoop := .f.
   enddo

   //Vertoon menu met vrae oor watter diere
   nWatt := fNewMenu(1,"WEEGA")
   if nWatt = 0
      return NIL
   endif

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption(nWatt))
   else
      fScrOpsk(1,"Option "+cOption(nWatt))
   endif

   //Vertoon menu met watter volgorde
   nOrde := fNewMenu(1,"WEEGB")
   if nOrde = 0
      cOption(-1)
      return NIL
   endif

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption(nOrde))
   else
      fScrOpsk(1,"Option "+cOption(nOrde))
   endif

   //Open die dataleer
   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      cOption(-2)
      return NIL
   endif
   if nOrde == 1
      set order to 7
   endif
   cSm3w := fTOpen(cDd(),"sm3weeg",,,,.f.)
   if left(cSm3w,1) == "f"
      fTClose(cData)
      cOption(-2)
      return NIL
   endif
   nTota := lastrec()
   ferase(cDd()+"weeg"+cIndeExt())
   cWeeg := fTOpen(cDd(),"weeg",,,,.f.)
   if left(cWeeg,1) == "f"
      fTClose(cSm3w)
      fTClose(cData)
      cOption(-2)
      return NIL
   endif

   //Maak leer skoon
   zap
   aCscr := fASaveScr()

   //Die keuses
   do case
      case nWatt == 1
         //Alle diere geweeg
         if cLanType() = "A"
            cHdln := "Alle diere"
         else
            cHdln := "All animals"
         endif

      case nWatt == 2
         //Groep
         cTest := sm3groe()
         if cLanType() = "A"
            cHdln := "Groep diere"
         else
            cHdln := "Group of animals"
         endif

      case nWatt == 3
         //Seleksiegroep
         cTest := sm3selg()
         cMemf := cDd()+"sm3selg.mem"
         restore from (cMemf) additive
         if cLanType() = "A"
            cHdln := "SELEKSIE: "+ALLTRIM(cMbes)
         else
            cHdln := "SELECTION: "+ALLTRIM(cMbes)
         endif

      case nWatt == 4
         //Fasegroep
         //Kry die fasegroep
         cTest := sm3fasg(4)
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen fasegroep is gekies nie!")
            else
               fScrWait(24,"No phase group was selected!")
            endif
            cOption(-2)
            return NIL
         endif
         //Mem veranderlikes
         if cLanType() == "A"
            cHdln := trim(cTest) + " Fasegroep"
         else
            cHdln := trim(cTest) + " Phase group"
         endif

      case nWatt == 5
         //Indeksgroep
         //Kry die indeksgroep
         cTest := sm3indg(4)
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen indeksgroep is gekies nie!")
            else
               fScrWait(24,"No index group was selected!")
            endif
            cOption(-2)
            return NIL
         endif
         //Mem veranderlikes
         if cLanType() == "A"
            cHdln := trim(cTest) + " Indeksgroep"
         else
            cHdln := trim(cTest) + " Index group"
         endif

      otherwise
         cOption(-2)
         return NIL
   endcase

   //Skerm
   fARestScr(aCscr)
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Diere word uitgesoek en gdt bereken")
   else
      fScrWbood(24,"Animals being sorted and adg calculated")
   endif
   select SM3WEEG
   go top
   cIdnr := SM3WEEG->idnr

   do while !eof()

      //Maak false
      nBegm := 0
      nEinm := 0

      //Kyk deur dier self
      do while SM3WEEG->idnr == cIdnr
         setcolor(cColBott())
         if cLanType() == "A"
            @23,35 say ltrim(str(zer(nReko,nTota)*100,3,0))+"% Voltooi"
         else
            @23,35 say ltrim(str(zer(nReko,nTota)*100,3,0))+"% Completed"
         endif
         nReko++
         setcolor(cColNorm())
         if SM3WEEG->weegdatum >= dDa1a .and. SM3WEEG->weegdatum <= dDa1b
            nBegm := SM3WEEG->massa
            dBegd := SM3WEEG->weegdatum
         endif
         if SM3WEEG->weegdatum >= dDa2a .and. SM3WEEG->weegdatum <= dDa2b
            nEinm := SM3WEEG->massa
            dEind := SM3WEEG->weegdatum
         endif
         //Volgende
         select SM3WEEG
         skip
      enddo

      //Kyk of wel bestaan
      select SM3DATA
      seek cIdnr
      if eof()
         nBegm := 0
      else
         if len(trim(cTest)) > 0
            if nWatt == 4
               if SM3DATA->fasekode != cTest
                  nBegm := 0
               endif
            elseif nWatt = 5
               if SM3DATA->indekskode != cTest
                  nBegm := 0
               endif
            elseif &cTest
            else
               nBegm := 0
            endif
         endif
      endif
      select SM3WEEG

      //Bewaar data
      if nBegm > 0 .and. nEinm > 0
         select WEEG
         append blank
         WEEG->idnr := cIdnr
         WEEG->datum1 := dBegd
         WEEG->massa1 := nBegm
         WEEG->datum2 := dEind
         WEEG->massa2 := nEinm
         WEEG->daeint := WEEG->datum2 - WEEG->datum1
         WEEG->toenam := WEEG->massa2 - WEEG->massa1
         WEEG->gdtgdt := zer(WEEG->toenam,WEEG->daeint)*1000
         nAant++
         nSomt += WEEG->gdtgdt
         if WEEG->gdtgdt < nMin
            nMin := WEEG->gdtgdt
         endif
         select SM3WEEG
      endif

      //Volgende dier
      cIdnr := SM3WEEG->idnr

   enddo

   //Toets of daar diere gekies was
   select WEEG
   go top
   if lastrec() == 0
      if cLanType() == "A"
         fScrBood(23,"Geen diere gevind wat voldoen aan weegdatum vereistes nie!")
      else
         fScrBood(23,"No animals found that comply with above weigh date requirements!")
      endif
      fScrWait(24)
      fTClose(cWeeg)
      fTClose(cSm3w)
      fTClose(cData)
      cOption(-2)
      return NIL
   endif
   nReko := 1
   nTota := lastrec()

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Gdt indekse word bereken")
   else
      fScrWbood(24,"Adg indices being calculated")
   endif

   if nMin < 0
      nMin := ABS(nMin) + 10
      nSomt := nSomt + (nMin * nAant)
   endif
   nSomt := zer(nSomt,nAant)

   do while !eof()
      nData := round(zer((WEEG->gdtgdt + nMin),nSomt)*100,0)
      if nData <= 9999 .and. nData >= -999
         WEEG->indeks := nData
      else
         WEEG->indeks := 0
      endif
      //Volgende dier
      skip
   enddo
   go top

   //Vertoon
   select WEEG
   set relation to WEEG->IDNR into SM3DATA
   fVertoon(aRecv,cHdln)

   //Herstel
   fTClose(cWeeg)
   fTClose(Csm3w)
   fTClose(cData)
   cOption(-2)

return NIL

//**************************************************************************/
STATIC FUNCTION fVertoon(aRecv,cHdln)

   //Funksie om gdt verslag te vertoon

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
   local cSort := cDd()+"weeg"+ordbagext()
   local nCopy := 0
   local cText := ""

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Bereken gemiddeldes
   do while !eof()
      //Bereken skermgemiddeldes
      for i := 1 to len(aRecv)
         if aRecv[i][3] == "N"
            //Kry die regte leer
            cText := aRecv[i,1]
            select select(alltrim(strtran(cText,"->")))
            if UPPER(aRecv[i,2]) == "TOENAM" .OR. UPPER(aRecv[i,2]) == "GDTGDT"
               aRecv[i,11]++
               aRecv[i,12] += fieldget(aRecv[i,13])
            elseif fieldget(aRecv[i,13]) <> 0
               aRecv[i,11]++
               aRecv[i,12] += fieldget(aRecv[i,13])
            endif
         endif
      next
      skip
   enddo
   go top

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
   if cLanType() == "A"
      fBox( nTopp, nLeft, nBott, nRigh, "GEREELDE WEGINGS GDT VERSLAG" )
   else
      fBox( nTopp, nLeft, nBott, nRigh, "REGULAR WEIGHINGS ADG REPORT" )
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
            fScrBood( 23, "[Esc]  [      Alt S       ]  [Alt P]" )
            fScrBood( 24, " Menu  Sorteer op Id nommer   Druk  " )
         else
            fScrBood( 23, "[Esc]  [     Alt S     ]  [Alt P]" )
            fScrBood( 24, " Menu  Sort on Id number   Print " )
         endif

      else
         if cLanType() == "A"
            fScrBood( 23, "[Esc]  [     Alt S     ]  [Alt P]" )
            fScrBood( 24, " Menu  Sorteer op indeks   Druk  " )
         else
            fScrBood( 23, "[Esc]  [   Alt S   ]  [Alt P]" )
            fScrBood( 24, " Menu  Sort on index   Print " )
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

      elseif nKeyp == K_ALT_P
         //Alt P means print a record
         nCopy := 1 // fCopies(1) 07-05-28 12:16
         for i := 1 to nCopy
            if !fPrint(aRecv,cHdln)
               exit
            endif
         next
         bBrow:refreshall()

      elseif nKeyp == K_ALT_S
         //Alt S means sort
         if lSort
            lSort := .f.
            set index to
         else
            lSort := .t.
            index on WEEG->indeks to (cSort) descend
            set index to (cSort)
         endif
         go top
         bBrow:refreshall()

      elseif nKeyp == K_F1
         //Hulp
         do help with "sm3gere",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
return NIL


/*************************************************************************/
STATIC FUNCTION fPrint(aRecv,cHdln)

   //Verklaar
   local lRetu := .t.
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nBlad := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nTotl := 0
   local cText := ""
   local aVaar := {}
   local lWarn := .f.
   local cPcod := ""

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      return .f.
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   select WEEG
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"weeg","idnr"      })
      aadd(aSend,{"weeg","datum1"    })
      aadd(aSend,{"weeg","datum2"    })
      aadd(aSend,{"weeg","daeint"    })
      aadd(aSend,{"weeg","massa1"    })
      aadd(aSend,{"weeg","massa2"    })
      aadd(aSend,{"weeg","toenam"    })
      aadd(aSend,{"weeg","gdtgdt"    })
      aadd(aSend,{"weeg","indeks"    })
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Bepaal die drukgrootte
   nTotl := 0
   for nI = 1 to len(aRecv)
      nTotl+= aRecv[nI,4]+1
      if aRecv[nI,3] == "N"
         aRecv[nI,11] := 0
         aRecv[nI,12] := 0
      endif
   next

   if nTotl <= nPrnWidt()
      cPcod := cPrnNorm()
      nWidt := nPrnWidt()
      nTopl := nPrnLine()
      nPrnl := nPrnPrnl()-2
      nPagl := nPrnLeng()
   else
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
      fScrbood(24,"Gereelde wegings gdt verslag word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Regular weighings adg report being printed!  [Esc]=Stop printer.")
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
            cText := "Gereelde wegings gdt verslag."
            @prow()  ,nWidt-len(cText)+1 say cText
            @prow()+1,nWidt-len(cHdln)+1 say cHdln
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
            cText := "Regular weighings adg report."
            @prow()  ,nWidt-len(cText)+1 say cText
            @prow()+1,nWidt-len(cHdln)+1 say cHdln
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
               if UPPER(aRecv[nI,2]) == "TOENAM" .OR. UPPER(aRecv[nI,2]) == "GDTGDT"
                  aRecv[nI,11]++
                  aRecv[nI,12] += fieldget(aRecv[nI,13])
               elseif fieldget(aRecv[nI,13]) <> 0
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
         select WEEG
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
         if EOF()
            //Druk gemiddeldes
            if cLanType() == "A"
               @prow()+1,  1 say padr("-Gemiddeldes"+repl("-", nWidt),nWidt)
            else
               @prow()+1,  1 say padr("-Averages"+repl("-", nWidt),nWidt)
            endif

            for nI := 1 to len(aRecv)
               if aRecv[nI,3] == "N"
                  if nI == 1
                     @prow()+1,  1 say str(zer(aRecv[nI,12],aRecv[nI,11]),aRecv[nI,4],aRecv[nI,5])
                  else
                     @prow(),pcol()+1 say str(zer(aRecv[nI,12],aRecv[nI,11]),aRecv[nI,4],aRecv[nI,5])
                  endif
               else
                  if nI == 1
                     @prow()+1,  1 say repl(" ",aRecv[nI,4])
                  else
                     @prow()  ,pcol()+1 say repl(" ",aRecv[nI,4])
                  endif
               endif
            next
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

