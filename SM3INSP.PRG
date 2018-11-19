//SM3INSP.PRG
//Program om inspeksielys te druk
//Kopiereg (c) 1993 A van Rensburg
//13:59 27 Jan,1993

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/****************************************************************************/
FUNCTION sm3insp( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local nWatt := 1
   local cInsp := ""
   local cHoof := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(12)
   local cTfil := cDd()+"sm3insp.txt"
   local nReko := 0
   local lIdnr := .f.
   local nCopy := 0

   private cTest := ""
   private cData := ""
   private cHead := ""
   private cRasn := ""
   private cOpsk := ""

   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption())
   else
      fScrOpsk( 1, "Option "+cOption())
   endif

   //Kry die rasnaam
   cOpsk := fRasNaam(substr(cTotNaam(),149,3),"HEADIL")
   if empty(cOpsk)
      cRasn := fRasNaam(substr(cTotNaam(),149,3))
      if cLanType() == "A"
         cOpsk := "Die "+cRasn+" Beestelersgenootskap van S.A."
      else
         cOpsk := "The "+cRasn+" Cattle Breeders Society of S.A."
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,21, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3insp","idnr"      })
      aadd(aSend,{"sm3data","gekeur"    })
      aadd(aSend,{"sm3data","redeui"    })
      aadd(aSend,{"sm3data","uitkrede"  })
      aadd(aSend,{"sm3data","geslag"    })
      aadd(aSend,{"sm3data","gebdatum"  })
      aadd(aSend,{"sm3data","generasie" })
      aadd(aSend,{"sm3data","ind205"    })
      aadd(aSend,{"sm3data","ind365"    })
      aadd(aSend,{"sm3data","ind540"    })
      aadd(aSend,{"sm3data","gdtind"    })
      aadd(aSend,{"sm3data","gdoind"    })
      aadd(aSend,{"sm3data","kleiberi"  })
      aadd(aSend,{"sm3data","voeromseti"})
      aadd(aSend,{"sm3data","gekskr"    })
      aadd(aSend,{"sm3data","idvaar"    })
      aadd(aSend,{"sm3data","idmoer"    })
   endif

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Vra een of groep diere
   if cLanType() == "A"
      fScrBood( 23, "Kies met " + D_DNARR + D_UPARR + " toetse en druk " + D_ENTER + ".  [Esc]=Menu" )
   else
      fScrBood( 23, "Choose with " + D_DNARR + D_UPARR + " tests and press " + D_ENTER + ".  [Esc]=Menu" )
   endif
   nWatt := fNewMenu(nWatt,"SM3INSP")
   fScrBood(23)
   if cLanType() == "A"
      fScrOpsk( 1, "Opsie "+cOption(nWatt))
   else
      fScrOpsk( 1, "Option "+cOption(nWatt))
   endif

   do case
      case nWatt == 1
         //Een dier
         lIdnr := .t.
      case nWatt == 2
         //Indeksgroep
         cTest := sm3indg(4)
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen indeksgroep is gekies nie!")
            else
               fScrWait(24,"No index group was selected!")
            endif
            cOption(-1)
            return NIL
         endif
      case nWatt == 3
         //Fasegroep
         cTest := sm3fasg(4)
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen fasegroep is gekies nie!")
            else
               fScrWait(24,"No phase group was selected!")
            endif
            cOption(-1)
            return NIL
         endif
      case nWatt == 4
         //Groep
         cTest := sm3groe()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen groep seleksie-vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No group selection requirements have been specified!")
            endif
            fTClose(cCdbf)
            restscreen(0,0,24,79,cCscr)
            cOption(-1)
            return cRetu
         endif
      case nWatt == 5
         //Seleksiegroep
         cTest := sm3selg()
         if len(trim(cTest)) == 0
            if cLanType() == "A"
               fScrWait(24,"Geen seleksiegroep vereistes is gespesifiseer nie!")
            else
               fScrWait(24,"No selection group requirements have been specified!")
            endif
            fTClose(cCdbf)
            restscreen(0,0,24,79,cCscr)
            cOption(-1)
            return cRetu
         endif
      case nWatt == 6
         //Vorige groep
         cTest := ""
      otherwise
         fTClose(cCdbf)
         restscreen(0,0,24,79,cCscr)
         cOption(-1)
         return cRetu
   endcase

   //Open datalˆers
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆers word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cInsp := fTOpen(cDd(),"sm3insp",,,,.f.)
   if left(cInsp,1) == "f"
      fTClose(cCdbf)
      restscreen(0,0,24,79,cCscr)
      cOption(-1)
      return cRetu
   endif
   if nWatt == 6
   else
      zap
   endif
   cHoof := fTOpen(cDd(),"sm3data")
   if left(cHoof,1) == "f"
      fTClose(cInsp)
      fTClose(cCdbf)
      restscreen(0,0,24,79,cCscr)
      cOption(-1)
      return cRetu
   endif

   //Soek diere
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Diere word uitgesoek")
   else
      fScrWbood(24,"Animals being selected")
   endif
   do case
      case nWatt == 2
         //Indeksgroep
         select SM3DATA
         set order to 3
         seek cTest
         do while SM3DATA->indekskode == cTest
            if SM3DATA->uitkrede $ cWaarisd()
               select SM3INSP
               append blank
               SM3INSP->idnr := SM3DATA->idnr
            endif
            select SM3DATA
            skip
         enddo
         set order to 1
      case nWatt == 3
         //Fasegroep
         select SM3DATA
         set order to 2
         seek cTest
         do while SM3DATA->fasekode == cTest
            if SM3DATA->uitkrede $ cWaarisd()
               select SM3INSP
               append blank
               SM3INSP->idnr := SM3DATA->idnr
            endif
            select SM3DATA
            skip
         enddo
         set order to 1
      case nWatt == 4 .or. nWatt == 5
         //Groep & seleksiegroep
         set order to 7
         go top
         do while !eof()
            if &cTest.
               select SM3INSP
               append blank
               SM3INSP->idnr := SM3DATA->idnr
            endif
            select SM3DATA
            skip
         enddo
         set order to 1
   endcase
   select SM3INSP
   set relation to SM3INSP->IDNR into SM3DATA
   go top

   //Skerm
   if cLanType() == "A"
      fScrOpsk(  , "Opsie "+cOption())
   else
      fScrOpsk(  , "Option "+cOption())
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
      fBox( nTop, nLeft, nBott, nRigh, "INSPEKSIELYS" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "INSPECTION LIST" )
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
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [A - Z]=Vind      [Alt R]=Resultate")
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt E]=Verander  [Alt P]=Druk     ")
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [A - Z]=Find  [Alt R]=Results" )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt E]=Edit  [Alt P]=Print  " )
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
         //Indien dier gevra moet word
         if lIdnr
            lIdnr := .f.
            keyboard chr(K_INS)
         endif
         // Everything's done -- just wait for a key
         nKeyp := InKey(0)
      endif

      if nKeyp == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKeyp == K_ENTER
         //Enter means return kode
         cRetu := fieldget(1)
         lMore := .f.

      elseif nKeyp == K_INS
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fACinsp()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fACinsp()
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_R
         //Alt R means save inspection
         fResult()
         bBrow:refreshall()

      elseif nKeyp == K_DEL
         //Delete means delete a record
         if fDelete(aRecv)
            bBrow:refreshall()
         endif

      elseif chr(nKeyp) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
         //Means locate a record
         if fLocate(aRecv,nKeyp)
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_P
         //Alt P means print
         nCopy := 1                              // fCopies(3) 07-05-28 12:16
         for i := 1 to nCopy
            if substr(cTotNaam(),149,3) == "219" //Drakensberger
               if !fPrint219()
                  exit
               endif
            else
               if !fPrint()
                  exit
               endif
            endif
         next
         bBrow:refreshall()

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cInsp)
   fTClose(cCdbf)
   cOption(-1)

