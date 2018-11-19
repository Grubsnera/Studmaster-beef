//sm3Aank.PRG
//Program om Aankope te bewaar en skrap
//Kopiereg (c) 1992 A van Rensburg
//12:44pm May 26,1992

#include "inkey.ch"
#include "albert.ch"
#include "set.ch"

/**************************************************************************/
FUNCTION sm3Aank( nTop, nLeft, nBottom, aVelde, cFind )

   //Veranderlikes
   LOCAL cCurSke := savescreen( 0, 0, 24, 79 )   //Skerm
   LOCAL cCurScr := fCurScreen()                 //Kleure ens
   LOCAL cCurDbf := fTOpen()                     //Databasis
   LOCAL cCurCur := Setcursor(0)                 //Cursor
   LOCAL aAdraOp := {}                           //Plaas opskrifte
   local aAankOp := {}
   LOCAL nScrlen := 0                            //Totale lengte van die veld
   LOCAL nBoxCoo := 0                            //Waar begin en endig die boks
   LOCAL nRight  := 76                           //Regterkantste lyn
   LOCAL cBrowse                                 //Browse object
   LOCAL cScr                                    //Skerm
   LOCAL aColumn := {}                           //Kolomme array
   LOCAL i                                       //Counter
   LOCAL lMore                                   //Logical looper
   LOCAL nKey                                    //Keypress
   LOCAL cReturn := cFind                        //Return value
   LOCAL lLogic                                  //Diverse logic carrier
   LOCAL cLocate
   LOCAL cAank
   LOCAL cHoof
   local cLocScr := ""
   local nBoxCoor := 0
   local getlist := {}

   PRIVATE cData := ""                           //Column data fields for tbrowse
   PRIVATE cHead := ""                           //Heading of tbrowse

   //Parameters
   nTop := if( nTop == NIL, 4, nTop )
   nLeft := if( nLeft == NIL, 4, nLeft )
   nBottom := if( nBottom == NIL, 4, nBottom )
   cFind := if( cFind == NIL, "     ", cFind )

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrBood(24,"Skermuitleg word bepaal")
   else
      fScrBood(24,"Screen outlay being determined")
   endif

   //Kry die veldbeskrywings
   //aVelde is array met velde wat vertoon moet word
   //aAankOp is array met volledige veldbesonderhede
   aAankOp := fGetfield( aVelde )

   //Kry totale lengte van velde om breedte van venster te bepaal
   for i = 1 to len( aAankOp )

      //Lengte
      nScrlen := nScrlen + aAankOp[i,4] + 1

      //Kolomme
      cData := aAankOp[i,1] + aAankOp[i,2]
      cHead := aAankOp[i,7] + ";" + aAankOp[i,8] + ";" + aAankOp[i,9]
      aadd( aColumn, TBColumnNew( cHead, {|| &cData } ) )

   next

   //Bepaal regterkantste lyn
   nRight := if(nLeft+nScrLen > 76, 76, nLeft+nScrLen )

   //Teken die boks
   if cLanType() == "A"
      fBox( nTop, nLeft, nBottom, nRight, "AANKOPE" )
   else
      fBox( nTop, nLeft, nBottom, nRight, "PURCHASES" )
   endif
   setcolor( cColNorm() )

   //Bou die tBrowse
   cBrowse := TBrowseDB( nTop+1, nLeft+1, nBottom-1, nRight-1 )
   cBrowse:headsep := "Í"
   cBrowse:colsep := "³"

   //Plaas Kolomme oor na die browse object
   for i = 1 to len( aColumn )
      cBrowse:addColumn( aColumn[i] )
   next

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrBood(24,"Datalˆers word geopen")
   else
      fScrBood(24,"Data files being opened")
   endif

   //Open die .dbf
   cHoof := fTOpen( cDd(), "sm3data", , "dbf", , .t., .f. )
   if left(cHoof, 1 ) == "f"
      fTClose( cCurDbf )
      fSetScreen( cCurscr )
      restscreen( 0, 0, 24, 79, cCurske )
      return cReturn
   endif
   cAank := fTOpen( cDd(), "sm3Aank", , "dbf", , .t., .f. )
   if left(cAank, 1 ) == "f"
      fTClose( cHoof )
      fTClose( cCurDbf )
      fSetScreen( cCurscr )
      restscreen( 0, 0, 24, 79, cCurske )
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

   //Main loop
   lMore := .T.
   do while lMore

      //Skerm
      if cLanType() == "A"
         fScrBood( 23, "[ Esc ]=Terug  [Ins]=Bewaar  [Alt E]=Verander  [Alt P]=Druk  " )
         fScrBood( 24, "[Enter]=Kies   [Del]=Skrap   [A - Z]=Vind      [Alt T]=Totale" )
      else
         fScrBood( 23, "[ Esc ]=Return  [Ins]=Enter   [Alt E]=Edit   [Alt P]=Print " )
         fScrBood( 24, "[Enter]=Choice  [Del]=Delete  [A - Z]=Find   [Alt T]=Totals" )
      endif

      //Vries
      //cBrowse:Freeze := 2

      //Sabilize display until stable or key is pressed
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
         // Everything's done -- wait for a key
         nKey := Inkey(0)
      endif

      if nKey == K_ESC
         // Esc means Leave
         lMore := .f.

      elseif nKey == K_ENTER
         //Enter means return kode and exit
         cReturn := fieldget(1)
         lMore := .f.

      elseif nKey == K_INS
         // Insert means add a record to the .dbf
         go bottom
         skip
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey ==K_ALT_E
         //Alt E means change a record
         if fAddChg()
            cBrowse:refreshall()
         endif

      elseif nKey == K_DEL
         // Del means delete a record
         if fDelete()
            cBrowse:refreshall()
         endif

      elseif nKey == K_F1
         //Hulp
         do help with "sm3Aank",1,"oorsig"

      elseif nKey == K_ALT_T
         //Kry totale
         go top
         cScr := savescreen( 0, 0, 24, 79)
         fTotals()
         cBrowse:refreshall()
         restscreen( 0, 0, 24, 79, cScr)

      elseif nKey == K_ALT_P
         //Druk aankope verslag
         fPrint()
         cBrowse:refreshall()

      elseif nKey >= 65 .and. nKey <= 90 .or. ;
            nKey >= 97 .and. nKey <= 122 .or. ;
            nKey >= 48 .and. nKey <= 57
         // Means locate a record
         cLocate := upper( chr( nKey ) ) + "           "
         cLocScr := savescreen( 0, 0, 24, 79 )
         fScrBood(23)
         if cLanType() == "A"
            fScrBood(24,"Tik 'n gedeelte van die Id nommer wat gesoek moet word.")
         else
            fScrBood(24,"Type a section of the Id number which should be found.")
         endif
         keyboard chr( K_RIGHT )
         //Skerm
         if cLanType() == "A"
            nBoxCoor := fBoxCent( 12, "Vind watter Dier? xxxxxxxxxxxx", 1 )
            @12, nBoxCoor say "Vind watter Dier?" get cLocate pict "@!"
         else
            nBoxCoor := fBoxCent( 12, "Find what Animal? xxxxxxxxxxxx", 1 )
            @12, nBoxCoor say "Find what Animal? " get cLocate pict "@!"
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
   fTClose( cAank )
   fTClose( cHoof )
   fTClose( cCurDbf )
   fSetScreen( cCurScr )
   restscreen( 0, 0, 24, 79, cCurske )
   setcursor( cCurCur )

