//SM3WELY.PRG
//Program om weeglyste te druk
//Kopiereg (c) 1992 A van Rensburg
//17:09 29 Dec,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

//****************************************************************************/
FUNCTION sm3wely

   //Veranderlikes
   local nTipe := 1
   local nWatt := 1
   local nGesl := 3
   local nLeer := 1
   local cData := ""
   local cTydi := ""
   local cFile := cDd()+"sm3tydi.dbf"
   local aSend := {}
   local aRecv := {}
   local cWeeg := ""
   local nMin  := 0
   local aCscr := {}
   private cTest := ""

   //Vertoon menu om te vra enkel of saamgestelde weeglys
   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption())
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
   else
      fScrOpsk(1,"Option "+cOption())
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
   endif

   nTipe := fNewMenu(nTipe,"WELYTIPE")
   nMin++

   if cLanType() == "A"
      fScrOpsk( ,"Opsie "+cOption(nTipe))
   else
      fScrOpsk( ,"Option "+cOption(nTipe))
   endif

   aCscr := fASaveScr()

   do case
      case nTipe == 1
         //Vier per lyn
      case nTipe == 2
         //Een per lyn
         //Vra watter verslag
         aSend := sm3eiev()

         if len(aSend) == 0
            cOption(-nMin)
            return NIL
         endif

      case nTipe == 3
         //Namibie Prestasietoetsskema
      case nTipe == 4
         //Weeglys na PSION handrekenaar
         // Weighing list to palmtop
      otherwise
         cOption(-nMin)
         return NIL
   endcase

   fARestScr(aCscr)

   //Vertoon menu om te vra groep ensovoorts
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
   endif
   nWatt := fNewMenu(nWatt,"WELYWATT")
   nMin++

   if cLanType() == "A"
      fScrOpsk(1,"Opsie "+cOption(nWatt))
   else
      fScrOpsk(1,"Option "+cOption(nWatt))
   endif

   aCscr := fASaveScr()

   do case
      case nWatt == 1
         //Indeksgroep
         //Kry die indeksgroep
         cTest := sm3indg(4)
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen indeksgroep is gekies nie!")
            else
               fScrWait(24,"No index group was selected!")
            endif
            cOption(-nMin)
            return NIL
         endif
      case nWatt == 2
         //Fasegroep
         //Kry die fasegroep
         cTest := sm3fasg(4)
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen fasegroep is gekies nie!")
            else
               fScrWait(24,"No phase group was selected!")
            endif
            cOption(-nMin)
            return NIL
         endif
      case nWatt == 3
         //Groep
         cTest := sm3groe()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif
            cOption(-nMin)
            return NIL
         endif
      case nWatt == 4
         //Seleksiegroep
         cTest := sm3selg()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No selection group requirements have been specified!")
            endif
            cOption(-nMin)
            return NIL
         endif
      otherwise
         cOption(-nMin)
         return NIL
   endcase

   fARestScr(aCscr)

   //Net in geval van indeksgroep
   if nWatt == 1
      //Vertoon menu om te vra watter geslag
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
      endif
      nGesl := fNewMenu(nGesl,"WELYGESL")
      nMin++

      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nGesl))
      else
         fScrOpsk(1,"Option "+cOption(nGesl))
      endif

      do case
         case nGesl == 1
            //Vroulik
         case nGesl == 2
            //Manlik
         case nGesl == 3
            //Albei
         otherwise
            cOption(-nMin)
            return NIL
      endcase
   elseif nWatt == 2
      //Fasegroep - doen niks
   else
      //Vertoon menu om te vra watter leer
      if cLanType() == "A"
         fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
      else
         fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
      endif
      nLeer := fNewMenu(nLeer,"WELYLEER")
      nMin++

      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption(nLeer))
      else
         fScrOpsk(1,"Option "+cOption(nLeer))
      endif

      do case
         case nLeer == 1
            //In kudde diere
         case nLeer == 2
            //Alle diere
         otherwise
            cOption(-nMin)
            return NIL
      endcase
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Diere word uitgesoek")
   else
      fScrWbood(24,"Animals being sorted")
   endif

   //Open dataleers
   cWeeg := fTOpen(cDd(),"sm3weeg")
   if left(cWeeg,1) == "f"
      cOption(-nMin)
      return NIL
   endif
   cData := fTOpen(cDd(),"sm3data")
   if left(cData,1) == "f"
      fTClose(cWeeg)
      cOption(-nMin)
      return NIL
   endif

   //Net in geval van indeksgroep
   if nWatt == 1
      //Kies die regte indeks
      set order to 3
      //Soek die indeksgroep
      seek cTest
      //Skep die tydelike leer
      copy to (cFile) fields idnr while SM3DATA->indekskode == cTest
      //Herstel indeks
      select SM3DATA
      set order to 1
   elseif nWatt == 2
      //Kies die regte indeks
      set order to 2
      //Soek die fasegroep
      seek cTest
      //Skep die tydelike leer
      copy to (cFile) fields idnr while SM3DATA->fasekode == cTest
      //Herstel indeks
      select SM3DATA
      set order to 1
   else
      if nLeer == 2
         //Hele leer
         //Skep die tydelike leer
         copy to (cFile) fields idnr for &cTest
      else
         //Slegs in kudde diere
         //Skep die tydelike leer
         set order to 7
         copy to (cFile) fields idnr for &cTest
         set order to 1
      endif
   endif

   //Open die tydelike leer
   cTydi := fTOpen(cDd(),"sm3tydi")
   if left(cTydi,1) == "f"
      fTClose(cData)
      fTClose(cWeeg)
      cOption(-nMin)
      return NIL
   endif

   //Kyk of daar diere bestaan
   if lastrec() == 0
      if cLanType() == "A"
         fScrBood(23,"Geen diere is gevind om te druk!")
      else
         fScrBood(23,"No animals have been found for printing!")
      endif
      fScrWait(24)
      fTClose(cTydi)
      fTClose(cData)
      fTClose(cWeeg)
      cOption(-nMin)
      return NIL
   endif

   //Stel relation
   set relation to SM3TYDI->IDNR into SM3DATA
   go top

   //Net in geval van indeksgroep
   if nWatt == 1
      //Verwyder ongewenste diere
      do while !eof()
         do while !rlock()
         enddo
         if SM3DATA->uitkrede $ cWaarisd()
         else
            delete
            skip
            loop
         endif
         if nGesl == 1 .and. SM3DATA->geslag $ "23"
            delete
            skip
            loop
         endif
         if nGesl == 2 .and. SM3DATA->geslag == "1"
            delete
            skip
            loop
         endif
         skip
      enddo
      go top
   endif

   //Skerm
   //   restscreen(0,0,24,79,cCscr)

   //Begin druk
   if nTipe == 1
      //Vier per blad
      fPrnVier()
   elseif nTipe == 2
      //Twee per blad
      fPrnEenn(aSend)
   elseif nTipe == 3
      //Namibie
      fPrnNami()
   else
      //Psion Handrekenaar
      //fPsion()
      fPalmTop()
   endif

   //Herstel
   fTClose(cTydi)
   fTClose(cData)
   fTClose(cWeeg)
   cOption(-nMin)

