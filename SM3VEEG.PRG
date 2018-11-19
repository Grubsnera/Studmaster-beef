//SM3VEEG.PRG
//Program om veegetalle te vertoon
//Kopiereg (c) 1993 A van Rensburg
//21:30 21 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3veeg( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cVeeg := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(8)
   local dDatu := ctod("")

   private cData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif
   else
      if cLanType() == "A"
         fScrOpsk( 1, "Opsie "+cOption())
      else
         fScrOpsk( 1, "Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,21, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3veeg","datumm"})
      aadd(aSend,{"sm3veeg","beskry"})
      aadd(aSend,{"sm3veeg","aantal"})
      aadd(aSend,{"sm3veeg","gemmas"})
      aadd(aSend,{"sm3veeg","waar01"})
      aadd(aSend,{"sm3veeg","waar02"})
      aadd(aSend,{"sm3veeg","waar03"})
      aadd(aSend,{"sm3veeg","genesp"})
      aadd(aSend,{"sm3veeg","genef5"})
      aadd(aSend,{"sm3veeg","genef4"})
      aadd(aSend,{"sm3veeg","genef3"})
      aadd(aSend,{"sm3veeg","genef2"})
      aadd(aSend,{"sm3veeg","genef1"})
      aadd(aSend,{"sm3veeg","genef0"})
      aadd(aSend,{"sm3veeg","geneni"})
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cVeeg := fTOpen(cDd(),"sm3veeg")
   if left(cVeeg,1) == "f"
      return cRetu
   endif

   //Skuif die databasis
   if cFind == NIL
      go bottom
      cFind := dtos(SM3VEEG->datumm)
      seek cFind
   else
      cRetu := cFind
      set soft on
      seek cFind
      set soft off
      if eof()
         go top
      endif
   endif

   //Kry die breedte van venster
   for i = 1 to len(aRecv)
      //Lengte
      nScrl := nScrl + aRecv[i,4] + 1
      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRigh := if(nLeft+nScrl > 77, 77, nLeft+nScrl )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBott, nRigh, "VEEGETALLE" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "STOCK FIGURES" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   bBrow := TBrowseDB( nTop+1, nLeft+1, nBott-1, nRigh-1 )
   bBrow:headsep := "Í"
   bBrow:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aCols )
      bBrow:addColumn( aCols[i] )
   next

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[Esc]=Menu   [0 - 3]=Vind" )
         fScrBood( 24, "[Del]=Skrap  [Alt P]=Druk" )
      else
         fScrBood( 23, "[Esc]=Menu    [0 - 3]=Find " )
         fScrBood( 24, "[Del]=Delete  [Alt P]=Print" )
      endif

      //Vries
      bBrow:freeze := 2

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
         if SM3VEEG->datumm <> dDatu
            dDatu := SM3VEEG->datumm
            keyboard chr(K_CTRL_BS)
         endif
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete(aRecv)
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "0123"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_CTRL_BS
         //Alt G means calculate averages
         if fAverage(aRecv,bBrow)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         fPrint(aRecv)
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cVeeg)
   fTClose(cCdbf)
return cRetu

/*************************************************************************/
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""
   local cSeek   := dtos(SM3VEEG->datumm)

   //Skerm
   if cLanType() == "A"
      fScrBood(23,"Veegetalle soos op "+dtoc(SM3VEEG->datumm))
      cBood := "Moet bogenoemde veegetalle geskrap word?"
   else
      fScrBood(23,"Stock count as at "+dtoc(SM3VEEG->datumm))
      cBood := "Should above-mentioned stock figures be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
      seek cSeek
      do while dtos(SM3VEEG->datumm) == cSeek
         do while !rlock()
         enddo
         delete
         skip
      enddo
      if eof()
         go top
      endif
      lReturn := .t.
   endif

return lReturn