return cReturn

/**************************************************************************/
STATIC FUNCTION fAddChg

   //Veranderlikes
   LOCAL Getlist := {}
   LOCAL cCurSke := Savescreen( 0, 0, 24, 79 )
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
   LOCAL aBeha   := {}

   //Kry die velde benodig
   asize( aSend, 0 )
   aadd( aSend, { "sm3Aank", "idnr" })
   aadd( aSend, { "sm3Aank", "datum" })
   aadd( aSend, { "sm3Aank", "massa" })
   aadd( aSend, { "sm3Aank", "adreskode" })
   aadd( aSend, { "sm3Aank", "bedrag" })
   aadd( aSend, { "sm3Aank", "graad" })
   aRecv := fGetField( aSend )

   //Bou veranderlikes
   if eof()
      nRekord := 0
   else
      nRekord := recno()
   endif

   //Lees data
   for i = 1 to len( aRecv )
      aRecv[i][14] := Fieldget( aRecv[i,13] )
   next

   //Skerm
   if cLanType() == "A"
      nBoxCoor := fBoxCent( 6, space(45), 8, "BEWAAR/VERANDER AANKOPE" )
   else
      nBoxCoor := fBoxCent( 6, space(45), 7, "ENTER/EDIT PURCHASES" )
   endif

   //Teken veldbeskrywings
   setcolor(cColNorm())
   @  7, nBoxCoor say aRecv[1 ,6]
   @  8, nBoxCoor say aRecv[2 ,6]
   @  9, nBoxCoor say aRecv[3 ,6]
   @ 10, nBoxCoor say aRecv[4 ,6]
   @ 11, nBoxCoor say aRecv[5 ,6]
   @ 12, nBoxCoor say aRecv[6 ,6]

   nLoop := 1
   do while nLoop > 0

      if nLoop == 1
         setcolor(cColInve())
         @  7, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
         @  8, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
         @  9, nBoxCoor+21 say transform( aRecv[3][14] , aRecv[3][10]  )
         @ 10, nBoxCoor+21 say transform( aRecv[4][14] , aRecv[4][10]  )
         @ 11, nBoxCoor+21 say transform( aRecv[5][14] , aRecv[5][10]  )
         @ 12, nBoxCoor+21 say transform( aRecv[6][14] , aRecv[6][10]  )
         setcolor(cColNorm())
      endif

      do case

         case nLoop == 1
            //Aankopekode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Aankope." )
               fScrBood( 24, "Tik die Id nommer van die dier." )
            else
               fScrBood( 23, "[Esc]=Return to Purchases." )
               fScrBood( 24, "Type the Id number of the animal." )
            endif
            @  7, nBoxCoor say aRecv[1,6] get aRecv[1][14] pict aRecv[1,10]
            set curs on
            read
            set curs off

            //Return to master
            if lastkey() == K_ESC .or. aRecv[1][14] == space(12)
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
               loop
            else
               if nRekord > 0 .and. nRekord == recno()
                  nLoop++
               else
                  //Vul data
                  for i = 1 to len( aRecv )
                     aRecv[i][14] := fieldget( aRecv[i,13] )
                  next
                  //Vertoon data
                  setcolor(cColInve())
                  @  7, nBoxCoor+21 say transform( aRecv[1][14] , aRecv[1][10]  )
                  @  8, nBoxCoor+21 say transform( aRecv[2][14] , aRecv[2][10]  )
                  @  9, nBoxCoor+21 say transform( aRecv[3][14] , aRecv[3][10]  )
                  @ 10, nBoxCoor+21 say transform( aRecv[4][14] , aRecv[4][10]  )
                  @ 11, nBoxCoor+21 say transform( aRecv[5][14] , aRecv[5][10]  )
                  @ 12, nBoxCoor+21 say transform( aRecv[6][14] , aRecv[6][10]  )
                  setcolor(cColNorm())
                  fScrBood( 23 )
                  if cLanType() == "A"
                     fScrwait( 24, "Dier reeds in aankope lˆer!" )
                  else
                     fScrWait( 24, "Animal already in purchases file!" )
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
            for i = 1 to len( aRecv )
               aRecv[i][14] := fieldget( aRecv[i,13] )
            next

         case nLoop == 2
            //Datum aangekoop
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Id nommer." )
               fScrBood( 24, "Tik die datum waarop die dier aangekoop is." )
            else
               fScrBood( 23, "[Esc]=Return to Id number." )
               fScrBood( 24, "Type the date on which the animal was purchased." )
            endif
            @  8, nBoxCoor say aRecv[2,6] get aRecv[2][14] pict aRecv[2,10]
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

         case nLoop == 3
            //Massa met aankoop
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Id nommer" )
               fScrBood( 24, "Tik die massa van die dier met aankoop." )
            else
               fScrBood( 23, "[Esc]=Return to Id number" )
               fScrBood( 24, "Type the mass of the animal purchased." )
            endif
            @ 9, nBoxCoor say aRecv[3,6] get aRecv[3][14] pict aRecv[3,10]
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
                  //Return to previous get
                  nLoop--
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 4
            //Verkoper se adreskode
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Id nommer.  "+D_DNARR+"==Adreskodes.")
               fScrBood( 24, "Tik die adreskode van die verkoper." )
            else
               fScrBood( 23, "[Esc]=Return to Id number. "+D_DNARR+"==Address codes." )
               fScrBood( 24, "Type the address code for the seller." )
            endif
            @ 10, nBoxCoor say aRecv[4,6] get aRecv[4][14] pict aRecv[4,10]
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
                  //Return to previous get
                  nLoop--
                  loop
               case lastkey() == K_DOWN
                  //Roep adresse
                  asize( aSend, 0 )
                  aadd( aSend, { "sm3klie", "kode" })
                  aadd( aSend, { "sm3klie", "naam" })
                  aRecv[4][14] := sm3klie( 4, 4, 20, aSend, aRecv[4][14] )
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 5
            //Bedrag betaal
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Id nommer." )
               fScrBood( 24, "Tik die bedrag waarvoor die dier aangekoop is." )
            else
               fScrBood( 23, "[Esc]=Return to Id number." )
               fScrBood( 24, "Type the amount paid for the animal purchased." )
            endif
            @ 11, nBoxCoor say aRecv[5,6] get aRecv[5][14] pict aRecv[5,10]
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
                  //Return to previous get
                  nLoop--
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         case nLoop == 6
            //Opmerking tydens aankoop
            //Skerm + read
            if cLanType() == "A"
               fScrBood( 23, "[Esc]=Terug na Id nommer." )
               fScrBood( 24, "Tik enige opmerking tydens aankoop van bogenoemde dier." )
            else
               fScrBood( 23, "[Esc]=Return to Id number." )
               fScrBood( 24, "Type any remark current to purchase of the animal." )
            endif
            @ 12, nBoxCoor say aRecv[6,6] get aRecv[6][14] pict aRecv[6,10]
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
                  //Return to previous get
                  nLoop--
                  loop
               case lastkey() == K_ENTER
                  //Volgende vraag
                  nLoop++
               otherwise
                  loop
            endcase

         otherwise
            //Bewaar record
            if nRekord > 0
               goto nRekord
            else
               select SM3DATA
               seek aRecv[1][14]
               if eof()
                  appe blank
                  do while !rlock()
                  enddo
                  SM3DATA->idnr := aRecv[1][14]
                  SM3DATA->dataan := aRecv[2][14]
               endif
               select SM3AANK
               appe blank
            endif

            lLoop := .T.
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
   restscreen( 0,0,24,79, cCurske )