return NIL

/****************************************************************************/
STATIC FUNCTION fPrnVier

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local nVmas := 0
   local dVdat := ctod("")
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

   // Normal Printing
   cPcod := cPrnNorm()
   nWidt := nPrnWidt()
   nTopl := nPrnLine()
   nPrnl := nPrnPrnl()
   nPagl := nPrnLeng()
   nMidc := nWidt - 29

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Weeglys word gedruk!  [Esc]=Stop drukker.")
      cHdln := "WEEGLYS."
   else
      fScrbood(24,"Weighing list being printed!  [Esc]=Stop printer.")
      cHdln := "WEIGHING LIST."
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
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Data eerste dier
      //Soek die vorige massa van die dier
      nVmas := 0
      dVdat := ctod("")
      select SM3WEEG
      seek SM3TYDI->idnr
      do while SM3WEEG->idnr == SM3TYDI->idnr .and. !(eof())
         nVmas := SM3WEEG->massa
         dVdat := SM3WEEG->weegdatum
         skip
      enddo
      select SM3TYDI
      @prow()+1,1 say trim(SM3TYDI->idnr) + str(nVmas,4,0)
      nReko++
      skip

      //Data tweede dier
      if !eof()
         //Soek die vorige massa van die dier
         nVmas := 0
         dVdat := ctod("")
         select SM3WEEG
         seek SM3TYDI->idnr
         do while SM3WEEG->idnr == SM3TYDI->idnr .and. !eof()
            nVmas := SM3WEEG->massa
            dVdat := SM3WEEG->weegdatum
            skip
         enddo
         select SM3TYDI
         @prow()  ,20 say trim(SM3TYDI->idnr) + str(nVmas,4,0)
         nReko++
         skip
      endif

      //Data derde dier
      if !eof()
         //Soek die vorige massa van die dier
         nVmas := 0
         dVdat := ctod("")
         select SM3WEEG
         seek SM3TYDI->idnr
         do while SM3WEEG->idnr == SM3TYDI->idnr .and. !eof()
            nVmas := SM3WEEG->massa
            dVdat := SM3WEEG->weegdatum
            skip
         enddo
         select SM3TYDI
         @prow()  ,40 say trim(SM3TYDI->idnr) + str(nVmas,4,0)
         nReko++
         skip
      endif

      //Data vierde dier
      if !eof()
         //Soek die vorige massa van die dier
         nVmas := 0
         dVdat := ctod("")
         select SM3WEEG
         seek SM3TYDI->idnr
         do while SM3WEEG->idnr == SM3TYDI->idnr .and. !eof()
            nVmas := SM3WEEG->massa
            dVdat := SM3WEEG->weegdatum
            skip
         enddo
         select SM3TYDI
         @prow()  ,60 say trim(SM3TYDI->idnr) + str(nVmas,4,0)
         nReko++
         skip
      endif

      @prow()+1,  1 say repl( "-",  nWidt )

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
      // endif
      // fPrnOn()

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()
         //Print onderste lyn
         @prow()  ,  1 say repl( "=",  nWidt )
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

