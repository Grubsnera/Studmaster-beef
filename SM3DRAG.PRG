// SM3DRAG.PRG
// Program om dragtigheidsverslag te druk
// Kopiereg (c) 1992 A van Rensburg
// 10:53 29 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION sm3drag(nTop,nLeft,nBottom,aSend,cFind)

   // Veranderlikes
   local cFile   := ""                           //Status of opened file
   local aRecv   := {}                           //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nRight  := 77                           //Regterkantste lyn
   local bBrowse := NIL                          //Browse object
   local aColumn := {}                           //Kolomme array
   local i       := 0                            //Counter
   local lMore   := .t.                          //Logical looper
   local nKey    := 0                            //Keypress
   local cToFile := cDd()+"sm3tydi.dbf"
   local nBoxc   := 0
   local dDate   := ctod("")
   local cLocate := ""
   local cLocScr := ""
   local nBoxCoor := 0
   local getlist := {}

   private cData := ""                           //Column data fields for tbrowse
   private cHead := ""                           //Heading of tbrowse

   // Skerm
   if cLanType() == "A"
      fScrOpsk(,"Opsie "+cOption())
   else
      fScrOpsk(,"Option "+cOption())
   endif

   // Parameters
   nTop    := if( nTop    == NIL, 3, nTop )
   nLeft   := if( nLeft   == NIL, 2, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3dekk","idmoer"})
      aadd(aSend,{"sm3dekk","idvaar"})
      aadd(aSend,{"sm3dekk","vaarkode"})
      aadd(aSend,{"sm3dekk","datumin"})
      aadd(aSend,{"sm3dekk","datumuit"})
      aadd(aSend,{"sm3dekk","dradag"})
      aadd(aSend,{"sm3dekk","drawee"})
      aadd(aSend,{"sm3dekk","dramaa"})
      aadd(aSend,{"sm3dekk","insem"})
      aadd(aSend,{"sm3dekk","opmerk"})
      aadd(aSend,{"sm3dekk","dragtig"})
   endif

   // Vra die datum waarop dragtigheidsondersoeke gedoen gaan word
   lMore := .t.
   do while lMore
      fSCrBood(23,"[Esc]=Menu")
      if cLanType() == "A"
         fScrBood(24,"Tik die datum waarop dragtigheidsondersoeke gedoen gaan word!")
         nBoxc := fBoxCent(11,"Datum van dragtigheidsondersoek? xxxxxxxx",3)
         @12,nBoxc say "Datum van dragtigheidsondersoek?" get dDate
      else
         fScrBood(24,"Type the date on which pregnancy diagnosis is to be done!")
         nBoxc := fBoxCent(11,"Date of pregnancy diagnosis? xxxxxxxx",3)
         @12,nBoxc say "Date of pregnancy diagnosis?" get dDate
      endif
      set cursor on
      read
      set cursor off
      if lastkey() == K_ESC
         return NIL
      endif
      if dDate == ctod("")
         if cLanType() == "A"
            fScrBood(23,"Datum waarop dragtigheidsondersoeke gedoen is, is verpligtend!")
         else
            fScrBood(23,"Date on which pregnancy diagnosis was done is compulsory!")
         endif
         fScrWait(24)
         loop
      endif
      lMore := .f.
   enddo

   // Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   // Open die stdmenu.tdb - gaan verander - use exclusive
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cFile := fTOpen(cDd(),"sm3dekk",,,,.t.,.f.)
   if left( cFile, 1 ) == "f"
      return NIL
   endif
   set order to 2

   // Skuif die databasis
   if cFind == NIL
      if cLanType() == "A"
         fScrBood(23,"Kalfseisoen onbekend!")
      else
         fScrBood(23,"Calving season unknown!")
      endif
      fScrWait(24)
      fTClose(cFile)
      return NIL
   else
      seek cFind
      if eof()
         if cLanType() == "A"
            fScrBood(23,"Geen inligting vir die kalfseisoen kon gevind word nie!")
         else
            fScrBood(23,"No information could be found for the calving season!")
         endif
         fScrWait(24)
         fTClose(cFile)
         return NIL
      endif
   endif

   // Soek diere
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kalfseisoen se dekkings word uitgesoek!")
   else
      fScrWbood(24,"Matings for calving season being sorted!")
   endif
   copy to (cToFile) while SM3DEKK->teelgroep == cFind

   // Sluit leer en open tydelike leer
   fTClose(cFile)
   cFile := fTOpen(cDd(),"sm3tydi",,,"sm3dekk",.f.,.f.)
   if left( cFile, 1 ) == "f"
      return NIL
   endif

   // Bereken aantal dae dragtig
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Aantal dae, weke en maande dragtig word bereken")
   else
      fScrWbood(24,"No. of days, weeks and months pregnant being calculated")
   endif
   do while !eof()
      if dDate - SM3DEKK->datumin > 0 .and. dDate - SM3DEKK->datumin < 700
         SM3DEKK->dradag := dDate - SM3DEKK->datumin
         SM3DEKK->drawee := round(SM3DEKK->dradag/7,1)
         SM3DEKK->dramaa := round(SM3DEKK->dradag/30.4375,1)
      endif
      skip
   enddo
   go top

   // Kry die breedte van venster
   for i = 1 to len( aRecv )

      // Lengte
      nScrLen := nScrLen + aRecv[i,4] + 3

      // Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   // Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 77, 77, nLeft+nScrLen )

   // Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "Kalfseisoen "+trim(cFind)+" dragtigheidsondersoekverslag op "+dtoc(dDate) )
   else
      fBox( nTop, nLeft, nBottom, nRight, "Calving season "+trim(cFind)+" pregnancy diagnosis report on "+dtoc(dDate) )
   endif
   setcolor( cColNorm() )

   // Bou die tBrowse
   bBrowse := TBrowseDB( nTop+1, nLeft+2, nBottom-1, nRight-2 )
   bBrowse:headsep := "Í"
   bBrowse:colsep := "³"

   // Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      bBrowse:addColumn( aColumn[i] )
   next

   // Main loop
   lMore := .t.
   do while lMore

      // Skerm
      if cLanType() == "A"
         fScrBood( 23, "            [A - Z]=Vind koei                        " )
         fScrBood( 24, "[Esc]=Menu  [Alt P]=Druk dragtigheidsondersoekverslag" )
      else
         fScrBood( 23, "            [A - Z]=Find cow   " )
         fScrBood( 24, "[Esc]=Menu  [Alt P]=Print pregnancy diagnosis report" )
      endif

      // Vries
      bBrowse:freeze := 1

      // Stabilize the display until it's stable or a key is pressed
      nKey := 0
      do while nKey == 0 .and. .not. bBrowse:stable
         bBrowse:stabilize()
         nKey := InKey()
      enddo

      if bBrowse:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrowse:refreshCurrent()
         ForceStable(bBrowse)
         // Everything's done -- just wait for a key
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKey == K_ALT_P
         //Means print mating list
         fPrint(aRecv,cFind,dDate)
         bBrowse:refreshall()

      elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122
         //Means locate a record
         cLocate := upper( chr( nKey ) ) + space(11)
         cLocScr := savescreen( 0, 0, 24, 79 )
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 11, "Vind watter koei? xxxxxxxxxxxx", 3 )
            @12, nBoxCoor say "Vind watter koei?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 11, "Find which cow? xxxxxxxxxxxx", 3 )
            @12, nBoxCoor say "Find which cow" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            go top
            locate for trim(cLocate) $ SM3DEKK->idmoer
            if eof()
               go top
            endif
            bBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(bBrowse, nKey)

      endif

   enddo

   // Herstel
   fTClose(cFile)

