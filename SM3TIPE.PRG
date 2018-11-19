//sm3tipe.PRG
//Program om adrestipes te bewaar
//Kopiereg (c) 1992 A van Rensburg
//09:18 07 Jun,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/************************************************************************/
FUNCTION sm3tipe( nTop, nLeft, nBottom, aVelde, cFind )

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := setcursor(0)                 //Cursor
   LOCAL aTipeOp := {}                           //Plaas opskrifte
   LOCAL nScrLen := 0                            //Totale lengte van die velde
   LOCAL nBoxCoo := 0                            //Waar begin en eindig die box
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i       := 0                            //Counter
   LOCAL lMore   := .t.                          //Logical looper
   LOCAL nKey    := 0                            //Keypress
   LOCAL cReturn := ""                           //Return value
   LOCAL lLogic  := .t.                          //Diverse logic carrier
   LOCAL cLocate := ""
   LOCAL cTipe   := ""
   local cLocScr := ""
   local nBoxCoor := 0

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 60, nLeft )
   nBottom := if( nBottom == NIL, 20, nBottom )
   cFind := if( cFind == NIL, "      ", cFind )

   //Skerm
   if cLanType() == "A"
	  fScrOpsk(,"Opsie "+cOption())
      fScrBood(24,"Skermuitleg word bepaal")
   else
	  fScrOpsk(,"Option "+cOption())
      fScrBood(24,"Screen outlay being determined")
   endif
   fScrBood(23,"")

   //Kry die veldbeskrywings
   //aVelde is die array met velde wat vertoon moet word
   //aTipeOp is die array met die volledige veldbesonderhede
   aTipeOp := fGetField( aVelde )

   //Kry die totale lengte van die velde om die breedte van die venster te bepaal
   for i = 1 to len( aTipeOp )
      //Lengte
      nScrLen := nScrLen + aTipeOp[i,4] + 1
      //Kolomme
      cData := aTipeOp[i,1] + aTipeOp[i,2]
      cHead := aTipeOp[i,7] + ";" + aTipeOp[i,8] + ";" + aTipeOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )
   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die box
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "ADRESTIPES" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "ADDRESS TYPES" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   //Skerm
   fScrBood(23,"")
   if cLanType() == "A"
      fScrBood(24,"Datalˆers word geopen")
   else
      fScrBood(24,"Data files being opened")
   endif

   //Open die .dbf
   cTipe := fTOpen( cDd(), "sm3tipe", , "dbf", , .t., .f. )
   if left( cTipe, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return cReturn
   endif

   //Skuif die databasis
   if len( alltrim( cFind ) ) <> 0
      set soft on
      seek cFind
      set soft off
      if eof()
         go top
      endif
   endif

   // Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar  [Alt E]=Verander             " )
         fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [A - Z]=Vind      [Alt T]=Tel" )
      else
         fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [Alt E]=Edit               " )
         fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [A - Z]=Find  [Alt T]=Count" )
      endif

      //Vries
      //cBrowse:freeze := 2

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
         // Esc means leave
         lMore := .f.

      elseif nKey == K_ENTER
         // Enter means return plaaskode and exit
         cReturn := fieldget(1)
         lMore := .f.

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_E
         //Alt V means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_DEL
         // Insert means delete a record
         if fdelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_ALT_T
         //Alt T means count adresses
         fTel()
         cBrowse:refreshall()

      elseif nKey == K_F1
         //Hulp
         do help with "sm3tipe",1,"oorsig"

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + " "
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik die gedeelte van die adrestipe waarvoor gesoek word.")
         else
            fScrBood(24,"Type a section of the address code which should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter Adrestipe? xx", 1 )
            @12, nBoxCoor say "Vind watter Adrestipe?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find what Address Code? xx", 1 )
            @12, nBoxCoor say "Find what Address Code?" get cLocate pict "@!"
         endif
         set cursor on
         read
         set cursor off
         restscreen( 0, 0, 24, 79, cLocScr )
         if lastkey() == K_ESC
         else
            cLocate := trim( cLocate )
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
   fTClose( cTipe )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
   setcursor( cCurCur )

return cReturn

