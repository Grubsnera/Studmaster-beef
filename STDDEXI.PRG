//STDDEXI.PRG
//Program om programindeks te vertoon
//Kopiereg (c) 1992 A van Rensburg
//13:23 09 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"
#include "common.ch"

/**************************************************************************/
FUNCTION stddexi( nTop, nLeft, nBottom, aVelde )

   //Veranderlikes
   local aRecv   := {}
   local nScrl   := 0
   local nBoxc   := 0
   local nRight  := 76
   local bBrow   := NIL
   local aCols   := {}
   local i       := 0
   local lMore   := TRUE
   local nKey    := 0
   local cReturn := NIL
   local cDexi   := ""
   local cLoca   := ""
   local aCdbf   := fATopen()

   private cData := ""
   private cHead := ""

   begin sequence
      //Skerm
      if cLanType() == "A"
         fScrOpsk( , "Opsie "+cOption())
      else
         fScrOpsk( , "Option "+cOption())
      endif

      if cLanType() == "A"
         fScrBood(24,"Skermuitleg word bepaal")
      else
         fScrBood(24,"Screen outlay being determined")
      endif

      //Parameters
      nTop    := if( nTop    == NIL, 3, nTop )
      nLeft   := if( nLeft   == NIL, 2, nLeft )
      nBottom := if( nBottom == NIL, 4, nBottom )

      //Kry die veldbeskrywings
      aRecv := fGetfield( aVelde )

      //Kry totale lengte van velde om breedte van venster te bepaal
      for i = 1 to len( aRecv )
         //Lengte
         nScrl := nScrl + aRecv[i,4] + 1
         //Kolomme
         cData := aRecv[i,1] + aRecv[i,2]
         cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
         aadd( aCols, TBColumnNew( cHead, {|| &cData } ) )
      next
      //Bepaal regterkantste lyn
      nRight := if(nLeft+nScrl > 76, 76, nLeft+nScrl )

      //Teken die boks
      if cLanType() == "A"
         fBox( nTop, nLeft, nBottom, nRight, "PROGRAMINDEKS" )
      else
         fBox( nTop, nLeft, nBottom, nRight, "PROGRAM INDEX" )
      endif
      setcolor( cColNorm() )

      //Bou die tBrowse
      bBrow := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
      bBrow:headsep := "Í"
      bBrow:colsep := "³"

      //Plaas Kolomme oor na die browse object
      for i = 1 to len( aCols )
         bBrow:addColumn( aCols[i] )
      next

      //Open die tdb leer
      if cLanType() == "A"
         fScrBood(24,"Datalˆers word geopen")
         aCdbf := fATopen(aCdbf,,"STDDEXA",,"tdb")
      else
         fScrBood(24,"Data files being opened")
         aCdbf := fATopen(aCdbf,,"STDDEXE",,"tdb")
      endif
      if !aCdbf[len(aCdbf),1]
         break
      endif

      //Main loop
      lMore := TRUE
      do while lMore

         //Skerm
         if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
            if cLanType() == "A"
               fScrBood( 23, "[ Esc ]=Menu   [Ins]=Bewaar  [Alt E]=Verander  [Alt P]=Druk  " )
               fScrBood( 24, "[Enter]=Opsie  [Del]=Skrap   [A - Z]=Vind      [Alt F]=Filter" )
            else
               fScrBood( 23, "[ Esc ]=Menu    [Ins]=Enter  [Alt E]=Edit  [Alt P]=Print  " )
               fScrBood( 24, "[Enter]=Option  [Del]=Delete [A - Z]=Find  [Alt F]=Filter " )
            endif
         else
            if cLanType() == "A"
               fScrBood( 23, "[ Esc ]=Menu      [A - Z]=Na inskrywing  [Alt P]=Druk  " )
               fScrBood( 24, "[Enter]=Na opsie  [Alt H]=Handleiding    [Alt F]=Filter" )
            else
               fScrBood( 23, "[ Esc ]=Menu         [A - Z]=Go to entry  [Alt P]=Print  " )
               fScrBood( 24, "[Enter]=Go to option [Alt H]=Manual       [Alt F]=Filter " )
            endif
         endif

         //Sabilize display until stable or key is pressed
         nKey := 0
         do while nKey == 0 .and. .not. bBrow:stable
            bBrow:stabilize()
            nKey := InKey()
         enddo

         if bBrow:stable
            // Make sure that the current record is showing
            // up-to-date data in case we are on a network.
            bBrow:refreshCurrent()
            ForceStable(bBrow)
            // Everything's done -- wait for a key
            nKey := Inkey(0)
         endif

         if nKey == K_ESC
            //Esc means Leave
            lMore := FALSE

         elseif nKey == K_ENTER
            //Enter means return option number
            cReturn := fieldget(3)
            lMore := FALSE

         elseif nKey == K_INS .and. (upper(left(cGebNaam(), 16)) == "6003295079089JNR")
            //Insert means add a record to the .dbf
            go bottom
            skip
            if fAddChg(aRecv)
               bBrow:refreshall()
            endif

         elseif nKey ==K_ALT_E .and. (upper(left(cGebNaam(), 16)) == "6003295079089JNR")
            //Alt E means change a record
            if fAddChg(aRecv)
               bBrow:refreshall()
            endif

         elseif nKey == K_DEL .and. (upper(left(cGebNaam(), 16)) == "6003295079089JNR")
            //Del means delete a record
            if fDelete()
               bBrow:refreshall()
            endif

         elseif nKey == K_ALT_H
            // Alt H means get help
            help(fieldget(1),1,"oorsig")

         elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122
            //Indien enige alfabetiese karakter gedruk was
            //Skuif die databasis
            cLoca = upper(chr(nKey))
            skip
            if cLanType() == "A"
               cData := left(STDDEXA->kode,1)
            else
               cData := left(STDDEXE->kode,1)
            endif
            if cData <> cLoca
               //Begin van voor af soek
               set soft on
               seek padr(cLoca,10)
               set soft off
               if eof()
                  go top
               endif
            else
               if cLanType() == "A"
                  do while left(STDDEXA->besk,1) == " "
                     skip
                     if eof()
                        exit
                     endif
                  enddo
                  if left(STDDEXA->kode,1) <> cLoca
                     //Begin van voor af soek
                     set soft on
                     seek padr(cLoca,10)
                     set soft off
                     if eof()
                        go top
                     endif
                  endif
               else
                  do while left(STDDEXE->besk,1) == " "
                     skip
                     if eof()
                        exit
                     endif
                  enddo
                  if left(STDDEXE->kode,1) <> cLoca
                     //Begin van voor af soek
                     set soft on
                     seek padr(cLoca,10)
                     set soft off
                     if eof()
                        go top
                     endif
                  endif
               endif
            endif
            bBrow:refreshall()

         elseif nKey == K_ALT_P
            //Alt P means print a record
            fPrint(aRecv)
            bBrow:refreshall()

         elseif nKey == K_ALT_F
            //Alt F means set a filter condition
            if fFilter()
               bBrow:refreshall()
            endif

         elseif nKey == K_F1
            //Hulp
            do help with "stddexi",1,"oorsig"

         else
            // Apply the key to the browse
            ApplyKey(bBrow, nKey)

         endif

      enddo

   end

   //Herstel
   fATclose(aCdbf)