return NIL

//***************************************************************************/
STATIC FUNCTION fPrint(aRecv,cFind,dDate)

   // Funksie om deklyste te druk

   // Verklaar
   local nRecno  := recno()
   local nTotaal := 1
   local aSend   := {}
   local lLoop   := .t.
   local nI      := 1
   local nRekord := 1
   local cKoenr  := ""
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   // Verstekwaardes
   cFind := if(cFind==NIL,"",cFind)

   // Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   // Databasis
   go top
   nTotaal := lastrec()

   // Drukker
   // Condense
   cPcod := cPrnCond()
   nWidt := nPrnCwid()
   nTopl := nPrnLine()
   if nPrnLptp() < 8
      nPrnl := nPrnPrnl() - 1
      nPagl := nPrnLeng()
   else
      nPrnl := nPrcPrnl() - 1
      nPagl := nPrcLeng()
   endif
   nMidc := nWidt - 29

   // Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif
   //Kry die velde benodig
   if aRecv == NIL
      asize( aSend, 0 )
      aadd(aSend,{"sm3dekk","idmoer"})
      aadd(aSend,{"sm3dekk","idvaar"})
      aadd(aSend,{"sm3dekk","vaarkode"})
      aadd(aSend,{"sm3dekk","datumin"})
      aadd(aSend,{"sm3dekk","datumuit"})
      aadd(aSend,{"sm3dekk","dradag"})
      aadd(aSend,{"sm3dekk","drawee"})
      aadd(aSend,{"sm3dekk","dramaa"})
      aadd(aSend,{"sm3dekk","insem"})
      aadd(aSend,{"sm3dekk","opmerk"})
      aadd(aSend,{"sm3dekk","dragtig"})
      aRecv := fGetField( aSend )
   endif

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Dragtigheidsondersoekverslag word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("DRAGTIGHEIDSONDERSOEKE OP "+dtoc(dDate)+" VIR DIE "+trim(cFind)+" KALFSEISOEN.")
   else
      fScrbood(24,"Pregnancy diagnosis report being printed!  [Esc]=Stop printer.")
      cHdln := upper("PREGNANCY DIAGNOSIS ON "+dtoc(dDate)+" FOR THE "+trim(cFind)+" CALVING SEASON.")
   endif

   //Skakel die drukker aan
   fPrnOn()
   fPrnCod( cPcod )

   //Doen die loop
   lLoop := .t.
   do while lLoop

      //Opskrifte
      if prow() = 0
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

         @prow()+1,  1 say repl( "=",nWidt )

         // 1e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say padr( trim( aRecv[nI,7] ), aRecv[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,7] ), aRecv[nI,4] )
            endif
         next
         if cLanType() == "A"
            @prow(),pcol()+1 say " | Weke       | "
         else
            @prow(),pcol()+1 say " | Weeks      | "
         endif

         // 2e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say padr( trim( aRecv[nI,8] ), aRecv[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,8] ), aRecv[nI,4])
            endif
         next
         if cLanType() == "A"
            @prow(),pcol()+1 say " | dragtig?   | "
         else
            @prow(),pcol()+1 say " | pregnant?  | "
         endif

         // 3e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say padr( trim( aRecv[nI,9] ), aRecv[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,9] ), aRecv[nI,4])
            endif
         next
         if cLanType() == "A"
            @prow(),pcol()+1 say " | 0=Nie drag | Enige ander opmerking"
         else
            @prow(),pcol()+1 say " | 0=Not preg | Any other remark"
         endif

         // 4e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say repl( "-", aRecv[nI,4] )
            else
               @prow()  ,pcol()+1 say repl( "-", aRecv[nI,4] )
            endif
         next
         @prow(),pcol()+1 say " | ---------- | ----------------------"
      endif

      // Toets of drukker moet stop
      If fPrnStop() = K_ESC
         goto nRecno
         return NIL
      endif

      // Data
      for nI = 1 to len( aRecv )
         if nI == 1
            if cKoenr == SM3DEKK->idmoer
               @prow()+1,       1 say space(12)
            else

               @prow()+1,       1 say fieldget(aRecv[nI][13])
            endif
         else
            @prow()  ,pcol()+1 say fieldget(aRecv[nI][13])
         endif
      next
      @prow(),pcol()+1 say " |            | "
      cKoenr := SM3DEKK->idmoer

      // Volgende rekord
      skip
      if cKoenr <> SM3DEKK->idmoer .and. !eof()
         @prow()+1,       1 say repl("-",nWidt)
      endif

      // Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()

         // Print onderste lyn
         if eof()
            @prow()+1,  1 say repl( "=",nWidt )
         endif
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         fPrnCod( cPcod )
         nBlad++

         // Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   // Herstel
   goto nRecno

return NIL
