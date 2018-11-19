//SM3FASK.PRG
//Program om fase d kostes te vertoon
//Kopiereg (c) 1993 A van Rensburg
//04-25-93 10:39am

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//****************************************************************************/
FUNCTION sm3fask( nTop, nLeft, nBott, aSend, cFind )

   //Veranderlikes
   local cCscr := savescreen(0,0,24,79)
   local cCdbf := fTOpen()
   local cFase := ""
   local aRecv := {}
   local nScrl := 0
   local nRigh := 77
   local bBrow := NIL
   local aCols := {}
   local i     := 0
   local lMore := .t.
   local nKeyp := 0
   local cRetu := space(6)
   local lCalc := .f.

   private cData := ""
   private cHead := ""

   //Skerm
   if nTop == NIL
      if cLanType() == "A"
         fScrOpsk(,"Opsie "+cOption())
      else
         fScrOpsk(,"Option "+cOption())
      endif
   else
      if cLanType() == "A"
         fScrOpsk(1,"Opsie "+cOption())
      else
         fScrOpsk(1,"Option "+cOption())
      endif
   endif

   //Parameters
   nTop    := if( nTop  == NIL, 3, nTop  )
   nLeft   := if( nLeft == NIL, 2, nLeft )
   nBott   := if( nBott == NIL,20, nBott )
   if aSend == NIL
      aSend := {}
      aadd(aSend,{"sm3fase","fasekode"})
      aadd(aSend,{"sm3fase","dat365"})
      aadd(aSend,{"sm3fase","ligmper"})
      aadd(aSend,{"sm3fase","rantkos"})
      aadd(aSend,{"sm3fase","massa"})
      aadd(aSend,{"sm3fase","aantal"})
      aadd(aSend,{"sm3fase","dae"})
      //aadd(aSend,{"sm3fase","kosbul"})
      aadd(aSend,{"sm3fase","lopbul"})
      //aadd(aSend,{"sm3fase","kostot"})
      aadd(aSend,{"sm3fase","loptot"})
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
      fScrWbood(24,"Opening data files")
   endif
   cFase := fTOpen(cDd(),"sm3fase")
   if left(cFase,1) == "f"
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
      fBox( nTop, nLeft, nBott, nRigh, "FASE D KOSTES" )
   else
      fBox( nTop, nLeft, nBott, nRigh, "PHASE D COSTS" )
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
         fScrBood( 23, "[Esc]  [Enter]  [Ins]  [Alt E ]  [Alt B]  [Alt P]  [Del]  [A-Z]  [F1]" )
         fScrBood( 24, " Menu   Kies     Nuwe  Verander  Bereken   Druk    Skrap   Vind  Hulp" )
      else
         fScrBood( 23, "[Esc]  [Enter]  [Ins]  [Alt E ]  [ Alt B ]  [Alt P]  [Del ]  [A-Z]  [F1]" )
         fScrBood( 24, " Menu   Choose   New     Edit    Calculate   Print   Delete   Find  Help" )
      endif

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
         if fACfask()
            lCalc := .f.
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_E
         //Alt E means change a record
         if fACfask()
            lCalc := .f.
            bBrow:refreshall()
         endif

      elseif nKeyp == K_ALT_B
         //Alt B means calculate
         if fCalc(fieldget(1))
            lCalc := .t.
            bBrow:refreshall()
         endif

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
         if !lCalc
            fCalc(fieldget(1))
         endif
         fPrint(,fieldget(1))
         bBrow:refreshall()

      elseif nKeyp == K_F1
         //Hulp
         do help with "sm3fask",1,"oorsig"

      else
         // Apply the key to the browse
         ApplyKey(bBrow, nKeyp)

      endif

   enddo

   //Herstel
   restscreen(0,0,24,79,cCscr)
   fTClose(cFase)
   fTClose(cCdbf)
return cRetu