/*************************************************************************/
STATIC FUNCTION fAddChg

   //Veranderlikes
   LOCAL GetList := {}
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )
   LOCAL aSend   := {}
   LOCAL aRecv   := {}
   LOCAL nRekord := 0
   LOCAL aData   := {}
   LOCAL nBoxCoor:= 0
   LOCAL nLoop   := 0
   LOCAL lLoop   := .t.
   LOCAL i       := 1
   LOCAL lReturn := .f.
   LOCAL aVelde  := {}

   //Kry die velde benodig
   asize( aSend, 0 )
   aadd( aSend, { "sm3tipe", "tipe" })
   aadd( aSend, { "sm3tipe", "beskr" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
   else
      nRekord := recno()
   endif

   //Lees data
   for i = 1 to len( aRecv )
      aRecv[i][14] := fieldget( aRecv[i,13] )
   next

   //Skerm
   if cLanType() == "A"
      nBoxCoor := fBoxCent( 9, space(50), 4, "BEWAAR/VERANDER ADRESTIPES" )
   else
      nBoxCoor := fBoxCent( 9, space(50), 4, "ENTER/EDIT ADDRESS TYPES" )
   endif

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @ 10, nBoxCoor say aRecv[1][6]
   @ 11, nBoxCoor say aRecv[2][6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @ 10, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
         @ 11, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Kode

            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na die adrestipes" )
               fScrBood( 24, "Tik 'n kort kode wat die TIPE adres sal identifiseer." )
            else
               fScrBood( 23, "[Esc]=Return to the address types" )
               fScrBood( 24, "Type a short code that will identify the address TYPE." )
            endif
            @ 10, nBoxCoor say aRecv[1][6] get aRecv[1][14] pict aRecv[1][10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC .or. aRecv[1][14] == "  "
               if eof()
                  go top
               endif
               nLoop := 0
               loop
            endif
            lReturn := .t.

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
                     aRecv[i][14] := fieldget( aRecv[i,13] )
                  next
                  //Vertoon data
                  setcolor(cColInve())
                  @ 10, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1,10]  )
                  @ 11, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2,10]  )
                  setcolor(cColNorm())
                  fScrBood( 23 )
                  if cLanType() == "A"
                     fScrWait( 24, "Adrestipe is reeds op rekenaar!" )
                  else
                     fScrWait( 24, "Address type already on computer!" )
                  endif
                  if nRekord > 0
                     goto nRekord
                  else
                     go bottom
                     skip
                  endif
               endif
            endif
            //Vul data
            for i = nLoop+1 to len( aRecv )
               aRecv[i][14] := fieldget( aRecv[i,13] )
            next
            //Vertoon data
            setcolor(cColInve())
            @ 10, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1,10]  )
            @ 11, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2,10]  )
            setcolor(cColNorm())

         case nLoop == 2
            //Beskrywing
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Adrestipes" )
               fScrBood( 24, "Tik 'n BESKRYWING van die adrestipe." )
            else
               fScrBood( 23, "[Esc]=Return to Address types" )
               fScrBood( 24, "Type a DESCRIPTION of the address type." )
            endif
            @ 11, nBoxCoor say aRecv[2,6] get aRecv[2][14] pict aRecv[2,10]
            readexit(.t.)
            set curs on
            read
            set curs off
            readexit(.f.)
            do case
               case lastkey() == K_ESC
                  //Return to first get
                  nLoop := 1
                  loop
               case lastkey() == K_UP
                  //Return to first get
                  nLoop--
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         otherwise
            //Bewaar rekord

            if nRekord > 0
               goto nRekord
            else
               appe blank
            endif

            lLoop := .t.
            do while lLoop
               if rlock()
                  for i = 1 to len( aRecv )
                     //Bewaar die data
                     fieldput( aRecv[i,13], aRecv[i][14] )
                     //Maak datavelde skoon
                     do case
                        case aRecv[i][3]  == "N"
                           aRecv[i][14] := 0
                        case aRecv[i][3]  == "D"
                           aRecv[i][14] := ctod("  /  /  ")
                        otherwise
                           aRecv[i][14] := space( aRecv[i,4] )
                     endcase
                  next
                  commit
                  exit
               endif
            enddo

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

/***********************************************************************/
STATIC FUNCTION fDelete

   //Funksie om enige adres totaal en al te skrap

   //Verklaar
   local lReturn := .f.

   fScrBood( 23, trim( SM3TIPE->tipe ) + " - " + trim( SM3TIPE->beskr ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde ADRESTIPE geskrap word?",,.f. )
         if rlock()
            delete
            dbUnlock()
            skip
            if eof()
               go top
            endif
            lReturn := .t.
         endif
      endif
   else
      if fJaNee( 24, "Should above ADDRESS TYPE be deleted?",,.f. )
         if rlock()
            delete
            dbUnlock()
            skip
            if eof()
               go top
            endif
            lReturn := .t.
         endif
      endif
   endif

return lReturn

/***********************************************************************/
STATIC FUNCTION fTel

   //Funksie om die aantal adresse te tel

   //Verklaar
   local GetList := {}
   local cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   local cCurScr := fCurScreen()                 //Kleure ens
   local cCurDbf := fTOpen()                     //Databasis
   local cLede   := ""                           //Adresse databasis
   local cData   := ""                           //Data carrier
   local i       := 1
   local nTeller := 1

   //Maak huidige adrestipes aantal skoon
   select sm3tipe
   go top
   if flock()
      replace all sm3tipe->aantal with 0
      dbUnlock()
   endif
   go top

   //Open die adresse leer
   cLede := fTOpen( cDd(), "sm3klie", , "dbf", , .t., .f. )
   if left( cLede, 1 ) == "f"
      fTClose(    cCurDbf )
      fSetScreen( cCurScr )
      restscreen( 0, 0, 24, 79, cCurSke )
      return NIL
   endif
   go top

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Adresse word getel")
   else
      fScrWbood(24,"Addresses being counted")
   endif

   //Die loop
   do while !( eof() )

      setcolor( cColBott() )
      if cLanType() == "A"
         @23,35 say str((nTeller/lastrec())*100,3,0)+"% voltooi"
      else
         @23,35 say str((nTeller/lastrec())*100,3,0)+"% completed"
      endif
      setcolor( cColNorm() )

      //Loop deur die tipe veld
      for i = 1 to 13 step 3
         cData := substr( SM3KLIE->tipe, i, 2 )
         if len( trim( cData ) ) > 0
            //Bewaar die aantal adresse
            select sm3tipe
            seek cData
            if !(eof()) .and. rlock()
               sm3tipe->aantal++
               dbUnlock()
            endif
            select SM3KLIE
         endif
      next

      //Breek indien nodig
      if inkey() == K_ESC
         select SM3KLIE
         go bottom
      endif

      //Volgende rekord
      nTeller++
      select SM3KLIE
      skip

   enddo

   //Herstel
   fTClose(    cLede   )
   fTClose(    cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurSke )
return NIL