return cRetu

/****************************************************************************/
STATIC FUNCTION fACinsp(aRecv)

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxc    := 0
   local aSend    := {}
   local lLoop    := .t.
   local lReturn  := .f.
   local i        := 0
   local nLoop    := 0
   local nRekord  := 0
   local aDbfs    := {}
   local cSearch  := ""
   local nLine    := 0

   private aData
   private cData

   //Kry die velde benodig
   if aRecv == NIL
      aadd(aSend,{"sm3insp","idnr"    })
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE INSPEKSIEDIER")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW INSPECTION ANIMAL")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER INSPEKSIEDIER")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT INSPECTION ANIMAL")
      endif
   endif

   //Vul met data en vertoon
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i][13] )
   next

   nLoop := 1
   do while nLoop > 0

      do case

         case nLoop == 1
            //Vra die velde
            //Skerm

            //Vra die idnr
            select SM3DATA
            aRecv[1][14] := sm3idnr(aRecv[1][14],nLine+1,nBoxc,,,,,)
            do case
               case left(aRecv[1][14],9) == "CANCELLED"
                  select SM3INSP
                  set relation to SM3INSP->IDNR into SM3DATA
                  lReturn := .t.
                  go top
                  nLoop := 0
                  loop
               case left(aRecv[1][14],3) == "NOT"
                  select SM3INSP
                  set relation to SM3INSP->IDNR into SM3DATA
                  lReturn := .t.
                  go top
                  nLoop := 0
                  loop
               otherwise
                  select SM3INSP
                  set relation to SM3INSP->IDNR into SM3DATA
                  //Kyk of data bestaan of nie
                  seek aRecv[1][14]
                  if eof()
                     //Bestaan nie - gaan voort
                     if nRekord > 0
                        goto nRekord
                     endif
                  else
                     //Bestaan
                     if nRekord > 0 .and. nRekord == recno()
                        //Dieselfde rekord - gaan voort
                     else
                        //Bestaan reeds - vertoon bestaande
                        if cLanType() == "A"
                           fScrBood(23,"Dier bestaan reeds in inspeksielys!")
                        else
                           fScrBood(23,"Animal already entered in inspection list!")
                        endif
                        fScrWait(24)
                        if nRekord > 0
                           goto nRekord
                        else
                           go bottom
                           skip
                        endif
                        aRecv[1][14] := SM3INSP->idnr
                        loop
                     endif
                  endif
                  nLoop++
            endcase

         otherwise
            //Bewaar rekord
            //Gaan na rekord
            if nRekord > 0
               goto nRekord
            else
               dbAppend()
            endif
            //Lock
            do while !rlock()
            enddo
            //Bewaar
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i][13], aRecv[i][14] )
            next
            commit
            if nRekord == 0
               nRekord := recno()
               //Maak rekord skoon
               go bottom
               skip
               for i = 1 to len( aRecv )
                  aRecv[i][14] := fieldget( aRecv[i][13] )
               next
               goto nRekord
               nRekord := 0
               nLoop := 1
            else
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen(0,0,24,79,cCurSke)
return lReturn

