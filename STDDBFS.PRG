//STDDBFS.PRG
//Program om databasisse te bewaar
//Kopiereg (c) 1991 A van Rensburg
//16:55 16 Sep,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

//**************************************************************************/
FUNCTION stddbfs( nTop, nLeft, nBottom, aSend, cFind )

   //Veranderlikes
   local cFile   := ""                           //Status of opened file
   local aRecv   := {}                           //Plaas opskrifte
   local nScrLen := 0                            //Totale lengte van die velde
   local nRight  := 77                           //Regterkantste lyn
   local cBrowse := NIL                          //Browse object
   local aColumn := {}                           //Kolomme array
   local i       := 0                            //Counter
   local lMore   := .t.                          //Logical looper
   local nKey    := 0                            //Keypress
   local cResult := cFind                        //Return value
   local cLocate := ""
   local cLocScr := ""
   local getlist := {}
   local nBoxCoor := 0

   private cData := ""                           //Column data fields for tbrowse
   private cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop    := if( nTop    == NIL, 4, nTop )
   nLeft   := if( nLeft   == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   if aSend == NIL
      aSend := {}
      if cLanType() == "A"
         aadd( aSend, { "stddbfs", "dbfname" })
         aadd( aSend, { "stddbfs", "dbfbesk" })
      else
         aadd( aSend, { "stddbfs", "dbfname" })
         aadd( aSend, { "stddbfs", "dbfdesc" })
      endif
   endif

   //Skerm
   fScrOpsk()

   //Veldbeskrywings
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Veldbeskrywings word opgesoek")
   else
      fScrWbood(24,"Field descriptions being sorted")
   endif
   aRecv := fGetField( aSend )

   //Open die stdmenu.tdb - gaan verander - use exclusive
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Datalˆer word geopen")
   else
      fScrWbood(24,"Data files being opened")
   endif
   cFile := fTOpen( , "stddbfs", , "tdb", "stddbfs", .f., .f. )
   if left( cFile, 1 ) == "f"
      return cResult
   endif

   //Skuif die databasis
   if cFind == NIL
   else
      seek cFind
      if eof()
         go top
      endif
   endif

   //Kry die breedte van venster
   for i = 1 to len( aRecv )

      //Lengte
      nScrLen := nScrLen + aRecv[i,4] + 3

      //Kolomme
      cData := aRecv[i,1] + aRecv[i,2]
      cHead := aRecv[i,7] + ";" + aRecv[i,8] + ";" + aRecv[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 77, 77, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "DATABASISSE" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "DATABASES" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+2, nBottom-1, nRight-2 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := " ³ "

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   // Main loop
   lMore := .t.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Menu  [Ins]=Nuwe   [A - Z]=Vind    " )
         fScrBood( 24, "[Enter]=Kies  [Del]=Skrap  [Alt E]=Verander" )
      else
         fScrBood( 23, "[ Esc ]=Menu    [Ins]=New     [A - Z]=Find  " )
         fScrBood( 24, "[Enter]=Choose  [Del]=Delete  [Alt E]=Edit  " )
      endif

      // Stabilize the display until it's stable or a key is pressed
      nKey := 0
      do while nKey == 0 .and. .not. cBrowse:stable
         cBrowse:stabilize()
         nKey := InKey()
      enddo

      if cBrowse:stable
         // Make sure that the current record is showing
         // up-to-date data in case we are on a network.
         cBrowse:refreshCurrent()
         ForceStable(cBrowse)
         // Everything's done -- just wait for a key
         nKey := InKey(0)
      endif

      if nKey == K_ESC
         //Esc means leave
         lMore := .f.

      elseif nKey == K_ENTER
         //Enter means return kode
         cResult := fieldget(1)
         lMore := .f.

      elseif nKey == K_INS
         //Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E
         //Alt E means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_DEL
         //Delete means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey >= 65 .and. nKey <= 90 .or. nKey >= 97 .and. nKey <= 122
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + space(9)
         cLocScr := savescreen( 0, 0, 24, 79 )
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter databasis? xxxxxxxxxx", 1 )
            @12, nBoxCoor say "Vind watter databasis?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find which database? xxxxxxxxxx", 1 )
            @12, nBoxCoor say "Find which database?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            set soft on
            seek cLocate
            if eof()
               go top
            endif
            set soft off
            cBrowse:refreshall()
         endif

      else
         // Apply the key to the browse
         ApplyKey(cBrowse, nKey)

      endif

   enddo

   //Herstel
   fTClose( cFile )
return cResult

/*************************************************************************/
STATIC FUNCTION fAddChg( lLogic )

   //Funksie om te bewaar of te verander

   //Veranderlikes
   local getlist  := {}
   local cCurSke  := savescreen(0,0,24,79)
   local nBoxCoor := 0
   local aSend    := {}
   local aRecv    := {}
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
   asize( aSend, 0 )
   aadd( aSend, { "stddbfs", "dbfname" })
   aadd( aSend, { "stddbfs", "dbfbesk" })
   aadd( aSend, { "stddbfs", "dbfdesc" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent(  9, space(60),   5, "NUWE DATABASIS" )
      else
         nBoxCoor := fBoxCent(  9, space(60),   5, "NEW DATABASE" )
      endif
   else
      nRekord := recno()
      //Skerm
      if cLanType() == "A"
         nBoxCoor := fBoxCent(  9, space(60),   5, "VERANDER DATABASIS" )
      else
         nBoxCoor := fBoxCent(  9, space(60),   5, "EDIT DATABASE" )
      endif
   endif

   //Vul met data en vertoon
   nLine := 9
   setcolor(cColNorm())
   @nLine,nBoxCoor say ""
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i][13] )
      @row()+1,nBoxCoor say aRecv[i][6]
   next

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @nLine,nBoxCoor+21 say ""
         for i = 1 to len( aRecv )
            @row()+1,nBoxCoor+21 say transform(aRecv[i][14],aRecv[i][10])
         next
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Menu naam
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na databasisse" )
               fScrBood( 24, "Tik die NAAM van die databasis." )
            else
               fScrBood( 23, "[Esc]=Return to database" )
               fScrBood( 24, "Type the NAME of the database." )
            endif
            @nLine+1,nBoxCoor say aRecv[1][6] get aRecv[1][14] pict aRecv[1][10]
            set curs on
            read
            set curs off
            //Nou??
            do case
               case lastkey() == K_ESC
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case len(trim(arecv[1][14])) == 0
                  if eof()
                     go top
                  endif
                  nLoop := 0
               case lastkey() == K_ENTER
                  //Toets of die rekord reeds bestaan
                  seek aRecv[1][14]
                  if eof()
                     //Bestaan nie - gaan voort
                     if nRekord > 0
                        goto nRekord
                     endif
                     nLoop++
                  else
                     //Bestaan wel
                     if nRekord > 0 .and. nRekord == recno()
                        //Dieselfde rekord - gaan voort
                        nLoop++
                     else
                        //Bestaan reeds - vertoon bestaande
                        for i = nLoop+1 to len( aRecv )
                           aRecv[i][14] := fieldget( aRecv[i][13] )
                        next
                        //Vertoon data
                        setcolor(cColInve())
                        @nLine,nBoxCoor+21 say ""
                        for i = 1 to len( aRecv )
                           @row()+1,nBoxCoor+21 say transform(aRecv[i][14],aRecv[i][10])
                        next
                        setcolor(cColNorm())
                        fScrBood( 23 )
                        if cLanType() == "A"
                           fScrWait( 24, "Databasis bestaan reeds!" )
                        else
                           fScrWait( 24, "Database already exists!" )
                        endif
                        if nRekord > 0
                           goto nRekord
                        else
                           go bottom
                           skip
                        endif
                        //Lees oorspronklike
                        for i = nLoop+1 to len( aRecv )
                           aRecv[i][14] := fieldget( aRecv[i][13] )
                        next
                        //Vertoon oorspronklike
                        setcolor(cColInve())
                        @nLine,nBoxCoor+21 say ""
                        for i = 1 to len( aRecv )
                           @row()+1,nBoxCoor+21 say transform(aRecv[i][14],aRecv[i][10])
                        next
                        setcolor(cColNorm())
                     endif
                  endif
            endcase

         case nLoop == 2
            //Menu option
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na databasis naam" )
               fScrBood( 24, "Tik die VOL NAAM van die databasis.")
            else
               fScrBood( 23, "[Esc]=Return to database name" )
               fScrBood( 24, "Type the FULL NAME of the database.")
            endif
            @nLine+2,nBoxCoor say aRecv[2][6] get aRecv[2][14] pict aRecv[2][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Nou??
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case len(trim(arecv[2][14])) == 0
                  if cLanType() == "A"
                     fScrBood(23,"Datalˆer beskrywing is verpligtend!")
                  else
                     fScrBood(23,"Data file description is compulsory!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         case nLoop == 3
            //Menu option
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na datalˆer naam" )
               fScrBood( 24, "Tik die VOLLE NAME van die datalˆer.")
            else
               fScrBood( 23, "[Esc]=Return to data file name" )
               fScrBood( 24, "Type the FULL NAME of the data file.")
            endif
            @nLine+3,nBoxCoor say aRecv[3][6] get aRecv[3][14] pict aRecv[3][10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            //Nou??
            do case
               case lastkey() == K_ESC
                  nLoop := 1
               case lastkey() == K_UP
                  nLoop--
               case len(trim(arecv[3][14])) == 0
                  if cLanType() == "A"
                     fScrBood(23,"Datalˆer beskrywing is verpligtend!")
                  else
                     fScrBood(23,"Data file description is compulsory!")
                  endif
                  fScrWait(24)
               case lastkey() == K_ENTER
                  nLoop++
            endcase

         otherwise
            //Bewaar rekord
            if nRekord > 0
               goto nRekord
            else
               dbAppend()
            endif
            //Lock
            do while !rlock()
            enddo
            for i = 1 to len( aRecv )
               //Bewaar die data
               fieldput( aRecv[i][13], aRecv[i][14] )
               //Maak dataSend skoon
               do case
                  case aRecv[i][3] == "N"
                     aRecv[i][14] := 0
                  case aRecv[i][3] == "D"
                     aRecv[i][14] := ctod("  /  /  ")
                  otherwise
                     aRecv[i][14] := space( aRecv[i][4] )
               endcase
            next

            if nRekord = 0
               nLoop := 1
            else
               nRekord = 0
               nLoop := 0
            endif

      endcase

   enddo

   //Herstel
   restscreen( 0, 0, 24, 79, cCurSke )
return lReturn

//*************************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige rekord te skrap

   //Verklaar
   local lReturn := .f.
   local cBood   := ""

   //Skerm
   if cLanType() == "A"
      fScrBood(23,trim(fieldget(2)))
      cBood := "Moet bogenoemde databasis geskrap word?"
   else
      fScrBood(23,trim(fieldget(3)))
      cBood := "Should above-mentioned database be deleted?"
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