/*************************************************************************/
STATIC FUNCTION fACfask(aRecv)

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
      aadd(aSend,{"sm3fase","fasekode"})
      aadd(aSend,{"sm3fase","dat365"})
      aadd(aSend,{"sm3fase","ligmper"})
      aadd(aSend,{"sm3fase","rantkos"})
      aadd(aSend,{"sm3fase","massa"})
      aadd(aSend,{"sm3fase","aantal"})
      aadd(aSend,{"sm3fase","dae"})
      aRecv := fGetField(aSend)
   endif

   //Bou veranderlikes
   nLine := 12 - int(len(aRecv)/2)
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NUWE FASE D KOSTE-INSKRYWING")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"NEW PHASE D COST ENTRY")
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"VERANDER FASE D KOSTE-INSKRYWING")
      else
         nBoxc := fBoxCent(nLine,space(50),len(aRecv)+2,"EDIT PHASE D COST ENTRY")
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
            //Read
            @nLine+ 1,nBoxc say aRecv[ 1,6] get aRecv[ 1,14] pict aRecv[ 1,10] valid(fVkode(1,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 2,nBoxc say aRecv[ 2,6] get aRecv[ 2,14] pict aRecv[ 2,10] valid(fVdatu(2,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 3,nBoxc say aRecv[ 3,6] get aRecv[ 3,14] pict aRecv[ 3,10] //valid(fVkode(3,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 4,nBoxc say aRecv[ 4,6] get aRecv[ 4,14] pict aRecv[ 4,10] //valid(fVkode(4,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 5,nBoxc say aRecv[ 5,6] get aRecv[ 5,14] pict aRecv[ 5,10] //valid(fVkode(5,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 6,nBoxc say aRecv[ 6,6] get aRecv[ 6,14] pict aRecv[ 6,10] //valid(fVkode(6,aRecv,nRekord,nLine,nBoxc))
            @nLine+ 7,nBoxc say aRecv[ 7,6] get aRecv[ 7,14] pict aRecv[ 7,10] //valid(fVkode(7,aRecv,nRekord,nLine,nBoxc))
            set cursor on
            read
            set cursor off
            lReturn := .t.
            //Wat nou
            do case
               case lastkey() == K_ESC
                  //Escaped
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case lastkey() == K_ENTER
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

//*************************************************************************/
STATIC FUNCTION fDelete(aRecv)

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(1))+" - "+dtoc(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde fase D koste-inskrywing geskrap word?"
   else
      cBood := "Should above-mentioned phase D cost entry be deleted?"
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

//*************************************************************************/
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
   cData := upper(chr(nKeyp)) + space(aRecv[1,4]-1)

   //Move cursor one right
   keyboard chr(K_RIGHT)

   //Teken die skerm
   if cLanType() == "A"
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"VIND")
   else
      nBoxc := fBoxCent(11,space(21+aRecv[1][4]),3,"FIND")
   endif

   //Vra die veld
   @12,nBoxc say aRecv[1][6] get cData pict aRecv[1][10]
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


/*************************************************************************/
STATIC FUNCTION fPrint(aRecv,cFasg)

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

   //Kry die velde wat gedruk moet word
   if aRecv == NIL
      asize(aSend,0)
      aadd(aSend,{"sm3fase","fasekode"})
      aadd(aSend,{"sm3fase","dat365"})
      aadd(aSend,{"sm3fase","ligmper"})
      aadd(aSend,{"sm3fase","rantkos"})
      aadd(aSend,{"sm3fase","massa"})
      aadd(aSend,{"sm3fase","aantal"})
      aadd(aSend,{"sm3fase","dae"})
      aadd(aSend,{"sm3fase","kosbul"})
      aadd(aSend,{"sm3fase","lopbul"})
      aadd(aSend,{"sm3fase","kostot"})
      aadd(aSend,{"sm3fase","loptot"})
      if cLanType() == "A"
         fScrwbood(24,"Veldbeskrywings word opgesoek")
      else
         fScrwbood(24,"Field descriptions being sorted")
      endif
      aRecv := fGetField(aSend)
   endif

   //Skuif die databasis
   select SM3FASE
   seek cFasg
   //go top

   //Tel aantal velde
   do while !eof()
      nTota++
      skip
   enddo
   seek cFasg
   //nTota := lastrec()

   //Bepaal die drukwydte
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
      fScrbood(24,"Fase D kostes word gedruk!  [Esc]=Stop drukker.")
      cHdln := upper("Fase D kostes vir die "+alltrim(cFasg)+" fasegroep.")
   else
      fScrbood(24,"Phase D costs being printed!  [Esc]=Stop printer.")
      cHdln := upper("Phase D costs for the "+alltrim(cFasg)+" phase group.")
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
      if prow() >= nPrnl .or. eof() .or. SM3FASE->fasekode <> cFasg

         //Print onderste lyn
         @prow()+1,  1 say repl( "=",  nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien nie meer groep
         if SM3FASE->fasekode <> cFasg
            lLoop := .f.
         endif

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   //go top
   seek cFasg
return NIL

//***************************************************************************/
STATIC FUNCTION fCalc(cFasg)

   //Funksie om fase d kostes te bereken

   //Verklaar
   local cCscr := savescreen(23,0,24,79)
   local nLbul := 0
   local nLtot := 0

   //Waardes
   if cFasg == NIL
      return .f.
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Kostes word bereken")
   else
      fScrWbood(24,"Costs being calculated")
   endif

   //Databasis
   select SM3FASE
   seek cFasg

   //Loop
   do while SM3FASE->fasekode == cFasg
      do while !rlock()
      enddo
      SM3FASE->kosbul := ((((SM3FASE->ligmper/100)*SM3FASE->massa)*SM3FASE->rantkos)*SM3FASE->dae)
      nLbul += SM3FASE->kosbul
      SM3FASE->lopbul := nLbul
      SM3FASE->kostot := (((((SM3FASE->ligmper/100)*SM3FASE->massa)*SM3FASE->rantkos)*SM3FASE->dae)*SM3FASE->aantal)
      nLtot += SM3FASE->kostot
      SM3FASE->loptot := nLtot
      skip
   enddo
   seek cFasg

   //Herstel
   restscreen(23,0,24,79,cCscr)
return .t.

//******************************************************************************/
STATIC FUNCTION fVkode(nItem,aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(23,0,24,79)

   do case
      case len(alltrim(aRecv[nItem][14])) == 0
         if cLanType() == "A"
            fScrBood(23,"Fasekode is verpligtend!")
         else
            fScrBood(23,"Phase code is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
   endcase

   //Herstel
   restscreen(23,0,24,79,cCscr)
return lRetu

//******************************************************************************/
STATIC FUNCTION fVdatu(nItem,aRecv,nRekord,nLine,nBoxc)

   //Verklaar
   local lRetu   := .t.
   local cCscr   := savescreen(0,0,24,79)
   local aDisp   := aclone(aRecv)
   local cSeek   := ""
   local i       := 1

   do case
      case aRecv[nItem][14] == ctod("")
         if cLanType() == "A"
            fScrBood(23,"Weegdatum is verpligtend!")
         else
            fScrBood(23,"Weigh date is compulsory!")
         endif
         fScrWait(24)
         lRetu := .f.
      otherwise
         //Kyk of rekord reeds bestaan
         seek aDisp[1,14]+dtos(aDisp[nItem][14])
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
               //Vul data
               for i = 1 to len(aDisp)
                  aDisp[i][14] := fieldget(aRecv[i][13])
                  setcolor(cColInve())
                  @nLine+i,nBoxc+21 say transform(aDisp[i][14],aDisp[i][10])
                  setcolor(cColNorm())
               next
               //Wag
               fScrBood(23)
               if cLanType() == "A"
                  fScrWait(24,"Fasekode en weegdatum bestaan reeds!" )
               else
                  fScrWait(24,"Phase code & weigh date already exist!" )
               endif
               if nRekord > 0
                  goto nRekord
               else
                  go bottom
                  skip
               endif
               //Vertoon oorspronklike
               setcolor(cColInve())
               for i = 1 to len(aRecv)
                  @nLine+i,nBoxc+21 say transform(aRecv[i][14],aRecv[i][10])
               next
               setcolor(cColNorm())
               lRetu := .f.
            endif
         endif
   endcase

   //Herstel
   restscreen(0,0,24,79,cCscr)
return lRetu