/*************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local dData := ctod("")
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   keyboard chr(nKeyp)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[1][6] get dData pict aRecv[1][10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. dData == ctod("")
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   set softseek on
   seek dData
   set softseek off
   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local cSeek := ""
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
      return NIL
   endif

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   cSeek := dtos(SM3VEEG->datumm)
   seek cSeek
   skip

   //Tel aantal velde
   nTota := 0
   do while dtos(SM3VEEG->datumm) == cSeek
      nTota++
      skip
   enddo
   seek cSeek
   skip

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3veeg","datumm"})
      aadd(aSend,{"sm3veeg","beskry"})
      aadd(aSend,{"sm3veeg","aantal"})
      aadd(aSend,{"sm3veeg","waar01"})
      aadd(aSend,{"sm3veeg","waar02"})
      aadd(aSend,{"sm3veeg","waar03"})
      aadd(aSend,{"sm3veeg","genesp"})
      aadd(aSend,{"sm3veeg","genef5"})
      aadd(aSend,{"sm3veeg","genef4"})
      aadd(aSend,{"sm3veeg","genef3"})
      aadd(aSend,{"sm3veeg","genef2"})
      aadd(aSend,{"sm3veeg","genef1"})
      aadd(aSend,{"sm3veeg","genef0"})
      aadd(aSend,{"sm3veeg","geneni"})
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Bepaal die drukgrootte
   nWidt := 0
   for nI = 1 to len(aRecv)
      nWidt+= aRecv[nI][4]+1
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
      fScrbood(24,"Veegetalle word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("Veegetalle soos op "+dtoc(SM3VEEG->datumm)+".")
   else
      fScrbood(24,"Stock figures being printed!  [Esc]=Stop printer.")
      cHdln := upper("Stock figures as at "+dtoc(SM3VEEG->datumm)+".")
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
         lLoop := .f.
         exit
      endif

      //Data
      cData := ""
      for nI = 1 to len( aRecv )
         do case
            case aRecv[nI][3] == "C"
               //Character
               cData+= fieldget(aRecv[nI,13]) + " "
            case aRecv[nI][3] == "N"
               //Numeric
               cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
            case aRecv[nI][3] == "D"
               //Date
               cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI][4])+" "
         endcase
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
      if prow() >= nPrnl .or. eof() .or. dtos(SM3VEEG->datumm) <> cSeek
         @prow()+1,  1 say repl( "-",  nWidt )

         //Print totals
         for nI := 1 to len(aRecv)
            if nI == 1
               if cLanType() == "A"
                  @prow()+1,1 say padr("Totale:",aRecv[nI,4])
               else
                  @prow()+1,1 say padr("Totals:",aRecv[nI,4])
               endif
            else
               if aRecv[nI,2] == "GEMMAS"
                  if aRecv[nI,12] > 0 .and. aRecv[nI,11] > 0
                     @prow(),pcol()+1 say str(aRecv[nI,12]/aRecv[nI,11],aRecv[nI][4],aRecv[nI][5])
                  else
                     @prow(),pcol()+1 say space(aRecv[nI,4])
                  endif
               else
                  if aRecv[nI,12] > 0
                     @prow(),pcol()+1 say str(aRecv[nI,12],aRecv[nI][4],aRecv[nI][5])
                  else
                     @prow(),pcol()+1 say space(aRecv[nI,4])
                  endif
               endif
            endif
         next

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof() .or. dtos(SM3VEEG->datumm) <> cSeek
            lLoop := .f.
         endif
      endif
   enddo

   fPrnOff()

   //Herstel
   seek cSeek
return NIL

/**************************************************************************/
STATIC FUNCTION fAverage(aRecv,bBrow)

   //Verklaar
   local i     := 0
   local lAver := .f.
   local cText := ""
   local nData := 0
   local oCols := NIL
   local nReko := recno()
   local cSeek := ""

   //Kyk of daar enige numeriese waardes is
   for i = 1 to len(aRecv)
      if aRecv[i][3] == "N"
         lAver := .t.
         aRecv[i,11] := 0
         aRecv[i,12] := 0
      endif
   next
   if !lAver
      return .f.
   endif

   //Bereken die gemiddeldes
   //fScrBood(23)
   //if cLanType() == "A"
   //   fScrWbood(24,"Totale word bereken")
   //else
   //   fScrWbood(24,"Totals being calculated")
   //endif

   //Kry die eerste rekord
   cSeek := dtos(SM3VEEG->datumm)
   seek cSeek
   do while dtos(SM3VEEG->datumm) == cSeek
      setcolor(cColBott())
      //if cLanType() == "A"
      //   @23,35 say fPercent(nReko/lastrec())+"% Voltooi"
      //else
      //   @23,35 say fPercent(nReko/lastrec())+"% Completed"
      //endif
      //setcolor(cColNorm())
      for i = 1 to len(aRecv)
         if aRecv[i][3] == "N"
            //Kies die regte leer
            cText := alltrim(strtran(aRecv[i,1],"->"))
            select select(cText)
            nData := fieldget(aRecv[i][13])
            if nData > 0
               aRecv[i][11]++
               aRecv[i][12]+= nData
            endif
            select SM3VEEG
         endif
      next
      select SM3VEEG
      skip
   enddo
   goto nReko

   //Kyk of daar enige gemiddeldes is
   lAver := .f.
   for i = 1 to len(aRecv)
      if aRecv[i][11] > 0
         lAver := .t.
         exit
      endif
   next
   if !lAver
      return .t.
   endif

   //Bou veranderlikes
   for i = 1 to len(aRecv)
      oCols := bBrow:getcolumn(i)
      if aRecv[i][12] > 0
         if aRecv[i,2] == "GEMMAS"
            oCols:footing := str(  aRecv[i,12]/aRecv[i,11] ,aRecv[i][4], aRecv[i][5] )
         else
            oCols:footing := str(  aRecv[i][12] ,aRecv[i][4], aRecv[i][5] )
         endif
         oCols:footsep := "Í"
      else
         oCols:footsep := "Í"
         if i == 1
            if cLanType() == "A"
               oCols:footing := left("Totale:",aRecv[i][4])
            else
               oCols:footing := left("Totals:",aRecv[i][4])
            endif
         endif
      endif
      bBrow:setcolumn(i,oCols)
   next

return .t.