return cReturn

/**************************************************************************/
STATIC FUNCTION fAddChg( aRecv )

   //Veranderlikes
   local Getlist := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )
   local aSend   := {}
   local nRekord := 0
   local aData   := {}
   local nBoxc   := 0
   local nLoop   := 0
   local lLoop   := TRUE
   local i       := 1
   local lReturn := FALSE
   local aVelde  := {}
   local aProd   := {}
   local nSaved  := 0

   //Kry die velde benodig
   if aRecv == NIL
      asize( aSend, 0 )
      if cLanType() == "A"
         aadd( aSend, { "stddexa", "kode" })
         aadd( aSend, { "stddexa", "besk" })
         aadd( aSend, { "stddexa", "opsi" })
      else
         aadd( aSend, { "stddexe", "kode" })
         aadd( aSend, { "stddexe", "besk" })
         aadd( aSend, { "stddexe", "opsi" })
      endif
      aRecv := fGetField( aSend )
   endif

   //Bou veranderlikes
   if eof()
      nRekord := 0
      if cLanType() == "A"
         nBoxc := fBoxCent( 9, space(50), 5, "BEWAAR NUWE PROGRAMINDEKS" )
      else
         nBoxc := fBoxCent( 9, space(50), 5, "ENTER NEW PROGRAM INDEX" )
      endif
   else
      nRekord := recno()
      if cLanType() == "A"
         nBoxc := fBoxCent( 9, space(50), 5, "VERANDER PROGRAMINDEKS" )
      else
         nBoxc := fBoxCent( 9, space(50), 5, "EDIT PROGRAM INDEX" )
      endif
   endif

   //Lees data
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i,13] )
   next

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @  10, nBoxc say aRecv[1][6]
   @  11, nBoxc say aRecv[2][6]
   @  12, nBoxc say aRecv[3][6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @ 10, nBoxc+21 say transform( aRecv[1][14] , aRecv[1][10]  )
         @ 11, nBoxc+21 say transform( aRecv[2][14] , aRecv[2][10]  )
         @ 12, nBoxc+21 say transform( aRecv[3][14] , aRecv[3][10]  )
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Kode

            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na programindeks" )
               fScrBood( 24, "Tik 'n kort sorteerkode vir die programindeks item." )
            else
               fScrBood( 23, "[Esc]=Return to program index" )
               fScrBood( 24, "Type a short sorting code for the program index item." )
            endif

            //Vra die vraag
            @  10, nBoxc say aRecv[1][6] get aRecv[1][14] pict aRecv[1][10]
            set curs on
            read
            set curs off

            //Wat nou
            do case
               case lastkey() == K_ESC
                  //If escaped
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case aRecv[1][14] == space(10)
                  //If nil
                  if cLanType() == "A"
                     fScrBood(23,"Kode mag nie niks wees nie!")
                  else
                     fScrBood(23,"Code may not be nothing!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  //Toets of die rekord reeds bestaan
                  seek upper(aRecv[1][14])
                  //Dieselfde rekord
                  if eof()
                     if nRekord > 0
                        goto nRekord
                     endif
                     nLoop++
                  else
                     if nRekord > 0 .and. nRekord == recno()
                        nLoop++
                     else
                        //Vul data
                        for i = nLoop+1 to len( aRecv )
                           aRecv[i][14] := fieldget( aRecv[i][13] )
                        next
                        //Vertoon data
                        setcolor(cColInve())
                        @ 10, nBoxc+21 say transform( aRecv[1][14], aRecv[1][10] )
                        @ 11, nBoxc+21 say transform( aRecv[2][14], aRecv[2][10] )
                        @ 12, nBoxc+21 say transform( aRecv[3][14], aRecv[3][10] )
                        setcolor(cColNorm())
                        fScrBood( 23 )
                        if cLanType() == "A"
                           fScrWait( 24, "Kode is reeds op rekenaar!" )
                        else
                           fScrWait( 24, "Code already on computer!" )
                        endif
                        if nRekord > 0
                           goto nRekord
                        else
                           go bottom
                           skip
                        endif
                        //Vul data
                        for i = nLoop+1 to len( aRecv )
                           aRecv[i][14] := fieldget( aRecv[i][13] )
                        next
                        //Vertoon data
                        setcolor(cColInve())
                        @ 10, nBoxc+21 say transform( aRecv[1][14], aRecv[1][10] )
                        @ 11, nBoxc+21 say transform( aRecv[2][14], aRecv[2][10] )
                        @ 12, nBoxc+21 say transform( aRecv[3][14], aRecv[3][10] )
                        setcolor(cColNorm())
                     endif
                  endif
            endcase

         case nLoop == 2
            //Beskrywing

            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na die kode." )
               fScrBood( 24, "Tik 'n beskrywing vir die item." )
            else
               fScrBood( 23, "[Esc]=Return to the code." )
               fScrBood( 24, "Type a description for the item." )
            endif
            @ 11, nBoxc  say aRecv[2][6] get aRecv[2][14] pict aRecv[2][10]
            readexit(TRUE)
            set curs on
            read
            set curs off
            readexit(FALSE)

            //Wat nou
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
            endcase

         case nLoop == 3
            //Opsie

            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na die kode." )
               fScrBood( 24, "Tik 'n programopsie." )
            else
               fScrBood( 23, "[Esc]=Return to the code." )
               fScrBood( 24, "Type a program option." )
            endif
            @ 12, nBoxc  say aRecv[3][6] get aRecv[3][14] pict aRecv[3][10]
            readexit(TRUE)
            set curs on
            read
            set curs off
            readexit(FALSE)

            //Wat nou
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
            endcase

         otherwise
            //Bewaar rekord
            if nRekord > 0
               goto nRekord
            else
               appe blank
            endif
            //Sluit rekord
            do while !rlock()
            enddo
            nSaved := recno()
            //Bewaar data
            for i = 1 to len( aRecv )
               fieldput( aRecv[i][13], aRecv[i][14] )
            next
            //Maak datavelde skoon
            go bottom
            skip
            for i = 1 to len( aRecv )
               aRecv[i][14] := fieldget( aRecv[i][13] )
            next
            goto nSaved
            //Waarheen nou
            if nRekord = 0
               nLoop := 1
            else
               nLoop := 0
            endif
            lReturn := TRUE

      endcase

   enddo

   //Herstel
   restscreen( 0,0,24,79, cCurske )
return lReturn

//*************************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := FALSE
   local cBood   := ""

   //Skerm
   fScrBood(23,trim(fieldget(2)))
   if cLanType() == "A"
      cBood := "Moet bogenoemde programindeks inskrywing geskrap word?"
   else
      cBood := "Should above-mentioned program index entry be deleted?"
   endif

   //Vra
   if fJaNee( 24, cBood,,FALSE )
      do while !rlock()
      enddo
      delete
      skip
      if eof()
         go top
      endif
      lReturn := TRUE
   endif

return lReturn

//***********************************************************************/
STATIC FUNCTION fPrint(aRecv)

   //Verklaar
   local nRecno  := recno()
   local nTotaal := 1
   local aSend   := {}
   local lLoop   := TRUE
   local nI      := 1
   local nRekord := 1
   local cHdln := ""
   local cPcod := ""
   local nMidc := 0
   local nWidt := 0
   local nTopl := 0
   local nPrnl := 0
   local nPagl := 0
   local nBlad := 1

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Databasis
   go top
   nTotaal := lastrec()

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif
   //Kry die velde benodig
   if aRecv == NIL
      asize( aSend, 0 )
      if upper(left(cGebNaam(), 16)) == "6003295079089JNR"
         if cLanType() == "A"
            aadd( aSend, { "stddexa", "kode" })
            aadd( aSend, { "stddexa", "besk" })
            aadd( aSend, { "stddexa", "opsi" })
         else
            aadd( aSend, { "stddexe", "kode" })
            aadd( aSend, { "stddexe", "besk" })
            aadd( aSend, { "stddexe", "opsi" })
         endif
      else
         if cLanType() == "A"
            aadd( aSend, { "stddexa", "besk" })
            aadd( aSend, { "stddexa", "opsi" })
         else
            aadd( aSend, { "stddexe", "besk" })
            aadd( aSend, { "stddexe", "opsi" })
         endif
      endif
      aRecv := fGetField( aSend )
   endif

   //Bepaal die drukwydte
   nWidt := 0
   for nI = 1 to len(aRecv)
      nWidt+= aRecv[nI,4]+1
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
      fScrbood(24,"Programindeks word gedruk!  [Esc]=Stop drukker.")
      cHdln := "PROGRAMINDEKS."
   else
      fScrbood(24,"Program index being printed!  [Esc]=Stop printer." )
      cHdln := "PROGRAM INDEX."
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := TRUE
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
         @prow()+1,  1 say repl( "=", nWidt )

         //1e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say padr( trim( aRecv[nI,7] ), aRecv[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,7] ), aRecv[nI,4] )
            endif
         next

         //2e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say padr( trim( aRecv[nI,8] ), aRecv[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,8] ), aRecv[nI,4])
            endif
         next

         //3e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say padr( trim( aRecv[nI,9] ), aRecv[nI,4])
            else
               @prow()  ,pcol()+1 say padr( trim( aRecv[nI,9] ), aRecv[nI,4])
            endif
         next

         //4e Lyn van opskrif
         for nI = 1 to len( aRecv )
            if nI == 1
               @prow()+1,       1 say repl( "-", aRecv[nI,4] )
            else
               @prow()  ,pcol()+1 say repl( "-", aRecv[nI,4] )
            endif
         next
      endif

      //Toets of drukker moet stop
      If fPrnStop() = K_ESC
         goto nRecno
         return NIL
      endif

      //Data
      for nI = 1 to len( aRecv )
         if nI == 1
            @prow()+1,  1 say fieldget(aRecv[nI][13])
         else
            @prow()  ,pcol()+1 say fieldget(aRecv[nI][13])
         endif
      next

      //Skerm
      // fPrnOff()
      // if nTotaal > 0
      //    setcolor( cColBott() )
      //    fScrBood(23)
      //    if cLanType() == "A"
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Voltooi"
      //    else
      //       @ 23, 30 say str( ( nRekord / nTotaal ) * 100, 4, 0 ) + " % Completed"
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
         @prow()+1,  1 say repl( "=", nWidt )
         @prow()+1,  1 say cAppName()
         fPrnEjec()
         //fPrnOff()
         nBlad++

         //Indien eof()
         if eof()
            lLoop := FALSE
         endif
      endif
   enddo

   fPrnOff()

   //Herstel
   goto nRecno
return NIL

//**************************************************************************/
STATIC FUNCTION fFilter()

   //Funksie om filter te stel

   //Verklaar
   local cLocScr := savescreen(0,0,24,79)
   local nBoxc   := 0
   local cFilter := space(30)
   local lReturn := FALSE
   local getlist := {}

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Terug na programindeks")
      fScrBood(24,"Tik die indeksinskrywing waarvoor gesoek word.")
      nBoxc := fBoxCent( 11, "Watter indeksinskrywing? "+space(30), 3, "FILTER" )
      @12, nBoxc say "Watter indeksinskrywing?" get cFilter pict "@!"
   else
      fScrBood(23,"[Esc]=Return to program index.")
      fScrBood(24,"Type the index entry which should be found.")
      nBoxc := fBoxCent( 11, "What index entry? "+space(30), 3, "FILTER" )
      @12, nBoxc say "What index entry?" get cFilter pict "@!"
   endif
   set cursor on
   read
   set cursor off
   restscreen(0,0,24,79,cLocScr)

   //Escaped
   if lastkey() == K_ESC
   else
      if cFilter == space(30)
         set filter to
         go top
      else
         cFilter := alltrim(cFilter)
         if cLanType() == "A"
            set filter to cFilter $ upper(STDDEXA->besk)
         else
            set filter to cFilter $ upper(STDDEXE->besk)
         endif
         go top
      endif
      lReturn := TRUE
   endif

   //Herstel
return lReturn