return lReturn

/**************************************************************************/
STATIC FUNCTION fDelete

   //Funksie om dier uit aankope lˆer te skrap

   //Verklaar
   LOCAL lReturn := .f.

   fScrBood( 23, Trim( sm3Aank->idnr ) + " - " + Trim( sm3Aank->adreskode ) )
   if cLanType() == "A"
      if fJaNee( 24, "Moet bogenoemde dier uit aankope lˆer geskrap word?", , .f. )
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
      if fJaNee( 24, "Should above-mentioned animal be removed from purchase file?", , .f. )
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

/**************************************************************************/
STATIC FUNCTION fTotals

   //Verklaar
   local cCurScr := savescreen(0,0,24,79)
   local dBdate  := ctod("")
   local dEdate  := ctod("")
   local nBoxc   := 0
   local cSeek   := ""
   local aTotal[5]
   local cMess   := "TOTALE"
   local getlist := {}

   //Waardes
   afill(aTotal,0)

   //Databasis
   select SM3AANK
   go top

   //Vra die datums

   //Teken skerm
   nBoxc := fBoxCent(10,space(36),5,cMess)
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Terug na Aankope")
      fScrBood(24,"Tik datums of laat albei datums oop vir alle aankope.")
   else
      fScrBood(23,"[Esc]=Return to Purchases")
      fScrBood(24,"Type dates or leave both dates open for all purchases.")
   endif

   //Vra die datums
   if cLanType() == "A"
      @11,nBoxc say "Aankope vanaf watter datum?" get dBdate
      @13,nBoxc say "          Tot watter datum?" get dEdate
   else
      @11,nBoxc say "Purchases from which date?" get dBdate
      @13,nBoxc say "            To which date?" get dEdate
   endif

   //Read
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC
      select SM3AANK
      go top
      restscreen(0,0,24,79,cCurScr)
      return NIL
   endif

   //Soekstring
   if cLanType() == "A"
      do case
         case dBdate <> ctod("") .and. dEdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'").and.datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "AANKOPE VANAF " + dtoc(dBdate) + " TOT " + dtoc(dEdate)
         case dBdate == ctod("") .and. dEdate == ctod("")
            cSeek := 'datum<>ctod("")'
            cMess := "ALLE AANKOPE"
         case dBdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'")'
            cMess := "AANKOPE NA " + dtoc(dBdate)
         case dEdate <> ctod("")
            cSeek := 'datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "AANKOPE VOOR " + dtoc(dEdate)
         otherwise
            cSeek := 'datum<>ctod("")'
            cMess := "ALLE AANKOPE"
      endcase
   else
      do case
         case dBdate <> ctod("") .and. dEdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'").and.datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "PURCHASES FROM " + dtoc(dBdate) + " TO " + dtoc(dEdate)
         case dBdate == ctod("") .and. dEdate == ctod("")
            cSeek := 'datum<>ctod("")'
            cMess := "ALL PURCHASES"
         case dBdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'")'
            cMess := "PURCHASES AFTER " + dtoc(dBdate)
         case dEdate <> ctod("")
            cSeek := 'datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "PURCHASES BEFORE " + dtoc(dEdate)
         otherwise
            cSeek := 'datum<>ctod("")'
            cMess := "ALL PURCHASES"
      endcase
   endif

   //Tel die diere
   do while !eof()

      if &cSeek
         aTotal[1]++
         if SM3AANK->massa > 0
            aTotal[2]++
            aTotal[3] := aTotal[3] + SM3AANK->massa
         endif
         if SM3AANK->bedrag > 0
            aTotal[4]++
            aTotal[5] := aTotal[5] + SM3AANK->bedrag
         endif
      endif

      skip

   enddo

   //Teken totale skerm
   restscreen(0,0,24,79,cCurScr)
   nBoxc := fBoxCent( 7,space(36),11,cMess)

   //Teken inhoud
   if cLanType() == "A"
      @ 8,nBoxc say "Aantal diere            "
      @10,nBoxc say "Aantal diere met massas "
      @11,nBoxc say "Totale massa            "
      @12,nBoxc say "Gemiddelde massa        "
      @14,nBoxc say "Aantal diere met bedrae "
      @15,nBoxc say "Totale bedrag           "
      @16,nBoxc say "Gemiddelde bedrag       "
   else
      @ 8,nBoxc say "No of animals           "
      @10,nBoxc say "No of animals with mass "
      @11,nBoxc say "Total mass              "
      @12,nBoxc say "Average mass            "
      @14,nBoxc say "No animals with values  "
      @15,nBoxc say "Total value             "
      @16,nBoxc say "Average value           "
   endif

   //Data
   setcolor(cColInve())
   @ 8,nBoxc+25 say ltrim(str(aTotal[1],10,0))
   @10,nBoxc+25 say ltrim(str(aTotal[2],10,0))
   @11,nBoxc+25 say ltrim(str(aTotal[3],10,0))
   @12,nBoxc+25 say if(aTotal[2]>0, ltrim(str(aTotal[3]/aTotal[2],10,0)), "0" )
   @14,nBoxc+25 say ltrim(str(aTotal[4],10,0))
   @15,nBoxc+25 say ltrim(str(aTotal[5],10,2))
   @16,nBoxc+25 say if(aTotal[4]>0, ltrim(str(aTotal[5]/aTotal[4],10,2)), "0.00" )
   setcolor(cColNorm())

   //Wag vir sleutel
   fScrBood(23)
   fScrWait(24)

   //Herstel
   select SM3AANK
   go top
   restscreen(0,0,24,79,cCurScr)