/****************************************************************************/
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde "+alltrim(aRecv[1][6])+" geskrap word?"
   else
      cBood := "Should above-mentioned "+alltrim(aRecv[1][6])+" be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,.f. )
      do while !rlock()
      enddo
      delete
      skip
      if eof()
         go top
      endif
      lReturn := .t.
   endif

return lReturn

/****************************************************************************/
STATIC FUNCTION fLocate(aRecv,nKeyp)

   //Funksie om vinnig 'n rekord op te soek

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local lRetu := .f.
   local cData := ""
   local nBoxc := 0
   local getlist := {}

   //Waardes
   if aRecv == NIL
      return lRetu
   endif
   cData := upper(chr(nKeyp)) + space(aRecv[1][4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[2][6] get cData pict aRecv[1][10]
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC .or. cData == space(aRecv[1][4])
      restscreen(0,0,24,79,cCscr)
      return lRetu
   endif

   //Soek
   set softseek on
   seek cData
   set softseek off
   if eof()
      go top
   endif
   lRetu := .t.

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

/****************************************************************************/
STATIC FUNCTION fPrint()

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nReko := 0
   local cData := ""
   local aSend := {}
   local aRecv := {}
   local nTotl := 0
   local dDat1 := ctod("")
   local dDat2 := ctod("")
   local nData := 0
   local nCrec := 0
   local cVaar := ""
   local lRetu := .t.
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      lRetu := .f.
      return lRetu
   endif

   // Force Condense Printing
   nWidt := nPrnCwid()
   nTopl := nPrnLine()
   if nPrnLptp() < 8
      cPcod := cPrnCond()
      nPrnl := nPrnPrnl()
      nPagl := nPrnLeng()
   else
      cPcod := cPrn8lpi()
      nPrnl := nPrcPrnl()
      nPagl := nPrcLeng()
   endif

   nMidc := nWidt - 29

   //Skerm
   fScrBood(23)

   //Skuif die databasis
   select SM3INSP
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Inspeksielys word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Inspection form being printed!  [Esc]=Stop printer.")
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
            @prow()+nTopl,(nWidt/2)-25 say upper(cOpsk)
            @prow()+1,(nWidt/2)-6  say "INSPEKSIELYS"
            @prow()+1,    1 say cGebNaam()
            @prow()  , nMidc say "             Verslag: " + cOption()
            @prow()+1,    1 say substr(cTotNaam(),1,40)
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,    1 say substr(cTotNaam(),41,40)
            @prow()  ,nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,    1 say trim(substr(cTotNaam(),81,40)) + ", " + substr(cTotNaam(),121,4)
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "Jaarlikse inspeksie [     ].          Fase [     ] inspeksie.          Inspeksiedatum [      /      /      ]."
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "                               Indekse             |    Vaar      |           Moer            |       |                          "
            @prow()+1,    1 say "             G G           ---------------         | ------------ | ------------------------- |       |                          "
            @prow()+1,    1 say "Id nommer    e e  Geboorte Spn Gdt Gdo V/K Fin Skt | Id nommer    | Id nommer    Geboorte     | û=In  |                          "
            @prow()+1,    1 say "RegNommer    s n  datum    205 365 540 ind mas omv | RegNommer    | RegNommer    datum    Kal | X=Uit | Opmerkings               "
            @prow()+1,    1 say "------------ - -- -------- --- --- --- --- --- --- | ------------ | ------------ -------- --- | ----- | -------------------------"
            //                   1            1416 19       28  32  36  40  44  48  5254           6769           82       91  95      103
         else
            @prow()+nTopl,(nWidt/2)-25 say upper(cOpsk)
            @prow()+1,(nWidt/2)-6  say "INSPECTION FORM"
            @prow()+1,    1 say cGebNaam()
            @prow()  , nMidc say "              Report: " + cOption()
            @prow()+1,    1 say substr(cTotNaam(),1,40)
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,    1 say substr(cTotNaam(),41,40)
            @prow()  ,nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,    1 say trim(substr(cTotNaam(),81,40)) + ", " + substr(cTotNaam(),121,4)
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "Annual inspection [     ].         Phase [     ] inspection.          Inspection date [      /      /      ]."
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "                               Indices             |    Sire      |            Dam            |       |                          "
            @prow()+1,    1 say "             S G           ---------------         | ------------ | ------------------------- |       |                          "
            @prow()+1,    1 say "Id number    e e  Birth    Wea Adg Ada Kle Fin Scr | Id number    | Id number    Birth    Cal | û=In  |                          "
            @prow()+1,    1 say "RegNumber    x n  date     205 365 540 ind mas cir | RegNumber    | RegNumber    date     ves | X=Out | Remarks                  "
            @prow()+1,    1 say "------------ - -- -------- --- --- --- --- --- --- | ------------ | ------------ -------- --- | ----- | -------------------------"
            //                   1            1416 19       28  32  36  40  44  48  5254           6769           82       91  95      103
         endif
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lRetu := .f.
         lLoop := .f.
         exit
      endif

      //Data
      @prow()+1,       1 say SM3INSP->idnr
      @prow()  ,pcol()+1 say SM3DATA->geslag
      @prow()  ,pcol()+1 say SM3DATA->generasie
      @prow()  ,pcol()+1 say SM3DATA->gebdatum
      @prow()  ,pcol()+1 say SM3DATA->ind205
      if empty(SM3DATA->fasekode)

         @prow()  ,pcol()+1 say SM3DATA->ind365
         @prow()  ,pcol()+1 say SM3DATA->ind540

         // Add finale mass on 12-07-02 12:10
         @prow()  ,pcol()+1 say "   "

         if SM3DATA->geslag == "1"
            @prow()  ,pcol()+1 say "   "
         elseif SM3DATA->gma540 > 0
            @prow()  ,pcol()+1 say SM3DATA->gma540
         else
            @prow()  ,pcol()+1 say SM3DATA->mas540
         endif

      else

         @prow()  ,pcol()+1 say SM3DATA->gdtind
         @prow()  ,pcol()+1 say SM3DATA->gdoind

         if "D" $ SM3DATA->fasekode
            if empty(SM3DATA->kleiberi) .and. !empty(SM3DATA->voeromseti)
               do while !SM3DATA->(rlock())
               enddo
               SM3DATA->kleiberi := SM3DATA->voeromseti
               SM3DATA->voeromseti := 0
               SM3DATA->(dbunlock())
            endif
            @prow()  ,pcol()+1 say SM3DATA->kleiberi
         else
            @prow()  ,pcol()+1 say SM3DATA->voeromseti
         endif
         @prow()  ,pcol()+1 say SM3DATA->einmas

      endif

      // 05-11-11 10:44 vervang
      //if empty(SM3DATA->mateskrot)
      //   @prow()  ,pcol()+1 say SM3DATA->gekskr
      //else
      //   @prow()  ,pcol()+1 say SM3DATA->mateskrot
      //endif
      // Add geslag on 12-07-02 12:02
      if SM3DATA->geslag == "1"
         @prow()  ,pcol()+1 say "   "
      else
         if empty(SM3DATA->fasekode)
               @prow()  ,pcol()+1 say SM3DATA->skr540
         else
            if empty(SM3DATA->gekskr)
               @prow()  ,pcol()+1 say SM3DATA->mateskrot
            else
               @prow()  ,pcol()+1 say SM3DATA->gekskr
            endif
         endif
      endif
      @prow()  ,pcol()+1 say "|"
      @prow()  ,pcol()+1 say SM3DATA->idvaar
      @prow()  ,pcol()+1 say "|"
      @prow()  ,pcol()+1 say SM3DATA->idmoer
      @prow()  ,pcol()+1 say if(empty(fMoerdata("gebdatum","D")),space(8),fMoerdata("gebdatum","D"))
      @prow()  ,pcol()+1 say if(empty(fMoerdata("kalfaantal","N")),space(3),fMoerdata("kalfaantal","N"))
      @prow()  ,pcol()+1 say "|"
      @prow()  ,pcol()+1 say "  " + SM3DATA->gekeur + "  "
      @prow()  ,pcol()+1 say "|"

      //Tweede lyn
      @prow()+1,  1 say SM3DATA->reknr
      @prow()  , 52 say "|"
      @prow()  , 54 say fVaarData("reknr")
      @prow()  , 67 say "|"
      @prow()  , 69 say fMoerData("reknr")
      @prow()  , 95 say "|"
      @prow()  ,103 say "|"

      @prow()+1,  1 say repl( "-",  nWidt )

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      //if eof() .or. (substr(cTotNaam(),149,3) != "213" .and. prow() >= nPrnl - 6) .or. ;
      //      (substr(cTotNaam(),149,3) == "213" .and. prow() >= nPrnl - 10)
      if eof() .or. (substr(cTotNaam(),149,3) != "213" .and. prow() >= nPagl - 6) .or. ;
            (substr(cTotNaam(),149,3) == "213" .and. prow() >= nPagl - 10)

         //Print onderste lyn
         @prow()  ,  1 say repl( "=",  nWidt )

         if cLanType() == "A"
            if substr(cTotNaam(),149,3) == "213"
               @prow()+1,  1 say "Onderneming deur Teler:"
               @prow()+1,  1 say "Hiermee onderneem ek, _________________________________________________________  Handtekeninge __________________________________"
               @prow()+1,  1 say "om, in die gee van die Bonsmarateelbeleid, geen afgekeurde Bonsmarabul of enige       van"
               @prow()+1,  1 say "ongekeurde Bonsmara of Bonsmaratipe bul of bulkalf ( uitgesonder 'n  ongeseende  Inspekteurs   __________________________________"
               @prow()+1,  1 say "kalf saam met sy moeder) vir teeldoeleindes aan enige persoon te verkoop of  te"
               @prow()+1,  1 say "vervreem nie.                                                                    Kilometers gereis ______________________________"
               @prow()+2,  1 say "Handtekening van Teler ________________________________________________________  " + cAppName()
            else
               @prow()+2,  1 say "Handtekening van Teler ______________________________________________       Handtekeninge _______________________________________"
               @prow()+1,  1 say "                                                                                 van"
               @prow()+1,  1 say "Kilometers gereis ___________________________________________________       Inspekteurs   _______________________________________"
            endif
         else
            if substr(cTotNaam(),149,3) == "213"
               @prow()+1,  1 say "Commitment by Breeder:    In the spirit of the Bonsmara breeding policy,"
               @prow()+1,  1 say "I______________________________________________________________________________    Signature     ________________________________"
               @prow()+1,  1 say "commit myself not to sell or alienate any rejected Bonsmara bull or any unapproved     of"
               @prow()+1,  1 say "Bonsmara or Bonsmaratype bull or bull calf (except an unweaned calf with its dam)  Inspectors    ________________________________"
               @prow()+1,  1 say "for breeding purposes to any other person."
               @prow()+1,  1 say "                                                                               Kilometers travelled _____________________________"
               @prow()+2,  1 say "Signature of Breeder ________________________________________________________  " + cAppName()
            else
               @prow()+2,  1 say "Signature of Breeder ______________________________________________        Signature      _______________________________________"
               @prow()+1,  1 say "                                                                               of"
               @prow()+1,  1 say "Kilometers travelled ___________________________________________________   Inspectors     _______________________________________"
            endif
         endif

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

/******************************************************************************/
STATIC FUNCTION fPrint219()                      //Drakensberger

   //Verklaar
   local nTota := 0
   local lLoop := .t.
   local nReko := 0
   local cData := ""
   local aSend := {}
   local aRecv := {}
   local nTotl := 0
   local dDat1 := ctod("")
   local dDat2 := ctod("")
   local nData := 0
   local nCrec := 0
   local cVaar := ""
   local lRetu := .t.
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   //Toets of drukker gereed is
   if fPrnReady() == K_ESC
      lRetu := .f.
      return lRetu
   endif

   // Force Condense Printing
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

   //Skuif die databasis
   select SM3INSP
   go top

   //Tel aantal velde
   nTota := lastrec()

   //Skerm
   if cLanType() == "A"
      fScrbood(24,"Inspeksielys word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Inspection form being printed!  [Esc]=Stop printer.")
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
            @prow()+nTopl,(nWidt/2)-25 say upper(cOpsk)
            @prow()+1,(nWidt/2)-6  say "INSPEKSIELYS"
            @prow()+1,    1 say cGebNaam()
            @prow()  , nMidc say "             Verslag: " + cOption()
            @prow()+1,    1 say substr(cTotNaam(),1,40)
            @prow()  , nMidc say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,    1 say substr(cTotNaam(),41,40)
            @prow()  ,nMidc say "              Bladsy: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,    1 say trim(substr(cTotNaam(),81,40)) + ", " + substr(cTotNaam(),121,4)
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "Fase [     ] inspeksie.          Inspeksiedatum [      /      /      ]."
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "                       |   |   |                         |                                 Indekse    "
            @prow()+1,    1 say "             Rekenaar  |   |   |                         |                         Aan ---------------"
            @prow()+1,    1 say "Id nommer    nommer    |In |Uit|Opmerking of Rede        |Id Vaar      Id Moer     kal 100 205 365 540"
            @prow()+1,    1 say "------------ ----------|---|---|-------------------------|------------ ----------- --- --- --- --- ---"
            //                   1            14         25  29  33                        59           72          84  88  92  96  100
         else
            @prow()+nTopl,(nWidt/2)-25 say upper(cOpsk)
            @prow()+1,(nWidt/2)-6  say "INSPECTION FORM"
            @prow()+1,    1 say cGebNaam()
            @prow()  , nMidc say "              Report: " + cOption()
            @prow()+1,    1 say substr(cTotNaam(),1,40)
            @prow()  , nMidc say "                Date: " + dtoc( dAppDate() )
            @prow()+1,    1 say substr(cTotNaam(),41,40)
            @prow()  ,nMidc say "                Page: " + ltrim( str( nBlad, 8 ) )
            @prow()+1,    1 say trim(substr(cTotNaam(),81,40)) + ", " + substr(cTotNaam(),121,4)
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "Phase [     ] inspection.          Inspection date [      /      /      ]."
            @prow()+1,    1 say repl("=",nWidt)
            @prow()+1,    1 say "                       |   |   |                         |                                 Indeces    "
            @prow()+1,    1 say "             Computer  |   |   |                         |                         Num ---------------"
            @prow()+1,    1 say "Id number    number    |In |Out| Remark or Reason        |Id Sire      Id Dam      cal 100 205 365 540"
            @prow()+1,    1 say "------------ ----------|---|---|-------------------------|------------ ----------- --- --- --- --- ---"
            //                   1            14         25  29  33                        59           72          84  88  92  96  100
         endif
      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         lRetu := .f.
         lLoop := .f.
         exit
      endif

      //Data
      @prow()+1,       1 say SM3INSP->idnr
      @prow()  ,      14 say SM3DATA->reknr
      @prow()  ,      24 say "|"
      @prow()  ,      28 say "|"
      @prow()  ,      32 say "|"
      @prow()  ,      58 say "|"
      @prow()  ,      59 say SM3DATA->idvaar
      @prow()  ,      72 say SM3DATA->idmoer
      @prow()  ,      84 say if(empty(fMoerdata("kalfaantal","N")),space(3),fMoerdata("kalfaantal","N"))
      @prow()  ,      88 say SM3DATA->ind100
      @prow()  ,      92 say SM3DATA->ind205
      @prow()  ,      96 say SM3DATA->ind365
      @prow()  ,     100 say SM3DATA->ind540

      @prow()+1,    1 say "-----------------------|---|---|-------------------------|--------------------------------------------"

      //@prow()+1,  1 say repl( "-",  nWidt )

      //Volgende rekord
      skip

      //Toets vir einde van bladsy
      if eof() .or. prow() >= nPrnl - 6

         //Print onderste lyn
         @prow()  ,  1 say repl( "=",  nWidt )

         if cLanType() == "A"
            @prow()+2,  1 say "Handtekening van Teler ______________________________________________       Handtekeninge _______________________________________"
            @prow()+1,  1 say "                                                                                 van"
            @prow()+1,  1 say "Kilometers gereis ___________________________________________________       Inspekteurs   _______________________________________"
         else
            @prow()+2,  1 say "Signature of Breeder ______________________________________________        Signature      _______________________________________"
            @prow()+1,  1 say "                                                                               of"
            @prow()+1,  1 say "Kilometers travelled ___________________________________________________   Inspectors     _______________________________________"
         endif

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

/****************************************************************************/
STATIC FUNCTION fResult

   //Verklaar
   local cCscr := savescreen(0,0,24,79)
   local aSend := {}
   local aRecv := {}
   local nBoxc := 0
   local getlist := {}

   //Lees die veldbeskrywing
   aadd(aSend,{"sm3data","idnr"  })
   aadd(aSend,{"sm3data","gekeur"})
   aadd(aSend,{"sm3data","redeui"})

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField(aSend)

   //Skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(10,space(50),5,"INSPEKSIERESULTATE")
   else
      nBoxc := fBoxCent(10,space(50),5,"INSPECTION RESULTS")
   endif

   //Loop
   do while !eof()

      //Vertoon dier
      @11,nBoxc say aRecv[1][6]
      setcolor(cColInve())
      @11,nBoxc+21 say SM3INSP->idnr
      setcolor(cColNorm())

      //Kry bestaande dier se syfers
      aRecv[2][14] := SM3DATA->gekeur
      aRecv[3][14] := SM3DATA->redeui

      //Vra die data
      if cLanType() == "A"
         fScrBood(23,"[Esc]=Inspeksies  [PgUp]=Vorige dier                   ")
         fScrBood(24,"[F1 ]=Hulp        [PgDn]=Volgende dier  [?]=Afkeurredes")
      else
         fScrBood(23,"[Esc]=Inspections  [PgUp]=Previous animal                     ")
         fScrBood(24,"[F1 ]=Help         [PgDn]=Next animal      [?]=Rejection codes")
      endif
      @12,nBoxc say aRecv[2][6] get aRecv[2][14] pict aRecv[2][10] valid(fVgekeur(2,aRecv))
      @13,nBoxc say aRecv[3][6] get aRecv[3][14] pict aRecv[3][10] valid(fVredeui(3,aRecv))
      set cursor on
      read
      set cursor off

      //Escaped
      if lastkey() == K_ESC
         exit
      endif

      //Stoor
      select SM3DATA
      do while !rlock()
      enddo
      SM3DATA->gekeur := aRecv[2][14]
      SM3DATA->redeui := aRecv[3][14]
      select SM3INSP

      //Sleutels
      do case
         case lastkey() == K_PGUP
            skip -1
            if bof()
               go top
            endif
         case lastkey() == K_PGDN
            skip
            if eof()
               go bottom
            endif
         otherwise
            skip
      endcase

   enddo
   go top

   //Herstel
   restscreen(0,0,24,79,cCscr)
return NIL

/****************************************************************************/
STATIC FUNCTION fVgekeur(nPlek,aRecv)

   //Verklaar
   local lRetu := .t.

   //Toets
   if aRecv[nPlek][14] == " "
      //Aanvaar
   elseif aRecv[nPlek][14] == "N"
      //Aanvaar
   elseif aRecv[nPlek][14] $ "JY"
      //Aanvaar na voorwaardes
      aRecv[3][14] := "  "
      keyboard chr(K_ENTER)
   else
      //Moenie aanvaar
      lRetu := .f.
   endif

return lRetu

/****************************************************************************/
STATIC FUNCTION fVredeui(nPlek,aRecv)

   //Verklaar
   local getlist := {}
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local cDbfs   := fTOpen()
   local cFile   := ""
   local lLoop   := .t.
   local aVeld   := {}
   local cData   := ""
   local cWend := ""

   //Nul data
   if empty(aRecv[nPlek][14]) .or. aRecv[nPlek][14] == "  -  -  -  -  "
      return lRetu
   endif

   //Open .dbf
   cFile := fTOpen(cDd(),"sm3rede")
   if left(cFile,1) == "f"
      if cLanType() == "A"
         fScrBood(23,"Afkeurredes lˆer kan nie geopen word nie!")
      else
         fScrBood(23,"Rejection code file cannot be opened!")
      endif
      fScrWait(24)
      lRetu := .f.
      return lRetu
   else
      select SM3REDE
      seek left(aRecv[nPlek][14],2)
      if eof() .or. "?" $ aRecv[nPlek][14]
         if eof()
            cWend := left(aRecv[nPlek][14],2)
         endif
         //Roep rede uit kudde program
         cData := sm3rede(5,5,,,left(aRecv[nPlek][14],2))
         if !empty(cData)
            if cData $ aRecv[nPlek][14]
            else
               aRecv[nPlek][14] := strtran(aRecv[nPlek][14],"? ",cData,1,1)
               lRetu := .f.
            endif
            if cData $ aRecv[nPlek][14]
            else
               aRecv[nPlek][14] := strtran(aRecv[nPlek][14]," ?",cData,1,1)
               lRetu := .f.
            endif
            if cData $ aRecv[nPlek][14]
            else
               if empty(cWend)
                  aRecv[nPlek][14] := strtran(aRecv[nPlek][14],"  ",cData,1,1)
               else
                  aRecv[nPlek][14] := strtran(aRecv[nPlek][14],cWend,cData,1,1)
               endif
               lRetu := .f.
            endif
         endif
      endif
   endif

   //Herstel
   fTClose(cFile)
   fTClose(cDbfs)
   restscreen(0,0,24,79,cCscr)
return lRetu

