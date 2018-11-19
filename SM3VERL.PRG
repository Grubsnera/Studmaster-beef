//SM3VERL.PRG
//Program om adreslys verslae te druk
//Kopiereg (c) 1992 A van Rensburg
//09:36 11 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION sm3verl(aSend,cHdln)

   //Verklaar
   local cLede   := NIL
   local cTemp   := NIL
   local nTotaal := 0
   local lLoop   := .t.
   local nI      := 1
   local nRekord := 1
   local cText   := ""
   local aRecv   := {}
   local cData   := ""
   local cPcod   := ""
   local nMidc   := 0
   local nWidt   := 0
   local nTopl   := 0
   local nPrnl   := 0
   local nPagl   := 0
   local nBlad   := 1

   //Waardes
   cHdln := if(cHdln==NIL,"Adreslys.",cHdln)

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   // Condense Printing
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
   nMidc := nWidt - 29

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif

   //Kry die velde wat gedruk moet word
   aRecv := fGetField(aSend)

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Datalˆers word geopen")
   else
      fScrBood(24,"Data files being opened")
   endif
   cLede := fTOpen( cDd(), "sm3klie", , "dbf", "sm3klie", .t., .f. )
   if left( cLede, 1 ) == "f"
      return NIL
   endif
   cTemp := fTOpen(cDd(),"sm3temp",,"dbf","sm3temp",.f.,.f.)
   if left( cTemp, 1 ) == "f"
      fTClose( cLede )
      return NIL
   endif
   nTotaal := lastrec()

   //Waarsku indien geen inligting om te druk
   if nTotaal <= 0
      if cLanType() == "A"
         fScrBood(23,"Geen inligting is gevind om te druk nie!")
      else
         fScrBood(23,"No information was found for printing!")
      endif
      fScrWait(24)
      dbCloseAll()
      return NIL
   endif

   //Set relation
   set relation to SM3TEMP->KODE into SM3KLIE
   go top

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Adresse word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Addresses being printed!  [Esc]=Stop printer.")
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
         @prow()+1,  1 say repl( "=",nWidt )

         //1e Lyn van opskrif
         cText := ""
         for nI = 1 to len( aRecv )
            cText := cText + trim(aRecv[nI,7]) + " "
         next
         @prow()+1,  1 say left(cText,nWidt)

         //2e Lyn van opskrif
         cText := ""
         for nI = 1 to len( aRecv )
            cText := cText + trim(aRecv[nI,8]) + " "
         next
         @prow()+1,  1 say left(cText,nWidt)

         //3e Lyn van opskrif
         cText := ""
         for nI = 1 to len( aRecv )
            cText := cText + trim(aRecv[nI,9]) + " "
         next
         @prow()+1,  1 say left(cText,nWidt)
         @prow()+1,  1 say repl("-",nWidt)
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         dbCloseAll()
         return NIL
      endif

      //Data
      cText := ""
      for nI = 1 to len( aRecv )
         cData := aRecv[nI,1] + aRecv[nI,2]
         do case
            case aRecv[nI][3] == "C"
               cText := cText + alltrim(&cData) + ", "
            case aRecv[nI][3] == "D"
               cText := cText + alltrim(dtoc(&cData)) + ", "
            case aRecv[nI][3] == "N"
               cText := cText + alltrim(str(&cData,aRecv[nI][4],aRecv[nI][5])) + ", "
         endcase
      next
      @prow()+1,  1 say left(cText,nWidt)

      //Skerm
      // fPrnOff()
      // if nTotaal > 0
      //    setcolor( cColBott() )
      //    if cLanType() == "A"
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Voltooi "
      //    else
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Completed "
      //    endif
      //    setcolor( cColNorm() )
      //    nRekord++
      // endif
      // fPrnOn()

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()
         //Print onderste lyn
         @prow()+1,  1 say repl( "=",nWidt )
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

   //Sluit leers
   dbCloseAll()

   //Herstel
return NIL