return NIL

/*************************************************************************/
STATIC FUNCTION fPrint

   //Verklaar
   local cCurScr := savescreen(0,0,24,79)
   local dBdate  := ctod("")
   local dEdate  := ctod("")
   local nBoxc   := 0
   local cSeek   := ""
   local aTotal[5]
   local cMess   := "AANKOPE VERSLAG"
   local aVelde  := {}
   local aDbfOp  := {}
   local cWaar   := NIL
   local nTotaal := 1
   local lLoop   := .t.
   local nI      := 1
   local nBladsy := 1
   local nRekord := 1
   local getlist := {}

   private cData

   //Waardes
   afill(aTotal,0)

   //Toets of drukker gereed is
   fScrBood(23)
   if fPrnReady() == K_ESC
      return NIL
   endif

   //Databasis
   select SM3AANK
   go top
   nTotaal := lastrec()

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrWbood(24,"Verslagformaat word bepaal")
   else
      fScrWbood(24,"Report format being determined")
   endif

   //Kry die velde wat gedruk moet word
   asize( aVelde, 0 )
   aadd( aVelde, { "sm3aank", "idnr" } )
   aadd( aVelde, { "sm3aank", "datum" } )
   aadd( aVelde, { "sm3aank", "massa" } )
   aadd( aVelde, { "sm3aank", "bedrag" } )
   aadd( aVelde, { "sm3aank", "graad" } )
   aadd( aVelde, { "sm3aank", "adreskode" } )
   aDbfOp := fGetField( aVelde )

   //Teken skerm
   nBoxc := fBoxCent(10,space(36),5,cMess)
   if cLanType() == "A"
      fScrBood(23,"[Esc]=Terug na Aankope")
      fScrBood(24,"Tik datums of laat albei datums oop vir alle aankope.")
   else
      fScrBood(23,"[Esc]=Return to Purchases")
      fScrBood(24,"Type dates or leave both dates open for all purchases.")
   endif

   //Vra die datums
   if cLanType() == "A"
      @11,nBoxc say "Aankope vanaf watter datum?" get dBdate
      @13,nBoxc say "          Tot watter datum?" get dEdate
   else
      @11,nBoxc say " Purchases from which date?" get dBdate
      @13,nBoxc say "             To which date?" get dEdate
   endif

   //Read
   set cursor on
   read
   set cursor off

   //Escaped
   if lastkey() == K_ESC
      select SM3AANK
      go top
      restscreen(0,0,24,79,cCurScr)
      return NIL
   endif

   //Soekstring
   if cLanType() == "A"
      do case
         case dBdate <> ctod("") .and. dEdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'").and.datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "AANKOPE VANAF " + dtoc(dBdate) + " TOT " + dtoc(dEdate)
         case dBdate == ctod("") .and. dEdate == ctod("")
            cSeek := 'datum<>ctod("")'
            cMess := "ALLE AANKOPE"
         case dBdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'")'
            cMess := "AANKOPE NA " + dtoc(dBdate)
         case dEdate <> ctod("")
            cSeek := 'datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "AANKOPE VOOR " + dtoc(dEdate)
         otherwise
            cSeek := 'datum<>ctod("")'
            cMess := "ALLE AANKOPE"
      endcase
   else
      do case
         case dBdate <> ctod("") .and. dEdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'").and.datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "PURCHASES FROM " + dtoc(dBdate) + " TO " + dtoc(dEdate)
         case dBdate == ctod("") .and. dEdate == ctod("")
            cSeek := 'datum<>ctod("")'
            cMess := "ALL PURCHASES"
         case dBdate <> ctod("")
            cSeek := 'datum>=ctod("'+dtoc(dBdate)+'")'
            cMess := "PURCHASES AFTER " + dtoc(dBdate)
         case dEdate <> ctod("")
            cSeek := 'datum<=ctod("'+dtoc(dEdate)+'")'
            cMess := "PURCHASES BEFORE " + dtoc(dEdate)
         otherwise
            cSeek := 'datum<>ctod("")'
            cMess := "ALL PURCHASES"
      endcase
   endif

   //Skerm
   fScrBood(23)
   if cLanType() == "A"
      fScrbood(24,"Aankope verslag word gedruk!  [Esc]=Stop drukker.")
   else
      fScrbood(24,"Purchases report being printed!  [Esc]=Stop printer.")
   endif

   //Skakel die drukker aan
   fPrnOn()

   //Doen die loop
   lLoop := .t.
   do while lLoop

      //Opskrifte
      if prow() = 0

         fPrnCod( cPrnNorm() )

         if cLanType() == "A"
            @prow()+1,  1 say upper( cGebNaam() )
            @prow()  , 50 say "               Datum: " + dtoc( dAppDate() )
            @prow()+1,  1 say upper( cMess )
            @prow()  , 50 say "              Bladsy: " + str( nBladsy, 8 )
         else
            @prow()+1,  1 say upper( cGebNaam() )
            @prow()  , 50 say "                Date: " + dtoc( dAppDate() )
            @prow()+1,  1 say upper( cMess )
            @prow()  , 50 say "                Page: " + str( nBladsy, 8 )
         endif
         @prow()+1,  1 say repl( "=", 79 )
         //1e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,7] ), aDbfOp[nI,4] )
            endif
         next
         //2e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,8] ), aDbfOp[nI,4] )
            endif
         next
         //3e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say padr( trim( aDbfOp[nI,9] ), aDbfOp[nI,4] )
            endif
         next
         //4e Lyn van opskrif
         for nI = 1 to len( aDbfOp )
            if nI == 1
               @prow()+1,       1 say repl( "-", aDbfOp[nI,4] )
            else
               @prow()  ,pcol()+1 say repl( "-", aDbfOp[nI,4] )
            endif
         next
         @prow()+1,  1 say repl( "=", 79 )

      endif

      //Toets of drukker moet stop
      if fPrnStop() = K_ESC
         fTClose( cWaar )
         return NIL
      endif

      //Data
      if &cSeek
         for nI = 1 to len( aDbfOp )
            cData := aDbfOp[nI,1] + aDbfOp[nI,2]
            if nI == 1
               @prow()+1,  1 say &cData
            else
               @prow()  ,pcol()+1 say &cData
            endif
         next
         aTotal[1]++
         if SM3AANK->massa > 0
            aTotal[2]++
            aTotal[3] := aTotal[3] + SM3AANK->massa
         endif
         if SM3AANK->bedrag > 0
            aTotal[4]++
            aTotal[5] := aTotal[5] + SM3AANK->bedrag
         endif
      endif

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
      if prow() >= 58 .or. eof()

         //Print onderste lyn
         @prow()+1,  1 say repl( "=", 79 )

         if cLanType() == "A"
            @prow()+1,  1 say "Aantal diere: " + ltrim(str(aTotal[1],10,0))
            @prow()  ,  22 say "Diere met massas: " + ltrim(str(aTotal[2],10,0))
            @prow()  ,  50 say "Diere met bedrae: " + ltrim(str(aTotal[4],10,0))

            @prow()+1,  22 say "Totale massa    : " + ltrim(str(aTotal[3],10,0))
            @prow()  ,  50 say "Totale bedrag   : " + ltrim(str(aTotal[5],10,2))

            @prow()+1,  22 say "Gem. massa      : " + if(aTotal[2]>0, ltrim(str(aTotal[3]/aTotal[2],10,0)), "0" )
            @prow()  ,  50 say "Gem. bedrag     : " + if(aTotal[4]>0, ltrim(str(aTotal[5]/aTotal[4],10,2)), "0.00" )
         else
            @prow()+1,  1 say "No of animals: " + ltrim(str(aTotal[1],10,0))
            @prow()  ,  22 say "Animals with masses: " + ltrim(str(aTotal[2],10,0))
            @prow()  ,  50 say "Animals with values: " + ltrim(str(aTotal[4],10,0))

            @prow()+1,  22 say "Total mass      : " + ltrim(str(aTotal[3],10,0))
            @prow()  ,  50 say "Total value     : " + ltrim(str(aTotal[5],10,2))

            @prow()+1,  22 say "Average mass    : " + if(aTotal[2]>0, ltrim(str(aTotal[3]/aTotal[2],10,0)), "0" )
            @prow()  ,  50 say "Average value   : " + if(aTotal[4]>0, ltrim(str(aTotal[5]/aTotal[4],10,2)), "0.00" )
         endif

         @prow()+1,  1 say repl( "=", 79 )
         @prow()+1,  1 say cAppName()
         fPrnCod( cPrnNorm() )

         // Form Feed
         fPrnEjec()
         //@prow()+(nPrnLeng()-prow()),1 say ""
         //setprc( 0, 0 )

         nBladsy++

         //Indien eof()
         if eof()
            lLoop := .f.
         endif

      endif

   enddo

   fPrnOff()

   //Herstel
   select SM3AANK
   go top
   restscreen(0,0,24,79,cCurScr)
return NIL

