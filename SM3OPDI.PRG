//SM3OPDI.PRG
//Program om opsommende deklys te vertoon
//Kopiereg (c) 1992 A van Rensburg
//22:07 14 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//****************************************************************************/
FUNCTION sm3opdi( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cOpde := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cCoun := ""
   local cRetu := space(6)

   private cData := ""
   private cHead := ""

   //Skerm
   if cLanType() == "A"
      fScrOpsk(  , "Opsie "+cOption())
   else
      fScrOpsk(  , "Option "+cOption())
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3deko","teelgroep"})
      aadd(aSend,{"sm3deko","idvaar"})
      aadd(aSend,{"sm3deko","aankoe"})
      aadd(aSend,{"sm3deko","aandra"})
      aadd(aSend,{"sm3deko","perdra"})
      aadd(aSend,{"sm3deko","aangeb"})
      aadd(aSend,{"sm3deko","pergeb"})
      aadd(aSend,{"sm3deko","aanspe"})
      aadd(aSend,{"sm3deko","perspe"})
      aadd(aSend,{"sm3deko","perspg"})
      aadd(aSend,{"sm3deko","aannat"})
      aadd(aSend,{"sm3deko","aankii"})
      aadd(aSend,{"sm3deko","aanino"})
      aadd(aSend,{"sm3deko","pernat"})
      aadd(aSend,{"sm3deko","perkii"})
      aadd(aSend,{"sm3deko","perino"})
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
   cOpde := fTOpen(cDd(),"sm3deko")
   if left(cOpde,1) == "f"
      return cRetu
   endif

   //Skuif die databasis
   if cFind == NIL
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
      fBox( nTop, nLeft, nBott, nRigh, "OPSOMMENDE DEKVERSLAG VIR DIE "+TRIM(sm3deko->TEELGROEP)+" KALFSEISOEN" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "SUMMARY MATING LIST FOR THE "+TRIM(sm3deko->TEELGROEP)+" CALVING SEASON" )
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
         fScrBood( 23 ,"[ Esc ]=Menu " )
         fScrBood( 24, "[Alt P]=Druk " )
      else
         fScrBood( 23 ,"[ Esc ]=Menu " )
         fScrBood( 24, "[Alt P]=Print" )
      endif

      //Freeze
      bBrow:freeze := 2

      // Stabilize the display until it's stable or a key is pressed
      nKeyp := 0
      do while nKeyp == 0 .and. .not. bBrow:stable
         bBrow:stabilize()
         nKeyp := InKey()
      enddo

      // Display the record number
      cCoun := PADL(LTRIM(STR(CMXKEYNO()))+"/"+LTRIM(STR(CMXKEYCOUNT())),15,CHR(205))
      @nBott,nRigh-(LEN(cCoun)+1) SAY cCoun

      if bBrow:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         bBrow:refreshCurrent()
         ForceStable(bBrow)
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         //Bring kalfseisoen op datum
         fUpdate()
         lMore := .f.

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
   fTClose(cOpde)
   fTClose(cCdbf)
return cRetu

/*************************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
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
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3deko","teelgroep"})
      aadd(aSend,{"sm3deko","idvaar"})
      aadd(aSend,{"sm3deko","aankoe"})
      aadd(aSend,{"sm3deko","aandra"})
      aadd(aSend,{"sm3deko","perdra"})
      aadd(aSend,{"sm3deko","aangeb"})
      aadd(aSend,{"sm3deko","pergeb"})
      aadd(aSend,{"sm3deko","aanspe"})
      aadd(aSend,{"sm3deko","perspe"})
      aadd(aSend,{"sm3deko","perspg"})
      aadd(aSend,{"sm3deko","aannat"})
      aadd(aSend,{"sm3deko","aankii"})
      aadd(aSend,{"sm3deko","aanino"})
      aadd(aSend,{"sm3deko","pernat"})
      aadd(aSend,{"sm3deko","perkii"})
      aadd(aSend,{"sm3deko","perino"})
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

   //Skerm
   if cLanType() == "A"
      fScrbood(24,alltrim(aRecv[1][6])+" word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("OPSOMMENDE DEKVERSLAG VAN DIE "+TRIM(sm3deko->TEELGROEP)+" KALFSEISOEN.")
   else
      fScrbood(24,alltrim(aRecv[1][6])+" being printed!  [Esc]=Stop printer.")
      cHdln := upper("SUMMARY MATING REPORT FOR THE "+TRIM(sm3deko->TEELGROEP)+" CALVING SEASON.")
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
      if prow() >= nPrnl .or. eof()
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

return NIL

//****************************************************************************/
STATIC FUNCTION fUpdate()

   //Funksie om kalfseisoenleer op datum te bring

   //Verklaar
   local cCdbf := fTOpen()
   local cFile := ""
   local cData := ""

   //Open leer
   cFile := fTOpen(cDd(),"sm3teeg")
   if left(cFile,1) == "f"
      return NIL
   endif

   //Bestaande leer
   select SM3DEKO
   go top
   cData := SM3DEKO->teelgroep

   //Teelgroepleer
   select SM3TEEG
   seek cData

   if !eof()
      do while !rlock()
      enddo
      //Bewaar die syfers
      SM3TEEG->aandek := SM3DEKO->aandek
      SM3TEEG->aankoe := SM3DEKO->aankoe
      SM3TEEG->aandra := SM3DEKO->aandra
      SM3TEEG->aangeb := SM3DEKO->aangeb
      SM3TEEG->aannat := SM3DEKO->aannat
      SM3TEEG->aankii := SM3DEKO->aankii
      SM3TEEG->aanino := SM3DEKO->aanino
      SM3TEEG->aanspe := SM3DEKO->aanspe
      SM3TEEG->aanwaa := SM3DEKO->aanwaa
      SM3TEEG->perdra := SM3DEKO->perdra
      SM3TEEG->pergeb := SM3DEKO->pergeb
      SM3TEEG->pernat := SM3DEKO->pernat
      SM3TEEG->perkii := SM3DEKO->perkii
      SM3TEEG->perino := SM3DEKO->perino
      SM3TEEG->perspe := SM3DEKO->perspe
      SM3TEEG->perspg := SM3DEKO->perspg
   endif


   //Herstel
   fTClose(cFile)
   fTClose(cCdbf)
return NIL