/****************************************************************************/
STATIC FUNCTION fPrnEenn(aSend)

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aRecv := {}
   local nVmas := 0
   local dVdat := ctod("")
   local cText := ""
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
   if cLanType() == "A"
      fScrwbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrwbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField(aSend)

   //Bepaal die drukgrootte
   nWidt := 38
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
      fScrbood(24,"Weeglys word gedruk!  [Esc]=Stop drukker.")
      cHdln := "Weeglys."
   else
      fScrbood(24,"Weighing list being printed!  [Esc]=Stop printer.")
      cHdln := "Weighing list."
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
         if cLanType() == "A"
            cData := "                             Vorige   "
         else
            cData := "                           Previous   "
         endif
         for nI = 1 to len( aRecv )
            cData+= padr( trim( aRecv[nI,7] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //2e Lyn van opskrif
         if cLanType() == "A"
            cData := "                        Vori weeg-    "
         else
            cData := "                        Prev weigh    "
         endif
         for nI = 1 to len( aRecv )
            cData+= padr( trim( aRecv[nI,8] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //3e Lyn van opskrif
         if cLanType() == "A"
            cData := "Id nommer    Massa      mass datum    "
         else
            cData := "Id number    Mass       mass date     "
         endif
         for nI = 1 to len( aRecv )
            cData+= padr( trim( aRecv[nI,9] ), aRecv[nI,4] ) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)

         //4e Lyn van opskrif
         cData := "------------ ---------- ---- -------- "
         for nI = 1 to len( aRecv )
            cData+= repl("-",aRecv[nI,4]) + " "
         next
         @prow()+1,1 say padr(cData, nWidt)
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Soek die vorige massa van die dier
      nVmas := 0
      dVdat := ctod("")
      select SM3WEEG
      seek SM3TYDI->idnr
      do while SM3WEEG->idnr == SM3TYDI->idnr
         nVmas := SM3WEEG->massa
         dVdat := SM3WEEG->weegdatum
         skip
      enddo
      select SM3TYDI

      //Data
      cData := SM3TYDI->idnr  + " " + ;
         repl(" ",10)   + " " + ;
         str(nVmas,4,0) + " " + ;
         dtoc(dVdat)    + " "
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
               cData+= str(  fieldget(aRecv[nI,13])  ,aRecv[nI][4],aRecv[nI][5]) + " "
            case aRecv[nI][3] == "D"
               //Date
               cData+= dtoc(  fieldget(aRecv[nI,13])  ) + " "
            otherwise
               //Nie een van bogenoemde
               cData+= space(aRecv[nI][4])+" "
         endcase
         select SM3TYDI
      next
      @prow()+1,1 say padr(cData,nWidt)
      @prow()+1,  1 say repl("-",nWidt)

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
         @prow()  ,  1 say repl( "=",  nWidt )
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

/****************************************************************************/
STATIC FUNCTION fPrnNami

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nI    := 1
   local nReko := 1
   local cData := ""
   local aSend := {}
   local nVmas := 0
   local dVdat := ctod("")
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

   // Normal Printing
   cPcod := cPrnNorm()
   nWidt := nPrnWidt()
   nTopl := nPrnLine()
   nPrnl := nPrnPrnl()
   nPagl := nPrnLeng()
   nMidc := nWidt - 29

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Weeglys word gedruk!  [Esc]=Stop drukker.")
      cHdln := "Weeglys."
   else
      fScrbood(24,"Weighing list being printed!  [Esc]=Stop printer.")
      cHdln := "Weighing list."
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
            @prow()+1,  1 say repl( "=",  nWidt )
            @prow()+1,  1 say "             | G |        |         Kalf            |     Koei(massa)     |"
            @prow()+1,  1 say "             | e |        | ---------------ddmmjj-- | ------------------- |"
            @prow()+1,  1 say "Id nommer    | s | Groep  | Massa | Byv | Weegdatum | Geb   | Speen | Byv |"
            @prow()+1,  1 say "------------ | - | ------ | ----- | --- | --------- | ----- | ----- | --- |"
            //                 1            14161820     2729    3537  4143        5355    6163    6971  75
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
            @prow()+1,  1 say repl( "=",  nWidt )
            @prow()+1,  1 say "             | S |        |         Calf            |      Cow(mass)      |"
            @prow()+1,  1 say "             | e |        | ---------------ddmmyy-- | ------------------- |"
            @prow()+1,  1 say "Id number    | x | Group  | Mass  | Sup | WeighDate | Birth | Wean  | Sup |"
            @prow()+1,  1 say "------------ | - | ------ | ----- | --- | --------- | ----- | ----- | --- |"
            //                 1            14161820     2729    3537  4143        5355    6163    6971  75
         endif
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lLoop := .f.
         exit
      endif

      //Data
      @prow()+1, 1 say SM3TYDI->idnr
      @prow()  ,14 say "|"
      @prow()  ,16 say SM3DATA->geslag
      @prow()  ,18 say "|"
      @prow()  ,20 say SM3DATA->indekskode
      @prow()  ,27 say "|"
      @prow()  ,35 say "|"
      @prow()  ,41 say "|"
      @prow()  ,53 say "|"
      @prow()  ,61 say "|"
      @prow()  ,69 say "|"
      @prow()  ,75 say "|"
      nReko++
      skip

      @prow()+1,  1 say repl( "-",  nWidt )

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
      // endif
      // fPrnOn()

      //Toets vir einde van bladsy
      if prow() >= nPrnl .or. eof()
         //Print onderste lyn
         @prow()  ,  1 say repl( "=",  nWidt )
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

/****************************************************************************/
STATIC FUNCTION fPsion

   //Verklaar
   local nTota   := 0
   local nReko   := 0
   local nHdel   := 0
   local nLen    := 0
   local cStr    := ""
   local aCscr   := {}
   local cCl     := "CL "+ALLTRIM(STR(nScBaud(),4,0))+","+ALLTRIM(STR(nScPort(),1,0))
   local lCl     := FALSE
   local cFile   := "WEEGLYS.ODB"

   BEGIN SEQUENCE
      //Skerm
      fScrBood(MAXROW()-1)
      fScrBood(MAXROW())

      //Check if PSION programs is available
      if ! FILE("CL.EXE")
         IF cLanType() == "A"
            fScrWait(MAXROW()-1,"Die PSION Program 'CL.EXE' is nie beskikbaar nie",,,,TRUE)
         else
            fScrWait(MAXROW()-1,"The PSION Program 'CL.EXE' is not available",,,,TRUE)
         endif

         break
      endif

      if ! FILE("S_FTRAN.EXE")
         IF cLanType() == "A"
            fScrWait(MAXROW()-1,"Die PSION program 'S_FTRAN.EXE' is nie beskikbaar nie",,,,TRUE)
         else
            fScrWait(MAXROW()-1,"The PSION Program 'S_FTRAN.EXE' is not available",,,,TRUE)
         endif

         break
      endif

      //Skuif die databasis
      DBSELECTAREA("SM3TYDI")
      DBGOTOP()
      nTota := lastrec()

      //Remove old weigh list file
      if file(cFile)
         if ferase(cFile) < 0
            fScrBood(MAXROW()-1)
            if cLanType() == "A"
               fScrWait(MAXROW(),"Kan nie die PSION ler verwyder nie : "+ALLTRIM(STR(FERROR(),5,0)))
            else
               fScrWait(MAXROW(),"Unable to Erase PSION File : "+ALLTRIM(STR(FERROR(),5,0)))
            endif

            BREAK
         endif
      endif

      nHdel := FCREATE(cFile)

      if nHdel < 0
         fScrBood(MAXROW()-1)
         if cLanType() == "A"
            fScrWait(MAXROW(),"Kan nie die PSION ler skep nie : "+ALLTRIM(STR(FERROR(),5,0)))
         else
            fScrWait(MAXROW(),"Unable to Create PSION File : "+ALLTRIM(STR(FERROR(),5,0)))
         endif

         BREAK
      endif

      if cLanType() == "A"
         fScrbood(MAXROW(),"PSION weeglys word voorberei.")
      else
         fScrbood(MAXROW(),"PSION weighing list being prepared.")
      endif

      //Doen die loop
      DO WHILE ! EOF()

         if nTota > 0
            if cLanType() == "A"
               fScrBood(MAXROW()-1,fPercent(++nReko/nTota)+"% Voltooi")
            else
               fScrBood(MAXROW()-1,fPercent(++nReko/nTota)+"% Completed")
            endif
         endif

         IF ! SM3DATA->(DBSEEK(SM3TYDI->idnr))
            DBSKIP()
            LOOP
         ENDIF

         // The actual write
         cStr := ALLTRIM(SM3TYDI->idnr)+","
         cStr += ALLTRIM(SM3DATA->michip)+",,0"
         cStr += CHR(13) + CHR(10)
         nLen := FWRITE(nHdel,cStr)

         IF nLen != LEN(cStr)
            fScrWBood(MAXROW(),"File Write Error : "+ALLTRIM(STR(FERROR(),5,0)))
            FCLOSE(nHdel)
            FERASE(cFile)
            EXIT
         ENDIF

         // Next
         DBSKIP()
      enddo

      // Close the file
      FCLOSE(nHdel)

      // Test if file was created
      if ! file(cFile)
         if cLanType() == "A"
            fScrWBood(maxrow()-1,"PSION weeglysler is nie geskep nie!")
         else
            fScrWBood(maxrow()-1,"PSION weigh list file was not created!")
         endif
         break
      else
         fScrBood(MAXROW())
         if cLanType() == "A"
            fScrOpsk( ,"Opsie "+cOption())
            @ 05,12 say "ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
            @ 06,12 say "บ                       WAARSKUWING !!!                    บ"
            @ 07,12 say "บ                                                          บ"
            @ 08,12 say "บ Die PSION Comms Link Program gaan nou geaktiveer word... บ"
            @ 09,12 say "บ                                                          บ"
            @ 10,12 say "บ  Koppel die PSION, en sodra die Comms Link Program loop, บ"
            @ 11,12 say "บ    selekteer die 'Comms' & 'Receive' funksies op die     บ"
            @ 12,12 say "บ          PSION sodat die weeglys oorgedra kan word.      บ"
            @ 13,12 say "บ                                                          บ"
            @ 14,12 say "บ  Wanneer die oordrag voltooi is... Stop die Comms Link   บ"
            @ 15,12 say "บ   program sodat StoetMeester weer geaktiveer kan word.   บ"
            @ 16,12 say "บ   Gebruik 'Q' en 'Y' om die Comms Link program te stop.  บ"
            @ 17,12 say "บ                                                          บ"
            @ 18,12 say "ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
            fScrWait(maxrow()-1,"Koppel die PSION...",,,,TRUE)
         else
            fScrOpsk( ,"Option "+cOption())
            @ 05,12 say "ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
            @ 06,12 say "บ                         WARNING !!!                      บ"
            @ 07,12 say "บ                                                          บ"
            @ 08,12 say "บ  The PSION Comms Link Program is about to be started...  บ"
            @ 09,12 say "บ                                                          บ"
            @ 10,12 say "บ Connect the PSION..., and once the Comms Link Program is บ"
            @ 11,12 say "บ   running, select the 'Comms' & 'Receive' functions on   บ"
            @ 12,12 say "บ     the PSION to transfer the Weigh list to the Psion.   บ"
            @ 13,12 say "บ                                                          บ"
            @ 14,12 say "บ  Once the transfer is completed... Quit the Comms Link   บ"
            @ 15,12 say "บ program to return to StudMaster. Use 'Q' and 'Y' to quit บ"
            @ 16,12 say "บ                 the Comms Link program.                  บ"
            @ 17,12 say "บ                                                          บ"
            @ 18,12 say "ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
            fScrWait(maxrow()-1,"Connect the PSION...",,,,TRUE)
         endif

         aCscr := fASaveScr()
         CLEAR SCREEN
         @ 0,0 SAY ""
         lCl  = SWPRUNCMD(cCl,0,"","")
         fARestScr(aCscr)

         if ! lCl
            if cLanType() == "A"
               fScrOpsk( ,"Opsie "+cOption())
               fScrWait(MAXROW()-1,"Kon nie die Comms Link Program aktiveer nie...")
            else
               fScrOpsk( ,"Option "+cOption())
               fScrWait(MAXROW()-1,"Unable to Initiate the Comms. Link Program...")
            endif

            break
         endif
      endif
   END

   //Herstel
   FCLOSE(nHdel)
   DBGOTOP()

return NIL

/******************************************************************************/
STATIC FUNCTION fPalmtop

   // Program to create a file

   // Declare
   local lRetu := .t.
   local aCscr := fASaveScr()
   local cPath := ""
   local cFile := ""
   local cKudd := ""
   local cJaar := ""
   local cVolg := ""
   local nBoxc := 0
   local i     := 0
   local cIcar := ""
   local getlist := {}
   local lDele := .f.
   begin sequence

      // Get the breed icar number
      cIcar := fRasNaam(substr(cTotNaam(),149,3),"ISOCOD")

      // Screen
      if cLanType() == "A"
         fScrOpsk( ,"Funksie "+cOption())
      else
         fScrOpsk( ,"Function "+cOption())
      endif

      // Ask the location of the palmtop file
      cPath := padr(cPalmDir()+"\W"+cIcar+alltrim(substr(cTotNaam(),125,4))+".STP",50)

      do while .t.

         if cLanType() = "A"
            fScrOpsk( ,"Funksie "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"SKRYF PALMTOP MASSAS")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Hulp")
            fScrBood(maxrow(),"Tik volledige lernaam bv. '"+cPath+"lernaam.ubr'")
         else
            fScrOpsk( ,"Function "+cOption())
            nBoxc := fBoxCent(11,space(50),3,"EXPORT PALMTOP WEIGHTS")
            fScrBood(maxrow()-1,"[Esc]=Menu  [F1]=Help")
            fScrBood(maxrow(),"Type full file name e.g. '"+cPath+"filename.ext'")
         endif

         @ 12,nboxc GET cPath
         set(_SET_CURSOR,1)
         read
         set(_SET_CURSOR,0)

         // Escaped
         if lastkey() == K_ESC
            lRetu := .f.
            break
         endif

         exit

      enddo

      // Get the file name
      //cPath := cPalmDir()+"\Weiglist.stp"
      cPath := alltrim(cPath)

      // Ask whether file must be deleted first
      if file(cPath)
         if cLanType() == "A"
            if fJaNee(maxrow(),"Moet bestaande elektroniese massas eers geskrap word?",cColBott(),TRUE,TRUE)
               ferase(cPath)
            endif
         else
            if fJaNee(maxrow(),"Should existing electronic weights file first be deleted?",cColBott(),TRUE,TRUE)
               ferase(cPath)
            endif
         endif
      endif

      // Screen
      if cLanType() == "A"
         fScrWbood(maxrow(),"Ler word voorberei")
      else
         fScrWbood(maxrow(),"File being prepared")
      endif

      // Create the file
      //cFile := cPath
      set alternate to (cPath) additive
      set alternate on
      set console off

      // Write the data
      select SM3WEEG
      set order to 2
      go top
      select SM3TYDI
      go top
      do while !eof()

         // The actual write
         ?? fid(SM3DATA->idnr,.t.)+","
         ?? alltrim(SM3DATA->idnr)+","
         select SM3WEEG
         seek SM3DATA->idnr
         ?? alltrim(str(SM3WEEG->massa))
         ?

         // Screen
         set alternate off
         set cons on
         if cLanType() == "A"
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Voltooi")
         else
            fScrBood(maxrow()-1,fPercent(cmkeyno(),cmkeycount())+"% Completed")
         endif
         set cons off
         set alternate on

         // Next
         select SM3TYDI
         skip

      enddo

      // Close the file
      set console on
      set alternate off
      set alternate to

      // Test if file was created
      if !file(cPath)
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Ler is nie geskep nie!")
         else
            fScrBood(maxrow()-1,"File was not created!")
         endif
      else
         if cLanType() == "A"
            fScrBood(maxrow()-1,"Ler is suksesvol geskep!")
         else
            fScrBood(maxrow()-1,"File was created succesfully!")
         endif
      endif
      fScrWait(maxrow())

   end

   // Reset
   fARestScr(aCscr)
   select SM3TYDI
   go top

return lRetu
